contractions <- lapply(lexicon::key_contractions, tolower)

#' Clean up text
#'
#' @param string Length-1 character
#' @param expand_contractions Whether to expand contractions. Defaults to `TRUE`
#'
#' @return Character
#' @export
#'
clean_text <- function(string, expand_contractions = TRUE) {
  trimmed <- stringi::stri_replace_all_regex(stringi::stri_replace_all_regex(string, "(^\\s+|\\s+$)", ""), "\\s+", " ")
  sentences <- stringi::stri_extract_all_regex(trimmed, "[^.?!]+")[[1]]
  sentences_trimmed <- stringi::stri_replace_all_regex(sentences, "(^+\\s|\\s+$)", "")
  punct_removed <- stringi::stri_replace_all_regex(sentences_trimmed, "[:;,\"\"]", "")
  squished <- stringi::stri_replace_all_regex(punct_removed, "\\s+", " ")
  sentence_words <- lapply(squished, function(x) {
    lowercase <- stringi::stri_trans_tolower(x)
    lowercase_split <- stringi::stri_split_regex(lowercase, "(\\s|-)")[[1]]
    words <- if (expand_contractions) {
      lapply(lowercase_split, function(y) {
        m <- match(y, contractions$contraction)
        if (!is.na(m)) {
          contractions$expanded[m]
        } else {
          y
        }
      })
    } else {
      unlist(lowercase_split, use.names = FALSE)
    }
    stringi::stri_split_fixed(stringi::stri_flatten(words, collapse = " "), " ")[[1]]
  })
  sentence_words <- unlist(sentence_words, use.names = FALSE, recursive = FALSE)
  ifelse(sentence_words %in% contractions$contraction, sentence_words,
         stringi::stri_replace_all_regex(sentence_words, "[[:punct:]]", ""))
}

# Dictionaries ----
get_phones <- function(word, keep_stresses = FALSE, squish = FALSE) {
  if (keep_stresses) {
    cmu_dict <- phon::cmudict
  }
  else {
    cmu_dict <- get("cmudict_san_stresses", envir = getOption("phon_env"))
  }
  phons <- cmu_dict[names(cmu_dict) %in% word]
  phons <- phons[!duplicated(names(phons))][word] # Multiple pronunciation is possible
  if (squish) {
    phons <- stringi::stri_replace_all_fixed(phons, " ", "")
  }
  phons
}

# Stella sentence profile ---
# stella_truth_clean <- clean_text(stella_truth)
# stella_stems <- stats::setNames(SnowballC::wordStem(unique(stella_truth_clean), "english"), unique(stella_truth_clean))
# stella_phones <- get_phones(sort(unique(stella_truth_clean)))
# stella_syl <- lapply(get_phones(sort(unique(stella_truth_clean)), keep_stresses = TRUE), syllabify)
