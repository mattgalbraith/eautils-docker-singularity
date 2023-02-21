[![Docker Image CI](https://github.com/mattgalbraith/eautils-docker-singularity/actions/workflows/docker-image.yml/badge.svg)](https://github.com/mattgalbraith/eautils-singularity/actions/workflows/docker-image.yml)

# eautils-docker-singularity

## Build Docker container for ea-utils and (optionally) convert to Apptainer/Singularity.  

TOOL DESRCIPTION  
  
#### Requirements:
See Dockerfile for build requirements.  
For adapter/primer removal with fastq-mcf - fasta format file with adapter sequences.  
  
## Build docker container:  

### 1. For ea-utils installation instructions:  
https://github.com/ExpressionAnalysis/ea-utils/blob/master/clipper/README  


### 2. Build the Docker Image

#### To build image from the command line:  
``` bash
# Assumes current working directory is the top-level <tool>-docker-singularity directory
docker build -t eautils:1.04.807 . # tag should match software version
```
* Can do this on [Google shell](https://shell.cloud.google.com)

#### To test this tool from the command line:
``` bash
docker run --rm -it eautils:1.04.807 fastq-mcf -h
docker run --rm -it eautils:1.04.807 fastq-mcf -h | grep "Version"

# Optional: Run with test data from PICARD Test Data GCS bucket
# mkdir fastq_test && gsutil cp gs://gatk-test-data/wgs_fastq/NA12878_20k/H06HDADXX130110.1.ATCACGAT.20k_reads_1.fastq ./fastq_test/ && gzip fastq_test/*.fastq
docker run -it --rm -v "$PWD":/data -w /data eautils:1.04.807 fastq-mcf -S -q 30 -o /dev/null  n/a ./fastq_test/H06HDADXX130110.1.ATCACGAT.20k_reads_1.fastq.gz
# -v mounts current working dir as /data in container
# -w sets working dir in conatiner
# -o /dev/null sends outpout to nowhere
# n/a sets empty adatpers.fa file
# SUCCESSFUL TEST RESULT: filtering stats to standard out
```

## Optional: Conversion of Docker image to Singularity  

### 3. Build a Docker image to run Singularity  
(skip if this image is already on your system)  
https://github.com/mattgalbraith/singularity-docker

### 4. Save Docker image as tar and convert to sif (using singularity run from Docker container)  
``` bash
docker images
docker save <Image_ID> -o eautils1.04.807-docker.tar && gzip eautils1.04.807-docker.tar # = IMAGE_ID of <tool> image
docker run -v "$PWD":/data --rm -it singularity:1.1.5 bash -c "singularity build /data/eautils1.04.807.sif docker-archive:///data/eautils1.04.807-docker.tar.gz"
```
NB: On Apple M1/M2 machines ensure Singularity image is built with x86_64 architecture or sif may get built with arm64  

Next, transfer the eautils1.04.807.sif file to the system on which you want to run ea-utils from the Singularity container  

### 5. Test singularity container on (HPC) system with Singularity/Apptainer available  
``` bash
# set up path to the Singularity container
EAUTILS_SIF=path/to/eautils1.04.807.sif

# Test that <tool> can run from Singularity container
singularity run $EAUTILS_SIF fastq-mcf -h # depending on system/version, singularity may be called apptainer
```