% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/map2.r, R/map_by_chunk_id.r
\name{cmap2}
\alias{cmap2}
\alias{map_by_chunk_id}
\title{`cmap2` a function to two disk.frames}
\usage{
cmap2(.x, .y, .f, ...)

map_by_chunk_id(.x, .y, .f, ..., outdir)
}
\arguments{
\item{.x}{a disk.frame}

\item{.y}{a disk.frame}

\item{.f}{a function to be called on each chunk of x and y matched by
chunk_id}

\item{...}{not used}

\item{outdir}{output directory}
}
\description{
Perform a function on both disk.frames .x and .y, each chunk of .x and .y
gets run by .f(x.chunk, y.chunk)
}
\examples{
cars.df = as.disk.frame(cars)

cars2.df = cmap2(cars.df, cars.df, ~data.table::rbindlist(list(.x, .y)))
collect(cars2.df)

# clean up cars.df
delete(cars.df)
delete(cars2.df)
}
