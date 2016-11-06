/*
Project:		Reggio Evaluation
Authors:		Chiara Pronzato, Anna Ziff
Date:			November 5, 2016

This file:		Propensity score matching for all cohorts
				Old results with previous set of outcomes and controls
*/
/*
cap log close

global klmReggio 	:	env klmReggio
global git_reggio	:	env git_reggio
global data_reggio	: 	env data_reggio
global output		= 	"${git_reggio}/Output"
global code			= 	"${git_reggio}/script"

local day=subinstr("$S_DATE"," ","",.)
log using "${code}/psm/PSM`day'.log", text replace

// bring in project-level macros
cd $code
include macros

// prepare variables needed for PSM
cd $data_reggio
use Reggio_prepared, clear


gen nido 		= (asilo == 1)
replace nido 	= . if(asilo > 3)

gen poorBHealth = (lowbirthweight == 1 | birthpremature==1) 

gen  oldsibs 	= 0

forvalues i = 3/10 {
	replace oldsibs = oldsibs + 1 * (Relation`i' == 11 & year`i' < 1994) 
}
replace oldsibs = 1 if oldsibs >= 1 & oldsibs < .

gen 	dadMaxEdu_Uni_F 	= dadMaxEdu_Uni
replace dadMaxEdu_Uni_F = 0 if dadMaxEdu_Uni == . 
gen 	dadMaxEdu_Uni_Miss 	= dadMaxEdu_Uni == .
gen 	momMaxEdu_Uni_F 	= momMaxEdu_Uni
replace momMaxEdu_Uni_F = 0 if momMaxEdu_Uni == .
gen 	momMaxEdu_Uni_Miss 	= momMaxEdu_Uni == .

tab 	cgIncomeCat, g(IncCat_)
gen 	HighInc 			= (IncCat_5==1 | IncCat_6==1) if !mi(cgIncomeCat)
gen 	HighInc_F 			= HighInc
replace HighInc_F 		= 0 if HighInc == .
gen 	HighInc_Miss 		= HighInc == .

gen 	houseOwn_F 			= houseOwn if(houseOwn! = .)
gen 	houseOwn_Miss 		= (houseOwn == .)
replace houseOwn_F 		= 0 if(houseOwn == .)

replace cgRelig 		= . if (cgRelig > 1)
gen 	cgRelig_F 			= cgRelig if (cgRelig != .)
gen 	cgRelig_Miss 		= (cgRelig == .)
replace cgRelig_F 		= 0 if (cgRelig == .)

local to_flip 	difficultiesSit difficultiesInterest difficultiesObey difficultiesEat 		///
				childAsthma_ childAllerg_ childDigest_ childEmot_diag childSleep_diag 		///
				childGums_diag childOther_diag childSnackNo childSnackCan childSnackRoll  	///
				childSnackChips childSnackOther worryMyself

foreach j in  `to_flip' {
	replace `j'= 1-`j'
} 

drop if(ReggioAsilo == . | ReggioMaterna == .)

gen sample1 		= (Reggio == 1)
gen sample_nido2 	= ((Reggio == 1 & ReggioAsilo == 1) 	| (Parma == 1) | (Padova == 1))
gen sample_materna2 	= ((Reggio == 1 & ReggioMaterna == 1) 	| (Parma == 1) | (Padova == 1))
gen sample3 		= (Reggio == 1 	| Parma == 1)
gen sample4 		= (Reggio == 1 	| Padova == 1)
*/

// here

local child_cat_groups	CN S H B 
local adol_cat_groups	CN S H B
local adult_cat_groups 	E W L H N S R

local child_cohorts		Child
local adol_cohorts		Adolescent
local adult_cohorts		Adult30 Adult40 Adult50

local nido_var			ReggioAsilo
local materna_var		ReggioMaterna

foreach group in /*child adol*/ adult { 				// group: children, adol, adults
	foreach school in nido materna {					// school: asilo, materna 
		foreach cohort in ``group'_cohorts' {			// cohort: childeren, adolescent, adults 30s, adults 40s, adults 50s
			
			// store estimates in a local by category
			local est_list 
			foreach cat in ``group'_cat_groups' {		// outcome category (differs by group)			
			
				foreach outcome in ${`group'_outcome_`cat'} { 	// outcome (differs by outcome category)
					
				preserve
					// mean of var
					sum `outcome' if sample1 == 1
					local varmean =  round(r(mean),0.01) 
					
					// get weights
					probit ``school'_var' ${`cohort'_baseline_vars} if Reggio == 1
					
					qui predict pr_``school'_var' if sample_`school'2 == 1
					
					qui gen weight = (1 / pr_``school'_var') if ``school'_var' == 1
					qui replace weight = (1 / (1 - pr_``school'_var')) if ``school'_var' == 0
					
					// use weights
					reg `outcome' ``school'_var' `school' ${`cohort'_baseline_vars} [pweight = weight] if (sample_`school'2 == 1), rob
					est store `outcome'`cat'`cohort'`school'
					
					// store estimates in a local
					local est_list `est_list' `outcome'`cat'`cohort'`school'
					
				restore

				}
				
				est dir
				di "`est_list'"
				
				// output table
				cd ${output}
				# delimit ;
					outreg2 [IQ_factorEAdult30nido]
						using "`cat'_`school'_`cohort'.tex", 
						replace 
						tex(frag) 
						bracket 
						dec(3) 
						ctitle("PSM") 
						keep(``school'_var')
						alpha(.01, .05, .10) 
						sym (***, **, *)
						addtext(Sample, RAvsPP, Mean, `varmean');
				# delimit cr
			}
		}
	}
}

/*
di "*** REGRESSION 6(PSM d&s)" // only children and adolescents
use "$dir/Analysis/chiara&daniela/child_data4July16.dta", clear

qui gen demand = (ReggioAsilo == 1)
qui gen supply = (ReggioAsilo == 1)
//biprobit (supply = score50 Male Age momMaxEdu_Uni_F momMaxEdu_Uni_Miss HighInc_F HighInc_Miss) (demand = cgAsilo_F distAsiloMunicipal1 distanza2 momBornProvince_F dadBornProvince_F momBornProvince_Miss dadBornProvince_Miss Male Age momMaxEdu_Uni_F momMaxEdu_Uni_Miss HighInc_F HighInc_Miss) if(Reggio == 1), partial difficult
biprobit (supply = score75 $controls) (demand = cgAsilo_F distAsiloMunicipal1 distanza2 distanza3 distA_MomBorn distA_oldsibs $controls) if(Reggio == 1), partial difficult

keep if(sampleAsilo2 == 1)

qui predict p11, p11
qui predict p10, p10
qui gen pr_supply = p11+p10
qui predict p01, p01
qui gen pr_demand = p11+p01
qui sum pr_supply pr_demand, d

qui gen weight = 1 /(pr_d*pr_s) if(ReggioAsilo == 1)
qui replace weight = 1 /(1 - pr_d*pr_s) if(ReggioAsilo == 0)

sum weight

reg `varoutcome' ReggioAsilo nido $controls [iweight = weight] if (sampleAsilo2 == 1), rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioAsilo]/_se[ReggioAsilo])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioAsilo])>0{
	     local ++cap //increase by one
	  }
	  if sign(_b[ReggioAsilo])<0{
	     local ++can //increase by one
	  }
	}
	outreg2 using `varoutcome'_asilo_child, append $outregOption ctitle("PSM2") addtext(Sample, RAvsPP, Mean, `varmean')

di "*** REGRESSION 8 (diff-in-diff Reggio + Parma)"

use "$dir/Analysis/chiara&daniela/child_data4July16.dta", clear

keep if(sample3 == 1)
count

qui probit ReggioAsilo $IVnido $controls if(Reggio == 1)
qui predict pr_ReggioAsilo
qui gen weight = (1 / pr_ReggioAsilo) if(ReggioAsilo == 1)
qui replace weight = (1 / (1 - pr_ReggioAsilo)) if(ReggioAsilo == 0)

qui gen ParmaAsilo = ((nido == 1 & asilo_Municipal == 1) & Parma == 1)
qui gen altroAsiloR = ((nido == 1 & ReggioAsilo == 0) & Reggio == 1)
qui gen altroAsiloP = ((nido == 1 & asilo_Municipal == 0) & Parma == 1) //watch-out: Parma and Padova can be confusing here in altroAsiloP
qui gen nidoXreggio = nido*Reggio

reg `varoutcome' ReggioAsilo nido Reggio nidoXreggio asilo_Municipal $controls [iweight = weight] if(sample3 == 1), rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioAsilo]/_se[ReggioAsilo])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioAsilo])>0{
	     local ++cap //increase by one
	  }
	  if sign(_b[ReggioAsilo])<0{
	     local ++can //increase by one
	  }
	}
	outreg2 using `varoutcome'_asilo_child, append $outregOption ctitle("DiD Pr") addtext(Sample, RePr, Mean, `varmean')

di "*check"
reg `varoutcome' ReggioAsilo ParmaAsilo altroAsiloR nido altroAsiloP $controls Parma [iweight = weight] if(sample3 == 1), rob
lincom (ReggioAsilo - altroAsiloR) - (ParmaAsilo - altroAsiloP)

di "*** REGRESSION 10 (diff-in-diff Reggio + Padova)"

use "$dir/Analysis/chiara&daniela/child_data4July16.dta", clear

keep if(sample4 == 1)
count

qui probit ReggioAsilo $IVnido $controls if(Reggio == 1)
qui predict pr_ReggioAsilo
qui gen weight = (1 / pr_ReggioAsilo) if(ReggioAsilo == 1)
qui replace weight = (1 / (1 - pr_ReggioAsilo)) if(ReggioAsilo == 0)

qui gen PadovaAsilo = ((nido == 1 & asilo_Municipal == 1) & Padova == 1)
qui gen altroAsiloR = ((nido == 1 & ReggioAsilo == 0) & Reggio == 1)
qui gen altroAsiloP = ((nido == 1 & asilo_Municipal == 0) & Padova == 1)
qui gen nidoXreggio = nido*Reggio

reg `varoutcome' ReggioAsilo nido Reggio nidoXreggio asilo_Municipal $controls [iweight = weight] if(sample4 == 1), rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioAsilo]/_se[ReggioAsilo])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioAsilo])>0{
	     local ++cap //increase by one
	  }
	  if sign(_b[ReggioAsilo])<0{
	     local ++can //increase by one
	  }
	}
	outreg2 using `varoutcome'_asilo_child, append $outregOption ctitle("DiD Pd") addtext(Sample, RePd, Mean, `varmean')

**CHECK
reg `varoutcome' ReggioAsilo altroAsiloR PadovaAsilo nido $controls Padova [iweight = weight] if(sample4 == 1), rob //altroAsiloP 
lincom (ReggioAsilo - altroAsiloR) - (PadovaAsilo) //(PadovaAsilo - altroAsiloP)


********************************************************************************
di "********************************************************************************"
di "*** SCUOLA MATERNA"

di "*** REGRESSION 1 (OLS REGGIO)"

use "$dir/Analysis/chiara&daniela/child_data4July16.dta", clear

keep if(sample1 == 1)
count

sum `varoutcome'
local varmean =  round(r(mean),0.01) //keep track of the overall mean and put it at the bottom of the tables

reg `varoutcome' ReggioMaterna $controls, rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_child, replace $outregOption ctitle("OLS") addtext(Sample, Reggio, Mean, `varmean') ///
	addnote(Mean = average of the y-variable for the whole sample considered. Sample: Reggio = only respondents in the city of Reggio Emilia. RAvsPrPd = Reggio Approach and all the respondents in Parma and Padova. RePr= all of the respondents in Reggio Emilia and Parma. RePd= all of the respondents in Reggio Emilia and Padova. Estimation Procedure: OLS = Ordinary Least Square; IV = Instrumental variable approach; CF = control function approach, cubic polynomial or residuals. PSM = simple propensity score matching. PSM2 = propensity sore matching using both demand and supply. DiD = differences-in-differences approach, municipal schools vs other schools across different cities)

di "*** REGRESSION 12 (IV REGGIO)"

ivreg2 `varoutcome' $controls (ReggioMaterna = $IVmaterna), robust small
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_child, append $outregOption ctitle("IV") addtext(Sample, Reggio, Mean, `varmean')

di "*** REGRESSION 13  (control function REGGIO)"

qui probit ReggioMaterna $IVmaterna $controls
qui predict pr_ReggioMaterna

qui gen unobs = ReggioMaterna - pr_ReggioMaterna
qui gen unobs2 = unobs^2
qui gen unobs3 = unobs^3

reg `varoutcome' ReggioMaterna unobs* $controls, rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_child, append $outregOption ctitle("CF") addtext(Sample, Reggio, Mean, `varmean')

di "*** REGRESSION 14 (RC in REGGIO vs noRC in Parma and Padova)"

use "$dir/Analysis/chiara&daniela/child_data4July16.dta", clear

reg `varoutcome' ReggioMaterna $controls if (sampleMaterna2 == 1), rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_child, append $outregOption ctitle("OLS") addtext(Sample, RAvsPrPd, Mean, `varmean')

di "*** REGRESSION 15 (PSM classico)"

qui probit ReggioMaterna $IVmaterna $controls if(Reggio == 1)
qui keep if(sampleMaterna2 == 1)

qui predict pr_ReggioMaterna

qui gen weight = (1 / pr_ReggioMaterna) if(ReggioMaterna == 1)
qui replace weight = (1 / (1 - pr_ReggioMaterna)) if(ReggioMaterna == 0)

reg `varoutcome' ReggioMaterna $controls [iweight = weight] if (sampleMaterna2 == 1), rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_child, append $outregOption ctitle("PSM") addtext(Sample, RAvsPP, Mean, `varmean')

di "*** REGRESSION 16(PSM d&s)"

use "$dir/Analysis/chiara&daniela/child_data4July16.dta", clear

qui gen demand = (ReggioMaterna == 1)
qui gen supply = (ReggioMaterna == 1)
//qui biprobit (supply = score50 Male Age momMaxEdu_Uni_F momMaxEdu_Uni_Miss houseOwn_F houseOwn_Miss) (demand = cgAsilo_F distMaternaMunicipal1 momBornProvince_F dadBornProvince_F momBornProvince_Miss dadBornProvince_Miss Male Age houseOwn_F houseOwn_Miss) if(Reggio == 1), partial difficult
biprobit (supply = score75 $controls) (demand = score75 distMaternaMunicipal1 distMaternaReligious1 distMR_relig distM_cgRelig_F $controls) if(Reggio == 1), partial difficult
//qui biprobit (supply = score75 Age Male momMaxEdu_Uni_F momMaxEdu_Uni_Miss dadMaxEdu_Uni_F dadMaxEdu_Uni_Miss houseOwn_F houseOwn_Miss) (demand = distMaternaMunicipal1 distMaternaReligious1 distMR_relig distM_cgRelig_F $controls) if(Reggio == 1), partial difficult iter(100)

qui keep if(sampleMaterna2 == 1)

qui predict p11, p11
qui predict p10, p10
qui gen pr_supply = p11+p10
qui predict p01, p01
qui gen pr_demand = p11+p01
sum pr_supply pr_demand, d

qui gen weight = 1 /(pr_d*pr_s) if(ReggioMaterna == 1)
qui replace weight = 1 /(1 - pr_d*pr_s) if(ReggioMaterna == 0)

sum weight

reg `varoutcome' ReggioMaterna $controls [iweight = weight] if (sampleMaterna2 == 1), rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_child, append $outregOption ctitle("PSM2") addtext(Sample, RAvsPP, Mean, `varmean')

di "*** REGRESSION 17 (OLS Reggio + Parma)"

use "$dir/Analysis/chiara&daniela/child_data4July16.dta", clear
keep if(sample3 == 1)
count

reg `varoutcome' ReggioMaterna $controls Parma, rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_child, append $outregOption ctitle("OLS") addtext(Sample, RePr, Mean, `varmean')

di "*** REGRESSION 18 (diff-in-diff Reggio + Parma)"

use "$dir/Analysis/chiara&daniela/child_data4July16.dta", clear

keep if(sample3 == 1)
count

qui probit ReggioMaterna $IVmaterna $controls if(Reggio == 1)
qui predict pr_ReggioMaterna
qui gen weight = (1 / pr_ReggioMaterna) if(ReggioMaterna == 1)
qui replace weight = (1 / (1 - pr_ReggioMaterna)) if(ReggioMaterna == 0)

qui gen ParmaMaterna = (materna_Municipal == 1 & Parma == 1)
qui gen altraMaternaR = (ReggioMaterna == 0 & Reggio == 1)
qui gen altraMaternaP = (ParmaMaterna  == 0 & Parma ==1)


reg `varoutcome' ReggioMaterna Reggio materna_Municipal $controls [iweight = weight] if sample3==1, rob 
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_child, append $outregOption ctitle("DiD Pr") addtext(Sample, RePr, Mean, `varmean')

**Double check
reg `varoutcome' ReggioMaterna ParmaMaterna altraMaternaR $controls [iweight = weight] if sample3==1, rob  //altraMaternaP 
lincom (ReggioMaterna - altraMaternaR) - (ParmaMaterna) //(ParmaMaterna - altraMaternaP)

di "*** REGRESSION 19 (OLS Reggio + Padova)"

use "$dir/Analysis/chiara&daniela/child_data4July16.dta", clear

keep if(sample4 == 1)
count

reg `varoutcome' ReggioMaterna $controls Padova, rob
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_child, append $outregOption ctitle("OLS") addtext(Sample, RePd, Mean, `varmean')

di "*** REGRESSION 20 (diff-in-diff Reggio + Padova)"

use "$dir/Analysis/chiara&daniela/child_data4July16.dta", clear

keep if(sample4 == 1)
count

qui probit ReggioMaterna $IVmaterna $controls if(Reggio == 1)
qui predict pr_ReggioMaterna
qui gen weight = (1 / pr_ReggioMaterna) if(ReggioMaterna == 1)
qui replace weight = (1 / (1 - pr_ReggioMaterna)) if(ReggioMaterna == 0)

qui gen PadovaMaterna = (materna_Municipal == 1 & Padova == 1)
qui gen altraMaternaR = (ReggioMaterna == 0 & Reggio == 1)
qui gen altraMaternaP = (PadovaMaterna  == 0 & Padova ==1)

reg `varoutcome' ReggioMaterna Reggio materna_Municipal $controls [iweight = weight] if sample4==1, rob //altraMaternaP 
	local pval = (2 * ttail(e(df_r), abs(_b[ReggioMaterna]/_se[ReggioMaterna])))
	if `pval'<0.1{ //results significant at 10%
	  if sign(_b[ReggioMaterna])>0{
	     local ++cmp //increase by one
	  }
	  if sign(_b[ReggioMaterna])<0{
	     local ++cmn //increase by one
	  }
	}
	outreg2 using `varoutcome'_materna_child, append $outregOption ctitle("DiD Pd") addtext(Sample, RePd, Mean, `varmean')

**CHECK
reg `varoutcome' ReggioMaterna PadovaMaterna altraMaternaR $controls [iweight = weight] if sample4==1, rob  //altraMaternaP 
lincom (ReggioMaterna - altraMaternaR) - (PadovaMaterna) //(PadovaMaterna - altraMaternaP)

di "----------------------- `cap' `can' `cmp' `cmn' --------------------"
matrix Signcount[`row',1] = `cap' 
matrix Signcount[`row',2] = `can' 
matrix Signcount[`row',3] = `cmp' 
matrix Signcount[`row',4] = `cmn' 
matrix list Signcount
local ++row
}

/* save the matrix in an excel sheet
putexcel set Signcount.xlsx, sheet(children) modify
putexcel B3 = matrix(Signcount)
*/

log close
