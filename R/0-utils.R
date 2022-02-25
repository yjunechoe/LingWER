walk <- function(.x, .f, ...) {
  for (idx in seq_along(.x)) .f(.x[[idx]], ...)
  invisible(.x)
}
