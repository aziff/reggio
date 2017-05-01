# ============================================================== #
# Description of Folder Structure of reggio/script
# Author: Jessica Yu Kyung Koh
# Updated: 2017/05/01
# ============================================================== #

# This txt file describes how folders are structure in this repository and 
  gives instructions on how to write/store a script in this directory.
  PLEASE read the below instructions closely before writing a script.

	  - Do files or scripts for a methodology should be stored in a corresponding subfolder 
	   (for example, IV scripts should be in "iv" subfolder).
	   
	  - prepare-data.do file creates Reggio_prepared.dta. After generating Reggio_prepared.dta,
	    driver.do in "reggio/data-construction/dataClean_namesManual_revised" should be run to 
	    generate Reggio_reassigned.dta. The purpose of this driver do file is to modify the wrong
	    school categorization, which is detected by CEHD researchers in the autumn of the year 2016.
	    Reggio_reassigned.dta should be used as a data file in scripts for all analysis. 
	    When changes are made to the prepare-data.do, prepare-data.do and driver.do should be ran again 
	    to create an updated Reggio_prepared.dta and Reggio_reassigned.dta.
		
	  - macro.do has all necessary local and global variables that will be used in the 
	    analysis do files. For example, locals for baseline variables and outcome variables 
	    are stored in this do file. Hence, this file MUST be included in the beginning of all scripts.
		
	  - All scripts MUST use global or local variables as defined in the "macro.do"	
	  
	  - Outputs for each script should be stored in the corresponding subfolder in "reggio/output"
	    For example, outputs for IV analysis should be stored in "reggio/output/iv" folder. 

	  - "function" folder in each subfolder for methodology stores functions programmed to do 
	    corresponding analysis. For example, "diffindiff.do" inside "reggio/scripts/did/function" is
	    the function for the diff-in-diff-in-diff for Reggio analysis. This function will be brought 
	    in do files that execute the diff-in-diff analysis.
	
	
* The results presented in the "Results" section of the final paper are derived from "step-down" subfolder. 
	- The do files that start with "stepdown_csvver_*" carry out the regressions and store results into 
	  the csv files mentioned in each do file.
	- The do files that start with "combine_tex*" brings in the csv result files and make them into LaTeX
	  tables presented in the final paper and appendix. In order to see where the LaTeX tables are store, 
          see the directories in each do file. 

		