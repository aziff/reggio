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
								momYearsEdu cgMigrant
								dadAgeBirth dadBornProvince
								dadYearsEdu
								numSiblings cgCatholic int_cgCatFaith
								houseOwn cgFamIncome_val;
								
								
local adult_baseline_vars		Male Age CAPI
								momBornProvince
								momYearsEdu
								dadBornProvince 
								dadYearsEdu
								numSiblings cgRelig;
								
								
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
		
		* --------------------------------------------------------------- *
		* Storing the mean and standard errors for each baseline variable *
		* --------------------------------------------------------------- *
		foreach v in ``cohort'_baseline_vars' {
			local row_m
			local row_s
				
			local school_i = 1
			foreach s in `schools' {
				
				sum `v' if maternaType == `school_i' & City == `city_i' & Cohort == `cohort_i'
				
				local N_save`s' = r(N)
				local mean_save = r(mean)
				local std_save = r(sd)
				
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
				foreach l in mean min max p50 std p {
					local `l'_save : di %9.2f ``l'_save'
				}
				foreach l in  r_squared  {
					local `l' : di %9.2f ``l''
				}
				local std_save (`std_save' )
				
				local N_save`s' : di %9.0f `N_save`s''
						
				if `N_save`s'' == 0 {
					local N_save`s' .
				}
					
				if `p_save' <= 0.1 {
					local mean_save \textbf{`mean_save'}
				}
					
				// save to row 
				if `school_i' == 1 {
					local row_m `row_m' 	`vl' & `mean_save' 
				}
				else {
					local row_m `row_m' 	& `mean_save' 
				}
				
				local row_s `row_s' 	& `std_save' 
					
				// write row
				if `school_i' == 5 {
					local row_m `row_m' \\
					local row_s `row_s' \\
							
					file write baseline "`row_m' " _n
					file write baseline "`row_s' " _n
				}
						
			local school_i = `school_i' + 1 
			}
				
		}
		
		* ---------------------------------------------------------------- *
		* Storing the number of people who attended each type of preschool *
		* ---------------------------------------------------------------- *
		local school_i = 1
		local row_N 	Observations
		foreach s in `schools' {
			summ intnr if maternaType == `school_i' & City == `city_i' & Cohort == `cohort_i'
			local N_`s' = r(N)
			local row_N `row_N' & `N_`s''
			
			if `school_i' == 5 {
				local row_N `row_N' \\
				
				file write baseline "\midrule " _n
				file write baseline "`row_N' " _n
			}
			local school_i = `school_i' + 1
		}
			
		file write baseline "\bottomrule" _n
		file write baseline "\end{tabular}" _n
		file close baseline
		local city_i = `city_i' + 1
	
	}
	local cohort_i = `cohort_i' + 1
}


