clear all
set more off
capture log close

/*
Author: Pietro Biroli (biroli@uchicago.edu)
Purpose: Clean the children dataset of the Reggio Project

This Draft: 13 April 2015

Note: The variable names are related to the number of the questions
      in the CAPI version of the questionnaire. See the file: REGGIO SCALES/reggio children quest CAPI bambini 26 nov.D

	  I am renaming the variables keep this convention:
	  - I try to use the camelCaseNamingConvention
	  - All the mother-related variables begin with 'mom'
	  - All the father-related variables begin with 'dad'
	  - All of the variables related to the caregiver begin with 'cg' 
				(note: the second respondent is the caregiver; not always it was the mother)
	  - All the variables that begin with 'child' are the care-giver answer to questions pertaining to the child
	  - All the other variables (without a particular prefix) are related to the child
	  - Not all the variables will be renamed
	  - I try to name the variables in English, even if the labels are usually in Italian;
	    as an execption, I will use the name "asilo" to refer to infant-toddler centers and the name
		"materna" to refer to preschool.
	  
	  For more description of the dataset, the old and new names, the section of the dataset
	  see the file data/sumStat_child.xlsx
	  
	  [=] Signal questions to be addressed

packages used: dummieslab, mvpatterns, zanthro, mdesc, logout
*/

/*-*-* directory: keep global directory from dataClean_all.do unless otherwise needed
 local dir : env klmReggio
 local datadir `dir'/SURVEY_DATA_COLLECTION/data"
cd "`datadir'"
*/

*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-* 
*-* Integrating the names and addresses 
*-* of the schools 
*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
pwd 
// import excel "./child_original.raw/Reggio Children nomi indirizzi materne BAMBINI.xls", sheet("DATIBT") firstrow clear
import excel "./child_original.raw/BAMBINI_11174_APERTE_INDIRIZZI_NIDO_al_3Settembre.xls", sheet("DATIBT") firstrow clear
save childVerbatim.dta, replace

import excel "./child_original.raw/BAMBINI_11174_APERTE_INDIRIZZI_MATERNE_al_3Settembre.xls", sheet("DATIBT") firstrow clear
merge 1:1 INTNR ID_Intervistatore PROGRESSIVO CITTA CAMPIONE using childVerbatim, gen(_mergeNido)
save childVerbatim.dta, replace

// import excel: other open answers
import excel "./child_original.raw/11174_BAMBINI_APERTE_ALTRO_FINALE.xls", sheet("Aperte") firstrow clear
destring _all, replace
drop COD*
tab ETICHETTA
drop ETICHETTA
list INTERVISTATORE INTNR CITTA CAMPIONE N_DOM_APERTA VERBATIM if N_DOM_APERTA==""
// replace N_DOM_APERTA = "V52180" if N_DOM_APERTA=="" // This is missing, but it's a comment
reshape wide @VERBATIM, i(INTNR) j(N_DOM_APERTA) string
des *VERBATIM

rename V30001VERBATIM V30001_open
rename V30020VERBATIM V30020_open
rename V30034VERBATIM V30034_open
rename V53130VERBATIM V53130_open
rename V53131VERBATIM V53131_open
rename V53140VERBATIM V53140_open
rename V53141VERBATIM V53141_open
rename V53190VERBATIM V53190_open
rename V53191VERBATIM V53191_open
rename V33202VERBATIM V33202_open
rename V54201VERBATIM V54201_open
rename V54302VERBATIM V54302_open
rename V56100VERBATIM V56100_open
rename V56200_1VERBATIM V56200_1_open
rename V56200_2VERBATIM V56200_2_open
rename V44130VERBATIM V44130_open
rename V45260VERBATIM V45260_open
rename V46110VERBATIM V46110_open
rename V57111VERBATIM V57111_open
rename V52121VERBATIM V52121_open
rename V52180VERBATIM V52180_open
rename V52220VERBATIM V52220_open
rename V66511VERBATIM V66511_open
rename V66521VERBATIM V66521_open
rename V66541VERBATIM V66541_open
rename V66580VERBATIM V66580_open

rename V30051VERBATIM V30051_open
rename V37220VERBATIM V37220_open
rename V37230VERBATIM V37230_open
rename V37240VERBATIM V37240_open
rename V52170VERBATIM V52170_open
rename V60160VERBATIM V60160_open
rename V66570VERBATIM V66570_open
rename V90200_2VERBATIM V90200_2_open
rename V90200_3VERBATIM V90200_3_open

label var V30001_open "Chi e' il capofamiglia?, Un'altra persona, specificare"
label var V30020_open "La vostra abitazione e' di proprietà oppure siete in affitto?"
label var V30034_open "Abitualmente in famiglia che lingua si parla?"
label var V53130_open "Per quali motivi suo/a figlio/a ha frequentato l'asilo nido? (anche piu' di una risposta"
label var V53131_open "Per quali motivi suo/a figlio/a ha frequentato la scuola materna/dell'infanzia? (anche piu' di una risposta"
label var V53140_open "Quali aspetti dell'esperienza dell'asilo nido pensa siano stati piu' importanti per suo/a figlio/a? (ANCHE PIÙ DI UNA RISPOSTA"
label var V53141_open "Quali aspetti dell'esperienza della scuola materna pensa siano stati piu' importanti per suo/a figlio/a? (ANCHE PIÙ DI UNA RISPOSTA"
label var V53190_open "Ricorda per quali motivi suo/a figlio/a NON ha frequentato l'asilo? (ANCHE PIÙ DI UNA RISPOSTA"
label var V53191_open "Ricorda per quali motivi suo/a figlio/a NON ha frequentato la scuola materna? (ANCHE PIÙ DI UNA RISPOSTA"
label var V33202_open "Puo' dirmi il nome della sua professione attuale, o della sua ultima professione, ed in cosa consiste(va il suo lavoro?"
label var V54201_open "Qual e' l'attività principale del capofamiglia?"
label var V54302_open "Puo' dirmi il nome della professione attuale o precedente del capofamiglia ed in cosa consiste(va il suo lavoro?"
label var V56100_open "Un medico, un infermiere o qualche altro operatore sanitario le ha mai detto che suo\a figlio\a ha:"
label var V56200_1_open "Di solito, cosa mangia fuori dai pasti? (contrassegnare tutte le risposte pertinenti)"
label var V56200_2_open "Di solito, cosa mangia fuori dai pasti? (contrassegnare tutte le risposte pertinenti)"
label var V44130_open "Qual e' la sua principale fonte di stress? (una sola risposta)"
label var V45260_open "Nei gruppi che frequenta ci sono stranieri?"
label var V46110_open "Riguardo al suo lavoro attuale (o quello precedente, qual e' il modo piu' semplice per lei di riferire il suo salario prima delle tasse (salario lordo)"
label var V57111_open "L'intervistato\a ha chiesto delucidazioni su alcune domande. Per quali domande?"
label var V52121_open "Pensi che l'intervistato sia stato riluttante a rispondere a qualche domanda. Per quali domande?"
label var V52180_open "Hai altri commenti da scrivere?"
label var V52220_open "Il modulo da autocompilare dovrebbe essere stato completato dall'intervistato senza alcun aiuto da parte tua. Per favore dicci, come mai questo NON e' successo?"
label var V66511_open "L'intervistato\a ha chiesto delucidazioni su alcune domande. Per quali domande?"
label var V66521_open "Pensi che l'intervistato fosse riluttante a rispondere a qualche domanda. Per quali domande?"
label var V66541_open "In complesso, pensi che l'intervistato abbia capito le domande. Quali domande?"
label var V66580_open "Hai altri commenti da scrivere?"

label var V30051_open "ALTRA NAZIONE"
label var V37220_open "Suo\a figlio\a segue corsi extracurricolari o svolge .... (contrassegnare tutte le risposte pertinenti)?"
label var V37230_open "Di solito chi porta suo\a figlio\a a scuola?"
label var V37240_open "Di solito chi va a prendere suo\a figlio\a a scuola?"
label var V52170_open "In che lingua e' stata condotta l'intervista?"
label var V60160_open "E infine, cosa vuoi fare da grande?"
label var V66570_open "In che lingua e' stata condotta l'intervista?"
label var V90200_2_open "LUOGO_NASCITA (altra nazione) Componente 2:"
label var V90200_3_open "LUOGO_NASCITA (altra nazione) Componente 3:"

rename INTERVISTATORE internr

merge 1:1 INTNR CITTA using childVerbatim, gen(_mergeSchoolNames)

/* NOTE: this has to be the same as merging only using the INTNR: double check that all variables are correct
merge 1:1 INTNR using childVerbatim, gen(_mergeSchoolNames)
*/
rename INTNR intnr //for merging later to the SPSS data

foreach var of varlist V5310?_? V6310?  V530?0_? V6530?0 {
	rename `var' `var'_Verbatim
}
corr internr ID_Inter // CHECK they should be the same
replace internr = ID_Inter if internr == .
drop ID_Inter
save childVerbatim.dta, replace

*-* THE SPSS DATASET
* use "child_original.raw/S11174BAMBINI07Feb.dta", clear
* use "child_original.raw/S11174BAMBINI20Mar.dta", clear
* use "child_original.raw/S11174BAMBINI9Ago.dta", clear
* use "child_original.raw/S11174BAMBINI20Dic.dta", clear
* use "child_original.raw/S11174BAMBINI31Dic.dta", clear
 use "child_original.raw/S11174BAMBINI14Feb.dta", clear

destring _all, replace
* Order the variables so that they are the same as in the questionnaire
order internr intnr V19999 V1330001 V20000_1 V20060_1 V20060_2 V20060_3  ///
V20060_4 V20060_5 V20060_6 V20060_7 V20060_8 V20060_9 V20060_10 V20070_1  ///
V20070_2 V20070_3 V20070_4 V20070_5 V20070_6 V20070_7 V20070_8 V20070_9  ///
V20070_10 V20080_1 V20080_2 V20080_3 V20080_4 V20080_5 V20080_6 V20080_7  ///
V20080_8 V20080_9 V20080_10 V20080_11 V20080_12 V20080_13 V20080_14 V20080_15  ///
V20080_16 V20080_17 V20080_18 V20080_19 V20080_20 V20080_21 V20080_22 V20080_23  ///
V20080_24 V20080_25 V20080_26 V20080_27 V20080_28 V20080_29 V20080_30 V20090_1  ///
V20090_2 V20090_3 V20090_4 V20090_5 V20090_6 V20090_7 V20090_8 V20090_9  ///
V20090_10 V20100_1 V20100_2 V20100_3 V20100_4 V20100_5 V20100_6 V20100_7  ///
V20100_8 V20100_9 V20100_10 V20200_1 V20200_2 V20200_3 V20200_4 V20200_5  ///
V20200_6 V20200_7 V20200_8 V20200_9 V20200_10 V90200_* V20201_1  ///
V20201_2 V20201_3 V20201_4 V20201_5 V20201_6 V20201_7 V20201_8 V20201_9  ///
V20201_10 V20220_1 V20220_2 V20220_3 V20220_4 V20220_5 V20220_6 V20220_7  ///
V20220_8 V20220_9 V20220_10 V20240_1 V20240_2 V20240_3 V20240_4 V20240_5  ///
V20240_6 V20240_7 V20240_8 V20240_9 V20240_10 V20300_1 V20300_2 V20300_3  ///
V20300_4 V20300_5 V20300_6 V20300_7 V20300_8 V20300_9 V20300_10 V20310_* V30001  ///
V30020 V30034 V30050 V30051 V30060_1 V30070_1 V53010 V253041_1  ///
V253041_2 V53040_1 V53040_2 V53040_3 V53040_4 V53040_5 V53040_6 V53041_1  ///
V53041_2 V53041_3 V53041_4 V53041_5 V53041_6 V53041_7 V53041_8 V53041_9  ///
V53041_10 V53050_1 V53050_2 V53050_3 V53050_4 V53050_5 V53060_1 V53060_2  ///
V53060_3 V53060_4 V53060_5 V653041_1 V653041_2 V653050 V653060 V53070 V53100_1 V53100_2 V53100_3 V53100_4  ///
V53100_5 V53100_6 V5300101_1 V5300101_2 V5300101_3 V5300101_4 V5300101_5 V5300101_6  ///
V5300101_7 V5300101_8 V5300101_9 V5300101_10 V53101_1 V53101_2 V53101_3 V53101_4  ///
V53101_5 V53102_1 V53102_2 V53102_3 V53102_4 V53102_5 V6300101_1 V6300101_2 V63101 V63102 V53130_1 V53130_2  ///
V53130_3 V53130_4 V53130_5 V53130_6 V53130_7 V53130_8 V53130_O1 V53131_1  ///
V53131_2 V53131_3 V53131_4 V53131_5 V53131_6 V53131_7 V53131_8 V53131_O1  ///
V53140_1 V53140_2 V53140_3 V53140_4 V53140_5 V53140_6 V53140_7 V53140_O1  ///
V53141_1 V53141_2 V53141_3 V53141_4 V53141_5 V53141_6 V53141_7 V53141_O1  ///
V53150 V53151_1 V53151_2 V53152 V53153_1 V53153_2 V53170_1 V53170_2  ///
V53170_3 V53170_O1 V53190_1 V53190_2 V53190_3 V53190_4 V53190_5 V53190_6  ///
V53190_7 V53190_8 V53190_9 V53190_10 V53190_O1 V53191_1 V53191_2 V53191_3  ///
V53191_4 V53191_5 V53191_6 V53191_7 V53191_8 V53191_9 V53191_10 V53191_O1  ///
V53200 V53220 V53221 V53222 V53231_1 V53231_2 V53231_3 V53231_4  ///
V53231_5 V53231_6 V53231_7 V53231_8 V53231_9 V53231_O1 V53232_1 V53232_2  ///
V53232_3 V53232_4 V53232_5 V53232_6 V53232_7 V53232_8 V53232_9 V53232_O1  ///
V53233_1 V53233_2 V53233_3 V53233_4 V53233_5 V53233_6 V53233_7 V53233_8  ///
V53233_9 V53233_O1 V53250_1 V53250_2 V53250_3 V53250_4 V53250_5 V53260  ///
V53270_1 V53270_2 V53270_3 V53270_4 V53270_O1 V31160 V31120 V31140  ///
V32100 V54030 V32160 V54050 V33100 V33190 V33191  ///
V33192 V33202 V33290 V54180 V33340 V54302 V54201 V54290  ///
V54291 V54292 V54390 V54380 V54440 V34120 V34190 V34191_1  ///
V34191_2 V36130 V36140 V37110 V37120 V37130 V37140 V37141  ///
V37150 V37190 V37200_1 V37200_2 V37200_3 V37210 V37220_1 V37220_2  ///
V37220_3 V37220_4 V37220_5 V55050 V37230 V37240 V37260_1 V37260_2  ///
V55120 V56010_1 V56010_2 V56010_3 V56010_4 V56010_5 V56010_6 V56010_7  ///
V56010_8 V56010_9 V56010_10 V56010_11 V56010_12 V56010_13 V56010_14 V56010_15  ///
V56010_16 V56010_17 V56010_18 V56010_19 V56010_20 V56010_21 V56010_22 V56010_23  ///
V56010_24 V56010_25 V39110 V38110 V38120 V38121 V38122 V38131  ///
V38132 V38142 V38143 V38150 V56100_1 V56100_2 V56100_3 V56100_4  ///
V56100_5 V56100_6 V56100_7 V56100_8 V40120_1 V40120_2 V56130_1 V56130_2  ///
V56200_1_1 V56200_1_2 V56200_1_3 V56200_1_4 V56200_1_5 V56200_1_6 V56200_1_7 V56200_1_8  ///
V56200_1_9 V56200_1_10 V56200_2_1 V56200_2_2 V56200_2_3 V56200_2_4 V56200_2_5 V56200_2_6  ///
V56200_2_7 V56200_2_8 V56200_2_9 V56200_2_10 V41150 V41340 V41350 V43170  ///
V43172 V56580 V43220 V43230 V43260 V43270 V43290 V44110_1  ///
V44110_2 V44110_3 V44110_4 V44110_5 V44120 V44130 V44150 V44160  ///
V45160 V45180 V45220_1 V45220_2 V45230 V45240 V45260_1 V45260_2  ///
V45260_3 V45260_4 V45260_5 V45320_1 V45320_2 V45320_3 V45320_4 V45321_1  ///
V45321_2 V45321_3 V45321_4 V45322_1 V45322_2 V45322_3 V45322_4 V45340_1  ///
V45340_2 V45340_3 V45340_4 V45340_5 V48110_1 V48110_2 V48110_3 V48110_4  ///
V49130 V49135 V49150 V49180 V49200 V49250 V50210_1 V50210_2  ///
V50210_3 V51110 V51200_1 V51200_2 V51200_3 V51200_4 V51200_5 V51200_6  ///
V51320 V51340 V51350 V46110 V46111 V46112 V46113 V46115  ///
V46116 V46118 V46120 V46130_1 V46130_2 V46130_3 V46130_4 V42401_1  ///
V42401_2 V42401_3 V42401_4 V42401_5 V42401_6 V42401_7 V42401_8 V42401_9  ///
V42401_10 V42401_11 V42401_12 V85003 V85005 V201234 V60000_1 V60000_2  ///
V60000_3 V60000_4 V60090_1 V60090_2 V60090_3 V60160_1 V60160_2 V60310_1  ///
V60310_2 V60310_3 V60370 V60380 V60391 V60392 V60393 V60394  ///
V60470_1 V60470_2 V60470_3 V60470_4 V60470_O1 V65010_1 V65010_2 V65010_3  ///
V65010_4 V66040 V66120_1 V66120_2 V66120_3 V66120_4 V66120_5 V66310  ///
V66410_1 V66410_2 V66410_3 V66410_4 V52401_1 V52401_10 V52401_11 V52401_12  ///
V52401_13 V52401_14 V52401_15 V52401_16 V52401_17 V52401_18 V52401_2 V52401_3  ///
V52401_4 V52401_5 V52401_6 V52401_7 V52401_8 V52401_9 V85007 V85008  ///
V999120 V100000 V100100 V100141 V1330002_1 V1330002_2 V1330002_3 V1330002_4  ///
V1330003_1 V1330003_2 V1330003_3 V1330003_4 V1330004_1 V1330004_2 V1330004_3 V1330004_4  ///
V1330005_1 V1330005_2 V1330005_3 V1330005_4 V52020 V52030 V52110 V57111_1  ///
V57111_2 V57111_3 V57111_4 V57111_5 V57111_6 V57111_7 V57111_8 V52120  ///
V52121_1 V52121_2 V52121_3 V52121_4 V52121_5 V52121_6 V52121_7 V52121_8  ///
V52130 V52140 V52150 V52160_1 V52160_2 V52160_3 V52160_4 V52160_5  ///
V52170 V52180_1 V52180_2 V52190 V52200 V52210 V52220_1 V52220_2  ///
privacy V66510 V66520 V66530 V66540 V66550 V66560_1  ///V12 
V66560_2 V66560_3 V66560_4 V66560_5 V66560_6 V66570 V66580_1 V66580_2  ///
V66590 V66600 V66020 V66030 DATA_INT V1914 V10010 V10020 

* merge with the School Names and Addresses
merge 1:1 intnr using childVerbatim.dta, gen(_mergeSchools)
tab _mergeSchools, missing // CHECK no "using only"
gen flagSchool = (_mergeSchools == 2)
list intnr internr if flagSchool==1
drop if _mergeSchools==2 //[=] keep only the ones we have data on
drop flagSchool

foreach var of varlist V53101_? V53102_? V6310?  V53050_? V53060_? V6530?0 {
	gen diff`var' = `var' - `var'_Verbatim
}
sum diff* //CHECK All of these should be zero!
egen dif_SPSS_XLS = rowtotal(diff*)
tab dif_SPSS_XLS, miss //there is no difference
gen flagSPSS_XLS = (dif_SPSS_XLS!=0) if dif_SPSS_XLS<. 
label var flagSPSS_XLS "dv: SPSS has different information than XLS"
drop diff* *_Verbatim

egen CITTA_XLS = group(CITTA) 
replace CITTA_XLS = 4-CITTA_XLS
tab CITTA*, miss
drop CITTA
label define City 1 "Reggio" 2 "Parma" 3 "Padova"
label values CITTA_XLS City

rm childVerbatim.dta

/* decode missing values:
.w = Non indica / Non pertinente (not pertinent)
.r = Rifiuto (refuse to respond)
.s = Non so / Non ricordo (Don't know/don't remember)
	.a = 'Altro, specificare' (Other, specify) --> kept as an answer not as missing for now
*/
* Non indica
mvdecode V66410_* V57111_* V46130* V45340_? V30060_1 V30070_1 V45220_? V38131 V38132 ///
         V38142 V38143 V56010_* V34120 V33190 V33191 V33340 V54201 ///
		 V54290 V54291 /// V31170_1 
		 V53233_O V53232_O V53231_O V53191_O V53190_O V53141_O V53140_O V53131_O V53130_O ///
		 V53220 V51320 V51110 V50210_3 V50210_2 V50210_1 V49250 V48110_4 V48110_3 V48110_2 ///
		 V48110_1 V46120 V46110 V45320_* V45230 V45180 V45160 ///
		 V38150 V38120 V38110 V36140 V36130 V33100 V30020 V30001 V20220_? ///
		 ///
		 V60370 V60310_3 V60310_2 V60310_1 V60090_3 V60090_2 V60090_1 V60000_4 V60000_3 V60000_2 V60000_1 ///
		 V53270_O1 V37210 V37200_? V37190 V37150 V37110 V37220* ///
  , mv(9 99 999 9999 99999 = .w) // Non Indica

mvdecode V49135 V49180 V55050 V3714? V54440 V37230 V37240 V20240_* V54302 V33202, mv(99 = .w) //Non indica (9 = imprenditore)
mvdecode V30050 , mv(999 = .w)
mvdecode V300?0 , mv(9999 = .w)

*Altro
*mvdecode V30020 V20240_* V46110 V33100 V54201 V53141_O1 V53190_O1 V53131_O1, mv(97 98 997 = .a) //Altro, specificare

*7=Rifiuto, 8=non so, 9= Non pertinente
mvdecode ///
         V66040 V43220 V43230 V43270 ///
         V44110_1 V44110_2 V44110_3 V44110_4 V44110_5 V44130 V44150 V44160 V41150 ///
         V41340 V40120_1 V40120_2 V56130_1 V56130_2 ///
   , mv(7 77 7777 = .r \ 8 88 8888 = .s \ 9 99 9999 = .w) //7=Rifiuto, 8=non so, 9= Non pertinente
mvdecode V56580 ///
   , mv(97 = .r \ 98 = .s \ 99 = .w) //97=Rifiuto, 98=non so, 99= Non pertinente
mvdecode V43170 V43172 V43260 ///
   , mv( 77 7777 = .r \ 88 8888 = .s \ 99 9999 = .w) //7=Rifiuto, 8=non so, 9= Non pertinente

*-* Transform 1-2 into 0-1 dummy variables
foreach var of varlist _all {
  qui sum `var'
  if (r(min)==1 & r(max)==2) | (r(min)==2 & r(max)==2) {
    qui replace `var' = 0 if `var' == 2 //transform 2=yes in 0=yes
  }
}

*-* Transform all of the date/time variables in stata format
* IQ begin and end
foreach var of varlist V85003 V85005 V85007 V85008{
	capture drop temp
	replace `var' = subinstr(`var',":","",.)
	gen temp = clock(`var',"hms")
	// replace temp = temp + 24*60*60000 if hh(temp)==0 //add a day if it's midnight
	destring `var' , replace
	replace `var' = temp
	format `var' %tc
	drop temp
}
// Wrong date if inputted at the turn of midnight
replace V85005 = V85005 + 24*60*60000 if V85005 < V85003 // add a day if it's midnight and the end time < beginning time
replace V85008 = V85008 + 24*60*60000 if V85008 < V85007 // add a day if it's midnight and the end time < beginning time

gen Date_int = date(DATA_INT, "YMD") //gen Date_int = date(V11111, "YMD") 

gen cgDateBegin  = Cmdyhms(V1330002_2, V1330002_1, year(Date_int),V1330002_3, V1330002_4, 0)
gen cgDateEnd    = Cmdyhms(V1330003_2, V1330003_1, year(Date_int),V1330003_3, V1330003_4, 0)
gen childDateBegin = Cmdyhms(V1330004_2, V1330004_1, year(Date_int),V1330004_3, V1330004_4, 0)
gen childDateEnd   = Cmdyhms(V1330005_2, V1330005_1, year(Date_int),V1330005_3, V1330005_4, 0)
gen cgIntTime = (cgDateEnd-cgDateBegin)/60000
gen childIntTime = (childDateEnd-childDateBegin)/60000
egen DateBegin = rowmin(*DateBegin)
egen DateEnd = rowmax(*DateEnd)
gen IntTime =  (DateEnd-DateBegin)/60000
replace IntTime = inttime/60 if IntTime >=.
label var IntTime "dv: Interview duration (min) - PAPI or CAPI"

replace inttime = inttime/60 // it's originally in seconds
label var inttime "Interview duration (min) CAPI"

format *Date* %tc
format Date_int %td
sort Date_int

label var Date_int "Date of the interview (entered in the computer)"
label var cgDateBegin "Date of beginning the caregiver PAPI questionnaire"
label var cgDateEnd   "Date of end of the caregiver PAPI questionnaire"
label var childDateBegin "Date of beginning the ado/child PAPI questionnaire"
label var childDateEnd   "Date of end of the ado/child PAPI questionnaire"
label var cgIntTime "dv: Lenght of the caregiver PAPI questionnaire (minutes)"
label var childIntTime "dv: Lenght of the ado/child PAPI questionnaire (minutes)"

pwcorr *IntTime Date_in, sig // no clear connection between date of interview and length
pwcorr *IntTime Date_in if cgIntTime<500, sig // no clear connection between date of interview and length

* if the date of the interview is later than the end of the PAPI, substitute with PAPI
gen lateCAPIconversion = (dofc(DateEnd)< Date_int) if DateEnd<.
label var lateCAPIconversion "The date of the computer is later than the end-date of the PAPI (The interviewer converted PAPI into CAPI some days later)"
replace Date_int = dofc(DateEnd) if lateCAPIconversion == 1

gen flagDate = (dofc(DateEnd)> Date_int) if DateEnd<. 
label var flagDate "The date of the computer is before the end-date of the PAPI (DOXA: Mistake in inputting)"

list intnr internr Date_int DateBegin DateEnd if flagDate==1 // some are made on December and record 2013 instead of 2012

/* SECTIONS OF THE QUESTIONNAIRE
To jump directly to different parts of the questionnaire, search for "* ("
	(A-P) Caregiver
 (A) Family Table
 (B) Child Preschool
 (C) Caregiver Schooling
 (D) Caregiver Work
 (E) Caregiver Personal Relations
 (F) Grandparents
 (G) Parenting
 (H) Child Noncognitive
 (I) Caregiver and Child Health
 (L) Caregiver Social Capital
 (M) Caregiver Time Use
 (N) Caregiver Racism
 (O) Caregiver self-completed
 (O-a) Noncognitive
 (O-b) Risky/unhealthy
 (O-c) Trust and Racism
 (O-d) Income
 (P) Caregiver IQ
	 (A-F) Child
 (A) Child School
 (B) Child Social Capital
 (C) Child Time Use
 (D) Child Reciprocity
 (E) Child Racism
 (F) Child IQ
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

gen     City = 1 if (IDprogressivo > 10000 & IDprogressivo < 40000)
replace City = 2 if (IDprogressivo > 40000 & IDprogressivo < 70000)
replace City = 3 if (IDprogressivo > 70000 & IDprogressivo < 99999)

tab City, miss // CHECK NO MISSING
gen Reggio = (City == 1) if City<.
gen Parma  = (City == 2) if City<.
gen Padova = (City == 3) if City<.

rename V19999 Municipality 
label var Municipality "DON'T USE. Municipality (entered by interviewer at beginning questionnaire)"

label values Municipality City City
tab Municipality City, miss

egen dif_Municipality = diff(Municipality City)
replace dif_Municipality = 0 if City >=.
gen flagMunicipality = (dif_Municipality == 1)
label var flagMunicipality "dv: Municipality information is different than City"
tab City CITTA // [=] CHECK, there should be no differences!
drop CITTA

rename V100040_3 Address
label var Address "Respondent address"

* Cohort
gen     Cohort = 1 if (IDprogressivo > 20000 & IDprogressivo <= 29999) | (IDprogressivo > 50000 & IDprogressivo <= 59999) | (IDprogressivo > 80000 & IDprogressivo <= 89999) 
replace Cohort = 2 if (IDprogressivo > 30000 & IDprogressivo <= 39999) | (IDprogressivo > 60000 & IDprogressivo <= 69999) | (IDprogressivo > 90000 & IDprogressivo <= 99999) 
replace Cohort = 3 if (IDprogressivo > 10000 & IDprogressivo <= 19999) | (IDprogressivo > 40000 & IDprogressivo <= 49999) | (IDprogressivo > 70000 & IDprogressivo <= 79999) 
label var Cohort "Cohort: I=child, II=migr, III=ado, IV-VI: adult"
label define Cohort 1 "Children" 2 "Migrants" 3 "Adolescents" 4 "Adult 30" 5 "Adult 40" 6 "Adult 50"
label values Cohort Cohort
tab Cohort, miss //CHECK there should be no missing
tab Cohort CAMPIONE, miss // CHECK no missing, the same
tab Cohort City, miss // CHECK the numbers are the same as said by Paolo

egen temp = group(City Cohort), label
tabstat IDprogressivo, by(temp) stat(min max)
drop temp

* CAPI vs PAPI questionnaire
rename V1330001 CAPI_detail
tab CAPI_detail, miss
gen CAPI = (CAPI_detail == 1) if CAPI_detail<.
label define CAPI 0 "PAPI" 1 "CAPI"
label values CAPI CAPI
label var CAPI "dv: PAPI (=0) or CAPI (=1) Questionnaire"
tab CAPI, missing

tab City CAPI
tab internr CAPI

probit CAPI Parma Padova

* (A) Family Initial Table --> it's well filled, no missing (except for the V20200 which is there only for those born outside of IT)
rename V20000_1 famSize
label var famSize "Number of family members"
tab famSize , missing
// egen temp = rownonmiss(V20060_*)
// corr famSize temp

* child/ado variables
rename V20060_1 Male // Gender of the child/ado
label var Male "Respondent is male"
label define gender 0 "female" 1 "male"
label values Male gender
tab Male, missing 

*----------* MANUAL CHANGES
replace V20080_1 = 28 if (V20080_1 == 29 & V20080_2 == 2 & V20080_3 == 2006) // the 29th of Feb did not exist in 2006
replace V20080_3 = .w if V20080_3==1900 // CHECK convert to missing if year of birth is 1900
gen Birthday  = mdy(V20080_2 , V20080_1 ,V20080_3)
label var Birthday "Respondent date of birth"
rename V20080_3 yob
label var yob "Year or Birth of respondent"
gen Age = (Date_int - Birthday)/365.25
label var Age "dv: Respondent age at interview"
sum intnr Age // CHECK that it's not too wide: between 17 and 19, and no missing
tab yob, miss // CHECK should only be 1994

rename V20090_1 BornIT
tab BornIT, missing
label var BornIT "Respondent is born in Italy"

gen BornCity = ((V20100_1 == 569127081 & City == 1) |  ///
				 (V20100_1 == 499127081 & City == 2) |  ///
				 (V20100_1 == 490025081 & City == 3))  ///
				if V20100_1<.
label var BornCity "dv: Respondent was born in the city" 

gen BornProvince = 0 if V20100_1<.
replace BornProvince = 1 if (City==1) & (V20100_1 == 12927032 | V20100_1 == 46527032 | V20100_1 == 47627022 | V20100_1 == 68527042 | V20100_1 == 78427032 | V20100_1 == 90727032 | V20100_1 == 100227012 | V20100_1 == 103027042 | V20100_1 == 115527032 | V20100_1 == 115827032 | V20100_1 == 141727022 | V20100_1 == 147527042 | V20100_1 == 153427022 | V20100_1 == 167827042 | V20100_1 == 173027032 | V20100_1 == 173127042 | V20100_1 == 187427032 | V20100_1 == 125727022 | V20100_1 == 221627012 | V20100_1 == 236527052 | V20100_1 == 267227032 | V20100_1 == 306127032 | V20100_1 == 330427032 | V20100_1 == 332427042 | V20100_1 == 358727012 | V20100_1 == 372827032 | V20100_1 == 431127042 | V20100_1 == 468027042 | V20100_1 == 549127032 | V20100_1 == 562027042 | V20100_1 == 565027012 | V20100_1 == 569227032 | V20100_1 == 569127081 | V20100_1 == 574727032 | V20100_1 == 591527022 | V20100_1 == 601427042 | V20100_1 == 631527032 | V20100_1 == 639527032 | V20100_1 == 654527042 | V20100_1 == 671327052 | V20100_1 == 727427022 | V20100_1 == 779727022 | V20100_1 == 780227022 | V20100_1 == 780927022 | V20100_1 == 788927022)
replace BornProvince = 1 if (City==2) & (V20100_1 == 11427022 | V20100_1 == 52127022 | V20100_1 == 58627022 | V20100_1 == 63727022 | V20100_1 == 78327012 | V20100_1 == 81027032 | V20100_1 == 101027032 | V20100_1 == 108627022 | V20100_1 == 222927042 | V20100_1 == 226627032 | V20100_1 == 228627012 | V20100_1 == 236027022 | V20100_1 == 273327032 | V20100_1 == 276727052 | V20100_1 == 284827032 | V20100_1 == 286127032 | V20100_1 == 289227032 | V20100_1 == 347327032 | V20100_1 == 356027022 | V20100_1 == 397827042 | V20100_1 == 405427022 | V20100_1 == 418227012 | V20100_1 == 431627042 | V20100_1 == 461727022 | V20100_1 == 464327042 | V20100_1 == 492527012 | V20100_1 == 499127081 | V20100_1 == 505527012 | V20100_1 == 535127012 | V20100_1 == 584127022 | V20100_1 == 605327032 | V20100_1 == 608727052 | V20100_1 == 642127032 | V20100_1 == 693327022 | V20100_1 == 696327012 | V20100_1 == 698827022 | V20100_1 == 699227032 | V20100_1 == 721027012 | V20100_1 == 727327022 | V20100_1 == 731427012 | V20100_1 == 737127032 | V20100_1 == 741027032 | V20100_1 == 741627022 | V20100_1 == 765327012 | V20100_1 == 768127022 | V20100_1 == 769327012 | V20100_1 == 808127012)
replace BornProvince = 1 if (City==3) & (V20100_1 == 125042 | V20100_1 == 6425022 | V20100_1 == 12825052 | V20100_1 == 24525022 | V20100_1 == 34825012 | V20100_1 == 35225022 | V20100_1 == 36925022 | V20100_1 == 46025022 | V20100_1 == 49625022 | V20100_1 == 51525012 | V20100_1 == 57425022 | V20100_1 == 72625022 | V20100_1 == 82625032 | V20100_1 == 87225022 | V20100_1 == 95025032 | V20100_1 == 103325042 | V20100_1 == 118125042 | V20100_1 == 118625022 | V20100_1 == 121125042 | V20100_1 == 117525032 | V20100_1 == 123025022 | V20100_1 == 135925012 | V20100_1 == 139525032 | V20100_1 == 143525022 | V20100_1 == 146025022 | V20100_1 == 148925032 | V20100_1 == 163325012 | V20100_1 == 198825032 | V20100_1 == 212125022 | V20100_1 == 214725042 | V20100_1 == 219725032 | V20100_1 == 231125042 | V20100_1 == 236725032 | V20100_1 == 250725032 | V20100_1 == 266525042 | V20100_1 == 285425032 | V20100_1 == 301725032 | V20100_1 == 302525022 | V20100_1 == 307725022 | V20100_1 == 323525022 | V20100_1 == 323625022 | V20100_1 == 353325032 | V20100_1 == 359425032 | V20100_1 == 366425032 | V20100_1 == 368125022 | V20100_1 == 392625032 | V20100_1 == 392825012 | V20100_1 == 394625032 | V20100_1 == 398625012 | V20100_1 == 398725022 | V20100_1 == 403425022 | V20100_1 == 404425042 | V20100_1 == 421525042 | V20100_1 == 422525032 | V20100_1 == 436125042 | V20100_1 == 468325042 | V20100_1 == 484925032 | V20100_1 == 490025081 | V20100_1 == 508825022 | V20100_1 == 514925012 | V20100_1 == 518425042 | V20100_1 == 527525032 | V20100_1 == 527925042 | V20100_1 == 537025022 | V20100_1 == 538925022 | V20100_1 == 541725022 | V20100_1 == 540525042 | V20100_1 == 550425022 | V20100_1 == 601025022 | V20100_1 == 601225042 | V20100_1 == 603725022 | V20100_1 == 607625022 | V20100_1 == 621925042 | V20100_1 == 622525032 | V20100_1 == 631025042 | V20100_1 == 638525022 | V20100_1 == 639325022 | V20100_1 == 657625032 | V20100_1 == 658125022 | V20100_1 == 651225032 | V20100_1 == 653625022 | V20100_1 == 655425022 | V20100_1 == 664325042 | V20100_1 == 678625052 | V20100_1 == 695925032 | V20100_1 == 707125022 | V20100_1 == 720325032 | V20100_1 == 723225022 | V20100_1 == 728725032 | V20100_1 == 735125032 | V20100_1 == 741425042 | V20100_1 == 746325022 | V20100_1 == 753625022 | V20100_1 == 771225022 | V20100_1 == 778725012 | V20100_1 == 784325012 | V20100_1 == 785725042 | V20100_1 == 786325052 | V20100_1 == 787825032 | V20100_1 == 788325022 | V20100_1 == 791625032 | V20100_1 == 794225032 | V20100_1 == 802625022 | V20100_1 == 261925032) 

label var BornProvince "dv: Respondent was born in the province" 

tab BornProvince BornCity, miss
tab V20100_1 BornProvince, miss
tab V20100_1 BornCity, miss


rename V20220_1 mStatus
tab mStatus // CHECK it should always be never married
label var mStatus "Marital Status of the respondent"
gen flagmStatus = (mStatus!=5) if mStatus<.
label var flagmStatus "dv: Respondent is not 'never married'"
list intnr internr mStatus if flagmStatus == 1

rename V20240_1 PA 
label var PA "Principal activity of the respondent"
tab PA , missing // CHECK all children should be students

gen student = (PA == 7) if PA<.
replace student = .w if PA==.w
tab student, miss // 30 adolescents are not students
label var student "dv: Respondent is a student"

rename V20300_1 MaxEdu
		* for the migrants
		replace MaxEdu = 1 if V20310_1 == 1 & MaxEdu>=.
		replace MaxEdu = 3 if V20310_1 == 2 & MaxEdu>=.
		replace MaxEdu = 6 if V20310_1 == 3 & MaxEdu>=.
		replace MaxEdu = 8 if V20310_1 == 4 & MaxEdu>=.
		gen flagMaxEdu = (V20310_1 <= 4 & MaxEdu>=.) 
		label var flagMaxEdu "dv: MaxEdu variable completed using migrant education categories"
tab MaxEdu , missing // CHECK: no missing
list intnr internr MaxEdu V20310_1 if MaxEdu>=.
label var MaxEdu "Maximum education level of respondent"

rename V20200_1 BirthState
rename V20201_1 ITNation

*-*Rest of the family
forvalues i = 2(1)10 {
	local j = (`i'*3) - 2 // month of birth (goes on every 3)
	local k = `j'+1       // year of birth
	local l = `j'+2       // day of birth
	replace V20080_`l'=.w if V20080_`l'==1900 // convert to non-respond (.w) if year of birth is 1900
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
		replace MaxEdu`i' = .w if V20310_`i' == 0 & MaxEdu`i'>=.
		gen flagMaxEdu`i' = (V20310_`i' <= 4 & MaxEdu`i'>=.) 
		label var flagMaxEdu`i' "dv: MaxEdu`i' variable completed using migrant education categories"
	gen BornCity`i' = ((V20100_`i' == 569127081 & City == 1) |  (V20100_`i' == 499127081 & City == 2) |  (V20100_`i' == 490025081 & City == 3)) if V20100_`i'<.
	gen BornProvince`i' = 0 if V20100_`i'<.
	replace BornProvince`i' = 1 if (City==1) & (V20100_`i' == 12927032 | V20100_`i' == 46527032 | V20100_`i' == 47627022 | V20100_`i' == 68527042 | V20100_`i' == 78427032 | V20100_`i' == 90727032 | V20100_`i' == 100227012 | V20100_`i' == 103027042 | V20100_`i' == 115527032 | V20100_`i' == 115827032 | V20100_`i' == 141727022 | V20100_`i' == 147527042 | V20100_`i' == 153427022 | V20100_`i' == 167827042 | V20100_`i' == 173027032 | V20100_`i' == 173127042 | V20100_`i' == 187427032 | V20100_`i' == 125727022 | V20100_`i' == 221627012 | V20100_`i' == 236527052 | V20100_`i' == 267227032 | V20100_`i' == 306127032 | V20100_`i' == 330427032 | V20100_`i' == 332427042 | V20100_`i' == 358727012 | V20100_`i' == 372827032 | V20100_`i' == 431127042 | V20100_`i' == 468027042 | V20100_`i' == 549127032 | V20100_`i' == 562027042 | V20100_`i' == 565027012 | V20100_`i' == 569227032 | V20100_`i' == 569127081 | V20100_`i' == 574727032 | V20100_`i' == 591527022 | V20100_`i' == 601427042 | V20100_`i' == 631527032 | V20100_`i' == 639527032 | V20100_`i' == 654527042 | V20100_`i' == 671327052 | V20100_`i' == 727427022 | V20100_`i' == 779727022 | V20100_`i' == 780227022 | V20100_`i' == 780927022 | V20100_`i' == 788927022)
	replace BornProvince`i' = 1 if (City==2) & (V20100_`i' == 11427022 | V20100_`i' == 52127022 | V20100_`i' == 58627022 | V20100_`i' == 63727022 | V20100_`i' == 78327012 | V20100_`i' == 81027032 | V20100_`i' == 101027032 | V20100_`i' == 108627022 | V20100_`i' == 222927042 | V20100_`i' == 226627032 | V20100_`i' == 228627012 | V20100_`i' == 236027022 | V20100_`i' == 273327032 | V20100_`i' == 276727052 | V20100_`i' == 284827032 | V20100_`i' == 286127032 | V20100_`i' == 289227032 | V20100_`i' == 347327032 | V20100_`i' == 356027022 | V20100_`i' == 397827042 | V20100_`i' == 405427022 | V20100_`i' == 418227012 | V20100_`i' == 431627042 | V20100_`i' == 461727022 | V20100_`i' == 464327042 | V20100_`i' == 492527012 | V20100_`i' == 499127081 | V20100_`i' == 505527012 | V20100_`i' == 535127012 | V20100_`i' == 584127022 | V20100_`i' == 605327032 | V20100_`i' == 608727052 | V20100_`i' == 642127032 | V20100_`i' == 693327022 | V20100_`i' == 696327012 | V20100_`i' == 698827022 | V20100_`i' == 699227032 | V20100_`i' == 721027012 | V20100_`i' == 727327022 | V20100_`i' == 731427012 | V20100_`i' == 737127032 | V20100_`i' == 741027032 | V20100_`i' == 741627022 | V20100_`i' == 765327012 | V20100_`i' == 768127022 | V20100_`i' == 769327012 | V20100_`i' == 808127012)
	replace BornProvince`i' = 1 if (City==3) & (V20100_`i' == 125042 | V20100_`i' == 6425022 | V20100_`i' == 12825052 | V20100_`i' == 24525022 | V20100_`i' == 34825012 | V20100_`i' == 35225022 | V20100_`i' == 36925022 | V20100_`i' == 46025022 | V20100_`i' == 49625022 | V20100_`i' == 51525012 | V20100_`i' == 57425022 | V20100_`i' == 72625022 | V20100_`i' == 82625032 | V20100_`i' == 87225022 | V20100_`i' == 95025032 | V20100_`i' == 103325042 | V20100_`i' == 118125042 | V20100_`i' == 118625022 | V20100_`i' == 121125042 | V20100_`i' == 117525032 | V20100_`i' == 123025022 | V20100_`i' == 135925012 | V20100_`i' == 139525032 | V20100_`i' == 143525022 | V20100_`i' == 146025022 | V20100_`i' == 148925032 | V20100_`i' == 163325012 | V20100_`i' == 198825032 | V20100_`i' == 212125022 | V20100_`i' == 214725042 | V20100_`i' == 219725032 | V20100_`i' == 231125042 | V20100_`i' == 236725032 | V20100_`i' == 250725032 | V20100_`i' == 266525042 | V20100_`i' == 285425032 | V20100_`i' == 301725032 | V20100_`i' == 302525022 | V20100_`i' == 307725022 | V20100_`i' == 323525022 | V20100_`i' == 323625022 | V20100_`i' == 353325032 | V20100_`i' == 359425032 | V20100_`i' == 366425032 | V20100_`i' == 368125022 | V20100_`i' == 392625032 | V20100_`i' == 392825012 | V20100_`i' == 394625032 | V20100_`i' == 398625012 | V20100_`i' == 398725022 | V20100_`i' == 403425022 | V20100_`i' == 404425042 | V20100_`i' == 421525042 | V20100_`i' == 422525032 | V20100_`i' == 436125042 | V20100_`i' == 468325042 | V20100_`i' == 484925032 | V20100_`i' == 490025081 | V20100_`i' == 508825022 | V20100_`i' == 514925012 | V20100_`i' == 518425042 | V20100_`i' == 527525032 | V20100_`i' == 527925042 | V20100_`i' == 537025022 | V20100_`i' == 538925022 | V20100_`i' == 541725022 | V20100_`i' == 540525042 | V20100_`i' == 550425022 | V20100_`i' == 601025022 | V20100_`i' == 601225042 | V20100_`i' == 603725022 | V20100_`i' == 607625022 | V20100_`i' == 621925042 | V20100_`i' == 622525032 | V20100_`i' == 631025042 | V20100_`i' == 638525022 | V20100_`i' == 639325022 | V20100_`i' == 657625032 | V20100_`i' == 658125022 | V20100_`i' == 651225032 | V20100_`i' == 653625022 | V20100_`i' == 655425022 | V20100_`i' == 664325042 | V20100_`i' == 678625052 | V20100_`i' == 695925032 | V20100_`i' == 707125022 | V20100_`i' == 720325032 | V20100_`i' == 723225022 | V20100_`i' == 728725032 | V20100_`i' == 735125032 | V20100_`i' == 741425042 | V20100_`i' == 746325022 | V20100_`i' == 753625022 | V20100_`i' == 771225022 | V20100_`i' == 778725012 | V20100_`i' == 784325012 | V20100_`i' == 785725042 | V20100_`i' == 786325052 | V20100_`i' == 787825032 | V20100_`i' == 788325022 | V20100_`i' == 791625032 | V20100_`i' == 794225032 | V20100_`i' == 802625022 | V20100_`i' == 261925032) 
	label var BornProvince`i' "dv: component `i' was born in the province" 	
	
	rename V20200_`i' BirthState`i'
	rename V20201_`i' ITNation`i'
	gen Migrant`i' = (BornIT`i' == 0 & ITNation`i' == 0) if BornIT`i'<.
	gen Age`i' = (Date_int - Birthday`i')/365.25
	
	label var yob`i' "Year or Birth of component `i'"
	label var Gender`i' "Gender of component `i'"
	label var Relation`i' "relation to Respondent of component `i'"
	label var Birthday`i' "date of birth of component `i'"
	label var Age`i' "dv: age at interview of component `i'"
	label var BornIT`i' "component `i' is born in Italy"
	label var mStatus`i' "marital status of component `i'"
	label var PA`i' "principal activity of component `i'"
	label var MaxEdu`i' "maximum education level of component `i'"
	label var BornCity`i' "dv: Component `i' was born in the City"
	label var BirthState`i' "state of Birth of component `i'"
	label var ITNation`i' "Component `i' has italian nationality"
	label var Migrant`i' "dv: Component `i' is a migrant (born outside IT and not IT-nationality)"
}
label values Gender* gender

tab Relation2 // CHECK it should always be genitore/caretaker

* construct the mom and dad indicators
forvalues i=2/10 {
	gen temp_parent`i' = ( Relation`i' == 7 | Relation`i' == 8 | Relation`i' == 9 | Relation`i' == 10 ) // natural, adoptive, foster, or Partner of the other parent
}
gen mom = 2     if (Gender2 == 0 & temp_parent2 == 1) // if component 2 is female and a parent
gen dad = 2     if (Gender2 == 1 & temp_parent2 == 1) // if component 2 is male and a parent
forvalues i=3/10 {
	replace mom = `i' if (Gender`i' == 0 & temp_parent`i' == 1) & mom >=. // if compenent `i' is female and a parent
	replace dad = `i' if (Gender`i' == 1 & temp_parent`i' == 1) & dad >=. // if compenent `i' is male and a parent
}
label var mom "dv: (step)Mother - family component number"
label var dad "dv: (step)Dad - family component number"

tab mom, miss // CHECK there should be very few missing
list intnr Relation2-Relation6 Gender2-Gender4 if mom>=4 // mom is not the caregiver (there were some mistakes in the construction of the family table: person 2 not the caregiver! Assumer caregiver is the parent (when present))
list intnr Relation2-Relation6 Gender2-Gender4 if mom>=. // mom is indeed not present
tab dad, miss 
list intnr Relation2-Relation6 Gender2-Gender4 if dad>=. // dad is indeed not present

gen flag2Famtable = (mom>2) if mom<. 
label var flag2Famtable "dv: Position 2 in family table is not mother (aunt/grandma/other), even if mom present"
// list intnr Relation2-Relation6 if flag2Famtable==1 // there were some mistakes in the construction of the family table: person 2 not the caregiver! Assumer caregiver is the parent (when present)
// browse intnr Relation2-Relation6 Gender2-Gender6 CAPI Cohort City Age? Migrant? if flag2Famtable==1 

*-------- [=] MANUAL FIX ONLY: MOVE MOTHER TO SECOND SPOT WHEN PRESENT (SOMETIMES FIRST ONE IS DAD, UNCLE, GRANDMA,SISTER)
foreach var in Gender Birthday BornCity BornProvince Migrant Relation yob Age BirthState BornIT ITNation mStatus PA MaxEdu{
	* swap 2 with mom 
	gen temp = `var'2	// store value for 2
	forvalues i=3/10{
	  replace `var'2 = `var'`i' if mom==`i' // move mom --> to 2
	  replace `var'`i' = temp   if mom==`i' // move 2 --> mom
	}
	drop temp
}
// browse intnr Relation2-Relation6 Gender2-Gender6 CAPI Cohort City Age? Migrant? if flag2Famtable==1 

drop mom dad temp*
* re-construct the mom and dad indicators
forvalues i=2/10 {
	gen temp_parent`i' = ( Relation`i' == 7 | Relation`i' == 8 | Relation`i' == 9 | Relation`i' == 10 ) // natural, adoptive, foster, or Partner of the other parent
}
gen mom = 2     if (Gender2 == 0 & temp_parent2 == 1) // if component 2 is female and a parent
gen dad = 2     if (Gender2 == 1 & temp_parent2 == 1) // if component 2 is male and a parent
forvalues i=3/10 {
	replace mom = `i' if (Gender`i' == 0 & temp_parent`i' == 1) & mom >=. // if compenent `i' is female and a parent
	replace dad = `i' if (Gender`i' == 1 & temp_parent`i' == 1) & dad >=. // if compenent `i' is male and a parent
}
label var mom "dv: (step)Mother - family component number"
label var dad "dv: (step)Dad - family component number"

tab mom, miss // CHECK there should be very few missing
list intnr Relation2-Relation6 Gender2-Gender4 if mom>=. // there were some mistakes in the construction of the family table: person 2 not the caregiver! Assumer caregiver is the parent (when present)
tab dad, miss 
list intnr Relation2-Relation6 Gender2-Gender4 if dad>=. // there were some mistakes in the construction of the family table: person 2 not the caregiver! Assumer caregiver is the parent (when present)

gen flagCaregiver = (Relation2>10) if Relation2<. 
label var flagCaregiver "dv: Caregiver is not the parent (aunt/grandma/other)"
list intnr Relation2-Relation6 if flagCaregiver==1 // there were some mistakes in the construction of the family table: person 2 not the caregiver! Assumer caregiver is the parent (when present)

// browse intnr MaxEdu* V20310_? flagMaxEdu? Migrant? // CHECK the education of the migrants
tab MaxEdu2, miss // CHECK there are 53 missing (.w) (5%)
tab MaxEdu2 if Migrant2==1, miss // CHECK there are 53 missing (.w) (16%)
sum MaxEdu? Age? // CHECK comparing the missing in Age and in MaxEdu, there are quite a few missing education
// list Age? MaxEdu? if Age2<. & MaxEdu2>=.

gen cgAge = (Date_int - Birthday2)/365.25
label var cgAge "dv: Age of caregiver at interview"
sum intnr cgAge // CHECK that there are no missing

sum V90200_? // CHECK they should all be missing, otherwise replace BirthState

* Age CHECK 
sum Age* // CHECK that is not too high
gen flagAge2 = (Age2>100 & Age2<.)
tab flagAge2
forvalues i=3/10{
replace flagAge2 = 1 if (Age`i'>100 & Age`i'<.)
}
tab flagAge2, miss // CHECK no age problems
list intnr internr Age2 Age3 Age4 Relation2-Relation4 yob2-yob4 if flagAge2==1

forvalues i =3/10{
sum Age`i' if Relation`i'==11 // for siblings: CHECK that ages are not too high
replace flagAge2 = 1 if (Age`i' > 30 & Age`i' < . ) & Relation`i'==11 
}

* browse Gender2 Gender3 Relation2 Relation3 temp* mom dad
// CHECK lesbians?
list intnr internr Gender2 Gender3 Relation2 Relation3 if (Gender2 == 0 & temp_parent2 == 1) & (Gender3 == 0 & temp_parent3 == 1)
// CHECK gays?
list intnr internr Gender2 Gender3 Relation2 Relation3 if (Gender2 == 1 & temp_parent2 == 1) & (Gender3 == 1 & temp_parent3 == 1)
gen flagGay = (Gender2 == 0 & temp_parent2 == 1) & (Gender3 == 0 & temp_parent3 == 1)
replace flagGay = 1 if (Gender2 == 1 & temp_parent2 == 1) & (Gender3 == 1 & temp_parent3 == 1)
label var flagGay "dv: Both parents have the same gender (input mistake?)"
tab flagGay, miss

replace mom = 10 if flagGay == 1 & mom >=.
replace dad = 10 if flagGay == 1 & dad >=.
label define parent 10 "gay?"
label values mom dad parent 
/* CHECK THAT DAD AND MOM ARE REALLY MISSING
browse Relation* Gender* dad if mom>=.
browse Relation* Gender* mom if dad>=.
*/
gen noMom = (mom >=.)
gen noDad = (dad >=.)
label var noMom "dv: No mother in the household (no bio/adoptive/partner)"
label var noDad "dv: No father in the household (no bio/adoptive/partner)"

drop temp*

foreach parent in mom dad {
	gen     `parent'Gender     = Gender2 if `parent' == 2
	gen     `parent'Relation   = Relation2 if `parent' == 2
	gen     `parent'Birthday   = Birthday2   if `parent' == 2
	gen     `parent'BornIT     = BornIT2 if `parent' == 2
	gen     `parent'mStatus    = mStatus2 if `parent' == 2
	gen     `parent'PA         = PA2 if `parent' == 2
	gen     `parent'MaxEdu     = MaxEdu2 if `parent' == 2
	gen     `parent'BornCity   = BornCity2 if `parent' == 2
	gen     `parent'BornProvince = BornProvince2 if `parent' == 2
	gen     `parent'BirthState = BirthState2 if `parent' == 2
	gen     `parent'ITNation   = ITNation2 if `parent' == 2
	gen     `parent'Migrant    = Migrant2 if `parent' == 2
	forvalues i=3/10 {
	replace `parent'Gender     = Gender`i' if `parent' == `i'
	replace `parent'Relation   = Relation`i' if `parent' == `i'
	replace `parent'Birthday   = Birthday`i'   if `parent' == `i'
	replace `parent'BornIT     = BornIT`i' if `parent' == `i'
	replace `parent'mStatus    = mStatus`i' if `parent' == `i'
	replace `parent'PA         = PA`i' if `parent' == `i'
	replace `parent'MaxEdu     = MaxEdu`i' if `parent' == `i'
	replace `parent'BornCity   = BornCity`i' if `parent' == `i'
	replace `parent'BornProvince = BornProvince`i' if `parent' == `i'
	replace `parent'BirthState = BirthState`i' if `parent' == `i'
	replace `parent'ITNation   = ITNation`i' if `parent' == `i'
	replace `parent'Migrant    = Migrant`i' if `parent' == `i'
	}
	gen     `parent'Age = (Date_int - `parent'Birthday)/365.25
	*not used: luogo e comune di nascita, stato estero di nascita, nazionalita'
	label var `parent'Gender "`parent' Gender"
	label var `parent'Relation "`parent' relation to Child/Adolescent"
	label var `parent'Birthday "`parent' date of birth"
	label var `parent'Age "`parent' age at interview"
	label var `parent'BornIT "`parent' is born in Italy"
	label var `parent'mStatus "`parent' marital status"
	label var `parent'PA "`parent' principal activity"
	label var `parent'MaxEdu "`parent' maximum education level"
	label var `parent'BornCity "dv: `parent' was born in the City"
	label var `parent'BornProvince "dv: `parent' was born in the province"
	label var `parent'BirthState "`parent' state of Birth"
	label var `parent'ITNation "`parent' has italian nationality"
	label var `parent'Migrant  "dv: `parent' is a migrant (born outside IT and not IT-nationality)"
}
format *irth* %d
format *BirthState* %8.0g
* Second respondent is caregiver: rename the variables related to the second respodent to cg`varname'
foreach suff in Gender Relation Birthday BirthState BornIT BornCity BornProvince mStatus MaxEdu PA ITNation {
	rename `suff'2 cg`suff'
}

label values *Relation V20070_2
label values *Gender gender
label values *mStatus V20220_1 
label values *PA V20240_1 
label values *MaxEdu V20300_1 

sum intnr cgAge momAge dadAge //[=] DOUBLE CHECK THESE, problems in reporting
gen flagAge = 0
replace flagAge = 1 if (cgAge < 20 | cgAge >70) & cgAge<.
replace flagAge = 1 if (momAge < 20 | momAge >65) & momAge<.
replace flagAge = 1 if (dadAge < 20 | dadAge >75) & dadAge<. //there is a dad aged 70 and another 73, DOXA checked and it's correct
replace flagAge = 1 if (Age < 5 | Age > 8) & Age<. // CHECK for children and adolescents
replace flagAge = 1 if Age>=. // there is no missing
label var flagAge "dv: Age of mother/father/caregiver/child/ado or mother age at birth is not credible"
list intnr internr cgAge momAge dadAge momBirthday dadBirthday if flagAge == 1
// browse Relation* Gender* Age* mom dad if flagAge==1

gen momAgeBirth = momAge - Age
label var momAgeBirth "dv: Mom age at birth of study child"
sum momAgeBirth

gen dadAgeBirth = dadAge - Age
label var dadAgeBirth "dv: dad age at birth of study child"
sum dadAgeBirth
// there is something wrong with *AgeBirth < 15 or >50
// see the flag variable [=]
gen     flagAgeBirth = (momAgeBirth<15 | momAgeBirth>45) if momAgeBirth<.
replace flagAgeBirth = 1 if (dadAgeBirth<15 | dadAgeBirth>60) & dadAgeBirth<.
list intnr internr cgAge ???AgeBirth momAge dadAge if flagAgeBirth == 1 // | flagAge == 1
label var flagAgeBirth "dv: Mother (Father) age at child's birth is below 15 or higher than 45 (60)"
tab flagAgeBirth flagAge, miss
sum dadAge* momAge* if flagAgeBirth==1
// browse *Relation* *Gender* mom momAge dad dadAge if intnr == 37708700 | intnr == 48122900

// Mom and dad age at the birth of the siblings
gen flagAgeBirth2 = .
forvalues i =3/10{
di "checking component `i'"
gen momAgeBirth`i' = momAge - Age`i' if Relation`i'==11 // for siblings: CHECK that ages are not too high
label var momAgeBirth`i' "Mother age at birth of component `i'"
replace flagAgeBirth2 = 1 if (momAgeBirth`i' < 15 | momAgeBirth`i' > 45) & momAgeBirth<. & Relation`i'==11 
gen dadAgeBirth`i' = dadAge - Age`i' if Relation`i'==11 // for siblings: CHECK that ages are not too high
label var dadAgeBirth`i' "Father age at birth of component `i'"
replace flagAgeBirth2 = 1 if (dadAgeBirth`i' < 15 | dadAgeBirth`i' > 60) & dadAgeBirth<. & Relation`i'==11 
}
sum momAgeBirth* dadAgeBirth*
label var flagAgeBirth2 "dv: Mother (Father) age at sibling's birth is below 15 or higher than 45 (60)"
tab flagAgeBirth*, miss
// browse intnr *Age* *Gender* *Relation* if flagAgeBirth2==1 | flagAgeBirth==1

* family size and other house characteristics
egen childrenSibIn = anycount(Relation*), values(11) // Relation* does not include the child herself or the caregiver
label var childrenSibIn "dv: Number of child/ado's siblings living in the household"

gen olderSibling = 0
gen youngSibling = 0
label var olderSibling "N. of older sibling living in the household"
label var youngSibling "N. of younger sibling living in the household"
forvalues iter=3/10{
	replace olderSibling = olderSibling+1 if (Relation`iter'==11 & Birthday`iter'<Birthday)
	replace youngSibling = youngSibling+1 if (Relation`iter'==11 & Birthday`iter'>Birthday)
}
** browse intnr famSize Age Birthday* *Sibling childrenSibIn if olderSibling>0

foreach var of varlist Age* {
gen round`var' = round(`var')
}
egen children0_18 = anycount(roundAge*), values(0/18)
drop roundAge*

tab famSize childrenSibIn, miss
tab famSize children0_18, miss
tab children0_18 childrenSibIn, miss

** Twins: there are some twins 
gen Twin = 0
forvalues i =3/10{
di "checking component `i'"
replace Twin = 1  if Relation`i'==11 & (Birthday`i' == Birthday) // check siblings with same birthday
}
label var Twin "Respondent has a twin living in the household"

*Two-twins in the dataset (they almost look like duplicates)
duplicates tag City Cohort Birthday if Twin==1, gen(TwinInData)
		/*
		sort Birthday
		browse intnr internr Cohort City Address Date_int Twin* stime CAPI famSize Male cgGender Gender* Age cgAge Age? Birthday Birthday? Relation? cgRelation if Twin==1
		*/

* house characteristics
rename V30001 hhead
rename V30001_open hhead_open
rename V30020 house
rename V30020_open house_open
rename V30034 lang
rename V30034_open lang_open
rename V30050 cgNationality
replace cgNationality = V30051 if V30051<.
rename V30051_open cgNationality_open 
//there are some discrepancies between cgITNation and Nationality: force them to be the same
gen flagcgMigrant = 1 if  (cgNationality!=121 & cgITNation==1) | (cgNationality==121 & cgITNation==0) 
replace cgITNation = 1 if cgNationality==121 
replace cgITNation = 0 if cgNationality!=121 

rename V30060_1 yrItaly // NOTE: this is asked if nationality is not italian --> should have been asked if BornIT2 is not italian!
rename V30070_1 yrCity
replace yrItaly = . if yrItaly == 9998 // 9999 "NON INDICA"; 9998 "SEMPRE VISSUTO QUI" // min(yrItaly,year(cgBirthday)) replaced with year of birth of second respondent
replace yrCity = . if yrCity == 9998 // 9999 "NON INDICA"; 9998 "SEMPRE VISSUTO QUI" // min(yrCity,year(cgBirthday)) replaced with year of birth of second respondent
label var yrItaly "Year of arrival in Italy (missing if always lived here)"
label var yrCity "Year of arrival in City (missing if always lived here)"
gen ageItaly = max(yrItaly - year(cgBirthday) , 0) if yrItaly!=.w
gen ageCity  = max(yrCity  - year(cgBirthday) , 0) if yrCity!=.w
label var ageItaly "dv: Age of arrival in Italy"
label var ageCity "dv: Age of arrival in the city"

gen flagAgemigrant = (ageCity < ageItaly)
label var flagAgemigrant "dv: Age arrival city < age arrival italy"
replace ageCity = ageItaly if ageCity < ageItaly // WARNING it shuold never be negative
gen livedAwayCity = ageCity - ageItaly //  >0 if arrived first in Italy and then moved to City
sum livedAwayCity 
label var livedAwayCity "dv: Ages lived in italy but not in this city"

/*-*-* Migrant Indicator *-*-*
The caregiver is born outside of Italy AND doesn't have IT nationality

The whole family is classified as a migrant based on the caregive's status 
The questions about migration (*Migr*) are asked only to the migrant families

For some issues, see the flag variable
*/
gen cgMigrant = (cgBornIT == 0 & cgITNation == 0) if (cgBornIT<.)
label var cgMigrant "dv: Migrant Family - based on mother's birth-place (not IT) AND nationality (not IT)"
tab cgMigrant , miss
tab cgNationality cgMigrant , miss
sum *BornIT* *ITNation* if cgMigrant == 1

// looking at the child
gen childMigrant = (BornIT == 0 & ITNation == 0) if (BornIT<.)
label var childMigrant "dv: Child is Migrant - based on child/ado's birth-place (not IT) AND nationality (not IT)"
tab childMigrant BornIT, miss
tab childMigrant ITNation, miss

tab cgMigrant childMigrant, miss
tab BornIT cgMigrant, miss
tab ITNation cgMigrant, miss // there are 2 children with non-IT nationality but mother is non-migrant

tab cgMigrant Cohort, miss // CHECK there should be cgMigrants only in the immigrant sample!
tab childMigrant Cohort, miss
tab childMigrant cgMigrant, miss

* (B) Child/Adolescent Preschool --> everybody replies
*-* Infant-toddler center
rename V53010 asilo
tab asilo, miss // CHECK no missing. only 31 went to "altre forme di accudimento" (3%)
gen flagasilo = (asilo == 4 | asilo >=.) //Don't remember or missing
label var flagasilo "dv: Doesn't know and doesn't answer whether attended asilo nido"
replace asilo = .s if asilo==4  //Don't remember or missing

egen asiloMultiple = rowtotal (V53040_?), missing
label var asiloMultiple "dv: Respondent reported more than one asilo-type"
tab asiloMultiple asilo, missing // CHECK there are 11 who reported to 2 asili, and 1 who reported to 3
label define LABI 0 "0" , modify
label define LABJ 0 "0" , modify
list V53040_? if asiloMultiple>1 & asiloMultiple<.

gen asiloType_self = 0 if asilo!=1 // 0 if not gone to asilo, missing will be replaced by type of school
replace asiloType_self = asilo if asilo>=. //missing or non-response
forvalues i = 1(1)6 {
	replace asiloType_self = `i' if V53040_`i' == 1 & asiloType_self >=.
}
replace asiloType_self = .s if asiloType_self == 6 // don't remember
label var asiloType_self "dv: Type of infant-toddler center attended (first self-reported)"
rename V53040_1 asiloStat_self
rename V53040_2 asiloMuni_self
rename V53040_3 asiloPubb_self
rename V53040_4 asiloReli_self
rename V53040_5 asiloPriv_self
rename V53040_6 asiloDK_self

label define Type_self 0 "Not Attended" 1 "State" 2 "Municipal" 3 "Public (DK)" 4 "Religious" 5 "Private" .s "Don't remember"
label values asiloType_self Type_self
tab asiloType_self , missing // CHECk no missing, only 7 don't remember
tab asiloType_self asilo, missing // CHECK
tab asiloType_self City, missing

gen flagasiloType_self = (asiloType_self == 6)
label var flagasiloType_self "dv: Don't remember / don't answer question about type of asilo nido"

	*age of entry and exit
rename V253041_1 asiloBeginOthe
rename V253041_2 asiloEndOther
rename V53041_1  asiloBeginStat
rename V53041_2  asiloEndStat
rename V53041_3  asiloBeginMuni
rename V53041_4  asiloEndMuni
rename V53041_5  asiloBeginPubb
rename V53041_6  asiloEndPubb
rename V53041_7  asiloBeginReli
rename V53041_8  asiloEndReli
rename V53041_9  asiloBeginPriv
rename V53041_10 asiloEndPriv

egen asiloBegin = rowmin(asiloBegin????)
label var asiloBegin "dv: Age at beginning of Asilo nido"
egen asiloEnd = rowmax(asiloEnd????)
label var asiloEnd "dv: Age at ending of Asilo nido"
gen asiloAges = asiloEnd - asiloBegin
label var asiloAges "dv: Ages spent in Asilo nido (overall)"

foreach suff in Othe Stat Muni Pubb Reli Priv{
	gen asiloAges`suff' = asiloEnd`suff' - asiloBegin`suff'
	label var asiloAges`suff' "dv: Ages spent in Asilo nido `suff'"
}
/* CHECK
egen ciccio = rowtotal(asiloAges????)
gen diff = asiloAges - ciccio
tab diff
* There are some people who report two or more asili, but during the same age. 
egen tempBeg1 = rowmin(asiloBegin????) // min
egen tempBeg2 = rowmax(asiloBegin????) // max
egen tempEnd1 = rowmin(asiloEnd????) // min
egen tempEnd2 = rowmax(asiloEnd????) // max
* looking at the names they reported, only very few actually went to only 1 asilo, but checked two boxes
* see flagAsiloMultiple -- manual check
browse intnr asiloAges temp ciccio asiloMultiple asiloAges* asiloBegin* asiloEnd* asilo*_self if asiloMultiple>1 & asiloMultiple<.
*/

* if multiple asili reported, see where spent more time and use that one as asiloType
egen temp = rowmax(asiloAges????)
gen prova = ""
foreach suff in Priv Reli Stat Pubb Muni { // if two or more have the same number of ages, Muni has priority, then pubb, then stat etc..
replace prova = "`suff'" if asiloAges`suff' == temp & temp<.
}
// browse prova asiloAges* temp asiloType_self
replace asiloType_self = 1 if prova == "Stat" & asiloMultiple>1 & asiloMultiple<.
replace asiloType_self = 2 if prova == "Muni" & asiloMultiple>1 & asiloMultiple<.
replace asiloType_self = 3 if prova == "Pubb" & asiloMultiple>1 & asiloMultiple<.
replace asiloType_self = 4 if prova == "Reli" & asiloMultiple>1 & asiloMultiple<.
replace asiloType_self = 5 if prova == "Priv" & asiloMultiple>1 & asiloMultiple<.
drop temp prova

	*name and/or address
egen asiloLocation = rowtotal(V53050_? V53060_?), missing
label var asiloLocation "dv: Do you remember the name/ address of the ailo?"
label define Location 0 "Yes, both" 1 "Yes, either name or address" 2 "No"
label values asiloLocation Location
tab asiloLocation, missing // those who don't remember neither name nor address (location = 2) are few
tab asiloType_self asiloLocation , missing 

egen asiloLocation_name = concat(V53050_?_NOME V653050_NOME)
egen temp2 = concat(V53050_?_NOME V653050_NOME), punct(;)
replace asiloLocation_name = temp2 if asiloMultiple > 1 & asiloMultiple <. // use ";" to separate multiple names 
drop temp2
egen asiloLocation_address = concat(V53060_?_INDIRIZZO V653060_INDIRIZZO)
egen temp2 = concat(V53060_?_INDIRIZZO V653060_INDIRIZZO), punct(;)
replace asiloLocation_address = temp2 if asiloMultiple > 1 & asiloMultiple <. // use ";" to separate multiple addresses 
drop temp2
// browse intnr asiloLocation* asiloType_self *NOME *INDIRIZZO

*-* Materna
rename V53070 materna
tab materna, miss // CHECK no miss; 23 didn't go and 2 don't remember
recode materna (2 = 0) (3 = .s)
gen flagmaterna = (materna == 3 | materna >=.)
label var flagmaterna "dv: Doesn't know and doesn't answer whether attended scuola materna"

egen maternaMultiple = rowtotal (V53100_?), missing
label var maternaMultiple "dv: Respondent reported more than one materna-type"
tab maternaMultiple materna, missing
list V53100_? if maternaMultiple >1 & maternaMultiple<. // there's 8 children who went to 2 different materna

gen maternaType_self = 0 if materna!=1 // 0 if not gone to materna, missing will be replaced by type of school
replace maternaType_self = materna if materna>=. //missing or non-response
forvalues i = 1(1)6 {
	replace maternaType_self = `i' if V53100_`i' == 1 & maternaType_self >=.
}
replace maternaType_self = .s if maternaType_self == 6 // don't remember
label var maternaType_self "dv: Type of preschool attended (first self-reported)"
label values maternaType_self Type_self
tab maternaType_self , missing // CHECK no missing, only 2 don't remember
tab maternaType_self materna , missing
tab maternaType_self City, missing

gen flagmaternaType_self = (maternaType_self == 6)
label var flagmaternaType_self "dv: Don't remember / don't answer question about type of materna"

rename V53100_1 maternaStat_self
rename V53100_2 maternaMuni_self
rename V53100_3 maternaPubb_self
rename V53100_4 maternaReli_self
rename V53100_5 maternaPriv_self
rename V53100_6 maternaDK_self

	*age of entry and exit
rename V5300101_1 maternaBeginStat
rename V5300101_2 maternaEndStat
rename V5300101_3 maternaBeginMuni
rename V5300101_4 maternaEndMuni
rename V5300101_5 maternaBeginPubb
rename V5300101_6 maternaEndPubb
rename V5300101_7 maternaBeginReli
rename V5300101_8 maternaEndReli
rename V5300101_9 maternaBeginPriv
rename V5300101_10 maternaEndPriv

egen maternaBegin = rowmin(maternaBegin????)
label var maternaBegin "dv: Age at beginning of materna"
egen maternaEnd = rowmax(maternaEnd????)
label var maternaEnd "dv: Age at ending of materna"
gen maternaAges = maternaEnd - maternaBegin
label var maternaAges "dv: Ages spent in Materna (overall)"

foreach suff in Stat Muni Pubb Reli Priv{
	gen maternaAges`suff' = maternaEnd`suff' - maternaBegin`suff'
	label var maternaAges`suff' "dv: Ages spent in materna `suff'"
}
/* CHECK
egen ciccio = rowtotal(maternaAges????)
gen diff = maternaAges - ciccio
tab diff
* There are some people who report two or more asili, but during the same age. 
egen tempBeg1 = rowmin(maternaBegin????) // min
egen tempBeg2 = rowmax(maternaBegin????) // max
egen tempEnd1 = rowmin(maternaEnd????) // min
egen tempEnd2 = rowmax(maternaEnd????) // max
* looking at the names they reported, only very few actually went to only 1 materna, but checked two boxes
* see flagAsiloMultiple -- manual check
browse intnr maternaAges temp ciccio maternaMultiple maternaAges* maternaBegin* maternaEnd* materna*_self if maternaMultiple>1 & maternaMultiple<.
*/

* if multiple materna reported, see where spent more time and use that one as maternaType
egen temp = rowmax(maternaAges????)
gen prova = ""
foreach suff in Priv Reli Stat Pubb Muni { // if two or more have the same number of ages, Muni has priority, then pubb, then stat etc..
replace prova = "`suff'" if maternaAges`suff' == temp & temp<.
}
// browse prova maternaAges* temp maternaType_self
replace maternaType_self = 1 if prova == "Stat" & maternaMultiple>1 & maternaMultiple<.
replace maternaType_self = 2 if prova == "Muni" & maternaMultiple>1 & maternaMultiple<.
replace maternaType_self = 3 if prova == "Pubb" & maternaMultiple>1 & maternaMultiple<.
replace maternaType_self = 4 if prova == "Reli" & maternaMultiple>1 & maternaMultiple<.
replace maternaType_self = 5 if prova == "Priv" & maternaMultiple>1 & maternaMultiple<.
drop temp prova

* name and/or address
recode V53101_? V53102_? (2 = 0)
egen maternaLocation = rowtotal(V53101_? V53102_?), missing
label var maternaLocation "dv: Do you remember the name/ address of the materna?"
label values maternaLocation Location
tab maternaLocation, missing // those who don't remember neither name nor address (location = 2) are few
tab maternaType_self maternaLocation , missing 

egen maternaLocation_name = concat(V53101_?_NOME V63101_NOME)
egen temp2 = concat(V53101_?_NOME V63101_NOME), punct(;)
replace maternaLocation_name = temp2 if maternaMultiple > 1 & maternaMultiple <. // use ";" to separate Multiple names 
drop temp2
egen maternaLocation_address = concat(V53102_?_INDIRIZZO V63102_INDIRIZZO)
egen temp2 = concat(V53102_?_INDIRIZZO V63102_INDIRIZZO), punct(;)
replace maternaLocation_address = temp2 if maternaMultiple > 1 & maternaMultiple <. // use ";" to separate Multiple addresses 
drop temp2
// browse intnr maternaMultiple maternaType_self maternaLocation_*

* Reason and motive why child/adolescent sent to asilo and scuola materna: 
	*1) needed to work
	*2) younger siblings needed care
	*3) no grandparent
	*4) important for growth
	*5) to socialize
rename V53130_1 asiloMotiveWork
rename V53130_2 asiloMotiveSibl
rename V53130_3 asiloMotiveNGra
rename V53130_4 asiloMotiveGrow
rename V53130_5 asiloMotiveSoci
rename V53130_6 asiloMotiveDK
rename V53130_7 asiloMotiveOthe
rename V53130_8 asiloMotiveMiss
rename V53130_O1 asiloMotive
rename V53130_open asiloMotive_open
* materna motive
rename V53131_1 maternaMotiveWork
rename V53131_2 maternaMotiveSibl
rename V53131_3 maternaMotiveNGra
rename V53131_4 maternaMotiveGrow
rename V53131_5 maternaMotiveSoci
rename V53131_6 maternaMotiveDK
rename V53131_7 maternaMotiveOthe
rename V53131_8 maternaMotiveMiss
rename V53131_O1 maternaMotive
rename V53131_open maternaMotive_open

* reason why asilo and materna where important for those who went
rename V53140_1 asiloImportantPlay
rename V53140_2 asiloImportantAuto
rename V53140_3 asiloImportantGame
rename V53140_4 asiloImportantNogo
rename V53140_5 asiloImportantDK
rename V53140_6 asiloImportantOthe
rename V53140_7 asiloImportantMiss
rename V53140_O1 asiloImportant
rename V53140_open asiloImportant_open
* materna
rename V53141_1 maternaImportantPlay
rename V53141_2 maternaImportantAuto
rename V53141_3 maternaImportantGame
rename V53141_4 maternaImportantNogo
rename V53141_5 maternaImportantDK
rename V53141_6 maternaImportantOthe
rename V53141_7 maternaImportantMiss
rename V53141_O1 maternaImportant
rename V53141_open maternaImportant_open

* time
rename V53150 asiloTime
rename V53151_1 asiloTimeBegin
rename V53151_2 asiloTimeEnd
rename V53152 maternaTime
rename V53153_1 maternaTimeBegin
rename V53153_2 maternaTimeEnd

* mother/father involvement
rename V53170_1 asiloParticipation
rename V53170_2 maternaParticipation
rename V53170_3 noParticipation
rename V53170_O1 parentParticipation

* Reason why NOT sent to asilo or schola materna
rename V53190_1 asiloNoMotiveGrow
rename V53190_2 asiloNoMotiveSmal
rename V53190_3 asiloNoMotiveWill
rename V53190_4 asiloNoMotiveCost
rename V53190_5 asiloNoMotiveFull
rename V53190_6 asiloNoMotiveQual
rename V53190_7 asiloNoMotiveGran
rename V53190_8 asiloNoMotiveDK
rename V53190_9 asiloNoMotiveOthe
rename V53190_10 asiloNoMotiveMiss
rename V53190_O1 asiloNoMotive
rename V53190_open asiloNoMotive_open
* materna
rename V53191_1 maternaNoMotiveGrow
rename V53191_2 maternaNoMotiveSmal
rename V53191_3 maternaNoMotiveWill
rename V53191_4 maternaNoMotiveCost
rename V53191_5 maternaNoMotiveFull
rename V53191_6 maternaNoMotiveQual
rename V53191_7 maternaNoMotiveGran
rename V53191_8 maternaNoMotiveDK
rename V53191_9 maternaNoMotiveOthe
rename V53191_10 maternaNoMotiveMiss
rename V53191_O1 maternaNoMotive
rename V53191_open maternaNoMotive_open

foreach var in asiloMotive asiloImportant asiloNoMotive maternaMotive maternaImportant maternaNoMotive {
	egen `var'Nr = rowtotal(`var'????), missing
	label var `var'Nr "dv: Number of reasons checked for `var'"
}

* Mother working or studying while child/adolescent was younger than 6
rename V53200 momWorking06
gen momWorkingAge = V53221
replace momWorkingAge = V53222*12 if momWorkingAge >=.
replace momWorkingAge = .w  if V53220==.w & momWorkingAge >=.
label var momWorkingAge "dv: How old was the child when the mother starting working again?"

* Who took care of the Child/Adolescent?
* when was not at the asilo
rename V53231_1 careAsiloMom
rename V53231_2 careAsiloDad
rename V53231_3 careAsiloGra
rename V53231_4 careAsiloBsh
rename V53231_5 careAsiloBso
rename V53231_6 careAsiloBro
rename V53231_7 careAsiloFam
rename V53231_8 careAsiloOth
rename V53231_9 careAsiloDK
rename V53231_O1 careAsilo
* in the years he did not go to asilo
rename V53232_1 careNoAsiloMom
rename V53232_2 careNoAsiloDad
rename V53232_3 careNoAsiloGra
rename V53232_4 careNoAsiloBsh
rename V53232_5 careNoAsiloBso
rename V53232_6 careNoAsiloBro
rename V53232_7 careNoAsiloFam
rename V53232_8 careNoAsiloOth
rename V53232_9 careNoAsiloDK
rename V53232_O1 careNoAsilo
* when Child/Adolescent was sick
rename V53233_1 careSickMom
rename V53233_2 careSickDad
rename V53233_3 careSickGra
rename V53233_4 careSickBsh
rename V53233_5 careSickBso
rename V53233_6 careSickBro
rename V53233_7 careSickFam
rename V53233_8 careSickOth
rename V53233_9 careSickDK
rename V53233_O1 careSick

* Difficulties encountered when starting primary school
rename V53250_1 difficultiesSit
rename V53250_2 difficultiesInterest
rename V53250_3 difficultiesObey
rename V53250_4 difficultiesEat
rename V53250_5 difficultiesNone

gen difficulties = .
label var difficulties "dv: Difficulties encountered when starting primary school"
local i = 0
foreach var of varlist difficulties* {
	local i = `i'+1
	replace difficulties = `i' if `var'==1 & difficulties >=.
}

label define difficulties 1 "La capacita' di stare seduto in un gruppo se richiesto " 2 " La mancanza di interesse nell'apprendimento " 3 " La capacita' nell'obbedire alle regole e direttive " 4 " La difficolta' nel mangiare " 5 "non indica\non ricorda\non sa" 
label values difficulties difficulties 

* Further schooling
rename V53260 elementary
rename V53270_1 elementaryState
rename V53270_2 elementaryRelig
rename V53270_3 elementaryPrivate
rename V53270_4 elementaryDK
rename V53270_O1 elementaryType

*-*-*-*-*-*-*-*-*-*
* (C-P) Caregiver Variables
* (C) Caregiver Schooling
// rename V31170 cgAgeSchool
// tab cgAgeSchool, missing
rename V31160 cgMaxEdu2
corr cgMaxEdu2 cgMaxEdu // CHECK they should be the same
gen flag_cgMaxEdu1 = (cgMaxEdu2 != cgMaxEdu & cgMaxEdu2<.)
label var flag_cgMaxEdu1 "dv: Max edu of caregiver is not consistently reported (see cgMaxEdu2 cgMaxEdu)"
list intnr cgMaxEdu2 cgMaxEdu if flag_cgMaxEdu1==1 & cgMaxEdu2<. // only one discrepancy, scuola media superiore vs inferiore

rename V31120 cgImmAsilo
rename V31140 cgImmMaterna
rename V32100 cgAsilo 
tab cgAsilo, miss //  10 people don't remember
mvdecode cgAsilo, mv(4 = .s)
recode cgAsilo (2=0)
replace cgAsilo = cgImmAsilo if cgAsilo>=. // merge the migrants and italians reports about infant-toddler center
tab cgAsilo, miss // only 10 missing

rename V54030 cgAsiloLike
tab cgAsiloLike cgAsilo , missing

rename V32160 cgMaterna 
tab cgMaterna //  5 people don't remember
mvdecode cgMaterna, mv(3 = .s)
recode cgMaterna (2=0)
replace cgMaterna = cgImmMaterna if cgMaterna>=. // merge the migrants and italians reports about preschool

rename V54050 cgMaternaLike
tab cgMaternaLike cgMaterna , missing

* (D) Caregiver Work
rename V33100 cgprincipalAct 
polychoric cgprincipalAct cgPA
drop cgprincipalAct 

rename V33190 cgHrsWork
rename V33191 cgHrsExtra
gen    cgHrsTot = cgHrsWork
replace cgHrsTot = cgHrsWork + cgHrsExtra if cgHrsExtra<.
rename V33202 cgSES
rename V33202_open cgSES_open
rename V33290 cgYrUnempl
rename V54180 cgLookwork
rename V33340 cgYrPension

tab cgSES cgPA, miss
label list V33100

rename V54302 hhSES
rename V54302_open hhSES_open
tab hhSES, miss
rename V54201 hhPA
rename V54201_open hhPA_open
tab hhPA, miss
rename V54290 hhHrsWork
rename V54291 hhHrsExtra
rename V54390 hhYrUnempl
rename V54380 hhLookwork
rename V54440 hhYrPension

tab hhSES hhPA, miss
label list V33100

* (E) Caregiver Family and personal relations
rename V34120 cgYrMarry
rename V34190 childrenSibOut
gen childrenSibTot = childrenSibIn + childrenSibOut
gen childrenTot = childrenSibIn + childrenSibOut + 1 
label var childrenSibOut "dv: Number of child/ado's siblings living outside of the house"
label var childrenSibTot "dv: Total number of siblings of the child/adolescent, living in or outside of the house"
label var childrenTot "dv: Total number of children of the family, living in or outside of the house (siblings+1)"

rename V34191_1 asiloChildren
rename V34191_2 maternaChildren
tab maternaChildren asiloChildren // there are some discrepancies: 4 vs 5 children
tab childrenTot asiloChildren 
tab childrenTot maternaChildren 
tab asiloChildren asilo 
	// the question might have been misunderstood, there are some people who say that no children has gone to asilo, but they report that child/adolescent went
	replace asiloChildren = 1 if asilo == 1 & asiloChildren == 0
tab maternaChildren materna
	// the question might have been misunderstood, there are some people who say that no children has gone to asilo, but they report that child/adolescent went
	replace maternaChildren = 1 if materna == 1 & maternaChildren == 0

* (F) Grandparents
rename V36130 grandDist
rename V36140 grandCare

gen grandAlive = (grandDist != 7) if grandDist<.
replace grandAlive = .w if grandDist == .w
tab grandDist grandAlive, miss
// replace grandDist = . if grandDist == 7 //deceased

* (G) Caregiver Investment (HOME)
/* NOTE: this is similar to the questions of the adult questionnaire; however here the questions are reffered to the 
level of investment RECEIVED by the child, hence they are called childinv* (in the adult, it refers to the investment 
that the adult makes into her own children, hence they are called inv*) */
rename V37110 childinvReadTo
rename V37120 childinvMusic
rename V37130 childinvCom
rename V37140 childinvTV_hrs
rename V37141 childinvVideoG_hrs
rename V37150 childinvOut
rename V37190 childinvFamMeal
rename V37200_1 childinvChoresRoom
rename V37200_2 childinvChoresHelp
rename V37200_3 childinvChoresHomew
rename V37210 childinvReadSelf
rename V37220_1 childinvSport
rename V37220_2 childinvDance
rename V37220_3 childinvTheater
rename V37220_4 childinvOther
foreach var in childinvSport childinvDance childinvTheater childinvOther{
   replace `var' = .w if V37220_5 == 1
}
rename V37220_open childinvExtracv_open

rename V55050 childinvFriends
rename V37230 childinvTakeToSchool
rename V37230_open childinvTakeToSchool_open
rename V37240 childinvTakeOutSchool
rename V37240_open childinvTakeOutSchool_open
rename V37260_1 distTime
rename V37260_2 distMeter
rename V55120 childSuspended

// factor childinvReadTo-childinvFriends

* (H) Caregiver on Child/Adolescent Noncog
rename V56010_1 childSDQPsoc1
rename V56010_2 childSDQHype1
rename V56010_3 childSDQEmot1
rename V56010_4 childSDQPsoc2
rename V56010_5 childSDQCond1
rename V56010_6 childSDQPeer1
rename V56010_7 childSDQCond2
rename V56010_8 childSDQEmot2
rename V56010_9 childSDQPsoc3
rename V56010_10 childSDQHype2
rename V56010_11 childSDQPeer2
rename V56010_12 childSDQCond3
rename V56010_13 childSDQEmot3
rename V56010_14 childSDQPeer3
rename V56010_15 childSDQHype3
rename V56010_16 childSDQEmot4
rename V56010_17 childSDQPsoc4
rename V56010_18 childSDQCond4
rename V56010_19 childSDQPeer4
rename V56010_20 childSDQPsoc5
rename V56010_21 childSDQHype4
rename V56010_22 childSDQCond5
rename V56010_23 childSDQPeer5
rename V56010_24 childSDQEmot5
rename V56010_25 childSDQHype5

* Missing: by question and by respondent
foreach var of varlist childSDQ????? {
	tab `var', missing // CHECK there are not that many missing (less than 10)
	quietly gen `var'_Wmiss = (`var'>.)
	quietly replace `var'= . if `var'>. //change .w missing into . missing so that SEM works better
}
mvpatterns childSDQ?????

factor childSDQ????? , factor(7)
sem ( X -> childSDQ????? ), latent(X) var(X@1) iter(500) method(mlmv)
predict childSDQ_factor if e(sample), latent(X)

foreach suff in Emot Peer Psoc Hype Cond {
	factor childSDQ`suff'?
	sem ( X -> childSDQ`suff'? ), latent(X) var(X@1) method(mlmv) iter(500)
	predict childSDQ`suff'_factor if e(sample), latent(X)
}
replace childSDQPsoc_factor = -childSDQPsoc_factor // reverse so that higher = more prosocial

foreach var of varlist childSDQ????? {
	quietly replace `var'= .w if `var'_Wmiss==1 //change back to .w missing
	quietly drop `var'_Wmiss
}

* official scoring (from http://www.sdqinfo.org/c3.html)
recode childSDQCond1 (1=3) (2=2) (3=1) (else=.), gen(qobeys)
recode childSDQHype4 (1=3) (2=2) (3=1) (else=.), gen(qreflect)
recode childSDQHype5 (1=3) (2=2) (3=1) (else=.), gen(qattends)
recode childSDQPeer2 (1=3) (2=2) (3=1) (else=.), gen(qfriend)
recode childSDQPeer3 (1=3) (2=2) (3=1) (else=.), gen(qpopular)

egen nemotion=rownonmiss(childSDQEmot1 childSDQEmot2 childSDQEmot3 childSDQEmot4 childSDQEmot5)
egen pemotion=rmean(childSDQEmot1 childSDQEmot2 childSDQEmot3 childSDQEmot4 childSDQEmot5) if nemotion>2
replace pemotion=15-round(pemotion*5) // each question scores 1 to 3, 3 being False: must reverse it and take away 5

egen nconduct=rownonmiss(childSDQCond1 qobeys childSDQCond3 childSDQCond4 childSDQCond5)
egen pconduct=rmean(childSDQCond1 qobeys childSDQCond3 childSDQCond4 childSDQCond5) if nconduct>2
replace pconduct=15-round(pconduct*5)

egen nhyper=rownonmiss(childSDQHype1 childSDQHype2 childSDQHype3 qreflect qattends)
egen phyper=rmean(childSDQHype1 childSDQHype2 childSDQHype3 qreflect qattends) if nhyper>2
replace phyper=15-round(phyper*5)

egen npeer=rownonmiss(childSDQPeer1 qfriend qpopular childSDQPeer4 childSDQPeer5)
egen ppeer=rmean(childSDQPeer1 qfriend qpopular childSDQPeer4 childSDQPeer5) if npeer>2
replace ppeer=15-round(ppeer*5)

egen nprosoc=rownonmiss(childSDQPsoc1 childSDQPsoc2 childSDQPsoc3 childSDQPsoc4 childSDQPsoc5)
egen pprosoc=rmean(childSDQPsoc1 childSDQPsoc2 childSDQPsoc3 childSDQPsoc4 childSDQPsoc5) if nprosoc>2
replace pprosoc=15-round(pprosoc*5)

drop qobeys qreflect qattends qfriend qpopular nemotion nconduct nhyper npeer nprosoc

gen pebdtot=pemotion+pconduct+phyper+ppeer

rename pemotion childSDQEmot_score
rename pconduct childSDQCond_score
rename phyper   childSDQHype_score
rename ppeer    childSDQPeer_score
rename pprosoc  childSDQPsoc_score
rename pebdtot  childSDQ_score

foreach suff in score factor {
	label var childSDQEmot_`suff' "dv: SDQ emotional symptoms `suff' - Mother reports"
	label var childSDQCond_`suff' "dv: SDQ conduct problems `suff' - Mother reports"
	label var childSDQHype_`suff' "dv: SDQ hperactivity/inattention `suff' - Mother reports"
	label var childSDQPeer_`suff' "dv: SDQ peer problems `suff' - Mother reports"
	label var childSDQPsoc_`suff' "dv: SDQ prosocial `suff' - Mother reports"
	label var childSDQ_`suff' "dv: SDQ Total difficulties `suff' - Mother reports"
}

foreach var of varlist childSDQ*_*{
	replace `var' = .w if `var'==.
}

sum childSDQ*_score

* (I) Caregiver and Child/Adolescent Health
rename V39110 cgHealth
rename V38110 childHealth
rename V38120 childSickDays
rename V38121 cgSleep
rename V38122 childSleep
rename V38131 cgHeight
rename V38132 childHeight
rename V38142 cgWeight
rename V38143 childWeight

gen cgBMI = cgWeight/(cgHeight/100)^2
gen childBMI = childWeight/(childHeight/100)^2

gen cgAgeDay = cgAge * 365.25
gen childAgeDay = Age * 365.25
egen childz_BMI = zanthro(childBMI,ba,US), xvar(childAgeDay) ageunit(day) gender(Male) gencode(male=1, female=0)
* egen chidBMIcat = zbmicat(childBMI), xvar(childAgeDay) ageunit(day) gender(Male) gencode(male=1, female=0) // only for those age<18
gen cgBMIcat = .
gen childBMIcat = .
foreach pp in child cg {
replace `pp'BMIcat = 0 if `pp'BMI < 18.5 & `pp'BMIcat >=.
replace `pp'BMIcat = 1 if `pp'BMI < 25   & `pp'BMIcat >=.
replace `pp'BMIcat = 2 if `pp'BMI < 30   & `pp'BMIcat >=.
replace `pp'BMIcat = 3 if `pp'BMI > 30   & `pp'BMIcat >=. & `pp'BMI<. 
}
foreach var of varlist *BMI*{
	replace `var' = .w if `var'==.
}
label define BMIcat 0 "Under wg" 1 "Normal wg" 2 "Overweight" 3 "Obese"
label values *BMIcat BMIcat
label var childBMIcat "dv: Child BMI categories"
label var cgBMIcat "dv: Caregiver BMI categories"
label var cgBMI "dv: Caregiver Body-Mass-Index (kg/m^2)"
label var childBMI "dv: Respondent Body-Mass-Index (kg/m^2) - caregiver report"
label var childz_BMI "dv: Respondent BMI - standardized score"
tab *BMIcat

drop *AgeDay

rename V38150 childDoctor
// Has the Child/Adolescent been diagnosed with one of the following disorders
rename V56100_1 childAsthma_diag
rename V56100_2 childAllerg_diag
rename V56100_3 childDigest_diag
rename V56100_4 childEmot_diag
rename V56100_5 childSleep_diag
rename V56100_6 childGums_diag
rename V56100_7 childOther_diag
rename V56100_8 childNone_diag
egen childTotal_diag = rowtotal(childAsthma_diag-childOther_diag)
replace childTotal_diag = .w if childTotal_diag == .
label var childTotal_diag "dv: Total number of diagnosed health problems"
rename V56100_open child_diag_open

* Eating
rename V40120_1 cgBreakfast
rename V40120_2 childBreakfast
rename V56130_1 cgFruit
rename V56130_2 childFruit
rename V56200_1_1 cgSnackNo
rename V56200_1_2 cgSnackFruit
rename V56200_1_3 cgSnackIce
rename V56200_1_4 cgSnackCandy
rename V56200_1_5 cgSnackRoll
rename V56200_1_6 cgSnackChips
rename V56200_1_7 cgSnackOther
foreach var of varlist cgSnack* {
replace `var' = .r if `var' == 0 & (V56200_1_8 == 1) // refuse to respond
replace `var' = .s if `var' == 0 & (V56200_1_9 == 1 ) // Don't know
replace `var' = .w if `var' == 0 & (V56200_1_10 == 1) // not pertinent
}
rename V56200_1_open cgSnack_open

rename V56200_2_1 childSnackNo
rename V56200_2_2 childSnackFruit
rename V56200_2_3 childSnackIce
rename V56200_2_4 childSnackCandy
rename V56200_2_5 childSnackRoll
rename V56200_2_6 childSnackChips
rename V56200_2_7 childSnackOther
foreach var of varlist childSnack* {
replace `var' = .r if `var' == 0 & (V56200_2_8 == 1) // refuse to respond
replace `var' = .s if `var' == 0 & (V56200_2_9 == 1 ) // Don't know
replace `var' = .w if `var' == 0 & (V56200_2_10 == 1) // not pertinent
}
rename V56200_2_open childSnack_open

* exercize
rename V41150 sportTogether

* birth
rename V41340 birthweight
rename V41350 birthpremature
tabstat birthweight, by(birthpremature) stat(mean sd min max)
gen lowbirthweight = (birthweight < 2500) if birthweight<.
label var lowbirthweight "dv: Birthweight < 2500 gr"
gen flagbirthwg = (birthweight < 700) if birthweight<.
label var flagbirthwg "dv: birthweight < 700g"
list intnr birthweight if flagbirthwg == 1 // CHECK

* (L) Caregiver Social Capital
rename V43170 cgFriends
rename V43172 cgRelatives
rename V56580 cgSocialMeet
sum intnr cgFriends-cgSocialMeet // some missing
polychoric cgFriends cgRelatives cgSocialMeet 

* twoway (kdensity cgFriends) (kdensity cgRelatives)
rename V43220 cgPolitics
tab cgPolitics, missing // 56% don't know/not interested

rename V43230 cgSatisEdu
rename V43260 cgReligType
gen cgRelig = (cgReligType > 0 ) if cgReligType<.
label var cgRelig "dv: Caregiver is religious"
replace cgRelig = cgReligType if cgRelig>=.
rename V43270 cgFaith
rename V43290 childRelig
tab cgFaith cgRelig, miss

polychoric cgFaith cgRelig childRelig

* (M) Caregiver Time Use
rename V44110_1 cgTimePrtn
rename V44110_2 cgTimeChild
rename V44110_3 cgTimeWork
rename V44110_4 cgTimeFriend
rename V44110_5 cgTimeFree
rename V44120 cgStress
rename V44130 cgStressSource
rename V44130_open cgStressSource_open
rename V44150 cgHomeWork
rename V44160 cgChildWork

//Replace no partner/no child with a missing
tab cgmStatus cgTimePrtn, miss
// replace cgTimePrtn = . if cgTimePrtn>. & (cgmStatus>1 & cgmStatus<6)
tab cgmStatus cgHomeWork, miss
mvdecode cgHomeWork cgChildWork , mv (5 = . \ 7 = .r \ 8 = .s \ 9 = .w) // 5 = no 7=Rifiuto, 8=non so, 9= Non pertinente


* (N) Caregiver Racism
rename V45160 cgMigrIntegr
rename V45180 cgMigrAttitude
rename V45220_1 cgMigrClass
rename V45220_2 cgStudClass
gen cgMigrSchoolPerc = cgMigrClass/cgStudClass
label var cgMigrSchoolPerc "dv: Percentage of migrants in Child/Adolescent's school"
replace cgMigrSchoolPerc = cgMigrClass if cgMigrClass>=.
rename V45230 cgMigrProgram
rename V45240 cgMigrFriend
rename V45260_1 cgMigrMeetNo
rename V45260_2 cgMigrMeetWork
rename V45260_3 cgMigrMeetChurch
rename V45260_4 cgMigrMeetSport
rename V45260_5 cgMigrMeetOther
tab cgMigrFriend cgMigrMeetNo, miss
rename V45260_open cgMigrMeet_open
label var cgMigrIntegr "Schools don't help migration (caregiver)"
label var cgMigrAttitude "Caregiver is diffident of immigrants"
label var cgMigrClass "Child/Ado has immigrant classmates (caregiver)"
label var cgMigrProgram "Migrants don't slow down class curriculum (caregiver)"
label var cgMigrFriend "Caregiver has ever had migrant friends"
label var cgMigrMeetNo "Caregiver doesn't hang out with migrants"
label var cgMigrMeetWork "Caregiver hangs out with migrants at work"
label var cgMigrMeetChurch "Caregiver hangs out with migrants at curch"
label var cgMigrMeetSport "Caregiver hangs out with migrants at sports"
label var cgMigrMeetOther "Caregiver hangs out with migrants (other)"


* For Migrants only
forvalues i=1(1)4 {
gen temp_`i' = .w if V45320_`i' == .w
replace temp_`i' = 0             if  V45320_`i' == 1 // subito
replace temp_`i' = V45321_`i'    if  V45320_`i' == 2 // indica mese
replace temp_`i' = V45322_`i'*12 if  V45320_`i' == 3 // indica anno
}
rename temp_1 cgMigrTimeFit
rename temp_2 cgMigrTimeSpeak
rename temp_3 cgMigrTimeFriends
rename temp_4 cgMigrTimeSatis
label var cgMigrTimeFit "dv: Time taken to fit in (in months)"
label var cgMigrTimeSpeak "dv: Time taken to speak language (in months)"
label var cgMigrTimeFriends "dv: Time taken to find friends (in months)"
label var cgMigrTimeSatis "dv: Time taken to feel satisfied (in months)"

* Friends
rename V45340_1 cgMigrFrComp
rename V45340_2 cgMigrFrIta
rename V45340_3 cgMigrFrCity
rename V45340_4 cgMigrFrOther
foreach var of varlist cgMigrFrComp-cgMigrFrOther {
replace `var' = .w if V45340_5==1
}

label var cgMigrFrComp  "Has compatriot friends"
label var cgMigrFrIta   "Has Italian friends"
label var cgMigrFrCity  "Has friends from the City"
label var cgMigrFrOther "Has immigrant friends"
// tab V70410 if cgStudClass == 0, miss // CHECK not sure why some people say that there are zero students in the class

* (O) Caregiver Self-responded
* (O-a) Noncog -- Rotter Locus of Control Scale (NLSY79)
forvalues i=1(1)4 {
	rename V48110_`i' cgLocus`i'
	tab cgLocus`i', missing // CHECK less than 2% non-response
	quietly gen cgLocus`i'_Wmiss = (cgLocus`i'>.)
	quietly replace cgLocus`i'= . if cgLocus`i'>. //change .w missing into . missing so that SEM works better
}
factor cgLocus?
sem (X -> cgLocus?), var(X@1) iter(500) method(mlmv) latent(X)
predict cgLocusControl if e(sample), latent(X)
label var cgLocusControl "dv: Caregiver Locus of Control - factor score"

foreach var of varlist cgLocus? {
	quietly replace `var'= .w if `var'_Wmiss==1 //change back to .w missing
	quietly drop `var'_Wmiss
}

* (O-b) Risky/unhealty
foreach var of varlist V49* {
	tab `var', missing // CHECK less than 3% non-response
}
rename V49130 cgSmoke
rename V49135 cgCig
rename V49150 cgSmokeProh
rename V49180 cgDrinkNum
rename V49200 cgDrinkProh
rename V49250 cgMariaProh
* (O-c) Trust and racism
* trust - from the German SOEP
forvalues i=1(1)3 {
	rename V50210_`i' cgTrust`i'
	tab cgTrust`i', missing // CEHCK less than 1% non-response
	quietly gen cgTrust`i'_Wmiss = (cgTrust`i'>.)
	quietly replace cgTrust`i'= . if cgTrust`i'>. //change .w missing into . missing so that SEM works better
}
label var cgTrust1 "Generally cannot trust people (caregiver)" // "In generale ci si puo' fidare della gente"
label var cgTrust2 "Can trust anyone (caregiver)" // "Al giorno d'oggi non ci si puo' fidare di nessuno"
label var cgTrust3 "Shouldn't be careful with strangers (caregiver)" // "Bisogna fare attenzione quando si ha a che fare con gli estranei"

factor cgTrust?
sem (Trust -> cgTrust2 cgTrust1 cgTrust3), latent(Trust) var(Trust@1) iter(500) method(mlmv)
//predict cgTrust_factor if e(sample), latent(Trust)
//label var cgTrust_factor "dv: Caregiver trust and reciprocity - factor score"

gen temp1 = 2-cgTrust1
gen temp2 = cgTrust2-2
gen temp3 = cgTrust3-2

egen cgTrust = rowtotal(temp?), miss
label var cgTrust "dv: Caregiver trust and reciprocity - sum score"

foreach var of varlist cgTrust? {
	quietly replace `var'= .w if `var'_Wmiss==1 //change back to .w missing
	quietly drop `var'_Wmiss
}

* racism
foreach var of varlist V51110 V51200_* {
	tab `var', missing
	// CHECK less than 1% non-response (.w)
	// about 50% "I wouldn't care"
	// not asked to migrants
}
rename V51110   cgMigrTaste
rename V51200_1 cgMigrAfri
rename V51200_2 cgMigrArab
rename V51200_3 cgMigrAsia
rename V51200_4 cgMigrEngl
rename V51200_5 cgMigrSAme
rename V51200_6 cgMigrSwed
label var cgMigrTaste "Caregiver likes migrants"

rename V51320   cgMigrCity
rename V51340   cgMigrIntegCity
rename V51350   cgMigrIntegIt
label var cgMigrCity "City hostile to migrants? (1=friendly,4=hostile)"
label var cgMigrIntegCity "Is it hard to integrate as a migrant in this City? (1-to-3)"
label var cgMigrIntegIt   "Is it hard to integrate as a migrant in Italy? (1-to-3)"

gen cgMigrIntegCityHarder = cgMigrIntegCity - cgMigrIntegIt 
label var cgMigrIntegCityHarder "dv: Harder to integrate in city than in italy (2=hareder, -2=easier)" 


* (O-d) Income
rename V46110 cgWageReport
rename V46110_open cgWageReport_open
tab cgWageReport_open // CHECK manually the answers
tab cgWageReport, missing // CHECK missing (.w) 45% of missing
tab cgPA cgWageReport, missing

rename V46111 cgWageHour
rename V46112 cgWageDay
rename V46113 cgWageWeek
rename V46115 cgWageMonth
rename V46116 cgWageYear
rename V46118 cgWageOther
replace cgWageMonth = 1500 if cgWageReport_open=="1500 EURO AL MESE"

gen     cgWage = cgWageMonth
replace cgWage = cgWageYear/12 if cgWage >=. // [=] or times 13 (tredicesima?)
	// Sources for hours and weeks worked 
	// OECD2011: 1774 hrs/year http://stats.oecd.org/Index.aspx?DatasetCode=ANHRS 
	// see also www.oecd.org/employment/outlook and http://www.nber.org/chapters/c0073.pdf
replace cgWage = cgWageWeek*4.35 if cgWage >=.
replace cgWage = cgWageDay*20    if cgWage >=. // or times 30 (every day is working)
replace cgWage = cgWageHour*167  if cgWage >=. // average working hours in a month -- or multiply by hours worked?
label var cgWage "dv: Monthly wage of the caregiver"
replace cgWage = .w if cgWageReport == .w
tabstat cgWage, by(cgWageReport) stat(mean median min max)
mdesc cgWage // CHECK almost 60% missing in total

gen temp = cgWageHour*cgHrsTot*4.35 //using the hours worked
gen diff = (cgWage - temp)
sum diff // using fixed-hours tend to overestimate the monthly wage
drop temp diff

rename V46120 cgIncomeCat
rename V46130_1 cgPension
rename V46130_2 cgBenefit
rename V46130_3 cgScholarship
rename V46130_4 cgNoneTranfer
tab cgIncomeCat, missing // CHECK 32% non response

/*----------* Manual change: 
Two main sources of income were reported, the respondent's wage and brackets of family income. 
The first income category is 1 to 5,000 euros; we would expect almost nobody to report such a low yearly family income, 
yet there are quite a few. Consulting DOXA and the interviewers, the most likely problem is that respondents 
used the same time-category that was used to answer the previous question on wage (e.g. monthly). 
Therefore, when a precise wage was reported, the implied yearly amount of that wage was cross-checked 
with the reported income and the income variable was appropriately recoded to take this into account. 
*/
gen temp12 = cgWage*12 // yearly wage
sum temp12
label list V46120
gen     cgIncomeCat_wage = .w if (cgWage == .w )
replace cgIncomeCat_wage = 1 if                    temp12 <= 5000    // yearly wage is lower than 5000
replace cgIncomeCat_wage = 2 if (temp12 > 5000   & temp12 <= 10000  )
replace cgIncomeCat_wage = 3 if (temp12 > 10000  & temp12 <= 25000  )
replace cgIncomeCat_wage = 4 if (temp12 > 25000  & temp12 <= 50000  )
replace cgIncomeCat_wage = 5 if (temp12 > 50000  & temp12 <= 100000 )
replace cgIncomeCat_wage = 6 if (temp12 > 100000 & temp12 <= 250000 )
replace cgIncomeCat_wage = 7 if (temp12 > 250000 ) & temp12<.
tabstat temp12, by(cgIncomeCat_wage) statistics(mean min max)
label var cgIncomeCat_wage "dv: Family Income categories, using reported wage"

tab cgIncomeCat*

egen cgIncomeCat_manual = rowmax(cgIncomeCat_wage cgIncomeCat)
label var cgIncomeCat_manual "dv: Family Income categories, using the max of reported wage and income categories"

label values cgIncomeCat* V46120
drop temp*

* (P) Caregiver IQ
sum intnr V42401_* // CHECK there are no missing
gen cgIQ1 = (V42401_1 == 8) if V42401_1<.
gen cgIQ2 = (V42401_2 == 4) if V42401_2<.
gen cgIQ3 = (V42401_3 == 5) if V42401_3<.
gen cgIQ4 = (V42401_4 == 1) if V42401_4<.
gen cgIQ5 = (V42401_5 == 2) if V42401_5<.
gen cgIQ6 = (V42401_6 == 5) if V42401_6<.
gen cgIQ7 = (V42401_7 == 6) if V42401_7<.
gen cgIQ8 = (V42401_8 == 3) if V42401_8<.
gen cgIQ9 = (V42401_9 == 7) if V42401_9<.
gen cgIQ10 = (V42401_10 == 8) if V42401_10<.
gen cgIQ11 = (V42401_11 == 7) if V42401_11<.
gen cgIQ12 = (V42401_12 == 6) if V42401_12<.

* answers to questions
gen cgIQ1_ans = V42401_1
gen cgIQ2_ans = V42401_2
gen cgIQ3_ans = V42401_3
gen cgIQ4_ans = V42401_4
gen cgIQ5_ans = V42401_5
gen cgIQ6_ans = V42401_6
gen cgIQ7_ans = V42401_7
gen cgIQ8_ans = V42401_8
gen cgIQ9_ans = V42401_9
gen cgIQ10_ans = V42401_10
gen cgIQ11_ans = V42401_11
gen cgIQ12_ans = V42401_12

factor cgIQ*
sem (IQ -> cgIQ10 cgIQ12 cgIQ11 cgIQ?), iter(500) latent(IQ) method(mlmv) var(IQ@1)
predict cgIQ_factor if e(sample), latent(IQ)
label var cgIQ_factor "dv: Caregiver mental ability. Raven matrices - factor score"

egen cgIQ_score = rowtotal(cgIQ? cgIQ10 cgIQ12 cgIQ11)
replace cgIQ_score = cgIQ_score/12
label var cgIQ_score "dv: Caregiver mental ability. Raven matrices - % of correct answers"

gen cgIQtime = V85005 - V85003
* format cgIQtime %tc
replace cgIQtime = cgIQtime/60000 
label var cgIQtime "dv: Time spent on IQ Raven Test (minutes)"
tabstat cgIQtime, by(CAPI)
xi: reg cgIQ_factor i.CAPI*cgIQtime, robust
drop _I*

*-*-*-*-*-*-*-*-*-*
* (A-F) Child Variables
* (A) Child School
sum intnr V60* //CHECK very few missing
rename V60000_1 likeSchool_child
rename V60000_2 likeRead
rename V60000_3 likeMath_child
rename V60000_4 likeGym
rename V60090_1 goodBoySchool
rename V60090_2 bullied
rename V60090_3 alienated
rename V60160_1 doGrowUp
replace doGrowUp = .s if V60160_2==1
rename V60160_open doGrowUp_open

* (B) Child Social Capital
rename V60310_1 likeTV
rename V60310_2 likeDraw
rename V60310_3 likeSport
*friendship
rename V60380 bestFriend
rename V60370 FriendsGender

label list  V60370 
tab FriendsGender Male, miss
gen ciccio = .
label define FriendsGender 1 "Same sex" 0 "Mix" -1 "Opposite sex" .w "NON INDICA"
replace ciccio = 1  if (FriendsGender == 1 & Male == 1) | (FriendsGender == 2 & Male == 0) 
replace ciccio = 0  if FriendsGender == 3 
replace ciccio = -1 if (FriendsGender == 1 & Male == 0) | (FriendsGender == 2 & Male == 1)
replace FriendsGender = ciccio
drop ciccio
label values FriendsGender FriendsGender 
tab FriendsGender Male, miss // CHECK some missing here
*family investment
rename V60394 funFamily
*reaction to worry
rename V60470_1 worryMyself
rename V60470_2 worryFriend
rename V60470_3 worryHome
rename V60470_4 worryTeacher
rename V60470_O1 worry
*overall satisfaction
rename V65010_1 faceMe
rename V65010_2 faceFamily
rename V65010_3 faceSchool
rename V65010_4 faceGeneral
*healthy behavior
rename V66040 brushTeeth

* (C) Child Time Use
rename V66120_1 TimeFriends
rename V66120_2 TimeSib
rename V66120_3 TimeMom
rename V66120_4 TimeDad
rename V66120_5 TimeGran

* (D) Child reciprocity
rename V60391 lendFriend
rename V60392 favorReturn
rename V60393 revengeReturn
rename V66310 candyGame

replace candyGame = candyGame-2
label var candyGame "How many candies are you willing to give to a classmate?"
label define candy -1 "keep all" 0 "share equally" 1 "give all"
label values candyGame candy
tab candyGame

* (E) Child Racism
rename V66410_1 MigrFriendFig
rename V66410_2 MigrNiceFig
rename V66410_3 MigrBadFig
rename V66410_4 MigrSimilarFig

* (F) Child IQ
sum intnr V52401_* //CHECK there are no missing
gen IQ1 = (V52401_1 == 5) if V52401_1<.
gen IQ2 = (V52401_2 == 2) if V52401_2<.
gen IQ3 = (V52401_3 == 3) if V52401_3<.
gen IQ4 = (V52401_4 == 3) if V52401_4<.
gen IQ5 = (V52401_5 == 3) if V52401_5<.
gen IQ6 = (V52401_6 == 5) if V52401_6<.
gen IQ7 = (V52401_7 == 5) if V52401_7<.
gen IQ8 = (V52401_8 == 6) if V52401_8<.
gen IQ9 = (V52401_9 == 1) if V52401_9<.
gen IQ10 = (V52401_10 == 4) if V52401_10<.
gen IQ11 = (V52401_11 == 3) if V52401_11<.
gen IQ12 = (V52401_12 == 2) if V52401_12<.
gen IQ13 = (V52401_13 == 6) if V52401_13<.
gen IQ14 = (V52401_14 == 2) if V52401_14<.
gen IQ15 = (V52401_15 == 3) if V52401_15<.
gen IQ16 = (V52401_16 == 6) if V52401_16<.
gen IQ17 = (V52401_17 == 3) if V52401_17<.
gen IQ18 = (V52401_18 == 5) if V52401_18<.

* answers to questions
gen IQ1_ans = V52401_1
gen IQ2_ans = V52401_2
gen IQ3_ans = V52401_3
gen IQ4_ans = V52401_4
gen IQ5_ans = V52401_5
gen IQ6_ans = V52401_6
gen IQ7_ans = V52401_7
gen IQ8_ans = V52401_8
gen IQ9_ans = V52401_9
gen IQ10_ans = V52401_10
gen IQ11_ans = V52401_11
gen IQ12_ans = V52401_12
gen IQ13_ans = V52401_13
gen IQ14_ans = V52401_14
gen IQ15_ans = V52401_15
gen IQ16_ans = V52401_16
gen IQ17_ans = V52401_17
gen IQ18_ans = V52401_18

factor IQ*
sem (IQ -> IQ10 IQ12 IQ11 IQ13 IQ14 IQ15 IQ16 IQ17 IQ18 IQ?), latent(IQ) method(mlmv) var(IQ@1) iter(500)
predict IQ_factor if e(sample), latent(IQ)
label var IQ_factor "dv: Respondent mental ability. Raven matrices - factor score"

egen IQ_score = rowtotal(IQ? IQ??)
replace IQ_score = IQ_score / 18
label var IQ_score "dv: Respondent mental ability. Raven matrices - % of correct answers"

gen IQtime = V85008 - V85007
* format IQtime %tc
replace IQtime = IQtime/60000 
label var IQtime "dv: Time spent on IQ Raven Test (minutes)"
tabstat IQtime, by(CAPI)
reg IQ_factor CAPI IQtime, robust

*-*-*-*-* (Interviewer) 
rename V999120 incentive
tab incentive City, miss column

rename V100100 email
rename V100141 phone
rename V52020 cgSessions
rename V52030 cgHelp
rename V52110 cgQuestion   // note this is without the "s"
rename V57111_1 cgQuestionsHome
rename V57111_2 cgQuestionsPolitic
rename V57111_3 cgQuestionsIncome
rename V57111_4 cgQuestionsDrug
rename V57111_5 cgQuestionsRisk
rename V57111_6 cgQuestionsMigration
rename V57111_7 cgQuestionsOther
foreach var of varlist cgQuestions* {
	replace `var' = .w if V52121_8 == 1
	tab `var', miss
	// most are question about politics and income
}
tab cgQuestion , missing // CHECK never = 81%
egen cgQuestionsNum = rowtotal(cgQuestions*), missing
label var cgQuestionsNum "dv: Number of items where the caregiver asked clarifications"
tab cgQuestionsNum cgQuestion 

rename V57111_open cgQuestionsHome_open

* the person was relectant to respond to:
rename V52120 cgReluct
rename V52121_1 cgReluctantHome
rename V52121_2 cgReluctantPolitic
rename V52121_3 cgReluctantIncome
rename V52121_4 cgReluctantDrug
rename V52121_5 cgReluctantRisk
rename V52121_6 cgReluctantMigration
rename V52121_7 cgReluctantOther
foreach var of varlist cgReluctant* {
	replace `var' = .w if V52121_8 == 1
	tab `var', miss
	// most are reluctant to answer to politics and income
}

tab cgReluct , missing // never = 71%
egen cgReluctantNum = rowtotal(cgReluctant*), missing
label var cgReluctantNum "dv: Number of items where the caregiver was reluctant to respond"
tab cgReluctantNum cgReluct 

rename V52121_open cgReluctantOther_open

rename V52130 cgBestReply
rename V52140 cgUnderstood
rename V52150 cgInterfere
rename V52160_1 cgInterferePrtn
rename V52160_2 cgInterfereChild
rename V52160_3 cgInterfereParent
rename V52160_4 cgInterfereRelative
rename V52160_5 cgInterfereOther
rename V52170 cgLangIntw
rename V52170_open cgLangIntw_open
rename V52180_1 cgComment
rename V52180_open cgComment_open
rename V52190 cgItaKnow
rename V52200 cgTranslation
rename V52210 cgSelfCompl
rename V52220_open cgSelfCompl_open

* Questions to interviewer about Child/Adolescent Responses
rename V66510 Question
rename V66511_open Question_open
rename V66520 Reluct
rename V66521_open Reluct_open
rename V66530 BestReply
rename V66540 Understood
rename V66541_open Understood_open
rename V66550 Interfere
rename V66560_1 InterfereMom
rename V66560_2 InterfereDad
rename V66560_3 InterfereBigsib
rename V66560_4 InterfereSmallsib
rename V66560_5 InterfereRelative
rename V66560_6 InterfereOther
rename V66570 LangIntw
rename V66570_open LangIntw_open
rename V66580_1 Comment
rename V66580_open Comment_open
rename V66590 ItaKnow
rename V66600 Translation
rename V66020 Sessions
rename V66030 Help

* (drop) useless variables
tab CAMPIONE Cohort, miss
drop CAMPIONE
   // self; date of bith; state of birth; city of birth; 
drop V20070_1 V20080_* V90200_* V30051 V20100_*
//drop dif_Municipality
tab V100042 City
drop V100042
   // Education for immigrants
drop V20310_*
   // remember the name or address of the asilo/materna
drop V530?0_* V53102_* V53101_* V653041_? V6530?0 V6300101_? V6310?
   // Name and Address
drop V*NOME V*INDIRIZZO //the last ones *_open are redundant, the same as V63101_INDIRIZZO etc..
   // mom started working when the Child/Adolescent was <age> old
drop V53220 V53221 V53222 
   // consistency checks: working more than 60 hours; end mom questionnaire
drop V33192 V54292 V201234
   // refusal, don't know, not pertinet
drop V56200_1_* V56200_2_* V57111_8 V52121_8 V37220_5 V60160_2 V45340_5
   // IQ and IQ time
drop V52401_* V42401_* V85003 V85005 V85007 V85008 
   // validity of interviews
drop privacy V100000 V52180_2 V52220_1 V52220_2 privacy V66580_2 V10010 V10020 DATA_INT //V12 V1914 
//rename V1914 intnr2 
//label var intnr2 "ID name - progressivo"
egen flagProgressivo = diff(IDprogressivo PROGRESSIVO) if PROGRESSIVO<.
tab flagProgressivo 
drop flagProgressivo PROGRESSIVO // CHECK that flag is zero
   // times and dates of PAPI
drop V133000* 
   // variables for migrants
drop V4532?_* 
*des V*

* (.) *-*-* Missing values for each part of the Questionnaire *-*-*
global Family		famSize childrenSib* children0_18 Male mom noMom dad noDad Gender* momGender dadGender cgGender  ///
			hhead* house* lang* cgNationality cgNationality_open yrItaly yrCity age* livedAway *Migrant ///
			Migrant2-Migrant10 *Relation* *BornCity* *BornProvince* *Birthday* yob* Age* momAge dadAge ???AgeBirth* ///
			cgAge *BirthState* *BornIT* *ITNation* *Status* *PA* *MaxEdu* student
global childSchool	asilo* materna* care* noParticipation parentParticipation momWorking06 momWorkingAge difficulties* cgStudClass elementary*
global cgSchool		cgMaxEdu2-cgMaternaLike cgImmAsilo cgImmMaterna
global cgWork 		cgPA cgSES_open hhPA hhSES_open cgHrs* cgSES-hhYrPension
global cgFamily 	cgYrMarry childrenSib* childrenTot
global cgGrandpa	grandDist grandCare
global cgInvest 	childinv* childinv*_open dist*
global childSDQ		childSDQ*
global cgHealth 	cgHealth-birthpremature lowbirthweight cg*BMI* child*BMI* cgSnack_open childSnack_open childTotal_diag child_diag_open
global cgSocial 	cgFriends-childRelig cgRelig
global cgTimeUse 	cgTimePrtn-cgChildWork cgStressSource_open
global cgMigr 		cgMigr*
global cgNoncog 	cgLocus*
global cgRisk 		cgSmoke-cgMariaProh
global cgTrust 		cgTrust*
global cgIncome 	cgWageReport_open cgWageReport-cgNoneTranfer cgWage cgIncomeCat*
global cgIQ 		cgIQ*

global School 		likeSchool-doGrowUp childSuspended doGrowUp_open
global Social 		likeTV-brushTeeth
global TimeUse 		Time*
global Reciprocity	candyGame
global Migr 		Migr*
global IQ 		IQ*

order intnr Cohort City CAPI $Family $childSchool $cgSchool $cgWork $cgFamily $cgGrandpa $cgInvest $childSDQ $cgHealth $cgSocial $cgTimeUse $cgMigr $cgNoncog $cgRisk $cgTrust $cgIncome $cgIQ ///
                             $School $Social $TimeUse $Reciprocity $Migr $IQ flag*

foreach section in Family childSchool cgSchool cgWork cgFamily cgGrandpa cgInvest childSDQ cgHealth cgSocial cgTimeUse cgMigr cgNoncog cgRisk cgTrust cgIncome cgIQ ///
                   School Social TimeUse Reciprocity Migr IQ {
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

global INR_Family	INR_famSize INR_childrenSib* INR_children0_18 INR_Male INR_mom INR_noMom INR_dad INR_noDad INR_Gender* INR_momGender INR_dadGender INR_cgGender ///
			INR_hhead* INR_house* INR_lang* INR_cgNationality INR_cgNationality_open INR_yrItaly INR_yrCity INR_age* INR_livedAway INR_*Migrant ///
			INR_Migrant2-INR_Migrant10 INR_*Relation* INR_*BornCity* INR_*BornProvince* INR_*Birthday* INR_yob* INR_Age* INR_momAge INR_momAgeBirth INR_dadAge ///
			INR_cgAge INR_*BirthState* INR_*BornIT* INR_*ITNation* INR_*Status* INR_*PA* INR_*MaxEdu* INR_student
global INR_childSchool	INR_asilo* INR_materna* INR_care* INR_noParticipation INR_parentParticipation INR_momWorking06 INR_momWorkingAge INR_difficulties* INR_cgStudClass INR_elementary*
global INR_cgSchool	INR_cgMaxEdu2-INR_cgMaternaLike INR_cgImmAsilo INR_cgImmMaterna
global INR_cgWork 	INR_cgPA INR_cgSES_open INR_hhPA INR_hhSES_open INR_cgHrs* INR_cgSES-INR_hhYrPension
global INR_cgFamily 	INR_cgYrMarry INR_childrenSib* INR_childrenTot
global INR_cgGrandpa	INR_grandDist INR_grandCare
global INR_cgInvest 	INR_childinv* INR_childinv*_open INR_dist*
global INR_childSDQ	INR_childSDQ*
global INR_cgHealth 	INR_cgHealth-INR_birthpremature INR_lowbirthweight INR_cg*BMI* INR_child*BMI* INR_cgSnack_open INR_childSnack_open INR_childTotal_diag INR_child_diag_open
global INR_cgSocial 	INR_cgFriends-INR_childRelig INR_cgRelig
global INR_cgTimeUse 	INR_cgTimePrtn-INR_cgChildWork INR_cgStressSource_open
global INR_cgMigr 	INR_cgMigr*
global INR_cgNoncog 	INR_cgLocus*
global INR_cgRisk 	INR_cgSmoke-INR_cgMariaProh
global INR_cgTrust 	INR_cgTrust*
global INR_cgIncome 	INR_cgWageReport_open INR_cgWageReport-INR_cgNoneTranfer INR_cgWage INR_cgIncomeCat*
global INR_cgIQ 	INR_cgIQ*
global INR_School 	INR_likeSchool-INR_doGrowUp INR_childSuspended INR_doGrowUp_open
global INR_Social 	INR_likeTV-INR_brushTeeth
global INR_TimeUse 	INR_Time*
global INR_Reciprocity 	INR_candyGame
global INR_Migr 	INR_Migr*
global INR_IQ 		INR_IQ*

foreach section in INR_Family INR_childSchool INR_cgSchool INR_cgWork INR_cgFamily INR_cgGrandpa INR_cgInvest INR_childSDQ INR_cgHealth INR_cgSocial INR_cgTimeUse INR_cgMigr INR_cgNoncog ///
					INR_cgRisk INR_cgTrust INR_cgIncome INR_cgIQ INR_School INR_Social INR_TimeUse INR_Reciprocity INR_Migr INR_IQ {
egen avg`section'    = rowmean($`section')
label var avg`section' "dv: Percentage of item-non-response in section `section'"
}
egen avgINR = rowmean(INR*)
sum avgINR*

*-*-8 For the codebook
save temp_child, replace
keep INR*
save tempINR_child, replace

describe, replace clear
save tempINR_child_des, replace

use tempINR_child
logout, replace save(tempINR_child_sum) dta: sum

use tempINR_child_sum, clear
rename v1 Variable
rename v2 Obs
rename v3 Mean
rename v4 StdDev
rename v5 Min
rename v6 Max
drop if inlist(_n,1)
gen position = _n

merge 1:1 position using tempINR_child_des
drop type-_merge
replace name = subinstr(name,"INR_","",10)
destring _all, replace
foreach var of varlist Variable-position{
	rename `var' INR_`var' 
}

save tempINR_child, replace
rm tempINR_child_des.dta
rm tempINR_child_sum.dta
rm tempINR_child_sum.txt

use temp_child.dta
rm temp_child.dta
*-*-8

drop INR* // [=] might want to keep it, but doubles number of variables

* (flag) variable [=]
// Mismatch between SPSS data and school addresses --> see inline code
// Age of Caregiver
// replace flag = 1 if  (cgAge<30 | cgAge>70) // & flag >=. replace flag = 100+flag if  (cgAge<30 | cgAge>70) & flag<.
// Arrival in Italy/city --> see inline code
// Migrant
gen flagMigrant = 0
replace flagMigrant = 1 if cgMigrant == 0 & cgNationality!=121 // Not migrant, but nationality is non-italian
replace flagMigrant = 2 if cgMigrant == 1 & cgNationality==121 // Migrant, but nationality is italian
replace flagMigrant = 3 if cgMigrant != childMigrant // Mother is migrant but child is not 
label var flagMigrant "dv: Different information regarding nationality/place of birth"
// Not born in Italy: it should be only for Parma, since we did not have information on the place of birth of the child but only the one of the guardian
tab BornIT City
gen flagBorn = (BornIT == 0) // & City!=2 // 2=parma
label var flagBorn "dv: Child is not born in Italy"

order flag*, last

compress
save ReggioChild.dta, replace
capture log close

* For the codebook
use ReggioChild.dta, clear
logout, replace save(temp_child_sum) dta: sum

use temp_child_sum, clear
rename v1 Variable
rename v2 Obs
rename v3 Mean
rename v4 StdDev
rename v5 Min
rename v6 Max
drop if inlist(_n,1)
gen position = _n
destring _all, replace
save temp_child_sum, replace

use ReggioChild.dta, clear
describe, replace clear

replace varlab= subinstr(varlab,"Ã¨","e'",.)
replace varlab= subinstr(varlab,"Ã©","e'",.)
replace varlab= subinstr(varlab,"é","e'",.)
replace varlab= subinstr(varlab,"Ãˆ","E'",.)
replace varlab= subinstr(varlab,"Ã‰","E'",.)
replace varlab= subinstr(varlab,"Ã¬","i'",.)
replace varlab= subinstr(varlab,"Ã¹","u'",.)
replace varlab= subinstr(varlab,"Ù","U'",.)
replace varlab= subinstr(varlab,"Ã²","o'",.)
replace varlab= subinstr(varlab,"Ã€","A'",.)
replace varlab= subinstr(varlab,"â€™","'",.)
replace varlab= subinstr(varlab,"â€","'",.)
replace varlab= subinstr(varlab,"â","'",.)
replace varlab= subinstr(varlab,"Ã","a'",.)
replace varlab= subinstr(varlab,"à","a'",.)
* charlist(varlab) //check there are no weird characters

merge 1:1 position using temp_child_sum
drop _merge

save codebook_child, replace
rm temp_child_sum.dta
rm temp_child_sum.txt

merge 1:1 name using tempINR_child
drop _merge
sort position
save codebook_child, replace
outsheet using "temp_codebookChild", replace

// rm temp_child.dta
rm tempINR_child.dta
rm codebook_child.dta

// tabmat famSize Male Age cgAge cgmStatus cgMaxEdu noMom noDad
*

capture rm temp_child.dta
capture rm tempINR_child.dta
capture rm temp_codebookChild.out
