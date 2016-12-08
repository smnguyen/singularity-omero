#!/bin/bash

USER_SHARE_FILE="$1"; shift
SCRIPT_TO_SUBMIT="$1"; shift
PORTS="$*"
SLEEP_TIME=5
POSITION_IN_FILE="$(grep -n "$USER" $USER_SHARE_FILE | sed 's/:.*//')"
LINES_IN_FILE="$(wc -l $USER_SHARE_FILE | awk '{print $1}')"

DAYS_SINCE_EPOCH=$(echo "$(date +%s) / (24*3600)" | bc)

if [ "$(echo $DAYS_SINCE_EPOCH % $LINES_IN_FILE | bc)" = "$(echo $POSITION_IN_FILE - 1 | bc)" ]; then
    JOB_ID="$(sbatch $SCRIPT_TO_SUBMIT | awk '{print $4}')"
    HOST="$(squeue -j $JOB_ID -o "%R" | tail -n 1)"
    echo Submitted batch job ${JOB_ID}

    if [ -n "$PORT" ]; then
        sleep $SLEEP_TIME
        while [ "$HOST" = "(None)" ]; do
            HOST=$(squeue -j $JOB_ID -o "%R" | tail -n 1)
            sleep $SLEEP_TIME
        done

        echo "SSH'ing to host: $HOST"
        TUNNEL=""
        for PORT in $PORTS; do
            TUNNEL="$TUNNEL -L $PORT:localhost:$PORT"
        done
        ssh -nNT $TUNNEL $HOST
    fi
fi
