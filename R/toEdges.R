#' convert rule data.frame to input for graph.data.frame (with from and to colmn).
#'
#' @param rules.data.frame  an object of inspectDf, or data.frame with LHS & RHS colmn.
#' @param sep  string to separate items from rule string.
#'
#' @return  a data frame with from and to colmn for graph.data.frame inputs.
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
#'
#' #' glo.inspectDF %>% toEdges %>% head
#' }
#'
#' @importFrom magrittr %>%
#'
#' @export

toEdges <- function(rules.data.frame, sep = ","){
  stopifnot(c("LHS", "RHS") %in% colnames(rules.data.frame))
  if(NROW(rules.data.frame)<1){
    return(data.frame(from="NA", to="NA"))
  }

  rule_rhs_edges <- rules.data.frame %>%
    dplyr::select(-LHS) %>%
    dplyr::rename(from = rule, to = RHS)

  lhs_rule_edges <- rules.data.frame %>%
    tidyr::separate_rows(LHS, sep = paste0("\\s*\\",sep,"\\s*")) %>%
    dplyr::select(-RHS) %>%
    dplyr::rename(from = LHS, to = rule)

  edges.all <- dplyr::bind_rows(rule_rhs_edges, lhs_rule_edges)

  class(edges.all) <- c(class(edges.all), "edges.from.rules")
  invisible(edges.all)
}

