#' Calculate match matrix
#'
#' @param hypothesis Observed string of text
#' @param reference True string of text
#' @param unit How edit distance should be calculated, if at all
#'
#' @return Matrix
#' @export
#'
match_matrix <- function(hypothesis, reference, unit = c("letter", "phon", "none")) {

  # Setup ====

  if (!missing(reference)) {
    reference <- clean_text(reference)
  }

  m_rows <- reference
  m_cols <- clean_text(hypothesis)

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
  r_missing_bins <- findInterval(missing_r_matches, c(0, vapply(r_bounds, max, double(1)), Inf))
  r_missing_sets <- split(missing_r_matches, r_missing_bins)

  edit_bins_2d <- intersect(names(c_missing_sets), names(r_missing_sets))

  edit_unit <- match.arg(unit)

  if (edit_unit != "none") {

    walk(edit_bins_2d, function(bin_chr) {
      c_set <- c_missing_sets[[bin_chr]]
      r_set <- r_missing_sets[[bin_chr]]

      col_words <- m_cols[c_set]
      row_words <- m_rows[r_set]

      edit_grid <- switch(
        edit_unit,
        "letter" = outer(row_words, col_words, stringdist::stringdist, method = "lv")
      )

      best_edits_grid <- grid_search_unique(edit_grid)
      dists <- edit_grid[which(best_edits_grid != Inf)]

      best_edits <- which(best_edits_grid != Inf, arr.ind = TRUE)
      c_ids <- c_set[best_edits[,"col"]]
      r_ids <- r_set[best_edits[,"row"]]

      walk(seq_along(dists), function(i) {
        m[r_ids[i], c_ids[i]] <<- dists[i]
      })

    })

  }

  m

}
