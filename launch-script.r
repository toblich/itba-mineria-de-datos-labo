args <- commandArgs(trailingOnly = TRUE)

argsStr <- paste(args, collapse = ", ")

writeLines(sprintf("Launch script invoked with args %s", argsStr))

funcName <- tolower(args[1])
experiment <- toupper(args[2])

writeLines(funcName)
writeLines(experiment)

source( "/home/tlichtig/labo/src/lib/exp_lib.r" )

writeLines("'exp_lib.r' loaded.")

if (experiment == NA || experiment == "" || experiment == NULL) {
  writeLines("No se seleccionó experimento.")
  exp_finalizar()
}

if (funcName == "start") {
  writeLines("Arrancando un experimento nuevo")
  exp_start(experiment)
} else if (funcName == "restart") {
  writeLines("Restarteando un experimento")
  exp_restart(experiment)
} else {
  writeLines("Está mal definida la acción a ejecutar")
  exp_finalizar()
}
