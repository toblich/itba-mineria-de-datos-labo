rm(list = ls()) # remove all objects
gc() # garbage collection

library("data.table")

setwd("/Users/tlichtig/Desktop/ITBA/2-mineria-de-datos/labo/exp")

filename <- function(experimento, iteracion) {
  parts <- strsplit(experimento, "-")
  return(sprintf("./%s/futuro_prediccion_semillerio_%s.csv", parts[[1]][1], parts[[1]][2]))
}

prediccion <- function(experimento) {
  pred <- fread(filename(experimento))
  setorder(pred, numero_de_cliente)
  return(pred)
}

experimentos <- c(
  "ZZ0002T-039",
  "ZZ8420T-088",
  "ZZ8421T-052"
)

predicciones <- lapply(experimentos, prediccion)
# print(predicciones)

a_hibridar <- predicciones[[1]][, "numero_de_cliente"]

for (pred in predicciones) {
  a_hibridar <- cbind(a_hibridar, pred$pred_acumulada)
}

colnames(a_hibridar) <- c("numero_de_cliente", experimentos) # numero_de_cliente,Predicted
print(a_hibridar)

hibridados <- a_hibridar[, pred_acumulada := rowSums(.SD), .SD = experimentos]
setorder(hibridados, -pred_acumulada)
corte <- 11000
hibridados[  , Predicted := 0L ]
hibridados[ 1:corte, Predicted := 1L ]
# print(hibridados)

output <- hibridados[, c("numero_de_cliente","Predicted")]
# setorder(output, -Predicted)
print(output)
write.csv(output, file = sprintf("./hibridacion/%s_%d.csv", paste(experimentos, collapse = "_"), corte), row.names = FALSE, quote = FALSE)
