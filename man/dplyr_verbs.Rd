% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dplyr_verbs.r
\name{select.disk.frame}
\alias{select.disk.frame}
\alias{rename.disk.frame}
\alias{filter.disk.frame}
\alias{mutate.disk.frame}
\alias{transmute.disk.frame}
\alias{arrange.disk.frame}
\alias{chunk_arrange}
\alias{distinct.disk.frame}
\alias{chunk_distinct}
\alias{glimpse.disk.frame}
\title{The dplyr verbs implemented for disk.frame}
\usage{
\method{select}{disk.frame}(.data, ...)

\method{rename}{disk.frame}(.data, ...)

\method{filter}{disk.frame}(.data, ...)

\method{mutate}{disk.frame}(.data, ...)

\method{transmute}{disk.frame}(.data, ...)

\method{arrange}{disk.frame}(.data, ...)

chunk_arrange(.data, ...)

\method{distinct}{disk.frame}(...)

chunk_distinct(.data, ...)

\method{glimpse}{disk.frame}(x, width = NULL, ...)
}
\arguments{
\item{.data}{a disk.frame}

\item{...}{Same as the dplyr functions}

\item{x}{`dplyr::glimpse` parameter}

\item{width}{`dplyr::glimpse` parameter}
}
\description{
Please see the dplyr document for their usage. Please note
`chunk_arrange` performs the actions within each chunk
}
\examples{
library(dplyr)
cars.df = as.disk.frame(cars)
mult = 2

# use all any of the supported dplyr
cars2 = cars.df \%>\% 
  select(speed) \%>\% 
  mutate(speed2 = speed * mult) \%>\% 
  filter(speed < 50) \%>\% 
  rename(speed1 = speed) \%>\% 
  collect

# clean up cars.df
delete(cars.df)
}
\concept{dplyr verbs}
