
<!-- README.md is generated from README.Rmd. Please edit that file -->

# LingWER

<!-- badges: start -->
<!-- badges: end -->

The goal of LingWER is to …

## Installation

You can install the development version of LingWER from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("yjunechoe/LingWER")
```

## Example

``` r
library(LingWER)

stella_sentence_truth <- "
  Please call Stella. Ask her to bring these things with her from the store:
  Six spoons of fresh snow peas, five thick slabs of blue cheese, and maybe
  a snack for her brother Bob. We also need a small plastic snake and a big
  toy frog for the kids. She can scoop these things into three red bags,
  and we will go meet her Wednesday at the train station.
"

stella_sentence_observed <- "
  Please castella asked her to bring these things with her from the store.
  Six pounds of fresh snow peas, five six slabs of blue cheese and maybe
  a snake for her brother Bob will also need a small plastic snake and a big
  toy frog for the case. She can scoop these things into three red bags
  and we will go meet her Wednesday at the train station.
"

stella_matrix <- match_matrix(stella_sentence_observed, stella_sentence_truth, unit = "letter")

# Truth x Observed
dim(stella_matrix)
#> [1] 69 68
rownames(stella_matrix)
#>  [1] "please"    "call"      "stella"    "ask"       "her"       "to"       
#>  [7] "bring"     "these"     "things"    "with"      "her"       "from"     
#> [13] "the"       "store"     "six"       "spoons"    "of"        "fresh"    
#> [19] "snow"      "peas"      "five"      "thick"     "slabs"     "of"       
#> [25] "blue"      "cheese"    "and"       "maybe"     "a"         "snack"    
#> [31] "for"       "her"       "brother"   "bob"       "we"        "also"     
#> [37] "need"      "a"         "small"     "plastic"   "snake"     "and"      
#> [43] "a"         "big"       "toy"       "frog"      "for"       "the"      
#> [49] "kids"      "she"       "can"       "scoop"     "these"     "things"   
#> [55] "into"      "three"     "red"       "bags"      "and"       "we"       
#> [61] "will"      "go"        "meet"      "her"       "wednesday" "at"       
#> [67] "the"       "train"     "station"
colnames(stella_matrix)
#>  [1] "please"    "castella"  "asked"     "her"       "to"        "bring"    
#>  [7] "these"     "things"    "with"      "her"       "from"      "the"      
#> [13] "store"     "six"       "pounds"    "of"        "fresh"     "snow"     
#> [19] "peas"      "five"      "six"       "slabs"     "of"        "blue"     
#> [25] "cheese"    "and"       "maybe"     "a"         "snake"     "for"      
#> [31] "her"       "brother"   "bob"       "will"      "also"      "need"     
#> [37] "a"         "small"     "plastic"   "snake"     "and"       "a"        
#> [43] "big"       "toy"       "frog"      "for"       "the"       "case"     
#> [49] "she"       "can"       "scoop"     "these"     "things"    "into"     
#> [55] "three"     "red"       "bags"      "and"       "we"        "will"     
#> [61] "go"        "meet"      "her"       "wednesday" "at"        "the"      
#> [67] "train"     "station"

get_metrics(stella_matrix)
#> $WER
#> [1] 0.115942
#> 
#> $info
#> $info$substitutions
#> castella    asked   pounds      six    snake     will     case 
#> "stella"    "ask" "spoons"  "thick"  "snack"     "we"   "kids" 
#> 
#> $info$edit_distance
#> [1] 2 2 3 4 2 3 4
#> 
#> $info$deletions
#> [1] "call"
#> 
#> $info$insertions
#> character(0)

draw_WER(stella_matrix)
```

<html>
<style type="text/css">
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
  </style>
<div class="wrapper">
<div id="tooltip"></div>
<div class="text-container">please <span class="highlighted del">call</span> <span class="highlighted sub" data-info="2-char edit from &quot;stella&quot;">castella</span> <span class="highlighted sub" data-info="2-char edit from &quot;ask&quot;">asked</span> her to bring these things with her from the store six <span class="highlighted sub" data-info="3-char edit from &quot;spoons&quot;">pounds</span> of fresh snow peas five <span class="highlighted sub" data-info="4-char edit from &quot;thick&quot;">six</span> slabs of blue cheese and maybe a <span class="highlighted sub" data-info="2-char edit from &quot;snack&quot;">snake</span> for her brother bob <span class="highlighted sub" data-info="3-char edit from &quot;we&quot;">will</span> also need a small plastic snake and a big toy frog for the <span class="highlighted sub" data-info="4-char edit from &quot;kids&quot;">case</span> she can scoop these things into three red bags and we will go meet her wednesday at the train station</div>
</div>
<script>
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
  </script>
</html>
