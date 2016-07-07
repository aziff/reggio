* ---------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - Selection into Different School Types
* Authors: Jessica Yu Kyung Koh
* Created: 07/05/2016
* Edited: 07/05/2016
* ---------------------------------------------------------------------------- *

clear all
set more off

* ---------------------------------------------------------------------------- *
* Set directory
global klmReggio	: 	env klmReggio		
global data_reggio	: 	env data_reggio

include "${klmReggio}/Analysis/prepare-data"
include "${klmReggio}/Analysis/baseline-rename"

* ---------------------------------------------------------------------------- *
* Create locals and label variables

** Categories
local cities				Reggio Parma Padova
local school_types 			None Muni Stat Reli Priv
local school_age_types		Asilo Materna
local cohorts			 	Child Migrants Adol Adult30 Adult40 Adult50

* Baseline variables
local baseline		    /*lowbirthweight birthpremature*/ momMaxEdu dadMaxEdu cgIncomeCat /*momAgeBirth numSiblings cgCatholic */ 
local lowbirthweight_lab	Mean Low Birthweight
local birthpremature_lab	Mean Birth Premature
local momMaxEdu_lab			Mean Mother's Max Edu Category
local dadMaxEdu_lab			Mean Father's Max Edu Category
local cgIncomeCat_lab		Mean Income Category
local teenMomBirth_lab		Mean Mother's Age Giving Birth
local numSiblings_lab		Mean Number of Siblings
local cgCatholic_lab   		Mean Probability of Being Catholic

** Cohort lab
local Child_lab				Children
local Migrants_lab			Migrants
local Adol_lab				Adolescents
local Adult30_lab			Age-30 Adults
local Adult40_lab			Age-40 Adults
local Adult50_lab			Age-50 Adults

* Scale
local scale_momMaxEdu_Child		range(-10 20)
local scale_momMaxEdu_Migrants	range(-3 15)
local scale_momMaxEdu_Adol		range(0 8)
local scale_momMaxEdu_Adult30	range(0 8)
local scale_momMaxEdu_Adult40	range(0 8)
local scale_momMaxEdu_Adult50	range(0 5)

local scale_momMaxEdu_Child		range(-7 17)
local scale_momMaxEdu_Migrants	range(-3 10)
local scale_momMaxEdu_Adol		range(-5 17)
local scale_dadMaxEdu_Adult30	range(0 8)
local scale_dadMaxEdu_Adult40	range(0 8)
local scale_dadMaxEdu_Adult50	range(0 5)


* ---------------------------------------------------------------------------- *
* Preparation (See http://www.ats.ucla.edu/stat/stata/faq/barcap.htm)
** Generate cityschool dummy
foreach cohort in `cohorts' {
	generate cityschool`cohort' = maternaType		if City == 1 & (Cohort_`cohort' == 1)
	replace  cityschool`cohort' = maternaType + 6	if City == 2 & (Cohort_`cohort' == 1)
	replace  cityschool`cohort' = maternaType + 12  if City == 3 & (Cohort_`cohort' == 1)
}

** Generate mean, high, and low for each baseline variable
foreach v in `baseline' {
	generate mean`v' = .
	generate hi`v' = .
	generate lo`v' = .
	
	foreach city in `cities' {
		foreach cohort in `cohorts' {
		
			local type_n = 0
			foreach type in `school_types' {

					summ `v' if (`city' == 1) & (Cohort_`cohort' == 1) & (maternaType == `type_n')
					local N = r(N)
					local mean = r(mean)
					local sd = r(sd)
					if `N' != 0 {
						replace mean`v' = `mean' if (`city' == 1) & (Cohort_`cohort' == 1) & (maternaType == `type_n')
						replace hi`v' = `mean' + invttail(`N',0.025)*(`sd'/sqrt(`N')) if (`city' == 1) & (Cohort_`cohort' == 1) & (maternaType == `type_n')
						replace lo`v' = `mean' - invttail(`N',0.025)*(`sd'/sqrt(`N')) if (`city' == 1) & (Cohort_`cohort' == 1) & (maternaType == `type_n')
					}
				
				local type_n = `type_n' + 1
			}
		}
	} 	
}	

** Drop duplicates

duplicates drop cityschoolChild if (cityschoolChild != .), force
duplicates drop cityschoolMigrants if (cityschoolMigrants != .), force
duplicates drop cityschoolAdol if (cityschoolAdol != .), force
duplicates drop cityschoolAdult30 if (cityschoolAdult30 != .), force
duplicates drop cityschoolAdult40 if (cityschoolAdult40 != .), force
duplicates drop cityschoolAdult50 if (cityschoolAdult50 != .), force


* ---------------------------------------------------------------------------- *

foreach v in `baseline' {
	foreach cohort in `cohorts' {
		twoway (bar mean`v' cityschool`cohort' if (maternaType == 0) & (Cohort_`cohort'== 1), color(gs1)) ///
			  (bar mean`v' cityschool`cohort' if (maternaType == 1) & (Cohort_`cohort'== 1), color(gs4)) ///
			   (bar mean`v' cityschool`cohort' if (maternaType == 2) & (Cohort_`cohort' == 1), color(gs7)) ///
			   (bar mean`v' cityschool`cohort' if (maternaType == 3) & (Cohort_`cohort' == 1), color(gs10)) ///
			   (bar mean`v' cityschool`cohort' if (maternaType == 4) & (Cohort_`cohort'== 1), color(gs13)) ///
			   (rcap hi`v' lo`v' cityschool`cohort'), ///
			   legend(row(1) order(1 "None" 2 "Muni" 3 "State" 4 "Religious" 5 "Private")) ///
			   graphregion(color(white)) ///
			   xlabel( 2 "Reggio" 8 "Parma" 14 "Padova", noticks) ///
			   xtitle("City") ytitle("") ///
			   title("``v'_lab': ``cohort'_lab'") ///
			   yscale(`scale_`v'_`cohort'')
		graph export "${klmReggio}/Analysis/Output/graphs/baseline/baseline_`v'_`cohort'.pdf", replace
	}
}

