grid_search_unique <- function(d) {

  if (max(dim(d)) == 1) {
    return(d)
  }

  wide <- !is.unsorted(dim(d))
  if (wide) {
    copy <- t(d)
  } else {
    copy <- d
  }

  for (i in seq_len(ncol(copy))) {
    anchor <- which.min(copy[, i])
    # If non-unique matches exist
    if (!min(collapse::funique(c(copy[-anchor, i], copy[anchor, -i], Inf))) == Inf) {
      this_dist <- copy[anchor, i]
      next_row <- min(anchor + 1, nrow(copy))
      next_col <- min(i + 1, ncol(copy))
      next_dist <- copy[anchor, next_col]
      # Does next candidate/column have smaller distance to truth/row?
      if (next_dist < this_dist) {
        # If it this truth the next candidate's best match too? If so give it to next candidate
        if (next_dist == min(copy[, next_col])) {
          # see if you can fallback to second best match
          if (anchor > 1 && copy[anchor - 1, i] != Inf) {
            copy[-(anchor - 1), i] <- Inf
          } else {
            # otherwise no match for this word
            copy[, i] <- Inf
          }
        } else {
          # If next candidate has better matches, match this truth to current candidate
          copy[-anchor, i] <- Inf
          copy[anchor, -i] <- Inf
        }
      } else {
        prev_row <- anchor - 1
        # If no better match to row/truth, proceed
        if (ncol(copy) == 1 || collapse::fmin(copy[anchor, i]) == this_dist) {
          copy[-anchor, i] <- Inf
          copy[anchor, -i] <- Inf
        } else {
          # Is tl-br possible?
          if (all(dim(copy) >= 2) && prev_row > 0 && collapse::fmax(next_dist, copy[prev_row, i]) != Inf) {
            ## If at the last 2x2 corner of the grid, force tl-br and maximize match
            if (all(c(anchor, next_col) == dim(copy))) {
              copy[-prev_row, i] <- Inf
              copy[prev_row, -i] <- Inf
            } else {
              tl <- copy[prev_row, i]
              bbr <- copy[anchor + 1, i + 1]
              # Is tl-br optimal?
              if ((tl + next_dist) <= (this_dist + bbr)) {
                copy[-prev_row, i] <- Inf
                copy[prev_row, -i] <- Inf
              } else {
                copy[-anchor, i] <- Inf
                copy[anchor, -i] <- Inf
              }
            }
          } else {
            # If tl-br is impossible, just take it
            copy[-anchor, i] <- Inf
            copy[anchor, -i] <- Inf
          }
        }
      }
    }
  }
  if (wide) { copy <- t(copy) }
  copy
}
