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
global data			= "${klmReggio}/data_survey/data"


cd $data
use Reggio_reassigned, clear

drop if maternaType == .s
drop if maternaType == .u

table Cohort asiloType City, c(freq)
dd
eststo clear
bysort City asiloType: eststo: estpost tabstat intnr, by(Cohort) stat(count)

cd "$output"
esttab using sample.tex, 								///
	booktabs 											///
	align(c) 											///
    cells(count) 										///
	`label' noobs 										///
	replace 											///
	collabels(none)  									///
	nonumbers 											///
	mlabels("None" "Muni." "State" "Relig." "Priv." "Municipal-Affiliated" "Other" "None" "Muni." "State" "Relig." "Priv." "Municipal-Affiliated" "Other" "None" "Muni." "State" "Relig." "Priv." "Municipal-Affiliated" "Other", lhs(Cohort)) ///
    mgroups("Reggio Emilia" "Parma" "Padova", pattern(0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1))
