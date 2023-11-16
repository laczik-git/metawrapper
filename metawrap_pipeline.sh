#!/bin/bash

###################################################################################
# Help!                                                                           #
###################################################################################
Help()
{
    # Display Help
    echo "This script will execute the MetaWrap pipeline (assembly [with megahit] --> binning [with concoct, MetaBat2, MaxBin2]  --> bin_refinement --> quant_bin) and identify bins with gtdb-tk (with the classify workflow)"
    echo "Syntax: ./metawrap_pipeline.sh [options]"
    echo
    echo "Mandatory arguments: -1; -2; -r; -m; -g; -c; -k"
    echo
    echo "File options:"
    echo
    echo "-1 --> path and name of the fastq file with all forward read of all the samples"
    echo "-2 --> path and name of the fastq file with all forward read of all the samples"
    echo "-r --> path to the individual fastq files of all the samples"
    echo
    echo "Anaconda environments:"
    echo
    echo "-m --> name of the anaconda environment containing metawrap"
    echo "-g --> name of the anaconda environment containing gtdb-tk"
    echo
    echo "Refinement options"
    echo
    echo "-c --> minimum completeness of the bins [number in percentage 1-100]"
    echo "-k --> maximum contamination of the bins [number in percentage 1-100]"
    echo
    echo "General options:"
    echo
    echo "-t --> number of cpu threads"
    echo "-p --> number of pplacer threads"
    echo "-h --> displays this help"
    echo
}


while getopts "1:2:r:d:m:g:c:k:t:p:h" option; do
  case $option in
    1)
      forward_read="$OPTARG"
      ;;
    2)
      reverse_read="$OPTARG"
      ;;
    r)
      path="$OPTARG"
      ;;
    m)
      metawrap="$OPTARG"
      ;;
    g)
      gtdb="$OPTARG"
      ;;
    c)
      completeness="$OPTARG"
      ;;
    k)
      contamination="$OPTARG"
      ;;
    t)
      threads="$OPTARG"
      ;;
    p)
      pplacer="$OPTARG"
      ;;
    h)
      Help
      exit 1
      ;;
  esac
done

eval "$(conda shell.bash hook)"
conda activate "$metawrap"

echo
echo "**********************************************************************************************************************"
echo "****                                       THE ASSEMBLY STARTS!                                                   ****"
echo "**********************************************************************************************************************"
echo

metawrap assembly --megahit -t "$threads" -o assembly -1 "$forward_read" -2 "$reverse_read";

echo
echo "**********************************************************************************************************************"
echo "****                                      INITIAL BINNING STARTS!                                                 ****"
echo "**********************************************************************************************************************"
echo

metawrap binning -a assembly/final_assembly.fasta -o binning -t "$threads" --metabat2 --concoct --maxbin2 "$forward_read" "$reverse_read";

echo
echo "**********************************************************************************************************************"
echo "****                                       BIN REFINEMENT STARTS!                                                 ****"
echo "**********************************************************************************************************************"
echo

metawrap bin_refinement -o bin_refinement -t "$threads" -A binning/metabat2_bins/ -B binning/maxbin2_bins/ -C binning/concoct_bins/ -c "$completeness" -x "$contamination";

echo
echo "**********************************************************************************************************************"
echo "****                                     BIN QUANTIFICATION STARTS!                                               ****"
echo "**********************************************************************************************************************"
echo

metawrap quant_bins -b bin_refinement/metawrap_"$completeness"_"$contamination"_bins/ -o quantitate_bins -a assembly/final_assembly.fasta -t "$threads" "$path"/*.fastq*;

eval "$(conda shell.bash hook)"
conda activate "$gtdb"

echo
echo "**********************************************************************************************************************"
echo "****                                     BIN CLASSIFICATION STARTS!                                               ****"
echo "**********************************************************************************************************************"
echo

gtdbtk classify_wf --genome_dir bin_refinement/metawrap_"$completeness"_"$contamination"_bins --out_dir gtdb_classification -x fa --cpus "$threads" --pplacer_cpus "$pplacer";
