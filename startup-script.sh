#! /bin/bash

cd /home/tlichtig

RSCRIPTPATH=$(curl http://metadata.google.internal/computeMetadata/v1/instance/attributes/r-script-path -H "Metadata-Flavor: Google")

cat > runner.sh <<FILE
#! /bin/bash
cd /home/tlichtig
echo "[Startup] About to begin Rscript process with $RSCRIPTPATH" >> script.log
runuser -l tlichtig -c "Rscript $RSCRIPTPATH" >> script.log
echo "[Startup] Rscript $RSCRIPTPATH process finished! - Powering off..." >> script.log
sleep 120
poweroff
FILE

chmod +x runner.sh

nohup ./runner.sh &
