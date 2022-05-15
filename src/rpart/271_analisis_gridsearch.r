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

gain.plot <- function(varname) {
  # varname <- "maxdepth"
  vars <- Filter(function(name) name != varname, c("cp", "minsplit", "minbucket", "maxdepth"))
  other.params <- data.table()
  for (var in vars) {
    tmp <- data.table(unique(dtrain[, ..var]))
    other.params <- other.params[, as.list(tmp), by = other.params]
  }
  varvals <- dtrain[, ..varname]

  p <- ggplot(data = dtrain[1, ], mapping = aes_string(x = varname, y = "ganancia_promedio")) +
    ylim(min(dtrain$ganancia_promedio), max(dtrain$ganancia_promedio)) +
    xlim(min(varvals), max(varvals) * 1.05)
  n <- nrow(other.params)
  cols <- rainbow(n)
  for (i in 1:n) {
    rowdata <- other.params[i, ]
    dots <- dtrain[rowdata, on = colnames(rowdata)]
    dots$idx <- i
    dots$params <- paste(other.params[i, ], collapse = " ")
    if (any(is.na(dots))) {
      next
    }
    # print(dots)
    p <- p +
      geom_line(data = dots, col = cols[i]) +
      geom_dl(data = dots, mapping = aes(label = params), method = "last.points")
  }
  print(p)
}

gain.plot("cp")
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
# prp(modelo, extra = 101, digits = 5, branch = 1, type = 4, varlen = 0, faclen = 0)
# dev.off()
