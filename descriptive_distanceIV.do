set more off
global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio // AZ: changed $git_reggio to point to GitHub repo

include "${git_reggio}/prepare-data"
include "${git_reggio}/baseline-rename"

set more off

*-------------------------------------------------------------------------------
local header1	"\begin{landscape}"
local header2	"\begin{center}"
local header3	"\begin{longtable}{L{5cm} c c c p{.5cm} c c c p{.5cm} c c c p{.5cm} c c c p{.5cm} c c c}"
local header4	"& \multicolumn{3}{c}{\textbf{Children}} & & \multicolumn{3}{c}{\textbf{Adolescents}} & & \multicolumn{3}{c}{\textbf{Adults 30}} & & \multicolumn{3}{c}{\textbf{Adults 40}} & & \multicolumn{3}{c}{\textbf{Adults 50}}\\"
local header5	"& \scriptsize{Reggio} & \scriptsize{Parma}& \scriptsize{Padova} & & \scriptsize{Reggio} & \scriptsize{Parma}& \scriptsize{Padova} & & \scriptsize{Reggio} & \scriptsize{Parma}& \scriptsize{Padova} & & \scriptsize{Reggio} & \scriptsize{Parma}& \scriptsize{Padova} & & \scriptsize{Reggio} & \scriptsize{Parma}& \scriptsize{Padova}\\"

cd "$git_reggio"

file open dstat using "Output/descriptiveStats_distanceIV.tex", write replace
file write dstat "\singlespace" _n
file write dstat "\setlength{\tabcolsep}{2pt}" _n
file write dstat "`header2'" _n
file write dstat "\scriptsize{" _n
file write dstat "`header3'" _n
file write dstat "\hline"
file write dstat "\multicolumn{20}{L{20cm}}{\textbf{Note:} Means are reported for each variable by cohort and city. Standard Deviations are reported in italics below each mean estimates.}" _n
file write dstat "\endfoot" _n
file write dstat "\caption{Mean and Standard Deviation for distance IVs by city and cohort} \label{table:Desc_dIV} \\" _n
file write dstat "\hline" _n
file write dstat "`header4'" _n
file write dstat "`header5'" _n
file write dstat "\hline \\ \endhead \\" _n
	
# delimit ;
local N distAsiloMunicipal1 distAsiloMunicipal2 distAsiloPrivate1 distAsiloPrivate2
		distAsiloReligious1 distAsiloReligious2
		distMaternaMunicipal1 distMaternaMunicipal2 distMaternaPrivate1 distMaternaPrivate2
		distMaternaState1 distMaternaState2 distMaternaReligious1 distMaternaReligious2 ;

# delimit cr

foreach outcome in `N'{
local vl : variable label `outcome'
	foreach cohort_val in 1 3 4 5 6{
		forvalues city_val =1/3{
			sum `outcome' if Cohort==`cohort_val' & City==`city_val'
			local mean_`cohort_val'_`city_val' = r(mean)
			local sd_`cohort_val'_`city_val' = r(sd)

			local mean_`cohort_val'_`city_val': di %9.2f `mean_`cohort_val'_`city_val''
			local sd_`cohort_val'_`city_val': di %9.2f `sd_`cohort_val'_`city_val''
		}
	}
	local meanRow `mean_1_1' & `mean_1_2' & `mean_1_3' & & `mean_3_1' & `mean_3_2' & `mean_3_3' & & `mean_4_1' & `mean_4_2' & `mean_4_3' & & `mean_5_1' & `mean_5_2' & `mean_5_3' & & `mean_6_1' & `mean_6_2' & `mean_6_3'
	local sdRow & $\mathit{`sd_1_1'}$ & $\mathit{`sd_1_2'}$ & $\mathit{`sd_1_3'}$ & & $\mathit{`sd_3_1'}$ & $\mathit{`sd_3_2'}$ & $\mathit{`sd_3_3'}$ & & $\mathit{`sd_4_1'}$ & $\mathit{`sd_4_2'}$ & $\mathit{`sd_4_3'}$ & & $\mathit{`sd_5_1'}$ & $\mathit{`sd_5_2'}$ & $\mathit{`sd_5_3'}$ & & $\mathit{`sd_6_1'}$ & $\mathit{`sd_6_2'}$ & $\mathit{`sd_6_3'}$
	file write dstat "``outcome'_lab' & `meanRow' \\*" _n
	file write dstat "`sdRow' \\[.7em]" _n
}

file write dstat "\hline" _n
file write dstat "\end{longtable}" _n
file write dstat "}" _n
file write dstat "\end{center}" _n
file close dstat
*-------------------------------------------------------------------------------

