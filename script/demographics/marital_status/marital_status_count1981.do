// 1981
cd ${input_data}
import excel using "marital_status_1971_2011.xlsx", clear sheet("1981") cellrange(A2:D12) firstr

gen source 		= "Marital Status"
gen year 		= 1981
gen Variable 	= "count"

rename ReggionellEmilia 		Reggio
rename capoluogo_di_provincia 	Name

replace Name = "Never Married" 		if Name == "T_03__NUBILI" 
replace Name = "Never Married" 		if Name == "T_03__CELIBI"
replace Name = "Married"			if Name == "T_03__CONIUGATE"
replace Name = "Married"			if Name == "T_03__CONIUGATI" 
replace Name = "Divorced"			if Name == "T_03__DIVORZIATE" 
replace Name = "Divorced"			if Name == "T_03__DIVORZIATI" 
replace Name = "Separated"			if Name == "T_03__SEPARATE_LEG"
replace Name = "Separated"			if Name == "T_03__SEPARATI_LEG"
replace Name = "Widowed"			if Name == "T_03__VEDOVE"
replace Name = "Widowed"			if Name == "T_03__VEDOVI"

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

lab var Name 		"Category"
lab var year		"Year"
lab var Variable	"Statistic"
lab var Name		"Marital Status"
lab var Reggio		"Reggio Emilia"
lab var Padova		"Padova"
lab var Parma		"Parma"

order Name year Variable Name Parma Padova Reggio

tempfile mstatus1981
save `mstatus1981'
