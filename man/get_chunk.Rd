% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_chunk.r
\name{get_chunk}
\alias{get_chunk}
\alias{get_chunk.disk.frame}
\title{Obtain one chunk by chunk id}
\usage{
get_chunk(...)

\method{get_chunk}{disk.frame}(df, n, keep = NULL, full.names = FALSE, ..., partitioned_info = NULL)
}
\arguments{
\item{...}{passed to fst::read_fst or whichever read function is used in the backend}

\item{df}{a disk.frame}

\item{n}{the chunk id. If numeric then matches by number, if character then returns the chunk with the same name as n}

\item{keep}{the columns to keep}

\item{full.names}{whether n is the full path to the chunks or just a relative path file name. Ignored if n is numeric}

\item{partitioned_info}{for internal use only. It's a data.frame used to help with filtering by partitions}
}
\description{
Obtain one chunk by chunk id
}
\examples{
cars.df = as.disk.frame(cars, nchunks = 2)
get_chunk(cars.df, 1)
get_chunk(cars.df, 2)
get_chunk(cars.df, 1, keep = "speed")

# if full.names = TRUE then the full path to the chunk need to be provided
get_chunk(cars.df, file.path(attr(cars.df, "path"), "1.fst"), full.names = TRUE)

# clean up cars.df
delete(cars.df)
}
