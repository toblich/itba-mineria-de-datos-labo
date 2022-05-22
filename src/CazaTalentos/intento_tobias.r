# Intento de Solucion del desafio  15k
# que NO logra solucionarlo, una que falta una idea fundamental, una chispa, un Momento Eureka
# pero crea estructura sobre la cual trabajar

# limpio la memoria
rm(list = ls())
gc()

require("data.table")

# library("parallel")
# library("DiceKriging")
# library("mlrMBO")

ftirar <- function(prob, qty) {
  return(sum(runif(qty) < prob))
}


# variables globales que usan las funciones gimnasio_xxxx
GLOBAL_jugadores <- c()
GLOBAL_tiros_total <- 0

# Crea el juego
# a cada jugador se le pone un numero de 1 a 100 en la espalda
# debajo de ese numero esta el indice_de_enceste  que NO puede ser visto por el cazatalentos
gimnasio_init <- function() {
  GLOBAL_jugadores <<- sample(c((501:599) / 1000, 0.7))
  GLOBAL_tiros_total <<- 0
}


# se le pasa un vector con los IDs de los jugadores y la cantidad de tiros a realizar
# devuelve en un vector cuantos aciertos tuvo cada jugador
gimnasio_tirar <- function(pids, pcantidad) {
  # print(pids)
  # print(pcantidad)
  GLOBAL_tiros_total <<- GLOBAL_tiros_total + length(pids) * pcantidad
  res <- mapply(ftirar, GLOBAL_jugadores[pids], pcantidad)

  return(res)
}


# El cazatalentos decide a que jugador llevarse
# devuelve la cantidad de tiros libres y si le acerto al verdadero_mejor o no
gimnasio_veredicto <- function(pid) {
  return(list(
    "tiros_total" = GLOBAL_tiros_total,
    "acierto" = as.integer(GLOBAL_jugadores[pid] == 0.7)
  ))
}
#------------------------------------------------------------------------------

params <- function(i = 0) {
  return(list(
    "rondas" = 3,
    "tiros" = 50 + 12 * i^2,
    "corte" = function(aciertos) {
      return(quantile(aciertos, 0.5 + 0.1 * i))
    },
    # "cuantil" = 0.25,
    "tirosFinales" = 200
  ))
}

params <- list(
  list("tiros" = 50, "cuantil" = 0.25),
  list("tiros" = 85, "cuantil" = 0.5),
  list("tiros" = 85, "cuantil" = 0.5)
  # list("tiros" = 90, "cuantil" = 0.5),
  # list("tiros" = 100, "cuantil" = 0.5)
  # list("i" = 4, "tiros" = 120, "cuantil" = 0.6)
)
tirosFinales <- 1000
for (i in 1:length(params)) {
  params[[i]]$i <- i
}

Estrategia_Tobias <- function(experimento) {
  shouldPrint <- experimento %% 50 == 0
  # Estrategia
  # Se juegan varias rondas
  # En cada ronda, los jugadores que participan, tiran 70 tiros
  # De una ronda a la otra, solo pasan los que tuvieron igual o mayor aciertos a la mediana de aciertos de la ronda anterior
  # Se elige el mejor jugador de la sexta ronda

  gimnasio_init()

  # Esta el la planilla del cazatalentos
  # el id es el numero que tiene en la espalda cada jugador
  planilla_cazatalentos <- data.table("id" = 1:100)

  # Ronda 1  ------------------------------------------------------
  # tiran los 100 jugadores es decir 1:100   70  tiros libres cada uno
  ids_juegan <- 1:100 # los jugadores que participan en la ronda,

  for (p in params) {
    # tiros <- 10 + 5 * i
    planilla_cazatalentos[ids_juegan, tiros := p$tiros] # registro en la planilla que tiran 70 tiros
    resultado <- gimnasio_tirar(ids_juegan, p$tiros)
    planilla_cazatalentos[ids_juegan, aciertos := resultado] # registro en la planilla
    # print(sort(resultado))
    corte <- planilla_cazatalentos[ids_juegan, quantile(aciertos, p$cuantil)]
    ids_juegan <- planilla_cazatalentos[ids_juegan][aciertos > corte, id]

    if (all(GLOBAL_jugadores[ids_juegan] != 0.7)) {
      print(sprintf("[Exp %i]: Se perdió al mejor jugador en la ronda %i", experimento, p$i))
      return(list(
        "tiros_total" = -1,
        "acierto" = 0
      ))
    }

    # if (shouldPrint) {
    #   print(sprintf("[Exp %i]: Quedan %i jugadores para la ronda %i - Se usaron %i tiros", experimento, length(ids_juegan), p$i + 1, GLOBAL_tiros_total))
    # }
  }

  # if (shouldPrint) {
  #   print(sprintf("Ultima ronda del experimento %i, con %i jugadores aún", experimento, length(ids_juegan)))
  # }

  tiros <- tirosFinales
  planilla_cazatalentos[ids_juegan, tiros := tiros] # registro en la planilla que tiran 200 tiros
  resultadoFinal <- gimnasio_tirar(ids_juegan, tiros)
  planilla_cazatalentos[ids_juegan, aciertos := resultadoFinal] # registro en la planilla


  # Epilogo
  # El cazatalentos toma una decision, elige al que mas aciertos tuvo en la ronda2
  pos_mejor <- planilla_cazatalentos[, which.max(aciertos)]
  id_mejor <- planilla_cazatalentos[pos_mejor, id]

  if (GLOBAL_jugadores[id_mejor] != 0.7) {
    print(sprintf("[Exp %i]: Se perdió al mejor jugador en la última ronda", experimento))
  }

  # Finalmente, la hora de la verdadero_mejor
  # Termino el juego
  veredicto <- gimnasio_veredicto(id_mejor)

  return(veredicto)
}
#------------------------------------------------------------------------------

# Aqui hago la Estimacion Montecarlo del porcentaje de aciertos que tiene la estrategia A

set.seed(102191) # debe ir una sola vez, ANTES de los experimentos

tabla_veredictos <- data.table(tiros_total = integer(), acierto = integer())

for (experimento in 1:3000) # TODO hacer 10k vueltas
{
  if (experimento %% 100 == 0) cat(experimento, "-----------\n") # desprolijo, pero es para saber por donde voy

  veredicto <- Estrategia_Tobias(experimento)

  tabla_veredictos <- rbind(tabla_veredictos, veredicto)
}

cat("\n")

tiros_total <- tabla_veredictos[, max(tiros_total)]
tasa_eleccion_correcta <- tabla_veredictos[, mean(acierto)]

str(params)
ultimo_j <- 100
tiros <- 0
historia_aprox <- data.frame(
  "jugadores" = ultimo_j,
  "tiros" = tiros
)
for (p in params) {
  tiros <- ultimo_j * p$tiros
  ultimo_j <- floor(ultimo_j * (1 - p$cuantil))
  historia_aprox <- rbind(historia_aprox, data.frame(
    "tiros" = tiros,
    "jugadores" = ultimo_j
  ))
}
historia_aprox <- rbind(historia_aprox, data.frame(
  "tiros" = ultimo_j * tirosFinales,
  "jugadores" = 1
))
print(historia_aprox)
print(tiros_total)
print(tasa_eleccion_correcta)

# Es una sábana corta ...

####################################
# Resultado original Estrategia B
####################################
# r$> tiros_total
# [1] 18400
# r$> tasa_eleccion_correcta
# [1] 0.9259
