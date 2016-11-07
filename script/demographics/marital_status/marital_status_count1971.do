// 1971
cd ${input_data}
import excel using "marital_status_1971_2011.xlsx", clear sheet("1971") cellrange(A4:D10) firstr

gen source 		= "Marital Status"
gen year 		= 1971
gen Variable 	= "count"

rename ReggionellEmilia 		Reggio
rename capoluogo_di_provincia 	Name

drop if Name == "TAV_C__CELIBI_71" ///
	  | Name == "TAV_C__CONIUGATI_71" ///
	  | Name == "TAV_C__VEDOVI_71"

replace Name = "Never Married" 	if Name == "TAV_C__CELIBI_NUBILI_71" 
replace Name = "Married"		if Name == "TAV_C__CONIUGATI_tot_71" 
replace Name = "Widowed"		if Name == "TAV_C__VEDOVI_tot_71" 

lab var Name 		"Category"
lab var year		"Year"
lab var Variable 	"Statistic"
lab var Reggio		"Reggio Emilia"

order Name year Variable source Parma Padova Reggio

tempfile mstatus1971
save 	`mstatus1971'
