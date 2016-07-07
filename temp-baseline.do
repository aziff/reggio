/*
Author: Anna Ziff, Yu Kyung Koh

Purpose:
-- Do the same as baseline-summary but writing directly into LaTeX


Update 6/12/16:
-- No asilo
-- Changing variables for adults to avoid confusion
-- Include aggregation code
*/

cap file close baseline
cap log close

global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio

include "${klmReggio}/Analysis/prepare-data"
include "${klmReggio}/Analysis/baseline-rename"

*-* Adjust variables and statistics of interest
#delimit ;

local main_baseline_vars  		Male Age lowbirthweight birthpremature CAPI
								momAgeBirth momBornProvince
								momMaxEdu_low momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni 
								dadAgeBirth dadBornProvince
								dadMaxEdu_low dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni 
								childrenSibTot cgRelig cgMigrant
								cgReddito_1 cgReddito_2 cgReddito_3 cgReddito_4 cgReddito_5 cgReddito_6 cgReddito_7;
								
								
local adult_baseline_vars		Male Age CAPI
								momBornProvince
								momMaxEdu_low momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni 
								dadBornProvince 
								dadMaxEdu_low dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni
								cgRelig cgCatholic int_cgCatFaith;
								
								
local Child_baseline_vars		`main_baseline_vars';
								
local Migrant_baseline_vars		`main_baseline_vars' 
								yrCity ageCity;

local Adolescent_baseline_vars	`main_baseline_vars';

local Adult30_baseline_vars 	`adult_baseline_vars'; 

local Adult40_baseline_vars 	`adult_baseline_vars';

local Adult50_baseline_vars 	`adult_baseline_vars';

local cohorts					Child Migrant Adolescent Adult30 Adult40 Adult50;
local cities					Reggio Parma Padova;
local schools					Municipal State Religious Private None;

# delimit cr


*-* To ease display of table

recode maternaType 			(1=1) (2=2) (3=3) (4=4) (0=5)

label define materna_type 	1 Municipal 2 State 3 Religious 4 Private 5 None 

label value maternaType 	materna_type

local materna_name			Materna


local tabular 	"\begin{tabular}{l c c c c c c }"
local header	"& \textbf{Municipal} & \textbf{State} & \textbf{Religious} & \textbf{Private} & \textbf{None} \\"

*-* Construct matrix of summary statistics disaggregated

cd "${klmReggio}/Analysis"
	
local cohort_i = 1
foreach cohort in `cohorts' {
	
	local city_i = 1
	foreach city in `cities' {
			
		file open baseline using "Output/description/baseline`city'`cohort'.tex", write replace
		file write baseline "`tabular'" _n
		file write baseline "\toprule" 	_n
		file write baseline "`header'" 	_n
		file write baseline "\midrule" 	_n
			
		foreach v in ``cohort'_baseline_vars' {
			local row
				
			local school_i = 1
			foreach s in `schools' {
				
				sum `v' if maternaType == `school_i' & City == `city_i' & Cohort == `cohort_i'
				
				local N_save`s' = r(N)
				local mean_save = r(mean)
				
				* Unconditional mean
				reg `v' i.maternaType
				local r_squared = e(r2)
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
						if r(r) == 2 & `N_save`s'' > 0 {
							ttest `v', by(compare_group) unequal welch
							local p_save = r(p)
						}
					
					restore 
					
				// get var label
				local vl 	: variable label `v'
					
				// reformat statistics
				foreach l in mean min max p50 sd p {
					local `l'_save : di %9.2f ``l'_save'
				}
				foreach l in  r_squared  {
					local `l' : di %9.2f ``l''
				}
				
				local N_save`s' : di %9.0f `N_save`s''
						
				if `N_save`s'' == 0 {
					local N_save`s' .
				}
					
				if `p_save' <= 0.1 {
					local mean_save \textbf{`mean_save'}
				}
					
				// save to row 
				if `school_i' == 1 {
					local row `row' 	`vl' & `mean_save' 
				}
				else {
					local row `row' 	& `mean_save' 
				}
					
					
				// write row
				if `school_i' == 5 {
					local row `row' \\
							
					file write baseline "`row'" _n
				}
						
			local school_i = `school_i' + 1 
			}
			
			file write baseline "\midrule" _n
			file write baseline "Observations & `N_saveMunicipal' & `N_saveState' & `N_saveReligious' & `N_savePrivate' & `N_saveNone'" _n
				
		}
			
		file write baseline "\bottomrule" _n
		file write baseline "\end{tabular}" _n
		file close baseline
		local city_i = `city_i' + 1
	
	}
	local cohort_i = `cohort_i' + 1
}


