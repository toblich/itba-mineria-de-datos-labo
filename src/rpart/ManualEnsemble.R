rm(list = ls()) # Borro todos los objetos
gc() # Garbage Collection

library("data.table")

setwd("/Users/tlichtig/Desktop/ITBA/2-mineria-de-datos/labo")

a1 <- fread("./labo/exp/KA2001/K101_001_850_335_6.csv")
a2 <- fread("./labo/exp/KA2001/K101_001_1500_300_6.csv")
a3 <- fread("./labo/exp/KA2001/K101_001_1800_400_6.csv")
# a4 <- fread("./labo/exp/KA2001/K101_001_2000_400_6.csv")
a5 <- fread("./labo/exp/KA2001/K101_001_2000_500_5.csv")
a6 <- fread("./labo/exp/KA2001/K101_001_1800_350_7.csv")

modelos <- list(a1, a2, a3, a5, a6)

j <- data.table(numero_de_cliente = modelos[[1]]$numero_de_cliente)

for (curr in modelos) {
  j <- j[curr, on = .(numero_de_cliente), nomatch = NULL]
}

# print(j)

r <- j[,
  pred := ifelse(sum(Predicted, i.Predicted, i.Predicted.1, i.Predicted.2, i.Predicted.3) > length(modelos) / 2, 1, 0),
  by = numero_de_cliente
]
print(lapply(r, sum))
final <- r[, "numero_de_cliente"]
final$Predicted <- r$pred
fwrite(final, file = "ensemble.csv")
