cd ${input_data}
import excel using "Size_household_1971_2011.xlsx", clear sheet("Sheet2") cellrange(A13:G17) firstr 

xpose, clear 
drop if v2 == .

gen N = _n
replace v1 = 1971 if N == 1
replace v1 = 1981 if N == 2
replace v1 = 1991 if N == 3
replace v1 = 2001 if N == 4
replace v1 = 2011 if N == 5

rename v1 year
rename v2 Padova
rename v3 Parma
rename v4 Reggio
drop N

gen Name 		= "Size of Household" 
gen Variable 	= "avg"
gen status		= "Rented"

lab var Name 				"Category"
lab var year 				"Year"
lab var Variable 			"Statistic"
lab var Reggio				"Reggio Emilia"
lab var Padova				"Padova"
lab var Parma				"Parma"

order Name Variable year Parma Padova Reggio
