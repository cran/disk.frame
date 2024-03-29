% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dplyr_verbs.r
\name{chunk_summarize}
\alias{chunk_summarize}
\alias{chunk_summarise}
\alias{chunk_group_by}
\alias{chunk_ungroup}
\title{#' @export
#' @importFrom dplyr add_count
#' @rdname dplyr_verbs
add_count.disk.frame <- create_chunk_mapper(dplyr::add_count)
#' @export
#' @importFrom dplyr add_tally
#' @rdname dplyr_verbs
add_tally.disk.frame <- create_chunk_mapper(dplyr::add_tally)}
\usage{
chunk_summarize(.data, ...)

chunk_summarise(.data, ...)

chunk_group_by(.data, ...)

chunk_ungroup(.data, ...)
}
\arguments{
\item{.data}{a disk.frame}

\item{...}{passed to dplyr::group_by}
}
\description{
The disk.frame group by operation perform group WITHIN each chunk. This is
often used for performance reasons. If the user wishes to perform group-by,
they may choose to use the `hard_group_by` function which is expensive as it
reorganizes the chunks by the shard key.
}
\seealso{
hard_group_by group_by
}
