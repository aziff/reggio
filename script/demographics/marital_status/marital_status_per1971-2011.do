
cd ${input_data}
import excel using "marital_status_1971_2011.xlsx", clear sheet("2011") cellrange(A16:D39) firstr

gen source 	= "Marital Status"
gen Name 	= Married

rename Married year


rename ReggioEmilia Reggio

gen N = _n
replace Name = "Married" 			if N > 0
replace Name = "Never Married" 		if N > 6
replace Name = "Divorced" 			if N > 12
replace Name = "Widowed" 			if N > 18
drop if Padova == .

gen Variable = "per"
drop N
destring(year), replace

lab var Name 		"Category"
lab var year		"Year"
lab var Variable	"Statistic"
lab var Reggio		"Reggio Emilia"
lab var Padova		"Padova"
lab var Parma		"Parma"

order Name source Variable year Parma Padova Reggio

