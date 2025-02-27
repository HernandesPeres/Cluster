#!/bin/bash

# Total number of jobs (adjustable)
# Make sure it doesn't exceed the queue limits
#NUM_JOBS=45
NUM_JOBS=40
# Name of the PBS script (adjustable)
PBS_SCRIPT="simulation_jobs.pbs"

# Index range (1 to NUM_JOBS)
for i in $(seq 1 $NUM_JOBS)
do
    echo -n "Submitting job with index $i - "
    # Attempts to run qsub and capture output and error
    # qsub uses -v to pass the JOB_INDEX environment variable with the value of $i
    # This variable can be accessed within the PBS script (clonal_job.pbs) as $JOB_INDEX
    JID=$(qsub -v JOB_INDEX=$i $PBS_SCRIPT 2>&1)
    if [ $? -eq 0 ]; then
        # If qsub was successful (exit code 0), print the JID
        echo "JID: $JID"
    else
        # If there was an error (non-zero exit code), print the error message
        echo "Error: $JID"
    fi
done
