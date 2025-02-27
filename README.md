
## Cluster 💻

Here you will find all the information needed to implement R scripts in the Cluster.

## Introduction to PBS script

There are 2 steps to run computational tasks on an HPC

### 1. Requesting resources

-   Number of nodes
-   Number of processor per node
-   Amount of RAM
-   Software scripts that you be utilized

The PBS script must be modified according to your specific needs.

[!TIP]

-   Always check the ".e" e. ".o" files generated
-   Always check your e-mail
-   Always check and validate your outputs
-   Read the documentation of the software you are going to use

1.  In this example, we have configured a job:

-   it will named "simulation"
-   it requires "1" node (nodes=1), "4" processors (ppn=4) and "20gb" of RAM (men = 20gb)
-   an email will be sent when the job stats ("b"), abort ("a"), and finishes ("e")
-   Processing will be stopped when it reaches 24 hours of running time (walltime = 24:00:00)
-   all output will be saved in "output.log" file.
-   if an error occurs, it will be save at "error.log" file
-   specify your e-mail to receive the notifications

```{bash}
#!/bin/bash                             # Do not change
#PBS -N simulation                      # Job's name
#PBS -l nodes=1:ppn=4,mem=12gb          # Nodes,ppn & RAM
#PBS -m abe                             # Abort, begun, end
#PBS -l walltime=24:00:00               # Time of processing
#PBS -o output.log                      # Folder for the outputs
#PBS -e error.log                       # Folder for the errors
#PBS -M <your e-mail>                   # Email to receive the notifications
```

### Setting up the environment

Never change this part

```{bash}
cd $PBS_O_WORKDIR
```

## Script begins here

[!NOTE] \### Why should you use JOB_INDEX?

The **'JOB_INDEX'** variable is used to differentiate and handle multiple job submissions when you're running a set of similar jobs. It's particularly useful in scenarios like running simulations, processing data, or performing tasks in parallel with each job having a unique index.

Here's why it's used:

**Dynamic Job Management:** In batch processing, especially when submitting many jobs that follow a similar structure but need to process different data or configurations, the **'JOB_INDEX'** allows each job to know its own unique position in the queue (e.g., job 1, job 2, etc.).

**Indexing for Data:** The **'JOB_INDEX'** is used to select a specific item (like a row or scenario) from a list or file. In your script, it helps determine which line to pick from the file *"scenarios"* based on the job's index. Each job can then process a unique scenario or dataset from that file.

**Automation:** Using JOB_INDEX allows for automating the submission of many jobs without needing to manually specify each one. By passing **'JOB_INDEX'** when submitting, you can easily scale your job submissions without modifying the script for each job.

For example, if you are running a simulation for several scenarios listed in a file, each job would be assigned a unique index that corresponds to a different line in the file, and each job processes a different scenario based on that index. This way, you can efficiently run many jobs in parallel.

In the example the **'JOB_INDEX'** variable is received as an environment variable passed by *qsub* in the submission script (submit_jobs.sh).

It contains the index of the current job (e.g., 1, 2, ..., 45) and can be used here.

Checking if **'JOB_INDEX'** was defined:

```{bash}
if [ -z "$JOB_INDEX" ]; then
    echo "Error: The JOB_INDEX environment variable is not defined."
    echo "You probably forgot to pass JOB_INDEX via 'qsub -v JOB_INDEX=<value>' in the submission script."
    exit 1  # Exit with an error code
fi

echo "Executing job with index: $JOB_INDEX"
```

jobID with the value passed by **'JOB_INDEX'**:

```{bash}
jobID=$JOB_INDEX
```

*multiple_jobs* stores the path to the data file for the distinct scenarios

```{bash}
multiple_jobs = '<your_dir>/scenarios'
```

Then, the script uses *multiple_jobs* to access the file and extract information from a specific line based on the **'JOB_INDEX'** value.

```{bash}
scenario=$(sed -n ${jobID}p ${multiple_jobs})
```

Loading the software that will be used to run the task, in our case, the R software:

```{bash}
module load r
```

Running a R script, with the directory where the script is being run *\$scenario* is a variable that holds the specific value to be passed as an argument to the **'RUNME.R'** script.

The value of *scenario* is determined by extracting a line from the *multiple_jobs* file, based on the job's index ("JOB_INDEX"). This value will be used within the R script to process data or perform some task

```{bash}
Rscript RUNME.R $scenario 
```

### Before run the jobs

As I mentioned before, it is important to have an additional file called *'scenarios'* which contains information that will be extract line by line based on the **'JOB_INDEX'** previously defined.

In the example, two columns are used to refer to the variables *'rep'* and *'herdability'*. The *'rep'* values from 1 to 2, and *'herdability'* values are 0.3 and 0.7.

```{bash}
1 0.3 
1 0.7
2 0.3
2 0.7
```

After defining the *"scenarios"* we also have to define the previously mentioned file called **submit_jobs.sh** which is used to implement multiple jobs without submitting them as a single job. Submitting them as one job could lead to interruptions if it requires too much memory.

First, you need to give execution permission using the following command:

```{bash}
chmod +x submit_jobs.sh
```


so now, instead of use *'qsub'* to submit the *'simulation.pbs'* file, we use:

```{bash}
./submit_jobs.sh
```

And it will submit the N jobs according to your needs

### getting the values at R script

You will have columns representing different variables, and all possible values of each variable will be combined with all values of the other variables. These combinations will be used inside R during execution.

```{r message=FALSE}
rm(list=ls())

setwd("/<your_dir>/")

options(echo=TRUE)
args = commandArgs(trailingOnly=TRUE)
rep <- as.numeric(args[1])           # Taking first arg
herdability <- as.numeric(args[2])   # Taking second arg 
```

## Important Commands

Below is a list of essential commands used for managing directories, submitting jobs, and working with software modules in a high-performance computing (HPC) environment.

1. Directory and File Management
```{bash}
mkdir <new_folder_name>  # Create a new directory
cd <folder_name>         # Navigate into the specified directory
pwd                      # Display the current working directory
ls                       # List all files and folders in the current directory
```

2. Job Submission and Monitoring
```{bash}
qsub <file_name>.pbs      # Submit a PBS script for job execution
qstat -anu <login>        # Check the status of running jobs for a specific user
```

3. Deleting job
```{bash}
pkill -u $USER <process_name>
pkill -u $USER                 
```

4. Software and Environment Management
```{bash}
module load <software_name>  # Load the specified software module
r                            # Start the R software environment
```

5. Variable Usage in Scripts
```{bash}
$<variable_name>  # Reference a variable in shell scripts
```

### Notes:
- Replace `<new_folder_name>` and `<folder_name>` with the actual names you want to use.
- Ensure that your PBS script is properly configured before submitting it with `qsub` or `./<file_name>.sh`.
- When using `qstat -anu <login>`, replace `<login>` with your actual username.
- Use `module avail` to check available software modules before loading one.
