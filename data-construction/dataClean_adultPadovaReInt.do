clear all
set more off
capture log close

/*
Author: Pietro Biroli (biroli@uchicago.edu)
Purpose: Clean the Adult dataset of the Reggio Project

This Draft: 19 June 2014

Note: The variable names are related to the number of the questions
      in the CAPI version of the questionnaire. See the file: QuestionnaireDOXA/adults.D

	  I am renaming the variables keep this convention:
	  - I try to use the camelCaseNamingConvention
	  - All the mother-related variables begin with 'mom'
	  - All the father-related variables begin with 'dad'
	  - All the other variables (without a particular prefix) are related to the main respondent
	  - Not all the variables will be renamed
	  - I try to name the variables in English, even if the labels are usually in Italian;
	    as an execption, I will use the name "asilo" to refer to infant-toddler centers and the name
		"materna" to refer to preschool.
	  
	  For more description of the dataset, the old and new names, the section of the dataset
	  see the file data/sumStat_adult.xlsx
	  
	  [=] Signal questions to be addressed
*/

/*-*-* directory: keep global directory from dataClean_all.do unless otherwise needed
 local dir "C:\Users\Pietro\Documents\ChicaGo\Heckman\ReggioChildren\data_survey\data"
 local dir "/mnt/ide0/share/klmReggio/data_survey/data"
 local dir "/mnt/ide0/home/biroli/ChicaGo/Heckman/ReggioChildren/data_survey/data"

cd "`dir'"
*/
* log using dataClean_adultPadovaReInt, replace

*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* 
*-* Integrating the names and addresses 
*-* of the schools 
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
//import excel "./adults_original.raw/11174_ADULTI_RECUPERI_APERTE_INDIRIZZI_NIDO_MATERNA_12giu.xls", sheet("DATIBT") firstrow clear
import excel "./adults_original.raw/11174_ADULTI_RECUPERI_APERTE_INDIRIZZI_NIDO_MATERNA_16giu.xls", sheet("DATIBT") firstrow clear
save adultVerbatim.dta, replace

//import excel "./adults_original.raw/11174_ADULTI_RECUPERI_APERTE_FINALI_Altro_12GIU.xls", sheet("Aperte") firstrow clear
import excel "./adults_original.raw/11174_ADULTI_RECUPERI_APERTE_FINALI_ALTRO_CASI_379.xls", sheet("Aperte") firstrow clear
destring _all, replace
drop COD* Coordinate* RIC // This is useless, confirmed by DOXA
tab ETICHETTA
drop ETICHETTA

reshape wide @VERBATIM, i(INTNR) j(N_DOM_APERTA) string
des *VERBATIM

capture gen V32240VERBATIM=""
capture gen V32371VERBATIM=""
capture gen V40190VERBATIM=""


rename V30001VERBATIM V30001_open
rename V30020VERBATIM V30020_open
rename V31180VERBATIM V31180_open
rename V32240VERBATIM V32240_open
rename V32250VERBATIM V32250_open
rename V32340VERBATIM V32340_open
rename V32360VERBATIM V32360_open
rename V32371VERBATIM V32371_open
rename V2VERBATIM V2_open
rename V37220VERBATIM V37220_open
rename V37230VERBATIM V37230_open
rename V37240VERBATIM V37240_open
rename V40190VERBATIM V40190_open
rename V43140VERBATIM V43140_open
rename V43175VERBATIM V43175_open
rename V44130VERBATIM V44130_open
rename V45260VERBATIM V45260_open
rename V46110VERBATIM V46110_open
rename V52111VERBATIM V52111_open
rename V52121VERBATIM V52121_open
rename V52180VERBATIM V52180_open
rename V52220VERBATIM V52220_open

label var  V30001_open "Who is the head of household?"
label var  V30020_open "Do you own or rent?"
label var  V31180_open "Why did you decide not to continue your studies?"
label var  V32240_open "What aspects of the infant-toddler center do you remember as being most important?" 
label var  V32250_open "What aspects of preschool do you remember as being most important?" 
label var  V32340_open "Which course of high school he attended?"
label var  V32360_open "What was the major of your highest qualification?"
label var  V32371_open "Other university, specify:"
label var  V2_open "Can you tell me the name of your current profession or occupation?"
label var  V37220_open "Your child follows extracurricular courses..."
label var  V37230_open "Who usually brings your child to school?"
label var  V37240_open "Who usually goes to get your child at school?"
label var  V40190_open "Usually, what do you eat between meals?"
label var  V43140_open "Are you part of a club or organization (such as a sports team, a theater company or entertainment, neighborhood association, a party etc ...)?"
label var  V43175_open "Are you part of a social network?"
label var  V44130_open "What is your main source of stress?"
label var  V45260_open "Are there foreigners in the groups that you attend?"
label var  V46110_open "As for your current job (or the previous one), what is the easiest way for you to report your wages before taxes (gross salary) per hour, per day, per week, per month?"
label var  V52111_open "The interviewee sought clarification on a few questions. To what questions?"
label var  V52121_open "Do you think that the respondent was reluctant to answer a few questions? To what questions?"
label var  V52180_open "Do you have other comments to write?"
label var  V52220_open "The module should have be self-completed by the respondent without any help from your side. Please tell us, why did this not happen?"

rename INTERVISTATORE internr

merge 1:1 INTNR CITTA using adultVerbatim, gen(_mergeSchoolNames)

/* NOTE: this has to be the same as merging only using the INTNR: double check that all variables are correct
merge 1:1 INTNR using adultVerbatim, gen(_mergeSchoolNames)
*/
rename INTNR intnr //for merging later to the SPSS data

foreach var in V32140 V32150 V32200 V32210 {
	rename `var' `var'_Verbatim
}
corr internr ID_Inter // CHECK they should be the same
replace internr = ID_Inter if internr == .
drop ID_Inter
save adultVerbatim.dta, replace

*-* THE SPSS DATASET
// use ./adults_original.raw/S11174Adulti12Giu.dta, clear //--> new set of interviews from DOXA, run separately
use ./adults_original.raw/S11174Adulti16Giu.dta, clear //--> new set of interviews from DOXA, run separately

destring _all, replace

* merge with the School Names and Addresses
merge 1:1 intnr using adultVerbatim.dta, gen(_mergeVerbatim)
tab _merge*, missing // CHECK
gen flagVerbatim = (_mergeVerbatim == 2) //[=] there should be no data coming only from the excel files, but there are 16 interviewers who didn't have any interviews
list intnr internr if flagVerbatim==1
drop if _mergeVerbatim==2 //[=] keep only the ones we have data on
drop flagVerbatim

foreach var in V32140 V32150 V32200 V32210 {
	tab `var' `var'_Verbatim, miss // [=] CHECK: they should be the same, but there's a problem with V32200
}

egen CITTA_XLS = group(CITTA) 
replace CITTA_XLS = 4-CITTA_XLS
tab CITTA*
drop CITTA
label define City 1 "Reggio" 2 "Parma" 3 "Padova"
label values CITTA_XLS City

rm adultVerbatim.dta

compress
save ReggioAdultPadovaReInt.dta, replace

capture log close
