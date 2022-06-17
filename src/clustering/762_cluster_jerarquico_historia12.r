# este script necesita para correr en Google Cloud
# RAM     16 GB
# vCPU     4
# disco  256 GB


# cluster jerárquico  utilizando "la distancia de Random Forest"
# adios a las fantasias de k-means y las distancias métricas, cuanto tiempo perdido ...
# corre muy lento porque la libreria RandomForest es del Jurasico y no es multithreading

# limpio la memoria
rm(list = ls()) # remove all objects
gc() # garbage collection

require("data.table")
require("randomForest")
require("ranger")

START <- strftime(as.POSIXlt(Sys.time(), tz = "UTC"), "%Y-%m-%d_%H:%M:%S%z")

setwd("~/buckets/b1/") # cambiar por la carpeta local

# leo el dataset
dataset_grande <- fread("./exp/FE0001T/paquete_premium_ext.csv.gz", stringsAsFactors = TRUE)

# me quedo SOLO con los BAJA+2
dataset <- copy(dataset_grande[clase_ternaria == "BAJA+2" & foto_mes >= 202001 & foto_mes <= 202011, ])

# armo el dataset de los 12 meses antes de la muerte de los registros que analizo
dataset12 <- copy(dataset_grande[numero_de_cliente %in% dataset[, unique(numero_de_cliente)]])

# asigno para cada registro cuantos meses faltan para morir
setorderv(dataset12, c("numero_de_cliente", "foto_mes"), c(1, -1))
dataset12[, pos := seq(.N), numero_de_cliente]

# me quedo solo con los 12 meses antes de morir
dataset12 <- dataset12[pos <= 12, ]
gc()


# quito los nulos para que se pueda ejecutar randomForest,  Dios que algoritmo prehistorico ...
dataset <- na.roughfix(dataset)


# los campos que arbitrariamente decido considerar para el clustering
# por supuesto, se pueden cambiar
campos_buenos <- c(
  # Primeras 100 variables según /Users/tlichtig/Desktop/ITBA/2-mineria-de-datos/labo/exp/ZZ0005T/FM_importance_101.txt
  "ctrx_quarter_normalizado",
  "ctrx_quarter",
  "mtarjeta_visa_consumo",
  "mprestamos_personales_ratioavg6",
  "t_mcapital",
  "mcaja_ahorro",
  "mv_status06_tend6",
  "cpayroll_trx",
  "ctarjeta_visa_trx",
  "mcuentas_saldo",
  "mpayroll",
  "mpasivos_margen",
  "mdescubierto_preacordado_tend6",
  "Visa_mfinanciacion_limite",
  "cproductos_ratioavg6",
  "mv_status07_ratioavg6",
  "mdescubierto_preacordado_avg6_delta1",
  "t_mpayroll_total_sobre_edad",
  "t_mcapital_rank",
  "ctarjeta_visa_trx_ratioavg6",
  "mprestamos_personales",
  "mprestamos_personales_min6",
  "mdescubierto_preacordado_delta3",
  "mtarjeta_visa_consumo_ratioavg6",
  "cpayroll_trx_ratioavg6",
  "mpayroll_sobre_edad",
  "mdescubierto_preacordado_avg6_delta1_delta3",
  "mv_msaldototal",
  # "foto_mes",
  "mcomisiones_mantenimiento_avg6_delta1",
  "ccomisiones_mantenimiento_tend6",
  "ccomisiones_mantenimiento_avg6_delta1",
  "mcuentas_saldo_ratioavg6",
  # "mes",
  "mcuentas_saldo_min6_delta2",
  "mv_msaldopesos",
  "ccaja_ahorro",
  "mcuenta_corriente_avg6_delta1",
  "mcaja_ahorro_dolares_delta1",
  "ctarjeta_visa_trx_avg6_lag1_delta2_lag3",
  "mdescubierto_preacordado",
  "mdescubierto_preacordado_delta1",
  "mv_status06_ratioavg6",
  "ccomisiones_mantenimiento_ratioavg6",
  "ctrx_quarter_avg6_delta1_lag2_lag3",
  "cproductos_min6_delta1",
  "tcallcenter_tend6",
  "mactivos_margen",
  "mprestamos_personales_ratioavg6_lag1",
  "mcuentas_saldo_avg6_delta3",
  "mprestamos_personales_tend6",
  "thomebanking_ratioavg6",
  "t_mpayroll_sobre_capital_rank",
  "mtarjeta_visa_consumo_avg6_delta1",
  "ccaja_ahorro_avg6",
  "ccallcenter_trx_ratioavg6",
  "mtransferencias_recibidas",
  "mprestamos_personales_avg6_lag1_lag2",
  "mprestamos_personales_ratioavg6_delta2_delta3",
  "thomebanking",
  "mdescubierto_preacordado_tend6_delta2_delta3",
  "mactivos_margen_lag2_lag3",
  "mcuentas_saldo_min6_delta1",
  "Visa_fultimo_cierre_avg6_lag2_delta3",
  "mprestamos_personales_delta3",
  "ccaja_seguridad",
  "t_mpayroll_total",
  "mdescubierto_preacordado_tend6_delta1_delta2_delta3",
  "ctrx_quarter_normalizado_avg6_delta1_lag2_lag3",
  "mcomisiones_mantenimiento_ratioavg6",
  "mcaja_ahorro_ratioavg6",
  "mvr_mpagominimo_avg6",
  "mactivos_margen_min6",
  "cproductos_delta2",
  "mprestamos_personales_ratioavg6_lag2",
  "Master_Fvencimiento_ratioavg6_delta1_delta2",
  "cproductos_avg6_delta1",
  "mactivos_margen_ratioavg6",
  "t_mcapital_rank_min6_delta2",
  "mcomisiones_mantenimiento",
  "cproductos",
  "ctarjeta_master_trx_ratioavg6",
  "mcomisiones_mantenimiento_avg6_delta1_lag2_lag3",
  "mrentabilidad_avg6_lag1_lag2",
  "ccomisiones_mantenimiento_delta1",
  "mdescubierto_preacordado_tend6_delta1_delta2",
  "mprestamos_personales_min6_lag1_lag2",
  "chomebanking_trx_delta1",
  "mv_status01",
  "t_mpayroll_total_min6",
  "mactivos_margen_avg6",
  "ccallcenter_trx_avg6_delta1",
  "t_mpayroll_total_min6_delta2",
  "ccallcenter_trx_tend6",
  "mcuentas_saldo_min6",
  "Visa_msaldopesos",
  "Visa_fechaalta_tend6",
  "mv_mpagominimo",
  "mcomisiones_mantenimiento_tend6",
  "ccaja_ahorro_ratioavg6"

  # Variables que puso Gustavo
  # "ctrx_quarter",
  # "cpayroll_trx",
  # "mcaja_ahorro",
  # "mtarjeta_visa_consumo",
  # "ctarjeta_visa_trx",
  # "mcuentas_saldo",
  # "mrentabilidad_annual",
  # "mprestamos_personales",
  # "mactivos_margen",
  # "mpayroll",
  # "Visa_mpagominimo",
  # "Master_fechaalta",
  # "cliente_edad",
  # "chomebanking_trx",
  # "Visa_msaldopesos",
  # "Visa_Fvencimiento",
  # "mrentabilidad",
  # "Visa_msaldototal",
  # "Master_Fvencimiento",
  # "mcuenta_corriente",
  # "Visa_mpagospesos",
  # "Visa_fechaalta",
  # "mcomisiones_mantenimiento",
  # "Visa_mfinanciacion_limite",
  # "mtransferencias_recibidas", "cliente_antiguedad",
  # "Visa_mconsumospesos",
  # "Master_mfinanciacion_limite",
  # "mcaja_ahorro_dolares",
  # "cproductos",
  # "mcomisiones_otras",
  # "thomebanking",
  # "mcuenta_debitos_automaticos",
  # "mcomisiones",
  # "Visa_cconsumos",
  # "ccomisiones_otras",
  # "Master_status",
  # "mtransferencias_emitidas",
  # "mpagomiscuentas"
)



# Ahora, a esperar mucho con este algoritmo del pasado que NO correr en paralelo, patetico
modelo <- randomForest(
  x = dataset[, campos_buenos, with = FALSE],
  y = NULL,
  ntree = 1000, # se puede aumentar a 10000
  proximity = TRUE,
  oob.prox = TRUE
)

# genero los clusters jerarquicos
hclust.rf <- hclust(as.dist(1.0 - modelo$proximity), # distancia = 1.0 - proximidad
  method = "ward.D2"
)



# primero, creo la carpeta donde van los resultados
dir.create("./exp/", showWarnings = FALSE)
dir.create("./exp/ST7621", showWarnings = FALSE)
setwd("~/buckets/b1/exp/ST7621")


# imprimo un pdf con la forma del cluster jerarquico
# pdf("cluster_jerarquico.pdf")
# plot(hclust.rf)
# dev.off()


# genero 7 clusters
h <- 20
distintos <- 0

while (h > 0 & !(distintos >= 6 & distintos <= 7)) {
  h <- h - 1
  rf.cluster <- cutree(hclust.rf, h)

  dataset[, cluster2 := NULL]
  dataset[, cluster2 := rf.cluster]

  distintos <- nrow(dataset[, .N, cluster2])
  cat(distintos, " ")
}

# en  dataset,  la columna  cluster2  tiene el numero de cluster
# sacar estadicas por cluster

dataset[, .N, cluster2] # tamaño de los clusters

# grabo el dataset en el bucket, luego debe bajarse a la PC y analizarse
fwrite(dataset,
  file = sprintf("cluster_de_bajas_%s.tsv", START),
  sep = "\t"
)


# ahora a mano veo los centroides de los 7 clusters
# esto hay que hacerlo para cada variable,
#  y ver cuales son las que mas diferencian a los clusters
# esta parte conviene hacerla desde la PC local, sobre  cluster_de_bajas.txt

dataset[, mean(ctrx_quarter), cluster2] # media de la variable  ctrx_quarter
dataset[, mean(mtarjeta_visa_consumo), cluster2]
dataset[, mean(mcuentas_saldo), cluster2]
dataset[, mean(chomebanking_trx), cluster2]


# Finalmente grabo el archivo para  Juan Pablo Cadaveira
# agrego a dataset12 el cluster2  y lo grabo

dataset12[dataset,
  on = "numero_de_cliente",
  cluster2 := i.cluster2
]

fwrite(dataset12,
  file = sprintf("cluster_de_bajas_12meses_%s.tsv", START),
  sep = "\t"
)
