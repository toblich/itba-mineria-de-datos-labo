rm(list = ls())
require("ggplot2")
library("ggrepel")
library("directlabels")

library("data.table")

setwd("/Users/tlichtig/Desktop/ITBA/2-mineria-de-datos/labo/exp/ST7620")

d <- fread("./cluster_de_bajas_12meses.txt")
d[, pos2 := -pos]

setorder(d, cluster2, foto_mes)
# str(d)



columnas <- colnames(d)
excluir <- c("foto_mes", "numero_de_cliente", "pos", "pos2")
features <- setdiff(columnas, excluir)


feature <- "mpayroll"
for (feature in features) {
  writeLines(feature)
  r <- d[, .(mean = mean(get(feature))), by = .(cluster2, pos2)]
  y <- "mean"
  p <- ggplot(r, aes_string(x = "pos2", y = y, group = "cluster2", col = "cluster2")) +
    labs(title = sprintf("%s media de cada cluster hasta ser BAJA=2", feature), colour = "# Cluster") +
    geom_point() +
    geom_line() +
    geom_dl(mapping = aes(label = cluster2),
      method = dl.combine(list("last.points", hjust = -2), list("first.points", hjust = 2))) +
    scale_x_continuous(name = "Meses faltantes hasta baja", breaks = -12:-1) +
    scale_y_continuous(name = feature) +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5, size = 22))

  print(p)
}
