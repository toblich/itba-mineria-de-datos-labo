#!/bin/zsh

DIR=`dirname -- $0`

EXPERIMENT=$1

gsutil -m cp "gs://tobi-data-ecd/exp/$EXPERIMENT/futuro_prediccion_*.csv" "$DIR/exp/$EXPERIMENT"
