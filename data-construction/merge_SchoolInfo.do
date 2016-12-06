* ---------------------------------------------------------------------------- *
* Prepare Data for Analysis
* Contributors:  Jessica Yu Kyung Koh
* Original version: Modified from 12/06/2016
* Current version:  12/06/16
* ---------------------------------------------------------------------------- *

clear all
set more off
set maxvar 32000

* ---------------------------------------------------------------------------- *
* Install command and set directory
* ---------------------------------------------------------------------------- *
/* Note: In order to make this do file runable on other computers, 
                  create an environment variable that points to the directory for Reggio.dta.
                  Those who want to use this code on their computers should set up 
                  environment variables named "klmReggio" for klmReggio 
                  and "data_reggio" for klmReggio/SURVEY_DATA_COLLECTION/data
                  on their computers. */

* Install the following commands: dummieslab, outreg2
capture which dummieslab     			// Checks system for estout
if _rc ssc install dummieslab  			// If not found, installs estout
capture which outreg2					// Checks system for diff
if _rc ssc install outreg2 				// CIf not found, installs diff


* Set globals for directories
global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

cd "$data_reggio"

use Reggio_prepared, clear

* Keep only the necessary variables from Reggio_prepared
keep intnr Birthday Address
rename Address Address_current

tempfile temp_reggio
save "`temp_reggio'"


* Import school name data
import excel using "ReggioAll_SchoolNames_manual.xlsx", clear firstrow


* Merge with the tempfile
merge m:1 intnr using `temp_reggio'

drop if _merge == 2 // using only

order internr intnr Cohort Birthday City school Stat Comu Pubb Reli Priv DK Type Location name address Address_current
sort City Cohort

export excel using "${data_reggio}/merged_ReggioAll_SchoolNames_manual.xlsx", replace firstrow(variables)

