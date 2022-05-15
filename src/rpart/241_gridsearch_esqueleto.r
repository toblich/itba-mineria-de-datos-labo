# esqueleto de grid search
# se espera que los alumnos completen lo que falta para recorrer TODOS cuatro los hiperparámetros

rm(list = ls()) # Borro todos los objetos
gc() # Garbage Collection

require("data.table")
require("rpart")
require("parallel")

semillas <- c(100003, 100019, 111317, 111323, 131071) # reemplazar por las propias semillas

#------------------------------------------------------------------------------
# particionar agrega una columna llamada fold a un dataset que consiste en una partición estratificada según agrupa
# particionar( data=dataset, division=c(70,30), agrupa=clase_ternaria, seed=semilla)   crea una partición 70, 30

particionar <- function(data, division, agrupa = "", campo = "fold", start = 1, seed = NA) {
  if (!is.na(seed)) set.seed(seed)

  bloque <- unlist(mapply(function(x, y) {
    rep(y, x)
  }, division, seq(from = start, length.out = length(division))))

  data[, (campo) := sample(rep(bloque, ceiling(.N / length(bloque))))[1:.N],
    by = agrupa
  ]
}
#------------------------------------------------------------------------------

ArbolEstimarGanancia <- function(semilla, param_basicos) {
  # particiono estratificadamente el dataset
  particionar(dataset, division = c(70, 30), agrupa = "clase_ternaria", seed = semilla) # Cambiar por la primer semilla de cada uno !

  # genero el modelo
  modelo <- rpart("clase_ternaria ~ .", # quiero predecir clase_ternaria a partir del resto
    data = dataset[fold == 1], # fold==1  es training,  el 70% de los datos
    xval = 0,
    control = param_basicos
  ) # aquí van los parámetros del árbol

  # aplico el modelo a los datos de testing
  prediccion <- predict(modelo, # el modelo que genere recién
    dataset[fold == 2], # fold==2  es testing, el 30% de los datos
    type = "prob"
  ) # type= "prob"  es que devuelva la probabilidad

  # prediccion es una matriz con TRES columnas, llamadas "BAJA+1", "BAJA+2"  y "CONTINUA"
  # cada columna es el vector de probabilidades


  # calculo la ganancia en testing  qu es fold==2
  ganancia_test <- dataset[
    fold == 2,
    sum(ifelse(prediccion[, "BAJA+2"] > 1 / 60,
      ifelse(clase_ternaria == "BAJA+2", 59000, -1000),
      0
    ))
  ]

  # escalo la ganancia como si fuera todo el dataset
  ganancia_test_normalizada <- ganancia_test / 0.3

  return(ganancia_test_normalizada)
}
#------------------------------------------------------------------------------

ArbolesMontecarlo <- function(semillas, param_basicos) {
  # la función mcmapply  llama a la función ArbolEstimarGanancia  tantas veces como valores tenga el vector  semillas
  ganancias <- mcmapply(ArbolEstimarGanancia,
    semillas, # paso el vector de semillas, que debe ser el primer parámetro de la función ArbolEstimarGanancia
    MoreArgs = list(param_basicos), # aquí paso el segundo parámetro
    SIMPLIFY = FALSE,
    mc.cores = 5
  ) # se puede subir a 5 si posee Linux o Mac OS

  ganancia_promedio <- mean(unlist(ganancias))

  return(ganancia_promedio)
}
#------------------------------------------------------------------------------

# Aquí se debe poner la carpeta de la computadora local
setwd("/Users/tlichtig/Desktop/ITBA/2-mineria-de-datos/labo") # Establezco el Working Directory

# cargo los datos
dataset <- fread("./datasets/paquete_premium_202011.csv")


# genero el archivo para Kaggle
# creo la carpeta donde va el experimento
# HT  representa  Hyperparameter Tuning
dir.create("./labo/exp/", showWarnings = FALSE)
dir.create("./labo/exp/HT2020/", showWarnings = FALSE)
archivo_salida <- "./labo/exp/HT2020/gridsearch.csv"

# Escribo los títulos al archivo donde van a quedar los resultados
# atención que si ya existe el archivo, esta instrucción LO SOBREESCRIBE, y lo que estaba antes se pierde
# la forma que no suceda lo anterior es con append=TRUE

header <- paste(
  c("timestamp", "cp", "minsplit", "minbucket", "maxdepth", "ganancia_promedio"),
  sep = "", collapse = ", "
)
print(header)
cat(
  file = archivo_salida,
  append = TRUE,
  sep = "",
  header, "\n"
)


# itero por los loops anidados para cada hiperparámetro

for (vcp in c(-0.1, -0.2, -0.3, -0.4, -0.5)) {
  for (vmin_split in c(1000, 500, 200, 100, 50)) {
    for (vmin_bucket in c(200, 100, 50, 10)) {
      for (vmax_depth in seq(3, 13, 2)) {
        if (vmin_bucket > vmin_split / 2) {
          # No tiene sentido pedir splits si las hojas están requeridas de tener más de la mitad de los nodos
          next
        }
        # if ((vmin_split <= 100) & (vmax_depth < 6)) {
        #   next
        # }

        # print(timestamp())
        # notar como se agrega - MISMO ORDEN QUE HEADER!!!!
        param_basicos <- list(
          "cp" = vcp, # complejidad minima
          "minsplit" = vmin_split, # minima cantidad de registros en un nodo para hacer el split
          "minbucket" = vmin_bucket, # minima cantidad de registros en una hoja
          "maxdepth" = vmax_depth
        ) # profundidad máxima del árbol

        ganancia_promedio <- ArbolesMontecarlo(semillas, param_basicos)

        ts <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
        line <- paste(c(ts, param_basicos, ganancia_promedio), sep = "", collapse = ", ")

        print(line)

        # escribo los resultados al archivo de salida
        cat(
          file = archivo_salida,
          append = TRUE,
          sep = "",
          line, "\n"
        )
      }
    }
  }
}
