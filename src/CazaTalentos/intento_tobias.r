# Intento de Solucion del desafio  15k
# que NO logra solucionarlo, una que falta una idea fundamental, una chispa, un Momento Eureka
# pero crea estructura sobre la cual trabajar

# limpio la memoria
rm(list = ls())
gc()

require("data.table")
library("rlist")

library("parallel")
library("parallelMap")
library("DiceKriging")
library("mlrMBO")

ftirar <- function(prob, qty) {
  return(sum(runif(qty) < prob))
}


# se le pasa un vector con los IDs de los jugadores y la cantidad de tiros a realizar
# devuelve en un vector cuantos aciertos tuvo cada jugador
# gimnasio_tirar <- function(registroJugadores, pids, pcantidad) {
#   # print(pids)
#   # print(pcantidad)
#   res <- mapply(ftirar, registroJugadores[pids], pcantidad)

#   return(res)
# }


Estrategia_Tobias <- function(experimento, rondas, tirosRonda, cuantil, tirosFinal) {
  shouldPrint <- experimento %% 50 == 0
  # writeLines(sprintf("Arrancando estrategia Tobias, %i, %i, %i, %f, %i", experimento, rondas, tirosRonda, cuantil, tirosFinal))

  registroJugadores <- sample(c((501:599) / 1000, 0.7))
  registroTirosTotal <- 0

  # Esta el la planilla del cazatalentos
  # el id es el numero que tiene en la espalda cada jugador
  planilla_cazatalentos <- data.table("id" = 1:100)

  ids_juegan <- 1:100 # los jugadores que participan en la ronda,

  for (i in 1:rondas) {

    planilla_cazatalentos[ids_juegan, tiros := tirosRonda] # registro en la planilla que tiran 70 tiros

    registroTirosTotal <- registroTirosTotal + length(ids_juegan) * tirosRonda
    resultado <- mapply(ftirar, registroJugadores[ids_juegan], tirosRonda)
    planilla_cazatalentos[ids_juegan, aciertos := resultado] # registro en la planilla

    corte <- planilla_cazatalentos[ids_juegan, quantile(aciertos, cuantil)]
    ids_juegan <- planilla_cazatalentos[ids_juegan][aciertos > corte, id]

    if (all(registroJugadores[ids_juegan] != 0.7)) {
      # print(sprintf("[Exp %i]: Se perdió al mejor jugador en la ronda %i", experimento, i))
      return(list(
        "tiros_total" = -1,
        "acierto" = 0
      ))
    }

    # if (shouldPrint) {
    #   print(sprintf("[Exp %i]: Quedan %i jugadores para la ronda %i - Se usaron %i tiros", experimento, length(ids_juegan), p$i + 1, registroTirosTotal))
    # }
  }

  # if (shouldPrint) {
  #   print(sprintf("Ultima ronda del experimento %i, con %i jugadores aún", experimento, length(ids_juegan)))
  # }

  planilla_cazatalentos[ids_juegan, tiros := tirosFinal] # registro en la planilla que tiran 200 tiros
  registroTirosTotal <- registroTirosTotal + length(ids_juegan) * tirosFinal
  resultadoFinal <- mapply(ftirar, registroJugadores[ids_juegan], tirosFinal)
  planilla_cazatalentos[ids_juegan, aciertos := resultadoFinal] # registro en la planilla


  # Epilogo
  # El cazatalentos toma una decision, elige al que mas aciertos tuvo en la ronda2
  pos_mejor <- planilla_cazatalentos[, which.max(aciertos)]
  id_mejor <- planilla_cazatalentos[pos_mejor, id]

  # if (registroJugadores[id_mejor] != 0.7) {
  #   print(sprintf("[Exp %i]: Se perdió al mejor jugador en la última ronda", experimento))
  # }

  # Finalmente, la hora de la verdadero_mejor
  # Termino el juego
  veredicto <- list(
    "tiros_total" = registroTirosTotal,
    "acierto" = as.integer(registroJugadores[id_mejor] == 0.7)
  )

  # writeLines("Termina estrategia Tobias")

  return(veredicto)
}
#------------------------------------------------------------------------------

# Aqui hago la Estimacion Montecarlo del porcentaje de aciertos que tiene la estrategia A

set.seed(100003) # debe ir una sola vez, ANTES de los experimentos

loguear <- function(reg, archivo, verbose = TRUE) {
  if (!file.exists(archivo)) # Escribo los títulos
    {
      linea <- paste0(
        "fecha\t",
        paste(list.names(reg), collapse = "\t"), "\n"
      )

      cat(linea, file = archivo)
    }

  linea <- paste0(
    format(Sys.time(), "%Y%m%d %H%M%S"), "\t", # la fecha y hora
    gsub(", ", "\t", toString(reg)), "\n"
  )

  cat(linea, file = archivo, append = TRUE) # grabo al archivo

  if (verbose) cat(linea) # imprimo por pantalla
}

GananciaMontecarlo <- function(x) {
  # GLOBAL_iteracion <<- GLOBAL_iteracion + 1

  tabla_veredictos <- data.table(tiros_total = integer(), acierto = integer())

  for (experimento in 1:5000) # TODO hacer 10k vueltas
  {
    if (experimento %% 1000 == 0) cat(
      "-", "(", paste(x, collapse=" "), ") | ", experimento, "-----------\n") # desprolijo, pero es para saber por donde voy

    veredicto <- Estrategia_Tobias(experimento, x$rondas, x$tirosRonda, x$cuantil, x$tirosFinal)

    tabla_veredictos <- rbind(tabla_veredictos, veredicto)
  }

  # cat("\n")
  # print(tabla_veredictos)

  tiros_total <- tabla_veredictos[, max(tiros_total)]
  tasa_eleccion_correcta <- tabla_veredictos[, mean(acierto)]

  registro <- x
  registro$tiros_total <- tiros_total
  registro$tasa_eleccion_correcta <- tasa_eleccion_correcta
  # registro$iteracion <- GLOBAL_iteracion
  penalizacion <- ifelse(tiros_total <= 15000, 0, tiros_total / 15e4)
  registro$ganancia <- tasa_eleccion_correcta - penalizacion
  loguear(registro, archivo_log)

  return(registro$ganancia)

  # str(params)
  # ultimo_j <- 100
  # tiros <- 0
  # historia_aprox <- data.frame(
  #   "jugadores" = ultimo_j,
  #   "tiros" = tiros
  # )
  # for (p in params) {
  #   tiros <- ultimo_j * p$tiros
  #   ultimo_j <- floor(ultimo_j * (1 - p$cuantil))
  #   historia_aprox <- rbind(historia_aprox, data.frame(
  #     "tiros" = tiros,
  #     "jugadores" = ultimo_j
  #   ))
  # }
  # historia_aprox <- rbind(historia_aprox, data.frame(
  #   "tiros" = ultimo_j * tirosFinales,
  #   "jugadores" = 1
  # ))
  # print(historia_aprox)
  # print(tiros_total)
  # print(tasa_eleccion_correcta)
}
# GananciaMontecarlo(list("rondas" = 1, "tirosRonda" = 88, "cuantil" = 0.248301184549147, "tirosFinal" = 318))

setwd("/Users/tlichtig/Desktop/ITBA/2-mineria-de-datos/labo")
out_root <- "./labo/exp/CT15"
dir.create(out_root, showWarnings = FALSE)
archivo_log <- sprintf("%s/CT15.txt", out_root)
archivo_BO <- sprintf("%s/CT15.RDATA", out_root)

# GLOBAL_iteracion <- 0

if (file.exists(archivo_log)) {
  tabla_log <- fread(archivo_log)
  # GLOBAL_iteracion <- nrow(tabla_log)
}

configureMlr(show.learner.output = TRUE)

obj.fun <- makeSingleObjectiveFunction(
  fn = GananciaMontecarlo,
  minimize = FALSE, # estoy Maximizando la ganancia
  noisy = TRUE,
  has.simple.signature = FALSE,
  par.set = makeParamSet(
    makeIntegerParam("rondas", lower = 1L, upper = 50L),
    makeIntegerParam("tirosRonda", lower = 5L, upper = 200L),
    makeNumericParam("cuantil", lower = 0.1, upper = 0.9),
    makeIntegerParam("tirosFinal", lower = 50L, upper = 1000L),
    forbidden = quote(rondas * tirosRonda * 5 + 2 * tirosFinal >= 15000)
  )
)

parallel <- 5

ctrl <- makeMBOControl(save.on.disk.at.time = 180, save.file.path = archivo_BO, propose.points = parallel)
ctrl <- setMBOControlTermination(ctrl, iters = 1000)
ctrl = setMBOControlInfill(ctrl, crit = crit.cb)
ctrl = setMBOControlMultiPoint(ctrl, method = "cb")

surr.km <- makeLearner("regr.km", predict.type = "se", covtype = "matern3_2", control = list(trace = TRUE))

# inicio la optimización bayesiana
if (!file.exists(archivo_BO)) {
  print("Arrancando de 0")
  parallelStartMulticore(cpus = parallel)
  run <- mbo(obj.fun, learner = surr.km, control = ctrl)
  parallelStop()
} else {
  print("CONTINUO")
  parallelStartMulticore(cpus = parallel)
  run <- mboContinue(archivo_BO)
  parallelStop()
} # retomo en caso que ya exista

# Es una sábana corta ...

####################################
# Resultado original Estrategia B
####################################
# r$> tiros_total
# [1] 18400
# r$> tasa_eleccion_correcta
# [1] 0.9259
