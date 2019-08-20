#' Write disk.frame to disk
#' @description 
#' Write a data.frame/disk.frame to a disk.frame location. If df is a
#' data.frame, then df must contain the column .out.disk.frame.id. This is
#' intended to be a low-level version of writing disk.frames. Using the
#' as.disk.frame function is recommended for most cases
#' @param df a disk.frame
#' @param outdir output directory for the disk.frame
#' @param nchunks number of chunks
#' @param overwrite overwrite output directory
#' @param shardby the columns to shard by
#' @param compress compression ratio for fst files
#' @param ... passed to map.disk.frame
#' @export
#' @import fst fs
#' @importFrom glue glue
#' @examples
#' cars.df = as.disk.frame(cars)
#' 
#' # write out a lazy disk.frame to disk
#' cars2.df = write_disk.frame(map(cars.df, ~.x[1,]), overwrite = TRUE)
#' collect(cars2.df)
#' 
#' # clean up cars.df
#' delete(cars.df)
#' delete(cars2.df)
write_disk.frame <- function(df, outdir = tempfile(fileext = ".df"), nchunks = nchunks.disk.frame(df), overwrite = FALSE, shardby=NULL, compress = 50, ...) {
  overwrite_check(outdir, overwrite)

  if(is.null(outdir)) {
    stop("outdir must not be NULL")
  }
  
  if(is_disk.frame(df)) {
    map.disk.frame(df, ~.x, outdir = outdir, lazy = FALSE, ..., compress = compress, overwrite = overwrite)
  } else if ("data.frame" %in% class(df)) {
    df[,{
      if (base::nrow(.SD) > 0) {
        fst::write_fst(.SD, file.path(outdir, paste0(.BY, ".fst")), compress = compress)
        NULL
      }
      NULL
    }, .out.disk.frame.id]
    res = disk.frame(outdir)
    add_meta(res, shardkey = shardby, shardchunks = nchunks, compress = compress)
  } else {
    stop("write_disk.frame error: df must be a disk.frame or data.frame")
  }
}

#' @rdname write_disk.frame
output_disk.frame <- function(...) {
  warning("output_disk.frame is DEPRECATED. Use write_disk.frame istead")
  write_disk.frame(...)
}