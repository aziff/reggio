* ---------------------------------------------------------------------------- *
* Identifying combinations of baseline characteristics that yield best fit for LPM
* Authors: Sidharth Moktan
* Created: 23 June 2016

* Sources of data:
* 	1.	"tuples_adult.csv": The file contains 4368 combinations of baseline 
* 		characteristics generated using the file "tuples_adult.py". 
*	2.	"prepare-data2.do": This file modifies the file "prepare-data.do" by
*		adding dummy variables for xm`city'`type'Migr
* ---------------------------------------------------------------------------- *

clear all
set more off
set maxvar 32000
set matsize 11000
* ---------------------------------------------------------------------------- *
* Set directory
global klmReggio	: 	env klmReggio		
global data_reggio	: 	env data_reggio

cd ${klmReggio}/Analysis/AIC_BIC_Analysis

* Importing list of tuples
import delimited using "./Tuples/Output/tuples_Adult.csv", varnames(1) clear

local max_tuple = 4368

* Saving list of all tuples to local macros for later use
forvalues i=1/`max_tuple'{
	local tuple_`i'=tuple[`i']
*	di "`tuple_`i''"
}


* Prepare the data for the analysis, creating variables and locals
include ${klmReggio}/Analysis/AIC_BIC_Analysis/prepare-data2.do

* Defining list of outcomes for analysis
# delimit ;
						
local outcomesAdult		all_houseOwn binSatisFamily binSatisHealth binSatisIncome binSatisWork
						BMI childrenResp Cig Depression_score Drink1Age Health HealthPerc 
						highschoolGrad HrsTot IncomeCat IQ_factor IQ_score p50IQ_score p75IQ_score 
						p50IQ_factor p75IQ_factor live_parent LocusControl Maria MaxEdu_Grad MaxEdu_Uni 
						MigrTaste_cat mStatus_married_cohab optimist PA_Empl Pension reciprocity1bin 
						reciprocity2bin	reciprocity3bin reciprocity4bin Reddito_1 Reddito_2 Reddito_3 
						Reddito_4 Reddito_5 Reddito_6 Reddito_7 SES_self SickDays Smoke sport votoMaturita 
						votoUni WageMonth;

# delimit cr

* Calculate dummies for median and 75th percentile
foreach iq_var in IQ_factor IQ_score {
       foreach perc in 50 75 {
              qui sum `iq_var', detail
              gen p`perc'`iq_var' = (`iq_var' >= r(p`perc'))
       }
}

/* The following vars are exluded from list of outcomes because they either had 0 obs for adult cohort,
   or there was no variance in the variable for adult cohort i.e., it was a dummy with all values = 0:
						
						i_RiskDUI i_RiskFight RiskSuspended SDQ_score */
	

/*Tuples contain all combinations of 5 of the following variables:
----------------------------------------------------------------
"Male", "CAPI", "numSiblings", "momMaxEdu_middle", "momMaxEdu_HS", "momMaxEdu_Uni","momMaxEdu_Grad","momBornProvince",
"dadMaxEdu_low", "dadMaxEdu_middle", "dadMaxEdu_HS", "dadMaxEdu_Uni", "dadMaxEdu_Grad","dadBornProvince"
"SES_worker", "SES_teacher","SES_professional" */

* Opening .csv file to store AIC/BIC results
file open file1 using "${klmReggio}/Analysis/AIC_BIC_Analysis/Output/AIC_BIC_AdultPooled.csv", write replace
file write file1 "Tuple,Controls,Dependent Variable,AIC,BIC,N" _n // 1st row = variable names

foreach outcome of local outcomesAdult{
	forvalues i = 1/`max_tuple'{
		quietly reg	`outcome' `tuple_`i'' if Cohort>3 //making sure we don't estimate over non-adults
		quietly estat ic //command creates matrix r(S) where 1st, 5th and 6th elements are N, AIC and BIC respectively 
		matrix aa =  r(S)
		local num =  aa[1,1]
		local aic =  aa[1,5]
		local bic =  aa[1,6]
		file write file1 "tuple_`i',`tuple_`i'',`outcome',`aic',`bic',`num'" _n
	}
}
file close file1
*-------------------------------------------------------------------------------*
* Creating a new .csv file containing the mean AIC/BIC for each tuple
*-------------------------------------------------------------------------------*
cd ${klmReggio}/Analysis/AIC_BIC_Analysis

* Importing file with AIC_BIC scores that was created above
import delimited "./Output/AIC_BIC_AdultPooled.csv", varnames(1) delimiters(",") clear

* creating variables that store mean of aic and bic
sort tuple
by tuple: egen mean_aic=mean(aic)
by tuple: egen mean_bic=mean(bic)

* Since the mean aic/bic by tuple is the same for all instances of a given tuple,
* we only keep one obs of each
gen indicator = (tuple[_n] != tuple[_n-1]) // variable equal to 1 if it is the first instance of tuple[i] and 0 otherwise
drop if indicator != 1 //deleting all but first occurences of each tuple[i]
summarize
local num_obs = r(N) //storing the total number of observations in local `num_obs'

* Opening .csv file to store AIC/BIC average results
file open file2 using "./Output/Average_AIC_BIC_AdultPooled.csv", write replace
file write file2 "tuple,controls, Mean AIC, Mean BIC" _n // 1st row = variable names

* Writing average AIC/BIC values by tuple in .csv file
forvalues i=1/`num_obs'{
	local tuple=tuple[`i']
	local control=control[`i']
	local meanAIC=mean_aic[`i']
	local meanBIC=mean_bic[`i']
	file write file2 "`tuple',`control',`meanAIC',`meanBIC'" _n
}
file close file2

* ---------------------------------------------------------------------------- *
