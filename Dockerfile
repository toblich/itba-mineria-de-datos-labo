FROM jupyter/datascience-notebook:2022-05-05

USER $NB_UID

RUN conda config --append channels r && \
  conda config --set channel_priority strict

RUN mamba install --yes \
  "r-Hmisc" \
  "r-rlist" \
  "r-vioplot" \
  "r-ROCR" \
  "r-gganimate" \
  "r-transformr" \
  "r-DiagrammeR" \
  "r-rpart.plot" \
  "r-ranger" \
  "r-xgboost" \
  "r-lightgbm" \
  "r-DiceKriging" \
  "r-mlrMBO"
  # "r-treeclust"
  # "r-primes"
