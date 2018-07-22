#' parse a decision tree in randomForest into list of path as data.frame
#'
#' @param forest  an object of ensemble trees to be parsed. See \code{\link{randomForest}} or \code{\link{xgboost}}.
#' @param ktree   an integer. number of decision tree to be parsed. If ktree=NULL (default), all tree will be parsed.
#' @param resample Logical. If TRUE, trees are ramdomly selected. If FALSE, trees are selected according to head(ktree) from forest.
#'
#' @return        a list of trees (list).
#'
#' @examples
#' \dontrun{
#' data(Groceries)
#' glo.apriori <- apriori(Groceries, parameter = list(confidence=0.01, support=0.01, maxlen=5, minlen=2))
#' glo.inspectDF  <- inspectDF(glo.apriori)
#' glo.inspectDF %>% head
#' }
#'
#' @importFrom magrittr %>%
#'
#' @export
magrittr::`%>%`

inspectDF <- function(rules, sep = ","){
  stopifnot("rules" %in% class(data))

  lhs = arules::labels(arules::lhs(rules), sep, "", "")
  rhs = arules::labels(arules::rhs(rules), sep, "", "")
  quality = arules::quality(rules)

  rules <- cbind(lhs, rhs, quality) %>%
    dplyr::arrange(support, confidence, lift) %>%
    dplyr::mutate(rule = paste("Rule",row_number()),
                  LHS = as.character(lhs),
                  RHS = as.character(rhs)) %>%
    dplyr::select(rule, LHS, RHS, everything()) %>%
    dplyr::select(-lhs, -rhs)

  return(rules)
}

