#!/bin/bash -l

#SBATCH --partition=mcovert
#SBATCH --time=23:30:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=3
#SBATCH --cpus-per-task=3
#
# Note: the time for the job is shorter than 24 hours to prevent multiple instances
# of OMERO running concurrently.
#
# 01 00 * * * /share/PI/mcovert/usr/local/bin/share_job.sh /share/PI/mcovert/etc/share_job/jenkins /share/PI/mcovert/usr/local/bin/jenkins_job.sh 4242

function get_port {
  local DESIRED_PORT=$1
  while [ $(netstat -lnt | grep ":$DESIRED_PORT " | wc -l) -ne 0 ]; do
    (( DESIRED_PORT++ ))
  done
  echo $DESIRED_PORT
}

REPO_ABSOLUTE_PATH=/share/PI/mcovert/omero
PGPASSWORD=covert_omero

PG_PORT=$(get_port 5432)
REGISTRY_PORT=$(get_port 4061)
TCP_PORT=$(get_port 4063)
SSL_PORT=$(get_port 4064)
WEB_PORT=$(get_port 4080)
HTTP_PORT=$(get_port 8080)


module load singularity/2.2
singularity run -w -B "$REPO_ABSOLUTE_PATH/data:/omero/data" -B "$REPO_ABSOLUTE_PATH/var:/omero/var" -B "$REPO_ABSOLUTE_PATH/postgres:/omero/postgres" -B "$REPO_ABSOLUTE_PATH/run:/omero/run" -B "$REPO_ABSOLUTE_PATH/user_scripts:/omero/user_scripts" $REPO_ABSOLUTE_PATH/omero.img --pg-port $PG_PORT --pg-password $PGPASSWORD --server-registry-port $REGISTRY_PORT --server-tcp-port $TCP_PORT --server-ssl-port $SSL_PORT --web $WEB_PORT --http $HTTP_PORT
