#! /bin/bash

cd /home/tlichtig

RSCRIPTPATH="/home/tlichtig/labo/launch-script.r"
FUNC=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/func -H "Metadata-Flavor: Google")
EXPERIMENT=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/experiment -H "Metadata-Flavor: Google")

cat > runner.sh <<FILE
#! /bin/bash
cd /home/tlichtig
echo "[Startup] About to begin Rscript process with $RSCRIPTPATH $FUNC $EXPERIMENT" >> script.log
runuser -l tlichtig -c "Rscript $RSCRIPTPATH $FUNC $EXPERIMENT" >> script.log
echo "[Startup] Rscript $RSCRIPTPATH $FUNC $EXPERIMENT process finished! - Powering off..." >> script.log
sleep 300
poweroff
FILE

chmod +x runner.sh

nohup ./runner.sh &
