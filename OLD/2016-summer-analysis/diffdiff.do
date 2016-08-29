/**********************************************************************
	
	Analyzing the Reggio Children Evaluation Survey
	
	Difference in Difference Command
	
	Author: Chase Owen Corbin 
	Email: (cocorbin@uchicago.edu)
	
	Created: 31 July 2016

	Edited:  31 July 2016

**********************************************************************
* Note * This command can be run prior to reading in any data, 
but will not return output unless prepare-data.do has already been completed

Syntax requires that the older cohort, younger cohort, and school comparison
be specified in that order.

	- Older cohort must be one of Age50, Age40, or Age30
	- Younger cohort muse be one of Children, Adolescent
	- School must be one of Pooled, Municipal, Municipal, State

Examples:

. DiffDiff Age50 Children Pooled

. DiffDiff Age30 Adolescent Municipal

. DiffDiff Age40 Children Religious

**********************************************************************
						TO-DO:
	1.) expand this script to look at: 
	
	- [Older](Municipal - Religious) vs [Younger](Municipal - Religious) 
		(For Pooled Cities)
	
	- [Reggio](Municipal - Religious) vs [Padova](municipal - Religious) 
		(For Fixed Cohort)

***********************************************************************/

capture which estout      			// Checks system for estout
if _rc ssc install estout   		// If not found, installs estout
capture which diff					// Checks system for diff
if _rc ssc install diff 			// CIf not found, installs diff
capture program drop DiffDiff		// Checks to see if older DiffDiff version has previously been installed, and drops it

** local school "Municipal Pooled Religious State"
** local adult "Age50 Age40 Age30"
** local younger "Adolescent Children"
** local city "Padova Parma"

                              
program DiffDiff, eclass
version 13
args older younger school
local covariates "Male CAPI numSiblings dadMaxEdu_Uni dadMaxEdu_Grad momMaxEdu_Grad"

	if `"`older'"' == `"Age50"' & `"`younger'"' == `"Children"' {
		replace Age50 = 0 if Cohort == 6
		replace Age50 = 1 if Cohort == 1
		}
	else if `"`older'"' == `"Age50"' & `"`younger'"' == `"Adolescents"' {
		replace Age50 = 0 if Cohort == 6
		replace Age50 = 1 if Cohort == 3
		}
	else if `"`older'"' == `"Age40"' & `"`younger'"' == `"Children"' {
		replace Age40 = 0 if Cohort == 5
		replace Age40 = 1 if Cohort == 1
		}
	else if `"`older'"' == `"Age40"' & `"`younger'"' == `"Adolescents"' {
		replace Age40 = 0 if Cohort == 5
		replace Age40 = 1 if Cohort == 3
		}
	else if `"`older'"' == `"Age30"' & `"`younger'"' == `"Children"' {
		replace Age30 = 0 if Cohort == 4
		replace Age30 = 1 if Cohort == 1
		}
	else if `"`older'"' == `"Age30"' & `"`younger'"' == `"Adolescents"' {
		replace Age30 = 0 if Cohort == 4
		replace Age30 = 1 if Cohort == 3
		}

	if `"`school'"' == `"Pooled"' {
	replace Padova = 0 if City == 1 & maternaType != 0
	replace Padova = 1 if City == 3 & maternaType != 0
	replace Parma = 0 if City == 1 & maternaType != 0
	replace Parma = 1 if City == 2 & maternaType != 0
	}
	else if `"`school'"' == `"Municipal"' {
	replace Padova = 0 if City == 1 & maternaType == 1
	replace Padova = 1 if City == 3 & maternaType == 1
	replace Parma = 0 if City == 1 & maternaType == 1
	replace Parma = 1 if City == 2 & maternaType == 1
	}	
	else if `"`school'"' == `"Religious"' {
	replace Padova = 0 if City == 1 & maternaType == 3
	replace Padova = 1 if City == 3 & maternaType == 3
	replace Parma = 0 if City == 1 & maternaType == 3
	replace Parma = 1 if City == 2 & maternaType == 3
	}	
	else if `"`school'"' == `"State"' {
	replace Padova = 0 if City == 1 & maternaType == 2
	replace Padova = 1 if City == 3 & maternaType == 2
	replace Parma = 0 if City == 1 & maternaType == 2
	replace Parma = 1 if City == 2 & maternaType == 2
	}
	
	#delimit ;
	
	foreach x in Padova Parma {;
	
		** IQ and Family Satisfaction Variables
		
		foreach i in IQ_v1 IQ_score IQ_factor satFamily unsatFamily satneutralFamily {;
			
		eststo: quietly diff `i', period(`older') treated(`x') cov(Male CAPI numSiblings dadMaxEdu_Uni dadMaxEdu_Grad momMaxEdu_Grad) ;
		mat `i'_`older'`x' = (r(mean_c0), r(se_c0) \ r(mean_t0) \ r(diff0) \ r(mean_c1) \ r(mean_t1) \ r(diff1) \ r(did)) ;

		};
		
		** Produces Tables with coefficients on FE, DID, and all covariates
		
		if `"`school'"' == "Pooled" { ;
			esttab using `older'_`x'vs`younger'_`school'1.tex, b(4) se(4) star nonumbers noobs notes nocons booktabs 
			mtitles("IQ rank" "IQ score" "IQ factor" "Family Sat." "Family Dis." "Family Neutral")
			coeflabels(`older' "Cohort FE" `x' "City FE" __000002 "Diff-in-Diff" Male "Male Dummy" numSiblings "No. of Siblings" dadMaxEdu_Uni "Father Univ." dadMaxEdu_Grad "Father HS" momMaxEdu_Grad "Mother HS")
			title("Reggio Emilia vs. `x', Comparing changes for `older' cohorts")
			addnotes("Estimates shown are for individuals that attended any preschool, regardless of type") replace;
			}; 
		
		else if `"`school'"' == "Municipal" {;
			esttab using `older'_`x'vs`younger'_`school'1.tex, b(4) se(4) star nonumbers noobs notes nocons booktabs 
			mtitles("IQ rank" "IQ score" "IQ factor" "Family Sat." "Family Dis." "Family Neutral")
			coeflabels(`older' "Cohort FE" `x' "City FE" __000002 "Diff-in-Diff" Male "Male Dummy" numSiblings "No. of Siblings" dadMaxEdu_Uni "Father Univ." dadMaxEdu_Grad "Father HS" momMaxEdu_Grad "Mother HS")
			title("Reggio Emilia vs. `x', Comparing changes for `older' cohorts") 
			addnotes("Estimates shown are for individuals that attended municipal preschools only") replace;
			};
			
		else if `"`school'"' == "Religious" {;
			esttab using `older'_`x'vs`younger'_`school'1.tex, b(4) se(4) star nonumbers noobs notes nocons booktabs 
			mtitles("IQ rank" "IQ score" "IQ factor" "Family Sat." "Family Dis." "Family Neutral")
			coeflabels(`older' "Cohort FE" `x' "City FE" __000002 "Diff-in-Diff" Male "Male Dummy" numSiblings "No. of Siblings" dadMaxEdu_Uni "Father Univ." dadMaxEdu_Grad "Father HS" momMaxEdu_Grad "Mother HS")
			title("Reggio Emilia vs. `x', Comparing changes for `older' cohorts") 
			addnotes("Estimates shown are for individuals that attended religious preschools only") replace;
			};
			
		else if `"`school'"' == "State" {;
			esttab using `older'_`x'vs`younger'_`school'1.tex, b(4) se(4) star nonumbers noobs notes nocons booktabs 
			mtitles("IQ rank" "IQ score" "IQ factor" "Family Sat." "Family Dis." "Family Neutral")
			coeflabels(`older' "Cohort FE" `x' "City FE" __000002 "Diff-in-Diff" Male "Male Dummy" numSiblings "No. of Siblings" dadMaxEdu_Uni "Father Univ." dadMaxEdu_Grad "Father HS" momMaxEdu_Grad "Mother HS")
			title("Reggio Emilia vs. `x', Comparing changes for `older' cohorts") 
			addnotes("Estimates shown are for individuals that attended state preschools only") replace;
			};
			
		eststo clear ;

		mat result_`older'`x' = (IQ_v1_`older'`x', IQ_score_`older'`x', IQ_factor_`older'`x', 
		satFamily_`older'`x', unsatFamily_`older'`x', satneutralFamily_`older'`x') ;

		mat colnames result_`older'`x' = "IQ rank" "IQ score" "IQ factor" "Family Sat" "Family Dissat" "Family Neutral" ;

		mat rownames result_`older'`x' = "`older':Reggio" "`older':`x'" "`older':Difference" 
		"`younger':Reggio" "`younger':`x'" "`younger':Difference" "Difference:Difference" ;


		if `"`school'"' == "Pooled" { ;
		esttab matrix(result_`older'`x', fmt(4)) using did_`older'vs`younger'_`x'`school'.tex, 
		nomtitles title("Difference in Differences, `older' to `younger' Cohorts") 
		addnotes("Estimates for those that attended any type of preschool in each city") replace ;
		};
		
		else if `"`school'"' == "Municipal" {;
		esttab matrix(result_`older'`x', fmt(4)) using did_`older'vs`younger'_`x'`school'.tex, 
		nomtitles title("Difference in Differences, `older' to `younger' Cohorts") 
		addnotes("Estimates for those that attended municipal preschools in each city") replace ;
		};
		
		matrix drop _all ;
		
		** Health and Obesity 
		
		foreach h in IQ_v1 IQ_score IQ_factor satFamily unsatFamily satneutralFamily C_A_HealthGood 
		C_A_HealthBad C_A_HealthAvg BMI_obese BMI_overweight {;
			
		eststo: quietly diff `h', period(`older') treated(`x') cov(`covariates') ;

		mat `h'_`older'`x' = (r(mean_c0), r(se_c0) \ r(mean_t0), r(se_t0) \ r(diff0), r(d \ r(mean_c1) \ r(mean_t1) \ r(diff1) \ r(did)) ;

		};
		
		if `"`school'"' == "Pooled" { ;
			esttab using `older'_`x'vs`younger'_`school'2.tex, b(4) se(4) star nonumbers noobs notes nocons booktabs 
			mtitles("Good Health" "Bad Health" "Avg Health" "Obese" "Overweight")
			coeflabels(`older' "Cohort FE" `x' "City FE" __000002 "Diff-in-Diff" Male "Male Dummy" numSiblings "No. of Siblings" dadMaxEdu_Uni "Father Univv." dadMaxEdu_Grad "Father HS" momMaxEdu_Grad "Mother HS")
			title("Reggio Emilia vs. `x', Comparing changes for `older' cohorts")
			addnotes("Estimates shown are for individuals that attended any preschool, regardless of type") replace;
			}; 
		
		else if `"`school'"' == "Municipal" {;
			esttab using `older'_`x'vs`younger'_`school'2.tex, b(4) se(4) star nonumbers noobs notes nocons booktabs 
			mtitles("Good Health" "Bad Health" "Avg Health" "Obese" "Overweight")
			coeflabels(`older' "Cohort FE" `x' "City FE" __000002 "Diff-in-Diff" Male "Male Dummy" numSiblings "No. of Siblings" dadMaxEdu_Uni "Father Univ." dadMaxEdu_Grad "Father HS" momMaxEdu_Grad "Mother HS")
			title("Reggio Emilia vs. `x', Comparing changes for `older' cohorts") 
			addnotes("Estimates shown are for individuals that attended municipal preschools only") replace;
			};

		else if `"`school'"' == "Religious" {;
			esttab using `older'_`x'vs`younger'_`school'2.tex, b(4) se(4) star nonumbers noobs notes nocons booktabs 
			mtitles("Good Health" "Bad Health" "Avg Health" "Obese" "Overweight")
			coeflabels(`older' "Cohort FE" `x' "City FE" __000002 "Diff-in-Diff" Male "Male Dummy" numSiblings "No. of Siblings" dadMaxEdu_Uni "Father Univ." dadMaxEdu_Grad "Father HS" momMaxEdu_Grad "Mother HS")
			title("Reggio Emilia vs. `x', Comparing changes for `older' cohorts") 
			addnotes("Estimates shown are for individuals that attended religious preschools only") replace;
			};

		else if `"`school'"' == "State" {;
			esttab using `older'_`x'vs`younger'_`school'2.tex, b(4) se(4) star nonumbers noobs notes nocons booktabs 
			mtitles("Good Health" "Bad Health" "Avg Health" "Obese" "Overweight")
			coeflabels(`older' "Cohort FE" `x' "City FE" __000002 "Diff-in-Diff" Male "Male Dummy" numSiblings "No. of Siblings" dadMaxEdu_Uni "Father Univ." dadMaxEdu_Grad "Father HS" momMaxEdu_Grad "Mother HS")
			title("Reggio Emilia vs. `x', Comparing changes for `older' cohorts") 
			addnotes("Estimates shown are for individuals that attended state preschools only") replace;
			};			
			
		eststo clear ;

		mat result_`older'`x' = (C_A_HealthGood_`older'`x', C_A_HealthBad_`older'`x', C_A_HealthAvg_`older'`x', BMI_obese_`older'`x', BMI_overweight_`older'`x') ;

		mat colnames result_`older'`x' = "Good Health" "Bad Health" "Avg Health" "Obese" "Overweight" ;

		mat rownames result_`older'`x' = "`older':Reggio" "`older':`x'" "`older':Difference" 
		"`younger':Reggio" "`younger':`x'" "`younger':Difference" "Difference:Difference" ;

		if `"`school'"' == "Pooled" { ;
		esttab matrix(result_`older'`x', fmt(4)) using did_`older'vs`younger'_`x'`school'2.tex, 
		nomtitles title("Difference in Differences, `older' to `younger' Cohorts") 
		addnotes("Estimates for those that attended any type of preschool in each city") replace ;
		};
		else if `"`school'"' == "Municipal" {;
		esttab matrix(result_`older'`x', fmt(4)) using did_`older'vs`younger'_`x'`school'2.tex, 
		nomtitles title("Difference in Differences, `older' to `younger' Cohorts") 
		addnotes("Estimates for those that attended municipal preschools in each city") replace ;
		};
		
		#delimit cr
		eststo clear  
		matrix drop _all 	
	}
end 


