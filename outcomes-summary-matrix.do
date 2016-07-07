/*
Author: Anna Ziff

Purpose:
-- Outcomes description

*/

cap file 	close outcomes
cap log 	close

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

cd 		$git_reggio
include prepare-data
include "${git_reggio}/outcomes-rename"

*-* Adjust variables and statistics of interest
#delimit ;

local Child_outcome_vars 		IQ_factor likeSchool_child childBMI childSDQ_score;

local Migrant_outcome_vars		IQ_factor likeSchool_child childBMI childSDQ_score;	
	
local Adolescent_outcome_vars 	IQ_factor RiskSuspended Smoke Cig sport 
								BMI LocusControl SDQ_score childSDQ_score Depression_score;
								
local Adult30_outcome_vars		IQ_factor votoMaturita votoUni highschoolGrad 
								PA_Empl SES_self HrsTot Reddito_1 Reddito_2 Reddito_3 Reddito_4 
								Reddito_5 Reddito_6 Reddito_7 Maria Smoke Cig 
								BMI Health SickDays LocusControl Depression_score
								binSatisIncome binSatisWork binSatisHealth binSatisFamily;
								
local Adult40_outcome_vars		IQ_factor votoMaturita votoUni highschoolGrad 
								PA_Empl SES_self HrsTot Reddito_1 Reddito_2 Reddito_3 Reddito_4 
								Reddito_5 Reddito_6 Reddito_7 Maria Smoke Cig 
								BMI Health SickDays LocusControl Depression_score
								binSatisIncome binSatisWork binSatisHealth binSatisFamily;
								
local Adult50_outcome_vars		IQ_factor votoMaturita votoUni highschoolGrad 
								PA_Empl SES_self HrsTot Reddito_1 Reddito_2 Reddito_3 Reddito_4 
								Reddito_5 Reddito_6 Reddito_7 Maria Smoke Cig 
								BMI Health SickDays LocusControl Depression_score
								binSatisIncome binSatisWork binSatisHealth binSatisFamily;

local control_vars;

local cohorts			Child Migrant Adolescent Adult30 Adult40 Adult50;
local cities			Reggio Parma Padova;
local schools	Municipal State Religious Private None;

#delimit cr

*-* To ease display of table

recode maternaType 		(1=1) (2=2) (3=3) (4=4) (0=5)

label define materna_type 	1 Municipal 2 State 3 Religious 4 Private 5 None

label value maternaType materna_type

local name		Materna

local tabular 	"\begin{tabular}{l r r r r r r r r r r}"
local header	"& \multicolumn{2}{c}{Municipal} & \multicolumn{2}{c}{State} & \multicolumn{2}{c}{Religious} & \multicolumn{2}{c}{Private} & \multicolumn{2}{c}{None} \\"
local meanN		"& \scriptsize Mean & \scriptsize N & \scriptsize Mean & \scriptsize N & \scriptsize Mean & \scriptsize N & \scriptsize Mean & \scriptsize N & \scriptsize Mean & \scriptsize N \\"


*-* Construct matrix of summary statistics disaggregated

cd ${git_reggio}

	
local cohort_i = 1
foreach cohort in `cohorts' {
	
	local city_i = 1
	foreach city in `cities' {
			
		file open outcome using "Output/description/outcome`city'`cohort'.tex", write replace
		file write outcome "`tabular'" 	_n
		file write outcome "\toprule" 			_n
		file write outcome "`header'" 	_n
		file write outcome "`meanN'"	_n
		file write outcome "\midrule" 			_n
			
			log using "Output/description/log/check`city'`cohort'", replace
			foreach v in ``cohort'_outcome_vars' {
				local row
				
				local school_i = 1
				foreach s in `schools' {
					
					sum `v' if maternaType == `school_i' & City == `city_i' & Cohort == `cohort_i'
						local N_save 	= r(N)
						local mean_save = r(mean)
					
					local p_save = 999 // in case the ttest doesn't go through
					preserve 
						
						keep if Cohort == `cohort_i'
						keep if City == 1 | City == `city_i'
						keep if maternaType == 1 | maternaType == `school_i' 
						tab maternaType City
						tab Cohort
						
						gen compare_group = .
						replace compare_group = 1 if maternaType == 1 & City == 1 
						replace compare_group = 0 if maternaType == `school_i' & City == `city_i' 
						
						tab compare_group
						if r(r) == 2 & `N_save' > 0 {
							cap ttest `v', by(compare_group) unequal welch
							local p_save = r(p)
						}
					
					restore 
					
					
					
				// get var label
				local vl 	: variable label `v'
					
				// reformat statistics
				foreach l in mean min max p50 sd p {
						local `l'_save : di %9.2f ``l'_save'
				}
				local N_save : di %9.0f `N_save'
						
				if `N_save' == 0 {
					local N_save .
				}
					
				if `p_save' <= 0.1 {
					local mean_save \textbf{`mean_save'}
				}
					
				// save to row
				if `school_i' == 1 {
					local row `row' 	`vl' & `mean_save' & `N_save'
				}
				else {
					local row `row' 	& `mean_save' & `N_save'
				}
					
					
				// write row
				if `school_i' == 5  {
					local row `row' \\
							
					file write outcome "`row'" _n
				}
						
			local school_i = `school_i' + 1 
			}
				
		}
		log close
			
		file write outcome "\bottomrule" _n
		file write outcome "\end{tabular}" _n
		file close outcome
		local city_i = `city_i' + 1
	
	}
	local cohort_i = `cohort_i' + 1
}


