

// locals for differences
local own1971					"TAV_U1__PRO_ABOCC"
local rent1971					"TAV_U1__AFFIT_ABOCC"
local other1971					"TAV_U1__ATIT_ABOCC"

local own1981					"T_16__PRO_AB"
local rent1981 					"T_16__AFF_AB"
local other1981		 			"T_16__ALTRO_AB"

local own1991					"T5_18__ABI_PR"
local rent1991					"T5_18__ABI_AF"
local other1991					"T5_18__ABI_AL"

local own2001					"T_12_AbResGod__PROPRIETA"
local rent2001					"T_12_AbResGod__AFFITTO"
local other2001					"T_12_AbResGod__ALTRO_TIT"

local cell_start 				= 13
local cell_end 					= 16

foreach y in 1971 1981 1991 2001 {

	if `y' == 1991 {
		local cell_start		= `cell_start' + 1
		local cell_end 			= `cell_end' + 1
	}

	cd ${input_data}
	import excel using "rented_properties_1971_2011.xlsx", clear sheet("`y'") cellrange(A`cell_start':D`cell_end') firstr 

	rename Municipality 		Name
	rename ReggionellEmilia		Reggio

	gen source 	 	= "Rented Properties"
	gen year 	 	= `y'
	gen Variable 	= "count"

	replace Name 	= "Owned" 	if Name == "`own`y''"
	replace Name 	= "Rented" 	if Name == "`rent`y''"
	replace Name 	= "Other" 	if Name == "`other`y''"

	lab var Name 				"Category"
	lab var year 				"Year"
	lab var Variable 			"Statistic"
	lab var Reggio				"Reggio Emilia"
	lab var Padova				"Padova"
	lab var Parma				"Parma"

	order Name source Variable year Parma Padova Reggio

	tempfile rented`y'
	save 	`rented`y''
}
