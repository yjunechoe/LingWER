#' Visualize the Word Error Rate
#'
#' @param m Matrix
#'
#' @importFrom htmltools tags
#'
#' @return HTML
#' @export
draw_WER <- function(m) {

  doc_css <- "
    .highlighted {
      display: inline-block;
      position: relative;
      margin: 2px 1px;
      padding: 0px 5px;
      border-radius: 5px;
    }
    .sub {
      color: black;
      background-color: #eeb91b;
    }
    .del {
      color: white;
      background-color: #c05656;
    }
    .ins {
      color: white;
      background-color: #4181c8;
    }
    .wrapper {
      padding: 2rem;
      font-family: monospace;
    }
    .text-container {
      padding: 2rem;
      font-size: 16px;
      background-color: #d3d3d370;
      line-height: 1.5;
    }
    #tooltip {
      opacity: 0;
      position: absolute;
      top: -14px;
      left: 0;
      padding: 0.6em 1em;
      background: #fff;
      text-align: center;
      line-height: 1.6em;
      font-size: 1em;
      border: 1px solid #ddd;
      border-radius: 5px;
      z-index: 10;
      transition: all 0.1s ease-out;
      pointer-events: none;
    }
  "

  tooltip_js <- htmltools::HTML('
    const tooltip = document.querySelector("#tooltip")
    const subs = document.querySelectorAll(".sub")
    subs.forEach(sub => sub.addEventListener("mouseover", event => {
      textbox = event.currentTarget
      textboxPos = textbox.getBoundingClientRect()

      tooltip.textContent = textbox.getAttribute("data-info")
      tooltip.style.left = textboxPos.x + "px"
      tooltip.style.top = textboxPos.y + textbox.clientHeight + 3 + "px"
      tooltip.style.opacity = 1
    }))
    subs.forEach(sub => sub.addEventListener("mouseout", event => {
      tooltip.style.opacity = 0
    }))
  ')

  match <- which(m == 0, arr.ind = TRUE)[,2]
  sub <- which(apply(m, 2, function(x) any(x > 0)))
  del <- which(is.na(collapse::fmin(t(m))))
  ins <- which(is.na(collapse::fmin(m)))

  metrics <- get_metrics(m)
  sub_tooltip <- paste0(metrics$info$edit_distance, '-char edit from "',
                        metrics$info$substitutions, '"')

  names(sub) <- sapply(seq_along(sub), function(x) {
    as.character(tags$span(names(sub)[x], class = c("highlighted", "sub"),
                           "data-info" = sub_tooltip[x]))
  })
  names(del) <- sapply(names(del), function(x) as.character(tags$span(x, class = c("highlighted", "del"))))
  names(ins) <- sapply(names(ins), function(x) as.character(tags$span(x, class = c("highlighted", "ins"))))

  # Positioning

  # TODO do this for R -> C slotting (basically deletions instead of insertions)
  del_slot_positions <- vapply(del, function(x) {
    prev_matches <- which(m[seq_len(x), ] >= 0, arr.ind = TRUE)
    if (length(prev_matches) > 0) {
      prev_matches[nrow(prev_matches), 2]
    } else {
      del[x]
    }
  }, double(1))
  all_words <- c(sort(c(match, sub, ins)), del)
  all_words_order <- order(c(seq_len(ncol(m)), del_slot_positions + 0.5))
  all_words_sorted <- all_words[all_words_order]

  text <- names(all_words_sorted)

  doc <- tags$html(
    tags$style(type = "text/css", doc_css),
    tags$div(
      tags$div(id = "tooltip"),
      tags$div(htmltools::HTML(text), class = "text-container"),
      class = "wrapper"
    ),
    tags$script(tooltip_js)
  )

  class(doc) <- c("wer", "shiny.tag")

  doc

}

#' @export
print.wer <- function(x, ...) {
  htmltools::html_print(x)
}

