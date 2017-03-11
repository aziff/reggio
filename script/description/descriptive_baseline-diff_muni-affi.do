/* ---------------------------------------------------------------------------- *
* Testing differences between Municipal and Muni-affiliated
* Author: Jessica Yu Kyung Koh
* Date: 03/09/2017
* Note: I need to check baseline characteristics of Reggio Muni, Reggio Municipal-affiliated, 
		Parma Municipal-affiliated, Padova Municipal affiliated, for Child and Adolescent Cohort
* ---------------------------------------------------------------------------- */

clear all
* ----------- *
* Preparation *
* ----------- *
cap file 	close outcomes
cap log 	close

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio


global here : pwd

use "${data_reggio}/Reggio_reassigned"


* define baseline variables			
global child_baseline_vars		Male lowbirthweight birthpremature 	///
								momMaxEdu_UniorGrad			///
								cgReddito_above50k 			///
								cgCatholic int_cgCatFaith		///
								momBornProvince 		///
								numSibling_2 numSibling_more	
								
								
global adol_baseline_vars		Male lowbirthweight birthpremature 	///
								momMaxEdu_UniorGrad 			///
								cgReddito_above50k 			///
								cgCatholic int_cgCatFaith		///
								momBornProvince cgMigrant		///
								numSibling_2 numSibling_more 
					 
global adult_baseline_vars		Male  					///
								momMaxEdu_HS momMaxEdu_UniorGrad	///
								cgRelig					///
								momBornProvince dadBornProvince		///
								numSibling_2 numSibling_more


local Male_n					"Male"					
local lowbirthweight_n 			"Low birthweight"
local birthpremature_n			"Premature birth"
local momMaxEdu_UniorGrad_n 	"Mom at least uni."
local cgReddito_above50k_n 		"Income more than 50,000"
local cgCatholic_n				"Caregiver is Catholic"
local int_cgCatFaith_n			"Caregiver is Catholic and very faithful"
local cgIslam_n					"Caregiver is Islam"
local momBornProvince_n			"Mom born in province"
local migrant_n					"Migrant"
local numSibling_2_n			"Has 2 siblings"
local numSibling_more_n			"Has more than 2 siblings"
local cgMigrant_n				"Caregiver is migrant"
local momMaxEdu_HS_n			"Mom high school grad"
local cgRelig_n					"Caregiver is religious"
local dadBornProvince_n			"Father born in province"


gen momMaxEdu_UniorGrad = (momMaxEdu_Uni == 1 | momMaxEdu_Grad == 1)
gen cgReddito_above50k	= (cgReddito_5 == 1 | cgReddito_6 == 1 | cgReddito_7 == 1)

* ---------------------- *
* Estimate: Child Cohort *
* ---------------------- *

preserve

keep if (Cohort == 1) & ((maternaMuni == 1) | (maternaAffi == 1)) // Keeping only child cohort

* Store mean and standard deviation
foreach city in Reggio Parma Padova {
	foreach type in Muni Affi {
		foreach var in $child_baseline_vars {
			* Summarize
			summ `var' if (`city' == 1) & (materna`type' == 1)
			
			* Store mean
			local m`city'`type'`var' = r(mean)
			local m`city'`type'`var' = string(`m`city'`type'`var'', "%9.2f")
			
			* Store standard deviation
			local sd`city'`type'`var' = r(sd)
			local sd`city'`type'`var' = string(`sd`city'`type'`var'', "%9.2f")
			local sd`city'`type'`var'  (`sd`city'`type'`var'')
			
			* Store observation
			local n`city'`type'`var' = r(N)
			local n`city'`type'`var'  "\textit{`n`city'`type'`var''}"
			
		}
	}
}


* T-test difference between Reggio Muni and comparison groups
foreach var in $child_baseline_vars {
	* Within Reggio
	ttest `var' if Reggio ==  1, by(maternaMuni)
	local pReggio`var' = r(p)
	
	* With Parma
	ttest `var' if (Reggio ==  1 & maternaMuni == 1) | (Parma == 1 & maternaAffi == 1), by(maternaMuni)
	local pParma`var' = r(p)
	
	* With Padova
	ttest `var' if (Reggio ==  1 & maternaMuni == 1) | (Padova == 1 & maternaAffi == 1), by(maternaMuni)
	local pPadova`var' = r(p)
	
}


* Final formatting of numbers
foreach city in Reggio Parma Padova {
	foreach var in $child_baseline_vars {
		if `p`city'`var'' <= 0.10 {
			local m`city'Affi`var' "\textbf{`m`city'Affi`var''}"
		}
	}
}


file open tabfilechild using "${git_reggio}/output/munivsaffi_child.tex", write replace
file write tabfilechild "\begin{tabular}{lcccc}" _n
file write tabfilechild "\toprule" _n
file write tabfilechild " Variable & Reggio Approach & Reggio Muni-Affi & Parma Muni-Affi & Padova Muni-Affi \\" _n
file write tabfilechild "\midrule" _n

foreach var in $child_baseline_vars {
	* Point Estimate
	file write tabfilechild "``var'_n' & `mReggioMuni`var'' & `mReggioAffi`var'' & `mParmaAffi`var'' & `mPadovaAffi`var'' \\" _n
	
	* Standard Error
	file write tabfilechild " & `sdReggioMuni`var'' & `sdReggioAffi`var'' & `sdParmaAffi`var'' & `sdPadovaAffi`var'' \\" _n
	
	* Number of obs
	file write tabfilechild " & `nReggioMuni`var'' & `nReggioAffi`var'' & `nParmaAffi`var'' & `nPadovaAffi`var'' \\" _n
}

file write tabfilechild "\bottomrule" _n
file write tabfilechild "\end{tabular}" _n
file close tabfilechild

restore









* --------------------------- *
* Estimate: Adolescent Cohort *
* --------------------------- *

preserve

keep if (Cohort == 3) & ((maternaMuni == 1) | (maternaAffi == 1)) // Keeping only adolescent cohort

* Store mean and standard deviation
foreach city in Reggio Parma Padova {
	foreach type in Muni Affi {
		foreach var in $adol_baseline_vars {
			* Summarize
			summ `var' if (`city' == 1) & (materna`type' == 1)
			
			* Store mean
			local m`city'`type'`var' = r(mean)
			local m`city'`type'`var' = string(`m`city'`type'`var'', "%9.2f")
			
			* Store standard deviation
			local sd`city'`type'`var' = r(sd)
			local sd`city'`type'`var' = string(`sd`city'`type'`var'', "%9.2f")
			local sd`city'`type'`var'  (`sd`city'`type'`var'')
			
			* Store observation
			local n`city'`type'`var' = r(N)
			local n`city'`type'`var'  "\textit{`n`city'`type'`var''}"
			
		}
	}
}


* T-test difference between Reggio Muni and comparison groups
foreach var in $adol_baseline_vars {
	* Within Reggio
	ttest `var' if Reggio ==  1, by(maternaMuni)
	local pReggio`var' = r(p)
	
	* With Parma
	ttest `var' if (Reggio ==  1 & maternaMuni == 1) | (Parma == 1 & maternaAffi == 1), by(maternaMuni)
	local pParma`var' = r(p)
	
	* With Padova
	ttest `var' if (Reggio ==  1 & maternaMuni == 1) | (Padova == 1 & maternaAffi == 1), by(maternaMuni)
	local pPadova`var' = r(p)
	
}


* Final formatting of numbers
foreach city in Reggio Parma Padova {
	foreach var in $adol_baseline_vars {
		if `p`city'`var'' <= 0.10 {
			local m`city'Affi`var' "\textbf{`m`city'Affi`var''}"
		}
	}
}


file open tabfileadol using "${git_reggio}/output/munivsaffi_adol.tex", write replace
file write tabfileadol "\begin{tabular}{lcccc}" _n
file write tabfileadol  "\toprule" _n
file write tabfileadol  " Variable & Reggio Approach & Reggio Muni-Affi & Parma Muni-Affi & Padova Muni-Affi \\" _n
file write tabfileadol "\midrule" _n

foreach var in $adol_baseline_vars {
	* Point Estimate
	file write tabfileadol "``var'_n' & `mReggioMuni`var'' & `mReggioAffi`var'' & `mParmaAffi`var'' & `mPadovaAffi`var'' \\" _n
	
	* Standard Error
	file write tabfileadol " & `sdReggioMuni`var'' & `sdReggioAffi`var'' & `sdParmaAffi`var'' & `sdPadovaAffi`var'' \\" _n
	
	* Number of obs
	file write tabfileadol " & `nReggioMuni`var'' & `nReggioAffi`var'' & `nParmaAffi`var'' & `nPadovaAffi`var'' \\" _n
}

file write tabfileadol "\bottomrule" _n
file write tabfileadol "\end{tabular}" _n
file close tabfileadol

restore
