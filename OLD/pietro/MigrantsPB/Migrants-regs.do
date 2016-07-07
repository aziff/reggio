
*---* Migrant Child
local i=0
foreach var of varlist Migr*_white Migr*_black MigrChildFactor{
local i=`i'+1

local var MigrFriendFig_white
local lablvar: variable label `var'
di "`lablvar'"

eststo eq0: reg `var' ReggioMaterna ReggioAsilo treated Parma Padova CAPI if sampleMigr==1 & Cohort==2, robust // [=] at some point should use logit/probit
outreg2 using MigrChild_`i'.out, replace ctitle("Baseline") title("`lablvar'") 

eststo eq1a: reg `var' ReggioMaterna Parma Padova CAPI if sampleMigr==1 & Cohort==2, robust // [=] at some point should use logit/probit
outreg2 using MigrChild_`i'.out, append ctitle("Baseline") title("`lablvar'") 

eststo eq1b: reg `var' ReggioAsilo Parma Padova CAPI if sampleMigr==1 & Cohort==2, robust // [=] at some point should use logit/probit
outreg2 using MigrChild_`i'.out, append ctitle("Baseline") title("`lablvar'")

eststo eq1c: reg `var' treated Parma Padova CAPI if sampleMigr==1 & Cohort==2, robust // [=] at some point should use logit/probit
outreg2 using MigrChild_`i'.out, append ctitle("Baseline") title("`lablvar'")

eststo eq3a: reg `var' ReggioMaterna Parma Padova $Controls $cgPA $cgmStatus $cgPA $cgmStatus  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle(" + Controls")

eststo eq3b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle(" + Controls")

eststo eq3c: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle(" + Controls")

eststo eq4a: reg `var' ReggioMaterna  Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle(" +mom")

eststo eq4b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle(" +mom")

eststo eq4c: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle(" +mom")

eststo eq5a: reg `var' ReggioMaterna Parma Padova $Controls $cgPA $cgmStatus $Migr_other $xmaterna  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle(" +school")

eststo eq5b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus $Migr_other $xasilo  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle(" +school")

eststo eq5c: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus $Migr_other $xmaterna $xasilo  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle(" +school")

eststo eq6a: reg `var' ReggioMaterna  $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("Reggio Only")

eststo eq6b: reg `var' ReggioAsilo    $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("Reggio Only")

eststo eq6c: reg `var' treated     $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("Reggio Only")

eststo eq7a: reg `var' ReggioMaterna  Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & materna_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("Mun. only")

eststo eq7b: reg `var' ReggioAsilo Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & asilo_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("Mun. only")

eststo eq7b: reg `var' treated Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & (materna_Municipal==1 | asilo_Municipal==1), robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using MigrChild_`i'.out, append ctitle("Mun. only")

esttab eq4a eq4b eq5a eq5b eq6a eq6b eq7a eq7b using MigrChild-`i'.tex, replace $Options ///  eq2 
stats(controls mom school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"Mom beliefs"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($Disp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
}

*---* Migrant Child: Instrumented regression
local i=0
foreach var of varlist Migr*_white Migr*_black MigrChildFactor{
local i=`i'+1

//local var MigrTaste_cat
local lablvar: variable label `var'
di "`lablvar'"

eststo eq0: ivregress 2sls `var' (ReggioMaterna ReggioAsilo treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter distCenter Parma Padova CAPI if sampleMigr==1 & Cohort==2, robust // [=] at some point should use logit/probit
outreg2 using IVMigrChild_`i'.out, replace ctitle("Baseline") title("`lablvar'") 

eststo eq1a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova CAPI if sampleMigr==1 & Cohort==2, robust // [=] at some point should use logit/probit
outreg2 using IVMigrChild_`i'.out, replace ctitle("Baseline") title("`lablvar'") 

eststo eq1b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova CAPI if sampleMigr==1 & Cohort==2, robust // [=] at some point should use logit/probit
outreg2 using IVMigrChild_`i'.out, append ctitle("Baseline") title("`lablvar'")

eststo eq1c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova CAPI if sampleMigr==1 & Cohort==2, robust // [=] at some point should use logit/probit
outreg2 using IVMigrChild_`i'.out, append ctitle("Baseline") title("`lablvar'")

eststo eq3a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle(" + Controls")

eststo eq3b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle(" + Controls")

eststo eq3c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle(" + Controls")

eststo eq4a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2, robust first
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle(" +mom")

eststo eq4b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle(" +mom")

eststo eq4c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle(" +mom")

eststo eq5a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other $xmaterna  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle(" +school")

eststo eq5b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other $xasilo  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle(" +school")

eststo eq5c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other $xmaterna $xasilo  if sampleMigr==1 & Cohort==2, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local school   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle(" +school")

eststo eq6a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("Reggio Only")

eststo eq6b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("Reggio Only")

eststo eq6c: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter  $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & Reggio==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local reggio   "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("Reggio Only")

eststo eq7a: ivregress 2sls `var' (ReggioMaterna =  IV_distMat IV_score IV_m*) distCenter  Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & materna_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("Mun. only")

eststo eq7b: ivregress 2sls `var' (ReggioAsilo =  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & asilo_Municipal==1, robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("Mun. only")

eststo eq7b: ivregress 2sls `var' (treated =  IV_distMat  IV_distAsi IV_score IV_m*) distCenter Parma Padova $Controls $cgPA $cgmStatus $Migr_other if sampleMigr==1 & Cohort==2 & (materna_Municipal==1 | asilo_Municipal==1), robust 
	estadd local controls "Yes", replace
	estadd local mom   "Yes", replace
	estadd local muni     "Yes", replace
outreg2 using IVMigrChild_`i'.out, append ctitle("Mun. only")

esttab eq4a eq4b eq5a eq5b eq6a eq6b eq7a eq7b using IVMigrChild-`i'.tex, replace $Options ///  eq2 
stats(controls mom school reggio muni N r2 , fmt(0 0 0 0 0 0 0 3) ///
labels(`"Controls"' `"SES"' `"School types"' `"Reggio Only"' `"Mun. Only"' `"Observations"' `"\(R^{2}\)"' ) ) ///
keep($Disp) ///
mgroups("`lablvar'"	, pattern(1 0 0 0 0 0 0)  prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span}))
}
