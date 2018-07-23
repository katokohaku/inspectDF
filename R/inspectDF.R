#' obtain rules as data.frame from arules instead of original inspect().
#'
#' @param rules  a rule object of  \code{\link{arules}}.
#' @param sep  string. items in rule string will be separated by sep.
#'
#' @return  a data frame of rules.
#'
#' @examples
#' \dontrun{
#' data(Groceries)
#'
#' pars <- list(confidence=0.01, support=0.01, maxlen=5, minlen=2)
#' glo.apriori <- apriori(Groceries, parameter = pars)
#'
#' glo.inspectDF  <- inspectDF(glo.apriori)
#' glo.inspectDF %>% head
#' }
#'
#' @importFrom magrittr %>%
#'
#' @export

inspectDF <- function(rules, sep = ","){
  stopifnot("rules" %in% class(rules))

  LHS = arules::labels(arules::lhs(rules), sep, "", "")
  RHS = arules::labels(arules::rhs(rules), sep, "", "")
  quality = arules::quality(rules)

  rules <- cbind(LHS, RHS, quality) %>%
    dplyr::arrange(support, confidence, lift) %>%
    dplyr::mutate(rule = paste("Rule", dplyr::row_number()),
                  LHS = as.character(LHS),
                  RHS = as.character(RHS),
                  n = stringr::str_count(LHS, pattern = sep) +1) %>%
    dplyr::select(rule, LHS, RHS, n, dplyr::everything())

  return(rules)
}

