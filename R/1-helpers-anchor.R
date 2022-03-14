anchor <- function(m_rows, m_cols, debug = FALSE) {
  dist_matrix <- outer(seq_along(m_rows), seq_along(m_cols), function(x, y) y - x )
  rownames(dist_matrix) <- m_rows
  colnames(dist_matrix) <- m_cols

  ci <- 1
  while (!ci > ncol(dist_matrix)) {
    ci_word <- m_cols[ci]
    ri <- collapse::whichv(dist_matrix[, ci], 0)
    ri_word <- m_rows[ri]

    # if (TRUE) {
    #   x <- dist_matrix[
    #     max(ri - 10, 1):min(ri + 10, nrow(dist_matrix)),
    #     max(ci - 10, 1):min(ci + 10, ncol(dist_matrix))
    #   ]
    #   print(hl_loc(x, "pink", ri, ci))
    #   print(paste("ri:", ri, "| ci:", ci))
    #   browser()
    # }

    # Move on if next observed is a duplicate but next match isn't
    if (
      (ci != length(m_cols) && ci_word == m_cols[ci + 1]) &&
      (ri != length(m_rows) && ri_word != m_rows[ri + 1])
    ) {
      dist_matrix[, ci] <- Inf
      ci <- ci + 1
    }
    # Search for best match
    else if (ci_word == ri_word) {
      dist_matrix[-ri, ci] <- Inf
      dist_matrix[ri, -ci] <- Inf
      ci <- ci + 1
    } else {
      next_match_rows <- which(m_rows == ci_word & seq_along(m_rows) > ri)
      next_match_cols <- which(m_cols == ri_word & seq_along(m_cols) > ci)
      if (length(next_match_rows) == 0) {
        # Insertion
        dist_matrix[, ci] <- Inf
        collapse::setop(dist_matrix, "-", 1)
        ci <- ci + 1
      } else if (length(next_match_cols) == 0) {
        # Deletion
        dist_matrix[ri, ] <- Inf
        collapse::setop(dist_matrix, "+", 1)
      } else {
        del_dist <- abs(dist_matrix[min(next_match_rows), ci])
        ins_dist <- abs(dist_matrix[ri, min(next_match_cols)])
        if (ins_dist < del_dist) {
          dist_matrix[, ci] <- Inf
          collapse::setop(dist_matrix, "-", 1)
          ci <- ci + 1
        } else {
          dist_matrix[ri, ] <- Inf
          collapse::setop(dist_matrix, "+", 1)
        }
      }
    }
  }

  collapse::setv(dist_matrix, Inf, NA_real_)
  collapse::setop(dist_matrix, 3, 0)

  dist_matrix

}
