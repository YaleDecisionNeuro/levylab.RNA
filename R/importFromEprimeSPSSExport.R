#' Import a single subject's R&A choice data from a text file exported by E-Prime.
#'
#' @param filename A full file path to a .txt file exported by E-Prime as "SPSS and Statview file"
#' @param choiceColumnName The name of the E-Prime column in which the subject's choice is recorded
#' @param discardOriginalColumns Purge the additional E-Prime columns from the returned data frame?
#' @return A clean R&A data frame
#' @export
importFromEprimeSPSSExport <- function(filename, choiceColumnName = 'choice', discardOriginalColumns = FALSE) {
  # TODO: Ensure that it's not exported with Unicode? Use readr to detect it.
  # read.table('file.txt', header = TRUE, sep = '\t', as.is = TRUE, fileEncoding = 'UTF-16LE')
  choice_name <- paste0(quo_name(choiceColumnName), '.RESP')

  x <- read.delim(filename, skip = 1)
  x <- mutate(x, val = ifelse(BlueValue == 0, RedValue, BlueValue),
              refSide = ifelse(LotterySide == 'Left', 2, 1)) %>%
    rename(choice = !!choice_name) # FIXME: See rlang / "Programming with dplyr" vignette
  # Get choice = chose lottery or not
  x <- x %>% mutate(choicePress = choice, choice = ifelse(choice == 0, NA, choice != refSide))

  standard_cols <- getLevelsFromLotteryName(x$RiskAmbigLevel)
  ID <- as.numeric(str_match(filename, '\\d+')) # FIXME: Should attempt this, but fail gracefully
  standard_cols$ID <- ID
  x <- cbind(x, standard_cols)

  if (discardOriginalColumns) {
    x <- select(x, -Block, -TrialNum, -BagNo, -BlueValue, -RedValue,
                -ends_with('.RT'), -LotterySide, -RiskAmbigLevel)
    # FIXME: Should include rather than exclude
  }
  return(x)
}

#' From a filename of risk-and-ambiguity lottery display, extract kind and level of lottery
#'
#' @param name Filename in the format kind_winColor_numericalLevel (e.g. ambig_red_25.png)
#' @import stringr
#' @return A data frame with winProb, ambiguity, and winColor columns
getLevelsFromLotteryName <- function(name) {
  level <- as.numeric(stringr::str_match(name, '\\d+$'))
  kind <- as.character(stringr::str_match(name, '^[a-z]+'))
  winColor <- gsub('_', '', as.character(stringr::str_match(name, '_[a-z]+_')))

  ambig_trials <- kind == "ambig"
  p = level / 100
  a = 0 * level

  p[ambig_trials] = 0.5
  a[ambig_trials] = level[ambig_trials] / 100

  return(data.frame(p = p, al = a, winColor = winColor))
}
