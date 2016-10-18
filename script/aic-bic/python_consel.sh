#!/bin/bash
#PBS -N PythonTest
#PBS -j oe
#PBS -V
#PBS -l nodes=1:ppn=20

#-------------------------------------------------
cd "/home/yukyungkoh/reggio/script/aic-bic"
python2.7 controls_selection.py



