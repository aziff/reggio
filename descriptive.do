set more off
global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio // AZ: changed $git_reggio to point to GitHub repo

include "${git_reggio}/prepare-data"
include "${git_reggio}/baseline-rename"

set more off

*-------------------------------------------------------------------------------

local N_short_name 	nonCog
local E_short_name 	edu
local H_short_name	health
local W_short_name	labor
local L_short_name	fam
local S_short_name	soc

local N_full_name	Non-cognitive
local E_full_name	Education
local H_full_name	Health
local W_full_name	Labor
local L_full_name	Family
local S_full_name	Social

local N_lower_name 	non-cognitive
local E_lower_name 	education
local H_lower_name	health
local W_lower_name	labor
local L_lower_name	family
local S_lower_name	social


local N 	pos_childSDQ_score pos_childSDQEmot_score pos_childSDQCond_score pos_childSDQHype_score pos_childSDQPeer_score pos_childSDQPsoc_score ///
			pos_SDQ_score pos_SDQEmot_score pos_SDQCond_score pos_SDQHype_score pos_SDQPeer_score pos_SDQPsoc_score ///
			pos_Depression_score pos_LocusControl optimist ///
			reciprocity1bin reciprocity2bin reciprocity3bin reciprocity4bin ///
			binSatisSchool binSatisHealth binSatisFamily binSatisIncome binSatisWork

local H 	childBMI childz_BMI cgBMI BMI z_BMI ///

local E		IQ_score IQ_factor cgIQ_score cgIQ_factor ///
			votoMaturita votoUni ///
			highschoolGrad MaxEdu_Uni MaxEdu_Grad

local W		PA_Empl SES_self HrsTot WageMonth ///
			Reddito_1 Reddito_2 Reddito_3 Reddito_4 Reddito_5 Reddito_6 Reddito_7

local L		mStatus_married_cohab childrenResp all_houseOwn live_parent 
									
local H		childBMI childz_BMI cgBMI BMI z_BMI ///
			Maria Smoke Cig goodHealth SickDays ///
			i_RiskFight i_RiskDUI RiskSuspended Drink1Age									
									
local S		MigrTaste Friends MigrFriend
			
		
local categories 	N H E W L H N S

local header1	"\begin{landscape}"
local header2	"\begin{center}"
local header3	"\begin{longtable}{L{12em} c c c p{1.2em} c c c p{1.2em} c c c p{1.2em} c c c p{1.2em} c c c p{1.2em} c c c}"
local header4	"& \multicolumn{3}{c}{\textbf{Children}} & & \mc{3}{c}{\textbf{Migrants}} & & \multicolumn{3}{c}{\textbf{Adolescents}} & & \multicolumn{3}{c}{\textbf{Adults 30}} & & \multicolumn{3}{c}{\textbf{Adults 40}} & & \multicolumn{3}{c}{\textbf{Adults 50}}\\"
local header5	"& \scriptsize{Reggio} & \scriptsize{Parma}& \scriptsize{Padova} & & \scriptsize{Reggio} & \scriptsize{Parma}& \scriptsize{Padova} & & \scriptsize{Reggio} & \scriptsize{Parma}& \scriptsize{Padova} & & \scriptsize{Reggio} & \scriptsize{Parma}& \scriptsize{Padova} & & \scriptsize{Reggio} & \scriptsize{Parma}& \scriptsize{Padova} & & \scriptsize{Reggio} & \scriptsize{Parma}& \scriptsize{Padova}\\"


*-------------------------------------------------------------------------------
// descriptive table of variables

cd "$git_reggio"

foreach category in `categories' {

	file open dstat using "Output/descriptiveStats_``category'_short_name'.tex", write replace
	file write dstat "% created using descriptive.do" _n
	file write dstat "\singlespace" _n
	file write dstat "\setlength{\tabcolsep}{2pt}" _n
	file write dstat "`header2'" _n
	file write dstat "\scriptsize{" _n
	file write dstat "`header3'" _n
	file write dstat "\hline"
	file write dstat "\multicolumn{24}{L{20cm}}{\textbf{Note:} Unconditional means are reported for each variable by cohort and city. Standard Deviations are reported in italics below each mean estimates.}" _n
	file write dstat "\endfoot" _n
	file write dstat "\caption{Mean and Standard Deviation for ``category'_full_name' variables by city and cohort} \label{table:Desc_`category'} \\" _n
	file write dstat "\hline" _n
	file write dstat "`header4'" _n
	file write dstat "`header5'" _n
	file write dstat "\hline \\ \endhead \\" _n
	
	foreach outcome in ``category''{
		local vl : variable label `outcome'
		forvalues cohort_val = 1/6 {
			forvalues city_val = 1/3 {
				qui sum `outcome' if Cohort==`cohort_val' & City==`city_val'
				
				local mean_`cohort_val'_`city_val' 	= r(mean)
				local sd_`cohort_val'_`city_val' 	= r(sd)

				local mean_`cohort_val'_`city_val': di %9.2f `mean_`cohort_val'_`city_val''
				local sd_`cohort_val'_`city_val': 	di %9.2f `sd_`cohort_val'_`city_val''
			}
		}
		local meanRow `mean_1_1' & `mean_1_2' & `mean_1_3' & & `mean_2_1' & `mean_2_2' & `mean_2_3' & & `mean_3_1' & `mean_3_2' & `mean_3_3' & & `mean_4_1' & `mean_4_2' & `mean_4_3' & & `mean_5_1' & `mean_5_2' & `mean_5_3' & & `mean_6_1' & `mean_6_2' & `mean_6_3'
		local sdRow & $\mathit{`sd_1_1'}$ & $\mathit{`sd_1_2'}$ & $\mathit{`sd_1_3'}$ & & $\mathit{`sd_2_1'}$ & $\mathit{`sd_2_2'}$ & $\mathit{`sd_2_3'}$ & & $\mathit{`sd_3_1'}$ & $\mathit{`sd_3_2'}$ & $\mathit{`sd_3_3'}$ & & $\mathit{`sd_4_1'}$ & $\mathit{`sd_4_2'}$ & $\mathit{`sd_4_3'}$ & & $\mathit{`sd_5_1'}$ & $\mathit{`sd_5_2'}$ & $\mathit{`sd_5_3'}$ & & $\mathit{`sd_6_1'}$ & $\mathit{`sd_6_2'}$ & $\mathit{`sd_6_3'}$
		
		file write dstat "``outcome'_lab' & `meanRow' \\*" _n
		file write dstat "`sdRow' \\[.7em]" _n
	}

	file write dstat "\hline" _n
	file write dstat "\end{longtable}" _n
	file write dstat "}" _n
	file write dstat "\end{center}" _n
	file close dstat
}
*-------------------------------------------------------------------------------
// table for missing observations in variables

foreach category in `categories' {

	file open missing using "Output/missingVal_``category'_short_name'.tex", write replace
	file write missing "% created using descriptive.do" _n
	file write missing "\singlespace" _n
	file write missing "\setlength{\tabcolsep}{2pt}" _n
	file write missing "`header2'" _n
	file write missing "\scriptsize{" _n
	file write missing "`header3'" _n
	file write missing "\multicolumn{24}{L{23cm}}{\textbf{Note:} This table reports the number of observations that are missing for each ``category'_lower_name' variable by city and cohort. \textbf{--} indicates that the variable has 0 observations for the particular cohort-city group.}" _n
	file write missing "\endfoot"
	file write missing "\caption{Missing observations for ``category'_lower_name' variables by city and cohort} \label{table:Miss_``category'_short_name'} \\" _n
	file write missing "\hline" _n
	file write missing "`header4'" _n
	file write missing "`header5'" _n
	file write missing "\hline \endhead \\" _n

	foreach outcome in ``category''{
		forvalues cohort_val = 1/6 {
			forvalues city_val = 1/3 {
			
				qui count if `outcome'!=. & Cohort==`cohort_val' & City==`city_val'
				local nocount_check = r(N)
				
				if `nocount_check' != 0 {
					qui count if Cohort == `cohort_val' & City == `city_val'
					local tot_count = r(N)
				
					qui count if `outcome'==. & Cohort==`cohort_val' & City==`city_val'
					local missing_`cohort_val'_`city_val' = r(N)
					local missing_`cohort_val'_`city_val' = `missing_`cohort_val'_`city_val''/`tot_count'
					
					local missing_`cohort_val'_`city_val': di %9.2f `missing_`cohort_val'_`city_val''
				}
				if `nocount_check' == 0 {
					local missing_`cohort_val'_`city_val' = "-"
				}
			}
		}
		local missingRow  `missing_1_1' & `missing_1_2' & `missing_1_3' & & `missing_2_1' & `missing_2_2' & `missing_2_3' & & `missing_3_1' & `missing_3_2' & `missing_3_3' & & `missing_4_1' & `missing_4_2' & `missing_4_3' & & `missing_5_1' & `missing_5_2' & `missing_5_3' & & `missing_6_1' & `missing_6_2' & `missing_6_3'
		file write missing "``outcome'_lab' & `missingRow' \\[.3em]" _n
	}

	file write missing "\hline" _n
	file write missing "\end{longtable}" _n
	file write missing "}" _n
	file write missing "\end{center}" _n
	file close missing
}
*-----------------------------------
// densities for IQ 

local RE_line 		lcol(black) lwidth(thick)
local PM_line 		lcol(gs8) lwidth(thick)
local PD_line 		lcol(black) lpattern(dash) lwidth(thick)
local graphregion 	graphregion(color(white)) 
local xaxis 		xtitle("IQ Score") xlabel(#5, grid glwidth(vthin) glcolor(gs11) format(%9.1f))
local yaxis 		ytitle("Density") ylabel(#5, glwidth(vthin) glcolor(gs11))
local legend		legend(rows(1) label(1 Reggio) label(2 Parma) label(3 Padova))

forvalues cohort_val = 1/6 {

	preserve
	
		keep if Cohort == `cohort_val'

		twoway 	(kdensity IQ_score if City == 1, `RE_line' ) 	///
				(kdensity IQ_score if City == 2, `PM_line' ) 	///
				(kdensity IQ_score if City == 3, `PD_line' ), 	///
				`graphregion'									///
				`xaxis' `yaxis'									///
				`legend'										
		graph export "Output/IQ_hist_`cohort_val'.eps", as(eps) replace
	restore
}

*-----------------------------------
