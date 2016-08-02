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
 local dir "C:\Users\Pietro\Documents\ChicaGo\Heckman\ReggioChildren\SURVEY_DATA_COLLECTION\data"
 local dir "/mnt/ide0/share/klmReggio/SURVEY_DATA_COLLECTION/data"
 local dir "/mnt/ide0/home/biroli/ChicaGo/Heckman/ReggioChildren/SURVEY_DATA_COLLECTION/data"
cd "`dir'"
*/
* log using dataClean_adultPilot, replace

*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* 
*-* Integrating the names and addresses 
*-* of the schools 
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// import excel: name of schools
import excel "./adults_original.raw/11174_ADULTI_2012_APERTE_INDIRIZZI_NIDO_MATERNA.xls", sheet("DATIBT") firstrow clear
save adultVerbatim.dta, replace
// import excel: other open answers
import excel "./adults_original.raw/11174_ADULTI_2012_APERTE_ALTRO.xls", sheet("Aperte") firstrow clear
destring _all, replace
drop COD* Coordinate* RIC // [=] CHECK: I don't really understand what these are. Seem useless
tab ETICHETTA
drop ETICHETTA

reshape wide @VERBATIM, i(INTNR) j(N_DOM_APERTA) string
des *VERBATIM

rename V30020VERBATIM V30020_open
rename V31180VERBATIM V31180_open
rename V31190VERBATIM V31190_open
rename V32230VERBATIM V32230_open
rename V32250VERBATIM V32250_open
rename V32260VERBATIM V32260_open
rename V32270VERBATIM V32270_open
rename V32340VERBATIM V32340_open
rename V32360VERBATIM V32360_open
rename V32371VERBATIM V32371_open
rename V33140VERBATIM V33140_open
rename V33202VERBATIM V33202_open
rename V37230VERBATIM V37230_open
rename V37240VERBATIM V37240_open
rename V39190VERBATIM V39190_open
rename V40200VERBATIM V40200_open
rename V43140VERBATIM V43140_open
rename V43175VERBATIM V43175_open
rename V43210VERBATIM V43210_open
rename V43310VERBATIM V43310_open
rename V44130VERBATIM V44130_open
rename V45260VERBATIM V45260_open
rename V52111VERBATIM V52111_open
rename V52121VERBATIM V52121_open
rename V52180VERBATIM V52180_open
rename V52220VERBATIM V52220_open
label var V30020_open "La vostra abitazione è di proprietà oppure siete in affitto?"
label var V31180_open "Perché ha deciso di non continuare i suoi studi?"
label var V31190_open "Qualcuno ha provato a convincerla a continuare ad andare a scuola?"
label var V32230_open "Ricorda per quali motivi ha frequentato la scuola materna?"
label var V32250_open "Quali aspetti dell'esperienza della scuola materna si ricorda come più importanti?"
label var V32260_open " Ricorda per quali motivi NON ha frequentato l'asilo?"
label var V32270_open " Ricorda per quali motivi NON ha frequentato la scuola materna?"
label var V32340_open " Quale corso di scuola media superiore ha frequentato?"
label var V32360_open " Qual è l'indirizzo del più alto titolo di studio da lei ottenuto?"
label var V32371_open " Altra università:"
label var V33140_open " Quale tipo di contratto ha?"
label var V33202_open " Può dirmi qual è la sua professione attuale?"
label var V37230_open " Di solito chi porta suo\a figlio\a a scuola?"
label var V37240_open " Di solito chi va a prendere suo\a figlio\a a scuola?"
label var V39190_open " Un medico, un infermiere o qualche altro operatore sanitario le ha mai detto che ha:"
label var V40200_open " Di solito, cosa mangia fuori dai pasti?"
label var V43140_open " Fa parte di un club o di un'organizzazione (come un gruppo sportivo, una compagnia teatrale o d'intrattenimento, un'associazione di quartiere, un partito etc...)?"
label var V43175_open " Fa parte di qualche social-network?"
label var V43210_open " Saprebbe dirmi il nome del sindaco di < 19999>?"
label var V43310_open " Si ritiene parte di un gruppo che è discriminato in Italia? Per motivi di?"
label var V44130_open " Qual è la sua principale fonte di stress?"
label var V45260_open " Nei gruppi che frequenta ci sono stranieri?"
label var V52111_open " L'intervistato\a ha chiesto delucidazioni su alcune domande. Per quali domande?"
label var V52121_open " Pensi che l'intervistato fosse riluttante a rispondere a qualche domanda? Per quali domande?"
label var V52180_open " Hai altri commenti da scrivere?"
label var V52220_open " Il modulo da autocompilare dovrebbe essere stato redatto dall'intervistatore senza alcun aiuto da parte tua. Per favore dicci, come mai questo non è successo?"
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
// use ./adults_original.raw/S11174EstensivaAdulti2012_303casi.dta, clear
use ./adults_original.raw/S11174EstensivaAdulti2012_303casi19Dic2013.dta, clear

destring _all, replace

* merge with the School Names and Addresses
merge 1:1 intnr using adultVerbatim.dta, gen(_mergeVerbatim)
tab _merge*, missing // CHECK
gen flagVerbatim = (_mergeVerbatim == 2) //[=] there should be no data coming only from the excel files!!
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


* Order the variables so that they are the same as in the questionnaire
order privacy, last

/*-* decode missing values:
.w = Non indica / Non pertinente (not pertinent)
.a = 'Altro, specificare' (Other, specify) --> kept as an answer not as missing for now
.r = Rifiuto (refuse to respond)
.s = Non so / Non ricordo (Don't know/don't remember)
*/
* Non indica
mvdecode V44110_? V50210_? V51130 V31210_O? V33150 V34210_? V36130  V36140  V37110  V37150  V37180  V37190  V37200_1  V37200_2  V37200_3  V37210 ///
	V38110_1 V38110_2 V38110_3 V38110_4 V38120_1 V38120_2 V38120_3 V38120_4 V38150_1 V38150_2 V38150_3 V38150_4 V38170_1 V38170_2 ///
	V38170_3 V38170_4 V45130 V45180 V45210 V45220 V45230 V45250 V45320_? V48110_? V48150_? V48200_? V48250_? V48250_10 V49150 V49160 V49190 V49250 ///
	V49310 V49330 V50110_? V51110 V51120 V51150 V51170 V51190 V51310 V51320 V51330 ///
	, mv(9 = .s) // Non indica, Non sa, non pertinente
	
mvdecode V49120 V49135 V49170 V49180 V49230 V37251 V37141 V37142 V35150 V37140 V34170 V34180 V33120_1 V33190_1 V33190_2 V33250_1 V31170_1 V482?0 V37240 V37230 V34270_? V34280_? V46110 ///
	V34240_? V33202 V33271 V33280 V33330 V46110 V33140 V30080 V20220_? V20240_? V30020 V37240 V37230 V48240 V48230 V48220 ///
	V43280 V44130 V35170_? ///
	, mv(99 999 9999 99999 = .w) // Non Indica, Non sa

mvdecode V32340 V38130_? V38140_? V37220 V36150 V32380_1 ///
	, mv(999 9999 99999 = .w) // Non Indica, Non sa

mvdecode V41180_? V46115 V46135 V46145_? ///
	, mv(99999 = .w) // Non Indica, Non sa

mvdecode  V34120  V35110_1 V35110_2 ///
	, mv(9999 99999 = .w) // Non Indica, Non sa

mvdecode V45170 V45160 ///
	, mv(9 = .s) // Non sa

mvdecode V34140 ///
	, mv(9 = .r) // non ricorda
	
mvdecode V43250, mv(3 = .s) // non so
mvdecode V35190_? V35200_?, mv(6 = .s) // non so

* Altro
* mvdecode V32370 V32340 V46110 V34270_? V34280_? V33202 V33271 V33280 V33330 V46110 V33140 V32340 V30080 V46110 V30020, mv(97 98 997 998 = .a) // Altro, specificare

* 7=Rifiuto, 8=non so, 9= Non pertinente
mvdecode V35160_? V43210 V44160 V44150 V43320_6 V43320_5 V43320_4 V43320_3 V43320_2 V43320_1 V43270 V43240 V43230 V43180 V42120 V42110 V42200_4 V42200_3 V42200_2 V42200_1 V41210 V40190 V40160 V40130 V40120 V39170 V39160 V39150 V39130 V39120 V39110 ///
   , mv(7 77 7777 = .r \ 8 88 8888 = .s \ 9 99 9999 = .w) // 7=Rifiuto, 8=non so, 9= Non pertinente

mvdecode V43171 V41160 V39141 V43220 V41190 V40110 V41110 V43170 ///
	, mv(77 7777 = .r \ 88 8888 = .s \ 99 9999 = .w) // 7=Rifiuto, 8=non so, 9= Non pertinente

mvdecode V39140 ///
	, mv(777 = .r \ 888 = .s \ 999 = .w) // 7=Rifiuto, 8=non so, 9= Non pertinente


mvdecode V32360 V37230  V37240 V44130 ///
	,mv(98  = .s \ 99 = .r) // 98 = non sa, 99=non risponse, 97 = altro      97 = .a \


recode V32140 V32150 V32200 V32210 (998 = 1) (999 = 0)

*-* Transform 1-2 into 0-1 dummy variables
foreach var of varlist _all {
  qui sum `var'
  if (r(min)==1 & r(max)==2) | (r(min)==2 & r(max)==2) {
    qui replace `var' = 0 if `var' == 2 // transform 2=yes in 0=yes
  }
}


*-* Transform all of the date/time variables in stata format
* IQ begin and end
foreach var of varlist V42300 V42399 V42419 V51400 V1045401 {
	gen `var'_temp = `var'
	capture drop temp
	replace `var' = subinstr(`var',":","",.)
	gen temp = clock(`var',"hms")
	destring `var' , replace
	replace `var' = temp
	format `var' %tc
	drop temp *_temp
}
// Wrong date if inputted at the turn of midnight
replace V42399 = V42399 + 24*60*60000 if V42399 < V42300  // add a day if it's midnight and the end time < beginning time
replace V1045401 = V1045401 + 24*60*60000 if V1045401 < V51400 // add a day if it's midnight and the end time < beginning time
replace V42419 = V42419 + 24*60*60000 if V42419 < V42399 // add a day if it's midnight and the end time < beginning time


gen Date_int = date(V111111, "YMD") 
label var Date_int "Date of the interview"
format Date_int %td
sort Date_int
order Date_int, first
order V11111, last

/* There was no question on datebegin and end
gen DateBegin  = Cmdyhms(V1330002_2, V1330002_1, year(Date_int),V1330002_3, V1330002_4, 0)
gen DateEnd    = Cmdyhms(V1330003_2, V1330003_1, year(Date_int),V1330003_3, V1330003_4, 0)
format *Date* %tc
format Date_int %td

label var DateBegin "Date of beginning the PAPI questionnaire"
label var DateEnd   "Date of end of the PAPI questionnaire"
//replace V1045401 = V1045401 + 24*60*60000 if V1045401 < V51400 // add a day if it's midnight and the end time < beginning time

gen     IntTime = (DateEnd-DateBegin)/60000
replace IntTime = inttime/60 if IntTime >=.
label var IntTime "dv: Interview duration (min) - PAPI or CAPI"

replace inttime = inttime/60 // it's originally in seconds
label var inttime "Interview duration (min) CAPI"

pwcorr *IntTime Date_in, sig
pwcorr *IntTime Date_in if IntTime<500, sig // no clear connection between date of interview and length

* if the date of the interview is later than the end of the PAPI, substitute with PAPI
gen lateCAPIconversion = (dofc(DateEnd)< Date_int) if DateEnd<.
label var lateCAPIconversion "dv: The date of the computer is later than the end-date of the PAPI (The interviewer converted PAPI into CAPI some days later)"
replace Date_int = dofc(DateEnd) if lateCAPIconversion == 1

gen flagDate = (dofc(DateEnd)> Date_int) if DateEnd<. 
label var flagDate "dv: The date of the computer is before the end-date of the PAPI"

list intnr internr Date_int DateBegin DateEnd
*/

label var Date_int "dv: Date of the interview"

/* SECTIONS OF THE QUESTIONNAIRE
To jump directly to different parts of the questionnaire, search for "* ("
 (A) Family Table
 (B) Education
 (C) Work
 (D) Personal Relations
 (E) Parents
 (F) Grandparents
 (G) Parenting
 (H) IQ
 (I) Child Health
 (J) Your Health
 (K) Noncog
 (L) Social Capital
 (M) Time use
 (N) Immigration
 (O-a) Income
 (O-b) Weight
 (O-c) Non-cog
 (O-c) Depression
 (O-d) Risky/unhealthy
 (O-d) Sex
 (O-e) Opinions
 (O-e) Racism
 (P) Drawing
*/

*
rename V19999 City
label values City City
tab City V100042, miss
drop V100042 // [=] CHECK only if they are the same
egen dif_City = diff(City CITTA_XLS)
replace dif_City = 0 if CITTA_XLS >=.
tab dif_City, miss
gen flagCity = (dif_City == 1)
label var flagCity "City information is different in SPSS and XLS"
tab City CITTA // [=] CHECK, there should be no differences
// Use the XLS definition of city
replace City = CITTA_XLS if dif_City==1 & CITTA_XLS<.
*
/*-* City and Cohort Identifiers
From Paolo:
V1914:IDENTIFICATIVO
10001-19999:Adolescenti (Reggio)
20001-29999:Bambini (Reggio)
30001-39999:Immigrati (Reggio)
40001-49999:Adolescenti (Parma)
50001-59999:Bambini (Parma)
60001-69999:Immigrati (Parma)
70001-79999:Adolescenti (Padova)
80001-89999:Bambini (Padova)
90001-99999:Immigrati (Padova)
*/
/* IDprogressivo is not there
rename V1914 IDprogressivo
label var IDprogressivo "ID of the respondent"

gen     City = 1 if (IDprogressivo > 300000 & IDprogressivo < 400000)
replace City = 2 if (IDprogressivo > 200000 & IDprogressivo < 300000)
replace City = 3 if (IDprogressivo > 100000 & IDprogressivo < 200000)
*/
tab City, miss // CHECK NO MISSING
gen Reggio = (City == 1) if City<.
gen Parma  = (City == 2) if City<.
gen Padova = (City == 3) if City<.

tab City CITTA, miss // [=] CHECK, there should be no differences!
drop CITTA

rename V100040_3 Address

/* CAPI vs PAPI questionnaire
rename V1330001 CAPI_detail
tab CAPI_detail, miss
gen CAPI = (CAPI_detail == 1) if CAPI_detail<.
label define CAPI 0 "PAPI" 1 "CAPI"
label values CAPI CAPI
label var CAPI "dv: PAPI (=0) or CAPI (=1) Questionnaire"
tab CAPI, missing

tab City CAPI, miss row // many more PAPI in Parma!!
tab internr CAPI, miss row

probit CAPI Parma Padova
*/
* (A) Family Initial Table --> it's well filled, no missing (except for the V20200 which is there only for those born outside of IT)
rename V20000_1 famSize
label var famSize "dv: Number of family members"
tab famSize , missing
// egen temp = rownonmiss(V20060_*)
// corr famSize temp

*-* Family Characteristics
forvalues i = 1(1)10 {
	local j = (`i'*3) - 2 // day of birth (goes on every 3)
	local k = `j'+1       // month of birth
	local l = `j'+2       // year of birth
	gen Birthday`i' = mdy(V20080_`k', V20080_`j' ,V20080_`l')
	rename V20080_`l' yob`i'
	rename V20060_`i' Gender`i'
	rename V20070_`i' Relation`i'
	rename V20090_`i' BornIT`i'
	rename V20220_`i' mStatus`i'
	rename V20240_`i' PA`i'
	rename V20300_`i' MaxEdu`i'
		* for the migrants
		replace MaxEdu`i' = 1 if V20310_`i' == 1 & MaxEdu`i'>=.
		replace MaxEdu`i' = 3 if V20310_`i' == 2 & MaxEdu`i'>=.
		replace MaxEdu`i' = 6 if V20310_`i' == 3 & MaxEdu`i'>=.
		replace MaxEdu`i' = 8 if V20310_`i' == 4 & MaxEdu`i'>=.
		gen flagMaxEdu`i' = (V20310_`i' <= 4 & MaxEdu`i'>=.) 
		label var flagMaxEdu`i' "dv: MaxEdu`i' variable completed using migrant education categories"

	// gen BornCity`i' = ((V20100_`i' == 569127081 & City == 1) |  (V20100_`i' == 499127081 & City == 2) |  (V20100_`i' == 490025081 & City == 3)) if V20100_`i'<.
	tostring V20100_`i', replace
	replace V20100_`i' = itrim(trim(V20100_`i'))
	split V20100_`i', limit(1) gen(V20100_`i'_) // parse(" ") 
	gen BornCity`i' = ((V20100_`i'_1 == "REGGIO" & City == 1) |  (V20100_`i'_1 == "PARMA" & City == 2) |  (V20100_`i'_1 == "PADOVA" & City == 3)) if V20100_`i'!=""
	rename V20100_`i' cityBirth`i'
	rename V20200_`i' BirthState`i'
	rename V20201_`i' ITNation`i'
	gen Migrant`i' = (BornIT`i' == 0 & ITNation`i' == 0)
	gen Age`i' = (Date_int - Birthday`i')/365.25
	
	label var Gender`i' "Gender of component `i'"
	label var Relation`i' "relation to respondent of component `i'"
	label var Birthday`i' "date of birth of component `i'"
	label var yob`i' "Year or Birth of component `i'"
	label var Age`i' "dv: age at interview of component `i'"
	label var BornIT`i' "is born in Italy of component `i'"
	label var mStatus`i' "marital status of component `i'"
	label var PA`i' "principal activity of component `i'"
	label var MaxEdu`i' "maximum education level of component `i'"
	label var BornCity`i' "dv: Component `i' was born in the City"
	label var BirthState`i' "state of Birth of component `i'"
	label var ITNation`i' "Component `i' has italian nationality"
	label var Migrant`i' "dv: Component`i' is a migrant (born outside IT and not IT-nationality)"
}
format Birthday* %td

* Main Respondent variables
rename Gender1 Male // Gender of the respondent
label var Male "Main respondent is male"
label define gender 0 "female" 1 "male"
label values Male Gender* gender
tab Male, missing 

rename Birthday1 Birthday
label var Birthday "Main respondent date of birth"
rename Age1 Age
label var Age "dv: Main respondent age at interview"
sum intnr Age // CHECK that it's between 30 and 60
tab yob1, miss // CHECK that it's only 54-59 or 69-70 or 80-81

* COHORT IDENTIFIER
gen     Cohort = 4 if (yob1 == 1980 | yob1 == 1981) 
replace Cohort = 5 if (yob1 == 1969 | yob1 == 1970) 
replace Cohort = 6 if (yob1 >= 1954 & yob1 <= 1959) 
label var Cohort "dv: Cohort: I=bam, II=imm, III=ado, IV=adults 80-81, V=adults 69-70, VI=adults 54-59"
tab yob1 Cohort, miss // CHECK no missing
tab Cohort City, miss // CHECK The numbers given by Paolo

rename BornIT1 BornIT
tab BornIT, missing
label var BornIT "Main respondent is born in Italy"

rename BornCity1 BornCity
label var BornCity "dv: Main respondent was born in the city" 

rename mStatus1 mStatus
tab mStatus , miss
label var mStatus "Marital Status of the Main respondent "

rename PA1 PA 
label var PA "Principal activity of the Main respondent "
tab PA , missing // CHECK

gen student = (PA == 7) if PA<.
replace student = PA if PA>=.
label var student "dv: Main respondent is a student"

rename MaxEdu1 MaxEdu
tab MaxEdu, missing // CHECK missing
label var MaxEdu "Maximum education level of Main respondent - from FamilyTable"

rename BirthState1 BirthState
rename ITNation1 ITNation
tab BirthState ITNation, miss

*-* Other family members
tab Relation2, miss // CHECK

* family size and other house characteristics
egen childrenResp = anycount(Relation*), values(3/6) // natural, adoptive, foster, partner's child
label var childrenResp "dv: Number of children of the respondent living in the household"

foreach var of varlist Age* {
gen round`var' = round(`var')
}
egen children0_18 = anycount(roundAge*), values(0/18)
label var children0_18 "dv: Number of children aged 0 to 18 living in the household"
drop roundAge*

tab famSize childrenResp, miss
tab famSize children0_18, miss
tab children0_18 childrenResp, miss

** Twins: there are some twins 
gen Twin = 0
forvalues i =2/10{
di "checking component `i'"
replace Twin = 1  if Relation`i'==11 & (Birthday`i' == Birthday) // check siblings with same birthday
}
label var Twin "Respondent has a twin living in the household"

*Two-twins in the dataset (they almost look like duplicates)
duplicates tag City Cohort Birthday if Twin==1, gen(TwinInData)
		/*
		sort Birthday
		browse intnr internr Cohort City Address Date_int Twin* CAPI famSize Male Gender* Age Age? Birthday Birthday? Relation? if Twin==1
		*/


* house characteristics
// rename V30001 hhead // [=] CHECK
rename V30020 house
rename V30020_open house_open
rename V30034 lang
rename V30050 nationality
// replace nationality = V30051 if V30051<.

rename V30060_1 yrItaly // NOTE: this is asked if nationality is not italian --> should have been asked if BornIT2 is not italian!
rename V30070_1 yrCity
mvdecode yrItaly yrCity, mv(9998 = . \ 9999 = .w) // 9999 "NON INDICA"; 9998 "SEMPRE VISSUTO QUI" 
label var yrItaly "dv: Year of arrival in Italy (missing if always lived here)"
label var yrCity "dv: Year of arrival in City (missing if always lived here)"
gen ageItaly = max(yrItaly - year(Birthday) , 0) if yrItaly<.
gen ageCity  = max(yrCity  - year(Birthday) , 0) if yrCity<.
label var ageItaly "dv: Age of arrival in Italy"
label var ageCity "dv: Age of arrival in the city"

gen flagAgemigrant = (ageCity < ageItaly)
label var flagAgemigrant "dv: Age arrival city < age arrival italy"
replace ageCity = ageItaly if ageCity < ageItaly // WARNING it shuold never be negative
gen livedAwayCity = ageCity - ageItaly //  >0 if arrived first in Italy and then moved to City
sum livedAwayCity 
label var livedAwayCity "dv: Ages lived in italy but not in this city"

/*-*-* Migrant Indicator *-*-*
The respondent is born outside of Italy AND doesn't have IT nationality

The whole family is classified as a migrant based on the respondent's status 

For some issues, see the flag variable
*/
gen Migrant = (BornIT == 0 & ITNation == 0)
label var Migrant "dv: Migrant Family - based on respondent's birth-place (not IT) AND nationality (not IT)"
tab Migrant , miss
tab nationality Migrant , miss
sum *BornIT* *ITNation* if Migrant == 1

* (B) Education
rename V31160 MaxEdu1
rename V31170_1 ageEdu //ageEdu1 is asked only to migrants
polychoric MaxEdu MaxEdu1  // CHECK they are the same
tab MaxEdu MaxEdu1, miss
drop MaxEdu1 // CHECK only if they are the same
rename V31200 regretStudy
tab regretStudy, miss

* those who dropped out
rename V31180_1 dropLike
rename V31180_2 dropFrustrat
rename V31180_3 dropWork
rename V31180_4 dropIndep
rename V31180_5 dropUseless
rename V31180_6 dropFam
rename V31180_7 dropOther
rename V31180_8 dropDK
rename V31180_open dropReason1_open

sum drop*
tab MaxEdu dropLike, miss // CHECK that it is there only for high school or less (MaxEdu<=3)

rename V31190_1 continueParent
rename V31190_2 continueTeacher
rename V31190_3 continueFriends
rename V31190_4 continueOther
rename V31190_5 continueNone
rename V31190_6 continueDK
rename V31190_open continue_open

sum continue*
sum continue* if continueNone == 1 // CHECK they should all be zero

* What is most important for your learning
rename V31210_5 learnDK
rename V31210_O1 learnImp1
rename V31210_O2 learnImp2
rename V31210_O3 learnImp3
rename V31210_O4 learnImp4
sum learn*
tab learnImp1 learnDK , miss // CHECK 
tab learnImp1 learnImp2, miss

*-* Asilo (Infant Toddler Center)
rename V32100 asilo
mvdecode asilo, mv(4 = .r) // Non ricordo
gen flagasilo = (asilo >=.)
label var flagasilo "dv: Doesn't know and doesn't answer whether attended asilo nido"
tab asilo flagasilo

rename V32110 asiloBegin
rename V32120 asiloYears
mvdecode asiloYear asiloBegin, mv(4 = .r)
label var asiloBegin "Age at beginning of Asilo nido"
gen asiloEnd = asiloBegin+asiloYears
replace asiloEnd = asiloBegin if asiloBegin>=. 
replace asiloEnd = asiloYears if asiloYears>=. 
label var asiloEnd "dv: Age at ending of Asilo nido"

rename V32130 asiloType_self
label var asiloType_self "Type of asilo attended, self-reported"
tab asiloType_self City, missing
tab asiloType_self asilo , miss // CHECK
replace asiloType_self = 0 if (asilo == 2 | asilo == 3) // include a 0 = Not attended if "other child-care" or "no, stayed home"
mvdecode asiloType_self, mv(6 = .s) // Non ricordo
gen flagasiloType_self = (asiloType_self >= .)
label var flagasiloType_self "dv: Don't remember / don't answer question about type of asilo"

gen asiloStat_self = (asiloType_self ==1) if asiloType_self<.
gen asiloMuni_self = (asiloType_self ==2) if asiloType_self<.
gen asiloPubb_self = (asiloType_self ==3) if asiloType_self<.
gen asiloReli_self = (asiloType_self ==4) if asiloType_self<.
gen asiloPriv_self = (asiloType_self ==5) if asiloType_self<.
gen asiloDK_self = (asiloType_self == .r) if asiloType_self!=.

tab Cohort City if asiloMuni==1, miss //[=] there should be no asilo comunale in Reggio for the last two cohorts

	* name and/or address
egen asiloLocation = rowtotal(V32140 V32150), missing
label var asiloLocation "dv: Do you remember the name/ address of the asilo?"
label define Location 0 "Yes, both" 1 "Yes, either name or address" 2 "No"
label values asiloLocation Location
tab asiloLocation, missing
tab asiloType_self asiloLocation , missing 

rename V32140_NOME_ASILO asiloLocation_name
rename V32150_INDIRIZZO_ASILO asiloLocation_address

*-* Materna
rename V32160 materna
recode materna (2 = 0) (3 = .s)
tab materna, miss // CHECK no miss; 2 didn't go and 1 doesn't remember
tab materna Cohort, miss // [=] there are 169 who said they went to a Materna in the control group (adults 54-59)
tab materna City if Cohort==6, miss
gen flagmaterna = (materna == 3 | materna >=.)
label var flagmaterna "dv: Doesn't know and doesn't answer whether attended scuola materna"

rename V32170 maternaBegin
rename V32180 maternaYear
mvdecode maternaYear maternaBegin, mv(4 = .r)

rename V32190 maternaType_self
label var maternaType_self "Type of materna attended, self-reported"
tab maternaType_self materna , miss // CHECK
replace maternaType_self = 0 if materna == 0 // include a 0 = Not attended
mvdecode maternaType_self , mv(6 = .s) // non ricordo
tab maternaType_self , missing // CHECK no missing, only 4 don't remember
tab maternaType_self materna , missing
tab maternaType_self City, missing

gen flagmaternaType_self = (maternaType_self == 6 | maternaType_self >.)
label var flagmaternaType_self "dv: Don't remember / don't answer question about type of materna"

gen maternaStat_self = (maternaType_self ==1) if maternaType_self<.
gen maternaMuni_self = (maternaType_self ==2) if maternaType_self<.
gen maternaPubb_self = (maternaType_self ==3) if maternaType_self<.
gen maternaReli_self = (maternaType_self ==4) if maternaType_self<.
gen maternaPriv_self = (maternaType_self ==5) if maternaType_self<.
gen maternaDK_self = (maternaType_self == .r) if maternaType_self!=.

tab maternaMuni_self City if Cohort==6, miss //[=] there should be no Reggio-comunale for this cohort!

	*name and/or address
egen maternaLocation = rowtotal(V32200 V32210), missing
label var maternaLocation "dv: Do you remember the name/ address of the materna?"
label values maternaLocation Location
tab maternaLocation, missing // those who don't remember neither name nor address (location = 2) are a lot
tab maternaType_self maternaLocation , missing 

rename V32200_NOME_MATERNA maternaLocation_name
rename V32210_INDIRIZZO_MATERNA maternaLocation_address
* Reason and motive why respondent sent to asilo and scuola materna: 
	*1) needed to work
	*2) younger siblings needed care
	*3) no grandparent
	*4) important for growth
	*5) to socialize
rename V32220_1 asiloMotiveWork
rename V32220_2 asiloMotiveSibl
rename V32220_3 asiloMotiveNGra
rename V32220_4 asiloMotiveSoci
rename V32220_5 asiloMotiveOthe
rename V32220_6 asiloMotiveDK
rename V32220_7 asiloMotiveMiss
tab asiloMotiveWork asilo, miss // CHECK
* materna
rename V32230_1 maternaMotiveWork
rename V32230_2 maternaMotiveSibl
rename V32230_3 maternaMotiveNGra
rename V32230_4 maternaMotiveSoci
rename V32230_5 maternaMotiveOthe
rename V32230_6 maternaMotiveDK
rename V32230_7 maternaMotiveMiss
tab maternaMotiveWork materna, miss // CHECK
rename V32230_open maternaMotiveMiss_open

* Reason why asilo and materna where important for those who went
rename V32240_1 asiloImportantPlay
rename V32240_2 asiloImportantAuto
rename V32240_3 asiloImportantGame
rename V32240_4 asiloImportantNogo
rename V32240_5 asiloImportantDK
rename V32240_6 asiloImportantOthe
rename V32240_7 asiloImportantMiss
* materna
rename V32250_1 maternaImportantPlay
rename V32250_2 maternaImportantAuto
rename V32250_3 maternaImportantGame
rename V32250_4 maternaImportantNogo
rename V32250_5 maternaImportantDK
rename V32250_6 maternaImportantOthe
rename V32250_7 maternaImportantMiss
rename V32250_open maternaImportant_open

* Reason why NOT sent to asilo or schola materna
rename V32260_1 asiloNoMotiveGrow
rename V32260_2 asiloNoMotiveSmal
rename V32260_3 asiloNoMotiveWill
rename V32260_4 asiloNoMotiveCost
rename V32260_5 asiloNoMotiveFull
rename V32260_6 asiloNoMotiveQual
rename V32260_7 asiloNoMotiveDK
rename V32260_8 asiloNoMotiveOthe
rename V32260_9 asiloNoMotiveMiss
tab asiloNoMotiveGrow asilo, miss
rename V32260_open asiloNoMotive_open
* materna
rename V32270_1 maternaNoMotiveGrow
rename V32270_2 maternaNoMotiveSmal
rename V32270_3 maternaNoMotiveWill
rename V32270_4 maternaNoMotiveCost
rename V32270_5 maternaNoMotiveFull
rename V32270_6 maternaNoMotiveQual
rename V32270_7 maternaNoMotiveDK
rename V32270_8 maternaNoMotiveOthe
rename V32270_9 maternaNoMotiveMiss
tab maternaNoMotiveGrow materna, miss
rename V32270_open maternaNoMotive_open

sum *NoMotive*

foreach var in asiloMotive asiloImportant asiloNoMotive maternaMotive maternaImportant maternaNoMotive {
	egen `var'Nr = rowtotal(`var'????), missing
	label var `var'Nr "Number of reasons checked for `var'"
}

* Mother working or studying while child/adolescent was younger than 6
rename V32280 momWorking06
tab momWorking06, miss

gen momNo06 = (momWorking06 == 9)
replace momNo06 = momWorking06 if momWorking06 >=.
label var momNo06 "dv: Mother non present/dead in the first 6 years of life" 
mvdecode  momWorking06, mv(9 = .a) // non presente, deceduta

* Who took care of the respondent?
* when was not at the asilo
rename V32290_1 careAsiloMom
rename V32290_2 careAsiloDad
rename V32290_3 careAsiloGra
rename V32290_4 careAsiloBsh
rename V32290_5 careAsiloBso
rename V32290_6 careAsiloBro
rename V32290_7 careAsiloFam
rename V32290_8 careAsiloOth
rename V32290_9 careAsiloDK
* in the years he did not go to asilo
rename V32300_1 careNoAsiloMom
rename V32300_2 careNoAsiloDad
rename V32300_3 careNoAsiloGra
rename V32300_4 careNoAsiloBsh
rename V32300_5 careNoAsiloBso
rename V32300_6 careNoAsiloBro
rename V32300_7 careNoAsiloFam
rename V32300_8 careNoAsiloOth
rename V32300_9 careNoAsiloDK
* when Child/Adolescent was sick
rename V32310_1 careSickMom
rename V32310_2 careSickDad
rename V32310_3 careSickGra
rename V32310_4 careSickBsh
rename V32310_5 careSickBso
rename V32310_6 careSickBro
rename V32310_7 careSickFam
rename V32310_8 careSickOth
rename V32310_9 careSickDK

*-* Elementary and middle school
egen elementaryMultiple = rowtotal (V32320_?), missing
label var elementaryMultiple "Respondent went to more than one elementary-type"
list V32320_? if elementaryMultiple>1 & elementaryMultiple<. // CHECK
gen elementaryType = 0 if elementaryMultiple>=. // 0 if not gone to elementary
forvalues i = 1(1)4 {
	replace elementaryType = `i' if V32320_`i' == 1 & elementaryType >=.
}
label var elementaryType "Type of elementary school attended (first reported)"
rename V32320_1 elementaryState
rename V32320_2 elementaryRelig
rename V32320_3 elementaryPrivate
rename V32320_4 elementaryDK
label define Type 0 "Non frequentato" 1 "Statale" 2 "Religioso" 3 "Privato" 4 "Non Ricordo"
label values elementaryType Type
tab elementaryType , missing // CHECk no missing
tab elementaryType City, missing
gen flagelementaryType = (elementaryType == 4 | elementaryType == 0)
label var flagelementaryType "dv: No elementary school / Don't remember type"

egen mediaMultiple = rowtotal (V32330_?), missing
label var mediaMultiple "Respondent went to more than one middle school-type"
list V32330_? if mediaMultiple>1 & mediaMultiple<. // CHECK
gen mediaType = 0 if mediaMultiple>=. // 0 if not gone to media
forvalues i = 1(1)4 {
	replace mediaType = `i' if V32330_`i' == 1 & mediaType >=.
}
label var mediaType "Type of media school attended (first reported)"
rename V32330_1 mediaStat
rename V32330_2 mediaReli
rename V32330_3 mediaPriv
rename V32330_4 mediaDK
label values mediaType Type
tab mediaType , missing // CHECk no missing
tab mediaType City, missing
gen flagmediaType = (mediaType == 4 | mediaType == 0)
label var flagmediaType "dv: No middle school / Don't remember type"

*-* scuola superiore e universita
rename V32340 highschoolType
rename V32340_open highschoolType_open
tab highschoolType, miss
gen highschoolGrad = (V32341 == 1 | V32341 == 2) // CHECK no missing by construction..
tab MaxEdu highschoolGrad , miss // [=] there's one who has university diploma but didn't graduate HS
replace highschoolGrad = 1 if MaxEdu>=4 & MaxEdu1<.
rename V32351 votoMaturita
replace votoMaturita = round(V32350/60*100) if V32350<. & votoMaturita>=.
gen flagvotoMaturita = (votoMaturita < 40) 
tab votoMaturita flagvoto, miss

rename V32360 uni
rename V32360_open uni_open
rename V32370 uniName
rename V32371_open uniName_open
rename V32380_1 votoUni
rename V32381 votoUniLode
tab uni
tab uniName
tab votoUni*, miss // check

* (C) Work
corr PA V33100
tab PA V33100
drop V33100 // only if they are the same

rename V33110 EverWork
tab PA EverWork, miss // CHECK: only for those who are not working (changed later, see below)

rename V33120_1 AgeWork
tab AgeWork EverWork, miss
rename V33140 Contract
rename V33140_open Contract_open
rename V33150 WorkPublic

gen BSNalone = (V33170 == 1) if V33170<.
gen BSNfamily = (V33170 == 2) if V33170<.
rename V33171 BSNnumEmployees
label var BSNalone "Self-employed, working alone"
label var BSNfamily "Self-employed, working with family"
label var BSNnumEmployees "Self-employed, number of employees in the firm"

rename V33180_1 YrWork
gen seniority = (date("30aug2012", "DMY") - mdy(1,1,YrWork))/365.25 // [=] Date_int 
label var seniority "Number of years in the current job"

rename V33190_1 HrsWork
replace HrsWork = .w if HrsWork == 98 // CHECK if this is actually a non-response
rename V33190_2 HrsExtra
rename V33202 SES
rename V33202_open SES_open

rename V33210 workComputer
rename V33220 workLanguage
rename V33230 workQualified
rename V33240 work2nd
gen work2ndYearly = (work2nd == 1) if work2nd<.
gen work2ndSeasonal = (work2nd == 2) if work2nd<.
gen work2ndOccasional  = (work2nd == 3) if work2nd<.
rename V33250_1 HrsWork2nd

rename V33280 UnempWhy
rename V33330 StudyWhat
rename V33290_1 YrUnemp
replace YrUnemp = YrUnemp +  V33290_2/12 if V33290_2<.

rename V33300_1 LookworkNo
rename V33300_2 LookworkRead
rename V33300_3 LookworkDirect
rename V33300_4 LookworkAgency
rename V33300_5 LookworkOther
rename V33300_6 LookworkDK

rename V33340 YrPension

tab SES PA, miss
label list V33100

* (D) Fertility
rename V34120 YrMarry
rename V34130 CohabBefore
tab YrMarry mStatus , miss
tab mStatus CohabBefore , miss
rename V34141 CohabBeforeYr
replace CohabBeforeYr = V34142/12 if V34142<. & CohabBeforeYr>=.
replace CohabBeforeYr = V34140    if V34140>. // put the missing values of V34140
drop V34140 V34142

rename V34150 numMarriage
rename V34170 numCohab
gen everCohab = (numCohab>0) if numCohab<.
replace everCohab = numCohab if numCohab>=.

rename V34180 YrLiveTogether
tab YrLiveTogether mStatus , miss
gen temp = (Date_int - mdy(1,1,YrMarry))/365.25 
replace temp = temp + CohabBeforeYr if CohabBeforeYr <.
replace YrLiveTogether = temp if temp<. & YrLiveTogether>=.
replace YrLiveTogether = YrMarry if YrMarry>. & YrLiveTogether == . 
label var YrLiveTogether "dv: Years living with the current partner"
drop temp

* children
rename V34181 childrenDum
tab childrenResp childrenDum // CHECK -- see flagChildren below
rename V34190 childrenOut
egen childrenNum = rowtotal(childrenOut childrenResp), miss
label var childrenNum "dv: total number of children of the respondent (in and out of house)"
tab childrenOut childrenDum, miss
tab childrenResp childrenDum, miss
tab childrenNum childrenDum , miss // CHECK
// browse children*
gen flagChildren1 = (childrenNum == 0 & childrenDum == 1)
label var flagChildren1 "dv: Report having children, but no children in or out of the house. Replaced childrenNum to 1"
list intnr internr childrenNum childrenDum childrenOut Relation2 Relation3 if flagChildren1==1 // list
replace childrenNum = 1 if flagChildren1 == 1 // [=] Paolo said that the child is present, but living with the other parent and not on his own (therefore not included in the table childreOut)
tab flagChildren1 mStatus, miss

gen flagChildren2 = (childrenNum > 0 & childrenDum == 0)
label var flagChildren1 "dv: Report having no children, but one or more children in or out of the house. They were all children of the partner"
list intnr internr childrenNum childrenDum Relation2 Relation3 Relation4 if flagChildren2==1 // they are the children of the partner

forvalues Num = 1/9{
	local j = (`Num'*3) - 2 // day of birth (goes on every 3)
	local k = `j'+1       // month of birth
	local l = `j'+2       // year of birth
	gen childout`Num'Birthday = mdy(V34220_`k', V34220_`j' ,V34220_`l')
	gen childout`Num'Age = (Date_int - childout`Num'Birthday)/365.25
	gen childout`Num'DateOut  = mdy(V34261_`k', V34261_`j' ,V34261_`l')
	gen childout`Num'YrOut = (Date_int - childout`Num'DateOut)/365.25
	
	rename V34200_`Num' childout`Num'Name
	rename V34210_`Num' childout`Num'Type
	gen childout`Num'Bio = (childout`Num'Type == 1) if childout`Num'Type<.
	rename V34240_`Num' childout`Num'WhyOut
	rename V34270_`Num' childout`Num'MaxEdu
	rename V34280_`Num' childout`Num'SES
	rename V34290_`Num' childout`Num'Asilo
	rename V34300_`Num' childout`Num'Materna
	
	label var childout`Num'Age	"dv: Age of `Num'-th child living out of the household"
	label var childout`Num'YrOut	"dv: Years that `Num'-th child has been living out of the household"
	label var childout`Num'Type	"dv: `Num'-th out-of-house-child is biological/adopted/foster"
	label var childout`Num'Bio 	"dv: `Num'-th out-of-house-child is biological"
	label var childout`Num'WhyOut	"dv: Reason why `Num'-th child lives out of the household"
	label var childout`Num'MaxEdu	"dv: Max Education of `Num'-th out-of-house-child"
	label var childout`Num'SES		"dv: Main Activity of `Num'-th out-of-house-child"
	label var childout`Num'Asilo 	"dv: `Num'-th out-of-house-child went to infant-toddler center"
	label var childout`Num'Materna	"dv: `Num'-th out-of-house-child went to preschool"
}
format childout?Birthday childout?DateOut %td

list childout?Age if childout1Age<childout2Age & childout2Age<. // CHECK there should be none
sum childout?Age
sum childout4* // CHECK there is none
if r(N)==0 {
drop childout4* childout5* childout6* childout7* childout8* childout9* 
}

egen temp = rowtotal(childout?Asilo), miss // [=] not asked for children in the house!!
gen childoutAsiloPerc = temp/childrenOut
label var childoutAsiloPerc "dv: Share of respondent children who went to infant-toddler center"
drop temp

egen temp = rowtotal(childout?Materna), miss // [=] not asked for children in the house!!
gen childoutMaternaPerc = temp/childrenOut
label var childoutMaternaPerc "dv: Share of respondent children who went to preschool"
drop temp

* (E) Parents
forvalues i=1/2{
	if `i' == 1{
	local parent dad
	}
	if `i' == 2{
	local parent mom
	}
	gen `parent'Age = 2013 - V35110_`i'
	rename V35120_`i' `parent'BornIT
	gen `parent'BornProvince = ( (V35121_`i' == 35 & City==1) |  (V35121_`i' == 34 & City==2) |(V35121_`i' == 28 & City==3) ) if V35121_`i'<.
	label var `parent'BornIT "`parent' was born in Italy"
	label var `parent'BornProvince "`parent' was born in the current province"
	rename V35121_`i' `parent'BirthProvince
	rename V35122_`i' `parent'BirthNation
	label var `parent'BirthProvince "`parent' province of birth"
	label var `parent'BirthNation "`parent' nation of birth (if not Italian)"
	rename V35140_`i' `parent'Alive
	rename V35160_`i' `parent'MaxEdu
	rename V35170_`i' `parent'SES
	rename V35180_`i' `parent'ReligType
	gen `parent'ReligionDum = (`parent'ReligType > 2) if `parent'ReligType<.
	rename V35190_`i' `parent'Religiosity
	rename V35200_`i' `parent'Sociability
}

rename V35150 numSiblings
tab numSiblings, miss

* (F) Gandparents
rename V36110_1 grandpa1Alive
rename V36110_2 grandma1Alive
rename V36110_3 grandpa2Alive
rename V36110_4 grandma2Alive
egen grandAlive = rowtotal(grand???Alive), miss
rename V36130 grandDist
rename V36140 grandCare
replace grandDist = 7 if grandAlive == 0 //deceased
rename V36150 grandCareHrs

* (G) Parenting -- HOME
/* NOTE: this is similar to the questions of the child questionnaire; however here the questions are reffered to the 
level of investment that the adult makes into her own children, hence they are called inv*.
(in the child, it refers to the investment RECEIVED by the child, hence they are called childinv*) */
rename V37110 invReadTo
rename V37120 invMusic
rename V37130 invCom
rename V37140 invTV_hrs
rename V37141 invVideoG_hrs
rename V37150 invOut
rename V37190 invFamMeal

rename V37191 children6under
rename V37200_1 invChoresRoom
rename V37200_2 invChoresHelp
rename V37200_3 invChoresHomew
rename V37210 invReadSelf

rename V37220 invExtracv
rename V37230 invTakeToSchool
rename V37230_open invTakeToSchool_open
rename V37240 invTakeOutSchool
rename V37240_open invTakeOutSchool_open
rename V37260_1 distTimeSchool
rename V37260_2 distMeterSchool

rename V37142 invInternet
rename V37180 invFamFriends
rename V37251 invAgeSchoolAlone

* (P) Respondent IQ
sum intnr V423* V424* 
gen IQ_A1 = (V42301 == 1) if V42301<.
gen IQ_A2 = (V42302 == 1) if V42302<.
gen IQ_A3 = (V42303 == 1) if V42303<.
gen IQ_A4 = (V42304 == 1) if V42304<.
gen IQ_A5 = (V42305 == 1) if V42305<.
gen IQ_A6 = (V42306 == 1) if V42306<.
gen IQ_A7 = (V42307 == 1) if V42307<.
gen IQ_A8 = (V42308 == 1) if V42308<.
gen IQ_A1_DK = (V42301 == 3) if V42301<.
gen IQ_A2_DK = (V42302 == 3) if V42302<.
gen IQ_A3_DK = (V42303 == 3) if V42303<.
gen IQ_A4_DK = (V42304 == 3) if V42304<.
gen IQ_A5_DK = (V42305 == 3) if V42305<.
gen IQ_A6_DK = (V42306 == 3) if V42306<.
gen IQ_A7_DK = (V42307 == 3) if V42307<.
gen IQ_A8_DK = (V42308 == 3) if V42308<.

factor IQ_A?
sem (IQ -> IQ_A?), iter(500) latent(IQ) method(mlmv) var(IQ@1)
predict IQ_A_factor if e(sample), latent(IQ)
label var IQ_A_factor "Respondet mental ability. Raven matrices part A - factor score"

egen IQ_A_score = rowtotal(IQ_A?)
replace IQ_A_score = IQ_A_score/8
label var IQ_A_score "Respondet mental ability. Raven matrices part A - % of correct answers"


forvalues i=1/9{
	gen IQ_B`i' = (V4240`i' == 1) if V4240`i'<.
	gen IQ_B`i'_DK = (V4240`i' == 3) if V4240`i'<.
}
forvalues i=10/12{
	gen IQ_B`i' = (V424`i' == 1) if V424`i'<.
	gen IQ_B`i'_DK = (V424`i' == 3) if V424`i'<.
}

factor IQ_B? IQ_B??
sem (IQ -> IQ_B10 IQ_B12 IQ_B11 IQ_B?), iter(500) latent(IQ) method(mlmv) var(IQ@1)
predict IQ_B_factor if e(sample), latent(IQ)
label var IQ_B_factor "Respondet mental ability. Raven matrices part B - factor score"

egen IQ_B_score = rowtotal(IQ_B10 IQ_B12 IQ_B11 IQ_B?)
replace IQ_B_score = IQ_B_score/12
label var IQ_B_score "Respondet mental ability. Raven matrices part B - % of correct answers"

gen IQ_ATime = V42399 - V42300
gen IQ_BTime = V42419 - V42399
* format IQ_ATime %tc
replace IQ_ATime = IQ_ATime/60000 
label var IQ_ATime "Time spent on IQ Raven Test (minutes), part A"
replace IQ_BTime = IQ_BTime/60000 
label var IQ_BTime "Time spent on IQ Raven Test (minutes), part B"

* (I) Child Health
* Find out the age of the children, using both in and out of the household
* [=] NOTE: this is not bulletproof code: it could depend on how the respondent defines "first/second/third child" and how they answered questions on children in and out of the household

capture drop temp*
forvalues i=1/8{
gen temp`i' = Age`i' if ( Relation`i' >= 3 & Relation`i' <= 6) // create a temporary variable with all the ages of children in the household
} 
forvalues i=1/3{ // [=] this has to be the maxnumber of children out of the household
local j = `i' + 8
gen temp`j' = childout`i'Age // other temporary variables with the age of children out of the household
}

sum childrenNum
local Num = r(max)
di `Num'
forvalues i = 1/`Num'{ // loop over the total number of children
	egen child`i'Age = rowmax(temp*) //age of first child = max age 
	foreach var of varlist temp*{
		replace `var' = . if `var' == child`i'Age // delete the age used, then loop over the remaining and find second-oldest etc..
	}
}
capture drop temp*

sum child?Age // CHECK [=] there are some ages that don't make sense!

//browse intnr internr Age* Relation* childout?Age child?Age if Age<child1Age+15 & child1Age<.
list intnr internr Age Age2 Age3 Age4 Age5 Age6 Relation2 Relation3 Relation4 Relation5 Relation6 if Age<child1Age+15 & child1Age<.
gen flagAgeChild = (Age<child1Age+15 & child1Age<.)
label var flagAgeChild "dv: Child is older than mother (or mother was younger than 15 at birth)"
tab flagAgeChild, miss

forvalues i=1/4{
	rename V38110_`i' child`i'Health
	rename V38120_`i' child`i'SickDays
	rename V38130_`i' child`i'Height
	rename V38140_`i' child`i'Weight
	rename V38150_`i' child`i'Doctor
	rename V38170_`i' child`i'Dentist

	gen child`i'BMI = child`i'Weight/(child`i'Height/100)^2
	/* [=] must find age of the "right" child, but there is no gender!!
	egen child`i'z_BMI = zanthro(child`i'BMI,ba,US), xvar(child`i'Age) ageunit(year) gender(male) gencode(male=1, female=0)
	egen child`i'BMI_cat = zbmicat(child`i'BMI), xvar(child`i'Age) ageunit(year) gender(male) gencode(male=1, female=0) // only for those age<18
	replace child`i'BMI_cat = -1 if child`i'z_BMI < invnorm(.01) //severely underweight: below 2nd percentile
	replace child`i'BMI_cat = 0 if (child`i'z_BMI >= invnorm(.01) & child`i'z_BMI < invnorm(.05)) //underweight: below 5th pct

	local condition "child`i'Age>18 & child`i'BMI_cat>=."
	replace child`i'BMI_cat = -1 if `condition' & child`i'BMI < 16  //severely underweight
	replace child`i'BMI_cat = 0 if `condition' & (child`i'BMI >= 16 & child`i'BMI < 18.5) //underweight
	replace child`i'BMI_cat = 1 if `condition' & (child`i'BMI >= 18.5 & child`i'BMI < 25)
	replace child`i'BMI_cat = 2 if `condition' & (child`i'BMI >= 25 & child`i'BMI < 30)
	replace child`i'BMI_cat = 3 if `condition' & (child`i'BMI >= 30 & child`i'BMI < .)
	*/
	label var child`i'BMI "dv: child`i' Body-Mass-Index (kg/m^2)"
	//label var child`i'BMI_cat "dv: child`i' BMI categories"
	//label var child`i'z_BMI "dv: child`i' BMI - standardized score"
}
sum child*BMI*
/* 
browse child*BMI* child?Age
browse child?BMI child?z_BMI child?Weight child?Height child?Age if (child1BMI<14 | child1BMI>40) & child1BMI<. //there are many underweight!

egen temp  = rowmin(child?BMI_cat)
gen flagchildBMI = (temp==-1 )
label var flagchildBMI "dv: at least one child is severely underweight"
*/

egen temp2 = rowmax(child?BMI)
gen flagchildBMI2 = (temp2>40 & temp2<.)
list intnr internr child?Weight child?Height child?BMI if flagchildBMI2==1
label var flagchildBMI2 "dv: at least one child is very severely obese"

drop temp*


* (J) Your Health
rename V39110 Health
rename V39120 Health16
rename V39130 Doctor
rename V39141 Sleep
rename V39140 Height
rename V47110 Weight

gen BMI = Weight/(Height/100)^2
sum BMI
gen BMI_cat = .
replace BMI_cat = -1 if BMI < 16 & BMI_cat >=.
replace BMI_cat = 0 if BMI < 18.5 & BMI_cat >=.
replace BMI_cat = 1 if BMI < 25   & BMI_cat >=.
replace BMI_cat = 2 if BMI < 30   & BMI_cat >=.
replace BMI_cat = 3 if BMI < 35   & BMI_cat >=. & BMI<. 
replace BMI_cat = 4 if BMI < 40   & BMI_cat >=. & BMI<. 
replace BMI_cat = 5 if BMI > 40   & BMI_cat >=. & BMI<. 

label define BMI_cat -1 "Severly Underwg" 0 "Under wg" 1 "Normal wg" 2 "Overweight" 3 "Obese" 4 "Severy Obese" 5 "Very Severy Obese"
label values *BMI_cat BMI_cat
label var BMI_cat "dv: Respondent BMI categories"
label var BMI "dv: Respondent Body-Mass-Index (kg/m^2)"
tab BMI_cat

rename V39150 SickDays
rename V39160 HealthLimits
rename V39170 HealthCronic
forvalues i=1/12{
	rename V39180_`i' HCondition`i'
	replace HCondition`i' = .r if HCondition`i' == 0 & (V39180_13 == 1) // refuse to respond
	replace HCondition`i' = .s if HCondition`i' == 0 & (V39180_14 == 1) // Don't know
	replace HCondition`i' = .w if HCondition`i' == 0 & (V39180_15 == 1) // not pertinent
}
forvalues i=1/14{
	rename V39190_`i' HConditionDoc`i'
	replace HConditionDoc`i' = .r if HConditionDoc`i' == 0 & (V39190_15 == 1) // refuse to respond
	replace HConditionDoc`i' = .s if HConditionDoc`i' == 0 & (V39190_16 == 1) // Don't know
	replace HConditionDoc`i' = .w if HConditionDoc`i' == 0 & (V39190_17 == 1) // not pertinent
}
rename V39190_open HConditionDoc_open
*Eating
rename V40110 EatOut
rename V40120 Breakfast
rename V40130 Fruit
rename V40150 NoFried
rename V40160 numLight
rename V40190 Snack
rename V40200_1 SnackFruit
rename V40200_2 SnackIce
rename V40200_3 SnackCandy
rename V40200_4 SnackRoll
rename V40200_5 SnackChips
rename V40200_6 SnackOther
foreach var of varlist Snack* {
replace `var' = .r if `var' == 0 & (V40200_7 == 1) // refuse to respond
replace `var' = .s if `var' == 0 & (V40200_8 == 1 ) // Don't know
replace `var' = .w if `var' == 0 & (V40200_9 == 1) // not pertinent
}
rename V40200_open Snack_open

*Physical Activity
rename V41110 sport
rename V41130 sportOrganized
rename V41160 TV_hrs
rename V41170_1 goSchoolCar
rename V41170_2 goSchoolbus
rename V41170_3 goSchoolfoot
rename V41170_4 goSchoolbike
rename V41170_5 goSchoolmoto
foreach var of varlist goSchool* {
replace `var' = .r if `var' == 0 & (V41170_6 == 1) // refuse to respond
replace `var' = .s if `var' == 0 & (V41170_7 == 1 ) // Don't know
replace `var' = .w if `var' == 0 & (V41170_8 == 1) // not pertinent
}

rename V41180_1 distTimeWork
rename V41180_2 distMeterWork

*Hygene
rename V41190 brushTeeth
rename V41200 floss
rename V41210 Dentist
*Pregnancy
rename V41350 smokePreg
rename V41360 drinkPreg
rename V41370 dietPreg

* (L) Social Capital
rename V43110 takeCareOth
rename V43120 volunteer
rename V43140 club
rename V43140_open club_open
rename V43150 scout
rename V43170 Friends
rename V43171 Relatives
rename V43175_1 facebookSocNet
rename V43175_2 linkedinSocNet
rename V43175_3 twitterSocNet
rename V43175_4 otherSocNet
rename V43175_5 noSocNet
rename V43175_open SocNet_open
rename V43180 SocialMeet
forvalues j=1/3{
forvalues i=1/5{
	replace V43190_`j'_`i' = .r if V43190_`j'_`i' == 0 & V43190_`j'_6 == 1
	replace V43190_`j'_`i' = .s if V43190_`j'_`i' == 0 & V43190_`j'_7 == 1
	replace V43190_`j'_`i' = .w if V43190_`j'_`i' == 0 & V43190_`j'_8 == 1
}
}
rename V43190_1_1 mediaIntInternet
rename V43190_1_2 mediaIntPaper
rename V43190_1_3 mediaIntRadio
rename V43190_1_4 mediaIntFriends
rename V43190_1_5 mediaIntNo
rename V43190_2_1 mediaNatInternet
rename V43190_2_2 mediaNatPaper
rename V43190_2_3 mediaNatRadio
rename V43190_2_4 mediaNatFriends
rename V43190_2_5 mediaNatNo
rename V43190_3_1 mediaLocalInternet
rename V43190_3_2 mediaLocalPaper
rename V43190_3_3 mediaLocalRadio
rename V43190_3_4 mediaLocalFriends
rename V43190_3_5 mediaLocalNo

rename V43200_1 votedNo
rename V43200_2 votedMunicipal
rename V43200_3 votedRegional
rename V43200_4 votedNational
foreach var of varlist voted*{
	replace `var' = .w if `var'==0 & V43200_5 == 1
}

rename V43210 mayorName
rename V43210_open mayorName_open
rename V43220 Politics
rename V43230 satisSystemEdu
rename V43240 satisSystemHealth
rename V43250 ReligType
rename V43270 Faith
rename V43280 Religiosity
rename V43290 babyRelig
rename V43300 discrNo
replace discrNo = 1-discrNo // CHECK question is asked differently
rename V43310_1 discrAge
rename V43310_2 discrGender
rename V43310_3 discrSex
rename V43310_4 discrDisab
rename V43310_5 discrRace
rename V43310_6 discrRelig
rename V43310_7 discrOther
foreach var of varlist discr*{
	replace `var' = .r if `var'==0 & V43310_8  == 1
	replace `var' = .s if `var'==0 & V43310_9  == 1
	replace `var' = .w if `var'==0 & V43310_10 == 1
}
rename V43310_open discr_open

rename V43320_1 workLearn
rename V43320_2 workEffort
rename V43320_3 workSecurity
rename V43320_4 workAutonomy
rename V43320_5 workStable
rename V43320_6 workLifeBalance

* (M) Time use
rename V44110_1 TimePrtn
rename V44110_2 TimeChild
rename V44110_3 TimeWork
rename V44110_4 TimeFriend
rename V44110_5 TimeFree
rename V44120 Stress
rename V44130 StressSource
gen StressWork = (StressSource == 1) if StressSource<.
replace StressWork = StressSource if StressSource >=.
label var StressWork "dv: Work is a source of stress"
rename V44130_open StressSource_open
rename V44140 timeAlone
rename V44150 HomeWork
rename V44160 ChildWork

//Replace no partner/no child with a missing
tab childrenNum TimeChild, miss
replace TimeChild = . if TimeChild>. & (childrenNum==0) //no children
tab mStatus TimePrtn, miss
replace TimePrtn = . if TimePrtn>. & (mStatus>1 & mStatus<6) //no partner
tab mStatus HomeWork, miss
replace HomeWork = . if HomeWork == 5 //no partner

* (N) Immigration
rename V45110 MigrBad
rename V45130 MigrTooMany
rename V45140 MigrFuture
gen MigrFutureIncrease = (MigrFuture == 1) if MigrFuture<.
rename V45160 MigrIntegr
rename V45170 MigrIntegrMunicipal
rename V45180 MigrAttitude
rename V45190 MigrClass
rename V45200 MigrClassInterg
rename V45210 MigrClassTooMany
rename V45220 MigrClassChild
rename V45230 MigrProgram
rename V45240 MigrFriend
rename V45250 MigrMeet
gen MigrAvoid = (MigrMeet == 1) if MigrMeet<.
rename V45260_1 MigrMeetNo
rename V45260_2 MigrMeetWork
rename V45260_3 MigrMeetChurch
rename V45260_4 MigrMeetSport
rename V45260_5 MigrMeetOther
rename V45260_open MigrMeetOther_open

label var MigrIntegr "Schools don't help migration"
label var MigrAttitude "Respondent is diffident of immigrants"
label var MigrClassChild "Respondent's child has immigrant classmates"
label var MigrProgram "Migrants don't slow down class curriculum"
label var MigrFriend "Respondent has ever had migrant friends"
label var MigrMeetNo "Respondent doesn't hang out with migrants"
label var MigrMeetWork "Respondent hangs out with migrants at work"
label var MigrMeetChurch "Respondent hangs out with migrants at curch"
label var MigrMeetSport "Respondent hangs out with migrants at sports"
label var MigrMeetOther "Respondent hangs out with migrants (other)"

* (O-a) Income
rename V46110 WageReport
tab WageReport, missing // CHECK missing (.w) 14% of missing!!!
tab PA WageReport, missing

rename V46111 WageHour
rename V46112 WageDay
rename V46113 WageWeek
rename V46115 WageMonth
rename V46116 WageYear
rename V46118 WageOther

gen Wage = WageYear
replace Wage = .w if WageReport == .w
replace Wage = WageMonth*12 if Wage >=. // [=] or times 13 (tredicesima?)
	// Sources for hours and weeks worked 
	// OECD2011: 1774 hrs/year http:// stats.oecd.org/Index.aspx?DatasetCode=ANHRS 
	// see also www.oecd.org/employment/outlook and http://www.nber.org/chapters/c0073.pdf
replace Wage = WageWeek*41   if Wage >=. // or times 52 (every week?)
replace Wage = WageDay*205   if Wage >=. // or times 252 (every working day?)
replace Wage = WageHour*1774 if Wage >=. 
label var Wage "Yearly wage of the caregiver"
tabstat Wage, by(WageReport) stat(mean median min max)
mdesc Wage // CHECK almost 65% missing in total
gen flagWage = (Wage < 5000 )
replace flagWage = 1 if WageHour == 99
replace flagWage = 1 if WageMonth >= 11000 & WageMonth<.
replace flagWage = 1 if Wage >=.
label var flagWage "Wage reporting is probably inaccurate"
tab flagWage // CHECK 70% is missing or inaccurate!!

rename V46120 IncomeCat
tab IncomeCat, missing // CHECK 32% non response

rename V46130 PensionDum
rename V46135 Pension
tab Pension PensionDum , miss
rename V46140_1 BenefitDum
rename V46145_1 Benefit
rename V46140_2 WelfareDum
rename V46145_2 Welfare
tab Welfare WelfareDum , miss
rename V46140_3 ScholarshipDum
rename V46145_3 Scholarship

* (O-b) Weight
rename V47120 WeightSelfperc
rename V47130 WeightDieting

* (O-c) Non-cog
* Locus of control
forvalues i=1(1)4 {
	rename V48110_`i' Locus`i'
	tab Locus`i', missing // CHEK: less than 3% non-response in whole-dataset, but 10% in new-padova-reinterviews
}

foreach var of varlist Locus? {
	quietly gen `var'_Wmiss = (`var'>.)
	quietly replace `var'= . if `var'>. //change .w missing into . missing so that SEM works better
}

factor Locus?
sem (X -> Locus?), latent(X) var(X@1) method(mlmv)
predict LocusControl if e(sample), latent(X)
label var LocusControl "dv: Respondet Locus of Control - factor"

foreach var of varlist Locus? {
	quietly replace `var'= .w if `var'_Wmiss==1 //change back to .w missing
	quietly drop `var'_Wmiss
}

rename V48150_1 reciprocity1
rename V48150_2 reciprocity2
rename V48150_3 reciprocity3
rename V48150_4 reciprocity4
factor reciprocity? //CHECK it looks like there are two factors Q1-Q3 and Q2-Q4, "positive" and "negative" reciporocity

rename V48200_1 SatisHealth
rename V48200_2 SatisWork
rename V48200_3 SatisIncome
rename V48200_4 SatisFamily
rename V48220 ladderToday
rename V48230 ladderFuture
rename V48240 ladderPast
gen ladderForw = ladderFuture - ladderToday
gen ladderBack = ladderToday  - ladderPast
replace ladderForw = ladderFuture if ladderFuture>=.
replace ladderForw = ladderToday if ladderToday>=.
replace ladderBack = ladderToday if ladderToday>=.
replace ladderBack = ladderPast if ladderPast>=.
label var ladderForw "dv: Forward look on life"
label var ladderBack "dv: Backward look on life"
// twoway (hist ladderForw) (hist ladderBack, color(gray))

gen optimist = (ladderForw > 0) if ladderForw <.
gen optimist2 = (ladderForw > ladderBack) if ladderForw <. &  ladderBack <.
gen pessimist = (ladderForw < 0) if ladderForw <.
gen pessimist2 = (ladderForw < ladderBack) if ladderForw <. &  ladderBack <.
replace optimist = ladderForw if ladderForw >=.
replace optimist2 = ladderForw if ladderForw >=.
replace pessimist = ladderForw if ladderForw >=.
replace pessimist2 = ladderForw if ladderForw >=.
label var optimist  "dv: Optimist look on life - tomorrow better than today (ladder)"
label var optimist2 "dv: Optimist look on life - ladder (tomorrow - today) > (today - yesterday)"
label var pessimist  "dv: Pessimist look on life - tomorrow worst than today (ladder)"
label var pessimist2 "dv: Pessimist look on life - ladder (tomorrow - today) < (today - yesterday)"
tab opti*
tab pessi*
polychoric opti* pessi*

* (O-c) Depression
rename V48250_1 Depress01
rename V48250_2 Depress02
rename V48250_3 Depress03
rename V48250_4 Depress04
rename V48250_5 Depress05
rename V48250_6 Depress06
rename V48250_7 Depress07
rename V48250_8 Depress08
rename V48250_9 Depress09
rename V48250_10 Depress10

foreach var of varlist Depress?? {
	tab `var', missing // CHECK there are not that many missing
	quietly gen `var'_Wmiss = (`var'>.)
	quietly replace `var'= . if `var'>. //change .w missing into . missing so that SEM works better
}

factor Depress?? 

gen Depression_score = Depress01+Depress02+Depress03+Depress04+(6-Depress05)+ ///
                       Depress06+Depress07+(6-Depress08)+Depress09+Depress10
replace Depression_score = .w if Depression_score == .
label var Depression_score "dv: Respondet Depression - score"

sem (X -> Depress?? ), latent(X) var(X@1) method(mlmv)
predict Depression_factor if e(sample), latent(X)
label var Depression_factor "dv: Respondet Depression - factor"

corr Depression*

foreach var of varlist Depress?? {
	quietly replace `var'= .w if `var'_Wmiss==1 //change back to .w missing
	quietly drop `var'_Wmiss
}

* (O-d) Risky/unhealthy
* smoke
rename V49110 SmokeEver
rename V49120 Smoke1Age
rename V49130 Smoke
rename V49135 Cig
rename V49140 SmokeReduce
rename V49150 SmokeProh
* drink
rename V49160 Drink
rename V49170 Drink1Age
gen DrinkEver = (Drink1Age != 0) if Drink1Age<.
replace DrinkEver = Drink1Age if Drink1Age>.
label var DrinkEver "dv: Ever drunk alcohol"
rename V49180 DrinkNum
rename V49190 DrinkProblems
rename V49200 DrinkProh
* Drugs
rename V49210 DrugMedicine
rename V49221_1 DrugStreoids
rename V49221_2 DrugMaria
rename V49221_3 DrugCoke
rename V49221_4 DrugEcstasy
rename V49221_5 DrugOther
rename V49230 DrugeAgeMaria
rename V49250 MariaProh
* Risky-seeking behavior
rename V49410_1 RiskSuspended
rename V49410_2 RiskDUI
rename V49410_3 RiskRob
rename V49410_4 RiskFight
rename V49410_5 RiskArrested

* (O-d) Sex
rename V49310 sexNumPartner
rename V49320 sexOccasional
rename V49330 sexProtected

* (O-e) Opinions
rename V50110_1 parentSacrifice
rename V50110_2 grandpaSacrifice
rename V50110_3 eduFamily
* sexism
rename V50110_4 sexistWork
rename V50110_5 sexistHouse
* trust
rename V50210_1 Trust1
rename V50210_2 Trust2
rename V50210_3 Trust3
label var Trust1 "Generally cannot trust people" // "In generale ci si puo' fidare della gente"
label var Trust2 "Can trust anyone" // "Al giorno d'oggi non ci si puo' fidare di nessuno"
label var Trust3 "Shouldn't be careful with strangers" // "Bisogna fare attenzione quando si ha a che fare con gli estranei"

foreach var of varlist Trust? {
	tab `var', missing // CHECK there are not that many missing
	quietly gen `var'_Wmiss = (`var'>.)
	quietly replace `var'= . if `var'>. //change .w missing into . missing so that SEM works better
}

factor Trust?
sem (Trust -> Trust2 Trust1 Trust3), latent(Trust) var(Trust@1) iter(500) method(mlmv)
//predict Trust_factor if e(sample), latent(Trust)
//label var Trust_factor "dv: Respondent trust and reciprocity - factor score"

gen temp1 = 2-Trust1
gen temp2 = Trust2-2
gen temp3 = Trust3-2

egen Trust = rowtotal(temp?), miss
label var Trust "dv: Respondent trust and reciprocity - sum score"

foreach var of varlist Trust? {
	quietly replace `var'= .w if `var'_Wmiss==1 //change back to .w missing
	quietly drop `var'_Wmiss
}

* racism
rename V51110 MigrTaste
rename V51120 MigrGood
rename V51130 MigrBetter
gen MigrBetterHost = (MigrBetter==1) if MigrBetter<.
replace MigrBetterHost = MigrBetter if MigrBetter>=.
gen MigrBetterAid = (MigrBetter==2) if MigrBetter<.
replace MigrBetterAid = MigrBetter if MigrBetter>=.
label var MigrBetterHost "dv: Better to host migrants"
label var MigrBetterAid "dv: Better to send aid to migrants' own country"
rename V51140 MigrViolence
rename V51150 MigrViolenceFeel
rename V51160 MigrViolenceIT
rename V51170 MigrViolenceITFeel
rename V51180 MigrViolenceMigr
rename V51190 MigrViolenceMigrFeel

* (O-e) Racism
rename V51200_1 MigrAfri
rename V51200_2 MigrArab
rename V51200_3 MigrAsia
rename V51200_4 MigrEngl
rename V51200_5 MigrSAme
rename V51200_6 MigrSwed
label var MigrTaste "Respondent likes migrants"
label var MigrGood "Respondent thinks migrations is good"

rename V51210_1 MigrFriendAfri
rename V51210_2 MigrFriendArab
rename V51210_3 MigrFriendAsia
rename V51210_4 MigrFriendEngl
rename V51210_5 MigrFriendSAme
rename V51210_6 MigrFriendSwed

* (P) Drawing
rename V45400 draw
gen drawTime = V1045401 - V51400
replace drawTime = drawTime/60000


* ( Interviewer part )
/*
rename V999120 incentive
rename V100100 email
* PAPI
rename V52020 Sessions
rename V52030 Help
*/
* problems in the interview
rename V52110 Question
rename V52111_open Question_open
rename V52120 Reluct
rename V52121_open Reluct_open
rename V52121_1 ReluctantHome
rename V52121_2 ReluctantPolitic
rename V52121_3 ReluctantIncome
rename V52121_4 ReluctantDrug
rename V52121_5 ReluctantRisk
rename V52121_6 ReluctantMigration
rename V52121_7 ReluctantOther
foreach var of varlist Reluctant* {
	replace `var' = .w if V52121_8 == 1
	tab `var', miss
	// most are reluctant to answer to politics and income
}

tab Reluct , missing //never = 62%
egen ReluctantNum = rowtotal(Reluctant*), missing
label var ReluctantNum "dv: Number of items where the caregiver was reluctant to respond"
tab ReluctantNum Reluct 

rename V52130 BestReply
rename V52140 Understood
rename V52150 Interfere
gen InterferePrtn = (V52160==1) if V52160 <.
gen InterfereChild = (V52160==2) if V52160 <.
gen InterfereParent = (V52160==3) if V52160 <.
gen InterfereRelative = (V52160==4) if V52160 <.
gen InterfereOther = (V52160==5) if V52160 <.
drop V52160
rename V52170 LangIntw
rename V52180_1 Comment
rename V52180_open Comments_open
rename V52190 ItaKnow
rename V52200 Translation
rename V52210 SelfCompl
rename V52220_open SelfCompl_open

/*tab TARGET Cohort, miss // CHECK there should be no difference
drop TARGET

corr ANNO_NASCITA yob1 // CHECK there should be no difference
drop ANNO_NASCITA
*/
* (drop) useless variables
   // self; date of bith; state of birth; city of birth; maxEdu of migrant
drop V20080_* V20310_* // V90200_* V30051 
drop dif_City
   // ever checked important factors for education
drop V31210_*
   // remember the name or address of the asilo/materna
drop V32140* V32150* V32200* V32210*
   // useless high-school graduation
drop V32341 V32350
   // month unempl
drop V33290_2
   // day and month of birth of child (only one var)
drop V34220_*
   // refusal, don't know, not pertinet
drop V52121_8 V39180_?? V41170_*  V43200_5 // V37220_6 V40190_* 
   // IQ and IQ time
// drop V42401_* 

   //  validity of interviews
drop privacy V52180_2 V52220_1 V52220_2 privacy // V1914 V11111 V10010 V10020 
/*rename V1914 intnr2 
label var intnr2 "ID name - progressivo"
egen flagProgressivo = diff(intnr2 PROGRESSIVO) if PROGRESSIVO<.
tab flagProgressivo 
drop flagProgressivo PROGRESSIVO // CHECK that flag is zero
*/
   // times and dates of PAPI
// drop V133000* 
   // Contatto genitore
drop V1100140
   // intervistatore indica/non indica
drop V52111_?
* des V*

* (.) *-*-* Missing values for each part of the Questionnaire *-*-*
global Family		famSize Male Gender* Relation* Age* Birthday* yob* BornIT* BornCity* cityBirth* BirthState* /// 
			ITNation* Migrant* mStatus* PA* MaxEdu* house house_open nationality ageItaly /// hhead hhead_open 
			yrItaly ageCity yrCity livedAwayCity childrenDum childrenNum childrenResp children0_18 children6under childrenOut 
global Education	ageEdu student drop* learn* asilo* materna* momWorking06 momNo06 care* elementary* flagelementaryType media* flagmediaType highschoolType_open /// 
			highschoolGrad votoMaturita uni* votoUni votoUniLode
global Work		EverWork AgeWork WorkPublic HrsWork HrsExtra SES SES_open workComputer workLanguage YrUnemp Lookwork* YrPension 
global Fertility	YrMarry numMarriage CohabBefore CohabBeforeYr everCohab numCohab YrLiveTogether childout*
global Parents		dad* mom* numSiblings grandAlive grandDist grandCare
global Parenting	inv* dist*School
global IQ		*IQ*
global ChildHealth	child1* child2* child3* child4* 
global Health		Health Health16 Sleep Height Weight* BMI* SickDays HCondition* EatOut Breakfast Fruit Snack* sport goSchool* dist*Work
global SocialCapital 	takeCareOth volunteer club* Friends Relatives *SocNet* SocialMeet voted* Politics satis* HomeWork ChildWork /// 
			ReligType Faith Religiosity babyRelig workLearn-workLifeBalance
global TimeUse		Time* Stress*
global Migration	Migr*
global Income		Wage* IncomeCat Pension Benefit Scholarship // NoneTransfer
global Noncog		Locus* reciprocity? Satis* ladder* optimist* pessimist* Trust? Depress?? Depression_* 
global Risky		Smoke* Cig Maria* Drink* Risk*
global Opinions		parentSacrifice grandpaSacrifice eduFamily sexistWork
global Interviewer	Question Question_open Reluct* BestReply Understood Interfere* LangIntw ItaKnow Translation Comment* ///
					SelfCompl SelfCompl_open // lateCAPIconversion incentive email Sessions Help IntTime 

order intnr Cohort City Address $Family $Education $Work $Fertility $Parents $Parenting $IQ $ChildHealth $Health $SocialCapital $TimeUse ///
      $Migration $Income $Noncog $Risky $Opinions $Interviewer flag* // CAPI 

foreach section in Family Education Work Fertility Parents IQ ChildHealth Healt SocialCapital TimeUse /// 
      Migration Income Noncog Risky Opinions Interviewer{
egen Miss`section'    = rowmiss($`section')
egen NonMiss`section' = rownonmiss($`section'), strok
replace Miss`section' = Miss`section' / (Miss`section' + NonMiss`section' )
label var Miss`section' "Percentage of missing answers in section `section'"
drop NonMiss`section'
}

sum Miss*
gen pilot = 1
*-* Item non response: create a dummy equal to 1 if the response is >. (.s .r .w .a or other)
qui ds, has(type numeric)
foreach var in `r(varlist)' {
	gen INR_`var' = (`var'>.)
}
qui ds, has(type string)
foreach var in `r(varlist)' {
	qui gen INR_`var' = .
}

drop INR_flag* INR_Miss*

/*
global INR_Family	INR_famSize INR_Male INR_Gender* INR_Relation* INR_Age* INR_Birthday* INR_yob* INR_BornIT* INR_BornCity* INR_cityBirth* INR_BirthState* /// 
			INR_ITNation* INR_Migrant* INR_mStatus* INR_PA* INR_MaxEdu* INR_hhead INR_hhead_open INR_house INR_house_open INR_nationality INR_ageItaly ///
			INR_yrItaly INR_ageCity INR_yrCity INR_livedAwayCity INR_childrenDum INR_childrenNum INR_childrenResp INR_children0_18 INR_children6under INR_childrenOut 
global INR_Education	INR_ageEdu INR_student INR_drop* INR_learn* INR_asilo* INR_materna* INR_momWorking06 INR_momNo06 INR_care* INR_elementaryType-INR_highschoolType_open /// 
			INR_highschoolGrad INR_votoMaturita INR_uni* INR_votoUni INR_votoUniLode
global INR_Work		INR_EverWork INR_AgeWork INR_WorkPublic INR_HrsWork INR_HrsExtra INR_HrsTot INR_SES INR_SES_open INR_workComputer INR_workLanguage INR_YrUnempl INR_Lookwork* INR_YrPension 
global INR_Fertility	INR_YrMarry INR_numMarriage INR_CohabBefore INR_CohabBeforeYr INR_everCohab INR_numCohab INR_YrLiveTogether INR_childout*
global INR_Parents	INR_dad* INR_mom* INR_numSiblings
global INR_Grandpa	INR_grandAlive INR_grandDist INR_grandCare
global INR_Parenting	INR_inv* INR_dist*School
global INR_ChildHealth	INR_child1* INR_child2* INR_child3* INR_child4* 
global INR_Health	INR_Health INR_Health16 INR_Sleep INR_Height INR_Weight* INR_BMI* INR_SickDays INR_HCondition* INR_EatOut INR_Breakfast INR_Fruit INR_Snack* INR_sport INR_goSchool* INR_distTime INR_distMeter
global INR_SocialCapital INR_takeCareOth INR_volunteer INR_club* INR_Friends INR_Relatives INR_*SocNet* INR_SocialMeet INR_voted* INR_Politics INR_satis* INR_HomeWork INR_ChildWork /// 
			INR_ReligType INR_Faith INR_Religiosity INR_babyRelig INR_workLearn-INR_workLifeBalance
global INR_TimeUse	INR_Time* INR_Stress*
global INR_Migration	INR_Migr*
global INR_Noncog	INR_Locus* INR_reciprocity? INR_Satis* INR_ladder* INR_optimist* INR_pessimist*
global INR_Depress 	INR_Depress?? INR_Depression_* 
global INR_Risky	INR_Smoke* INR_Cig INR_Maria* INR_Drink* INR_Risk*
global INR_Trust	INR_parentSacrifice INR_grandpaSacrifice INR_eduFamily INR_sexistWork INR_Trust?
global INR_Income	INR_Wage* INR_IncomeCat* INR_Pension INR_Benefit INR_Scholarship INR_NoneTransfer
global INR_IQ		INR_*IQ*
global INR_Interviewer	INR_incentive INR_email INR_Sessions INR_Help INR_Question INR_Question_open INR_Reluct* INR_BestReply INR_Understood INR_Interfere* INR_LangIntw INR_ItaKnow INR_Translation INR_Comment* ///
			INR_SelfCompl INR_SelfCompl_open INR_IntTime INR_lateCAPIconversion

foreach section in INR_Family INR_Education INR_Work INR_Fertility INR_Parents INR_Grandpa INR_Parenting INR_ChildHealth INR_Health INR_SocialCapital INR_TimeUse ///
		INR_Migration INR_Noncog INR_Depress INR_Risky INR_Trust INR_Income INR_IQ INR_Interviewer{
// des $`section'
di "`section'"
egen avg`section'    = rowmean($`section')
label var avg`section' "dv: Percentage of item-non-response in section `section'"
}
*/
egen avgINR = rowmean(INR*)
sum avgINR*

/*-*-*-8 For the codebook
save temp_Adult, replace
keep INR*

describe, replace clear
save tempINR_Adult_des, replace

use temp_Adult
keep INR*
logout, replace save(tempINR_Adult_sum) dta: sum

use tempINR_Adult_sum, clear
rename v1 Variable
rename v2 Obs
rename v3 Mean
rename v4 StdDev
rename v5 Min
rename v6 Max
drop if inlist(_n,1)
gen position = _n

merge 1:1 position using tempINR_Adult_des
drop type-_merge
replace name = subinstr(name,"INR_","",10)
destring _all, replace
foreach var of varlist Variable-position{
	rename `var' INR_`var' 
}

save tempINR_Adult, replace
rm tempINR_Adult_des.dta
rm tempINR_Adult_sum.dta
rm tempINR_Adult_sum.txt

use temp_Adult.dta
*/

drop INR* // [=] might want to keep it, but doubles number of variables


compress
save ReggioAdultPilot.dta, replace

capture log close
