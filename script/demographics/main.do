/*
Project:			Reggio Evaluation
Authors:			Sidharth Moktan, Anna Ziff
Original date:		10/28/16

This file:			Call files that clean specific excel files
*/

global klmReggio 	: env klmReggio
global data_reggio	: env data_reggio
global git_reggio	: env git_reggio

global input_data 	= "${klmReggio}/data_other/Demographics_data_working"
global output_data	= "${input_data}/Stata"
global scripts		= "${git_reggio}/script/demographics"

// age distribution
	cd ${scripts}
		include allAge

// election
	cd ${scripts}
		include election

// education attainment
	cd ${scripts}
		include educational_attainment

// economic activity
	cd ${scripts}
		include economic_activity

// demographic balance
	cd ${scripts}
		include demographic_balance

// marital status
	cd "${scripts}/marital_status"
		include marital_status_count1971
	
	cd "${scripts}/marital_status"
		include marital_status_count1981
	
	cd "${scripts}/marital_status"
		include marital_status_count1991
	
	cd "${scripts}/marital_status"
		include marital_status_count2001
	
	cd "${scripts}/marital_status"
		include marital_status_count2011
	
	cd "${scripts}/marital_status"
		include marital_status_per1971-2011
	
	// combine all marital status datasets
	forvalues y = 1971(10)2011 {
		append using `mstatus`y''
	}
	sort year Name
	save ${output_data}/marital_status, replace

// population
cd "${scripts}/population"
	include population_count1971-2011
	
	save "${output_data}/population", replace

// rented properties
	cd "${scripts}/rented_properties"
		include rented_properties_count1971-2001
		
	cd "${scripts}/rented_properties"
		include rented_properties_count2011
		
	cd "${scripts}/rented_properties"
		include rented_properties_per1971-2011

	forvalues y = 1971(10)2011 {
		append using `rented`y''
	}
	sort year Name
	save ${output_data}/rented_properties, replace

// size of household
cd "${scripts}/size_household"
	include size_household_1971-2011
	
	sort year Name
	save ${output_data}/size_household, replace

// industry
cd "${scripts}/industry"
	include industry_count1971-2011
	
cd "${scripts}/industry"
	include industry_per1971-2011
	
	append using `industry_count'
	sort year Name
	save ${output_data}/size_household, replace
	

// combine all datasets together
cd $output_data
append using marital_status
append using population
append using rented_properties
append using size_household
append using all_age
append using demographic_balance
append using economic_activity
append using election

replace Variable = "perc" if Variable == "per"

save combined_all, replace
