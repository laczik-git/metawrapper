# metawrapper
This simple bash script fully automates the MetaWRAP pipeline from metagenome assembly until bin classification. This pipeline does not run the Kraken2 and the bin reassembly modules if you need them run them separately or feel free to implement them into the script.
Make sure you have Metawrap installed in an Anaconda environment (https://github.com/bxlab/metaWRAP)! You will also need GTDB-tk (https://github.com/Ecogenomics/GTDBTk) to fully utilize the power of the script. 

## Installation of prerequironments
conda create -n metawrap -c ursky metawrap-mg
conda create -n gtdbtk -c bioconda gtdbtk

## Usage 
bash metawrap_pipeline.sh

## Mandatory arguments: -1; -2; -r; -m; -g; -c; -k
    
    ### File options:
    
    -1 --> path and name of the fastq file with all forward read of all the samples
    -2 --> path and name of the fastq file with all reverse read of all the samples
    -r --> path to the individual fastq files of all the samples
    
    Anaconda environments:
    
    -m --> name of the anaconda environment containing metawrap
    -g --> name of the anaconda environment containing gtdb-tk
    
    Refinement options
    
    -c --> minimum completeness of the bins [number in percentage 1-100]
    -k --> maximum contamination of the bins [number in percentage 1-100]
    
    General options:
    
    -t --> number of cpu threads
    -p --> number of pplacer threads
    -h --> displays this help
