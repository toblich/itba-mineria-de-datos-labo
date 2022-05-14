# Árbol elemental con librería  rpart
# Debe tener instaladas las librerías  data.table  ,  rpart   y rpart.plot

# cargo las librerías que necesito
require("data.table")
require("rpart")
require("rpart.plot")

# Aquí se debe poner la carpeta de SU computadora local
setwd("/Users/tlichtig/Desktop/ITBA/2-mineria-de-datos/labo") # Establezco el Working Directory

# cargo los datos de 202011 que es donde voy a ENTRENAR el modelo
dtrain <- fread("./datasets/paquete_premium_202011.csv")

hiperparams <- data.frame(
  cp = -0.3,
  minsplit = 30,
  minbucket = 5,
  maxdepth = 8
)

print(hiperparams)

# genero el modelo,  aquí se construye el árbol
modelo <- rpart("clase_ternaria ~ .", # quiero predecir clase_ternaria a partir de el resto de las variables
  data = dtrain,
  xval = 0,
  cp = hiperparams$cp, # esto significa no limitar la complejidad de los splits
  minsplit = hiperparams$minsplit, # minima cantidad de registros para que se haga el split
  minbucket = hiperparams$minbucket, # tamaño mínimo de una hoja
  maxdepth = hiperparams$maxdepth
) # profundidad maxima del árbol


# grafico el árbol
prp(modelo, extra = 101, digits = 5, branch = 1, type = 4, varlen = 0, faclen = 0)


# Ahora aplico al modelo  a los datos de 202101  y genero la salida para kaggle

# cargo los datos de 202011, que es donde voy a APLICAR el modelo
dapply <- fread("./datasets/paquete_premium_202101.csv")

# aplico el modelo a los datos nuevos
prediccion <- predict(modelo, dapply, type = "prob")

# prediccion es una matriz con TRES columnas, llamadas "BAJA+1", "BAJA+2"  y "CONTINUA"
# cada columna es el vector de probabilidades

# agrego a dapply una columna nueva que es la probabilidad de BAJA+2
dapply[, prob_baja2 := prediccion[, "BAJA+2"]]

# solo le envío estimulo a los registros con probabilidad de BAJA+2 mayor  a  1/60
dapply[, Predicted := as.numeric(prob_baja2 > 1 / 60)]

# genero un dataset con las dos columnas que me interesan
entrega <- dapply[, list(numero_de_cliente, Predicted)] # genero la salida

# genero el archivo para Kaggle
# creo la carpeta donde va el experimento
dir.create("./labo/exp/")
dir.create("./labo/exp/KA2001")

fwrite(entrega,
  file = "./labo/exp/KA2001/K101_001.csv",
  sep = ","
)
