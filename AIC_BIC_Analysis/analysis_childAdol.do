* ---------------------------------------------------------------------------- *
* Identifying combinations of baseline characteristics that yield best fit for LPM
* Authors: Sidharth Moktan
* Created: 23 June 2016

* Sources of data:
* 	1.	"tuples.csv": The file contains 98280 combinations of baseline 
* 		characteristics generated using the file "tuples.py". 
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

cd ${klmReggio}/Analysis/AIC_BIC_Analysis/

/*Tuples contain all combinations of 5 of the following variables:
----------------------------------------------------------------
"Male", "CAPI", "lowbirthweight", "birthpremature", "momMaxEdu_low", "momMaxEdu_middle",
"momMaxEdu_HS", "momMaxEdu_Uni", "momBornProvince", "teenMomBirth", "dadMaxEdu_low", "dadMaxEdu_middle",
"dadMaxEdu_HS", "dadMaxEdu_Uni", "dadBornProvince", "teenDadBirth", "cgRelig", "cgCatholic", "cgFaith_dummy"
"int_cgCatFaith", "houseOwn", "cgMigrant", "cgReddito_1", "cgReddito_2", "numSibling_0", "numSibling_1"
"numSibling_2", "numSibling_more"
*/

* Importing list of tuples
import delimited using "./Tuples/Output/tuples_ChildAdo.csv", varnames(1)

local max_tuple = 98280

* Saving list of all tuples to local macros for later use
forvalues i=1/`max_tuple'{
	local tuple_`i'=tuples[`i']
}

* Prepare the data for the analysis, creating variables and locals
include prepare-data2.do

cd ${klmReggio}/Analysis/AIC_BIC_Analysis/


* Opening .csv file to store AIC/BIC results
file open file1 using "./Output/AIC_BIC_childAdo.csv", write replace
file write file1 "Tuple,Controls,Dependent Variable,AIC,BIC,N" _n // 1st row = variable names

local city_val = 1
foreach city in Reggio Parma Padova{ 
	//Reggio=1,Parma=2,Padova=3
	
	local cohort_val = 1
	foreach cohort in Child Migr Adol{ 
		//Child=1,Migr=2 and Adol=3
	
		foreach type in Muni None Reli Stat{
			//excluding Priv as discussed
		
			forvalues i = 1/`max_tuple'{
				quietly reg	xm`city'`type'`cohort' `tuple_`i'' if (Cohort == `cohort_val')&(City==`city_val')
				quietly estat ic //command creates matrix r(S) where 1st, 5th and 6th elements are N, AIC and BIC respectively 
				matrix aa =  r(S)
				local num =  aa[1,1]
				local aic =  aa[1,5]
				local bic =  aa[1,6]
				file write file1 "tuple_`i',`tuple_`i'',xm`city'`type'`cohort',`aic',`bic',`num'" _n
			}
		}
		local cohort_val = `cohort_val'+1
	}
	local city_val = `city_val'+1
}
	
file close file1

*-------------------------------------------------------------------------------*
* Creating a new .csv file containing the mean AIC/BIC for each tuple
*-------------------------------------------------------------------------------*
cd ${klmReggio}/Analysis/AIC_BIC_Analysis/

* Importing file with AIC_BIC scores that was created above
import delimited "./Output/AIC_BIC_childAdo.csv", varnames(1) delimiters(",") clear

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
file open file2 using "./Output/Average_AIC_BIC_childAdo.csv", write replace
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

*------------------------------------------------------------------------------- *

