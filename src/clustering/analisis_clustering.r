rm(list = ls())
gc()

library("data.table")

setwd("/Users/tlichtig/Desktop/ITBA/2-mineria-de-datos/labo/exp/ST7620")

 d <- fread("./cluster_de_bajas_12meses.txt")

setorder(d, cluster2, foto_mes)
str(d)


r <- d[ , .(mean=mean(mpayroll)), by=.(cluster2, pos)]
print(r)
