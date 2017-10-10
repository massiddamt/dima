#!/usr/bin/env bash

usage="$(basename "$0") [-h] -c FILENAME [-w DIR] [-s \"parameters\"] --script to execute a snakemake workflow

where:
    -h  show this help text
    -c  path to the snakemake's configuration file.
    -w  is the project's workdir label. Default is current timestamp.
    -s  snakemake parameters as \"--rerun-incomplete --dryrun --keep-going --restart-time\"
"

while getopts ':hc:w:s:' option; do
  case "$option" in
    h) echo "$usage"
       exit
       ;;
    c) CONFIG_FILE=$OPTARG
       ;;
    w) SM_WORK_DIR=$OPTARG
       ;;
    s) SM_PARAMETERS=$OPTARG
       ;;
    :) printf "missing argument for -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
   \?) printf "illegal option: -%s\n" "$OPTARG" >&2
       echo "$usage" >&2
       exit 1
       ;;
    *) echo "$usage"
       exit
  esac
done
shift $((OPTIND - 1))

[ -z ${SM_WORK_DIR:=$(date +%F_%s)} ]

if [ -f "$CONFIG_FILE" ]
then
   CONFIG_FILEPATH=$(readlink -e "${CONFIG_FILE}")
   echo "Running snakemake with ${CONFIG_FILEPATH} on $(pwd)/${SM_WORK_DIR}"
else
   echo "${CONFIG_FILE} config file not found"
   echo "$usage" >&2
   exit 1
fi

if [ -f ".git_repo_last_commit" ]
then
   cp .git_repo_last_commit "${SM_WORK_DIR}"
fi

PROJECT_NAME="_project_name_"
source activate ${PROJECT_NAME}

SHORTNAME=${PROJECT_NAME:0:1}${PROJECT_NAME: -1}

if [ -f 'cluster.json' ]
then
    snakemake --use-conda \
          --stats stats.json \
          --configfile ${CONFIG_FILEPATH} \
          --directory ${SM_WORK_DIR} \
          --printshellcmds \
          --cluster-config cluster.json \
          --max-jobs-per-second 1 \
          --cores 20 \
          --latency-wait 120 \
          --jobname ${SHORTNAME}".{rulename}.{jobid}.sh" \
          --jobs 64 \
          --drmaa ' -S /bin/bash {cluster.hosts_group} -w n -b y -V ' \
	  --drmaa-log-dir "logs/ge" \
          ${SM_PARAMETERS}
else
     snakemake --use-conda \
          --stats stats.json \
          --configfile ${CONFIG_FILEPATH} \
          --directory ${SM_WORK_DIR} \
          --printshellcmds \
	  ${SM_PARAMETERS}
fi
 
          
