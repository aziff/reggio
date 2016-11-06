* ------------------------*---------------------------------------------------- *
* Drawing Density Plots for 
* Authors: Sidharth Moktan
* Created: 10/07/2016
* Edited: 10/07/2016
* ---------------------------------------------------------------------------- *
clear all
set more off

global klmReggio	: 	env klmReggio		
global data_reggio	: 	env data_reggio
/*
include "${klmReggio}/data_other/Demographics_data_working/Sidharth/script/combine"
include "${klmReggio}/data_other/Demographics_data_working/Anna/scripts/reggioDemographic_prepare"
*/

cd "${klmReggio}/data_other/Demographics_data_working/Sidharth/intermed_output"
use combined_all, clear

foreach city in Reggio Parma Padova{
	egen house_own_`city' = total(`city') if Variable == "count" & source == "Rented Properties", by(year)
	gen house_perc_`city' = `city'/house_own_`city' if Variable == "count" & source == "Rented Properties"
	replace `city' = house_perc_`city' if Variable == "count" & source == "Rented Properties"
	drop house_own_`city' house_perc_`city' 
}
replace Variable = "perc" if Variable == "count" & source == "Rented Properties"
	
	
replace Name = Variable if Name == "Population"
replace Variable = "perc" if Name == "aindex" | Name == "dratio" | Name == "ecratio" | Name == "pop"
drop if Name == "" | source == "allAge"
drop if year != 1971& year != 1981& year != 1991& year != 2001& year != 2011

replace sex = "Male" if strpos(Name,"_Male")>0 & sex == ""
replace sex = "Female" if strpos(Name,"_Female")>0 & sex == ""
replace sex = "Both" if (strpos(Name,"_Total")>0 | (strpos(Name,"_Male")==0 & strpos(Name,"_Female")==0)) & sex == ""
replace sex = "Both" if sex == "Total"
foreach s in Male Female Total{
	replace Name = subinstr(Name,"_`s'","",.)
}

replace Name = Name + " (" + substr(sex,1,1)+")"

duplicates drop Name Variable sex year, force

reshape wide Reggio Parma Padova, i(Name Variable sex) j(year)

keep if Variable == "perc"

sort source Name sex

replace Name = subinstr(Name,"currentlyeconomicallyactive","economically active",.)
replace Name = subinstr(Name,"currentlynoneconomicallyactive","non-economically active",.)
replace Name = subinstr(Name,"inothercondition","other",.)
replace Name = subinstr(Name,"pensionerorcapitalincomerecipient","pensioner",.)
replace Name = subinstr(Name,"employedperson","employed",.)
replace Name = subinstr(Name,"unemployedperson","unemployed",.)
replace Name = subinstr(Name,"High School Diploma","High School",.)
replace Name = subinstr(Name,"Less than Primary","$<$ Primary",.)
replace Name = subinstr(Name,"Lower Secondary School","Lower Secondary",.)
replace Name = subinstr(Name,"Primary School","Primary",.)
replace Name = subinstr(Name,"_BirthRates","Birth rate",.)
replace Name = subinstr(Name,"_MortalityRates","Mortality rate",.)
replace Name = subinstr(Name,"_NaturalIncreaseRates","Natural increase rate",.)
replace Name = subinstr(Name,"_NetForeignMigrationRate","Net foreign migration rate",.)
replace Name = subinstr(Name,"_NetInternalMigrationRate","Net internal migration rate",.)
replace Name = subinstr(Name,"_NetMigrationRate","Net migration rate",.)
replace Name = subinstr(Name,"financial and insurance activities, real estate activities, professional, scientific, technical, administrative and support service activities  (k to n)","Finance, Professional, Scientific, Admin",.)
replace Name = subinstr(Name,"transportation and storage; information and communication","Transport, Storage, Info, Communication",.)
replace Name = subinstr(Name,"(o to u)","",.)
replace Name = subinstr(Name,"(g and i)","",.)
replace Name = subinstr(Name,"(h and j)","",.)
replace source = subinstr(source," ","",.)

replace Name = proper(Name)

replace Name = "ec-ratio (B)" if Name == "Ecratio (B)"
replace Name = "d-ratio (B)" if Name == "Dratio (B)"
replace Name = "a-index (B)" if Name == "Aindex (B)"

drop if Name == "Pop (B)"
drop if strpos(Name,"Illiterate")>0
drop if strpos(Name,"Total")>0
drop if strpos(Name,"Economically Active")>0 | strpos(Name,"non-economically active")>0 | strpos(Name,"Literate 6+ With Less")>0


order Name Reggio* Parma* Padova*
