* ---------------------------------------------------------------------------- *
* Analyzing the Reggio Children Evaluation Survey - Linear Probability Model (Pooled Ver.)
* Authors: Jessica Yu Kyung Koh
* Created: 13 June 2016
* Edited:  13 June 2016
* ---------------------------------------------------------------------------- *

capture log close
clear all
set more off
set maxvar 32000

* ---------------------------------------------------------------------------- *
* Set directory
global klmReggio	: 	env klmReggio		
global data_reggio	: 	env data_reggio

* Prepare the data for the analysis, creating variables and locals
include ${klmReggio}/Analysis/prepare-data.do

cd ${klmReggio}/Analysis/Output/

* ---------------------------------------------------------------------------- *
* Migrant variables

** Caregiver's nationality and religion 
tab cgNationality if cgNationality != 121
tabout cgNationality if cgNationality != 121 using "${git_reggio}/Output/check_variables/cgNationality_new.tex", ///
					replace style(tex) format(0)

*** Define Religion label
label define religion_lab  0 "None" 1 "Catholic" 2 "Protestant" 3 "Orthodox" 4 "Christian" ///
							5 "Jewish" 6 "Islamica" 7 "Eastern Religion" 8 "Other Religion"
label values cgReligType religion_lab

*** Reggio					
tab cgNationality cgReligType if (cgNationality != 121) & (City == 1) & (Cohort == 2)				
tabout cgNationality cgReligType if (cgNationality != 121) & (City == 1) & (Cohort == 2) using "${git_reggio}/Output/check_variables/cgNationality_religion_reggio_new.tex", ///
					replace style(tex) format(0)
*** Parma
tab cgNationality cgReligType if (cgNationality != 121) & (City == 2) & (Cohort == 2)				
tabout cgNationality cgReligType if (cgNationality != 121) & (City == 2) & (Cohort == 2) using "${git_reggio}/Output/check_variables/cgNationality_religion_parma_new.tex", ///
					replace style(tex) format(0)
*** Padova
tab cgNationality cgReligType if (cgNationality != 121) & (City == 3) & (Cohort == 2)				
tabout cgNationality cgReligType if (cgNationality != 121) & (City == 3) & (Cohort == 2) using "${git_reggio}/Output/check_variables/cgNationality_religion_padova_new.tex", ///
					replace style(tex) format(0)


** Caregiver's nationality and income
*** Reggio					
tab cgNationality cgIncomeCat if (cgNationality != 121) & (City == 1) & (Cohort == 2)				
tabout cgNationality cgIncomeCat if (cgNationality != 121) & (City == 1) & (Cohort == 2) using "${git_reggio}/Output/check_variables/cgNationality_income_reggio_new.tex", ///
					replace style(tex) format(0)
*** Parma
tab cgNationality cgIncomeCat if (cgNationality != 121) & (City == 2) & (Cohort == 2)				
tabout cgNationality cgIncomeCat if (cgNationality != 121) & (City == 2) & (Cohort == 2) using "${git_reggio}/Output/check_variables/cgNationality_income_parma_new.tex", ///
					replace style(tex) format(0)
*** Padova
tab cgNationality cgReligType if (cgNationality != 121) & (City == 3) & (Cohort == 2)				
tabout cgNationality cgIncomeCat if (cgNationality != 121) & (City == 3) & (Cohort == 2) using "${git_reggio}/Output/check_variables/cgNationality_income_padova_new.tex", ///
					replace style(tex) format(0)
