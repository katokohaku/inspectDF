#' plot rules.data.frame as graph.
#'
#' @param rules.data.frame  rules.data.frame.
#' @param adujust.support.size  adujust.support.size
#' @param label  labels for item node.
#' @param cex  label size for ittem node.
#' @param ...  arguments path to plot.igraph()
#'
#' export

plotRuleGraph <- function(rules.data.frame, adujust.support.size=50, label="", cex=1.0, ...){

  obj <- plotEdgeWithRule(edges = toEdges(rules.data.frame),
                          rules = rules.data.frame,
                          adujust.support.size = adujust.support.size,
                          label=label, cex=cex, ...)

  # for additional draw control:
  invisible(obj)
}

#' plot edge.data.frame with rules as graph.
#'
#' @param edges a data.frame for input to graph.data.frame.
#' @param adujust.support.size  adujust.support.size
#' @param label  labels for item node.
#' @param cex  label size for ittem node.
#' @param ...  arguments path to plot.igraph()
#'
#' @import igraph
#' @export

plotEdgeWithRule <- function(edges, rules, adujust.support.size=50, label="", cex=1.0, ...){

  if(NROW(edges) < 2){
    plot(0, type="n", bty="n", xaxt="n", yaxt="n", xlab="", ylab="")
    legend("topleft", label, bty="n")
    text(x = 0, "No rules to be plot")
    return()
  }
  if(!all(c("from", "to") %in% colnames(edges))){
    stop("input edge.data.frame must have at least 2 colmns with \"from\" and \"to\"")
  }

  g <- graph.data.frame(edges, directed=TRUE)

  v_to_support_map <- setNames(rules$support * adujust.support.size, rules$rule)
  v_to_support <- function(name) {
    if_else(name %in% names(v_to_support_map), v_to_support_map[name],0)
  }

  v_to_lift_map <- setNames(rules$lift, rules$rule)
  v_to_lift <- function(name) {
    if_else(name %in% names(v_to_lift_map), v_to_lift_map[name],0)
  }

  v_to_confidence_map <- setNames(rules$confidence, rules$rule)
  v_to_confidence <- function(name) {
    if_else(name %in% names(v_to_confidence_map), v_to_confidence_map[name],0)
  }

  # Sewt color scale with confidence
  c_scale <- colorRamp(c('white','red'))
  V(g)$color <- apply(c_scale(v_to_confidence(V(g)$name)), 1, function(x) rgb(x[1]/255,x[2]/255,x[3]/255, alpha=0.8) )

  # Mute labels of rule-node
  modify_label <- function(x) {if_else(str_detect(x,"^Rule "), "", x)}

  param <- list(
    edge.arrow.size    = 0.4,
    vertex.size        = v_to_support(V(g)$name),
    labels             = modify_label(V(g)$name),
    vertex.label.family= "sans",
    vertex.label.color = rgb(0.04,0.04,0.04),
    vertex.label.cex   = cex,
    vertex.frame.color = rgb(1,0.5,0.5)
  )

  # Draw Graph
  par(mar=c(0,0,0,0))
  plot(g,
       edge.arrow.size    = param$edge.arrow.size,
       vertex.size        = param$vertex.size,
       vertex.label       = param$labels,
       vertex.label.family= param$vertex.label.family,
       vertex.label.color = param$vertex.label.color,
       vertex.label.cex   = param$vertex.label.cex,
       vertex.frame.color = param$vertex.frame.color,
       ...)
  legend("topleft", label, bty="n")

  obj <- list(legend = label, graph=g, parameter=param)
  class(obj) <- c(class(obj), "plotRulesGraph")

  # for additional draw control:
  invisible(obj)
}

