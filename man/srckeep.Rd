% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/srckeep.disk.frame.r
\name{srckeep}
\alias{srckeep}
\title{Keep only the variables from the input listed in selections}
\usage{
srckeep(diskf, selections, ...)
}
\arguments{
\item{diskf}{a disk.frame}

\item{selections}{The list of variables to keep from the input source}

\item{...}{not yet used}
}
\description{
Keep only the variables from the input listed in selections
}
\examples{
cars.df = as.disk.frame(cars)

# when loading cars's chunks into RAM, load only the column speed
collect(srckeep(cars.df, "speed"))

# clean up cars.df
delete(cars.df)
}
