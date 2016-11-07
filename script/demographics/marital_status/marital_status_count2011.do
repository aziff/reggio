// 2011
cd ${input_data}
import excel using "marital_status_1971_2011.xlsx", clear sheet("2011") cellrange(O6:U13) firstr

gen N = _n
drop if N < 5

foreach v in married legallyseparated divorced defactoseparated nevermarried widowed totalpopulation {
	destring(`v'), replace
}

xpose, clear

rename v1 Padova
rename v2 Parma
rename v3 Reggio
drop if Padova == 5

gen N 		= _n
gen Name 	= ""

replace Name = "Married" 			if N == 1
replace Name = "Separated" 			if N == 2
replace Name = "Divorced" 			if N == 3
replace Name = "Separated" 			if N == 4
replace Name = "Never married" 		if N == 5
replace Name = "Widowed" 			if N == 6
drop 								if N == 7

foreach c in Padova Parma Reggio {
	sort Name
	by Name : egen tot`c' = sum(`c')
	
	drop `c'
	rename tot`c' `c'
}

drop N
sort Name
by Name: gen N = _n
drop if N == 2
drop N

gen source 		= "Marital Status"
gen year 		= 2011
gen Variable 	= "count"

lab var Name 		"Category"
lab var year		"Year"
lab var Variable	"Statistic"
lab var Reggio		"Reggio Emilia"
lab var Padova		"Padova"
lab var Parma		"Parma"

order Name year Variable source Parma Padova Reggio

tempfile mstatus2011
save 	`mstatus2011'

