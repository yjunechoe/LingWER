#' Calculate match matrix
#'
#' @param hypothesis Observed string of text
#' @param reference True string of text
#' @param clean Whether to apply `clean_text()` to the text inputs
#' @param unit How edit distance should be calculated, if at all
#' @param out Whether to return the matrix (`"matrix"`) or a dataframe of edits (`"edit"`)
#'
#' @return Matrix
#' @export
#'
match_matrix <- function(hypothesis, reference, clean = TRUE, unit = c("word", "letter", "phon", "none"), out = c("matrix", "edits")) {

  # Setup ====

  m_rows <- reference
  m_cols <- hypothesis

  if (clean) {
    m_rows <- clean_text(m_rows)
    m_cols <- clean_text(m_cols)
  }

  n_rows <- length(m_rows)
  n_cols <- length(m_cols)

  # Stems ----
  # unique_words_observed <- m_cols[!m_cols %in% names(comma_truth_stems)]
  # stem_dictionary <- c(comma_truth_stems, stats::setNames(wordStem(unique_words_observed, "english"), unique_words_observed))

  m <- anchor(m_rows, m_cols)

  # Compute phone distance edits for non-matches ====
  # TODO special handling for stopwords that are light

  missing_c_matches <- collapse::whichNA(collapse::fmin(m))
  missing_r_matches <- collapse::whichNA(collapse::fmin(t(m)))
  # pm[missing_r_matches, missing_c_matches, drop = FALSE]

  c_missing_sets <- split(missing_c_matches, cumsum(c(1, diff(missing_c_matches) != 1)))
  r_bounds <- lapply(c_missing_sets, function(c_set) {
    r_min <- max(collapse::whichv(m[, max(collapse::fmin(c_set) - 1, 1)], 0), 1)
    r_max <- min(collapse::whichv(m[, min(collapse::fmax(c_set) + 1, n_cols)], 0), Inf)
    c(r_min, r_max)
  })
  r_missing_as_edits <- vapply(missing_r_matches, function(x) {
    any(vapply(r_bounds, function(b) { x > b[1] && x < b[2] }, logical(1)))
  }, logical(1))
  missing_r_matches <- missing_r_matches[r_missing_as_edits]
  r_missing_bins <- findInterval(missing_r_matches, c(0, vapply(r_bounds, max, double(1)), Inf))
  r_missing_sets <- split(missing_r_matches, r_missing_bins)

  edit_bins_2d <- intersect(names(c_missing_sets), names(r_missing_sets))

  edit_unit <- match.arg(unit)
  out <- match.arg(out)

  edits <- lapply(edit_bins_2d, function(bin_chr) {
    c_set <- c_missing_sets[[bin_chr]]
    r_set <- r_missing_sets[[bin_chr]]

    col_words <- m_cols[c_set]
    row_words <- m_rows[r_set]

    edit_grid <- switch(
      edit_unit,
      "none"   = outer(row_words, col_words, function(x, y) rep(Inf, length(x))),
      "letter" = outer(row_words, col_words, stringdist::stringdist, method = "lv"),
      "word"   = ifelse(outer(seq_along(row_words), seq_along(col_words), `==`), 1L, Inf)
    )

    rownames(edit_grid) <- row_words
    colnames(edit_grid) <- col_words

    best_edits_grid <- grid_search_unique(edit_grid)
    dists <- edit_grid[which(best_edits_grid != Inf)]

    best_edits <- which(best_edits_grid != Inf, arr.ind = TRUE)
    c_ids <- c_set[best_edits[,"col"]]
    r_ids <- r_set[best_edits[,"row"]]

    walk(seq_along(dists), function(i) {
      m[r_ids[i], c_ids[i]] <<- dists[i]
    })

    if (length(dists) != 0) {
      data.frame(
        idx      = c_set[1],
        truth    = paste(rownames(edit_grid), collapse = " "),
        observed = paste(colnames(edit_grid), collapse = " ")
      )
    }

  })

  switch(
    out,
    "matrix" = m,
    "edits"  = do.call(rbind, edits)
  )

}
