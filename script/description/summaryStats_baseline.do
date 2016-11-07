set more off
global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio 
*-------------------------------------------------------------------------------
include "${git_reggio}/script/prepare-data"
include "${git_reggio}/script/macros"

set more off
*-------------------------------------------------------------------------------

local baseline	${child_baseline_vars} ${adol_baseline_vars} ${adult_baseline_vars}

local baseline: list uniq baseline

foreach v in `baseline'{
	egen check_`v' = total(`v'), by(Cohort)
	replace `v' = . if check_`v' == 0
}

*-------------------------------------------------------------------------------
local header1	"\begin{landscape}"
local header2	"\begin{center}"
local header3	"\begin{longtable}{L{6cm} c c c p{.5cm} c c c p{.5cm} c c c p{.5cm} c c c p{.5cm} c c c}"
local header4	"& \multicolumn{3}{c}{\textbf{Children}} & & \multicolumn{3}{c}{\textbf{Adolescents}} & & \multicolumn{3}{c}{\textbf{Adults 30}} & & \multicolumn{3}{c}{\textbf{Adults 40}} & & \multicolumn{3}{c}{\textbf{Adults 50}}\\"
local header5	"& \scriptsize{Reggio} & \scriptsize{Parma}& \scriptsize{Padova} & & \scriptsize{Reggio} & \scriptsize{Parma}& \scriptsize{Padova} & & \scriptsize{Reggio} & \scriptsize{Parma}& \scriptsize{Padova} & & \scriptsize{Reggio} & \scriptsize{Parma}& \scriptsize{Padova} & & \scriptsize{Reggio} & \scriptsize{Parma}& \scriptsize{Padova}\\"

cd "$git_reggio\Output"

file open dstat using "summaryAll_baseline_output.tex", write replace
file write dstat "\singlespace" _n
file write dstat "\setlength{\tabcolsep}{2pt}" _n
file write dstat "`header2'" _n
file write dstat "\scriptsize{" _n
file write dstat "`header3'" _n
file write dstat "\hline"
file write dstat "\multicolumn{20}{L{24cm}}{\textbf{Note:} Means are reported for each variable by cohort and city. Standard Deviations are reported in italics below each mean estimate. A . denotes that the variable is not defined for a specific cohort.}" _n
file write dstat "\endfoot" _n
file write dstat "\caption{Summary statistics for baseline variables by cohort and city} \label{table:summaryStat_baseline} \\" _n
file write dstat "\hline" _n
file write dstat "`header4'" _n
file write dstat "`header5'" _n
file write dstat "\hline \\[.2em] \endhead" _n
	

foreach outcome in `baseline'{
	local vl : variable label `outcome'
		foreach cohort_val in 1 3 4 5 6{
			forvalues city_val =1/3{
				qui: sum `outcome' if Cohort==`cohort_val' & City==`city_val'
				local mean_`cohort_val'_`city_val' : di %9.2f `= r(mean)'
				local sd_`cohort_val'_`city_val' : di %9.2f `= r(sd)'
				local N_`cohort_val'_`city_val' = r(N)
			}
		}
		local meanRow `mean_1_1' & `mean_1_2' & `mean_1_3' & & `mean_3_1' & `mean_3_2' & `mean_3_3' & & `mean_4_1' & `mean_4_2' & `mean_4_3' & & `mean_5_1' & `mean_5_2' & `mean_5_3' & & `mean_6_1' & `mean_6_2' & `mean_6_3'
		local sdRow & $\mathit{`sd_1_1'}$ & $\mathit{`sd_1_2'}$ & $\mathit{`sd_1_3'}$ & & $\mathit{`sd_3_1'}$ & $\mathit{`sd_3_2'}$ & $\mathit{`sd_3_3'}$ & & $\mathit{`sd_4_1'}$ & $\mathit{`sd_4_2'}$ & $\mathit{`sd_4_3'}$ & & $\mathit{`sd_5_1'}$ & $\mathit{`sd_5_2'}$ & $\mathit{`sd_5_3'}$ & & $\mathit{`sd_6_1'}$ & $\mathit{`sd_6_2'}$ & $\mathit{`sd_6_3'}$
		local NRow & `N_1_1' & `N_1_2' & `N_1_3' & & `N_3_1' & `N_3_2' & `N_3_3' & & `N_4_1' & `N_4_2' & `N_4_3' & & `N_5_1' & `N_5_2' & `N_5_3' & & `N_6_1' & `N_6_2' & `N_6_3'

		file write dstat " \quad ${`outcome'_lab} & `meanRow' \\*" _n
		file write dstat " \quad `sdRow' \\[.2em]" _n
		*file write dstat " \quad `NRow' \\[.7em]" _n
}
file write dstat " ~\\[-.5em]" _n


file write dstat "\hline" _n
file write dstat "\end{longtable}" _n
file write dstat "}" _n
file write dstat "\end{center}" _n
file close dstat
*-------------------------------------------------------------------------------

