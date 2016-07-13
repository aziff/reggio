clear all
set more off
capture log close

/*
Author: Pietro Biroli (biroli@uchicago.edu)
Purpose: See the effect of interviewer characteristics

This Draft: 12 Feb 2014 -- Lincoln's birthday
*/

/*** directory: keep global directory from dataClean_all.do unless otherwise needed
 local dir "C:\Users\Pietro\Documents\ChicaGo\Heckman\ReggioChildren\SURVEY_DATA_COLLECTION\data"
 local dir "/mnt/ide0/share/klmReggio/SURVEY_DATA_COLLECTION/data"
 local dir "/mnt/ide0/home/biroli/ChicaGo/Heckman/ReggioChildren/SURVEY_DATA_COLLECTION/data"

cd `dir'
*/
cd interviewers
* log using interviewers, replace

global regression = 0 //=1 if want to run regression of interviewers effects

*-* Get the information of the interviewers
import excel "reggio children-AGGIUNTA INTERVISTATORI-14MARZO2014.xls", sheet("stataImport") firstrow clear
drop if internr>=. // empty rows at the end
destring _all, replace
compress
save interviewers.dta, replace

label var Age "interviewer Age"
label var Gender "Interviwer gender"

encode Gender, gen(Female)
replace Female = 2-Female
drop Gender

tab Education
gen     education = 0 if strpos(Education,"MEDIA")>0
replace education = 1 if strpos(Education,"SUPERIORE")>0
replace education = 2 if strpos(Education,"SENZA")>0
replace education = 3 if strpos(Education,"CON LAUREA")>0
replace education = 3 if Education == "LAUREA"
tab Education education, miss //CHECK there should be no missing
drop Education
label define education 0 "Middle School" 1 "High School" 2 "Drop College" 3 "College"
label values education education
label var education "Education of the interviewer"

tab TipoDiCollaborazione
gen contractTemp = 1 if strpos(TipoDiCollaborazione,"PROGETTO")>0
replace contractTemp = 0 if strpos(TipoDiCollaborazione,"IVA")>0
tab TipoDiCollaborazione contractTemp, miss
drop TipoDiCollaborazione 
label var contractTemp "Interviewer on temporary contract (a progetto)"

tab Residence
gen     local = 1 if strpos(lower(Residence),"local" )>0
replace local = 0 if strpos(lower(Residence),"no" )>0
replace local = 0 if local >=.
tab Residence local
label var local "Interviewer is local"
drop Residence

gen student = (lower(MainOccupation)=="student")
gen inter = (lower(MainOccupation)=="interviewer")
gen employee = (lower(MainOccupation)=="employee")
label var student "Interviewer is a student"
label var inter "Interviewer does this as main job"
label var employee "Interviewer is employee as main job"
gen temp1 = City
foreach var in MainOccupation City Cohort { //Female
egen temp = group(`var'), label lname(`var')
drop `var'
rename temp `var'
}
replace City = 4 - City // So that Reggoio is 1, Parma 2, Padova 3
label drop City
label define City 1 "Reggio" 2 "Parma" 3 "Padova"
tab City temp1, miss
drop temp1
label var City "Main city interviewer went to"

gen Nprojects = (length(MainProjects) - length(subinstr(MainProjects, "-", "",.))) / length("-")
replace Nprojects = Nprojects + 1
// browse MainProjects Nprojects
label var Nproject "number of projects the interviewer is working on"
rename CollaborazioneConDoxa yeardoxa
replace yeardoxa = 2014-yeardoxa //count the number of years with doxa
label var yeardoxa "Number of years working with Doxa"

rename Cohort temp
egen Cohort = group(temp)
tab Cohort temp, miss // CHECK no miss
drop temp
label define Cohort1 1 "ado+child" 2 "adults" 3 "all" 4 "Pilot"
label values Cohort Cohort1
label var Cohort "Children+ado, adults, or both"

*-* Rename: all variable should begin with inter_ 
foreach var of varlist yeardoxa-Cohort{
rename `var' inter_`var'
}

save interviewers.dta, replace

if $regression==1{
/*-* join with the Reggio Data
do ../dataClean_all.do
cd interviewers
*/
use ../Reggio.dta, clear
capture drop inter_*

*create dummies
foreach var in house cgmStatus cgPA hhPA{
 dummieslab `var', template(@_`var') truncate(23)
}
recode asilo materna (2 3 = 0)

//collapse it to merge with the interviewer data
global JacobsChild Male Age cgAge famSize cgMarried cgEmpl cgHouseWife houseOwn cgHealthPerc cgBMI ///
              cgHSgrad dadHSgrad cgIncome25000 IQ_score likeSchool likeLit likeMath childHealthPerc childFruitDaily childBMI // cgUni dadUni 
des $JacobsChild

global JacobsAdult childrenNum Married Empl HouseWife /// numMarriage Age houseOwn 
              HSgrad Uni votoMaturita votoUni Income25000 HrsWork HealthPerc BMI FruitDaily sportTwice SmokeEver Stressed Satisfied ///
	      volunteer Friends // IQ_score 
des $JacobsAdult

collapse (count) intnr (mean) City CAPI childrenSibTot children0_18 *_house Migrant momAge dadAge *_cgmStatus *_cgPA *_hhPA /// 
				cgMaxEdu momMaxEdu dadMaxEdu asilo asiloStat asiloCom asiloPub asiloRel asiloPriv asiloDK ///
				asiloBegin asiloEnd materna maternaStat maternaMuni maternaPubb maternaReli maternaPriv ///
				maternaDK maternaBegin maternaEnd ///
				$JacobsChild $JacobsAdult ///
			, by(internr)

rename intnr totInterviews
*merge with the information from the interviewers
merge 1:1 internr using interviewers.dta
drop if _merge==2 // there are some from using: we have interviewer info, but they didn't do any useful interview

** Run some regressions
foreach var in edu MainOccu Cohort {
 dummieslab inter_`var', template(`var'_@)
}
gen inter_Age2 = inter_Age^2

**effect of interviewer chracteristcs on total number of interviews:
reg totInt inter_Age edu_College inter_student inter_inter inter_contract inter_local inter_Female inter_Nprojects inter_yeardoxa Age Cohort_adochild Cohort_adults , robust
outreg2 using interviewers_effect.out, brack se replace nolabel aster

foreach var of varlist CAPI-Friends{
	di "Effect of interviewer chracteristcs on `var'"
	reg `var' inter_Age edu_College inter_student inter_inter inter_contract inter_local inter_Female inter_Nprojects inter_yeardoxa Age Cohort_adochild Cohort_adults [aweight=totInt], robust 
	outreg2 using interviewers_effect.out, brack se append nolabel aster
} // end of fore
} // end of if $regression
capture log close

cd ..
cd $dir
