clear all
set more off
capture log close

/*
Author: Pietro Biroli (biroli@uchicago.edu)
Purpose: Clean the Adult dataset of the Reggio Project

This Draft: 23 June 2014

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

* log using dataClean_adult, replace
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* 
*-* Integrating the names and addresses 
*-* of the schools 
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
// import excel: name of schools
// import excel "./adults_original.raw/11174_ADULTI_2012_APERTE_INDIRIZZI_NIDO_MATERNA.xls", sheet("DATIBT") firstrow clear
import excel "./adults_original.raw/11174_ADULTI_APERTE_INDIRIZZI_NIDO_MATERNA_FINALE_OK_CLIENTE.xls", sheet("DATIBT") firstrow clear
save adultVerbatim.dta, replace
// import excel: other open answers
// import excel "./adults_original.raw/11174_ADULTI_2012_APERTE_ALTRO.xls", sheet("Aperte") firstrow clear
import excel "./adults_original.raw/ADULTI_APERTE_ALTRO_20dic.xls", sheet("Aperte") firstrow clear
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

label var  V30001_open "Who is the head of household?"
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
* use ./adults_original.raw/S11174EstensivaAdulti2012_303casi.dta, clear
* use ./adults_original.raw/S11174Adulti20Dic.dta, clear
 use ./adults_original.raw/S11174Adulti28Mar.dta, clear
// use ./adults_original.raw/S11174Adulti16Giu.dta, clear //--> new set of interviews from DOXA, run separately and then save as ReggioAdultPadovaReInt

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

*--------------------------------------------------------------------------------------------------------------------------------
*--* Combining the new interviews from Padova 
/*
do gitReggioCode/dataClean_adultPadovaReInt.do
*/
gen interPadova = (internr == 174 | internr == 175 | internr == 2525) if (V1914 > 100000 & V1914 < 200000) // only for Padova adults; V1914 = IDprogressivo
label var interPadova "3 Strange Padova interviewers (174,175,2525)"
append using ReggioAdultPadovaReInt.dta, generate(PadovaReinterview)
label var PadovaReinterview "Second run of interviews done to replace StrangePadovaInterviews"
tab PadovaReinterview, miss
duplicates tag V1914, generate(InterviewedTwice) // V1914 = IDprogressivo
label var InterviewedTwice "Interviewed twice: original and PadovaReinterivew"
tab InterviewedTwice PadovaReinterview, miss

gen source = 1 if PadovaReinterview==0 & interPadova!=1
replace source = 2 if interPadova==1
replace source = 3 if PadovaReinterview==1
label define source 1 "Original" 2 "Strange Padova" 3 "Re-interviews Padova"
label values source source
label var source "Source of the data"
tab source

* Order the variables so that they are the same as in the questionnaire
order V111111 internr intnr V19999 V100040_3 V1330001 V20000_1 V20060_1 V20060_2 V20060_3 V20060_4 V20060_5 V20060_6 V20060_7 ///
V20060_8 V20060_9 V20060_10 V20070_1 V20070_2 V20070_3 V20070_4 V20070_5 V20070_6 V20070_7 V20070_8 V20070_9 V20070_10 ///
V20080_1 V20080_2 V20080_3 V20080_4 V20080_5 V20080_6 V20080_7 V20080_8 V20080_9 V20080_10 V20080_11 V20080_12 V20080_13 ///
V20080_14 V20080_15 V20080_16 V20080_17 V20080_18 V20080_19 V20080_20 V20080_21 V20080_22 V20080_23 V20080_24 V20080_25 ///
V20080_26 V20080_27 V20080_28 V20080_29 V20080_30 V20090_1 V20090_2 V20090_3 V20090_4 V20090_5 V20090_6 V20090_7 ///
V20090_8 V20090_9 V20090_10 V20100_1 V20100_2 V20100_3 V20100_4 V20100_5 V20100_6 V20100_7 V20100_8 V20100_9 V20100_10 ///
V20200_1 V20200_2 V20200_3 V20200_4 V20200_5 V20200_6 V20200_7 V20200_8 V20200_9 V20200_10 V20201_1 V20201_2 V20201_3 ///
V20201_4 V20201_5 V20201_6 V20201_7 V20201_8 V20201_9 V20201_10 V20220_1 V20220_2 V20220_3 V20220_4 V20220_5 V20220_6 ///
V20220_7 V20220_8 V20220_9 V20220_10 V20240_1 V20240_2 V20240_3 V20240_4 V20240_5 V20240_6 V20240_7 V20240_8 V20240_9 ///
V20240_10 V20300_1 V20300_2 V20300_3 V20300_4 V20300_5 V20300_6 V20300_7 V20300_8 V20300_9 V20300_10 V20310_1 V20310_10 ///
V20310_2 V20310_3 V20310_4 V20310_5 V20310_6 V20310_7 V20310_8 V20310_9 V30001 V30051 V30001_open V30020 V30020_open ///
V30050 V30060_1 V30070_1 V31170_1 V31180_1 V31180_2 V31180_3 V31180_4 V31180_5 V31180_6 V31180_7 V31180_8 V31180_O1 ///
V31180_open V31210_1 V31210_2 V31210_3 V31210_4 V31210_5 V31210_O1 V31210_O2 V31210_O3 V31210_O4 V32100 V32110 V32120 ///
V32130 V32140 V32140_NOME_ASILO V32140_Verbatim V32150 V32150_INDIRIZZO_ASILO V32150_Verbatim V32160 V32170 V32180 ///
V32190 V32200 V32200_NOME_MATERNA V32200_Verbatim V32210 V32210_INDIRIZZO_MATERNA V32210_Verbatim V32240_1 V32240_2 ///
V32240_3 V32240_4 V32240_5 V32240_6 V32240_7 V32240_O1 V32240_open V32250_1 V32250_2 V32250_3 V32250_4 V32250_5 V32250_6 ///
V32250_7 V32250_O1 V32250_open V32280 V32290_1 V32290_2 V32290_3 V32290_4 V32290_5 V32290_6 V32290_7 V32290_8 V32290_9 ///
V32290_O1 V32300_1 V32300_2 V32300_3 V32300_4 V32300_5 V32300_6 V32300_7 V32300_8 V32300_9 V32300_O1 V32310_1 V32310_2 ///
V32310_3 V32310_4 V32310_5 V32310_6 V32310_7 V32310_8 V32310_9 V32310_O1 V32320 V32330 V32340 V32340_open V32341 V32350 ///
V32351 V32360 V32360_open V32370 V32371_open V32380_1 V32381 V33100 V33110 V33120_1 V33150 V33190_1 V33190_2 V33192 V2 ///
V2_open V33210 V33220 V33290_1 V33290_2 V33300_1 V33300_2 V33300_3 V33300_4 V33300_5 V33300_6 V33340 V34120 V34130 ///
V34140 V34141 V34142 V34150 V34170 V34180 V34181 V34190 V34210_1 V34220_1 V34220_2 V34220_3 V34240_1 V34290_1 V34300_1 ///
V34210_2 V34220_4 V34220_5 V34220_6 V34240_2 V34290_2 V34300_2 V34210_3 V34220_7 V34220_8 V34220_9 V34240_3 V34290_3 ///
V34300_3 V34210_4 V34220_10 V34220_11 V34220_12 V34240_4 V34290_4 V34300_4 V34210_5 V34220_13 V34220_14 V34220_15 ///
V34240_5 V34290_5 V34300_5 V34210_6 V34220_16 V34220_17 V34220_18 V34240_6 V34290_6 V34300_6 V34210_7 V34220_19 ///
V34220_20 V34220_21 V34240_7 V34290_7 V34300_7 V34210_8 V34220_22 V34220_23 V34220_24 V34240_8 V34290_8 V34300_8 ///
V34210_9 V34220_25 V34220_26 V34220_27 V34240_9 V34290_9 V34300_9 V35120_1 V35121_1 V35122_1 V35140_1 V35120_2 V35121_2 ///
V35122_2 V35140_2 V35150 V35160_1 V35190_1 V35160_2 V35190_2 V36110 V36130 V36140 V37110 V37120 V37130 V37140 V37141 ///
V37150 V37190 V37191 V37200_1 V37200_2 V37200_3 V37210 V37220_1 V37220_2 V37220_3 V37220_4 V37220_5 V37220_6 V37220_open V37230 ///
V37230_open V37240 V37240_open V37260_1 V37260_2 V42399 V42401_1 V42401_2 V42401_3 V42401_4 V42401_5 V42401_6 V42401_7 ///
V42401_8 V42401_9 V42401_10 V42401_11 V42401_12 V38120_1 V38130_1 V38140_1 V38150_1 V38120_2 V38130_2 V38140_2 V38150_2 ///
V38120_3 V38130_3 V38140_3 V38150_3 V38120_4 V38130_4 V38140_4 V38150_4 V39110 V39120 V39141 V39140 V39150 V39180_1 ///
V39180_2 V39180_3 V39180_4 V39180_5 V39180_6 V39180_7 V39180_8 V39180_9 V39180_10 V39180_11 V39180_12 V39180_13 V40110 ///
V40120 V40130 V40190_1 V40190_2 V40190_3 V40190_4 V40190_5 V40190_6 V40190_7 V40190_8 V40190_9 V40190_10 V40190_open V41110 ///
V41170_O1 V41170_O2 V41170_1 V41170_2 V41170_3 V41170_4 V41170_5 V41170_6 V41170_7 V41170_8 V41180 V41181 V43110 V43120 ///
V43140 V43140_open V43170 V43171 V43175_1 V43175_2 V43175_3 V43175_4 V43175_5 V43175_O1 V43175_open V43180 V43200_1 ///
V43200_2 V43200_3 V43200_4 V43200_5 V43220 V43230 V43240 V43250 V43270 V43280 V43290 V43320_1 V43320_2 V43320_3 V43320_4 ///
V43320_5 V43320_6 V44110_1 V44110_2 V44110_3 V44110_4 V44110_5 V44120 V44130 V44130_open V44150 V44160 V45110 V45160 ///
V45170 V45180 V45220 V45230 V45240 V45250 V45260_1 V45260_2 V45260_3 V45260_4 V45260_5 V45260_open V46110 V46110_open ///
V46111 V46112 V46113 V46115 V46116 V46118 V46120 V46130_1 V46130_2 V46130_3 V46130_4 V47110 V47120 V47130 V48110_1 ///
V48110_2 V48110_3 V48110_4 V48150_1 V48150_2 V48150_3 V48150_4 V48200_1 V48200_2 V48200_3 V48200_4 V48220 V48230 V48240 ///
V48250_1 V48250_2 V48250_3 V48250_4 V48250_5 V48250_6 V48250_7 V48250_8 V48250_9 V48250_10 V49110 V49120 V49130 V49135 ///
V49140 V49150 V49156 V49160 V49170 V49180 V49200 V49250 V49410_1 V49410_2 V49410_3 V49410_4 V50110_1 V50110_2 V50110_3 ///
V50110_4 V50210_1 V50210_2 V50210_3 V51110 V51120 V51130 V51200_1 V51200_2 V51200_3 V51200_4 V51200_5 V51200_6 V999120 ///
PROGRESSIVO V100042 V10010 V100100 V10020 V1330002_1 V1330002_2 V1330002_3 V1330002_4 V1330003_1 V1330003_2 V1330003_3 ///
V1330003_4 V1914 V52020 V52030 privacy V1100140 V52110 V52111_1 V52111_2 V52111_open V52120 V52121_1 V52121_2 V52121_3 ///
V52121_4 V52121_5 V52121_6 V52121_7 V52121_8 V52121_open V52130 V52140 V52150 V52160_1 V52160_2 V52160_3 V52160_4 ///
V52160_5 V52170 V52180_1 V52180_2 V52180_open V52190 V52200 V52210 V52220_1 V52220_2 V52220_open V90200_1 V90200_2 ///
V90200_3 V90200_4 V90200_5 V90200_6 V90200_7 V90200_8 V90200_9 V90200_10 _mergeSchoolNames _mergeVerbatim ANNO_NASCITA ///
CITTA_XLS DOM_13 TARGET 

/*-* decode missing values:
.w = Non indica / Non pertinente (not pertinent)
.a = 'Altro, specificare' (Other, specify) --> kept as an answer not as missing for now
.r = Rifiuto (refuse to respond)
.s = Non so / Non ricordo (Don't know/don't remember)
*/
* Non indica
mvdecode V32320 V32330 V44110_? V50210_? V51130 V31210_O? V33150 V34210_? V36130  V36140  V37110  V37150  V37190  V37200_1  V37200_2  V37200_3  V37210 /// V37180  V38110_1 V38110_2 V38110_3 V38110_4 V38170_1 V38170_2 V38170_3 V38170_4 
	V45180 V45220 V45230 V45250 V48110_? V48150_? V48200_? V48250_? V48250_10 V49150 V49160 V49250 /// V45130 V45210 V45320_? V49190 
	V50110_? V51110 V51120 /// V49310 V49330 V51150 V51170 V51190 V51310 V51320 V51330 
	, mv(9 = .w) // Non indica, Non sa, non pertinente

mvdecode V38120_? V38150_? , mv(8 = .p \ 9 = .w) // 8 = non pertinente, 9 = non indica

mvdecode V37260_1 V34170 V34150 V33340 V32350 V32240_O1 V32250_O1 V32290_O1 V32300_O1 V32310_O1 V31180_O1 V30001 V49120 V49135 V49170 V49180 V37141 /// V37251 V43175_O1 
	V35150 V37140 V34170 V34180 V33120_1 V33190_1 V33190_2 V31170_1 V482?0 V37240 V37230 V46110 /// V49230 V37142 V33250_1 V34270_? V34280_? 
	V34240_? V2 V46110 V20220_? V20240_? V30020 V37240 V37230 V48240 V48230 V48220 /// V33271 V33280 V33330 V33140 V30080 
	V43280 V44130 /// V35170_? 
	, mv(99 999 9999 99999 = .w) // Non Indica, Non sa

mvdecode V32370 V47110 V32351 V41180 V32340 V38130_? V38140_? V32380_1 /// V37220 V36150 
	, mv(888 999 9999 99999 = .w) // Non Indica, Non sa, non pertinente

mvdecode V46116 V41181 V46115 /// V41180_? V46135 V46145_? 
	, mv(99999 = .w) // Non Indica, Non sa

mvdecode  V34120 /// V35110_1 V35110_2 
	, mv(9999 99999 = .w) // Non Indica, Non sa

mvdecode V45170 V45160 ///
	, mv(9 = .s) // Non sa

mvdecode V34140 ///
	, mv(9 = .r) // non ricorda
	
mvdecode V43250, mv(3 = .s) // non so
mvdecode V35190_? , mv(6 = .s) // non so V35200_?

* Altro
mvdecode V32240_O1 V32250_O1 V32290_O1 V32300_O1 V32310_O1 V31180_O1 V32370 V32340 V46110 /// V34270_? V34280_? V33271 V33280 V33330 V33140 V30080 V43175_O1 
	V2 V46110 V32340 V46110 V30020, mv(97 98 997 998 = .a) // Altro, specificare 

* 7=Rifiuto, 8=non so, 9= Non pertinente
mvdecode V35160_? V44160 V44150 V43320_6 V43320_5 V43320_4 V43320_3 V43320_2 V43320_1 V43270 V43240 V43230 V43180 /// 
	V40130 V40120 V39150 V39120 V39110 /// V43210 V42120 V42110 V42200_4 V42200_3 V42200_2 V42200_1 V41210 V40190 V40160 V39170 V39160 V39130 
   , mv(7 77 7777 = .r \ 8 88 8888 = .s \ 9 99 9999 = .w) // 7=Rifiuto, 8=non so, 9= Non pertinente

mvdecode V41170_O1 V43171 V39141 V43220 V40110 V41110 V43170 /// V41160 V41190 
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
foreach var of varlist V42399 V42419 { // V42300 V42399 V42419 V51400 V1045401 
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
replace V42419 = V42419 + 24*60*60000 if V42419 < V42399 // add a day if it's midnight and the end time < beginning time
*

gen Date_int = date(V111111, "YMD") 
label var Date_int "Date of the interview"
format Date_int %td
sort Date_int
order Date_int, first
order V11111, last

gen DateBegin  = Cmdyhms(V1330002_2, V1330002_1, year(Date_int),V1330002_3, V1330002_4, 0)
gen DateEnd    = Cmdyhms(V1330003_2, V1330003_1, year(Date_int),V1330003_3, V1330003_4, 0)
format *Date* %tc
format Date_int %td

label var DateBegin "Date of beginning the PAPI questionnaire"
label var DateEnd   "Date of end of the PAPI questionnaire"

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
 (H) Child Health
 (I) Your Health
 (L) Social Capital
 (M) Immigration
(N) Self-completed
 (N-a) Noncognitive
 (N-b) Depression
 (N-c) Risky/unhealthy
 (N-d) Trust and Racism
 (N-e) Income
 (N-f) Weight
(O) Respondent IQ
*/


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
rename V1914 IDprogressivo
label var IDprogressivo "ID of the respondent"

gen     City = 1 if (IDprogressivo > 300000 & IDprogressivo < 400000)
replace City = 2 if (IDprogressivo > 200000 & IDprogressivo < 300000)
replace City = 3 if (IDprogressivo > 100000 & IDprogressivo < 200000)

tab City, miss // CHECK NO MISSING
gen Reggio = (City == 1) if City<.
gen Parma  = (City == 2) if City<.
gen Padova = (City == 3) if City<.

rename V19999 Municipality 
label var Municipality "DON'T USE. Municipality (entered by interviewer at beginning questionnaire)"

label values Municipality City City
tab Municipality City, miss

tab City V100042, miss
drop V100042 // [=] CHECK only if they are the same

egen dif_Municipality = diff(Municipality City)
replace dif_Municipality = 0 if City >=.
gen flagMunicipality = (dif_Municipality == 1)
label var flagMunicipality "dv: Municipality information is different than City"
tab City CITTA // [=] CHECK, there should be no differences!
drop CITTA

rename V100040_3 Address

* CAPI vs PAPI questionnaire
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
	gen BornCity`i' = ((V20100_`i' == 569127081 & City == 1) |  (V20100_`i' == 499127081 & City == 2) |  (V20100_`i' == 490025081 & City == 3)) if V20100_`i'<.
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
rename V30001 hhead
rename V30001_open hhead_open
rename V30020 house
rename V30020_open house_open
rename V30050 nationality
// replace nationality = V30051 if V30051<.

rename V30060_1 yrItaly // NOTE: this is asked if nationality is not italian --> should have been asked if BornIT2 is not italian!
rename V30070_1 yrCity
mvdecode yrItaly yrCity, mv(9998 = . \ 9999 = .w) // 9999 "NON INDICA"; 9998 "SEMPRE VISSUTO QUI" 
label var yrItaly "dv: Year of arrival in Italy (missing if always lived here)"
label var yrCity "dv: Year of arrival in City (missing if always lived here)"
gen ageItaly = max(yrItaly - year(Birthday) , 0) if yrItaly<.
gen ageCity  = max(yrCity  - year(Birthday) , 0) if yrCity<.
replace ageItaly = yrItaly if yrItaly>=.
replace ageCity = yrCity if yrCity>=.
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
// rename V31160 MaxEdu
rename V31170_1 ageEdu

* those who dropped out
rename V31180_1 dropLike
rename V31180_2 dropFrustrat
rename V31180_3 dropWork
rename V31180_4 dropIndep
rename V31180_5 dropUseless
rename V31180_6 dropFam
rename V31180_7 dropOther
rename V31180_8 dropDK
rename V31180_O1 dropReason1
rename V31180_open dropReason1_open

sum drop*
tab MaxEdu dropLike, miss // CHECK that it is there only for high school or less (MaxEdu<=3)

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
tab materna, miss // CHECK no miss; 603 didn't go and 1 doesn't remember
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

* Reason why asilo and materna where important for those who went
rename V32240_1 asiloImportantPlay
rename V32240_2 asiloImportantAuto
rename V32240_3 asiloImportantGame
rename V32240_4 asiloImportantNogo
rename V32240_5 asiloImportantDK
rename V32240_6 asiloImportantOthe
rename V32240_7 asiloImportantMiss
rename V32240_O1 asiloImportant
rename V32240_open asiloImportant_open
* materna
rename V32250_1 maternaImportantPlay
rename V32250_2 maternaImportantAuto
rename V32250_3 maternaImportantGame
rename V32250_4 maternaImportantNogo
rename V32250_5 maternaImportantDK
rename V32250_6 maternaImportantOthe
rename V32250_7 maternaImportantMiss
rename V32250_O1 maternaImportant
rename V32250_open maternaImportant_open

* Mother working or studying while respondent was younger than 6
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
rename V32290_O1 careAsilo
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
rename V32300_O1 careNoAsilo
* when respondent was sick
rename V32310_1 careSickMom
rename V32310_2 careSickDad
rename V32310_3 careSickGra
rename V32310_4 careSickBsh
rename V32310_5 careSickBso
rename V32310_6 careSickBro
rename V32310_7 careSickFam
rename V32310_8 careSickOth
rename V32310_9 careSickDK
rename V32310_O1 careSick

*-* Elementary and middle school
rename V32320 elementaryType
label var elementaryType "Type of elementary school attended"
tab elementaryType , missing // CHECk no missing
tab elementaryType City, missing
gen flagelementaryType = (elementaryType == 4 | elementaryType == 0)
label var flagelementaryType "dv: No elementary school / Don't remember type"

rename V32330 mediaType
label var mediaType "Type of media school attended (first reported)"
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
label var EverWork "dv: =1 if respondent ever worked"
tab PA EverWork, miss // CHECK: only for those who are not working (changed later, see below)

rename V33120_1 AgeWork
tab AgeWork EverWork, miss
rename V33150 WorkPublic

rename V33190_1 HrsWork
replace HrsWork = .w if HrsWork == 98 // CHECK if this is actually a non-response
rename V33190_2 HrsExtra
gen     HrsTot = HrsWork
replace HrsTot = HrsWork + HrsExtra if HrsExtra<.
rename V2 SES
rename V2_open SES_open

rename V33210 workComputer
rename V33220 workLanguage

rename V33290_1 YrUnempl
replace YrUnempl = YrUnempl +  V33290_2/12 if V33290_2<.

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
	
	rename V34210_`Num' childout`Num'Type
	gen childout`Num'Bio = (childout`Num'Type == 1) if childout`Num'Type<.
	rename V34240_`Num' childout`Num'WhyOut
	rename V34290_`Num' childout`Num'Asilo
	rename V34300_`Num' childout`Num'Materna
	
	label var childout`Num'Age	"dv: Age of `Num'-th child living out of the household"
	label var childout`Num'Type	"dv: `Num'-th out-of-house-child is biological/adopted/foster"
	label var childout`Num'Bio 	"dv: `Num'-th out-of-house-child is biological"
	label var childout`Num'WhyOut	"dv: Reason why `Num'-th child lives out of the household"
	label var childout`Num'Asilo 	"dv: `Num'-th out-of-house-child went to infant-toddler center"
	label var childout`Num'Materna	"dv: `Num'-th out-of-house-child went to preschool"
}
format childout?Birthday %td

list childout?Age if childout1Age<childout2Age & childout2Age<. // CHECK there should be none
sum childout?Age
sum childout4* // CHECK there is none
if r(N)==0 {
drop childout4* childout5* childout6* childout7* childout8* childout9* //childout3* 
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
	rename V35190_`i' `parent'Religiosity
}

rename V35150 numSiblings
tab numSiblings, miss

* (F) Gandparents
rename V36110 grandAlive
rename V36130 grandDist
replace grandDist = 7 if grandAlive == 0 //deceased
rename V36140 grandCare


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

rename V37220_open invExtracv_open
rename V37220_1 invSport
rename V37220_2 invDance
rename V37220_3 invTheater
rename V37220_4 invOther
rename V37220_5 invNone
foreach var of varlist invSport-invNone{
	replace `var' = .w if V37220_6 == 1
}

rename V37230 invTakeToSchool
rename V37230_open invTakeToSchool_open
rename V37240 invTakeOutSchool
rename V37240_open invTakeOutSchool_open
rename V37260_1 distTimeSchool
rename V37260_2 distMeterSchool


* (H) Child Health
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

sum child?Age //

//browse intnr internr Age* Relation* childout?Age child?Age if Age<child1Age+15 & child1Age<.
list intnr internr Age Age2 Age3 Age4 Age5 Age6 Relation2 Relation3 Relation4 Relation5 Relation6 if Age<child1Age+15 & child1Age<.
gen flagAgeChild = (Age<child1Age+15 & child1Age<.)
label var flagAgeChild "dv: Child is older than mother (or mother was younger than 15 at birth)"
tab flagAgeChild, miss

forvalues i=1/4{
	rename V38120_`i' child`i'SickDays
	rename V38130_`i' child`i'Height
	rename V38140_`i' child`i'Weight
	rename V38150_`i' child`i'Doctor

	gen child`i'BMI = child`i'Weight/(child`i'Height/100)^2
	/* [=] must find age of the "right" child, but there is no gender!!
	egen child`i'z_BMI = zanthro(child`i'BMI,ba,US), xvar(child`i'Age) ageunit(year) gender(Male) gencode(male=1, female=0)
	egen child`i'BMI_cat = zbmicat(child`i'BMI), xvar(child`i'Age) ageunit(year) gender(Male) gencode(male=1, female=0) // only for those age<18
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

	foreach var of varlist child`i'BMI*{
	replace `var' = child`i'Weight if child`i'Weight>=.
	replace `var' = child`i'Height if child`i'Height>=.
	}
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


* (I) Your Health
rename V39110 Health
rename V39120 Health16
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
foreach var of varlist BMI*{
	replace `var' = Weight if Weight>=.
	replace `var' = Height if Height>=.
}
tab BMI_cat


rename V39150 SickDays
forvalues i=1/10{
	rename V39180_`i' HCondition`i'
	replace HCondition`i' = .r if HCondition`i' == 0 & (V39180_11 == 1) // refuse to respond
	replace HCondition`i' = .s if HCondition`i' == 0 & (V39180_12 == 1) // Don't know
	replace HCondition`i' = .w if HCondition`i' == 0 & (V39180_13 == 1) // not pertinent
}

*Eating
rename V40110 EatOut
rename V40120 Breakfast
rename V40130 Fruit
rename V40190_1 SnackNo
rename V40190_2 SnackFruit
rename V40190_3 SnackIce
rename V40190_4 SnackCandy
rename V40190_5 SnackRoll
rename V40190_6 SnackChips
rename V40190_7 SnackOther

foreach var of varlist Snack* {
replace `var' = .r if `var' == 0 & (V40190_8 == 1) // refuse to respond
replace `var' = .s if `var' == 0 & (V40190_9 == 1 ) // Don't know
replace `var' = .w if `var' == 0 & (V40190_10 == 1) // not pertinent
}
rename V40190_open Snack_open

*Physical Activity
rename V41110 sport
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
rename V41170_O1 goSchool1
rename V41170_O2 goSchool2

rename V41180 distTime
rename V41181 distMeter

* (L) Social Capital
rename V43110 takeCareOth
rename V43120 volunteer
rename V43140 club
rename V43140_open club_open
// rename V43150 scout
rename V43170 Friends
rename V43171 Relatives
rename V43175_1 facebookSocNet
rename V43175_2 linkedinSocNet
rename V43175_3 twitterSocNet
rename V43175_4 otherSocNet
rename V43175_5 noSocNet
rename V43180 SocialMeet
rename V43175_O1 SocNet1
rename V43175_open SocNet_open
egen ciccio = rowtotal(*SocNet)
tab ciccio //CHECK there should be no zeros; convert zero to missing
foreach var of varlist *SocNet{
	replace `var' = .w if ciccio == 0
}
drop ciccio

rename V43200_1 votedNo
rename V43200_2 votedMunicipal
rename V43200_3 votedRegional
rename V43200_4 votedNational
foreach var of varlist voted*{
	replace `var' = .w if `var'==0 & V43200_5 == 1
}

rename V43220 Politics
rename V43230 satisSystemEdu
rename V43240 satisSystemHealth
rename V43250 ReligType
rename V43270 Faith
rename V43280 Religiosity
rename V43290 babyRelig

rename V43320_1 workLearn
rename V43320_2 workEffort
rename V43320_3 workSecurity
rename V43320_4 workAutonomy
rename V43320_5 workStable
rename V43320_6 workLifeBalance

* (L-b) Time use
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
rename V44150 HomeWork
rename V44160 ChildWork

//Replace no partner/no child with a missing
tab childrenNum TimeChild, miss
replace TimeChild = . if TimeChild>. & (childrenNum==0) //no children
tab mStatus TimePrtn, miss
replace TimePrtn = . if TimePrtn>. & (mStatus>1 & mStatus<6) //no partner
tab mStatus HomeWork, miss
replace HomeWork = . if HomeWork == 5 //no partner

* (M) Immigration
rename V45110 MigrBad
rename V45160 MigrIntegr
rename V45170 MigrIntegrMunicipal
rename V45180 MigrAttitude
rename V45220 MigrClassChild
rename V45230 MigrProgram
rename V45240 MigrFriend
rename V45250 MigrMeet
//gen MigrAvoid = (MigrMeet == 1) if MigrMeet<.
//replace MigrAvoid = MigrMeet if MigrMeet >=.
//label var MigrAvoid "dv: Respondents avoids migrants"
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


* (N) Self-Completed
* (N-a) Noncognitive
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

**Sidharth's edit --6/22/2016-- Locus variables reversed**
*--------------------------------------------------------------------------------------------------------*
recode Locus1 (1=5) (2=4) (3=3) (4=2) (5=1), gen(pos_Locus1)
recode Locus2 (1=5) (2=4) (3=3) (4=2) (5=1), gen(pos_Locus2)
recode Locus3 (1=5) (2=4) (3=3) (4=2) (5=1), gen(pos_Locus3)
recode Locus4 (1=5) (2=4) (3=3) (4=2) (5=1), gen(pos_Locus4)

factor pos_Locus?
sem (X -> pos_Locus?), latent(X) var(X@1) method(mlmv)
predict pos_LocusControl if e(sample), latent(X)
label var pos_LocusControl "dv: Modified Adolescent Locus of Control - factor"
*--------------------------------------------------------------------------------------------------------*


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

* (N-b) Depression
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
predict Depression if e(sample), latent(X)
label var Depression "dv: Respondet Depression - factor"

corr Depression*

foreach var of varlist Depress?? {
	quietly replace `var'= .w if `var'_Wmiss==1 //change back to .w missing
	quietly drop `var'_Wmiss
}

**Sidharth's edit --6/22/2016-- Depression scores reversed**
*--------------------------------------------------------------------------------------------------------*
gen pos_Depression_score = (6-Depress01)+(6-Depress02)+(6-Depress03)+(6-Depress04)+Depress05+ ///
                       (6-Depress06)+(6-Depress07)+Depress08+(6-Depress09)+(6-Depress10)
label var pos_Depression_score "dv: Modified Respondet Depression - score"
*--------------------------------------------------------------------------------------------------------*


* (N-c) Risky/unhealthy
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
rename V49200 DrinkProh
* Drugs
rename V49156 Maria
rename V49250 MariaProh
* Risky-seeking behavior
rename V49410_1 RiskSuspended
rename V49410_2 RiskDUI
rename V49410_3 RiskRob
rename V49410_4 RiskFight

* (N-d) Trust and Racism
rename V50110_1 parentSacrifice
rename V50110_2 grandpaSacrifice
rename V50110_3 eduFamily
* sexism
rename V50110_4 sexistWork
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
rename V51200_1 MigrAfri
rename V51200_2 MigrArab
rename V51200_3 MigrAsia
rename V51200_4 MigrEngl
rename V51200_5 MigrSAme
rename V51200_6 MigrSwed
label var MigrTaste "Respondent likes migrants"
label var MigrGood "Respondent thinks migrations is good"

* (N-e) Income
rename V46110 WageReport
rename V46110_open WageReport_open
tab WageReport_open
tab WageReport, missing // CHECK missing (.w) 63% of missing!!!
tab PA WageReport, missing

rename V46111 WageHour
rename V46112 WageDay
rename V46113 WageWeek
rename V46115 WageMonth
rename V46116 WageYear
rename V46118 WageOther
replace WageMonth = 1800 if WageReport_open=="PER 3 MESI 1800 EURO" // manual input
replace WageMonth = 2800 if WageReport_open=="NETTO AL MESE" //manual input

gen     Wage = WageMonth
replace Wage = WageYear/12 if Wage >=. // [=] or times 13 (tredicesima?)
	// Sources for hours and weeks worked 
	// OECD2011: 1774 hrs/year http:// stats.oecd.org/Index.aspx?DatasetCode=ANHRS 
	// see also www.oecd.org/employment/outlook and http://www.nber.org/chapters/c0073.pdf
replace Wage = WageWeek*4.35 if Wage >=.
replace Wage = WageDay*20    if Wage >=. // or times 30 (every working day?)
replace Wage = WageHour*167  if Wage >=. // average working hours in a month -- or multiply by hours worked?
replace Wage = .w if WageReport == .w
label var Wage "dv: Monthly wage of the caregiver"
tabstat Wage, by(WageReport) stat(mean median min max)
mdesc Wage // CHECK almost 65% missing in total

gen flagWage = (Wage < 5000 )
replace flagWage = 1 if WageHour == 99
replace flagWage = 1 if WageMonth >= 11000 & WageMonth<.
replace flagWage = 1 if Wage >=.
label var flagWage "dv: Wage reporting is probably inaccurate"
tab flagWage // CHECK 70% is missing or inaccurate!!

rename V46120 IncomeCat
tab IncomeCat, missing // CHECK 0% non response

rename V46130_1 Pension
rename V46130_2 Benefit
rename V46130_3 Scholarship
rename V46130_4 NoneTransfer

/*----------* Manual change: 
Two main sources of income were reported, the respondent's wage and brackets of family income. 
The first income category is 1 to 5,000 euros; we would expect almost nobody to report such a low yearly family income, 
yet there are quite a few. Consulting DOXA and the interviewers, the most likely problem is that respondents 
used the same time-category that was used to answer the previous question on wage (e.g. monthly). 
Therefore, when a precise wage was reported, the implied yearly amount of that wage was cross-checked 
with the reported income and the income variable was appropriately recoded to take this into account. 
*/
gen temp12 = Wage*12 // yearly wage
sum temp12
label list V46120
gen     IncomeCat_wage = .w if (Wage == .w )
replace IncomeCat_wage = 1 if                    temp12 <= 5000    // yearly wage is lower than 5000
replace IncomeCat_wage = 2 if (temp12 > 5000   & temp12 <= 10000  )
replace IncomeCat_wage = 3 if (temp12 > 10000  & temp12 <= 25000  )
replace IncomeCat_wage = 4 if (temp12 > 25000  & temp12 <= 50000  )
replace IncomeCat_wage = 5 if (temp12 > 50000  & temp12 <= 100000 )
replace IncomeCat_wage = 6 if (temp12 > 100000 & temp12 <= 250000 )
replace IncomeCat_wage = 7 if (temp12 > 250000 ) & temp12<.
tabstat temp12, by(IncomeCat_wage) statistics(mean min max)
label var IncomeCat_wage "dv: Family Income categories, using reported wage"

tab IncomeCat*

egen IncomeCat_manual = rowmax(IncomeCat_wage IncomeCat)
label var IncomeCat_manual "dv: Family Income categories, using the max of reported wage and income categories"

label values IncomeCat* V46120
sum IncomeCat*
drop temp*

* (N-f) Weight
rename V47120 WeightSelfperc
rename V47130 WeightDieting

* (O) Respondent IQ
sum intnr V42401_* //CHECK there are no missing
gen IQ1 = (V42401_1 == 8) if V42401_1<.
gen IQ2 = (V42401_2 == 4) if V42401_2<.
gen IQ3 = (V42401_3 == 5) if V42401_3<.
gen IQ4 = (V42401_4 == 1) if V42401_4<.
gen IQ5 = (V42401_5 == 2) if V42401_5<.
gen IQ6 = (V42401_6 == 5) if V42401_6<.
gen IQ7 = (V42401_7 == 6) if V42401_7<.
gen IQ8 = (V42401_8 == 3) if V42401_8<.
gen IQ9 = (V42401_9 == 7) if V42401_9<.
gen IQ10 = (V42401_10 == 8) if V42401_10<.
gen IQ11 = (V42401_11 == 7) if V42401_11<.
gen IQ12 = (V42401_12 == 6) if V42401_12<.

factor IQ? IQ??
sem (IQ -> IQ? IQ??), iter(500) latent(IQ) method(mlmv) var(IQ@1)
predict IQ_factor if e(sample), latent(IQ)
label var IQ_factor "dv: Respondet mental ability. Raven matrices - factor score"

egen IQ_score = rowtotal(IQ? IQ??)
replace IQ_score = IQ_score/12
label var IQ_score "dv: Respondet mental ability. Raven matrices - % of correct answers"

* 
gen IQtime = V42419 - V42399 
replace IQtime = IQtime/60000 
replace IQtime = .b if IQtime>30 // if the interviewer goes back and forth, it can make the timing imprecise
sum IQtime
label var IQtime "dv: Time spent on IQ Raven Test (minutes)"
* hist IQtime //a lot of very very short!
* twoway (kdensity IQtime if CAPI==1) (kdensity IQtime if CAPI==0), legend(label (1 "CAPI") label (2 "PAPI"))
*


* ( Interviewer part )
rename V999120 incentive
rename V100100 email
* PAPI
rename V52020 Sessions
rename V52030 Help
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
rename V52160_1 InterferePrtn
rename V52160_2 InterfereChild
rename V52160_3 InterfereParent
rename V52160_4 InterfereRelative
rename V52160_5 InterfereOther
rename V52170 LangIntw
rename V52180_1 Comment
rename V52180_open Comments_open
rename V52190 ItaKnow
rename V52200 Translation
rename V52210 SelfCompl
rename V52220_open SelfCompl_open

tab TARGET Cohort, miss // CHECK there should be no difference
drop TARGET

corr ANNO_NASCITA yob1 // CHECK there should be no difference
drop ANNO_NASCITA

* (drop) useless variables
   // self; date of bith; state of birth; city of birth; maxEdu of migrant
drop V20080_* V90200_* V30051 V20310_*
drop dif_Municipality
   // ever checked important factors for education
drop V31210_*
   // remember the name or address of the asilo/materna
drop V32140* V32150* V32200* V32210*
   // useless high-school graduation
drop V32341 V32350
   // consistency checks: working more than 60 hours; end mom questionnaire
drop V33192 
   // month unempl
drop V33290_2
   // day and month of birth of child (only one var)
drop V34220_*
   // refusal, don't know, not pertinet
drop V37220_6 V52121_8 V39180_?? V40190_* V41170_*  V43200_5 
   // IQ and IQ time
drop V42401_* V42399 V42419

   //  validity of interviews
drop privacy V52180_2 V52220_1 V52220_2 privacy V10010 V10020 // V1914 V11111
egen flagProgressivo = diff(IDprogressivo PROGRESSIVO) if PROGRESSIVO<.
tab flagProgressivo  // CHECK that flag is zero
drop flagProgressivo PROGRESSIVO
   // times and dates of PAPI
drop V133000* 
   // Contatto genitore
drop V1100140
   // intervistatore indica/non indica
drop V52111_?
   // same as V32190 maternaType_self
tab DOM_13 maternaType_self
drop DOM_13
* des V*

* (.) *-*-* Missing values for each part of the Questionnaire *-*-*
global Family		famSize Male Gender* Relation* Age* Birthday* yob* BornIT* BornCity* cityBirth* BirthState* /// 
			ITNation* Migrant* mStatus* PA* MaxEdu* hhead hhead_open house house_open nationality ageItaly ///
			yrItaly ageCity yrCity livedAwayCity childrenDum childrenNum childrenResp children0_18 children6under childrenOut 
global Education	ageEdu student drop* learn* asilo* materna* momWorking06 momNo06 care* elementaryType-highschoolType_open /// 
			highschoolGrad votoMaturita uni* votoUni votoUniLode
global Work		EverWork AgeWork WorkPublic HrsWork HrsExtra HrsTot SES SES_open workComputer workLanguage YrUnempl Lookwork* YrPension 
global Fertility	YrMarry numMarriage CohabBefore CohabBeforeYr everCohab numCohab YrLiveTogether childout*
global Parents		dad* mom* numSiblings 
global Grandpa 		grandAlive grandDist grandCare
global Parenting	inv* dist*School
global ChildHealth	child1* child2* child3* child4* 
global Health		Health Health16 Sleep Height Weight* BMI* SickDays HCondition* EatOut Breakfast Fruit Snack* sport goSchool* distTime distMeter
global SocialCapital 	takeCareOth volunteer club* Friends Relatives *SocNet* SocialMeet voted* Politics satis* HomeWork ChildWork /// 
			ReligType Faith Religiosity babyRelig workLearn-workLifeBalance
global TimeUse		Time* Stress*
global Migration	Migr*
global Noncog		Locus* reciprocity? Satis* ladder* optimist* pessimist*
global Depress 		Depress?? Depression* 
global Risky		Smoke* Cig Maria* Drink* Risk*
global Trust		parentSacrifice grandpaSacrifice eduFamily sexistWork Trust?
global Income		Wage* IncomeCat* Pension Benefit Scholarship NoneTransfer
global IQ		*IQ*
global Interviewer	incentive email Sessions Help Question Question_open Reluct* BestReply Understood Interfere* LangIntw ItaKnow Translation Comment* ///
			SelfCompl SelfCompl_open IntTime lateCAPIconversion

order intnr Cohort City Address CAPI $Family $Education $Work $Fertility $Parents $Grandpa $Parenting $ChildHealth $Health $SocialCapital $TimeUse ///
$Migration $Noncog $Depress $Risky $Trust $Income $IQ $interviewer flag*

foreach section in Family Education Work Fertility Parents Grandpa Parenting ChildHealth Health SocialCapital TimeUse ///
		Migration Noncog Depress Risky Trust Income IQ interviewer{
egen Miss`section'    = rowmiss($`section')
egen NonMiss`section' = rownonmiss($`section'), strok
replace Miss`section' = Miss`section' / (Miss`section' + NonMiss`section' )
label var Miss`section' "dv: Percentage of missing answers in section `section'"
drop NonMiss`section'
}

sum Miss*

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
global INR_Depress 	INR_Depress?? INR_Depression* 
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
egen avgINR = rowmean(INR*)
sum avgINR*

*-*-*-8 For the codebook
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
*

drop INR* // [=] might want to keep it, but doubles number of variables


compress
save ReggioAdult.dta, replace
capture log close

/* For the codebook
use ReggioAdult.dta, clear
logout, replace save(temp_Adult_sum) dta: sum

use temp_Adult_sum, clear
rename v1 Variable
rename v2 Obs
rename v3 Mean
rename v4 StdDev
rename v5 Min
rename v6 Max
drop if inlist(_n,1)
gen position = _n
destring _all, replace
save temp_Adult_sum, replace

use ReggioAdult.dta, clear
describe, replace clear

replace varlab= subinstr(varlab,"Ã¨","e'",.)
replace varlab= subinstr(varlab,"Ã©","e'",.)
replace varlab= subinstr(varlab,"é","e'",.)
replace varlab= subinstr(varlab,"è","e'",.)
replace varlab= subinstr(varlab,"Ãˆ","E'",.)
replace varlab= subinstr(varlab,"Ã‰","E'",.)
replace varlab= subinstr(varlab,"Ã¬","i'",.)
replace varlab= subinstr(varlab,"Ã¹","u'",.)
replace varlab= subinstr(varlab,"ù","u'",.)
replace varlab= subinstr(varlab,"Ù","U'",.)
replace varlab= subinstr(varlab,"ò","o'",.)
replace varlab= subinstr(varlab,"Ã²","o'",.)
replace varlab= subinstr(varlab,"Ã€","A'",.)
replace varlab= subinstr(varlab,"â€™","'",.)
replace varlab= subinstr(varlab,"â€","'",.)
replace varlab= subinstr(varlab,"â","'",.)
replace varlab= subinstr(varlab,"Ã","a'",.)
replace varlab= subinstr(varlab,"à","a'",.)
replace varlab= subinstr(varlab,"À","A'",.)
* charlist(varlab) //check there are no weird characters

merge 1:1 position using temp_Adult_sum
drop _merge

save codebook_Adult, replace
rm temp_Adult_sum.dta
rm temp_Adult_sum.txt
capture rm temp_Adult.dta
//rm tempINR_Adult.dta

merge 1:1 name using tempINR_Adult
drop _merge
sort position
save codebook_Adult, replace
outsheet using "temp_codebookAdult", replace

// rm temp_Adult.dta
rm tempINR_Adult.dta
rm codebook_Adult.dta

*/

capture rm temp_Adult.dta
capture rm tempINR_Adult.dta
 capture rm temp_codebookAdult.out
