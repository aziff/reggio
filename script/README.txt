# ============================================================== #
# Description of Folder Structure of reggio/script
# Author: Jessica Yu Kyung Koh
# Date: 2016/08/29
# ============================================================== #

# This txt file describes how folders are structure in this repository and 
  gives instructions on how to write / store a script in this directory.
  PLEASE read the below instructions closely before writing a script.

  - Do files or scripts for a methodology should be stored in a corresponding subfolder 
   (for example, IV scripts should be in "iv" subfolder).
   
  - prepare-data.do file creates Reggio_prepared.dta, which should be used as a 
    data file in scripts for all analysis. When changes are made to the prepare-data.do,
	it should be ran again to create an updated Reggio_prepared.dta.
	
  - macro.do has all necessary local and global variables that will be used in the 
    analysis do files. For example, locals for baseline variables and outcome variables 
	are stored in this do file. Hence, this file MUST be included in the beginning of all scripts.
	
  - All scripts MUST use global or local variables as defined in the "macro.do"	
  
  - Outputs for each script should be stored in the corresponding subfolder in "reggio/output"
    For example, outputs for IV analysis should be stored in "reggio/output/iv" folder. 
