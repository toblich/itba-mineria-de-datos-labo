#!/bin/zsh

DIR=`dirname -- $0`

EXPERIMENT=$1

if [[ $EXPERIMENT == ZZ* ]]; then
  gsutil -m cp \
    "gs://tobi-data-ecd/exp/$EXPERIMENT/futuro_prediccion_*.csv" \
    "gs://tobi-data-ecd/exp/$EXPERIMENT/tb_predicciones.txt" \
    "gs://tobi-data-ecd/exp/$EXPERIMENT/${EXPERIMENT}_semillerio_*.csv" \
    "$DIR/exp/$EXPERIMENT" # directorio donde escribir
fi

if [[ $EXPERIMENT == HT* ]]; then
  gsutil -m cp "gs://tobi-data-ecd/exp/$EXPERIMENT/BO_log.txt" "$DIR/exp/$EXPERIMENT"
fi
