# BSD_2_clause

#' Create a plotly heatmap of habitat changes
#'
#' @param data The data set to subset
#' @param species The name of the species to plot
#' @return A plotly heatmap
#' @importFrom dplyr filter
#' @importFrom vegan diversity
#' @export
#' @examples
#' \dontrun{
#' make_heatmap(all_sp, "RiceRat")
#' }
make_heatmap <- function(df, species = "", title = "", height = NULL) {
  if(species == "") {
    subd <- df
  } else {
    subd <- dplyr::filter(df, Species == species)
  }
  leg <- "Acres"
  if(vegan::diversity(subd$Acres) > 1.3 | vegan::diversity(subd$Acres) < 0.8) {
    leg <- "log10(Acres)"
  }

  habs <- union(unique(subd$from), unique(subd$to))
  habs <- habs[!is.na(habs)]
  mat <- matrix(NA, nrow = length(habs), ncol = length(habs))
  row.names(mat) <- habs
  colnames(mat) <- habs
  for(i in 1:length(habs)) {
    for(j in 1:length(habs)) {
      sub <- dplyr::filter(subd, from == habs[i], to == habs[j])
      mat[i, j] <- ifelse(leg == "Acres",
                          sum(sub$Acres, na.rm = TRUE),
                          log10(sum(sub$Acres, na.rm = TRUE) + 1))
    }
  }

  plot <- plot_ly(z = mat,
                  type = "heatmap",
                  colorbar = list(title = leg),
                  x = colnames(mat),
                  y = row.names(mat),
                  height = height,
                  colors = viridis(7)) %>%
          layout(title = title,
                 xaxis = list(title = "To", tickangle = 45),
                 yaxis = list(title = "From", tickangle = -45),
                 margin = list(l = 150, b = 250))
  return(plot)
}
