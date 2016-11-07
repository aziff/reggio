cd ${input_data}
import excel using "rented_properties_1971_2011.xlsx", clear sheet("2011") cellrange(A7:E10) firstr 

drop B
xpose, clear 

drop if v1 == .
rename v1	Padova
rename v2	Parma
rename v3	Reggio

gen N 			= _n
gen Name 		= ""
replace Name 	= "Owned" 	if N == 1
replace Name	= "Rented" 	if N == 2
replace Name 	= "Other"	if N == 3
drop N

gen source		= "Rented Properties" 
gen year 		= 2011
gen Variable 	= "count"

lab var Name 				"Category"
lab var year 				"Year"
lab var Variable 			"Statistic"
lab var source 				"Rental status"
lab var Reggio				"Reggio Emilia"
lab var Padova				"Padova"
lab var Parma				"Parma"

order Name source Variable year Parma Padova Reggio

tempfile rented2011
save 	`rented2011'
