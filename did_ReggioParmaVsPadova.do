
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
	- School must be one of Pooled Municipal

Examples:

. DiffDiff Age50 Children Pooled

. DiffDiff Age30 Adolescent Municipal
***********************************************************************/

capture which estout      	// Checks system for estout
if _rc ssc install estout   // If not found, installs estout
capture which diff			// Checks system for diff
if _rc ssc install diff 	// CIf not found, installs diff

quietly{

capture program drop DiffDiff
program DiffDiff, eclass
version 13
args older younger school
local covariates "Male CAPI numSiblings dadMaxEdu_Uni dadMaxEdu_Grad momMaxEdu_Grad"
	if `"`older'"' == "Age50" & `"`younger'"' == "Age40" {
		replace Age50 = 0 if Cohort == 6
		replace Age50 = 1 if Cohort == 5
		}
	else if `"`older'"' == "Age50" & `"`younger'"' == "Age30" {
		replace Age50 = 0 if Cohort == 6
		replace Age50 = 1 if Cohort == 4
		}
	else if `"`older'"' == "Age40" & `"`younger'"' == "Age30" {
		replace Age40 = 0 if Cohort == 5
		replace Age40 = 1 if Cohort == 4
		}

	if `"`school'"' == "Pooled" {
	replace Padova = 0 if City == 1 & maternaType != 0
	replace Padova = 0 if City == 2 & maternaType != 0
	replace Padova = 1 if City == 3 & maternaType != 0
	}
	else if `"`school'"' == "Municipal" {
	replace Padova = 0 if City == 1 & maternaType == 1
	replace Padova = 0 if City == 2 & maternaType == 0
	replace Padova = 1 if City == 3 & maternaType == 1
	}
	
	#delimit ;
	
	foreach x in Padova {;
		
		foreach i in IQ_v1 IQ_score IQ_factor satFamily unsatFamily satneutralFamily {;
			
		eststo: quietly diff `i', period(`older') treated(`x') cov(`covariates') ;

		mat `i'_`older'`x' = (r(mean_c0) \ r(mean_t0) \ r(diff0) \ r(mean_c1) \ r(mean_t1) \ r(diff1) \ r(did)) ;

		};
		
		if `"`school'"' == "Pooled" { ;
			esttab using `older'_`x'vs`younger'_`school'1_C.tex, b(4) se(4) star nonumbers noobs notes nocons booktabs 
			mtitles("IQ rank" "IQ score" "IQ factor" "Family Sat." "Family Dis." "Family Neutral")
			coeflabels(`older' "Cohort FE" `x' "City FE" __000002 "Diff-in-Diff" Male "Male Dummy" numSiblings "No. of Siblings" dadMaxEdu_Uni "Father Univ." dadMaxEdu_Grad "Father HS" momMaxEdu_Grad "Mother HS")
			title("Reggio and Parma Combined vs. `x', Comparing changes for `older' cohorts")
			addnotes("Estimates shown are for individuals that attended any preschool, regardless of type") replace;
			}; 
		else if `"`school'"' == "Municipal" {;
			esttab using `older'_`x'vs`younger'_`school'1_C.tex, b(4) se(4) star nonumbers noobs notes nocons booktabs 
			mtitles("IQ rank" "IQ score" "IQ factor" "Family Sat." "Family Dis." "Family Neutral")
			coeflabels(`older' "Cohort FE" `x' "City FE" __000002 "Diff-in-Diff" Male "Male Dummy" numSiblings "No. of Siblings" dadMaxEdu_Uni "Father Univ." dadMaxEdu_Grad "Father HS" momMaxEdu_Grad "Mother HS")
			title("Reggio and Parma Combined vs. `x', Comparing changes for `older' cohorts") 
			addnotes("Estimates shown are for individuals that attended municipal preschools only") replace;
			};
			
		eststo clear ;

		mat result_`older'`x' = (IQ_v1_`older'`x', IQ_score_`older'`x', IQ_factor_`older'`x', 
		satFamily_`older'`x', unsatFamily_`older'`x', satneutralFamily_`older'`x') ;

		mat colnames result_`older'`x' = "IQ rank" "IQ score" "IQ factor" "Family Sat" "Family Dissat" "Family Neutral" ;

		mat rownames result_`older'`x' = "`older':Combined" "`older':`x'" "`older':Difference" 
		"`younger':Combined" "`younger':`x'" "`younger':Difference" "Difference:Difference" ;

		if `"`school'"' == "Pooled" { ;
		esttab matrix(result_`older'`x', fmt(4)) using did_`older'vs`younger'_`x'`school'_C.tex, 
		nomtitles title("Difference in Differences, `older' to `younger' Cohorts") 
		addnotes("Estimates for those that attended any type of preschool in each city") replace ;
		};
		else if `"`school'"' == "Municipal" {;
		esttab matrix(result_`older'`x', fmt(4)) using did_`older'vs`younger'_`x'`school'_C.tex, 
		nomtitles title("Difference in Differences, `older' to `younger' Cohorts") 
		addnotes("Estimates for those that attended municipal preschools in each city") replace ;
		};

		
	foreach h in C_A_HealthGood C_A_HealthBad C_A_HealthAvg BMI_obese BMI_overweight {;
			
		eststo: quietly diff `h', period(`older') treated(`x') cov(`covariates') ;

		mat `h'_`older'`x' = (r(mean_c0) \ r(mean_t0) \ r(diff0) \ r(mean_c1) \ r(mean_t1) \ r(diff1) \ r(did)) ;

		};
		
		if `"`school'"' == "Pooled" { ;
			esttab using `older'_`x'vs`younger'_`school'2_C.tex, b(4) se(4) star nonumbers noobs notes nocons booktabs 
			mtitles("Good Health" "Bad Health" "Avg Health" "Obese" "Overweight")
			coeflabels(`older' "Cohort FE" `x' "City FE" __000002 "Diff-in-Diff" Male "Male Dummy" numSiblings "No. of Siblings" dadMaxEdu_Uni "Father Univv." dadMaxEdu_Grad "Father HS" momMaxEdu_Grad "Mother HS")
			title("Reggio and Parma Combined vs. `x', Comparing changes for `older' cohorts")
			addnotes("Estimates shown are for individuals that attended any preschool, regardless of type") replace;
			}; 
		else if `"`school'"' == "Municipal" {;
			esttab using `older'_`x'vs`younger'_`school'2_C.tex, b(4) se(4) star nonumbers noobs notes nocons booktabs 
			mtitles("Good Health" "Bad Health" "Avg Health" "Obese" "Overweight")
			coeflabels(`older' "Cohort FE" `x' "City FE" __000002 "Diff-in-Diff" Male "Male Dummy" numSiblings "No. of Siblings" dadMaxEdu_Uni "Father Univ." dadMaxEdu_Grad "Father HS" momMaxEdu_Grad "Mother HS")
			title("Reggio and Parma Combined vs. `x', Comparing changes for `older' cohorts") 
			addnotes("Estimates shown are for individuals that attended municipal preschools only") replace;
			};
			
		eststo clear ;

		mat result_`older'`x' = (C_A_HealthGood_`older'`x', C_A_HealthBad_`older'`x', C_A_HealthAvg_`older'`x', BMI_obese_`older'`x', BMI_overweight_`older'`x') ;

		mat colnames result_`older'`x' = "Good Health" "Bad Health" "Avg Health" "Obese" "Overweight" ;

		mat rownames result_`older'`x' = "`older':Combined" "`older':`x'" "`older':Difference" 
		"`younger':Combined" "`younger':`x'" "`younger':Difference" "Difference:Difference" ;

		if `"`school'"' == "Pooled" { ;
		esttab matrix(result_`older'`x', fmt(4)) using did_`older'vs`younger'_`x'`school'2_C.tex, 
		nomtitles title("Difference in Differences, `older' to `younger' Cohorts") 
		addnotes("Estimates for those that attended any type of preschool in each city") replace ;
		};
		else if `"`school'"' == "Municipal" {;
		esttab matrix(result_`older'`x', fmt(4)) using did_`older'vs`younger'_`x'`school'2_C.tex, 
		nomtitles title("Difference in Differences, `older' to `younger' Cohorts") 
		addnotes("Estimates for those that attended municipal preschools in each city") replace ;
		};
		
		eststo clear ; 
		
	foreach e in votoMaturita votoUni highschoolGrad MaxEdu_Uni MaxEdu_Grad{;
			
		eststo: quietly diff `e', period(`older') treated(`x') cov(`covariates') ;

		mat `e'_`older'`x' = (r(mean_c0) \ r(mean_t0) \ r(diff0) \ r(mean_c1) \ r(mean_t1) \ r(diff1) \ r(did)) ;

		};
		
		if `"`school'"' == "Pooled" { ;
			esttab using `older'_`x'vs`younger'_`school'3_C.tex, b(4) se(4) star nonumbers noobs notes nocons booktabs 
			mtitles("HS Grade" "Uni Grade" "Graduate HS" "Graduate Uni" "Graduate Grad Sch")
			coeflabels(`older' "Cohort FE" `x' "City FE" __000002 "Diff-in-Diff" Male "Male Dummy" numSiblings "No. of Siblings" dadMaxEdu_Uni "Father Univv." dadMaxEdu_Grad "Father HS" momMaxEdu_Grad "Mother HS")
			title("Reggio and Parma Combined vs. `x', Comparing changes for `older' cohorts")
			addnotes("Estimates shown are for individuals that attended any preschool, regardless of type") replace;
			}; 
		else if `"`school'"' == "Municipal" {;
			esttab using `older'_`x'vs`younger'_`school'3_C.tex, b(4) se(4) star nonumbers noobs notes nocons booktabs 
			mtitles("HS Grade" "Uni Grade" "Graduate HS" "Graduate Uni" "Graduate Grad Sch")
			coeflabels(`older' "Cohort FE" `x' "City FE" __000002 "Diff-in-Diff" Male "Male Dummy" numSiblings "No. of Siblings" dadMaxEdu_Uni "Father Univ." dadMaxEdu_Grad "Father HS" momMaxEdu_Grad "Mother HS")
			title("Reggio and Parma Combined vs. `x', Comparing changes for `older' cohorts") 
			addnotes("Estimates shown are for individuals that attended municipal preschools only") replace;
			};
			
		eststo clear ;

		mat result_`older'`x' = (C_A_HealthGood_`older'`x', C_A_HealthBad_`older'`x', C_A_HealthAvg_`older'`x', BMI_obese_`older'`x', BMI_overweight_`older'`x') ;

		mat colnames result_`older'`x' = "HS Grade" "Uni Grade" "Graduate HS" "Graduate Uni" "Graduate Grad Sch" ;

		mat rownames result_`older'`x' = "`older':Combined" "`older':`x'" "`older':Difference" 
		"`younger':Combined" "`younger':`x'" "`younger':Difference" "Difference:Difference" ;

		if `"`school'"' == "Pooled" { ;
		esttab matrix(result_`older'`x', fmt(4)) using did_`older'vs`younger'_`x'`school'3_C.tex, 
		nomtitles title("Difference in Differences, `older' to `younger' Cohorts") 
		addnotes("Estimates for those that attended any type of preschool in each city") replace ;
		};
		else if `"`school'"' == "Municipal" {;
		esttab matrix(result_`older'`x', fmt(4)) using did_`older'vs`younger'_`x'`school'3_C.tex, 
		nomtitles title("Difference in Differences, `older' to `younger' Cohorts") 
		addnotes("Estimates for those that attended municipal preschools in each city") replace ;
		};
		
		eststo clear ; 
		
	};
end ;

#delimit cr

}
