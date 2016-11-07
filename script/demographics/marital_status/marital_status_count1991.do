// 1991
cd ${input_data}
import excel using "marital_status_1971_2011.xlsx", clear sheet("1991") cellrange(A4:D16) firstr

gen source 		= "Marital Status"
gen year 		= 1991
gen Variable 	= "count"

rename ReggionellEmilia 		Reggio
rename capoluogo_di_provincia 	Name

replace Name = "Never Married" 		if Name == "T5_01__CELIBI" 
replace Name = "Never Married" 		if Name == "T5_01__NUBILI"
replace Name = "Married"			if Name == "T5_01__CON_TOT_M"
replace Name = "Married"			if Name == "T5_01__CON_TOT_F" 
replace Name = "Divorced"			if Name == "T5_01__DIVOR_M" 
replace Name = "Divorced"			if Name == "T5_01__DIVOR_F" 
replace Name = "Separated"			if Name == "T5_01__SEP_FATT_M"
replace Name = "Separated"			if Name == "T5_01__SEP_FATT_F"
replace Name = "Separated"			if Name == "T5_01__SEP_LEG_M"
replace Name = "Separated"			if Name == "T5_01__SEP_LEG_F"	
replace Name = "Widowed"			if Name == "T5_01__VEDOVI"
replace Name = "Widowed"			if Name == "T5_01__VEDOVE"

gen N = _n
gen female = mod(N,2)

foreach c in Padova Parma Reggio {
	sort Name 
	by Name : egen tot`c' = sum(`c')
	
	drop `c'
	rename tot`c' `c'
}


drop if female == 0
drop N female
sort Name
by Name: gen N = _n
drop if N == 2
drop N

lab var Name 		"Category"
lab var year		"Year"
lab var Variable	"Statistic"
lab var source		"Marital status"
lab var Reggio		"Reggio Emilia"
lab var Padova		"Padova"
lab var Parma		"Parma"

order Name year Variable source Parma Padova Reggio

tempfile mstatus1991
save 	`mstatus1991'
