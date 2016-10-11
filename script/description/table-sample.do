/*
Project:		Reggio Evaluation
Author:			Anna Ziff
Date:			10/10/16
File:			Make table with details of sample size
*/

// macros
global klmReggio 	: env klmReggio
global git_reggio 	: env git_reggio
global output		= "${git_reggio}/writeup/draft/output"
global data			= "${klmReggio}/SURVEY_DATA_COLLECTION/data"


cd $data
use Reggio, clear


table Cohort maternaType City, c(freq)

eststo clear
bysort City maternaType: eststo: estpost tabstat intnr, by(Cohort) stat(count)

cd $output
esttab using sample.tex, 								///
	booktabs 											///
	align(c) 											///
    cells(count) 										///
	`label' noobs 										///
	replace 											///
	collabels(none)  									///
	nonumbers 											///
	mlabels("None" "Muni." "State" "Relig." "Priv." "None" "Muni." "State" "Relig." "Priv." "None" "Muni." "State" "Relig." "Priv.", lhs(Cohort)) ///
    mgroups("Reggio Emilia" "Parma" "Padova", pattern(0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1))
