* ---------------------------------------------------------------------------- *
* Graphs of results of jk-az-analysis.do
* Creators: Jessica Koh and Anna Ziff
* Origianl date: 1/4/16
* ---------------------------------------------------------------------------- *

global klmReggio : env klmReggio

//cd ${klmReggio}/Analysis/jk-az-analysis/Output/ExcelTables
cd /Users/annaziff/Desktop/ExcelTables

* ---------------------------------------------------------------------------- *

local cities 			Reggio Parma Padova
local ages				Child Adol Adult
local schools			Asilo Materna

local Child_outcomes	childSDQ 		//childHealthPerc
local Adol_outcomes		childSDQ SDQ 	childHealthPerc HealthPerc Migrant Depression
local Adult_outcomes	SDQ 							HealthPerc Migrant Depression

* ---------------------------------------------------------------------------- *
* Graph by cities and cohort 

foreach o of local Child_outcomes {
	import excel using "ReggioMaternaChild.xlsx", sheet("`o'") cellrange(A4:T246) clear
}
