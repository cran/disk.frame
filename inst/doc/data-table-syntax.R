## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup_data_table, cache=TRUE---------------------------------------------
library(disk.frame)

# set-up disk.frame to use multiple workers
if(interactive()) {
  setup_disk.frame()
  # highly recommended, however it is pun into interactive() for CRAN because
  # change user options are not allowed on CRAN
  options(future.globals.maxSize = Inf)  
} else {
  setup_disk.frame(2)
}


library(nycflights13)

# create a disk.frame
flights.df = as.disk.frame(nycflights13::flights, outdir = file.path(tempdir(),"flights13"), overwrite = TRUE)

## ----ok, dependson='setup_data_table'-----------------------------------------
library(data.table)
library(disk.frame)

flights.df = disk.frame(file.path(tempdir(),"flights13"))

names(flights.df)

flights.df[,.N, .(year, month), keep = c("year", "month")]

## ----var_detect, dependson='setup_data_table'---------------------------------
y = 42 
some_fn <- function(x) x


flights.df[,some_fn(y)]

## ----clean_up, include=FALSE--------------------------------------------------
fs::dir_delete(file.path(tempdir(),"flights13"))

