/*
Author: Pietro Biroli (biroli@uchicago.edu)

Purpose:
-- Create some summary tables for the Reggio Project
-- Edit of old file to create tables in latex

Initial draft: descrittivePietro/sumStat.do
This Draft: 8 April 2016, 

*/

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

cd 		$git_reggio
include ${git_reggio}/prepare-data.do

cd 		${klmReggio}/Analysis/Output/

replace momBornProvince=0 if Cohort==2 //not relevant for immigrants, otherwise it won't run
replace dadBornProvince=0 if Cohort==2 //not relevant for immigrants, otherwise it won't run

local options se sdbracket vert nototal nptest //sd mtprob mtest bdec(3) ci cibrace nptest 
local childPRE `Xcontrol' cgReddito_1 
local adolePRE `Xcontrol' cgReddito_1 
local adultPRE `Xcontrol'

*-* Predetermined Characteristics: by infant-toddler center type and city
local group cityXasilo
tabformprova `childPRE' using children_PREasilo if Cohort==1, by(`group') `options'
tabformprova `childPRE' using immigrant_PREasilo if Cohort==2, by(`group') `options'
tabformprova `childPRE' using adolescent_PREasilo if Cohort==3, by(`group') `options'

tabformprova `adultPRE' using adults_PREasilo if Cohort>3, by(`group') `options'
tabformprova `adultPRE' using adult30_PREasilo if Cohort==4, by(`group') `options'
tabformprova `adultPRE' using adult40_PREasilo if Cohort==5, by(`group') `options'
tabformprova `adultPRE' using adult50_PREasilo if Cohort==6, by(`group') `options'

*-* Predetermined Characteristics: by preschool type and city
local group cityXmaterna
tabformprova `childPRE' using children_PREmaterna if Cohort==1, by(`group') `options'
tabformprova `childPRE' using immigrant_PREmaterna if Cohort==2, by(`group') `options'
tabformprova `adolePRE' using adolescent_PREmaterna if Cohort==3, by(`group') `options'

tabformprova `adultPRE' using adults_PREmaterna if Cohort>3, by(`group') `options'
tabformprova `adultPRE' using adult30_PREmaterna if Cohort==4, by(`group') `options'
tabformprova `adultPRE' using adult40_PREmaterna if Cohort==5, by(`group') `options'
tabformprova `adultPRE' using adult50_PREmaterna if Cohort==6, by(`group') `options'

*-* Predetermined Characteristics in the other cities (Parma and Padova)
foreach city in Parma Padova{
foreach scuola in asilo materna{
local options se sdbracket vert nototal nptest //sd mtprob mtest bdec(3) ci cibrace nptest 
local group cityX`scuola'
tabformprova `childPRE' using children_PRE`scuola'`city' if Cohort==1 & `city'==1, by(`group') `options'
tabformprova `childPRE' using immigrant_PRE`scuola'`city' if Cohort==2 & `city'==1, by(`group') `options'
tabformprova `childPRE' using adolescent_PRE`scuola'`city' if Cohort==3 & `city'==1, by(`group') `options'

tabformprova `adultPRE' using adults_PRE`scuola'`city' if Cohort>3 & `city'==1, by(`group') `options'
tabformprova `adultPRE' using adult30_PRE`scuola'`city' if Cohort==4 & `city'==1, by(`group') `options'
tabformprova `adultPRE' using adult40_PRE`scuola'`city' if Cohort==5 & `city'==1, by(`group') `options'
tabformprova `adultPRE' using adult50_PRE`scuola'`city' if Cohort==6 & `city'==1, by(`group') `options'
}
}

*-* Outcomes considered
* By asilo type and city
local group cityXasilo
tabformprova `outChild' using children_OUTCOMEasilo if Cohort==1, by(`group') `options'
tabformprova `outChild' using immigrant_OUTCOMEasilo if Cohort==2, by(`group') `options'
tabformprova `outAdol'  using adolescent_OUTCOMEasilo if Cohort==3, by(`group') `options'

tabformprova `outAdult' using adults_OUTCOMEasilo if Cohort>3, by(`group') `options'
tabformprova `outAdult' using adult30_OUTCOMEasilo if Cohort==4, by(`group') `options'
tabformprova `outAdult' using adult40_OUTCOMEasilo if Cohort==5, by(`group') `options'
tabformprova `outAdult' using adult50_OUTCOMEasilo if Cohort==6, by(`group') `options'

* by preschool type and city
local group cityXmaterna
tabformprova `outChild' using children_OUTCOMEmaterna if Cohort==1, by(`group') `options'
tabformprova `outChild' using immigrant_OUTCOMEmaterna if Cohort==2, by(`group') `options'
tabformprova `outAdol'  using adolescent_OUTCOMEmaterna if Cohort==3, by(`group') `options'

tabformprova `outAdult' using adults_OUTCOMEmaterna if Cohort>3, by(`group') `options'
tabformprova `outAdult' using adult30_OUTCOMEmaterna if Cohort==4, by(`group') `options'
tabformprova `outAdult' using adult40_OUTCOMEmaterna if Cohort==5, by(`group') `options'
tabformprova `outAdult' using adult50_OUTCOMEmaterna if Cohort==6, by(`group') `options'
