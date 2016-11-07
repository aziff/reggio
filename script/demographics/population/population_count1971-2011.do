// 1971-2011
cd ${input_data}
import excel using "Population_Idicators.xlsx", clear sheet("Indicators relating to the  (2") cellrange(A8:V13) firstr

drop B 
rename residentpopulationabsoluteva pop1971
rename D 							pop1981
rename E 							pop1991
rename F 							pop2001
rename G 							pop2011
rename elderforchild				ecratio1971
rename I							ecratio1981
rename J							ecratio1991
rename K							ecratio2001
rename L							ecratio2011
rename dependencyratio				dratio1971
rename N							dratio1981
rename O							dratio1991
rename P							dratio2001
rename Q							dratio2011
rename ageingindex					aindex1971
rename S							aindex1981
rename T							aindex1991
rename U							aindex2001
rename V							aindex2011
drop if Datatype == "Census year" | Datatype == "Territory"

foreach v in pop ecratio dratio aindex {
	foreach y in 1971(10)2011 {
		destring ``v'`y'', replace
	}
}

rename Datatype city
replace city = subinstr(city," ", "", .)
replace city = "Reggio" if city == "ReggioEmilia"

reshape long pop ecratio dratio aindex, i(city) j(year)
gen Padova = .
gen Parma = .
gen Reggio = .
set obs 60
drop year
egen year = fill(1971 1981 1991 2001 2011 1971 1981 1991 2001 2011)


gen N = _n
gen Variable = "pop" 					if N > 0
replace Variable = "ecratio" 			if N > 15
replace Variable = "dratio" 			if N > 30
replace Variable = "aindex" 			if N > 45

foreach c in Padova Parma Reggio {
	foreach v in pop ecratio dratio aindex {
		forvalues y = 1971(10)2011 {
		
			sum `v' if city == "`c'" & year == `y'
			local `c'`v'`y' = r(mean)
			
			replace `c' = ``c'`v'`y'' if year == `y' & Variable == "`v'"
			
		}
	}
}

drop city pop ecratio dratio aindex N
sort Variable
by Variable: gen N = _n
drop if N > 5
drop N

gen source = "Population"
gen Name = "Population"

order Name Variable year Parma Padova Reggio

