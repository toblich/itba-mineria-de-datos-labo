#!/bin/zsh

DIR=`dirname -- $0`

EXPERIMENT=$1

if [[ $EXPERIMENT == ZZ* ]]; then
  gsutil -m cp "gs://tobi-data-ecd/exp/$EXPERIMENT/futuro_prediccion_*.csv" "$DIR/exp/$EXPERIMENT"
fi

if [[ $EXPERIMENT == HT* ]]; then
  gsutil -m cp "gs://tobi-data-ecd/exp/$EXPERIMENT/BO_log.txt" "$DIR/exp/$EXPERIMENT"
fi
