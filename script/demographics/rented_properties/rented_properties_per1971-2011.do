cd ${input_data}
import excel using "rented_properties_1971_2011.xlsx", clear sheet("per") cellrange(A1:F5) firstr 

xpose, clear 

drop if v1 == .
rename v1	year
rename v2 	Padova
rename v3	Parma
rename v4	Reggio

gen source 		= "Rented Properties" 
gen Variable 	= "per"
gen Name		= "Rented"

lab var Name 				"Category"
lab var year 				"Year"
lab var Variable 			"Statistic"
lab var Reggio				"Reggio Emilia"
lab var Padova				"Padova"
lab var Parma				"Parma"

order Name source Variable year Parma Padova Reggio
