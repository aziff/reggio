* ---------------------------------------------------------------------------- *
* Experimenting with Different Control Groups
* Contributors:			Anna Ziff
* Original version: 	Modified from 12/11/15
* Current version: 		1/25/16
* ---------------------------------------------------------------------------- *
* Define macros

local cities				Reggio 
local school_types 			None Muni Stat Reli Priv
local school_age_types		Asilo Materna
local cohorts				Child 

local am_groups				a1m1 a0m1 a1m0 a0m0 a1_or_m1
local a1m1_name				"Asilo = 1 and Materna = 1"
local a0m1_name				"Asilo = 0 and Materna = 1"
local a1m0_name				"Asilo = 1 and Materna = 0"
local a0m0_name				"Asilo = 0 and Materna = 0"
local a1_or_m1_name 		"Asilo = 1 or Materna = 1"

* ---------------------------------------------------------------------------- *
* Retrieve data with basic variables for analysis

cd $git_reggio
cd ~/Desktop/work/repos/gitreggiocode

include prepare-data

* ---------------------------------------------------------------------------- *
* To examine asilo/materna dynamics:
* 1. Asilo=1 & Materna=1 vs. Asilo=0 & Materna=0
* 2. Asilo=0 & Materna=1 vs. Asilo=0 & Materna=0
* 3. Asilo=1 & Materna=0 vs. Asilo=0 & Materna=0
* 4. Asilo=1 | Materna=1 vs. Asilo=0 & Materna=0

foreach c of local cities {
	local `c'_a1m1 		`c'Asilo == 1 & `c'Materna == 1
	local `c'_a0m1		`c'Asilo == 0 & `c'Materna == 1
	local `c'_a1m0 		`c'Asilo == 1 & `c'Materna == 0
	local `c'_a1_or_m1	`c'Asilo == 1 | `c'Materna == 1
	local `c'_a0m0		`c'Asilo == 0 & `c'Materna == 0
	
	
	foreach g of local am_groups {
		gen `c'_`g' = (``c'_`g'' & City == `c')
		lab var `c'_`g' "``g'_name' for city `c'"
	
		gen `g'`c'Muni_m = `c'_`g' * materna_Municipal
		gen `g'`c'Muni_a = `c'_`g' * asilo_Municipal
	}
}

* ---------------------------------------------------------------------------- *
* Comparison 1: Reggio municipal vs. Reggio non-municipal

foreach a of local school_age_types {
	foreach c of local cohorts {
		foreach o of local out`c'{
			reg `o' Reggio_a1m1 Reggio_a0m1 `Xright' 
		}
	}
}

* ---------------------------------------------------------------------------- *
* Comparison 2: Reggio municipal vs. non-Reggio everything

* ---------------------------------------------------------------------------- *
* Comparison 3: Reggio municipal vs. Reggio none
