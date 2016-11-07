// 2001
cd ${input_data}
import excel using "marital_status_1971_2011.xlsx", clear sheet("2001") cellrange(A11:D16) 

gen source 		= "Marital Status"
gen year 		= 2001
gen Variable 	= "count"


rename A 	Name
rename B	Padova
rename C	Parma
rename D	Reggio


replace Name = "Never Married" 		if Name == "T_6_popScivileTOT__Celibi_nubili" 
replace Name = "Married"			if Name == "T_6_popScivileTOT__Coniugati_e"
replace Name = "Divorced"			if Name == "T_6_popScivileTOT__Divorziati_e" 
replace Name = "Separated"			if Name == "T_6_popScivileTOT__Separati_e_di_fatto"
replace Name = "Separated"			if Name == "T_6_popScivileTOT__Separati_e_legalmente"
replace Name = "Widowed"			if Name == "T_6_popScivileTOT__Vedovi_e"

foreach c in Padova Parma Reggio {
	sort Name 
	by Name : egen tot`c' = sum(`c')
	
	drop `c'
	rename tot`c' `c'
}


lab var Name 		"Category"
lab var year		"Year"
lab var Variable	"Statistic"
lab var Reggio		"Reggio Emilia"
lab var Padova		"Padova"
lab var Parma		"Parma"

order Name year Variable source Parma Padova Reggio

tempfile mstatus2001
save 	`mstatus2001'
