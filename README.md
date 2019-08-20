
<!-- README.md is generated from README.Rmd. Please edit that file -->

# disk.frame

<!-- badges: start -->

![disk.frame logo](man/figures/disk.frame.png?raw=true
"disk.frame logo") <!-- badges: end -->

# Introduction

The `disk.frame` package aims to be the answer to the question: how do I
manipulate structured tabular data that doesn’t fit into Random Access
Memory (RAM)?

In a nutshell, `disk.frame` makes use of two simple ideas

1)  split up a larger-than-RAM dataset into chunks and store each chunk
    in a separate file inside a folder and
2)  provide a convenient API to manipulate these chunks

`disk.frame` performs a similar role to distributed systems such as
Apache Spark, Python’s Dask, and Julia’s JuliaDB.jl for *medium data*
which are datasets that are too large for RAM but not quite large enough
to qualify as *big data* that require distributing processing over many
computers to be effective.

## Installation

You can install the released version of disk.frame from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("disk.frame")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("xiaodaigh/disk.frame")
```

## Vignette

Please see this vignette [Introduction to
disk.frame](http://daizj.net/disk.frame/articles/intro-disk-frame.html)
which replicates the `sparklyr` vignette for manipulating the
`nycflights13` flights data.

## Common questions

### a) What is `disk.frame` and why create it?

`disk.frame` is an R package that provides a framework for manipulating
larger-than-RAM structured tabular data on disk efficiently. The reason
one would want to manipulate data on disk is that it allows arbitrarily
large datasets to be processed by R. In other words, we go from “R can
only deal with data that fits in RAM” to “R can deal with any data that
fits on disk”. See the next section.

### b) How is it different to `data.frame` and `data.table`?

A `data.frame` in R is an in-memory data structure, which means that R
must load the data in its entirety into RAM. A corollary of this is that
only data that can fit into RAM can be processed using `data.frame`s.
This places significant restrictions on what R can process with minimal
hassle.

In contrast, `disk.frame` provides a framework to store and manipulate
data on the hard drive. It does this by loading only a small part of the
data, called a chunk, into RAM; process the chunk, write out the results
and repeat with the next chunk. This chunking strategy is widely applied
in other packages to enable processing large amounts of data in R, for
example, see [`chunkded`](https://github.com/edwindj/chunked)
[`arkdb`](https://github.com/ropensci/arkdb), and
[`iotools`](https://github.com/s-u/iotools).

Furthermore, there is a row-limit of 2^31 for `data.frame`s in R; hence
an alternate approach is needed to apply R to these large datasets. The
chunking mechanism in `disk.frame` provides such an avenue to enable
data manipulation beyond the 2^31 row limit.

### c) How is `disk.frame` different to previous “big” data solutions for R?

R has many packages that can deal with larger-than-RAM datasets,
including `ff` and `bigmemory`. However, `ff` and `bigmemory` restrict
the user to primitive data types such as double, which means they do not
support character (string) and factor types. In contrast, `disk.frame`
makes use of `data.table::data.table` and `data.frame` directly, so all
data types are supported. Also, `disk.frame` strives to provide an API
that is as similar to `data.frame`’s where possible. `disk.frame`
supports many `dplyr` verbs for manipulating `disk.frame`s.

Additionally, `disk.frame` supports parallel data operations using
infrastructures provided by the excellent [`future`
package](https://CRAN.R-project.org/package=future) to take advantage of
multi-core CPUs. Further, `disk.frame` uses state-of-the-art data
storage techniques such as fast data compression, and random access to
rows and columns provided by the [`fst`
package](http://www.fstpackage.org/) to provide superior data
manipulation speeds.

### d) How does `disk.frame` work?

`disk.frame` works by breaking large datasets into smaller individual
chunks and storing the chunks in `fst` files inside a folder. Each chunk
is a `fst` file containing a `data.frame/data.table`. One can construct
the original large dataset by loading all the chunks into RAM and
row-bind all the chunks into one large `data.frame`. Of course, in
practice this isn’t always possible; hence why we store them as smaller
individual chunks.

`disk.frame` makes it easy to manipulate the underlying chunks by
implementing `dplyr` functions/verbs and other convenient functions
(e.g. the `map.disk.frame(a.disk.frame, fn, lazy = F)` function which
applies the function `fn` to each chunk of `a.disk.frame` in parallel).
So that `disk.frame` can be manipulated in a similar fashion to
in-memory `data.frame`s.

### e) How is `disk.frame` different from Spark, Dask, and JuliaDB.jl?

Spark is primarily a distributed system that also works on a single
machine. Dask is a Python package that is most similar to `disk.frame`,
and JuliaDB.jl is a Julia package. All three can distribute work over a
cluster of computers. However, `disk.frame` currently cannot distribute
data processes over many computers, and is, therefore, single machine
focused.

In R, one can access Spark via `sparklyr`, but that requires a Spark
cluster to be set up. On the other hand `disk.frame` requires zero-setup
apart from running `install.packages("disk.frame")` or
`devtools::install_github("xiaodaigh/disk.frame")`.

Finally, Spark can only apply functions that are implemented for Spark,
whereas `disk.frame` can use any function in R including user-defined
functions.

### f) How is `disk.frame` different from multidplyr, partools and distributedR?

The packages [multidplyr](https://github.com/tidyverse/multidplyr)
doesn’t seem to be disk-focussed and hence does not allow arbitrarily
large dataset to be manipulated; the focus on parallel processing is
similar to disk.frame though. For partools
\[<https://matloff.wordpress.com/2015/08/05/partools-a-sensible-r-package-for-large-data-sets/>\],
it seems to use it’s own verbs for aggregating data instead of relying
on existing verbs provided by data.table and dplyr. The package
[`distributedR`](https://github.com/vertica/DistributedR) hasn’t been
updated for a few years and also seems to require its own functions and
verbs.

## Set-up `disk.frame`

`disk.frame` works best if it can process multiple data chunks in
parallel. The best way to set-up `disk.frame` so that each CPU core runs
a background worker is by using

``` r
setup_disk.frame()

# this allows large datasets to be transferred between sessions
options(future.globals.maxSize = Inf)
```

The `setup_disk.frame()` sets up background workers equal to the number
of CPU cores; please note that, by default, hyper-threaded cores are
counted as one not two.

Alternatively, one may specify the number of workers using
`setup_disk.frame(workers = n)`.

# Example usage

``` r
library(dplyr)
library(disk.frame)
library(data.table)
library(fst)

# you need to run this to make multiple workers
# this will setup disk.frame's parallel backend with number of workers equal to the number of CPU cores (hyper-threaded cores are counted as one not two)
setup_disk.frame()
# this allows large datasets to be transferred between sessions
options(future.globals.maxSize = Inf)

rows_per_chunk = 1e7
# generate synthetic data
tmpdir = "tmpfst"
if(fs::dir_exists(tmpdir)) {
  fs::dir_delete(tmpdir)
}

# write out nworkers chunks
pt = proc.time()

df = disk.frame(tmpdir)

sapply(1:(nworkers*2), function(ii) {
  system.time(ab <- data.table(a = runif(rows_per_chunk), b = runif(rows_per_chunk)) ) #102 seconds
  add_chunk(df, ab, ii)
  NULL
})
cat("Generating data took: ", timetaken(pt), "\n")


# read and output the disk.frame as it to assess "sequential" read-write performance
pt = proc.time()
df2 <- map(df, ~.x, outdir = "tmpfst2", lazy = F, overwrite = T)
cat("Read and write took: ", timetaken(pt), "\n")

# get first few rows
head(df)

# get last few rows
tail(df)

# number of rows
nrow(df)

# number of columns
ncol(df)
```

## Example: dplyr verbs

``` r
df = disk.frame(tmpdir)

df %>%
  summarise(suma = sum(a)) %>% # this does a count per chunk
  collect(parallel = T)

# need a 2nd stage to finalise summing
df %>%
  summarise(suma = sum(a)) %>% # this does a count per chunk
  collect(parallel = T) %>% 
  summarise(suma = sum(suma)) 

# filter
pt = proc.time()
system.time(df_filtered <- df %>% 
              filter(a < 0.1))
cat("filtering a < 0.1 took: ", timetaken(pt), "\n")
nrow(df_filtered)
```

### Group by

Group-by in disk.frame are performed within each chunk, hence a
two-stage group by is required to obtain the correct group by results.
The two-stage approach is preferred for performance reasons too.

``` r
pt = proc.time()
res1 <- df %>% 
  filter(b < 0.1) %>% 
  mutate(blt005 = b < 0.05) %>% 
  group_by(blt005) %>% 
  summarise(suma = sum(a), n = n()) %>% 
  collect %>%
  group_by(blt005) %>% 
  summarise(suma = sum(suma), n = sum(n)) %>% 
cat("group by took: ", data.table::timetaken(pt), "\n")
```

However, a one-stage `group_by` is possible with a `hard_group_by` to
first rechunk the disk.frame. This **not** recommended for performance
reasons, as it can quite slow.

``` r
pt = proc.time()
res1 <- df %>% 
  filter(b < 0.1) %>% 
  mutate(blt005 = b < 0.05) %>% 
  hard_group_by(blt005) %>% # hard group_by is MUCH SLOWER but avoid a 2nd stage aggregation
  summarise(suma = sum(a), n = n()) %>% 
  collect(parallel = T)
cat("group by took: ", timetaken(pt), "\n")
```

### Other dplyr verbs

``` r
# keep only one var is faster
pt = proc.time()
res1 <- df %>% 
  srckeep("a") %>% #keeping only the column `a` from the input
  summarise(suma = sum(a), n = n()) %>% 
  collect(parallel = T)
cat("summarise keeping only one column ", timetaken(pt), "\n")

# same operation without keeping
pt = proc.time()
res1 <- df %>% 
  summarise(suma = sum(a), n = n()) %>% 
  collect(parallel = T)
cat("summarise without keeping", timetaken(pt), "\n")
```

## Example: data.table syntax

``` r
library(data.table)

# count by chunks
system.time(df_cnt_by_chunk <- df[,.N])
pt = proc.time()
system.time(sum(df[,.N])) # need a 2nd stage of summary
cat("sum(df[,.N]) took: ", timetaken(pt), "\n")

# filter
pt = proc.time()
system.time(df_filtered <- df[a < 0.1,])
cat("df[a < 0.1,] took: ", timetaken(pt), "\n")
nrow(df_filtered)

# group by
pt = proc.time()
system.time(res1 <- df[b < 0.1,.(sum_a = sum(a), .N), by = b < 0.05])
cat("df[b < 0.1,.(sum_a = sum(a), .N), by = b < 0.05] took: ", timetaken(pt), "\n")
# res1 has performed group by for each of the 4 chunks need to further summarise
system.time(res2 <- res1[, .(sum(sum_a), sum(N)),b][, .(mean_a = V1/V2), b])
res2 # abit painful to create mean, but currently only this low level interface; will do a dplyr on top later

# keep only one var is faster
pt = proc.time()
system.time(df[,.(sum(a)), keep = "a"][,sum(V1)]) # 1.17
cat("df[,.(sum(a)), keep = 'a'] took: ", timetaken(pt), "\n")

# same operation without keeping
pt = proc.time()
system.time(df[,.(sum(a))][,sum(V1)]) #2.95
cat("df[,.(sum(a))] took: ", timetaken(pt), "\n")
```

## Hex logo

![disk.frame logo](inst/figures/hex-logo.png?raw=true)

## Contributors

This project exists thanks to all the people who contribute.
<a href="https://github.com/xiaodaigh/disk.frame/graphs/contributors"><img src="https://opencollective.com/diskframe/contributors.svg?width=890&button=false" /></a>

## Open Collective

If you like disk.frame and want to speed up its development or perhaps
you have a feature request? Please considering sponsoring me on Open
Collective

### Backers

Thank you to all our backers\! 🙏 \[[Become a
backer](https://opencollective.com/diskframe#backer)\]

<a href="https://opencollective.com/diskframe#backers" target="_blank"><img src="https://opencollective.com/diskframe/backers.svg?width=890"></a>

[![Backers on Open
Collective](https://opencollective.com/diskframe/backers/badge.svg)](#backers)

### Sponsors

Support this project by becoming a sponsor. Your logo will show up here
with a link to your website. \[[Become a
sponsor](https://opencollective.com/diskframe#sponsor)\]

[![Sponsors on Open
Collective](https://opencollective.com/diskframe/sponsors/badge.svg)](#sponsors)

## Contact me for consulting

**Do you need help with machine learning and data science in R, Python,
or Julia?** [![Contact me on
Codementor](https://cdn.codementor.io/badges/contact_me_github.svg)](https://www.codementor.io/evalparse)

I am available for Machine Learning/Data Science/R/Python/Julia
consulting\! [Email me](mailto:dzj@analytixware.com) to get 10% discount
off the hourly rate.
