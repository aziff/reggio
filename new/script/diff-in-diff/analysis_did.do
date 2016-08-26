* ---------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - Diff-in-Diff for Adult Cohorts
* Authors: Jessica Yu Kyung Koh
* Created: 06/16/2016
* Edited:  08/24/2016
* ---------------------------------------------------------------------------- *


clear all

cap file 	close outcomes
cap log 	close

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

global current : pwd

include "${current}/../prepare-data"
include "${current}/../macros" 

* ---------------------------------------------------------------------------- *
* 								Preparation 								   *
* ---------------------------------------------------------------------------- *
** Keep only the adult cohorts
keep if (Cohort == 4) | (Cohort == 5)

** Gender condition
local p_con	
local m_con		& Male == 1
local f_con		& Male == 0

* ---------------------------------------------------------------------------- *
* Regression: Padova Muni and Reli
* ---------------------------------------------------------------------------- *
local X					Cohort_Adult30 maternaReli xmReliAdult30	
local ifcondition 		Padova == 1 & (maternaMuni == 1 | maternaReli ==1)	
local controls			`adult_baseline_vars'

local coeflabel

foreach type in E W L H N S R {
	foreach var in `adult_outcome_`type'' {		
		di "adult outcomes: `adult_outcome_`type''"
		sum `var' if `ifcondition'
		if r(N) > 0 {
			eststo `var' : quietly reg `var' `X' `controls' if `ifcondition'
			local coeflabel `coeflabel' `var' "${`var'_lab}"
		}
	}	


	esttab, se nostar keep(_cons Cohort_Adult30 maternaReli xmReliAdult30)

	matrix C = r(coefs)

	eststo clear
	local rnames : rownames C
	local models : coleq C
	local models : list uniq models
	local i 0

	foreach name of local rnames {
	   local ++i
	   local j 0
	   capture matrix drop b
	   capture matrix drop se
	   foreach model of local models {
		   local ++j
		   matrix tmp = C[`i', 2*`j'-1]
		   if tmp[1,1] < . {
			  matrix colnames tmp = `model'
			  matrix b = nullmat(b), tmp
			  matrix tmp[1,1] = C[`i', 2*`j']
			  matrix se = nullmat(se), tmp
		  }
	  }
	  ereturn post b
	  quietly estadd matrix se
	  eststo `name'
	}

	esttab using "${current}/../../output/did/did-padova-relimuni-`type'.tex", replace se mtitle ///
				coeflabels(`coeflabel') noobs nonotes addnotes("Note: This table shows")

}
	


* ---------------------------------------------------------------------------- *
* Regression: Padova Reli and None
* ---------------------------------------------------------------------------- *
local X					Cohort_Adult30 maternaReli xmReliAdult30
local ifcondition 		Padova == 1 & (maternaNone == 1 | maternaReli ==1)	
local controls			`adult_baseline_vars'

local coeflabel

foreach type in E W L H N S R {
	foreach var in `adult_outcome_`type'' {		
		sum `var' if `ifcondition'
		if r(N) > 0 {
			eststo `var' : quietly reg `var' `X' `controls' if `ifcondition'
			local coeflabel `coeflabel' `var' "${`var'_lab}"
		}
	}	


	esttab, se nostar keep(_cons Cohort_Adult30 maternaReli xmReliAdult30)

	matrix C = r(coefs)

	eststo clear
	local rnames : rownames C
	local models : coleq C
	local models : list uniq models
	local i 0

	foreach name of local rnames {
	   local ++i
	   local j 0
	   capture matrix drop b
	   capture matrix drop se
	   foreach model of local models {
		   local ++j
		   matrix tmp = C[`i', 2*`j'-1]
		   if tmp[1,1] < . {
			  matrix colnames tmp = `model'
			  matrix b = nullmat(b), tmp
			  matrix tmp[1,1] = C[`i', 2*`j']
			  matrix se = nullmat(se), tmp
		  }
	  }
	  ereturn post b
	  quietly estadd matrix se
	  eststo `name'
	}

	esttab using "${current}/../../output/did/did-padova-relinone-`type'.tex", replace se mtitle ///
				coeflabels(`coeflabel') noobs nonotes addnotes("Note: This table shows")

}	
