* ---------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - Selection into Different School Types
* Authors: Pietro Biroli, Chiara Pronzato
* Editors: Jessica Yu Kyung Koh, Anna Ziff
* Created: 12/11/2015
* Edited: 01/14/2016
* ---------------------------------------------------------------------------- *

clear all
set more off
set maxvar 32000
* ---------------------------------------------------------------------------- *
* Set directory

/* 
Note: In order to make this do file runable on other computers, 
		create an environment variable that points to the directory for Reggio.dta.
		Those who want to use this code on their computers should set up 
		environment variables named "klmReggio" for klmReggio 
		and "data_reggio" for klmReggio/SURVEY_DATA_COLLECTION/data
		on their computers. 
Note: Install the following commands: dummieslab, outreg2
*/

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

cd $git_reggio

//include prepare-data.do

* ---------------------------------------------------------------------------- *
* Summary statistics of the baseline characteristics
include ${git_reggio}/baseline-summary.do 

* ---------------------------------------------------------------------------- *
* Contolling for balance in the baseline characteristics
include ${git_reggio}/analysis-Xleft.do 

* ---------------------------------------------------------------------------- *
* Summary and tables of comparisons of the potential outcomes 
include ${git_reggio}/outcomes.do 

* ---------------------------------------------------------------------------- *
* Summary graphs of the outcomes
//include ${git_reggio}/graph-summary.do 

* ---------------------------------------------------------------------------- *
* Regression Analyses separated by city and age
//include ${git_reggio}/analysis_cityreg.do


* ---------------------------------------------------------------------------- *
* Regression Analyses pooled across city, but separated by asilo vs materna
include ${git_reggio}/analysis_pooled.do

