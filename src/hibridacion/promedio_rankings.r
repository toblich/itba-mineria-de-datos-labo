rm(list = ls()) # remove all objects
gc() # garbage collection

library("data.table")

setwd("/Users/tlichtig/Desktop/ITBA/2-mineria-de-datos/labo/exp")

filename <- function(experimento, iteracion) {
  parts <- strsplit(experimento, "-")
  return(sprintf("./%s/futuro_prediccion_semillerio_%s.csv", parts[[1]][1], parts[[1]][2]))
}

prediccion <- function(fname) {
  pred <- fread(fname)
  setorder(pred, numero_de_cliente)
  return(pred)
}

experimentos <- c(
  "ZZ0002T-039",
  "ZZ8420T-088",
  "ZZ8421T-052",
  "ZZ0003T-090"
  # # "ZZ8421T-052",
  # # "ZZ0002T-039",
  # # "ZZ8420T-088",
  # "ZZ8421T-105",
  # "ZZ8421T-050",
  # "ZZ0002T-060",
  # "ZZ0002T-109",
  # "ZZ0001T-060",
  # "ZZ0001T-039",
  # "ZZ0001T-109",
  # "ZZ8420T-003",
  # "ZZ8420T-047"
)

filenames <- lapply(experimentos, filename)
predicciones <- lapply(filenames, prediccion)
str(predicciones)

a_hibridar <- predicciones[[1]][, "numero_de_cliente"]

for (pred in predicciones) {
  a_hibridar <- cbind(a_hibridar, pred$pred_acumulada)
}

all_names <- c(experimentos)
# otra_pred <- prediccion("./ZZ0003T/futuro_prediccion_090.csv")
# a_hibridar <- cbind(a_hibridar, otra_pred$prob)

colnames(a_hibridar) <- c("numero_de_cliente", all_names) # numero_de_cliente,Predicted
print(a_hibridar)

hibridados <- a_hibridar[, pred_acumulada := rowSums(.SD), .SD = all_names]
setorder(hibridados, -pred_acumulada)
corte_inicial <- 1
corte_final <- 12500
hibridados[, Predicted := 0L]
hibridados[corte_inicial:corte_final, Predicted := 1L]
# print(hibridados)

output <- hibridados[, c("numero_de_cliente", "Predicted")]
# setorder(output, -Predicted)
print(output)
out_name <- sprintf("./hibridacion/%s_%d_%d.csv", paste(all_names, collapse = "_"), corte_inicial, corte_final)
writeLines(out_name)
write.csv(output, file = out_name, row.names = FALSE, quote = FALSE)
