% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/chunk_mapper.r
\name{create_chunk_mapper}
\alias{create_chunk_mapper}
\title{Create function that applies to each chunk if disk.frame}
\usage{
create_chunk_mapper(chunk_fn, warning_msg = NULL, as.data.frame = FALSE)
}
\arguments{
\item{chunk_fn}{The dplyr function to create a mapper for}

\item{warning_msg}{The warning message to display when invoking the mapper}

\item{as.data.frame}{force the input chunk of a data.frame; needed for dtplyr}
}
\description{
A function to make it easier to create functions like \code{filter}
}
\examples{

filter = create_chunk_mapper(dplyr::filter)

#' example: creating a function that keeps only the first and last n row
first_and_last <- function(chunk, n, ...) {
  nr = nrow(chunk)
  print(nr-n+1:nr)
  chunk[c(1:n, (nr-n+1):nr), ]
}

#' create the function for use with disk.frame
first_and_last_df = create_chunk_mapper(first_and_last)

mtcars.df = as.disk.frame(mtcars)

#' the operation is lazy
lazy_mtcars.df = mtcars.df \%>\%
  first_and_last_df(2)

#' bring into R
collect(lazy_mtcars.df)

#' clean up
delete(mtcars.df)

}
