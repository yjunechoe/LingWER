#' Extract metrics from match matrix
#'
#' @param m Matrix
#'
#' @return List
#' @export
get_metrics <- function(m) {
  s <- which(m > 0)
  s_pairs <- which(m > 0, arr.ind = TRUE)
  d <- apply(m, 1, function(x) all(is.na(x)))
  i <- apply(m, 2, function(x) all(is.na(x)))

  S <- length(s)
  D <- sum(d)
  I <- sum(i)
  N <- nrow(m)

  WER <- (S + D + I) / N

  info <- list(
    substitutions = stats::setNames(rownames(m)[s_pairs[,"row"]], colnames(m)[s_pairs[,"col"]]),
    edit_distance = m[s],
    deletions     = rownames(m)[d],
    insertions    = colnames(m)[i]
  )

  list(
    WER = WER,
    info = info
  )

}
