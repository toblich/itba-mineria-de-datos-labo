export EXPERIMENT=ZZ0007T
export FUNC=start
export CPU=16
export RAM=$((1024 * 128))-ext
export DISK_SIZE=350

export INSTANCE_NAME=vm-$(echo $EXPERIMENT | awk '{print tolower($0)}')
export MACHINE_TYPE=custom-$CPU-$RAM

# export RSCRIPTPATH="/home/tlichtig/labo/launch-script.r"
export RSCRIPTPATH="/home/tlichtig/labo/src/clustering/z762_cluster_jerarquico_historia12.r"

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
  --create-disk=auto-delete=yes,boot=yes,device-name=$INSTANCE_NAME,image=projects/indigo-history-351015/global/images/dm-custom-with-logs,mode=rw,size=$DISK_SIZE,type=projects/indigo-history-351015/zones/us-west4-c/diskTypes/pd-standard \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --reservation-affinity=any \
  --metadata=shutdown-script=suicidio.sh,func=$FUNC,experiment=$EXPERIMENT,rscriptpath=$RSCRIPTPATH \
  --metadata-from-file=startup-script="/Users/tlichtig/Desktop/ITBA/2-mineria-de-datos/labo/startup-script.sh"

sleep 60;  gcloud compute ssh "$INSTANCE_NAME" --command 'tail -n 100 -f /home/tlichtig/script.log'

# gcloud compute ssh "$INSTANCE_NAME"

# gcloud compute instances delete "$INSTANCE_NAME"
