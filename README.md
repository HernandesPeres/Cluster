## Cluster 💻

Here you will find all the information needed to implement any script in the Cluster.

### Important commands

```{r message=FALSE}
mkdir <new_folder_name>          # Create a new directory  
cd <folder_name>                 # Access the directory  
pwd                              # View the current directory  
ls                               # List all files inside the current folder  
qsub <file_name>.pbs             # Submit the 'PBS' file for execution  
qstat -anu <login>               # Check the status of running jobs  
module load <software_name>      # Load the desired software  
r                                # Start the R software  
$                                # Specify a variable to be used 
```

### PBS script

The PBS script must be modified according to your specific needs.

The file 0.RUNME.PBS is the main PBS script, responsible for starting the execution of the R script, which in turn will call all other necessary scripts.

```{r message=FALSE, warning=FALSE}
#!/bin/bash                             # Do not change
#PBS -N job                             # Job's name
#PBS -l nodes=1:ppn=4                   # Specify nodes & ppn
#PBS -l walltime=23:59:00               # Time of processing
#PBS -l mem=8gb                         # RAM needed
#PBS -o output.log                      # Folder for the outputs
#PBS -e error.log                       # Folder for the errors
#PBS -m abe                             # Notification when: a(abortion), b(begun), e(end)
#PBS -M hernandes.panichi@ufv.br        # Email to receive the notifications
#PBS -J 1-10                            # Number of lines at the scenarios archive (All the combinated variables)

### Setting up the environment - Do not change this part (never)

cd $PBS_O_WORKDIR

### Script begins here

jobID=$PBS_ARRAY_INDEX                        # Takes the scenarios archive as array

fileInfo='<your_dir>/scenarios_test.txt'      # Diretory of the scenario archive

scenario=$(sed -n ${jobID}p ${fileInfo})      # scenario use each line of the archive as a single scenario

module load r # Loading R                     # Load R

# Run R script
Rscript RUNME.R $scenario                     # Run R script calling the variable scenario
```

It is important to have an additional file called scenarios_test.txt, which contain all the variable combinations to be tested, including:

🔗 Number of repetitions 🔗 Degree of dominance 🔗 Heritability

All these variables will be read and processed, line by line, within R during execution, as specified in R script.

### scenarios_test.txt 

You will have columns representing different variables, and all possible values of each variable will be combined with all values of the other variables. These combinations will be used inside R during execution.

```{r message=FALSE}
rm(list=ls())

setwd("<your_dir>/")

options(echo=TRUE)
args = commandArgs(trailingOnly=TRUE)
variable_1 <- as.numeric(args[1])               # Taking first arg
variable_2 <- as.numeric(args[2])               # Taking second arg 
variable_3 <- as.numeric(args[3])               # Taking third arg
```
