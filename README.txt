# ============================================================== #
# Description of Folder Structure of Reggio git repository
# Author: Jessica Yu Kyung Koh
# Edited: 2017/05/01
# ============================================================== #

# This txt file describes how folders are structure in this repository.

1. data
	- This folder contains final Reggio data
	- "school-info" subfolders contains XLSX files for school informaton for each subject.

2. data-construction
	- This folder contains do files used to clean the Reggio data.
	- (Added in the autumn of 2016) driver.do in "dataClean_namesManual_revised" subfolder
	  should be run in order to fix the mistakes on school categorization for each individual.
	  This error was detected in 2016 by CEHD researchers.
	  See README.txt inside reggio/script subfolder to see the instruction on when to run 
	  driver.do in "dataClean_namesManual_revised". 

2. old
	- This folder contains old do files + documentations + outputs created in the past.
	- "2016-summer-analysis" subfolder shows all the previous work done in the summer of 2016.

3. outcome	
	- This folder contains the list of outcomes analyzed for each cohort in the format of csv.
	- These csv files are necessary for conducting BIC-AIC in "script" folder.

4. output
	- This folder stores outputs from the analysis do files. 
	- The subfolders are structured in a way that shows which analysis the outputs are for. 
	  For example, "did" subfolder shows the outputs from the did codes.

5. script
	- This folder stores the scripts used to perform various analysis. 
	- Each subfolder shows the scripts used for a particular method / purporse.
	- "macros.do" should be included in the beginning of all analysis do files. 
	  They are the prepatory materials. 

6. writeup
	- This folder shows all the documentation / writeups for the Reggio project. 
	- "auxiliary" subfolder stores auxiliary files, such as "preamble.tex"
	- "docs" contains the actual documents written by the Reggio team. This folder is again
	  divided into different subfolders depending on the purpose of the document. 
	
	