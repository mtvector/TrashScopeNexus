#!/bin/bash
#$ -o ~/log
#$ -e ~/log
#$ -cwd
#$ -j y
#$ -pe smp 1
#$ -l mem_free=96G
#$ -l h_rt=72:00:00

source ~/.bashrc
source activate imaging
python ~/code/macaque-dev-brain/imaging/Runallstitching.py /wynton/group/ye/mtschmitz/images/MacaqueMotorCortex2/
source activate imagej
#python ~/code/macaque-dev-brain/imaging/TestStitching.py /wynton/group/ye/mtschmitz/images/MacaqueMotorCortex2/


