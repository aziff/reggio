* ---------------------------------------------------------------------------- *
* Analyzing the Reggio Treatment Effects Using the Random Forest Approach
* Authors: Jessica Yu Kyung Koh
* Created: 07 August 2016
* Edited:  14 August 2016
* ---------------------------------------------------------------------------- *
clear all

cap file 	close outcomes
cap log 	close

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

include "${git_reggio}/prepare-data"


* ---------------------------------------------------------------------------- *
* 							 Create locals									   *
* ---------------------------------------------------------------------------- *							
** Random forest inputs
local outcomes_of_interest		BMIcat						// Outcomes of interest should be ordered categorical variables.
								
local unordered_preschool		City Cohort maternaType		// preschool-related unordered variables
local unordered_other			Male  CAPI cgMigrant ///	
								cgCatholic int_cgCatFaith 
local ordered_other				lowbirthweight birthpremature momBornProvince dadBornProvince cgIncomeCat ///
								momMaxEdu dadMaxEdu houseOwn numSiblings 
local tree_number				10 							// I get errors when I include more than 10 trees


* ---------------------------------------------------------------------------- *
*								Analysis									   *
* ---------------------------------------------------------------------------- *
* Check if chaidforest command is installed, and if not install it
capture which chaidforest    
if _rc ssc install chaidforest   


* Keep only the necessary variables
preserve
keep `outcomes_of_interest' `unordered_preschool' `unordered_other' `ordered_other'
keep if Cohort > 3 	// only keeping adults


* Perform random forest analysis
foreach var in `outcomes_of_interest' {
	
	* 1. Only including `unordered_preschool'
	** Run command
	di "Running chaidforest: only including unordered preschool variables"
	chaidforest `var', unordered(`unordered_preschool') ntree(`tree_number') nvuse(3) 
	
	** Graph each tree
	di "Graphing: only including unordered preschool variables"
	foreach num of numlist 1/`tree_number' {
		estat gettree, tree(`num') graph  // How can I include graph options?
		graph export "${git_reggio}/Output/Randomforest/`var'_onlypreschool_tree`num'.eps", replace
	}
	
	/*
	* 2. Including all baseline variables (2016/08/14 NOT WORKING, "invalid numlist has too few elements")
	** Run command
	di "Running chaidforest: including all variables"
	chaidforest `var', unordered(`unordered_preschool' `unordered_other') ordered(`ordered_other') ntree(`tree_number')
	
	** Graph each tree
	di "Graphing: including all variables"
	foreach num of numlist 1/`tree_number' {
		estat gettree, tree(`num') graph
		graph export "${git_reggio}/Output/Randomforest/`var'_all_tree`num'.eps", replace
	} */

}

restore
