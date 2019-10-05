## ----setup, include = FALSE----------------------------------------------
library(disk.frame)
library(fst)
library(magrittr)
library(nycflights13)
library(dplyr)
library(data.table)

# you need to run this for multi-worker support
# limit to 2 cores if not running interactively; most likely on CRAN
# set-up disk.frame to use multiple workers
if(interactive()) {
  setup_disk.frame()
  # highly recommended, however it is pun into interactive() for CRAN because
  # change user options are not allowed on CRAN
  options(future.globals.maxSize = Inf)  
} else {
  setup_disk.frame(2)
}


knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----asdiskframe, cache=TRUE---------------------------------------------
library(nycflights13)
library(dplyr)
library(disk.frame)
library(data.table)

# convert the flights data to a disk.frame and store the disk.frame in the folder
# "tmp_flights" and overwrite any content if needed
flights.df <- as.disk.frame(
  flights, 
  outdir = file.path(tempdir(), "tmp_flights.df"),
  overwrite = TRUE)
flights.df

## ------------------------------------------------------------------------
library(nycflights13)
# write a csv
csv_path = file.path(tempdir(), "tmp_flights.csv")
data.table::fwrite(flights, csv_path)

# load the csv into a disk.frame
df_path = file.path(tempdir(), "tmp_flights.df")
flights.df <- csv_to_disk.frame(
  csv_path, 
  outdir = df_path,
  overwrite = T)
  
flights.df

## ------------------------------------------------------------------------
library(nycflights13)
library(disk.frame)

# write a csv
csv_path = file.path(tempdir(), "tmp_flights.csv")

data.table::fwrite(flights, csv_path)

df_path = file.path(tempdir(), "tmp_flights.df")

flights.df <- csv_to_disk.frame(
  csv_path, 
  outdir = df_path, 
  in_chunk_size = 100000)
  
flights.df

## ----dfselect, dependson='asdiskframe', cache=TRUE-----------------------
flights.df1 <- select(flights.df, year:day, arr_delay, dep_delay)
flights.df1

## ----dependson='dfselect'------------------------------------------------
class(flights.df1)

## ---- dependson='dfselect'-----------------------------------------------
collect(flights.df1) %>% head

## ---- dependson='asdiskframe'--------------------------------------------
filter(flights.df, dep_delay > 1000) %>% collect %>% head

## ---- dependson='asdiskframe'--------------------------------------------
mutate(flights.df, speed = distance / air_time * 60) %>% collect %>% head

## ---- dependson='asdiskframe'--------------------------------------------
# this only sorts within each chunk
chunk_arrange(flights.df, dplyr::desc(dep_delay)) %>% collect %>% head

## ---- dependson='asdiskframe'--------------------------------------------
chunk_summarize(flights.df, mean_dep_delay = mean(dep_delay, na.rm =T)) %>% collect

## ---- dependson='asdiskframe'--------------------------------------------
c4 <- flights %>%
  filter(month == 5, day == 17, carrier %in% c('UA', 'WN', 'AA', 'DL')) %>%
  select(carrier, dep_delay, air_time, distance) %>%
  mutate(air_time_hours = air_time / 60) %>%
  collect %>%
  arrange(carrier)# arrange should occur after `collect`

c4  %>% head

## ---- dependson='asdiskframe'--------------------------------------------
flights.df %>%
  hard_group_by(carrier) %>% # notice that hard_group_by needs to be set
  chunk_summarize(count = n(), mean_dep_delay = mean(dep_delay, na.rm=T)) %>%  # mean follows normal R rules
  collect %>% 
  arrange(carrier)

## ---- dependson='asdiskframe'--------------------------------------------
flights.df %>%
  chunk_group_by(carrier) %>% # `chunk_group_by` aggregates within each chunk
  chunk_summarize(count = n()) %>%  # mean follows normal R rules
  collect %>%  # collect each individul chunks results and row-bind into a data.table
  group_by(carrier) %>% 
  summarize(count = sum(count)) %>% 
  arrange(carrier)

## ---- dependson='asdiskframe'--------------------------------------------
flights.df %>%
  srckeep(c("carrier","dep_delay")) %>%
  hard_group_by(carrier) %>% 
  chunk_summarize(count = n(), mean_dep_delay = mean(dep_delay, na.rm=T)) %>%  # mean follows normal R rules
  collect

## ----airlines_dt, dependson='asdiskframe', cache=TRUE--------------------
# make airlines a data.table
airlines.dt <- data.table(airlines)
# flights %>% left_join(airlines, by = "carrier") #
flights.df %>% 
  left_join(airlines.dt, by ="carrier") %>% 
  collect %>% 
  head

## ---- dependson='airlines_dt'--------------------------------------------
flights.df %>% 
  left_join(airlines.dt, by = c("carrier", "carrier")) %>% 
  collect %>% 
  tail

## ---- dependson='asdiskframe'--------------------------------------------
# Find the most and least delayed flight each day
bestworst <- flights.df %>%
   srckeep(c("year","month","day", "dep_delay")) %>%
   chunk_group_by(year, month, day) %>%
   select(dep_delay) %>%
   filter(dep_delay == min(dep_delay, na.rm = T) || dep_delay == max(dep_delay, na.rm = T)) %>%
   collect
   

bestworst %>% head

## ---- dependson='asdiskframe'--------------------------------------------
# Rank each flight within a daily
ranked <- flights.df %>%
  srckeep(c("year","month","day", "dep_delay")) %>%
  chunk_group_by(year, month, day) %>%
  select(dep_delay) %>%
  mutate(rank = rank(desc(dep_delay))) %>%
  collect

ranked %>% head

## ---- dependson='asdiskframe'--------------------------------------------
flights.df1 <- delayed(flights.df, ~nrow(.x))
collect_list(flights.df1) %>% head # returns number of rows for each data.frame in a list

## ---- dependson='asdiskframe'--------------------------------------------
map(flights.df, ~nrow(.x), lazy = F) %>% head

## ---- dependson='asdiskframe'--------------------------------------------
# return the first 10 rows of each chunk
flights.df2 <- map(flights.df, ~.x[1:10,], lazy = F, outdir = file.path(tempdir(), "tmp2"), overwrite = T)

flights.df2 %>% head

## ---- dependson='asdiskframe'--------------------------------------------
flights.df %>% sample_frac(0.01) %>% collect %>% head

## ----cleanup-------------------------------------------------------------
fs::dir_delete(file.path(tempdir(), "tmp_flights.df"))
fs::dir_delete(file.path(tempdir(), "tmp2"))
fs::file_delete(file.path(tempdir(), "tmp_flights.csv"))

