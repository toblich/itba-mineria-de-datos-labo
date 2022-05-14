rm(list = ls()) # Borro todos los objetos
gc() # Garbage Collection

# cargo las librerías que necesito
require("data.table")
require("rpart")
require("rpart.plot")

# Aquí se debe poner la carpeta de SU computadora local
setwd("/Users/tlichtig/Desktop/ITBA/2-mineria-de-datos/labo") # Establezco el Working Directory

# cargo la salida del Grid Search, verifique que corresponda a la carpeta donde dejó el resultado
dtrain <- fread("./labo/exp/HT2020/gridsearch.csv")

plot(ganancia_promedio ~ cp, data = dtrain, main = "CP", type = "b")
plot(ganancia_promedio ~ minsplit, data = dtrain, main = "MIN SPLIT", type = "b")
plot(ganancia_promedio ~ minbucket, data = dtrain, main = "MIN BUCKET", type = "b")
plot(ganancia_promedio ~ maxdepth, data = dtrain, main = "MAX DEPTH", type = "b")


# genero el modelo,  aquí se construye el árbol
# este sera un árbol de REGRESIÓN ya que la variable objetivo, ganancia_promedio,  es una variable continua
modelo <- rpart("ganancia_promedio ~ . - timestamp", # quiero predecir clase_ternaria a partir de el resto de las variables
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
