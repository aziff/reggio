/*
Author:      Anna Ziff (aziff@uchicago.edu)
Purpose:     Make tables for many outcomes comapring cities and school types

     [=] Signal questions to be addressed
*/

// define macros and necessary variables
global klmreggio      :          env klmreggio
global data_reggio    :          env data_reggio
global git_reggio     :          env git_reggio

* Prepare the data for the analysis, creating variables and locals
include ${klmReggio}/Analysis/prepare-data_new.do

cd ${klmReggio}/Analysis/Output/
* ---------------------------------------------------------------------------- *
* Create locals and label variables
** Categories
local Child_name               Children
local Adol_name                Adolescents
local Adult_name               Adults
local asilo_name               Infant-Toddler Care
local materna_name             Preschool
local None_name                No
local Muni_name                Municipal
local Stat_name                State
local Reli_name                Religious
local Priv_name                Private

# delimit ;

local outcomesChild              IQ_factor IQ_score p50IQ_score p75IQ_score
                                 likeSchool_child   
                                 childBMI childHealthPerc
                                 childSDQ_score;
                                   
local outcomesAdol               IQ_factor IQ_score p50IQ_score p75IQ_score
                                 RiskSuspended
                                 Smoke Cig sport 
                                 BMI HealthPerc childHealthPerc 
                                 LocusControl SDQ_score childSDQ_score Depression_score 
                                 MigrTaste_cat;
                                                 
local outcomesAdult              IQ_factor IQ_score p50IQ_score p75IQ_score
                                 votoMaturita votoUni highschoolGrad 
                                 PA_Empl IncomeCat Pension        
                                 Maria Smoke Cig sport 
                                 BMI Health SickDays HealthPerc  
                                 LocusControl SDQ_score Depression_score 
                                 MigrTaste_cat;
                                                 
local outcomesAll                     `outcomesChild' `outcomesAdol' `outcomesAdult';

local options                             se sdbracket vert nototal;
                                                 
# delimit cr              

gen Cohort_new = Cohort
recode Cohort_new (1 = 1) (2 = 0) (3 = 2) (4 = 3) (5 = 3) (6 = 3)

// calculate dummies for median and 75th percentile
foreach iq_var in IQ_factor IQ_score {
       foreach perc in 50 75 {
              qui sum `iq_var', detail
              gen p`perc'`iq_var' = (`iq_var' >= r(p`perc'))
       }
}

cd ${git_reggio}/writeup/tables

// construct tables
// for each cohort and asilo/materna type, row outcomes
local cohort_val = 1
foreach cohort in Child Adol Adult {
       foreach age in asilo materna {
	   
			local city_val= 1
			
			foreach city in `cities' {
				local options se sdbracket vert nototal nptest //sd mtprob mtest bdec(3) ci cibrace nptest 
				tabformprova `outcomes`cohort'' using tab`cohort'`age'`city' if Cohort_new==`cohort_val' & City == `city_val', by(`age'Type)
				
				local city_val = `city_val' + 1
			}                     
       }
       local cohort_val = `cohort_val' + 1
}



