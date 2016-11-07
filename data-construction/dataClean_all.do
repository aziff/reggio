clear all
set more off
capture log close

/*
Author: Pietro Biroli (pietrobiroli@gmail.com)
Purpose:
-- Merge the children, adolescent, and adult data into a common dataset + add interviewers and schoolType_manual data
-- Create some common variables (e.g. treatment group etc.)
-- Quality check on some particular variables with unexpected averages 

This Draft: 19 July 2016

Input: 	ReggioChild.dta  --> see dataClean_child.do
        ReggioAdo.dta    --> see dataClean_ado.do
		ReggioAdult.dta  --> see dataClean_adult.do (+Pilot, +PadovaReInt)
		interviewers.dta --> see interviewers.do
		ReggioAll_SchoolNames_manual --> see NamesManual.do


Output:	Reggio.dta --> single dataset with child+migrant+ado
	Quality-Checks for strange results --> if $check == 1

	[=] Signal questions to be addressed

I am renaming the variables keep this convention:
  - I try to use the camelCaseNamingConvention
  - All the mother-related variables begin with 'mom'
  - All the father-related variables begin with 'dad'
  - All of the variables related to the caregiver begin with 'cg' 
			(note: the second respondent is the caregiver; not always it was the mother)
  - All the variables that begin with 'child' are the care-giver answer to questions pertaining to the child
  - All the other variables (without a particular prefix) are related to the child
  - I try to name the variables in English, even if the labels are usually in Italian;
    as an execption, I will use the name "asilo" to refer to infant-toddler centers and the name
	"materna" to refer to preschool.
  - *bin refers to a binary variable created to make a dummy out of a continuous / more complex variable
  - *cat refers to a categorial variable created to simply a continuous / more complex variable

*/

global check    = 0   // = 1 --> do the quality-checks, = 0 skip that section
global notInter = 0   // = 1 --> do the section on preschool-attendance of not-interviewed , = 0 skip that section

*** directory
global dir : env klmReggio

global datadir "$dir/data_survey/data"
cd "$datadir"

* log using dataClean_all, replace

if 1==1 { // 1) Create common data Reggio.dta
/* ================ Merging the datasets ================ */

*
do $dir/Analysis/data-construction/dataClean_child.do
do $dir/Analysis/data-construction/dataClean_ado.do
do $dir/Analysis/data-construction/dataClean_adultPilot.do
do $dir/Analysis/data-construction/dataClean_adultPadovaReInt.do
do $dir/Analysis/data-construction/dataClean_adult.do
do $dir/Analysis/data-construction/dataClean_interviewers.do
do $dir/Analysis/data-construction/dataClean_namesManual.do
//do $dir/Analysis/data-construction/dataClean_distances.do
//do $dir/Analysis/data-construction/dataClean_instruments.do
*


cd "$datadir"
*========* Append all the different datasets
use ReggioChild.dta, clear
append using ReggioAdo.dta 
append using ReggioAdult.dta
// append using ReggioAdultPilot.dta, generate(Pilot) force //done at the end

tab Cohort PadovaReinterview, miss
tab Cohort interPadova, miss

replace PadovaReinterview = 0 if PadovaReinterview ==.
replace interPadova = 0 if interPadova == .

tab Cohort PadovaReinterview, miss
tab Cohort interPadova, miss

capture drop source
gen source = 1 if PadovaReinterview!=1 & interPadova!=1 // Original sample without the 3-strange-interviwers from Padova
replace source = 2 if interPadova==1 //3-strange interviewers from Padova that we don't trust
replace source = 3 if PadovaReinterview==1 //re-interviews in Padova
//replace source = 0 if Pilot==1 // August 2012 Pilot
label define source 0 "Pilot" 1 "Original" 2 "Strange Padova" 3 "Re-interviews Padova", replace
label values source source
label var source "Source of the data"
tab source, miss


*========* Merge with interviewers data
merge m:1 internr using interviewers/interviewers.dta, gen(_mergeInter)
drop if _mergeInter == 2  // there are some from using: we have interviewer info, but they didn't do any useful interview

/* -----------Manual Check of Preschool Names and Addresses 
saveold Reggio.dta, replace
use Reggio_all.dta, clear
*-* extract the names and address and cross-refernce them with the list of schools to assign the correct school type
sort City Cohort intnr internr
keep internr intnr Cohort City *_self *Location* source // *Multiple 
* reshape so that asilo_address and materna_address are the same column --> easier for searching
reshape long @Stat_self @Muni_self @Pubb_self @Reli_self @Priv_self @DK_self @Type_self ///
             @Location @Location_name @Location_address flag@Type_self @Multiple /// 
	         flag@Multiple, i(intnr) j(school) string ///@Type_manualFull @Type_manual @Type2_manual @NotCity @name_manual flag@Accuracy

rename Location_name name
rename Location_address address
gen Type_manualFull = "Non Frequentato" if Type_self == 0
foreach var in name address{
	replace `var' = "" if `var'=="."
	replace `var' = subinstr(`var',";;",";",.)
	replace `var' = subinstr(`var',";;",";",.)
	replace `var' = subinstr(`var',";;",";",.)
	replace `var' = subinstr(`var',";;",";",.)
	replace `var' = "" if `var'==";"
}
replace Type_manualFull = "No Info" if (name=="" & address=="") & Type_manualFull==""
order internr intnr Cohort City Stat Muni Pubb Reli Priv DK Type_self Location name address flagType Multiple school Type_manualFull flagMultiple source

export excel using "ReggioAll_SchoolNames.xlsx" if Type_manualFull=="", sheet("ReggioAll_SchoolNames") firstrow(variables) replace
export excel using "temp.xlsx"                  if Type_manualFull!="", sheet("NoInfo") firstrow(variables) replace

*-* import the manually coded preschool_type
do $dir/Analysis/data-construction/NamesManual.do

*/

*========* Merge with manual-preschool-type
merge 1:1 intnr using ReggioAll_SchoolNames_manual, gen(_mergeManual) //CHECK should merge perfectly, but for those 2 "fake" adolescents in Parma
tab source_manual if _mergeManual==2 //CHECK: should only be fake or pilot
drop if intnr == 37712200 //& internr == 4086
drop if intnr == 37724400 //& internr == 4088
drop if source_manual == "Pilot"
tab _mergeManual
drop source_manual

// create a single school-type merging the information from the manual and self-reported type
gen asilo_Attend = (asilo==1) if asilo<.
label var asilo_Attend "Respondent attended infant-toddler-center"

gen materna_Attend = (materna==1) if materna<. //this is redundant
label var asilo_Attend "Respondent attended preschool"

tab asiloType_self asiloType_manual
tab asiloType_self asiloType_manual, miss
tab asiloType_self asiloType_manual, row
tab asiloType_self asiloType_manual if (asiloType_manual>0 & asiloType_manual<5)  , row // This table goes in the report  --> see the excel file: \SURVEY_DATA_COLLECTION\dataReggioAll_SchoolNames_manual.xlsx

tab asiloType_self City if asiloType_manual>=10
* [=] THERE ARE 67 PEOPLE WHO SELF-REPORT HAVING GONE A **STATE** ASILO NIDO, WHICH DON'T EXIST. 
* I FORCE THEM TO BE MUNICIPAL. 13 OF THEM ARE IN REGGIO, THEREFORE THEY ARE CONSIDERED AS TREATED!
replace asiloType_manual = 1 if (asiloType_self==1 & asiloType_manual>=10)

tab maternaType_self maternaType_manual
tab maternaType_self maternaType_manual, miss
tab maternaType_self maternaType_manual, row
tab maternaType_self maternaType_manual if (maternaType_manual>0 & maternaType_manual<5)  , row // This table goes in the report  --> see the excel file: \SURVEY_DATA_COLLECTION\dataReggioAll_SchoolNames_manual.xlsx
// tabout maternaType_self maternaType_manual if (maternaType_manual>0 & maternaType_manual<5) using cancella.out , row // This table goes in the report

* Type of preschool and infant-toddler center attended: maternaType and asiloType --> based on manual and then filled in with self-reported when manual was missing
foreach school in asilo materna{
gen `school'Type = `school'Type_manual 
label values `school'Type Type_manual
label list Type_manual Type_self
replace `school'Type = .u if `school'Type_manual==10 |  `school'Type_manual==11 //unclear or no info left as missing
replace `school'Type = 4 if (`school'Type_manual==5 ) // Spazio bimbi and educatore coded as --> private
replace `school'Type = 2 if (`school'Type_manual==6 ) // Autogestito coded as --> state

replace `school'Type = 0 if (`school'Type_self==0 & `school'Type >=.) // Not attended
replace `school'Type = 1 if (`school'Type_self==2 & `school'Type >=.) // Muncipal
replace `school'Type = 2 if (`school'Type_self==1 & `school'Type >=.) // State
replace `school'Type = 3 if (`school'Type_self==4 & `school'Type >=.) // Religious
replace `school'Type = 4 if (`school'Type_self==5 & `school'Type >=.) // Private
replace `school'Type = .s if (`school'==.s) // Don't remember

tab `school'Type_self `school'Type , miss
}

bys City: tab asiloType Cohort, column // this goes into the report --> see the excel file: \SURVEY_DATA_COLLECTION\dataReggioAll_SchoolNames_manual.xlsx
bys City: tab maternaType Cohort, column // this goes into the report --> see the excel file: \SURVEY_DATA_COLLECTION\dataReggioAll_SchoolNames_manual.xlsx

dummieslab maternaType, template(materna_@) truncate(23)
replace materna_NotAttended = 1-materna if materna<.
tab materna_NotAttend materna, miss

dummieslab asiloType, template(asilo_@) truncate(23)
gen asilo_State = 0 if asiloType<. // there are no state infant-toddler centers
replace asilo_NotAttended = 1-asilo_Attend if asilo_Attend<.
tab asilo_NotAttend asilo, miss

replace materna_NotAttend = 1-materna if materna<. //[=] CHECK browse materna* if materna==.s & materna_NotAtt==1
label var materna_NotAttend "No preschool"
label var materna_Municipal "Municipal preschool"
label var materna_State "State preschool"
label var materna_Religious "Religious preschool"
label var materna_Private "Private preschool"
//label var materna_Outside "Preschool outside of city"
label var asilo_NotAttend "No infant-toddler-center"
label var asilo_Municipal "Municipal infant-toddler-center"
label var asilo_State "State infant-toddler-center"
label var asilo_Religious "Religious infant-toddler-center"
label var asilo_Private "Private infant-toddler-center"
//label var asilo_Outside "Infant-toddler-center outside of city"

foreach school in asilo materna{
foreach name in name address{
   replace `school'Location_`name'="" if `school'Location_`name'=="."
   replace `school'Location_`name'="" if `school'Location_`name'==";"
   replace `school'Location_`name'="" if `school'Location_`name'==","
}
}

*========* Merge with distances and other instruments
merge 1:1 intnr using Instruments.dta, gen(_mergeIV) //CHECK should merge perfectly, keep only "new" variables
tab _mergeIV source, miss //CHECK: should only be the 303 from the pilot
drop if _mergeIV==2


/* ====================  Create some useful variables  ============== */
*----------------------* TREATMENT GROUP
gen ReggioAsilo   = (City==1 & asiloType==1) if asiloType<.  //treated if 1)Reggio 2)went to municipal infant-toddler center
gen ReggioMaterna = (City==1 & maternaType==1) if maternaType<. //treated if 1)Reggio 2)went to municipal preschool

replace ReggioAsilo   = 0 if (asiloNotCity>0 & asiloNotCity<.)  & ReggioAsilo==1 //take away those who attended a municipal school outside of the City
replace ReggioMaterna = 0 if (maternaNotCity>0 & maternaNotCity<.) & ReggioMaterna==1 // Only 1 change made
replace ReggioMaterna = 1 if maternaComment =="Living in Parma, attended school in Reggio" & maternaType==1 // There are 16 people from Parma gone to Reggio Children

gen treated = (ReggioAsilo==1  | ReggioMaterna==1) if (ReggioMaterna<. | ReggioAsilo<.) //treated if went to municipal preschool or infant-toddler center
tab treated City

tab maternaType treated if City==1 & asiloType!=2
tab asiloType treated if City==1 & maternaType!=2
label var treated "dv: Treatment group - went to Reggio Children Nidi and/or Materna"

gen     treatGroup = 1 if treated == 1
replace treatGroup = 2 if treated == 0 & City == 1 // Reggio non municipal
replace treatGroup = 3 if City == 2 // Parma
replace treatGroup = 4 if City == 3 // Padova
label define treatGroup 1 "Reggio Municipal" 2 "Reggio non-municipal" 3 "Parma, all schools" 4 "Padova, all schools"
label values treatGroup treatGroup
tab treatGroup City

gen DoxaContract = 1 if (City==1 & (maternaMuni_self==1 ))
replace DoxaContract = 2 if City == 1  & DoxaContract>=. // Reggio non municipal
replace DoxaContract = 3 if City == 2 // Parma
replace DoxaContract = 4 if City == 3 // Padova
label define DoxaContract 1 "Reggio Municipal" 2 "Reggio non-municipal" 3 "Parma, all schools" 4 "Padova, all schools"
label values DoxaContract DoxaContract
tab DoxaContract City

tab Cohort DoxaContract , miss // CHECK this should be the same as the numbers given to us by Paolo

*----------------------* SES and background dummies
dummieslab famSize
tab famSize
//drop famSize_1 famSize_6-famSize_10 // keep famSize=1 as reference
gen famSize_4plus = (famSize>=4) if famSize<. // 5 or more all together
gen famSize_5plus = (famSize>=5) if famSize<. // 5 or more all together

foreach pref in cg mom dad hh " " {
	if "`pref'"!="hh"{
	* Marital status
	tab `pref'mStatus
	gen `pref'mStatus_married = (`pref'mStatus==1) if `pref'mStatus<.
	gen `pref'mStatus_div = (`pref'mStatus==2 | `pref'mStatus==3 | `pref'mStatus==4) if `pref'mStatus<. //separated, divorced, widowed
	gen `pref'mStatus_cohab = (`pref'mStatus == 6) if `pref'mStatus<.
	gen `pref'mStatus_nevmarry = (`pref'mStatus == 5)  if `pref'mStatus<. 
	gen `pref'mStatus_miss = (`pref'mStatus >=.) 
	label var `pref'mStatus_married "Married `pref'"
	label var `pref'mStatus_div "Divorced `pref'"
	label var `pref'mStatus_cohab "Cohabiting `pref'"
	label var `pref'mStatus_nevmarry "Never married `pref'"
	label var `pref'mStatus_miss "Missing marital status `pref'"

	* Education
	tab `pref'MaxEdu
	gen `pref'MaxEdu_low = (`pref'MaxEdu==1) if `pref'MaxEdu<. 
	gen `pref'MaxEdu_middle = (`pref'MaxEdu==2) if `pref'MaxEdu<.  
	gen `pref'MaxEdu_HS = (`pref'MaxEdu==3) if `pref'MaxEdu<. 
	gen `pref'MaxEdu_Uni = (`pref'MaxEdu>3) if `pref'MaxEdu<. 
	gen `pref'MaxEdu_Grad = (`pref'MaxEdu>7) if `pref'MaxEdu<. 
	gen `pref'MaxEdu_miss = (`pref'MaxEdu>=.) 
	label var `pref'MaxEdu_low "Low edu `pref'"
	label var `pref'MaxEdu_middle "Middle school edu `pref'"
	label var `pref'MaxEdu_HS "High school edu `pref'"
	label var `pref'MaxEdu_Uni "University edu or more `pref'"
	label var `pref'MaxEdu_Grad "Master or phd `pref'"
	label var `pref'MaxEdu_miss "Missing edu `pref'"
	}

	* Principal Activity
	tab `pref'PA
	gen `pref'PA_Empl = (`pref'PA == 1 | `pref'PA == 2 | `pref'PA == 3 | `pref'PA == 4 | `pref'PA == 9 | `pref'PA == 10) if `pref'PA<. // [=] Tirocinante: is that employed?
	gen `pref'PA_Unempl = (`pref'PA == 5 | `pref'PA == 6) if `pref'PA<.  // either unemployed , or looking for first job
	gen `pref'PA_OLF= (`pref'PA == 7 | `pref'PA == 8 | `pref'PA == 11 | `pref'PA == 5 ) if `pref'PA<.  // student, retired, housewife, unemployed
	gen `pref'PA_HouseWife= (`pref'PA == 11 ) if `pref'PA<. 
	gen `pref'PA_other = (`pref'PA_Unempl==0 & `pref'PA_Empl==0 & `pref'PA_OLF==0 & `pref'PA_HouseWife==0)  if `pref'PA<. //Unemployed but NOT looking for work, military, other
	gen `pref'PA_miss = (`pref'PA>=.)
	// rename student PA_student //Multicollinear with cohort and maxedu
	label var `pref'PA_Empl "Employed `pref'"
	label var `pref'PA_Unempl "Unemployed `pref'"
	label var `pref'PA_OLF "Out of labor force `pref'"
	label var `pref'PA_HouseWife "House wife `pref'"
	label var `pref'PA_other "Other principal activity `pref'"
	label var `pref'PA_miss "Missing PA `pref'"
}

* make some categorical variables for SES
//first standardize aross SES
replace cgSES = cgSES - 1 
replace hhSES = hhSES - 1

foreach pref in cgSES hhSES SES {
	gen `pref'_worker = (`pref' == 1 | `pref' == 2 | `pref' == 3 | `pref' == 10) if (`pref'<.)
	gen `pref'_teacher = (`pref' == 4) if (`pref'<.)
	gen `pref'_professional = (`pref' == 5 | `pref' == 6 | `pref' == 7 | `pref' == 8) if (`pref'<.)
	gen `pref'_self = (`pref' == 9) if (`pref'<.)
}
label var cgSES_worker "Worker caregiver"
label var cgSES_teacher "Teacher caregiver"
label var cgSES_professional "Professional caregiver"
label var cgSES_self "Self Employed caregiver"
	label var hhSES_worker "Worker head of hh"
	label var hhSES_teacher "Teacher head of hh"
	label var hhSES_professional "Professional head of hh"
	label var hhSES_self "Self Employed head of hh"
label var SES_worker "Worker"
label var SES_teacher "Teacher"
label var SES_professional "Professional"
label var SES_self "Self Employed"

label define SES 0 "Never Worked" 1 "Farmer" 2 "Worker" 3 "Employee" 4 "Teacher" 5 "Executive" ///
6 "Manager" 7 "Professional (Doctor, Lawyer, etc.)" 8 "Entrepreneur" 9 "Self-Employed" ///
10 "Atypical Worker" 11 "Other"
label values SES SES
label values cgSES SES
label values hhSES SES

* Principal Activity value labels
label define PA 1 "Employee" 2 "Self-employed" 3 "Employed in family business" 4 "Intern" 5 "Unemployed" ///
                6 "Looking for first employment" 7 "Student" 8 "Retired" 9 "Maternity/paternity leave" ///
				10 "Disability leave" 11 "Housewife/Homemaker" 12 "Military" 98 "Other" 99 "No response"
label values PA PA
label values cgPA PA
label values hhPA PA
label values dadPA PA
label values momPA PA

* Income and household
gen cgIncome25000 = (cgIncomeCat < 4 ) if cgIncomeCat<.
gen Income25000 = (IncomeCat < 4 ) if IncomeCat<.
gen houseOwn = (house==1) if house<.

* Language spoken in the household (only for Children and Adolescents, not adults)
gen speakDial = (lang==2) if lang<.
gen speakItal = (lang==1) if lang<.
gen speakFore = (lang==3) if lang<.
label var speakDial "Dialect spoken at home"
label var speakItal "Italian spoken at home"
label var speakFore "Foreign language spoken at home"

* Mom at home during childhood
gen momHome06 = (momWorking06==4) if momWorking06<.
label var momHome06 "Mother was home when child was 0 to 6"

gen lone_parent = noDad
replace lone_parent = 1 if noMom==1
label var lone_parent "Either no mom or dad in the household"

* Mom self-assessed religiosity 
gen cgSuperFaith = (cgFaith >=4) if cgFaith <.

* Grandparents presence
gen daily_grandCare = (grandCare == 1 | grandCare == 2) if (grandCare<.)
label var daily_grandCare "Grandp care often"

gen grand_close = (grandDist == 1 | grandDist == 2) if (grandDist<.)
label var grand_close "Grandparents close" //same house or nextdoor

gen grand_nbrhood = (grandDist <= 3) if (grandDist<.)
label var grand_nbrhood "Grandparents in neighborhood"

gen grand_city = (grandDist <= 4) if (grandDist<.)
label var grand_city "Grandparents in city" 

gen grand_far =  (grandDist == 5 | grandDist == 6) if (grandDist<.)
label var grand_far "Grandparents far"

* very few - this gets dropped from every regression
gen grand_notPresent = (grandDist == 7) if (grandDist<.)
label var grand_notPresent "Grandparents not present"

* Religiosity
tab cgReligType Cohort // only for young
tab momReligiosity Cohort // only for adult
label var cgRelig "Caregiver Religious"
foreach pref in mom dad " " { //cg already defined
	gen `pref'Relig = (`pref'Religiosity < 4) if (`pref'Religiosity<.)
	gen `pref'Relig50 = (`pref'Religiosity < 4 & Cohort == 6) if (`pref'Religiosity<.)
	label var `pref'Relig "Religious `pref'"
	label var `pref'Relig50 "Religious `pref'- Adult 50"
}
/*
gen cgCatholic= (cgReligType == 1) if cgReligType<.
label var cgCatholic"Caregiver Catholic"
tab cgCatholicCohort

gen cgOtherRelig = (cgReligType > 1) if cgReligType<.
label var cgOtherRelig "Caregiver Other Relig."
tab cgOtherRelig Cohort
*/

*----------------------* Satisfaction
foreach var in Income Work Health Family{
	gen Satis`var'_bin = (Satis`var' >= 4) if Satis`var'<.
	label var Satis`var'_bin "Satisfied with `var'"
}
egen temp = rownonmiss(Satis*)
gen Satisfied = (SatisHealth==5 | SatisSchool==5 | SatisFamily==5 | SatisWork==5) if temp>0
label var Satisfied "Satisfied of at least one aspect of life"
drop temp
//binary variable for income satisfaction (50%)
//binary variable for saisfied with work (71%)
//binary variable for health satisfaction (86%)
//binary for satisfaction w/ family (76%)

gen SocialMeet_bin = (SocialMeet <= 3) if SocialMeet<. //binary if meets people more than once a month

*----------------------* Child self-reported status using faces
foreach var in faceMe faceFamily faceSchool faceGeneral{
	gen `var'_bin = (`var'>=10)
	replace `var'_bin = `var' if `var'>=.
	tab `var' `var'_bin, miss
}
label var faceMe_bin "Happy child"
label var faceFamily_bin "Happy in the family"
label var faceSchool_bin "Happy at school"
label var faceGeneral_bin "Happy in general"

foreach var in closeMom closeDad{
	gen `var'_bin = (`var'>=4)
	replace `var'_bin = `var' if `var'>=.
	tab `var' `var'_bin, miss
}
label var closeMom_bin "Feels close to mom"
label var closeDad_bin "Feels close to dad"

*----------------------* School and computer
* School and difficulties
gen likeSchool = (likeSchool_child == 1) if likeSchool_child <.
replace likeSchool = (likeSchool_ado <= 2) if likeSchool_ado <. & likeSchool == .
gen likeMath = (likeMath_child == 1) if likeMath_child <.
replace likeMath = (likeMath_ado <= 2) if likeMath_ado <. & likeMath == .
gen likeLit = (likeRead == 1) if likeRead <.
replace likeLit = (likeItal <= 2) if likeItal <. & likeRead == .
label var likeSchool "Child likes school (%)"
label var likeMath "Child likes math (%)"
label var likeLit "Child likes reading/italian (%)"

gen SatisSchool_bin = (SatisSchool >= 4 & Cohort == 3) if SatisSchool<. //binary for school satisfaction (72%)
label var SatisSchool_bin "Satisfied with school"

/* computer usage */
* children: computer in household they can use
* adults: use a computer for work
* adolescents: spend any time on computer/smartphone (highest %)
gen computer = (workComputer == 4) if (workComputer <.) // cond(workComputer == 4,0,cond(workComputer == .,.,1))
replace computer = 1 if(childinvCom < 3 & childinvCom != .)
replace computer = 0 if childinvCom == 3
replace computer = (PC_hrs == 0) if Cohort == 3 & PC_hrs<.

*----------------------* Who should be in charge of education
gen eduFamily_bin = (eduFamily>=4)
replace eduFamily_bin = eduFamily if eduFamily>=.
tab eduFamily eduFamily_bin, miss
label var eduFamily_bin "Family should be main responsible for childcare (not public service)"

*----------------------* Health
* Child health
gen childHealthPerc = (childHealth<=2) if childHealth<.
gen cgHealthPerc = (cgHealth<=2) if cgHealth<.
gen childFruitDaily = (childFruit<=3) if childFruit<.
gen HealthPerc = (Health<=2) if Health<.
gen FruitDaily = (Fruit<=3) if Fruit<.
gen sportTwice = (sport>=2) if sport<.
gen Stressed = (Stress<=2) if Stress<.
//binary variable for stressed or not (29%) /*Stress: lower is more stressed, switched order here so that a 1 is stressed (consistent with other variables)*/

label var childHealthPerc "Child health is good (%) - mom report"
label var cgHealthPerc "Caregiver health is good (%)"
label var childFruitDaily "Child eats fruit daily (%) - mom report"
label var HealthPerc "Respondent health is good (%)"
label var FruitDaily "Respondent eats fruit daily (%)"

gen childDoctorRecent = (childDoctor <= 2) //binary if child has visited doctor in past month (48%)
replace childDoctorRecent = . if missing(childDoctor)
*NOTE: Order switched so positive means more recent 

gen childDiag = (childTotal_diag >= 1) //binary if child has any health problems (26%)
replace childDiag = . if missing(childTotal_diag)

gen noSickDays_bin = (SickDays > 1 ) if SickDays<. //binary if child has sick days
gen childnoSickDays_bin = (childSickDays > 1 ) if childSickDays<. //binary if child has sick days
label var childnoSickDays_bin "Child never skipped school beacuse ill last month"

*----------------------* Reciprocity
forvalues i=1/4{
	** Reciprocity -- converted into dummies
	gen reciprocity`i'_bin = (reciprocity`i'>=4) 
	replace reciprocity`i'_bin = reciprocity`i' if reciprocity`i'>=.
	tab reciprocity`i' reciprocity`i'_bin, miss
}
label var reciprocity3_bin "Reciprocate kindness"

*----------------------* Importance of learning
forvalues i=1/4{
	** What is important for learning -- converted into dummies for schools or teachers
	gen learnImp`i'_school = (learnImp`i'<=2) 
	replace learnImp`i'_school = learnImp`i' if learnImp`i'>=.
	tab learnImp`i' learnImp`i'_school, miss
}
label var learnImp1_school "Teachers or school are most important factor for learning"
label var learnImp2_school "Teachers or school are second most important factor for learning"
label var learnImp3_school "Teachers or school are third most important factor for learning"
label var learnImp4_school "Teachers or school are least important factor for learning"

** Migrants 
*--------------------------------------------------------*
* (item) Construct some variables
foreach var of varlist *Afri *Arab *Asia *Engl *SAme *Swed {
   gen `var'_Y  = (`var'==1) if `var'<.
   gen `var'_N  = (`var'==2) if `var'<.
   gen `var'_NI = (`var'==3) if `var'<.
   replace `var'_Y  = `var' if `var'>=.
   replace `var'_N  = `var' if `var'>=.
   replace `var'_NI = `var' if `var'>=.
}

label var MigrAfri_Y "Would like to have African Neighbour"  
label var MigrAfri_N "Would not like to have African Neighbour"  
label var MigrAfri_NI "Does not care if neighbour is African"  
label var MigrArab_Y "Would like to have Arab Neighbour"  
label var MigrArab_N "Would not like to have Arab Neighbour"  
label var MigrArab_NI "Does not care if Neighbour is Arab"  
label var MigrAsia_Y "Would like to have Asian Neighbour"  
label var MigrAsia_N "Would not like to have Asian Neighbour"  
label var MigrAsia_NI "Does not care if Neighbour is Asian"  
label var MigrEngl_Y "Would like to have English Neighbour"  
label var MigrEngl_N "Would not like to have English Neighbour"  
label var MigrEngl_NI "Does not care if Neighbour is English"  
label var MigrSAme_Y "Would like to have South American Neighbour"  
label var MigrSAme_N "Would not like to have South American Neighbour"  
label var MigrSAme_NI "Does not care if Neighbour is South American"  
label var MigrSwed_Y "Would like to have Swedish Neighbour"  
label var MigrSwed_N "Would not like to have Swedish Neighbour"  
label var MigrSwed_NI "Does not care if Neighbour is Swedish"  
    
label var cgMigrAfri_Y "Would like to have African Neighbour (caregiver)" 
label var cgMigrAfri_N "Would not like to have African Neighbour (caregiver)" 
label var cgMigrAfri_NI "Does not care if neighbour is African (caregiver)" 
label var cgMigrArab_Y "Would like to have Arab Neighbour (caregiver)" 
label var cgMigrArab_N "Would not like to have Arab Neighbour (caregiver)" 
label var cgMigrArab_NI "Does not care if Neighbour is Arab (caregiver)" 
label var cgMigrAsia_Y "Would like to have Asian Neighbour (caregiver)" 
label var cgMigrAsia_N "Would not like to have Asian Neighbour (caregiver)" 
label var cgMigrAsia_NI "Does not care if Neighbour is Asian (caregiver)" 
label var cgMigrEngl_Y "Would like to have English Neighbour (caregiver)" 
label var cgMigrEngl_N "Would not like to have English Neighbour (caregiver)" 
label var cgMigrEngl_NI "Does not care if Neighbour is English (caregiver)" 
label var cgMigrSAme_Y "Would like to have South American Neighbour (caregiver)" 
label var cgMigrSAme_N "Would not like to have South American Neighbour (caregiver)" 
label var cgMigrSAme_NI "Does not care if Neighbour is South American (caregiver)" 
label var cgMigrSwed_Y "Would like to have Swedish Neighbour (caregiver)" 
label var cgMigrSwed_N "Would not like to have Swedish Neighbour (caregiver)" 
label var cgMigrSwed_NI "Does not care if Neighbour is Swedish (caregiver)" 

label var MigrFriendAfri_Y "Would like to have African Friend"
label var MigrFriendAfri_N "Would not like to have African Friend"
label var MigrFriendAfri_NI "Does not care if Friend is African"
label var MigrFriendArab_Y "Would like to have Arab Friend"
label var MigrFriendArab_N "Would not like to have Arab Friend"
label var MigrFriendArab_NI "Does not care if Friend is Arab"
label var MigrFriendAsia_Y "Would like to have Asian Friend"
label var MigrFriendAsia_N "Would not like to have Asian Friend"
label var MigrFriendAsia_NI "Does not care if Friend is Asian"
label var MigrFriendEngl_Y "Would like to have English Friend"
label var MigrFriendEngl_N "Would not like to have English Friend"
label var MigrFriendEngl_NI "Does not care if Friend is English"
label var MigrFriendSAme_Y "Would like to have South American Friend"
label var MigrFriendSAme_N "Would not like to have South American Friend"
label var MigrFriendSAme_NI "Does not care if Friend is South American"
label var MigrFriendSwed_Y "Would like to have Swedish Friend"
label var MigrFriendSwed_N "Would not like to have Swedish Friend"
label var MigrFriendSwed_NI "Does not care if Friend is Swedish"


foreach var in FriendFig NiceFig BadFig SimilarFig{
   gen `var'_white = (Migr`var'==2 | Migr`var'==5 ) if Migr`var'<.
   replace `var'_white = Migr`var' if Migr`var'>.
   gen Ita`var'_white = `var'_white  if Cohort==1
   gen Migr`var'_white = `var'_white  if Cohort==2
   //drop `var'_white

   gen `var'_black = (Migr`var'==3 | Migr`var'==1) if Migr`var'<.
   replace `var'_black = Migr`var' if Migr`var'>.
   gen Ita`var'_black = `var'_black  if Cohort==1
   gen Migr`var'_black = `var'_black  if Cohort==2
   //drop `var'_black
}
label var ItaFriendFig_white "Want white as friend (ita)"
label var ItaNiceFig_white "White seems nice (ita)"
label var ItaBadFig_white "White seems bad (ita)"
label var ItaSimilarFig_white "White seems like me (ita)"
label var MigrFriendFig_white "Want white as friend (migrant)"
label var MigrNiceFig_white "White seems nice (migrant)"
label var MigrBadFig_white "White seems bad (migrant)"
label var MigrSimilarFig_white "White seems like me (migrant)"

label var ItaFriendFig_black "Want black as friend (ita)"
label var ItaNiceFig_black "Black seems nice (ita)"
label var ItaBadFig_black "Black seems bad (ita)"
label var ItaSimilarFig_black "Black seems like me (ita)"
label var MigrFriendFig_black "Want black as friend (migrant)"
label var MigrNiceFig_black "Black seems nice (migrant)"
label var MigrBadFig_black "Black seems bad (migrant)"
label var MigrSimilarFig_black "Black seems like me (migrant)"

foreach var of varlist cgMigrTimeFit cgMigrTimeSpeak cgMigrTimeFriends cgMigrTimeSatis {
   recode `var' (0 = 0) (1/6 = 1) (7/12 = 2) (13/100000 = 3), generate(`var'_cat)
   local vlabel : variable label `var'
   label var `var'_cat "`vlabel' - categorized"
}
label define time_cat 0 "Immediately" 1 "1-6 mth" 2 "7-12 mth" 3 ">1 year"
label values cgMigrTime*cat time_cat

recode MigrIntegr (1 = 1) (2/3 = 0), gen(MigrIntegr_bin)
label var MigrIntegr_bin "Schools help migration"
recode MigrAttitude (1/2 = 0) (3 = 1), gen(MigrAttitude_bin)
label var MigrAttitude_bin "Diffident toward migrants"
recode  MigrProgram  (1/2 = 1) (3/4 = 0), gen( MigrProgram_bin)
label var MigrProgram_bin "Migrants slow down class curriculum"
recode  MigrClassIntegr (1 = 1) (2/3 = 0), gen( MigrClassIntegr_bin)
label var MigrClassIntegr_bin "Migrants are well integrated in classroom"
recode  MigrTaste (1/2 = 1) (3/5 = 0), gen( MigrTaste_bin)
label var MigrTaste_bin "Bothered by immigration into city"
recode  MigrGood (1/2 = 1) (3/5 = 0), gen( MigrGood_bin)
label var MigrGood_bin "Immigration is bad for our country"
recode  MigrClassChild (1/3 = 0) (4/5 = 1), gen( MigrClassChild_bin)
label var MigrClassChild_bin "Too many migrants in child's classroom"

recode cgMigrCity (1/2 = 0) (3/4 = 1), gen(cgMigrCity_bin)
label var cgMigrCity_bin "City hostile to migrants"
recode  cgMigrIntegCity (1/2 = 0) (3 = 1), gen(cgMigrIntegCity_bin)
label var cgMigrIntegCity_bin "Hard to integrate into city"
recode  cgMigrIntegIt (1/2 = 0) (3 = 1), gen(cgMigrIntegIt_bin)
label var cgMigrIntegIt_bin "Hard to integrate in Italy"
recode cgMigrIntegr (1 = 1) (2/3 = 0), gen(cgMigrIntegr_bin)
label var cgMigrIntegr_bin "Schools help migration (caregiver)"
recode cgMigrAttitude (1/2 = 0) (3 = 1), gen(cgMigrAttitude_bin)
label var cgMigrAttitude_bin "Diffident toward migrants (caregiver)"
recode  cgMigrProgram  (1/2 = 1) (3/4 = 0), gen( cgMigrProgram_bin)
label var cgMigrProgram_bin "Migrants slow down class curriculum (caregiver)"
recode  cgMigrTaste (1/2 = 1) (3/5 = 0), gen(cgMigrTaste_bin)
label var cgMigrTaste_bin "Bothered by immigration into city (caregiver)"


*----------------------*  Admission Criteria Score (by Chiara) =====================================
gen one_out= momBornCity==0 | dadBornCity==0
gen two_out= momBornCity==0 & dadBornCity==0

gen score_adozione=5*(cgRelation==8|cgRelation==9)
gen score_lone=16*(lone_parent==1 & (cgmStatus==2 | cgmStatus==3)) + 14*(lone_parent==1 & cgmStatus==5)
gen fullTime= cgHrsWork>=40 | hhHrsWork>=40
gen score_teacher=11*(cgSES==4 | hhSES==4) + 0.5*fullTime
gen score_fullTime=0.5*fullTime

/*
gen score_ore=7*(cgHrsWork<15 & cgHrsWork>0) + 7*(hhHrsWork>0 & hhHrsWork<15) + 9*(cgHrsWork>=15 & cgHrsWork<=23) + 9*(hhHrsWork>=15 & hhHrsWork<=23) /*
*/ + 10*(cgHrsWork>=24 & cgHrsWork<=28) + 10*(hhHrsWork>=24 & hhHrsWork<=28) + 11*(cgHrsWork>=29 & cgHrsWork<=32) + 11*(hhHrsWork>=29 & hhHrsWork<=32) /*
*/ + 13*(cgHrsWork>=33 & cgHrsWork<=36) + 11*(hhHrsWork>=33 & hhHrsWork<=36) + 14*(cgHrsWork>=37 & cgHrsWork<100) + 14*(hhHrsWork>=37 & hhHrsWork<100) if hhead!=1
replace score_ore=7*(cgHrsWork<15) + 9*(cgHrsWork>=15 & cgHrsWork<=23) /*
*/ + 10*(cgHrsWork>=24 & cgHrsWork<=28) + 11*(cgHrsWork>=29 & cgHrsWork<=32) /*
*/ + 13*(cgHrsWork>=33 & cgHrsWork<=36) + 14*(cgHrsWork>=37 & cgHrsWork<100) if hhead==1
*/

gen score_ore=14.5*(noDad==0)
gen score_migrant=3*(momMigrant==1 & dadMigrant==1 & yrItaly>=2003)
gen score_unemp=8*(momPA_Unemp+dadPA_Unemp==2) + 4*(momPA_Unemp+dadPA_Unemp==1)
gen score_student=8*(momPA==7 | dadPA==7) & score_full==0 & score_ore==0 & score_un==0

/*
gen adozione = 0
forvalues i = 3/10 {
replace  adozione = adozione + 1 if(Relation`i' == 8 | Relation`i' == 9)
}
replace adozione = adozione + 1 if(cgRelation == 8 |  cgRelation == 9)
recode adozione (2 = 1)
gen score_adozione_bis=5*adozione
*/

forvalues i = 3/10 {
format Birthday`i' %td
gen year`i'=year(Birthday`i')
}

gen score_siblings=0
forvalues i = 3/10 {
replace score_siblings=score_siblings + 1*(Relation`i' == 11 & year`i'>=1989 & year`i'<=1992) + 2*(Relation`i' == 11 & year`i'>=1993 & year`i'<=1999) /// 
        + 3*(Relation`i' == 11 & year`i'>=2000 & year`i'<=2004) + 4.5*(Relation`i' == 11 & year`i'>=2005 & year`i'<=2008)
}

gen score_nonni=11*(grandDist==7) + 10*(grandDist==6) + 5*(grandDist==5) + 2*(grandDist==2 | grandDist==3 | grandDist==4)

gen score=score_sib+score_unemp+score_ado+score_migr+score_tea+score_full+score_student+score_ore+score_lone+score_nonni
sum score, d
replace score=r(max)+1 if (lone_parent==1 & mommStatus==5) | (lone_parent==1 & dadmStatus==5)
label var score "Admission score in RCH (approximated)"
/*
kdensity score if ReggioAsilo==1, addplot(kdensity score if ReggioAsilo==0 & Reggio==1 || kdensity score if Reggio==1 & asiloType==0) /*
*/ ytitle("Density function") xtitle("Score") legend(lab(3 "No childcare") lab(2 "Non municipal childcare") lab(1 "Municipal childcare"))
*distplot line score if ReggioAsilo==1, addplot(distplot line score if ReggioAsilo==0 & Reggio==1 || distplot line score if Reggio==1 & asiloType==0)
graph save score_reggio.gph, replace
graph export score_reggio.png, replace

kdensity score if ReggioAsilo==1, addplot(kdensity score if Parma==1 & asilo_Municipal==1 || kdensity score if Padova==1 & asilo_Municipal==1) /*
*/ ytitle("Density function") xtitle("Score") legend(lab(3 "Padova") lab(2 "Parma") lab(1 "Reggio"))
*distplot line score if ReggioAsilo==1, addplot(distplot line score if ReggioAsilo==0 & Reggio==1 || distplot line score if Reggio==1 & asiloType==0)
graph save score_cities.gph, replace
graph export score_cities.png, replace

kdensity score if ReggioAsilo==1, addplot(kdensity score if ReggioAsilo==0 & Reggio==1 || kdensity score if Parma==1 & asilo_Attend==1 || kdensity score if Padova==1 & asilo_Attend==1) /*
*/ ytitle("Density function") xtitle("Score") legend(lab(4 "Padova- childcare") lab(3 "Parma- childcare") lab(2 "Reggio- non municipal") lab(1 "Reggio- municipal"))
*distplot line score if ReggioAsilo==1, addplot(distplot line score if ReggioAsilo==0 & Reggio==1 || distplot line score if Reggio==1 & asiloType==0)
graph save score_any_cities.gph, replace
graph export score_any_cities.png, replace
*/

*----------------------* Different Groups: by preschool type
gen materna3Type = maternaType if maternaType>0 & maternaType<10
replace materna3Type = 3 if maternaType == 4 | maternaType==5 // Private or other --> religious
replace materna3Type = 2 if maternaType == 6 // Autogestito --> state
label define materna3Type 1 "Municipal" 2 "State" 3 "Religious or other"
label values materna3Type materna3Type 
tab materna*Type, miss

* recode so that Municipal is the first category and not attended the last -- for tabulation
recode maternaType (0=20), gen(temp)
label copy Type_manual temp
label define temp 20 "Not Attended" 0 "" , modify
label values temp temp
tab maternaType temp

egen cityXmaterna = group(City temp), label
tab cityXmaterna
egen cohortXmaterna = group(Cohort temp), label
tab cohortXmaterna
egen cityXmaterna3 = group(City materna3Type), label
tab cityXmaterna3
egen cohortXmaterna3 = group(Cohort materna3Type), label
tab cohortXmaterna3
drop temp

* recode so that Municipal is the first category and not attended the last -- for tabulation
recode asiloType (0=20), gen(temp)
label values temp temp
tab asiloType temp

tab asilo*Type, miss
egen cityXasilo = group(City temp), label
tab cityXasilo
egen cohortXasilo = group(Cohort temp), label
tab cohortXasilo
drop temp

egen cohortXcity = group(Cohort City), label
tab cohortXcity
egen cohortXtreat = group(Cohort treatGroup), label
tab cohortXtreat, miss


*----------------------* Some variables for the regressions:
rename inter_MainProjects interMain_Project // so that inter_* doesn't list this, it's a string
* control variables and covariates (dummies etc)
gen Age_sq = Age^2
gen Age_3rd = Age^3

dummieslab Cohort , template(Cohort_@) truncate(23)
drop Cohort_Adult50 // last cohort as baseline

* interviewers F.E.
dummieslab internr // generate dummy variables by interviewer
capture gen interPadova = (internr == 174 | internr == 175 | internr == 2525) if (City == 3 & Cohort>3) // only for Padova adults
tab internr interPadova, miss
tab Cohort interPadova 
gen interPadova_all = (interPadova==1)

label var interPadova "3 Strange Padova interviewers (174,175,2525) Missing for non-adult-padova"
label var interPadova_all "3 Strange Padova interviewers (174,175,2525) no missing"


*----------------------* Outcomes of interest for Children and Adolescents (written by Chiara in 1.outcomes15July16children.do)

/* TUTTI GLI OUTCOMES (5+10+6+31+26+16+11+20=135)

*** DIFFICULTIES (5)

difficultiesSit byte    %8.0g      LABU       Ability to sit still in a group when asked (difficulties in primary school)
difficultiesI~t byte    %8.0g      LABU       Lack of excitement to learn (difficulties in primary school)
difficultiesO~y byte    %8.0g      LABU       Ability to obey rules and directions (difficulties in primary school)
difficultiesEat byte    %8.0g      LABU       Fussy eater (difficulties in primary school)
difficulties    byte    %55.0g     difficulties

                                              dv: Difficulties encountered when starting primary school
											  
*** THINGS AT HOME (10)

childinvReadTo  byte    %8.0g      V37110   * Frequency reading to child
childinvMusic   byte    %8.0g      V37120   * Music instrument at home
childinvCom     byte    %8.0g      V37130     Is there a computer at home that the child can use?
childinvTV_hrs  byte    %10.0g              * In a typical day, how many hours does your child spend watching television?
childinvVideo~s byte    %10.0g              * In a typical day, how many hours does your child spend watching video games?
childinvOut     byte    %8.0g      V37150   * Frequency taking child out (high = never)
childinvFamMeal byte    %8.0g      V37190   * Frequency eating a meal together
childinvChore~m byte    %8.0g      V37200_1 * How often is your child expected to do the following? Clean up his/her room?
childinvChore~p byte    %8.0g      V37200_2 * How often is your child expected to do the following? Do routine chores such
                                                as
childinvChore~w byte    %8.0g      V37200_3 * How often is your child expected to do the following? Do homework
                                                voluntarily?
												
*** EXTRA ACTIVITIES (6)
											
childinvReadS~f byte    %8.0g      V37210     Frequency reading by herself
childinvSport   byte    %8.0g      LABA       Child does sport
childinvDance   byte    %8.0g      LABA       Child does dances
childinvTheater byte    %8.0g      LABA       Child does theater
childinvOther   byte    %8.0g      LABA       Does your child participate in the following activities? Other, specify
childFriends byte    %10.0g              * Number of child's friends

*** S&D (31)

childSDQPsoc1   byte    %8.0g      V56010_1   Considerate of other people's feelings
childSDQHype1   byte    %8.0g      V56010_2 * Restless, overactive, cannot stay still for long
childSDQEmot1   byte    %8.0g      V56010_3 * Often complains of headaches, stomach-aches or sickness
childSDQPsoc2   byte    %8.0g      V56010_4 * Shares readily with other children, for example toys, treats, pencils
childSDQCond1   byte    %8.0g      V56010_5   Often loses temper or is in a bad mood
childSDQPeer1   byte    %8.0g      V56010_6   Rather solitary, prefers to play alone
childSDQCond2   byte    %8.0g      V56010_7 * Generally well behaved, usually does what adults request
childSDQEmot2   byte    %8.0g      V56010_8   Frequently worried or often seems worried
childSDQPsoc3   byte    %8.0g      V56010_9 * Helpful if someone is hurt, upset or feeling ill
childSDQHype2   byte    %8.0g      V530_A     Constantly fidgeting or squirming
childSDQPeer2   byte    %8.0g      V531_A     Has at least one good friend
childSDQCond3   byte    %8.0g      V532_A   * Often fights with other children or bullies them
childSDQEmot3   byte    %8.0g      V533_A     Often unhappy, depressed or tearful
childSDQPeer3   byte    %8.0g      V534_A     Generally liked by other children
childSDQHype3   byte    %8.0g      V535_A     Easily distracted, concentration wanders
childSDQEmot4   byte    %8.0g      V536_A   * Nervous or clingy in new situations, easily loses confidence
childSDQPsoc4   byte    %8.0g      V537_A     Kind to younger children
childSDQCond4   byte    %8.0g      V538_A     Often lies or cheats
childSDQPeer4   byte    %8.0g      V539_A     Picked on or bullied by other children
childSDQPsoc5   byte    %8.0g      V540_A   * Often offers to help others (parents, teachers, other children)
childSDQHype4   byte    %8.0g      V541_A     Thinks things out before acting
childSDQCond5   byte    %8.0g      V542_A   * Steals from home, school or elsewhere
childSDQPeer5   byte    %8.0g      V543_A     Gets along better with adults than with other children
childSDQEmot5   byte    %8.0g      V544_A     Many fears, easily scared
childSDQHype5   byte    %8.0g      V545_A   * Good attention span, sees work through to the end

childSDQEmot_~e byte    %9.0g                 SDQ emotional symptoms score - Mother reports
childSDQCond_~e byte    %9.0g                 SDQ conduct problems score - Mother reports
childSDQHype_~e byte    %9.0g                 SDQ hyperactivity/inattention score - Mother reports
childSDQPeer_~e byte    %9.0g                 SDQ peer problems score - Mother reports
childSDQPsoc_~e byte    %9.0g                 SDQ prosocial score - Mother reports
childSDQ_score  byte    %9.0g                 SDQ Total difficulties score - Mother reports

*** HEALTH AND HABITS (26)

childHealth     byte    %8.0g      V38110     Child general health (high = sick) - Mother reports
childSickDays   byte    %8.0g      V38120   * Child number of sick days
childSleep      byte    %10.0g                On average, how many hours do you sleep a night? CHILD
childHeight     int     %10.0g                Child Height
childWeight     int     %10.0g                Child Weight
childDoctor     byte    %8.0g      V38150   * How long has it been since your child last visited a doctor or dentist for a
                                                rou
childAsthma_d~g byte    %8.0g      LABW       asthma (has your child ever been diagnosed with...)
childAllerg_d~g byte    %8.0g      LABW       allergies (has your child ever been diagnosed with...)
childDigest_d~g byte    %8.0g      LABW       digestive problems (has your child ever been diagnosed with...)
childEmot_diag  byte    %8.0g      LABW       emotional problems (has your child ever been diagnosed with...)
childSleep_diag byte    %8.0g      LABW       sleeping problems (has your child ever been diagnosed with...)
childGums_diag  byte    %8.0g      LABW     * gum disease (gingivitis; periodontal disease) or tooth loss because of
                                                cavities
childOther_diag byte    %8.0g      LABW       other (e.g.cancer, leukemia, diabetes, etc.) (has your child ever been
                                                diagnosed
childNone_diag  byte    %8.0g      LABW       none of these (has your child ever been diagnosed with...)

childBreakfast  byte    %8.0g      V40120_2 * In a typical week, how many times do you have breakfast? CHILD
childFruit      byte    %8.0g      V56130_2 * Frequency eating fruit, child
childSnackNo    byte    %8.0g      LABY       Never Snack (usually eat as snack, child)
childSnackFruit byte    %8.0g      LABY       Eat fruit as snack, child
childSnackIce   byte    %8.0g      LABY       Ice cream (usually eat as snack, child)
childSnackCandy byte    %8.0g      LABY       Candies, sweets, chocolate bars (usually eat as snack, child)
childSnackRoll  byte    %8.0g      LABY       Cookies, roll cakes, baked goods (usually eat as snack, child)
childSnackChips byte    %8.0g      LABY       Chips, crackers (usually eat as snack, child)
childSnackOther byte    %8.0g      LABY       Other (specify_________) (usually eat as snack, child)
sportTogether   byte    %8.0g      V41150   * Frequencty done sport together (high = a lot)
childBMI        float   %9.0g                 BMI child
childTotal_diag byte    %9.0g                 Total number of diagnosed health problems, child
                                                child												
*** THINGS AT SCHOOL (16)

likeSchool_ch~d byte    %8.0g      V60000_1   Child dislikes school
likeRead        byte    %8.0g      V60000_2   Child dislikes reading
likeMath_child  byte    %8.0g      V60000_3   Child dislikes Math
likeGym         byte    %8.0g      V60000_4 * Child dislikes gym
goodBoySchool   byte    %8.0g      V60090_1   Child not a good boy in class
bullied         byte    %8.0g      V60090_2 * How often do other children bully you?
alienated       byte    %8.0g      V60090_3 * How often do you feel left out of things by children at school?
doGrowUp        byte    %8.0g      LABAA      And finally, what would you like to be when you grow up?
likeTV          byte    %8.0g      V60310_1 * Child dislikes TV
likeDraw        byte    %8.0g      V60310_2   Child dislikes drawing
likeSport       byte    %8.0g      V60310_3   Child dislikes sports
FriendsGender   byte    %12.0g     FriendsGender
                                            * Are your friends mostly boys, mostly girls or a mixture of boys and girls?
bestFriend      byte    %8.0g      V60380     Do you have any best friends?
lendFriend      byte    %8.0g      V60391     Child doesn't lends to friends
favorReturn     byte    %8.0g      V60392     Child doesn't return a favor
revengeReturn   byte    %8.0g      V60393   * Child doesn't seek revenge

*** FEELINGS (11)

funFamily       byte    %8.0g      V60394     Child doesn't have fun in family
worryMyself     byte    %8.0g      LABAB      I keep it to myself (what you do when worried)
worryFriend     byte    %8.0g      LABAB      I tell a friend (what you do when worried)
worryHome       byte    %8.0g      LABAB      I tell someone at home (what you do when worried)
worryTeacher    byte    %8.0g      LABAB      I tell a teacher (what you do when worried)
faceMe          byte    %10.0g                Happy child
faceFamily      byte    %10.0g                Happy family
faceSchool      byte    %10.0g                Happy school
faceGeneral     byte    %10.0g                Happy in general
brushTeeth      byte    %10.0g                How many times do you brush your teeth a day?
candyGame       byte    %13.0g     candy    * How many candies are you willing to give to a classmate?


*** COGNITIVE (20)

IQ1             byte    %9.0g                 
IQ2             byte    %9.0g                 
IQ3             byte    %9.0g                 
IQ4             byte    %9.0g                 
IQ5             byte    %9.0g                 
IQ6             byte    %9.0g                 
IQ7             byte    %9.0g                 
IQ8             byte    %9.0g                 
IQ9             byte    %9.0g                 
IQ10            byte    %9.0g                 
IQ11            byte    %9.0g                 
IQ12            byte    %9.0g                 
IQ13            byte    %9.0g                 
IQ14            byte    %9.0g                 
IQ15            byte    %9.0g                 
IQ16            byte    %9.0g                 
IQ17            byte    %9.0g                 
IQ18            byte    %9.0g                 
IQ_factor       float   %9.0g                 dv: Respondent mental ability. Raven matrices - factor score
IQ_score        float   %9.0g                 Respondent mental ability. % of correct answers (Raven matrices)


*/

*** no flip dummy

sum difficultiesNone childinvMusic childinvSport childinvDance childinvTheater childinvOther childnoSickDays childNone_diag childSnackFruit childSnackIce worryFriend worryHome ///
worryTeacher faceMe_bin faceFamily_bin faceSchool_bin faceGeneral_bin IQ1 IQ2 IQ3 IQ4 IQ5 IQ6 IQ7 IQ8 IQ9 IQ10 IQ11 IQ12 IQ13 IQ14 IQ15 IQ16 IQ17 IQ18 bestFriend

desc difficultiesNone childinvMusic childinvSport childinvDance childinvTheater childinvOther  childNone_diag childSnackFruit childSnackIce worryFriend worryHome ///
worryTeacher IQ1 IQ2 IQ3 IQ4 IQ5 IQ6 IQ7 IQ8 IQ9 IQ10 IQ11 IQ12 IQ13 IQ14 IQ15 IQ16 IQ17 IQ18 bestFriend

/*** flip these dummies (higher = better): do this in the analysis do file, otherwise things get messed up

sum difficultiesSit difficultiesInterest difficultiesObey difficultiesEat ///
childAsthma_* childAllerg_* childDigest_* childEmot_diag childSleep_diag childGums_diag childOther_diag childSnackNo childSnackCan childSnackRoll  ///
childSnackChips childSnackOther  worryMyself 

desc difficultiesSit difficultiesInterest difficultiesObey difficultiesEat ///
childAsthma_* childAllerg_* childDigest_* childEmot_diag childSleep_diag childGums_diag childOther_diag childSnackNo childSnackCan childSnackRoll  ///
childSnackChips childSnackOther  worryMyself

foreach j in difficultiesSit difficultiesInterest difficultiesObey difficultiesEat ///
childAsthma_ childAllerg_ childDigest_ childEmot_diag childSleep_diag childGums_diag childOther_diag childSnackNo childSnackCan childSnackRoll  ///
childSnackChips childSnackOther  worryMyself {

replace `j'= 1-`j'
label var `j' "`j' flipped"
} 
*/

sum difficultiesSit difficultiesInterest difficultiesObey difficultiesEat ///
childAsthma_* childAllerg_* childDigest_* childEmot_diag childSleep_diag childGums_diag childOther_diag childSnackNo childSnackCan childSnackRoll  ///
childSnackChips childSnackOther  worryMyself 

*** create some dummies
local varCreate childinvReadTo  childinvFamMeal childinvChoresRoom childinvChoresHelp childinvChoresHomew childinvReadSelf  childFriends ///
childSleep childHeight childBreakfast childFruit sportTogether bullied alienated revengeReturn brushTeeth ///
candyGame IQ_score IQ_factor childSDQHype1 childSDQHype2 childSDQHype3 childSDQEmot1 childSDQEmot2 ///
childSDQEmot3 childSDQEmot4 childSDQEmot5 childSDQCond1 childSDQCond3 childSDQCond4 childSDQCond5 childSDQPeer1 childSDQPeer4 childSDQPeer5

sum `varCreate'
des `varCreate'

tab doGrowUp, m
tab doGrowUp, gen(doGrowUp)
replace doGrowUp1 = 0 if(doGrowUp1 == .)
drop doGrowUp
ren doGrowUp1 doGrowUp

tab FriendsGender
tab FriendsGender, nol
gen FriendsGender_bin = (FriendsGender == 0)
label var FriendsGender_bin "Friends from both genders"

foreach j in `varCreate'{

sum `j', d
gen dummy1 = (`j' > r(p50)) if `j'<.
gen dummy2 = (`j' >= r(p50)) if `j'<.
sum dummy1
gen diff1 = abs(r(mean)-0.5)
sum dummy2
gen diff2 = abs(r(mean)-0.5)
gen `j'_bin = dummy1 if(diff1 <= diff2)
replace `j'_bin = dummy2 if(diff1 > diff2)
drop dummy1 dummy2 diff1 diff2
label var `j'_bin "Dummy for `j'"
} 

sum childinvReadTo_bin childinvFamMeal_bin childinvChoresRoom_bin childinvChoresHelp_bin childinvChoresHomew_bin childinvReadSelf_bin childFriends_bin ///
childSleep_bin childHeight_bin childBreakfast_bin childFruit_bin sportTogether_bin bullied_bin alienated_bin revengeReturn_bin brushTeeth_bin ///
candyGame_bin IQ_score_bin IQ_factor_bin childSDQHype1_bin childSDQHype2_bin childSDQHype3_bin childSDQEmot1_bin childSDQEmot2_bin ///
childSDQEmot3_bin childSDQEmot4_bin childSDQEmot5_bin childSDQCond1_bin childSDQCond3_bin childSDQCond4_bin childSDQCond5_bin childSDQPeer1_bin childSDQPeer4_bin childSDQPeer5_bin ///
doGrowUp FriendsGender_bin

*** crate and flip some dummy (higher = better)
local varCreflip childinvTV_hrs childinvVideoG_hrs childHealth childWeight childDoctor childBMI childTotal_diag /// difficulties
likeSchool_child likeRead likeMath_child likeGym goodBoySchool likeTV likeDraw likeSport lendFriend favorReturn funFamily ///
childinvCom childinvOut ///
childSDQPsoc1 childSDQPsoc2 childSDQPsoc3 childSDQPsoc4 childSDQPsoc5 ///
childSDQHype4 childSDQHype5 childSDQCond2 childSDQPeer2 childSDQPeer3 ///
childSDQ????_score childSDQ_score childSDQ_factor ///

des `varCreflip'
sum `varCreflip'
foreach j of varlist `varCreflip'{

sum `j', d
gen dummy1 = (`j' > r(p50)) if `j'<.
gen dummy2 = (`j' >= r(p50)) if `j'<.
sum dummy1
gen diff1 = abs(r(mean)-0.5)
sum dummy2
gen diff2 = abs(r(mean)-0.5)
gen `j'_bin = dummy1 if(diff1 <= diff2)
replace `j'_bin = dummy2 if(diff1 > diff2)
drop dummy1 dummy2 diff1 diff2
replace `j'_bin= 1-`j'_bin
label var `j'_bin "Dummy for `j' (flipped)"
} 

sum childinvTV_hrs_bin childinvVideoG_hrs_bin childHealth_bin childWeight_bin childDoctor_bin childBMI_bin childTotal_diag_bin /// difficulties_bin 
likeSchool_child_bin likeRead_bin likeMath_child_bin likeGym_bin goodBoySchool_bin likeTV_bin likeDraw_bin likeSport_bin lendFriend_bin favorReturn_bin funFamily_bin ///
childinvCom_bin childinvOut_bin ///
childSDQPsoc1_bin childSDQPsoc2_bin childSDQPsoc3_bin childSDQPsoc4_bin childSDQPsoc5_bin ///
childSDQHype4_bin childSDQHype5_bin childSDQCond2_bin childSDQPeer2_bin childSDQPeer3_bin childSDQ*score_bin

*** full list of outcomes for children

sum difficultiesSit difficultiesInterest difficultiesObey difficultiesEat difficultiesNone ///
childinvReadTo_bin childinvMusic childinvCom_bin childinvTV_hrs_bin childinvVideoG_hrs_bin childinvOut_bin childinvFamMeal_bin childinvChoresRoom_bin childinvChoresHelp_bin ///
childinvChoresHomew_bin ///
childinvReadSelf_bin childinvSport childinvDance childinvTheater childinvOther childFriends_bin ///
childSDQPsoc1_bin childSDQPsoc2_bin childSDQPsoc3_bin childSDQPsoc4_bin childSDQPsoc5_bin childSDQPsoc_score_bin /// childSDQPsoc_factor_bin 
childSDQHype1_bin childSDQHype2_bin childSDQHype3_bin childSDQHype4_bin childSDQHype5_bin childSDQHype_score_bin /// childSDQHype_factor_bin 
childSDQEmot1_bin childSDQEmot2_bin childSDQEmot3_bin childSDQEmot4_bin childSDQEmot5_bin childSDQEmot_score_bin /// childSDQEmot_factor_bin 
childSDQCond1_bin childSDQCond2_bin childSDQCond3_bin childSDQCond4_bin childSDQCond5_bin childSDQCond_score_bin /// childSDQCond_factor_bin 
childSDQPeer1_bin childSDQPeer2_bin childSDQPeer3_bin childSDQPeer4_bin childSDQPeer5_bin childSDQPeer_score_bin /// childSDQPeer_factor_bin 
childSDQ_score_bin childSDQ_factor_bin /// 
childHealth_bin childnoSickDays_bin childSleep_bin childHeight_bin childWeight_bin childDoctor_bin childAsthma_diag childAllerg_diag childDigest_diag childEmot_diag ///
childSleep_diag childGums_diag childOther_diag childNone_diag childBreakfast_bin childFruit_bin childSnackNo childSnackFruit childSnackIce ///
childSnackCan childSnackRoll childSnackChips childSnackOther sportTogether_bin childBMI_bin childTotal_diag_bin /// 
likeSchool_child_bin likeRead_bin likeMath_child_bin likeGym_bin goodBoySchool_bin bullied_bin alienated_bin doGrowUp likeTV_bin likeDraw_bin likeSport_bin /// 
FriendsGender_bin bestFriend lendFriend_bin favorReturn_bin revengeReturn_bin ///
funFamily_bin worryMyself worryFriend worryHome worryTeacher faceMe_bin faceFamily_bin faceSchool_bin faceGeneral_bin brushTeeth_bin candyGame_bin ///
IQ1 IQ2 IQ3 IQ4 IQ5 IQ6 IQ7 IQ8 IQ9 IQ10 IQ11 IQ12 IQ13 IQ14 IQ15 IQ16 IQ17 IQ18 IQ_score_bin IQ_factor_bin 

*----------------------* Put some labels and save the data *----------------------------*
// Give a label to all the variables (taken from codebook_All.xlsx)
do $dir/Analysis/data-construction/varLabels.do 

// Take away labels that are too long and prevent saving to stata13

foreach var of varlist pos_SDQ????? pos_childSDQ????? pos_Locus?{
label var `var' "RECODE to higher = better"
}


//save the data
compress
saveold Reggio_all.dta, replace

// Drop the strange interviews from Padova (n=368)
drop if source==2 //3-strange-interviewers from Padova
saveold Reggio.dta, replace

/* PILOT: all the changes in the variables have not been made, so the variables (maybe with the same name) are not necessary comparable
use Reggio_all.dta
append using ReggioAdultPilot.dta, generate(Pilot) force //cithBirth is string in Pilot
replace source = 0 if Pilot==1 // August 2012 Pilot
tab source, miss
saveold Reggio_all.dta, replace
*/

/* Data for the maps
use Reggio_all.dta, clear
label define temp 1 "Reggio nell'Emilia" 2 "Parma" 3 "Padova"
label values City temp

gen     Province = "RE" if City==1
replace Province = "PR" if City==2
replace Province = "PD" if City==3
tab City Province, miss

gen     Region = "Emilia-Romagna" if City==1 | City==2
replace Region = "Veneto" if City==3

gen Country = "Italy"

outsheet intnr internr Cohort City Address Province Region Country /// 
         asiloType maternaType asiloname_manual maternaname_manual *NotCity /// asiloType maternaType 
		 source CAPI Male Age Migrant PA MaxEdu *IncomeCat ///
	 using ./Maps/ReggioSurveyMap.csv, comma replace //nolabel
*/

/* For the codebook:
use Reggio.dta, clear
logout, replace save(temp_sum) dta: sum

use temp_sum, clear
rename v1 Variable
rename v2 Obs
rename v3 Mean
rename v4 StdDev
rename v5 Min
rename v6 Max
drop if inlist(_n,1)
gen position_all = _n
destring _all, replace
save temp_sum, replace

foreach data in Child Ado Adult AdultPilot{
	use Reggio`data', clear
	describe, replace
	gen data`data' = 1
	save Describe`data', replace
}
use Reggio, clear
describe, replace
gen dataAll = 1
rename position position_all
save DescribeAll, replace

use DescribeChild, clear
merge 1:1 name using DescribeAdo, gen(_mergeAdo)
merge 1:1 name using DescribeAdult, gen(_mergeAdult)
//merge 1:1 name using DescribeAdultPilot, gen(_mergeAdultPilot)
merge 1:1 name using DescribeAll, gen(_mergeAll) 
drop _merge*

replace varlab= subinstr(varlab,"è","e'",.)
replace varlab= subinstr(varlab,"é","e'",.)
replace varlab= subinstr(varlab,"�","e'",.)
replace varlab= subinstr(varlab,"�","e'",.)
replace varlab= subinstr(varlab,"È","E'",.)
replace varlab= subinstr(varlab,"É","E'",.)
replace varlab= subinstr(varlab,"ì","i'",.)
replace varlab= subinstr(varlab,"ù","u'",.)
replace varlab= subinstr(varlab,"�","u'",.)
replace varlab= subinstr(varlab,"�","U'",.)
replace varlab= subinstr(varlab,"ò","o'",.)
replace varlab= subinstr(varlab,"�","o'",.)
replace varlab= subinstr(varlab,"À","A'",.)
replace varlab= subinstr(varlab,"’","'",.)
replace varlab= subinstr(varlab,"�","'",.)
replace varlab= subinstr(varlab,"�","'",.)
replace varlab= subinstr(varlab,"�","a'",.)
replace varlab= subinstr(varlab,"�","a'",.)
replace varlab= subinstr(varlab,"�","a'",.)
replace varlab= subinstr(varlab,"�"," ",.)
* charlist(varlab) //check there are no weird characters

 
merge 1:1 position_all using temp_sum
drop _merge

order position position_all

browse

rm temp_sum.dta
rm DescribeChild.dta
rm DescribeAdo.dta
rm DescribeAdult.dta
rm DescribeAdultPilot.dta
rm DescribeAll.dta
rm temp_sum.txt
*/
}
if $check==1{ // Quality Checks: look at particular subgroups and understand if there reporting errors
use Reggio.dta, clear
cd tables

*-----------------------------------------------------* 
*   Duplicates
*-----------------------------------------------------* 
sort Date_int intnr
global Family	famSize childrenSib* children0_18 Male mom noMom dad noDad Gender* momGender dadGender cgGender  ///
			hhead* house* lang* nationality yrItaly yrCity age* livedAway *Migrant ///
			Migrant2-Migrant10 *Relation* *BornCity* *Birthday* yob* /// Age* momAge dadAge dadAge ???AgeBirth* 
			cgAge *BirthState* *BornIT* *ITNation* *Status* *PA* *MaxEdu* student
duplicates tag $Family if Twin!=1, gen(dupFamily)
//browse if dupFamily==1

global Family2 famSize-dadMaxEdu
duplicates tag $Family2 , gen(dupFamily2)
tab dupFamily*
//browse if dupFamily2==1
** MANUALLY CHECKING WE FOUND ALSO THESE ADDITIONAL INTERVIEWS BY THE SAME INTERVIEWERS
gen dupManual = (intnr == 38752200 | intnr == 38752300 | intnr == 39572500 | intnr == 39572600 | intnr == 39574600 | intnr == 39574700 | intnr == 50032400 | intnr == 50032500 | intnr == 50077900 | intnr == 50078000 )
//browse if dupManual==1

global FamShort City Cohort famSize Birthday Birthday? //PA PA? mStatus mStatus?
duplicates tag $FamShort , gen(dupFamShort)
tab dupFamShort dupFamily
// browse intnr internr dup* Cohort City Address Date_int stime CAPI famSize Male cgGender Gender* Age cgAge Age? Birthday Birthday? Relation? cgRelation if dupFamShort==1
// a lot of them are living alone and born on the same date. This is plausible

duplicates tag City Address, gen(dupAddress)
tab dupAddress TwinInData
// browse intnr internr dup* Cohort City Address Date_int stime CAPI famSize Male cgGender Gender* Age cgAge Age? Birthday Birthday? Relation? cgRelation if dupFamShort==1
// there are quite a few, but 

*-----------------------------------------------------* 
*   IQ Test
*-----------------------------------------------------* 
/* Create a data only with IQ related information:
use Reggio, clear
keep intnr internr Cohort City CAPI Male Age cgGender cgAge *IQ*
drop *factor *score Miss* avgINR*
// merge with original answers
*child
merge 1:1 intnr using $dir/child_original.raw/S11174BAMBINI14Feb.dta, keepusing(V42401_* V52401_*) gen(_mergeChildIQ) //NOTE: must destring the data
*ado
merge 1:1 intnr using $dir/ado_original.raw/S11174RAGAZZI14Mar.dta, keepusing(V42401_* V242401_*) gen(_mergeAdoIQ) //NOTE: must destring the data
drop if _mergeAdoIQ==2 //the two wrong interviews
*adult
merge 1:1 intnr using $dir/adults_original.raw/S11174Adulti28Mar.dta, keepusing(V42401_*)  gen(_mergeAdultIQ) //NOTE: must destring the data
save $dir/ReggioIQ, replace
*/

tabstat cgIQ_* 

* Time
tabstat cgIQtime IQtime if CAPI==1, by(Cohort) stat(mean sd median min max)
hist IQtime if IQtime<5
hist IQtime if IQtime<5 & CAPI==1
hist IQtime if IQtime<5 & CAPI==0
twoway (kdens IQtime if CAPI==1) (kdens IQtime if CAPI==0) if IQtime<5 ///
   , legend(label (1 "CAPI") label (2 "PAPI")) title("Time spent on IQ test (minutes)")
graph export IQtime.png, replace
* Score
tabstat cgIQ_* IQ_* , by(Cohort) stat(mean sd median min max)
twoway (kdens IQ_score if CAPI==1) (kdens IQ_score if CAPI==0) ///
   , legend(label (1 "CAPI") label (2 "PAPI")) title("IQ score - percentage correct")
graph export IQ_score.png, replace
twoway (kdens IQ_factor if CAPI==1) (kdens IQ_factor if CAPI==0) ///
   , legend(label (1 "CAPI") label (2 "PAPI")) title("IQ factor score, by interview mode")
graph export IQ_factor.png, replace

twoway /// 
(kdens IQ_factor if Cohort==1) ///
(kdens IQ_factor if Cohort==2) ///
(kdens IQ_factor if Cohort==3) ///
(kdens IQ_factor if Cohort==4) ///
(kdens IQ_factor if Cohort==5) ///
(kdens IQ_factor if Cohort==6) ///
  if CAPI==1 , legend(label (1 "Children") label (2 "Immigrants") label (3 "Adolescets") label (4 "Adults-30s") label (5 "Adults-40s") label (6 "Adults-50s")) ///
  title("IQ factor score, CAPI only, by Cohort")
graph export IQ_factor-CAPI-cohort.png, replace

twoway /// 
(kdens IQ_factor if Cohort==1) ///
(kdens IQ_factor if Cohort==2) ///
(kdens IQ_factor if Cohort==3) ///
(kdens IQ_factor if Cohort==4) ///
(kdens IQ_factor if Cohort==5) ///
(kdens IQ_factor if Cohort==6) ///
  if CAPI==0 , legend(label (1 "Children") label (2 "Immigrants") label (3 "Adolescets") label (4 "Adults-30s") label (5 "Adults-40s") label (6 "Adults-50s")) ///
  title("IQ factor score, PAPI only, by Cohort")
graph export IQ_factor-PAPI-cohort.png, replace


*-----------------------------------------------------* 
*   Interviewers
*-----------------------------------------------------* 

tab internr City, miss
gen inter2437 = (internr == 2437) if (Cohort==2 & City == 3) // only for Padova Immigrants
tab internr inter2437, miss

tab City Cohort if internr==2526
gen inter2526 = (internr == 2526) if (Cohort==1 | Cohort==3 ) & (City==1 | City == 3) // Reggio and Padova, children and Adolescents
tab internr inter2526, miss

capture drop interPadova
gen interPadova = (internr == 174 | internr == 175 | internr == 2525) if (City == 3 & Cohort>3) // only for Padova adults
tab internr interPadova, miss
tab Cohort interPadova 

gen interHigh = (internr == 170 | internr == 184 | internr == 186 | internr == 187) if (City != 3 & Cohort>3) // only for Padova adults
tab internr interHigh, miss
tab interHigh Cohort, miss

gen inter173 = (internr == 173) if (City == 1 & Cohort>3) // only for Reggio
gen interRandom = (internr == 4037 | internr == 4035 | internr == 2544 | internr == 4043 | internr == 4044 | internr == 4045) if (City == 3 & Cohort>3) // only for Padova adults
tab internr interRandom // random interviewers, place test 

capture drop interPadova_all
gen interPadova_all = (interPadova==1)
gen interRandom_all = (interRandom==1)
gen inter2437_all = (inter2437==1)
gen inter2526_all = (inter2526==1)
tab internr interPadova_all

*-*-*-* (1) Income Category; especially for immigrants
* The first income category is 1 to 5,000 euros: we would expect basically NOBODY to be there, yet there's a lot!
local var IncomeCat
bys Cohort: tab cg`var' City, column //problem mosty for immigrants in Padova
bys Cohort: tab `var' City, column //little problem for adult 30 in Reggio

local var IncomeCat
bys internr: tab cg`var' City if Cohort==2, column 
tab cg`var' CAPI if internr == 2437, column //espcially problematic for this interviewer
tab cg`var' inter2437, column 
list cgWage cg`var' if internr == 2437
/*
Probably they answered using the same time-category as the wages that was reported above
Paolo confirmed
*/

*-*-*-* (2) Health; especially for Padova (immigrant and adult-30)
local var Health
bys Cohort: tab cg`var' City, column //problem mosty for immigrants in Padova
bys Cohort: tab `var' City, column //problem mosty for adult 30 in Padova

local var Health
bys internr: tab cg`var' City if Cohort==2, column
tab cg`var' CAPI if internr == 2437, column //espcially problematic for this interviewer
tab cg`var' inter2437 if City==3 & Cohort==2, column 
tab cg`var' inter2437_all, column 

local var Health
tab cg`var' CAPI if internr == 2526, column //espcially problematic for this interviewer
tab cg`var' inter2526 if City==3 & Cohort==3, column 
tab cg`var' inter2526 if City==3 & Cohort==1, column 
tab cg`var' inter2526 if City==1 & Cohort==3, column 
tab cg`var' inter2526 if City==1 & Cohort==1, column 
tab cg`var' inter2526 , column 

local var Health
tab `var' CAPI if internr == 2526, column //espcially problematic for this interviewer
tab `var' inter2526 if City==3 & Cohort==3, column 
tab `var' inter2526 if City==1 & Cohort==3, column 
tab `var' inter2526 , column 

local var Health
bys internr: tab `var' City if Cohort==4, column //problem mosty for only for immigrants
tab `var' Cohort if internr == 2526, column //espcially problematic for this interviewer
tab `var' Cohort if internr == 2525, column //espcially problematic for this interviewer
tab `var' Cohort if internr == 175, column
tab `var' Cohort if internr == 174, column
tab `var' Cohort if internr == 173, column
tab `var' interPadova_all, column
tab `var' interPadova, column
tab `var' interPadova if Cohort==4, column
tab `var' interPadova if Cohort==4 & CAPI==0, column

*placebo
local var Health
tab `var' interRandom_all if Cohort==4 & interPadova!=1, column 
tab `var' interRandom_all if  interPadova!=1, column // not clear if interPadova is very high, or interRandom is very low!!

/* Some Graphs
twoway histogram cgHealth if Cohort==2 & City==2, bfcolor(none) blcolor(pink) || histogram cgHealth if  Cohort==2 & City==3, bfcolor(none) blcolor(blue) || hist cgHealth if Cohort==2 & City==1, bfcolor(none) blcolor(green)
local var IQ_score
twoway histogram `var' if interPadova!=1, bfcolor(none) blcolor(pink) || histogram `var' if interPadova==1, bfcolor(none) blcolor(blue) 
twoway (kdens `var' if interPadova!=1) (kdens `var' if interPadova==1), legend(label (1 "Others") label (2 "Padova Strange"))
*/

*-*-*-* (3) Stress; especially for Padova
local var Stress
bys Cohort: tab cg`var' City, column //little problem for immigrants in Reggio
bys Cohort: tab `var' City, column //problem mosty for all adults in Padova

local var Stress
bys internr: tab cg`var' City if Cohort==2, column //problem mosty for only for immigrants
tab cg`var' CAPI if internr == 2437, column
tab cg`var' inter2437 if City==3 & Cohort==2, column 
tab cg`var' inter2437, column 

local var Stress
tab cg`var' CAPI if internr == 2526, column //espcially problematic for this interviewer
tab cg`var' inter2526 if City==3 & Cohort==3, column 
tab cg`var' inter2526 if City==3 & Cohort==1, column 
tab cg`var' inter2526 if City==1 & Cohort==3, column 
tab cg`var' inter2526 if City==1 & Cohort==1, column 
tab cg`var' inter2526 , column 

local var Stress
tab `var' CAPI if internr == 2526, column //espcially problematic for this interviewer
tab `var' inter2526 if City==3 & Cohort==3, column 
tab `var' inter2526 if City==1 & Cohort==3, column 
tab `var' inter2526 , column 

local var Stress
bys internr: tab `var' City if Cohort==4, column //problem mosty for only for immigrants
tab `var' Cohort if internr == 2525, column
tab `var' Cohort if internr == 175, column
tab `var' Cohort if internr == 174, column
tab `var' interPadova , column

*-*-*-* (4) Satisfied: Health, School, Family, Work, Income
foreach var in SatisHealth SatisSchool SatisFamily SatisWork SatisIncome{
	//local var SatisHealth //Especially Padova (adult 30) 
	di "-------------------Looking at the dimension: `var'"
	tab `var' City, column //problem mosty for only for immigrants
}

foreach var in SatisHealth SatisSchool SatisFamily SatisWork SatisIncome{
	di "-------------------Looking at the dimension: `var'"
	//tab `var' Cohort if internr == 2525, column
	//tab `var' Cohort if internr == 175, column
	//tab `var' Cohort if internr == 174, column
	tab `var' interPadova , column 
	tab `var' interPadova if Cohort==4, column 
}

*-*-*-* (5) IQ; especially for Padova
global noInter    IQtime CAPI Parma Padova Cohort_* Age Age_sq Male famSize_* MaxEdu_* PA_* mStatus_* // mStatus is there only for adults!
global IQcontrols $noInter inter_*
reg IQ_score                               $noInter, robust
reg IQ_score                               $IQcontrols, robust
xi: reg IQ_score                               $IQcontrols i.internr, robust
reg IQ_score interPadova_all inter2437_all $IQcontrols, robust
reg IQ_score interPadova_all inter2437_all interRandom_all $IQcontrols, robust

reg IQ_score interPadova, robust 
reg IQ_score interPadova $IQcontrols, robust // THIS IS A BIG PROBLEM!
reg IQ_score inter2437 CAPI Age Age2 Male famSize_*, robust

tabstat IQ_score, by(City)
tabstat IQ_score if interPadova!=1, by(City) // much more similar if I drop them!!
graph bar IQ_score , over(City)
graph bar IQ_score if interPadova!=1, over(City)
graph bar IQ_score , over(interRandom_all)
graph bar IQ_score , over(interPadova_all)

local var IQ_score
twoway (kdens `var' if interPadova!=1  & interHigh!=1) (kdens `var' if interPadova==1) (kdens `var' if interHigh==1), legend(label (1 "Others") label (2 "Padova Strange") label (3 "Reggio Strange"))
twoway (kdens `var' if interPadova==0 ) (kdens `var' if interPadova==1), legend(label (1 "Others") label (2 "Padova Strange"))

/* It doesn't seem like the answered all of the answer the same:
browse V42401_* if (internr == 174 | internr == 175 | internr == 2525) 
*/

egen temp = group(City Cohort), label
tab temp
graph bar IQ_score , over(temp) //big problem in Padova adults
graph bar IQ_score if interPadova!=1, over(temp)

*-*-*-* (6) Depression; especially for Padova
local var Depression_score
twoway (kdens `var' if interPadova!=1  & interHigh!=1) (kdens `var' if interPadova==1) (kdens `var' if interHigh==1), legend(label (1 "Others") label (2 "Padova Strange") label (3 "Reggio Strange"))
twoway (kdens `var' if interPadova==0 ) (kdens `var' if interPadova==1), legend(label (1 "Others") label (2 "Padova Strange"))

*-*-*-* (7) Ladder; especially for Padova
local var ladderToday
twoway (kdens `var' if interPadova!=1  & interHigh!=1) (kdens `var' if interPadova==1) (kdens `var' if interHigh==1), legend(label (1 "Others") label (2 "Padova Strange") label (3 "Reggio Strange"))
twoway (kdens `var' if interPadova==0 ) (kdens `var' if interPadova==1), legend(label (1 "Others") label (2 "Padova Strange"))

local var ladderPast
twoway (kdens `var' if interPadova!=1  & interHigh!=1) (kdens `var' if interPadova==1) (kdens `var' if interHigh==1), legend(label (1 "Others") label (2 "Padova Strange") label (3 "Reggio Strange"))
twoway (kdens `var' if interPadova==0 ) (kdens `var' if interPadova==1), legend(label (1 "Others") label (2 "Padova Strange"))

local var ladderFuture
twoway (kdens `var' if interPadova!=1  & interHigh!=1) (kdens `var' if interPadova==1) (kdens `var' if interHigh==1), legend(label (1 "Others") label (2 "Padova Strange") label (3 "Reggio Strange"))
twoway (kdens `var' if interPadova==0 ) (kdens `var' if interPadova==1), legend(label (1 "Others") label (2 "Padova Strange"))

*-*-*-* (8) Interview Date; interPadova tends to interview later
local var Date_int
tabstat `var', by(interPadova) stat(mean min max) format
sum `var' if interPadova<.
local low=r(min)
local high=r(max)
local step=round((`high'-`low')/5)
//twoway (kdens `var' if interPadova!=1  & interHigh!=1) (kdens `var' if interPadova==1) (kdens `var' if interHigh==1), legend(label (1 "Others") label (2 "Padova Strange") label (3 "Reggio Strange"))
twoway (kdens `var' if interPadova==0 ) (kdens `var' if interPadova==1), ///
       xlabel(`low'(`step')`high' , format(%td)) legend(label (1 "Others") label (2 "Padova Strange"))
twoway histogram `var' if interPadova==0, bfcolor(none) blcolor(green) ///
    || histogram `var' if interPadova==1, bfcolor(none) blcolor(blue) 

*-*-*-* (9) Interview Time; interPadova tends to interview later
*Time taken to answer the IQ test
capture drop temp
egen temp = group (CAPI interPadova), label

local var IQtime
tabstat `var', by(temp) stat(mean median min max) 
tabstat `var' if CAPI==1, by(interPadova) stat(mean median min max) 
twoway (kdens `var' if interPadova==0 ) (kdens `var' if interPadova==1), legend(label (1 "Others") label (2 "Padova Strange"))
twoway (kdens `var' if interPadova==0 & CAPI==1) (kdens `var' if interPadova==1 & CAPI==1), legend(label (1 "Others") label (2 "Padova Strange"))

*Time taken to input infor in the questionnaire
local var inttime //IntTime
tabstat `var', by(temp) stat(mean median min max) 
tabstat `var' if CAPI==1, by(interPadova) stat(mean median min max) 
twoway (kdens `var' if interPadova==0 ) (kdens `var' if interPadova==1), legend(label (1 "Others") label (2 "Padova Strange"))
twoway (kdens `var' if interPadova==0 & CAPI==1) (kdens `var' if interPadova==1 & CAPI==1), legend(label (1 "Others") label (2 "Padova Strange")) title("Interview Duration (min), Padova Adults")
graph export Duration_Padova.png, replace

local var inttime //IntTime
twoway (kdens `var' if interPadova==0 & CAPI==1 & Cohort==4) (kdens `var' if interPadova==1 & CAPI==1 & Cohort==4), legend(label (1 "Others") label (2 "Padova Strange")) title("Interview Duration (min), Padova 30 year old")
graph export Duration_Padova30.png, replace
twoway (kdens `var' if interPadova==0 & CAPI==1 & Cohort==5) (kdens `var' if interPadova==1 & CAPI==1 & Cohort==5), legend(label (1 "Others") label (2 "Padova Strange")) title("Interview Duration (min), Padova 40 year old")
graph export Duration_Padova40.png, replace
twoway (kdens `var' if interPadova==0 & CAPI==1 & Cohort==6) (kdens `var' if interPadova==1 & CAPI==1 & Cohort==6), legend(label (1 "Others") label (2 "Padova Strange")) title("Interview Duration (min), Padova 50 year old")
graph export Duration_Padova50.png, replace

local var IntTime
twoway (kdens `var' if interPadova==0 & CAPI==0 & Cohort==4) (kdens `var' if interPadova==1 & CAPI==0 & Cohort==4), legend(label (1 "Others") label (2 "Padova Strange"))
twoway (kdens `var' if interPadova==0 & CAPI==0 & Cohort==5) (kdens `var' if interPadova==1 & CAPI==0 & Cohort==5), legend(label (1 "Others") label (2 "Padova Strange"))
twoway (kdens `var' if interPadova==0 & CAPI==0 & Cohort==6) (kdens `var' if interPadova==1 & CAPI==0 & Cohort==6), legend(label (1 "Others") label (2 "Padova Strange"))

drop temp

*-*-*-* (**) Try Everything on the two interviewers dummies
global controls       CAPI Parma Padova Cohort_*      Age Age_sq Male famSize_* MaxEdu_* PA_* inter_*
global controlsPadova CAPI              Cohort_Adult* Age Age_sq Male famSize_* MaxEdu_* PA_* inter_yeardoxa inter_Age inter_local inter_Male // inter_* -- not enough variation

reg IQ_score interPadova_all inter2437_all IQtime $controls, robust
outreg2 using badInternr.out, brack se replace nolabel aster

replace Health = childHealth if Health>=.
ologit Health interPadova_all inter2437_all $controls, robust iter(200)
ologit Health interPadova CAPI Cohort_Adult* Age Age_sq Male famSize_* MaxEdu_* PA_*, robust iter(200) 
ologit Health interPadova CAPI Cohort_Adult* Age Age_sq Male famSize_* MaxEdu_* PA_* inter_*, robust iter(200) // controlling for interviewer characteristics make it go away
ologit Health interPadova                   $controlsPadova, robust iter(200)
 

foreach var of varlist momMaxEdu dadMaxEdu student asilo materna /// asiloStat_self asiloMuni_self asiloPubb_self asiloReli_self asiloPriv_self asiloDK_self 
	/// maternaStat_self maternaMuni_self maternaPubb_self maternaReli_self maternaPriv_self maternaDK_self 
	momWorking06 incentive cgEmpl hhEmpl cgUnempl hhUnempl childinvMusic childinvCom childinvTV_hrs childinvVideoG_hrs childinvOut ///  
	cgHealth childHealth cgSocialMeet cgPolitics cgSatisEdu cgReligType cgFaith childRelig cgTimeWork cgTimeFriend ///  cgRelig cgTimePrtn cgTimeChild 
	cgTimeFree cgStress cgHomeWork cgChildWork cgMigrIntegr cgMigrAttitude cgMigrProgram cgMigrFriend cgLocus1 cgLocus2 cgLocus3 cgLocus4 cgSmoke ///
	cgTrust1 cgTrust2 cgTrust3 cgIncomeCat cgPension likeSchool_child likeRead likeMath_child likeGym goodBoySchool bullied alienated /// doGrowUp 
	likeTV likeDraw likeSport funFamily worryMyself worryFriend worryHome worryTeacher worry candyGame TimeFriends TimeSib TimeMom /// childSuspended 
	TimeDad TimeGran Fruit SnackNo SnackFruit SnackIce SnackCandy SnackRoll SnackChips SnackOther sport facebookSocNet linkedinSocNet otherSocNet ///
	noSocNet SocialMeet Politics ReligType Faith babyRelig discrNo /// discrAge discrGender TimeSelf TimeParent TimeRelat TimeStudy TimeFriend TimeFree 
	TimeRest TimeUseless Stress Locus1 Locus2 Locus3 Locus4 reciprocity1 reciprocity2 reciprocity3 reciprocity4 SatisHealth SatisSchool SatisFamily ///
	ladderToday ladderFuture ladderPast optimist optimist2 pessimist pessimist2 SmokeEver Trust1 Trust2 Trust3 childrenDum childrenNum childrenResp ///
	children6under asiloYears maternaYear cgMarried Married houseOwn momHome06 difficultiesNone cgHSgrad cgUni dadHSgrad dadUni cgIncome25000 /// votoUniLode HSgrad Uni 
	Income25000 likeSchool likeMath likeLit childHealthPerc cgHealthPerc childFruitDaily Health HealthPerc FruitDaily sportTwice Stressed Satisfied {
	des `var'
	ologit `var' interPadova_all inter2437_all $controls, robust iter(200)
	outreg2 using badInternr.out, brack se append nolabel aster
}

foreach var of varlist *score cgBMI childBMI childz_BMI z_BMI BMI childinvReadTo {
	des `var'
	reg `var' interPadova_all inter2437_all $controls, robust
	outreg2 using badInternr.out, brack se append nolabel aster
}

** Only padova
reg IQ_score interPadova $controlsPadova, robust
outreg2 using badInternrPadova.out, brack se replace nolabel aster

foreach var of varlist momMaxEdu dadMaxEdu asilo materna /// asiloStat_self asiloMuni_self asiloPubb_self asiloReli_self asiloPriv_self asiloDK_self  student
	momWorking06 incentive /// 
	Fruit SnackNo SnackFruit SnackIce SnackCandy SnackRoll SnackChips SnackOther sport facebookSocNet linkedinSocNet otherSocNet ///
	noSocNet SocialMeet Politics ReligType Faith babyRelig /// discrAge discrGender TimeSelf TimeParent TimeRelat TimeStudy TimeFriend TimeFree discrNo 
	TimeFriend TimeFree Stress Locus1 Locus2 Locus3 Locus4 reciprocity1 reciprocity2 reciprocity3 reciprocity4 SatisHealth SatisFamily ///TimeRest TimeUseless SatisSchool 
	ladderToday ladderFuture ladderPast optimist optimist2 pessimist pessimist2 SmokeEver Trust1 Trust2 Trust3 childrenDum childrenNum childrenResp ///
	children6under asiloYears maternaYear Married houseOwn momHome06 HSgrad Uni Income25000 /// votoUniLode HSgrad Uni 
	Income25000 Health HealthPerc FruitDaily sportTwice Stressed Satisfied {
	des `var'
	ologit `var' interPadova $controlsPadova, robust iter(200)
	outreg2 using badInternrPadova.out, brack se append nolabel aster
}

foreach var of varlist Depression_score BMI {
	des `var'
	reg `var' interPadova $controlsPadova, robust
	outreg2 using badInternrPadova.out, brack se append nolabel aster
}

//tabform _all using badinterPadova.txt, by(internPadova) //doesn't work because of string variable

cd ..
}

if $notInter==1{ // Preschool attendance of those who were not intreviewed (info on preshcool obtained via phone contact by DOXA)
import excel "child_original.raw/Reggio children nido materna attendance of the contacts not int-CHILDREN ADO.xls", sheet("DATIFFF5") firstrow clear
saveold notInterviewed.dta, replace

import excel "adults_original.raw/Reggio children nido materna attendance contacts not int ADULTS.xls", sheet("DATIFFF5") firstrow clear
append using notInterviewed

gen Cohort = 1 if COORTE == "BAMBINI"
replace Cohort = 2 if COORTE == "IMMIGRATI"
replace Cohort = 3 if COORTE == "ADOLESCENTI"
replace Cohort = 5 if COORTE == "ADULTI" // THIS IS NOT CORRECT BUT WE DON'T HAVE THE FULL INFO
tab Cohort COORTE
//drop COORTE

egen City = group(CITTA)
replace City = 4-City
tab City CITTA
//drop CITTA

rename COGNOME_NOME Name
rename INDIRIZZO Address
rename N_CONT numContact
rename ESITO Outcome
rename NIDO asilo_Attend
rename MATERNA_MUNIC~E maternaMuni_self
rename MATERNA_RELIG~A maternaReli_self
rename MATERNA_STATALE maternaStat_self
rename MATERNA_NON_F~A materna_NotAttended

replace Outcome ="wrong address, name not present at address" if Outcome == "INDIRIZZO ERRATO, NOME NON PRESENTE ALL'INDIRIZZO"
replace Outcome ="interview completed" if Outcome == "INTERVISTA EFFETTUATA"
replace Outcome ="interview began but not completed" if Outcome == "INTERVISTA INIZIATA MA NON COMPLETATA"
replace Outcome ="interview not completed because of language" if Outcome == "INTERVISTA NON EFFETTUATA PER INCOMPRENSIBILIT� LINGUISTICA"
replace Outcome ="left paper questionnaire" if Outcome == "LASCIATO QUESTIONARIO CARTACEO"
replace Outcome ="gravely ill" if Outcome == "MALATO GRAVE"
replace Outcome ="no person present" if Outcome == "NESSUNA PERSONA PRESENTE"
replace Outcome ="talked with family member, come back later" if Outcome == "PARLATO CON UN FAMILIARE, RIPASSARE"
replace Outcome ="made an appointment for capi interview" if Outcome == "PRESO APPUNTAMENTO PER INTERVISTA CAPI"
replace Outcome ="sharp refusal" if Outcome == "RIFIUTO NETTO"
replace Outcome ="always absent\lives somewhere else\moved" if Outcome == "SEMPRE ASSENTE\VIVE ALTROVE\TRASFERITO"
replace Outcome ="disabled" if Outcome == "SOGGETTO INCAPACE\INABILE"
replace Outcome ="does not have required preschool background" if Outcome == "SOGGETTO NON AVENTE I REQUISITI RICHIESTI IN TERMINI DI SCUOLA MATERNA FREQUENTATA"

compress
saveold notInterviewed.dta, replace

use Reggio, replace
keep intnr Cohort City Address materna*_self maternaType materna materna_NotAttended asilo asilo_Attend asiloType
append using notInterviewed, gen(append)

tab Cohort COORTE // CHECK
tab City CITTA // CHECK
drop CITTA COORTE

replace Outcome = "interview completed" if append==0 & Outcome==""

tabstat asilo_Attend maternaMuni_self maternaReli_self maternaStat_self materna_NotAttended, by(Outcome)
tab Outcome, miss

compress
saveold notInterviewed.dta, replace
}
capture log close
