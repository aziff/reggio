/*
Author: Geoffrey Wang and Pietro Biroli
First Date: 12/11/2014
Current Version: 01 Oct 2015

Purpose:	
	(1) Find coordinates of school and individual's addresses (using ArcGIS)
	(2) Merge the individuals' home coordinates with the distances of all schools
	(3) Construct the distance to the border


Input: Indiv_coord.xlsx; School_coord.xlsx

Output: distances between individuals and school


Process of creating file of distances from individuals to school (school_dist_collapsed.dta)
Author: Geoffrey Wang and Pietro Biroli
Date: 3/16/2015

// =========== Step: Prepare schools and individuals for geocoding ===================
Each school was given an unique ID manually using the file klmReggio\data_survey\Scuole_ParmaReggioPadova_updated.xlsx
School ID has been hard-coded so that 
the first number is for the city (1=Reggio, 2=Parma, 3=Padova)
the second number is the type of school (1=municipal, 2=state, 3=Religious, 4=Private)
the last three numbers are for the school number (if nido and materna have same address and same name, then same ID; if same name but different address, the nido ID is the same as materna ID +1)
IDs are given (roughly) sorting by name and address
If "short name" is missing, then there is nobody in our dataset assigned to that school

Each individual was assigned to a particular school manually based on the answers to name and address of preschool, see file klmReggio\data_survey\data\ReggioAll_SchoolNames_manual.xlsx
Each school is identified by a "short name" and a "school ID", both of which are also present in the file klmReggio\data_survey\Scuole_ParmaReggioPadova_updated.xlsx


Use do files in order to update Reggio_all.dta

Run "clean_Reggio_geocode.do" to prepare data for geocoding

saved file: "Reggio_geocode.xlsx"


// ========== Step: Geocode schools and individuals ======================

Use ArcGIS to: 
Geocode schools (input: klmReggio\data_survey\Scuole_ParmaReggioPadova_updated.xlsx, output: CAREFULLY overwrite same file)
Geocode individuals (input: klmReggio\data_survey\data\Distances\Reggio_geocode.xlsx, output:klmReggio\data_survey\data\Distances\indiv_coord.xlsx)

// ========= Step: Calculate distances =================================
---First, calculate individuals' distances to center of their respective cities

---Next, make a cross section of all individuals and schools (4690 people * 372 schools),
calculate a distance from each individual to all schools

---To create the 2 shortest distances for each type of school, sort by intnr, Nido or Materna, school type, and distance.
Keep only the 1st two in each of these categories

---To find the individuals' attended schools, match by school id
*/

clear all
capture log close
set more off

/***directory
 global dir "/mnt/ide0/share/klmReggio/data_survey/data/"
// global dir "/Volumes/klmReggio/data_survey/data/"
// global dir "\\athens.uchicago.edu/klmReggio/data_survey/data/"
cd "$dir"
*/
if 1==0{ // Prepare the data for ArcGIS to geocode individuals and schools addresses
cd "$dir"

use Reggio_all.dta, clear

//=============================================================================

// drop unneeded variables
keep intnr City internr Address ///
     flagasilo* flagmaterna* asiloNotCity maternaNotCity asiloType maternaType //these last variables are there for colored-maps in ArcGIS

//add Country variable
gen Country = "Italy"


//replace City with string (use "Reggio nell'Emilia" rather than "Reggio" for more accurate geocoding)
tostring City, replace force

replace City = "Reggio nell'Emilia" if City == "1"
replace City = "Parma" if City == "2"
replace City = "Padova" if City == "3"

* Add city centers (Piazza del duomo)
gen X_center = .
gen Y_center = .

* Reggio
replace X_center = 10.630476 if City == "Reggio nell'Emilia" 
replace Y_center = 44.697976 if City == "Reggio nell'Emilia"

* Parma: 
replace X_center = 10.3306775 if City == "Parma"
replace Y_center = 44.8033735 if City == "Parma"

* Padova
replace X_center = 11.8724846 if City == "Padova"
replace Y_center = 45.406679  if City == "Padova"

cd Maps/Geoffrey_geocode/Reggio_GeoCode
/* According to international standards 
replace X_center = 10.333 if City == "Parma"
replace Y_center = 44.8 if City == "Parma"

replace X_center = 10.633 if City == "Reggio nell'Emilia"
replace Y_center = 44.7 if City == "Reggio nell'Emilia"

replace X_center = 11.8667 if City == "Padova"
replace Y_center = 45.4167 if City == "Padova"

* save dta file
save Reggio_geocode.dta, replace
*/

//save excel file
export excel using Reggio_geocode.xls, firstrow(variables) replace


/* save separate files for geocoding of different cities
preserve
keep if City == "Reggio nell'Emilia"

export excel using Reggio_only.xls, firstrow(variables) replace

restore, preserve
keep if City == "Parma"
export excel using Parma_only.xls, firstrow(variables) replace

restore
keep if City == "Padova"
export excel using Padova_only.xls, firstrow(variables) replace
*/

*** NOW USE ARCGIS TO GEOCODE THE ADDRESSES --> OUTPUT: indiv_coord.xlsx
}

if 1==1{ // Calculate the distances
cd "$dir"

/* ============== Prepare data ======== */
** School Data
import excel "Scuole_ParmaReggioPadova_updated.xlsx", sheet("list") firstrow clear

//rename variables to distinguish from individual
drop Street_School country_School CAP_School
//rename (X Y) (X_School Y_School)

label define Type 0 "Not Attended" 1 "Municipal" 2 "State" 3 "Religious" 4 "Private"
label values SchoolType Type

egen temp = group(Province_School) 
replace temp = 4-temp 
tab temp Province, miss
drop Province
rename temp Province_School
label define City 1 "Reggio" 2 "Parma" 3 "Padova"
label values Province City

duplicates report ID_School if ID_School<. //check ID is well done
save Scuole.dta, replace

** Individuals
import excel ./Maps/Geoffrey_geocode/Reggio_GeoCode/Indiv_coord.raw.xls, sheet("Sheet1") firstrow clear
rename (X Y) (X_Address Y_Address)

egen temp = group(City) 
replace temp = 4-temp 
tab temp City, miss
drop City
rename temp City
label define City 1 "Reggio" 2 "Parma" 3 "Padova"
label values City City

* merge with the ID of the school actually chosen
//do ../gitReggioCode/NamesManual.do
merge 1:1 intnr using "ReggioAll_SchoolNames_manual.dta", keepusing(*SchoolID_manual *name_manual) 
drop _merge

//save Distances.dta, replace

/* ============== Calculate distance to city center =============== */
// ssc install geodist
geodist Y_Address X_Address Y_center X_center, gen(distCenter)
label var distCenter "Distance from respondent's current address to city center"
drop Y_center X_center
//save Distances.dta, replace

/* ============== Form all Crosswise Pairs and Calculate Distances ==============*/
*Merge individuals and schools
cross using Scuole.dta //cross=forms pairwise combination of the two datasets

*calculate distances (Geodetic distances -- lenght of shortest curve between two points of a mathematical model of the earth) 
geodist Y_Address X_Address Y_School X_School, gen(dist)
label var dist "Distance to each school (km)"
sort intnr NidoScuola SchoolType dist

*identify the distance to the school chosen
gen dist_asiloChosen   = dist if ID_School == asiloSchoolID_manual
gen dist_maternaChosen = dist if ID_School == maternaSchoolID_manual

* spread the dist-school across all individuals
capture drop temp*
foreach var in dist_asiloChosen dist_maternaChosen {
egen temp1 = min(`var'), by(intnr)
/* Check that there are no double matches, and then 
egen temp2 = max(`var'), by(intnr)
tab asiloname_manual if temp1!=temp2
*browse  intnr asiloname_manual asiloSchoolID_manual ID_School ShortName_School NidoScuola dist dist_asiloChosen dist_maternaChosen temp1 temp2   if temp1!=temp2
*/
replace `var' = temp1
drop temp*
}
sum dist*

** keep only the cross within each City --> NOTE: this should be done right after cross, however there are some people from Parma attending a school in Reggio.
keep if City == Province_School

*check that there are no huge distances
sum dist* // hist dist
tab ShortName_School City if dist>23 // [=] double check-these schools
/*
browse Address intnr internr City ID_School ShortName_School SchoolType NidoScuola Province_School dist if dist>25
*/

*create a duplicate of all the materna schools that are also asilo (duplicate = expand 2, triplicate = expand 3...)
expand 2 if NidoScuola=="Nido_Scuola", gen(temp)
replace NidoScuola="Nido"   if NidoScuola=="Nido_Scuola" & temp==0
replace NidoScuola="Scuola" if NidoScuola=="Nido_Scuola" & temp==1
*rename to be consistent with the rest of the naming conventions
replace NidoScuola="asilo" if NidoScuola=="Nido"
replace NidoScuola="materna" if NidoScuola=="Scuola"
tab SchoolType NidoScuola, miss // CHECK that there are no State asilo
drop temp

/* =============== Part 4: Find 2 closest school for each school type ===================================*/
/* ========= by school type (religious, private, state, municipal) in each Nido/Scuola Category ========*/
*sort by category and distance, then create an order variable
sort intnr NidoScuola SchoolType dist 
bys intnr NidoScuola SchoolType: gen orderDistance = _n
save Distances_long.dta, replace

* keep only the first and second closest school by category
keep if orderDistance<=2 //keep only the 2-closest

* checks
duplicates report intnr // check there should be 14 repetitions for each person: 7 categories X 2 distances
duplicates report intnr if City==1 // [=] check: why Reggio has 15 and Parma 18?
duplicates report intnr if City==2 // [=] check: why Reggio has 15 and Parma 18?
sum dist*
tab City SchoolType if dist>10
tab ShortName if dist>10
//list intnr dist* if dist>10
//save Distnaces.dta, replace

* reshape into wide format, to have 1 observation per person. Keep only the distances (not the identity of the closest schools)
drop ID_School Name_School ShortName_School SchoolTypeFull address_School City_School comments_School X_School Y_School Province_School accuracy
decode SchoolType, gen(ciccio)
gen category = NidoScuola+ciccio+string(orderDistance)
tab category
drop ciccio SchoolType NidoScuola orderDistance Date_founded Date_closed Street_School_2 City_SchoolFull //they are sporadic and might change

reshape wide dist, i(intnr) j(category) string

order intnr intnr internr Address Country Postal X_Address Y_Address City

label var distasiloMunicipal1 "Distance from closest municipal infant-toddler center"
label var distasiloMunicipal2 "Distance from second closest municipal infant-toddler center"
label var distmaternaMunicipal1 "Distance from closest municipal preschool"
label var distmaternaMunicipal2 "Distance from second closest municipal preschool"
//label var distasiloState1 "Distance from closest state infant-toddler center"
//label var distasiloState2 "Distance from second closest state infant-toddler center"
label var distmaternaState1 "Distance from closest state preschool"
label var distmaternaState2 "Distance from second closest state preschool"
label var distasiloReligious1 "Distance from closest religious infant-toddler center"
label var distasiloReligious2 "Distance from second closest religious infant-toddler center"
label var distmaternaReligious1 "Distance from closest religious preschool"
label var distmaternaReligious2 "Distance from second closest religious preschool"
label var distasiloPrivate1 "Distance from closest private infant-toddler center"
label var distasiloPrivate2 "Distance from second closest private infant-toddler center"
label var distmaternaPrivate1 "Distance from closest private preschool"
label var distmaternaPrivate2 "Distance from second closest private preschool"

label var dist_asiloChosen "Distance to chosen infant-toddler center"
label var dist_maternaChosen "Distance to chosen preschool"

dropmiss, force

rename Cohort temp
gen Cohort = 1 if temp == "Children"
replace Cohort = 2 if temp == "Migrants"
replace Cohort = 3 if temp == "Adolescents"
replace Cohort = 4 if temp == "Adult 30"
replace Cohort = 5 if temp == "Adult 40"
replace Cohort = 6 if temp == "Adult 50"
tab Cohort temp, miss
drop temp

save Distances.dta, replace
}
if 1==1{ // calculate the distances to the border
use Distances.dta, clear

//create coordinates for border between Padova and Reggio and border between Parma and Reggio
//Coordinates of Colerno used for border between Parma and Reggio
//Coordinates of Bondeno used for border between Padova and Reggio

gen X_PadReg = 11.4149565
gen Y_PadReg = 44.8909458
gen X_ParReg = 10.4860772
gen Y_ParReg = 44.7497228

//generate distances
geodist Y_Address X_Address Y_PadReg X_PadReg, gen(dist_PadReg)
geodist Y_Address X_Address Y_ParReg X_ParReg, gen(dist_ParReg)

replace dist_PadReg=.w if City==2 //replace distance to missing for Parma
replace dist_ParReg=.w if City==3 //replace distance to missing for Padova

/* display histograms
hist dist_PadReg
hist dist_ParReg
*/
save Distances.dta, replace
}
