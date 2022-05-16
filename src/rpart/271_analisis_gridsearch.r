rm(list = ls()) # Borro todos los objetos
gc() # Garbage Collection

# cargo las librerías que necesito
require("data.table")
require("rpart")
require("rpart.plot")
require("ggplot2")
library("ggrepel")
library("directlabels")

# Aquí se debe poner la carpeta de SU computadora local
setwd("/Users/tlichtig/Desktop/ITBA/2-mineria-de-datos/labo") # Establezco el Working Directory

# cargo la salida del Grid Search, verifique que corresponda a la carpeta donde dejó el resultado
dtrain <- fread("./labo/exp/HT2020/gridsearch.csv")

threshold <- 1e7

gain.plot <- function(varname) {
  vars <- Filter(function(name) name != varname, c("minsplit", "minbucket", "maxdepth"))
  other.params <- data.table()
  for (var in vars) {
    tmp <- data.table(unique(dtrain[, ..var]))
    other.params <- other.params[, as.list(tmp), by = other.params]
  }
  varvals <- dtrain[, ..varname]

  N <- nrow(other.params)
  k <- 0
  all_dots <- data.table(
    timestamp = Sys.time(),
    cp = 0,
    minsplit = 0,
    minbucket = 0,
    maxdepth = 0,
    ganancia_promedio = 0,
    idx = -1,
    params = ""
  )
  for (i in 1:N) {
    if (i %% 20 == 0) {
      writeLines(sprintf("%s %i/%i: %i", varname, i, N, k))
    }
    rowdata <- other.params[i, ]
    dots <- dtrain[rowdata, on = colnames(rowdata)]
    if (any(is.na(dots)) | all((dots$ganancia_promedio < threshold))) {
      # writeLines(sprintf("Dropping %s", paste(dots, collapse = ", ")))
      next
    }
    k <- k + 1
    dots$idx <- k
    dots$params <- paste(other.params[i, ], collapse = " ")
    all_dots <- rbindlist(list(all_dots, dots))
  }

  all_dots <- all_dots[-1, ] # Saco la primera fila (basura con la inicializo)
  print(all_dots)

  mmax <- max(varvals)
  mmin <- min(varvals)
  r <- abs(mmax - mmin)

  p <- ggplot(all_dots, aes_string(x = varname, y = "ganancia_promedio", group = "idx", col = "params")) +
    ylim(min(all_dots$ganancia_promedio), max(all_dots$ganancia_promedio)) +
    xlim(mmin, mmax + 0.1 * r) +
    geom_point() +
    geom_line() +
    geom_dl(mapping = aes(label = params), method = dl.combine("top.points", "last.points"))

  print(k)
  print(p)
}

# gain.plot("cp")
gain.plot("minsplit")
gain.plot("minbucket")
gain.plot("maxdepth")


# genero el modelo,  aquí se construye el árbol
# este sera un árbol de REGRESIÓN ya que la variable objetivo, ganancia_promedio,  es una variable continua
# quiero predecir clase_ternaria a partir de el resto de las variables
modelo <- rpart("ganancia_promedio ~ . - timestamp",
  data = dtrain,
  xval = 0,
  cp = 0,
  minsplit = 10, # minima cantidad de registros para que se haga el split
  minbucket = 10, # tamaño mínimo de una hoja
  maxdepth = 4
) # profundidad maxima del árbol
# grafico el árbol

# primero creo la carpeta a donde voy a guardar el dibujo del árbol
# dir.create("./labo/exp/", showWarnings = FALSE)
# dir.create("./labo/exp/ST2030/", showWarnings = FALSE)
# archivo_salida <- "./labo/exp/ST2030/arbol_analisis_gridsearch.pdf"

# finalmente, genero el grafico guardándolo en un archivo pdf
# pdf(archivo_salida, paper = "a4r")
prp(modelo, extra = 101, digits = 5, branch = 1, type = 4, varlen = 0, faclen = 0)
# dev.off()
