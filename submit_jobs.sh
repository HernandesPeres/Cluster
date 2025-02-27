#!/bin/bash

NUM_JOBS=4

PBS_SCRIPT="simulation_jobs.pbs"

for i in $(seq 1 $NUM_JOBS)
do
    echo -n "Submitting job with index $i - "

    JID=$(qsub -v JOB_INDEX=$i $PBS_SCRIPT 2>&1)
    if [ $? -eq 0 ]; then
        echo "JID: $JID"
    else
        echo "Error: $JID"
    fi
done
