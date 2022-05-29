export INSTANCE_NAME=xgboost-opt-hist-573
export SCRIPT=xgboost/z573_xgboost_histograma_BO.r
export CPU=8
export RAM=$((1024 * 16))

export MACHINE_TYPE=custom-$CPU-$RAM

gcloud compute instances create "$INSTANCE_NAME" \
  --project=indigo-history-351015 \
  --zone=us-west4-c \
  --machine-type="$MACHINE_TYPE" \
  --network-interface=network-tier=PREMIUM,subnet=default \
  --no-restart-on-failure \
  --maintenance-policy=TERMINATE \
  --provisioning-model=SPOT \
  --instance-termination-action=DELETE \
  --service-account=934014334952-compute@developer.gserviceaccount.com \
  --scopes=https://www.googleapis.com/auth/cloud-platform \
  --tags=http-server \
  --create-disk=auto-delete=yes,boot=yes,device-name=$INSTANCE_NAME,image=projects/indigo-history-351015/global/images/dm-custom-with-logs,mode=rw,size=256,type=projects/indigo-history-351015/zones/us-west4-c/diskTypes/pd-standard \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --reservation-affinity=any \
  --metadata-from-file=startup-script="/Users/tlichtig/Desktop/ITBA/2-mineria-de-datos/labo/startup-script.sh" \
  --metadata=shutdown-script=suicidio.sh,r-script-path="/home/tlichtig/labo/src/$SCRIPT"


# gcloud compute ssh "$INSTANCE_NAME"

# gcloud compute instances delete "$INSTANCE_NAME"
