* ---------------------------------------------------------------------------- *
* Testing differences between Municipal and Muni-affiliated
* Author: Jessica Yu Kyung Koh
* Date: 03/09/2017
* ---------------------------------------------------------------------------- *

clear all

cap file 	close outcomes
cap log 	close

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio


global here : pwd

use "${data_reggio}/Reggio_reassigned"


// define baseline variables			
global child_baseline_vars		Male lowbirthweight birthpremature 	///
					momMaxEdu_UniorGrad			///
					cgReddito_above50k 			///
					cgCatholic int_cgCatFaith		///
					momBornProvince migrant 		///
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

local lowbirthweight_n 			"Lowbirthweight"
local birthpremature_n			"Premature"
local momMaxEdu_UniorGrad_n 		"MomatleastUni"
local cgReddito_above50k_n 		"Incomeatleast50000"
local cgCatholic_n			"Catholiccaregiver"
local cgIslam_n				"Islamiccaregiver"
local momBornProvince_n			"Momborninprovince"
local migrant_n				"Migrant"
local numSibling_2_n			"Atleast2siblings"
local numSibling_more_n			"Morethan2siblings"
local Male_n				"Male"
local cgMigrant_n			"Migrantcaregiver"
local momMaxEdu_HS_n			"Momonlyhighschool"
local cgRelig_n				"Religiouscaregiver"
local dadBornProvince_n			"Dadborninprovince"
local int_cgCatFaith_n			"ReligCathcaregiver"
