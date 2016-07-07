* ---------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - Instrumental Variable Regression
* Authors: Pietro Biroli, Chiara Pronzato
* Editors: Jessica Yu Kyung Koh, Anna Ziff
* Created: 02 March 2016
* Edited:  11 March 2016
* ---------------------------------------------------------------------------- *

capture log close
clear all
set more off
set maxvar 32000

* ---------------------------------------------------------------------------- *
* Set directory
/* 
Note: In order to make this do file runable on other computers, 
		create an environment variable that points to the directory for Reggio.dta.
		Those who want to use this code on their computers should set up 
		environment variables named "klmReggio" for klmReggio 
		and "data_reggio" for klmReggio/SURVEY_DATA_COLLECTION/data
		on their computers. 
Note: Install the following commands: dummieslab, outreg2
*/

global klmReggio	: 	env klmReggio		
global data_reggio	: 	env data_reggio

* Prepare the data for the analysis, creating variables and locals
include ${klmReggio}/Analysis/prepare-data.do

cd ${klmReggio}/Analysis/Output/


* Options to only include main_terms
local outregOptionChild	  bracket label dec(3) keep(ReggioAsilo ReggioMaterna xa* xm* Male) sortvar(ReggioAsilo ReggioMaterna xaReggioNone* xaReggioState* xaReggioReli* xaReggioSome* xaParmaMuni* xaPadovaMuni* xmReggioNone* xmReggioState* xmReggioReli* xmReggioSome* xmParmaMuni* xmPadovaMuni* Male) ctitle(" ") //drop(o.* *internr_* *Month_int_* Male* mom* dad* cgRelig* houseOwn* cgReddito*) 
local outregOptionAdol    `outregOptionChild'
local outregOptionAdult   `outregOptionChild'

/* definition of controls: check prepare-data.do */


* ---------------------------------------------------------------------------- *
** Run regressions and save the outputs
log using analysis_instruments, replace 

/* keep track of what happens in the loops
set trace on
set tracedepth 1
*/
foreach group in short long { // run regressions for two different comparison groups: one with municipal-other-none (short), the other with all the school types (muni, reli, state, priv, none -- long)
	foreach age in `school_age_types' { // Asilo or Materna
		local cohort_val = 1
		** MAIN TREATMENT EFFECTS; CHANGE REFERENCE GROUP HERE
		if "`age'" == "Asilo" & "`group'" == "short" {
			local int xa 
			local iv_term           ReggioAsilo
			local omitted_term      xaReggioSome // omitted category
			local other_terms	    xaParmaMuni xaPadovaMuni /// Parma Padova ReggioAsilo 
						            xaParmaSome xaPadovaSome /// xaReggioSome 
						            xaParmaNone xaPadovaNone xaReggioNone 
		}
		else if "`age'" == "Materna" & "`group'" == "short" {
			local int xm
			local iv_term           ReggioMaterna
			local omitted_term      xmReggioSome // omitted category
			local other_terms	    xmParmaMuni xmPadovaMuni /// Parma Padova ReggioMaterna 
						            xmParmaSome xmPadovaSome /// xmReggioSome 
						            xmParmaNone xmPadovaNone xmReggioNone 
		}						
		else if "`age'" == "Asilo" & "`group'" == "long" {
			local int xa 
			local iv_term           ReggioAsilo
			local omitted_term      xaReggioReli // omitted category
			local other_terms	    xaParmaMuni xaPadovaMuni /// Parma Padova ReggioAsilo 
						            xaParmaReli xaPadovaReli /// xaReggioReli /// 
						            xaParmaPriv xaPadovaPriv xaReggioPriv /// 
						            xaParmaNone xaPadovaNone xaReggioNone 
		}
		else if "`age'" == "Materna" & "`group'" == "long" {
			local int xm
			local iv_term           ReggioMaterna
			local omitted_term      xmReggioReli // omitted category
			local other_terms	    xmParmaMuni xmPadovaMuni /// Parma Padova ReggioMaterna 
						            xmParmaStat xmPadovaStat xmReggioStat ///
						            xmParmaReli xmPadovaReli ///xmReggioReli /// 
						            xmParmaPriv xmPadovaPriv xmReggioPriv ///
						            xmParmaNone xmPadovaNone xmReggioNone 
		}
			
		foreach cohort in `cohorts' { // Child, Adol, or Adult 
		di "`cohort'"
			foreach outcome in `out`cohort'' {
				local large_sample_condition largeSample_`age'`cohort'``outcome'_short' == 1
				local outcomelabel : variable label `outcome'


				** Generate large sample (all missing are imputed to zero and converted into dummies)
				quietly reg `outcome' `omitted_term' `other_terms' `Xright' `Xleft' `Xright_Parma' `Xright_Padova' `Xleft_Parma' `Xleft_Padova' if (Cohort_new == `cohort_val'), robust  
				capture gen largeSample_`age'`cohort'``outcome'_short' = e(sample)	
				tab largeSample_`age'`cohort'``outcome'_short'

				** Run regressions and store results into latex
				di "Running the regressions for outcome `outcome' in cohort `cohort'"
				di "1. Only city/age terms"
				reg `outcome' `omitted_term' `other_terms' if `large_sample_condition', robust  
				outreg2 using "${klmReggio}/Analysis/Output/iv_tex`age'`cohort'``outcome'_short'_`group'.tex", ///
							  replace `outregOption`cohort'' tex(frag) addtext(Controls, None) ///
						  addnote("Dependent variable: `outcomelabel'.") //First column has no controls and shows the difference among averages. Second column includes interviewer fixed effects. Third column adds denmographic and family controls. Fourth column also controls for initial conditions (birthweight and prematurity, when present). Fifth column interacts all controls with city-dummies. Sixth column runs the regression only for the Reggio Emilia sample. Final column does not include interviewer fixed effects.")

				di "2. All controls"
				reg `outcome' `omitted_term' `other_terms' `Xright' `Xleft' if `large_sample_condition', robust  
				outreg2 using "${klmReggio}/Analysis/Output/iv_tex`age'`cohort'``outcome'_short'_`group'.tex", append `outregOption`cohort'' tex(frag) addtext(Controls, All)

				di "3. Controls interacted with City"
				reg `outcome' `omitted_term' `other_terms' `Xright' `Xleft' `Xright_Parma' `Xright_Padova' `Xleft_Parma' `Xleft_Padova' if `large_sample_condition', robust 
				outreg2 using "${klmReggio}/Analysis/Output/iv_tex`age'`cohort'``outcome'_short'_`group'.tex", append `outregOption`cohort'' tex(frag) addtext(Controls, Inter)

				/*di "4. Only Reggio"
				reg `outcome' `omitted_term' `other_terms' `Xright' `Xleft' if `large_sample_condition' & Reggio==1, robust  
				outreg2 using "${klmReggio}/Analysis/Output/iv_tex`age'`cohort'``outcome'_short'_`group'.tex", append `outregOption`cohort'' tex(frag) addtext(Controls, Reggio)
				*/
				** Instrumenting
				di "5. IV with controls interacted with City"
				ivregress 2sls  `outcome' `other_terms' (`iv_term' = c.dist`age'*1_Reggio) `Xright' `Xleft' `Xright_Parma' `Xright_Padova' `Xleft_Parma' `Xleft_Padova' if `large_sample_condition', robust 
				outreg2 using "${klmReggio}/Analysis/Output/iv_tex`age'`cohort'``outcome'_short'_`group'.tex", append `outregOption`cohort'' tex(frag) addtext(IV, distance)

				/*di "6. IV only Reggio"
				ivregress 2sls  `outcome' `other_terms' (`iv_term' = c.dist`age'*1_Reggio) `Xright' `Xleft' `Xright_Parma' `Xright_Padova' `Xleft_Parma' `Xleft_Padova' if `large_sample_condition' & Reggio==1, robust 
				outreg2 using "${klmReggio}/Analysis/Output/iv_tex`age'`cohort'``outcome'_short'_`group'.tex", append `outregOption`cohort'' tex(frag) addtext(IV, Reggio)
				*/

				di "7. IV with controls interacted with City"
				ivregress 2sls  `outcome' `other_terms' (`iv_term' = c.dist`age'*1_Reggio##c.numSiblings) `Xright' `Xleft' `Xright_Parma' `Xright_Padova' `Xleft_Parma' `Xleft_Padova' if `large_sample_condition', robust 
				outreg2 using "${klmReggio}/Analysis/Output/iv_tex`age'`cohort'``outcome'_short'_`group'.tex", append `outregOption`cohort'' tex(frag) addtext(IV, distXsib)

				di "8. IV with controls interacted with City"
				ivregress 2sls  `outcome' `other_terms' (`iv_term' = c.dist`age'*1_Reggio score score2) `Xright' `Xleft' `Xright_Parma' `Xright_Padova' `Xleft_Parma' `Xleft_Padova' if `large_sample_condition', robust 
				outreg2 using "${klmReggio}/Analysis/Output/iv_tex`age'`cohort'``outcome'_short'_`group'.tex", append `outregOption`cohort'' tex(frag) addtext(IV, dist score)

			}
			local cohort_val = `cohort_val' + 1
		}
	}
}

log close

***----- General trials, outside of the loops and the locals--------------------------------------------------------------*
/* potential instruments
*Distance
lowess ReggioAsilo distAsiloMunicipal1 if Reggio==1 & Cohort==1
lowess ReggioAsilo distAsiloMunicipal1 if Reggio==1 & Cohort==3
lowess ReggioAsilo distAsiloMunicipal1 if Reggio==1 & Cohort>3

lowess ReggioMaterna distMaternaMunicipal1 if Reggio==1 & Cohort==1
lowess ReggioMaterna distMaternaMunicipal1 if Reggio==1 & Cohort==3
lowess ReggioMaterna distMaternaMunicipal1 if Reggio==1 & Cohort>3


*Score
lowess ReggioAsilo score if Reggio==1 & Cohort==1
lowess ReggioAsilo score if Reggio==1 & Cohort==3
lowess ReggioAsilo score if Reggio==1 & Cohort>3

lowess ReggioMaterna score if Reggio==1 & Cohort==1
lowess ReggioMaterna score if Reggio==1 & Cohort==3
lowess ReggioMaterna score if Reggio==1 & Cohort>3

* Quantiles -- they don't work
* Asilo
capture drop d_a_m_q*
xtile pct = distAsiloMunicipal1, n(5)
tab pct, gen(d_a_m_q)
drop pct d_a_m_q1 //keep the closest ars reference

* Higher order -- they don't work
gen dist2AsiloMunicipal1 = distAsiloMunicipal1^2
gen dist3AsiloMunicipal1 = distAsiloMunicipal1^3


* Materna
capture drop d_m_m_q*
xtile pct = distMaternaMunicipal1, n(5)
tab pct, gen(d_m_m_q)
drop pct d_m_m_q1 //keep the closest ars reference


score score2 
dist175m 
grand_city 
lone_parent 
numSibling 
d_a_m_q*
distAsilo*1 distAsilo*2
distMaterna*1 distMaterna*2

*interactions
c.distAsilo*1##c.childrenSibIn 
c.distAsilo*1##grand_city
c.distAsiloMunicipal1##c.score 
c.distAsiloMunicipal1##otherSib
c.distAsiloMunicipal1##cgReddito_low
c.distAsiloMunicipal1##cgSES_worker
c.distAsiloMunicipal1##cgSES_teacher
c.distAsiloMunicipal1##cgSES_professional
c.distAsiloMunicipal1##cgSES_self
c.distAsiloMunicipal1##momMaxEdu_low
c.distAsiloMunicipal1##momMaxEdu_HS
c.distAsiloMunicipal1##momMaxEdu_middle
c.distAsiloMunicipal1##momMaxEdu_Uni
*

**** First stage 
**Asilo
global z (c.distAsilo*1)##(c.numSibling)#City // momMaxEdu_low cgReddito_low distAsilo*2 

reg ReggioAsilo $someX $z distCenter if Reggio==1 & Cohort==1, robust
reg ReggioAsilo $someX $z distCenter if             Cohort==1, robust

reg ReggioAsilo $someX $z distCenter if Reggio==1 & Cohort==3, robust

reg ReggioAsilo $someX $z distCenter if Reggio==1 & Cohort>3, robust

**Materna
global z c.distMaterna*1##(c.numSibling)#City // momMaxEdu_low cgReddito_low distAsilo*2 

reg ReggioMaterna $someX $z distCenter if Reggio==1 & Cohort==1, robust

reg ReggioMaterna $someX $z distCenter if Reggio==1 & Cohort==3, robust

reg ReggioMaterna $someX $z distCenter if Reggio==1 & Cohort>3, robust


global main xaParmaMuni xaPadovaMuni /// Parma Padova ReggioAsilo /// omitted category: Reggio approach
								xaReggioSome xaParmaSome xaPadovaSome ///
								xaReggioNone xaParmaNone xaPadovaNone

** Second Stage
foreach age in Asilo Materna{
des dist`age'*1
ivregress 2sls childSDQ_score xaParmaMuni xaPadovaMuni xaParmaSome xaPadovaSome xaParmaNone xaPadovaNone xaReggioNone (xaReggioSome  = (c.dist`age'*1)##c.numSibling#City) $fullX if Cohort==1 & Reggio==1, robust 
}

** simple OLS
reg childSDQ_score xaReggioNone xaReggioSome xaParmaMuni xaPadovaMuni xaParmaSome xaPadovaSome xaParmaNone xaPadovaNone $fullX if Cohort==1, robust 
reg childSDQ_score xaReggioNone ReggioAsilo xaParmaMuni xaPadovaMuni xaParmaSome xaPadovaSome xaParmaNone xaPadovaNone $fullX if Cohort==1, robust 

*/
