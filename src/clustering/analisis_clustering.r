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
excluir <- c("foto_mes", "numero_de_cliente")
features <- setdiff(columnas, excluir)

cols <- rainbow(7)


r <- d[ , .(mean=mean(mpayroll)), by=.(cluster2, pos2)]
print(r)

y <- "mean"
p <- ggplot(r, aes_string(x = "pos2", y = y, group = "cluster2", col="cluster2")) +
  geom_point() +
  geom_line() +
  geom_dl(mapping = aes(label = cluster2), method = list("last.points", hjust=-2)) +
  scale_x_continuous(name = "Meses faltantes hasta baja", breaks = -12:-1) +
  scale_y_continuous(name = "mpayroll") +
  theme_minimal()
  # scale_x_discrete(name = "Meses faltantes hasta naja", limits=seq(-12,-1, 1))


print(p)
# p <- (sub_data$pos, sub_data$mean, main = sprintf("Media del mpayroll del cluster %d", cluster), type = "o")
