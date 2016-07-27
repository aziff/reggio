* ---------------------------------------------------------------------------- *
* Labeling and Renaming Variables (Preparation Step for Estimation)
* Authors: Anna Ziff, Jessica Yu Kyung Koh
* Date Modified: 07/05/2016
* ---------------------------------------------------------------------------- *

* ---------------------------------------------------------------------------- *
* Outcome Estimation
** Labeling Variables
label var Male 					"Male indicator"
label var momAgeBirth 			"Mother: age at birth"
label var dadAgeBirth 			"Father: age at birth"
label var momMaxEdu_low			"Mother max. edu.: less than middle school"
label var momMaxEdu_middle  	"Mother max. edu.: middle school"
label var momMaxEdu_HS 			"Mother max. edu.: high school"
label var momMaxEdu_Uni 		"Mother max. edu.: university"
label var dadMaxEdu_low			"Father max. edu.: less than middle school"
label var dadMaxEdu_middle 		"Father max. edu.: middle school"
label var dadMaxEdu_HS 			"Father max. edu.: high school"
label var dadMaxEdu_Uni 		"Father max. edu.: university"
label var momBornProvince 		"Mother: born in province"
label var dadBornProvince 		"Father: born in province"
label var cgRelig 				"Religious caregiver indicator"
label var houseOwn 				"Home ownership indicator"
label var cgReddito_1			"Income: 5,000 euros or less"
label var cgReddito_2			"Income: 5,001-10,000 euros"
label var cgReddito_3 			"Income: 10,001-25,000 euros"
label var cgReddito_4 			"Income: 25,001-50,000 euros"
label var cgReddito_5 			"Income: 50,001-100,000 euros"
label var cgReddito_6 			"Income: 100,001-250,000 euros"
label var cgReddito_7 			"Income: more than 250,000 euros"		
label var lowbirthweight 		"Low birthweight"
label var birthpremature		"Premature birth"
label var childrenSibTot		"Number of siblings"
label var yrCity				"Migrants: year entered city"
label var ageCity				"Migrants: age entered city"
label var cgMigrant				"Mother: born outside of Italy"

label var mStatus_married_cohab "Married or Cohabitating"
label var childrenResp			"Num. of Children in House"
label var all_houseOwn			"Own House"
label var live_parent			"Live With Parents"

label var Maria					"Tried Marijuana"
label var Smoke					"Smoker"
label var Cig					"Num. of Cigarettes Per Day"
label var BMI					"BMI"
label var childBMI 				"BMI - child"
label var childz_BMI 			"BMI z-score - child"
label var cgBMI 				"Caregiver BMI"
label var z_BMI					"BCMI z-score"
label var Health				"Good Health"
label var SickDays				"Num. of Days Sick Past Month"
label var i_RiskDUI				"Drove Under Influence "
label var i_RiskFight			"Engaged in A Fight "
label var RiskSuspended			"Ever Suspended from School"
label var Drink1Age				"Age At First Drink"

label var LocusControl			"Locus of Control"
label var Depression_score		"Depression Score"
label var pos_LocusControl		"Locus of Control - Positive"
label var pos_Depression_score	"Depression Score - Positive"
label var binSatisIncome		"Satisfied with Income"
label var binSatisWork			"Satisfied with Work"
label var binSatisHealth 		"Satisfied with Health"
label var binSatisFamily		"Satisfied with Family"
label var optimist				"Optimistic Look on Life"
label var reciprocity1bin		"Return a Favor"
label var reciprocity2bin		"Put Someone in Difficulty"
label var reciprocity3bin		"Help Someone Who is Kind To Me"
label var reciprocity4bin 		"Would Insult Someone Back"

label var MigrTaste				"Favorable to Migrants"
label var Friends				"Number of Friends"
label var MigrFriend			"Has Migrant Friends"




** Locals for labels
** Label
local IQ_factor_lab 			IQ Factor
local IQ_score_lab 				IQ Score
local cgIQ_score_lab 			Caregiver IQ Score
local cgIQ_factor_lab			Caregiver IQ Factor
local votoMaturita_lab			High School Grade
local votoUni_lab				University Grade
local highschoolGrad_lab		Graduate from High School
local MaxEdu_Uni_lab			Max Edu: University
local MaxEdu_Grad_lab			Max Edu: Graduate School

local PA_Empl_lab				Employed
local SES_self_lab				Self-Employed
local HrsTot_lab				Hours Worked Per Week
local WageMonth_lab				Monthly Wage
local Reddito_1_lab				H. Income: 5,000 Euros of Less
local Reddito_2_lab				H. Income: 5,001-10,000 Euros
local Reddito_3_lab				H. Income: 10,001-25,000 Euros
local Reddito_4_lab				H. Income: 25,001-50,000 Euros
local Reddito_5_lab				H. Income: 50,001-100,000 Euros
local Reddito_6_lab				H. Income: 100,001-250,000 Euros
local Reddito_7_lab				H. Income: More than 250,000 Euros

local mStatus_married_cohab_lab Married or Cohabitating
local childrenResp_lab			Num. of Children in House
local all_houseOwn_lab			Own House
local live_parent_lab			Live With Parents

local Maria_lab					Tried Marijuana
local Smoke_lab					Smokes
local Cig_lab					Num. of Cigarettes Per Day
local BMI_lab					BMI
local childBMI_lab 				"BMI - child"
local childz_BMI_lab 			"BMI z-score - child"
local cgBMI_lab					Caregiver BMI	
local goodHealth_lab			Good Health
local SickDays_lab				Num. of Days Sick Past Month
local i_RiskDUI_lab				Drove Under Influence 
local i_RiskFight_lab			Engaged in A Fight 
local RiskSuspended_lab			Ever Suspended from School
local Drink1Age_lab				Age At First Drink

local LocusControl_lab			Locus of Control
local Depression_score_lab		Depression Score

local pos_LocusControl_lab		Locus of Control - positive
local pos_Depression_score_lab	Depression Score - positive

local binSatisIncome_lab		Satisfied with Income
local binSatisWork_lab			Satisfied with Work
local binSatisHealth_lab 		Satisfied with Health 
local binSatisFamily_lab		Satisfied with Family
local optimist_lab				Optimistic Look on Life
local binSatisSchool_lab		Satisfied with School

local reciprocity1bin_lab		Return Favor 
local reciprocity2bin_lab		Put Someone in Difficulty
local reciprocity3bin_lab		Help Someone Kind To Me
local reciprocity4bin_lab 		Insult Back

local MrgrTaste_lab				Favorable to Migrants
local Friends_lab				Number of Friends
local MigrFriend_lab			Has Migrant Friends

local pos_SDQ_score_lab				SDQ Composite
local pos_SDQEmot_score_lab			SDQ Emotional
local pos_SDQCond_score_lab			SDQ Conduct
local pos_SDQHype_score_lab			SDQ Hyper
local pos_SDQPeer_score_lab			SDQ Peer problems
local pos_SDQPsoc_score_lab			SDQ Pro-social

local pos_childSDQ_score_lab		SDQ Composite - Child
local pos_childSDQEmot_score_lab	SDQ Emotional - Child
local pos_childSDQCond_score_lab	SDQ Conduct - Child
local pos_childSDQHype_score_lab	SDQ Hyper - Child
local pos_childSDQPeer_score_lab	SDQ Peer problems - Child
local pos_childSDQPsoc_score_lab	SDQ Pro-social - Child
* ---------------------------------------------------------------------------- *
* Baseline Estimation
* Locals
** Basic
local Child_lab		Children
local Migr_lab		Migrants
local Adol_lab		Adolescents
local Adult30_lab	Adults (Age 30)
local Adult40_lab	Adults (Age 40)
local Adult50_lab	Adults (Age 50)

local 0_note		females
local 1_note		males
local Child_note	children
local Migr_note		migrants
local Adol_note		adolescents
local Adult30_note	adults in their 30's
local Adult40_note	adults in their 40's
local Adult50_note	adults in their 50's

** Variables
local Male_lab					Male
local CAPI_lab 					CAPI
local lowbirthweight_lab 		Low Birthweight
local birthpremature_lab     	Premature at Birth          
local momMaxEdu_middle_lab 		Max Education: Middle School
local momMaxEdu_HS_lab 			Max Education: High School
local momMaxEdu_Uni_lab 		Max Education: University
local teenMomBirth_lab 			Teenager at Birth
local momBornProvince_lab 		Born in Province
local dadMaxEdu_middle_lab 		Max Education: Middle School
local dadMaxEdu_HS_lab 			Max Education: High School
local dadMaxEdu_Uni_lab 		Max Education: University
local teenDadBirth_lab 			Teenager at Birth
local dadBornProvince_lab 		Born in Province
local cgRelig_lab 				Caregiver Has Religion
local cgCatholic_lab			Caregiver is Catholic
local int_cgCatFaith_lab		Caregiver is Catholic and Faithful
local numSibling_1_lab 			One Sibling
local numSibling_2_lab 			Two Siblings
local numSibling_more_lab		More Than Three Siblings
local houseOwn_lab 				Owns House
local cgReddito_2_lab 			Income 5K-10K Euro
local cgReddito_3_lab 			Income 10K-25K Euro
local cgReddito_4_lab 			Income 25K-50K Euro
local cgReddito_5_lab 			Income 50K-100K Euro
local cgReddito_6_lab 			Income 100K-250K Euro
local cgReddito_7_lab  			Income More Than 250K Euro

** Variables_short
local CAPI_short 					CP
local lowbirthweight_short 			LB
local birthpremature_short     		PB          
local momMaxEdu_middle_short 		MMS
local momMaxEdu_HS_short 			MHS
local momMaxEdu_Uni_short 			MUN
local teenMomBirth_short 			MTB
local momBornProvince_short 		MBP
local dadMaxEdu_middle_short 		DMS
local dadMaxEdu_HS_short 			DHS
local dadMaxEdu_Uni_short 			DUN
local teenDadBirth_short 			DTB
local dadBornProvince_short 		DBP
local cgRelig_short 				RL
local cgCatholic_short				CAT	
local int_cgCatFaith_short			CTF
local numSibling_1_short 			NS1
local numSibling_2_short 			NS2
local numSibling_more_short			NSM
local houseOwn_short 				OH
local cgReddito_2_short 			I5
local cgReddito_3_short 			I10
local cgReddito_4_short 			I25
local cgReddito_5_short 			I50
local cgReddito_6_short 			IH
local cgReddito_7_short  			IM
