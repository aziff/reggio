/////////////////////////////////////////////////////////////////////////////////////////////////////
***Gabriella, 17 April 2016
/////////////////////////////////////////////////////////////////////////////////////////////////////

set   more off
cap   log c
local date 17Apr2016
local resdir "C:\REGGIO\ANALYSIS\Results/"
log   using "C:\REGGIO\ANALYSIS\Results/ReggioADO-`date'.log", replace
use   "C:\REGGIO\ANALYSIS\Reggio.dta", clear

keep if (Cohort==3|Cohort==1)
g    Coh1=Cohort==1
g    MunPRE=maternaType==1 if !mi(maternaType) // Preschool=materna
g    MunITC=asiloType==1 if !mi(asiloType) // ITC=asilo


/////////////////////////////////////////////////////////////////////////////////////////////////////
***Controls 
/////////////////////////////////////////////////////////////////////////////////////////////////////
g  poorBHealth=(lowbirthweight==1|birthpremature==1) // there are no missings in bw
ta cgIncomeCat, g(IncCat_)
g  MInt=mofd(Date_int)
g  HighInc=(IncCat_5==1|IncCat_6==1|IncCat_7==1) if !mi(cgIncomeCat)
g  HighInc_F=HighInc
replace HighInc_F=0 if HighInc==.
g HighInc_Miss=HighInc==.
g  oldsibs=0
forvalues i = 3/10 {
la var year`i' "Birthday of component `i'"
}
forvalues i = 3/10 {
replace oldsibs=oldsibs+1*(Relation`i'==11&year`i'<2006) if (Cohort==1|Cohort==2)
replace oldsibs=oldsibs+1*(Relation`i'==11&year`i'<1994) if (Cohort==3)
}
g 		dadMaxEdu_Uni_F=dadMaxEdu_Uni
replace dadMaxEdu_Uni_F=0 if dadMaxEdu_Uni==.
g 		dadMaxEdu_Uni_Miss=dadMaxEdu_Uni==.
g 		dadBornProvince_F=dadBornProvince
replace dadBornProvince_F=0 if dadBornProvince==.
g 		dadBornProvince_Miss=dadBornProvince==.
g       distAsiloMunicipal1_MomEd=distAsiloMunicipal1*momMaxEdu_Uni
g       distAsiloMunicipal1_MomBP=distAsiloMunicipal1*momBornProvince

global BasicXsPRE  Male oldsibs Coh1
global BasicXsITC  Male oldsibs 
global FullXsPREV1 momMaxEdu_Uni momAgeBirth momBornProvince cgRelig houseOwn poorBHealth cgMaterna distCenter
global FullXsPREV2 momMaxEdu_Uni dadMaxEdu_Uni momAgeBirth momBornProvince dadBornProvince cgRelig houseOwn poorBHealth cgMaterna distCenter
global FullXsPREV3 momMaxEdu_Uni dadMaxEdu_Uni_F dadMaxEdu_Uni_Miss momAgeBirth momBornProvince dadBornProvince_F dadBornProvince_Miss ///
				   cgRelig houseOwn poorBHealth HighInc_F HighInc_Miss cgMaterna distCenter
global FullXsITCV1 momMaxEdu_Uni momAgeBirth momBornProvince cgRelig houseOwn poorBHealth cgAsilo distCenter
global FullXsITCV2 momMaxEdu_Uni dadMaxEdu_Uni momAgeBirth momBornProvince dadBornProvince cgRelig houseOwn poorBHealth cgAsilo distCenter
global FullXsITCV3 momMaxEdu_Uni dadMaxEdu_Uni_F dadMaxEdu_Uni_Miss momAgeBirth momBornProvince dadBornProvince_F dadBornProvince_Miss ///
				   cgRelig houseOwn poorBHealth HighInc_F HighInc_Miss cgAsilo distCenter
global InterviewXs Age CAPI 
global FullIVPRE   distMaternaMunicipal1 distMaternaPrivate1 distMaternaReligious1 distMaternaState1 
global FullIVITCV1 distAsiloMunicipal1 distAsiloPrivate1 distAsiloMunicipal1_MomEd
global FullIVITCV2 distAsiloMunicipal1 distAsiloMunicipal1_MomBP


/////////////////////////////////////////////////////////////////////////////////////////////////////
***Treatment
/////////////////////////////////////////////////////////////////////////////////////////////////////
reg MunPRE $BasicXsPRE $FullIVPRE if City==1
outreg2 using "`resdir'Mun", excel nocons dec(3) ctitle(PRE-Basic) append
reg MunPRE $BasicXsPRE $FullXsPREV1 $FullIVPRE if City==1
outreg2 using "`resdir'Mun", excel nocons dec(3) ctitle(PRE-V1) append
reg MunPRE $BasicXsPRE $FullXsPREV2 $FullIVPRE if City==1
outreg2 using "`resdir'Mun", excel nocons dec(3) ctitle(PRE-V2) append
reg MunPRE $BasicXsPRE $FullXsPREV3 $FullIVPRE if City==1
outreg2 using "`resdir'Mun", excel nocons dec(3) ctitle(PRE-V3) append
reg MunPRE $BasicXsPRE $FullXsPREV3 $FullIVPRE $InterviewXs if City==1
outreg2 using "`resdir'Mun", excel nocons dec(3) ctitle(PRE-Int) append

reg MunITC $BasicXsITC $FullIVITCV1 if City==1&Cohort==1
outreg2 using "`resdir'Mun", excel nocons dec(3) ctitle(ITC-COH1-Basic) append
reg MunITC $BasicXsITC $FullXsITCV1 $FullIVITCV1 if City==1&Cohort==1
outreg2 using "`resdir'Mun", excel nocons dec(3) ctitle(ITC-COH1-V1) append
reg MunITC $BasicXsITC $FullXsITCV2 $FullIVITCV1 if City==1&Cohort==1
outreg2 using "`resdir'Mun", excel nocons dec(3) ctitle(ITC-COH1-V2) append
reg MunITC $BasicXsITC $FullXsITCV3 $FullIVITCV1 if City==1&Cohort==1
outreg2 using "`resdir'Mun", excel nocons dec(3) ctitle(ITC-COH1-V3) append
reg MunITC $BasicXsITC $FullXsITCV3 $FullIVITCV1 $InterviewXs if City==1&Cohort==1
outreg2 using "`resdir'Mun", excel nocons dec(3) ctitle(Int) append

reg MunITC $BasicXsITC $FullIVITCV2 if City==1&Cohort==3
outreg2 using "`resdir'Mun", excel nocons dec(3) ctitle(ITC-COH3-Basic) append
reg MunITC $BasicXsITC $FullXsITCV1 $FullIVITCV2 if City==1&Cohort==3
outreg2 using "`resdir'Mun", excel nocons dec(3) ctitle(ITC-COH3-V1) append
reg MunITC $BasicXsITC $FullXsITCV2 $FullIVITCV2 if City==1&Cohort==3
outreg2 using "`resdir'Mun", excel nocons dec(3) ctitle(ITC-COH3-V2) append
reg MunITC $BasicXsITC $FullXsITCV3 $FullIVITCV2 if City==1&Cohort==3
outreg2 using "`resdir'Mun", excel nocons dec(3) ctitle(ITC-COH3-V3) append
reg MunITC $BasicXsITC $FullXsITCV3 $FullIVITCV2 $InterviewXs if City==1&Cohort==3
outreg2 using "`resdir'Mun", excel nocons dec(3) ctitle(Int) append
