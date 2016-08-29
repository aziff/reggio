* Authors: Jessica and Pietro
* This small code runs regression analyses separated by city and age
* It then plots the coefficients into graphs --> output can be seen in /presentations/first-results

// Regression analysis 
* ---------------------------------------------------------------------------- *
* Regression Analyses separated by city and age
/* Note: Children => Cohort == 1
		 Migrants => Cohort == 2
		 Adolescents => Cohort == 3 
		 Adult 30 => Cohort == 4
		 Adult 40 => Cohort == 5
		 Adult 50 => Cohort == 6 */
		 
** For convenience, group all adults into a same cohort
generate Cohort_new = 0
replace Cohort_new = 1 if Cohort == 1 // children
replace Cohort_new = 2 if Cohort == 3 // adolescents
replace Cohort_new = 3 if Cohort == 4 | Cohort == 5 | Cohort == 6 // adults

** Run regressions and save the outputs
local int xa 
foreach age in `school_age_types' { // Asilo or Materna
	local city_val = 1
	foreach city in `cities' {
		local cohort_val = 1
		** MAIN TREATMENT EFFECTS; CHANGE REFERENCE GROUP HERE
		if "`age'" == "Asilo" {
			local main_terms		`city'`age' `int'`city'Priv	`int'`city'None
		
		}
		else {
			local main_terms	`city'`age' `int'`city'Priv `int'`city'Stat `int'`city'None
		}
		
		foreach cohort in `cohorts' { // Child, Adol, or Adult
			foreach outcome in `out`cohort'' {
				di "Running regression for `cohort' in `city' attending `age' and outcome `outcome'"
			    local large_sample_condition	largeSample_`city'`age'`cohort'``outcome'_short' == 1
				
				** Generate small sample		 
				//reg childSDQ_score `city'`age' `int'`city'Reli `int'`city'Priv `Xright' if (City == `city_val' & Cohort_new == `cohort_val' & momMaxEdu_miss == 0 & cgReddito_miss == 0), robust  
				//gen smallSample_`city'`age'`cohort' = e(sample)	
	
				** Generate large sample
				sum `outcome' `main_terms' `Xright' `Xleft`cohort''
				reg `outcome' `main_terms' `Xright' `Xleft`cohort'' if (City == `city_val' & Cohort_new == `cohort_val'), robust  
				gen largeSample_`city'`age'`cohort'``outcome'_short' = e(sample)	
				tab largeSample_`city'`age'`cohort'``outcome'_short'

				** Run regressions and store results into latex
				
				* 1. Only city/age terms
				reg `outcome' `main_terms' if `large_sample_condition', robust  
					estimates store `city'`age'`cohort'``outcome'_short'main
					estimates dir
					outreg2 using "${klmReggio}/Analysis/Output/test`city'`age'`cohort'``outcome'_short'.out", replace `outregOption`cohort'' addtext(Controls, None)
				
				* 2. Adding interviewer fixed effects
				reg `outcome' `main_terms' CAPI internr_* if `large_sample_condition', robust  
					estimates store `city'`age'`cohort'``outcome'_short'inter
					estimates dir
					outreg2 using "${klmReggio}/Analysis/Output/test`city'`age'`cohort'``outcome'_short'.out", append `outregOption`cohort'' addtext(Controls, Yes)


				* 3. Interviewer and demographic/family/interview characteristics
				reg `outcome' `main_terms' `Xright' if `large_sample_condition', robust  
					estimates store `city'`age'`cohort'``outcome'_short'right
					estimates dir
					outreg2 using "${klmReggio}/Analysis/Output/test`city'`age'`cohort'``outcome'_short'.out", append `outregOption`cohort'' addtext(Controls, Yes) 
				
				* 4. All controls
				reg `outcome' `main_terms' `Xright' `Xleft`cohort'' if `large_sample_condition', robust  
					estimates store `city'`age'`cohort'``outcome'_short'all
					estimates dir
					outreg2 using "${klmReggio}/Analysis/Output/test`city'`age'`cohort'``outcome'_short'.out", append `outregOption`cohort'' addtext(Controls, all)
					* outreg2 using "${klmReggio}/Analysis/Output/test`city'`age'`cohort'``outcome'_short'all.tex", replace `outregOption`cohort'' addtext(Controls, all)
			
			
				** Save results
				foreach r in /*main inter right*/ all {
					estimates restore `city'`age'`cohort'``outcome'_short'`r'
					
					scalar N_``outcome'_short'_`age'_`city'_`cohort'_`r' = e(N)
					matrix b_``outcome'_short'_`age'_`city'_`cohort'_`r' = e(b)
					matrix V_``outcome'_short'_`age'_`city'_`cohort'_`r' = e(V)
					
					forval i = 1/4 {
						gen b`i'``outcome'_short'_`age'_`city'_`cohort'_`r' = b_``outcome'_short'_`age'_`city'_`cohort'_`r'[1,`i'] // this is regression coefficient
						gen v`i'``outcome'_short'_`age'_`city'_`cohort'_`r' = sqrt(V_``outcome'_short'_`age'_`city'_`cohort'_`r'[`i',`i']) // this is standard error.
						
						gen u`i'``outcome'_short'_`age'_`city'_`cohort'_`r' = b`i'``outcome'_short'_`age'_`city'_`cohort'_`r' + 1.95*(v`i'``outcome'_short'_`age'_`city'_`cohort'_`r')/sqrt(N_``outcome'_short'_`age'_`city'_`cohort'_`r')
						gen l`i'``outcome'_short'_`age'_`city'_`cohort'_`r' = b`i'``outcome'_short'_`age'_`city'_`cohort'_`r' - 1.95*(v`i'``outcome'_short'_`age'_`city'_`cohort'_`r')/sqrt(N_``outcome'_short'_`age'_`city'_`cohort'_`r')
					}
					
					gen N_``outcome'_short'_`age'_`city'_`cohort'_`r' = N_``outcome'_short'_`age'_`city'_`cohort'_`r'
				}
			}
			local cohort_val = `cohort_val' + 1
		}
		local city_val = `city_val' + 1
	}
	local int xm
}

//save ${klmReggio}/Analysis/Output/temp.dta, replace 

* ---------------------------------------------------------------------------- *

local graph_region		graphregion(color(white))

//each outcome should have its own axis
local yaxis_CS 			ylabel(-5(1)5, labsize(small)) yline(0,lcol(black) lwidth(thin)) ytitle(Est. difference wrt Religious)
local yaxis_S 			`yaxis_CS'
local yaxis_D 			`yaxis_CS'
local yaxis_CH 			ylabel(-0.75(0.25)0.75, labsize(small)) yline(0,lcol(black) lwidth(thin)) ytitle(Est. difference wrt Religious)
local yaxis_H 			`yaxis_CH'
local yaxis_M 			`yaxis_CH'
local xaxisAsilo 		xtick(none) xlabel(2 "Reggio" 6 "Parma"	10 "Padova")
local xaxisMaterna 		xtick(none) xlabel(2.5 "Reggio" 7.5 "Parma" 12.5 "Padova")
	
local bar_look			lwidth(5)

local Asilo_bar1		col(dkgreen) //bar1 is municipal --> treatment
local Asilo_bar2		col(gs8)
local Asilo_bar3		col(dkorange)

local Materna_bar1		col(dkgreen) //bar1 is municipal --> treatment
local Materna_bar2		col(gs8)
local Materna_bar3		col(navy)
local Materna_bar4		col(dkorange)

local ci_lines			col(red)	lwidth(vvthin)

local Asilo_legend		legend(size(small) rows(1) holes(1) order(1 2 3) label(1 Municipal) label(2 Private) label(3 None))
local Materna_legend	legend(rows(1) order(1 2 3 4) label(1 Municipal) label(2 Private) label(3 State) label(4 None))

* ---------------------------------------------------------------------------- *
* For the plot
forval i = 0/20 {
	capture gen ref`i' = `i' // x values to plot the points
}


** Graph results
foreach age of local school_age_types { // Asilo or Materna
	foreach cohort in `cohorts' { // Child, Adol, or Adult
		foreach outcome in `out`cohort'' {
			foreach r in main inter right all {

			local title				title("``age'_name': ``outcome'_name', ``r'_name'") //I need to put title here, otherwise STATA won't recognize all the category locals.
		
				if "`age'" == "Asilo" {
					# delimit ;
					twoway (rspike b1``outcome'_short'_`age'_Reggio_`cohort'_`r' ref0 ref1, `bar_look' `Asilo_bar1') 
							(rspike b2``outcome'_short'_`age'_Reggio_`cohort'_`r' ref0 ref2, `bar_look' `Asilo_bar2') 
							(rspike b3``outcome'_short'_`age'_Reggio_`cohort'_`r' ref0 ref3,  `bar_look' `Asilo_bar3')
							(rspike b1``outcome'_short'_`age'_Parma_`cohort'_`r' ref0 ref5,  `bar_look' `Asilo_bar1') 
							(rspike b2``outcome'_short'_`age'_Parma_`cohort'_`r' ref0 ref6,  `bar_look' `Asilo_bar2') 
							(rspike b3``outcome'_short'_`age'_Parma_`cohort'_`r' ref0 ref7, `bar_look' `Asilo_bar3')
							(rspike b1``outcome'_short'_`age'_Padova_`cohort'_`r' ref0 ref9,  `bar_look' `Asilo_bar1') 
							(rspike b2``outcome'_short'_`age'_Padova_`cohort'_`r' ref0 ref10,  `bar_look' `Asilo_bar2') 
							(rspike b3``outcome'_short'_`age'_Padova_`cohort'_`r' ref0 ref11,  `bar_look' `Asilo_bar3')
							(rcap 		l1``outcome'_short'_`age'_Reggio_`cohort'_`r' 
										u1``outcome'_short'_`age'_Reggio_`cohort'_`r' ref1, `ci_lines')
							(rcap 		l2``outcome'_short'_`age'_Reggio_`cohort'_`r' 
										u2``outcome'_short'_`age'_Reggio_`cohort'_`r' ref2, `ci_lines')
							(rcap 		l3``outcome'_short'_`age'_Reggio_`cohort'_`r' 
										u3``outcome'_short'_`age'_Reggio_`cohort'_`r' ref3, `ci_lines')
							(rcap 		l1``outcome'_short'_`age'_Parma_`cohort'_`r' 
										u1``outcome'_short'_`age'_Parma_`cohort'_`r' ref5, `ci_lines')
							(rcap 		l2``outcome'_short'_`age'_Parma_`cohort'_`r' 
										u2``outcome'_short'_`age'_Parma_`cohort'_`r' ref6, `ci_lines')
							(rcap		l3``outcome'_short'_`age'_Parma_`cohort'_`r' 
										u3``outcome'_short'_`age'_Parma_`cohort'_`r' ref7, `ci_lines')
							(rcap 		l1``outcome'_short'_`age'_Padova_`cohort'_`r' 
										u1``outcome'_short'_`age'_Padova_`cohort'_`r' ref9, `ci_lines')
							(rcap 		l2``outcome'_short'_`age'_Padova_`cohort'_`r' 
										u2``outcome'_short'_`age'_Padova_`cohort'_`r' ref10, `ci_lines')
							(rcap 		l3``outcome'_short'_`age'_Padova_`cohort'_`r' 
										u3``outcome'_short'_`age'_Padova_`cohort'_`r' ref11, `ci_lines'
												`title' `yaxis_``outcome'_short'' `xaxis`age''
												`Asilo_legend' 
												`graph_region' name(``outcome'_short'_`age'_`cohort'_`r',replace));
					graph export "${klmReggio}/Analysis/Output/graphs/``outcome'_short'_`age'_`cohort'_`r'.eps", replace as(eps);
					# delimit cr
				}
				
				else {
					# delimit ;
					twoway (rspike b1``outcome'_short'_`age'_Reggio_`cohort'_`r' ref0 ref1, `bar_look' `Materna_bar1') 
							(rspike b2``outcome'_short'_`age'_Reggio_`cohort'_`r' ref0 ref2, `bar_look' `Materna_bar2') 
							(rspike b3``outcome'_short'_`age'_Reggio_`cohort'_`r' ref0 ref3, `bar_look' `Materna_bar3')
							(rspike b4``outcome'_short'_`age'_Reggio_`cohort'_`r' ref0 ref4, `bar_look' `Materna_bar4')
							(rspike b1``outcome'_short'_`age'_Parma_`cohort'_`r' ref0 ref6, `bar_look' `Materna_bar1') 
							(rspike b2``outcome'_short'_`age'_Parma_`cohort'_`r' ref0 ref7, `bar_look' `Materna_bar2') 
							(rspike b3``outcome'_short'_`age'_Parma_`cohort'_`r' ref0 ref8, `bar_look' `Materna_bar3')
							(rspike b4``outcome'_short'_`age'_Parma_`cohort'_`r' ref0 ref9, `bar_look' `Materna_bar4')
							(rspike b1``outcome'_short'_`age'_Padova_`cohort'_`r' ref0 ref11, `bar_look' `Materna_bar1') 
							(rspike b2``outcome'_short'_`age'_Padova_`cohort'_`r' ref0 ref12, `bar_look' `Materna_bar2') 
							(rspike b3``outcome'_short'_`age'_Padova_`cohort'_`r' ref0 ref13, `bar_look' `Materna_bar3')
							(rspike b4``outcome'_short'_`age'_Padova_`cohort'_`r' ref0 ref14, `bar_look' `Materna_bar4')
							(rcap		l1``outcome'_short'_`age'_Reggio_`cohort'_`r' 
										u1``outcome'_short'_`age'_Reggio_`cohort'_`r' ref1, `ci_lines')
							(rcap	 	l2``outcome'_short'_`age'_Reggio_`cohort'_`r' 
										u2``outcome'_short'_`age'_Reggio_`cohort'_`r' ref2, `ci_lines')
							(rcap	 	l3``outcome'_short'_`age'_Reggio_`cohort'_`r' 
										u3``outcome'_short'_`age'_Reggio_`cohort'_`r' ref3, `ci_lines')
							(rcap		l4``outcome'_short'_`age'_Reggio_`cohort'_`r' 
										u4``outcome'_short'_`age'_Reggio_`cohort'_`r' ref4, `ci_lines')
							(rcap	 	l1``outcome'_short'_`age'_Parma_`cohort'_`r' 
										u1``outcome'_short'_`age'_Parma_`cohort'_`r' ref6, `ci_lines')
							(rcap	 	l2``outcome'_short'_`age'_Parma_`cohort'_`r' 
										u2``outcome'_short'_`age'_Parma_`cohort'_`r' ref7, `ci_lines')
							(rcap	 	l3``outcome'_short'_`age'_Parma_`cohort'_`r' 
										u3``outcome'_short'_`age'_Parma_`cohort'_`r' ref8, `ci_lines')
							(rcap	 	l4``outcome'_short'_`age'_Parma_`cohort'_`r' 
										u4``outcome'_short'_`age'_Parma_`cohort'_`r' ref9, `ci_lines')
							(rcap	 	l1``outcome'_short'_`age'_Padova_`cohort'_`r'
										u1``outcome'_short'_`age'_Padova_`cohort'_`r' ref11, `ci_lines')
							(rcap	 	l2``outcome'_short'_`age'_Padova_`cohort'_`r' 
										u2``outcome'_short'_`age'_Padova_`cohort'_`r' ref12, `ci_lines')
							(rcap	 	l3``outcome'_short'_`age'_Padova_`cohort'_`r' 
										u3``outcome'_short'_`age'_Padova_`cohort'_`r' ref13, `ci_lines')
							(rcap	 	l4``outcome'_short'_`age'_Padova_`cohort'_`r' 
										u4``outcome'_short'_`age'_Padova_`cohort'_`r' ref14, `ci_lines'
												`title' `yaxis_``outcome'_short'' `xaxis`age''
												`Materna_legend' 
												`graph_region');
					graph export "${klmReggio}/Analysis/Output/graphs/``outcome'_short'_`age'_`cohort'_`r'.eps", replace as(eps);
					# delimit cr
						
				}
				
			}
		}
	}
}


} // end of if loop of the regression analysis

