* ---------------------------------------------------------------------------- *
* Globals and locals for Reggio analysis
* Authors: Reggio Team
* Edited: 2016/08/23
* ---------------------------------------------------------------------------- * 

* -------------- *
* Classification *
* -------------- *
global cohorts					Child Migrant Adolescent Adult30 Adult40 Adult50
global cities					Reggio Parma Padova
global schools					Municipal State Religious Private None
	
* ------------------ *
* Baseline variables *
* ------------------ *
global child_baseline_vars  	Male /*Cohort_Migrants*/ lowbirthweight birthpremature CAPI	momBornProvince momMaxEdu_low momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni ///
								dadBornProvince dadMaxEdu_low dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni numSibling_1 numSibling_2 numSibling_more cgCatholic cgIslam ///
								int_cgCatFaith houseOwn cgMigrant cgReddito_1 cgReddito_2 cgReddito_3 cgReddito_4 cgReddito_5 cgReddito_6
								// momWork_fulltime06 momWork_parttime06 momSchool06  
								// We assume that household income abd family house ownership for children cohorts can be considered as "baseline"
								
global adol_baseline_vars  		Male lowbirthweight birthpremature CAPI cgIslam ///
								momBornProvince ///
								momMaxEdu_low momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni  ///
								dadBornProvince ///
								dadMaxEdu_low dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni  ///
								numSibling_1 numSibling_2 numSibling_more cgCatholic int_cgCatFaith cgMigrant 
								// momWork_fulltime06 momWork_parttime06 momSchool06		 						
								
								
global adult_baseline_vars		Male CAPI ///
								momBornProvince ///
								momMaxEdu_low momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni  ///
								dadBornProvince  ///
								dadMaxEdu_low dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni  ///
								numSibling_1 numSibling_2 numSibling_more cgRelig cgIslam
								// momWork_fulltime06 momWork_parttime06 momSchool06
															
								
global Child_baseline_vars				$child_baseline_vars							
global Migrant_baseline_vars			$child_baseline_vars yrCity ageCity
global Adolescent_baseline_vars			$adol_baseline_vars
global Adult30_baseline_vars 			$adult_baseline_vars
global Adult40_baseline_vars 			$adult_baseline_vars
global Adult50_baseline_vars		 	$adult_baseline_vars


* ------------------------------- *								
* BIC-selected baseline variables *
* ------------------------------- *
* For Preschool
*global bic_child_baseline_vars					Male CAPI asilo Cohort_Migrants momMaxEdu_Uni houseOwn cgReddito_3
global bic_child_baseline_vars					Male CAPI asilo momMaxEdu_Uni houseOwn cgReddito_3
global bic_adol_baseline_vars					Male CAPI asilo dadMaxEdu_HS dadMaxEdu_Uni int_cgCatFaith
global bic_adult_baseline_vars		    		Male CAPI dadMaxEdu_Uni numSibling_2 numSibling_more

global bic_child_baseline_did_vars				maternaMuni##Male maternaMuni##CAPI maternaMuni##asilo maternaMuni##momMaxEdu_Uni maternaMuni##houseOwn maternaMuni##cgReddito_3
global bic_adol_baseline_did_vars				maternaMuni##Male maternaMuni##CAPI maternaMuni##asilo maternaMuni##dadMaxEdu_HS maternaMuni##dadMaxEdu_Uni maternaMuni##int_cgCatFaith
global bic_adult_baseline_did_vars		    	maternaMuni##Male maternaMuni##CAPI maternaMuni##dadMaxEdu_Uni maternaMuni##numSibling_2 maternaMuni##numSibling_more

* For Asilo
*global bic_asilo_child_baseline_vars			Male CAPI Cohort_Migrants momMaxEdu_Uni houseOwn cgReddito_3
global bic_asilo_child_baseline_vars			Male CAPI momMaxEdu_Uni houseOwn cgReddito_3
global bic_asilo_adol_baseline_vars				Male CAPI dadMaxEdu_HS dadMaxEdu_Uni int_cgCatFaith
global bic_asilo_adult_baseline_vars		    Male CAPI dadMaxEdu_Uni numSibling_2 numSibling_more
global bic_asilo_adult30_baseline_vars			Male CAPI dadMaxEdu_Uni numSibling_2

global bic_asilo_child_baseline_did				maternaMuni##Male maternaMuni##CAPI maternaMuni##momMaxEdu_Uni maternaMuni##houseOwn maternaMuni##cgReddito_3
global bic_asilo_adol_baseline_did				maternaMuni##Male maternaMuni##CAPI maternaMuni##dadMaxEdu_HS maternaMuni##dadMaxEdu_Uni maternaMuni##int_cgCatFaith
global bic_asilo_adult_baseline_did				maternaMuni##Male maternaMuni##CAPI maternaMuni##dadMaxEdu_Uni maternaMuni##numSibling_2 maternaMuni##numSibling_more



* ------------------------------------------- *											
* Outcomes for each category: Younger Cohorts *
* ------------------------------------------- *
global child_outcome_M					IQ_factor pos_childSDQ_score BMI_obese BMI_overweight childHealthPerc diffInterest diffSit likeSch_child_pos childFriends candyGame_bin // Main outcomes

global child_outcome_CN         		IQ_factor IQ_score ///
										pos_childSDQ_score pos_cSDQPsoc pos_cSDQPeer pos_cSDQHype pos_cSDQEmot pos_cSDQCond 
								 
global child_outcome_C	         		IQ_factor IQ_score
										
global child_outcome_N					pos_childSDQ_score pos_cSDQPsoc pos_cSDQPeer pos_cSDQHype pos_cSDQEmot pos_cSDQCond 	 								 
								 
global child_outcome_S	 		 		childinvMusic  ///
										worryHome worryTeacher worryFriend worryMyself childFriends candyGame_bin
								 
global child_outcome_H 			 		BMI_obese BMI_overweight childHealthPerc childSickDays 

global child_outcome_B			 		diffInterest diffSit likeSch_child_pos faceGeneral 
                                 

global adol_outcome_M					IQ_factor pos_childSDQ_score pos_SDQ_score pos_Depress pos_LocusControl BMI_obese BMI_overweight childHealthPerc dropoutSchool likeSch_ado_pos sport Friends volunteer Trust							 
				  
global adol_outcome_CN          		IQ_factor IQ_score ///
										pos_childSDQ_score pos_cSDQPsoc pos_cSDQPeer pos_cSDQHype pos_cSDQEmot pos_cSDQCond  ///
										pos_SDQ_score pos_SDQPsoc pos_SDQPeer pos_SDQHype pos_SDQEmot pos_SDQCond /*LocusControl*/ pos_Depress 

global adol_outcome_C	          		IQ_factor IQ_score

global adol_outcome_N	          		pos_childSDQ_score pos_cSDQPsoc pos_cSDQPeer pos_cSDQHype pos_cSDQEmot pos_cSDQCond  ///
										pos_SDQ_score pos_SDQPsoc pos_SDQPeer pos_SDQHype pos_SDQEmot pos_SDQCond /*LocusControl*/ pos_Depress 					
										
global adol_outcome_S 					Friends cTalkOut cTalkSchool volunteer
								 
global adol_outcome_H            		BMI_obese BMI_overweight childHealthPerc childSickDays ///
										RiskSuspended 
								 
global adol_outcome_B           		diffInterest diffSit dropoutSchool likeSch_ado_pos MigrTaste Trust sport 
								 
* ----------------------------------------- *											
* Outcomes for each category: Adult Cohorts *
* ----------------------------------------- *								 
* Cognitive skills and education
global adult_outcome_M					IQ_factor highschoolGrad votoMaturita votoMaturita_std MaxEdu_Uni PA_Empl HrsTot mar_cohab BMI_obese ///
										BMI_overweight pos_LocusControl pos_Depress volunteer votedMunicipal votedRegional Friends Trust

global adult_outcome_E					IQ_factor IQ_score votoMaturita  ///
										highschoolGrad MaxEdu_Uni 

* Employment										
global adult_outcome_W					PA_Empl SES_self HrsTot ///
										Reddito_1 Reddito_2 Reddito_3 Reddito_4 Reddito_5 

* Living status										
global adult_outcome_L					mar_cohab mStatus_div childrenResp all_houseOwn live_parent

* Health									
global adult_outcome_H					Maria /*Smoke*/ Cig BMI BMI_obese BMI_overweight goodHealth HCondition9 SickDays ///
										/*i_RiskFight i_RiskDUI*/ RiskSuspended Drink1Age							

* Noncognitive										
global adult_outcome_N					pos_LocusControl pos_Depress Stress StressWork ///
										SatisIncome SatisWork SatisHealth SatisFamily ///
										optimist pos_reci neg_reci	

* Social										
global adult_outcome_S					MigrTaste Friends MigrFriend volunteer /*invFamMeal*/ votedMunicipal votedRegional 

* Religion
global adult_outcome_R					Faith


* Cognitive skills and education
global adult30_outcome_M					IQ_factor highschoolGrad votoMaturita votoMaturita_std MaxEdu_Uni PA_Empl HrsTot mar_cohab BMI_obese ///
											BMI_overweight pos_LocusControl pos_Depress volunteer votedMunicipal votedRegional Friends Trust

global adult30_outcome_E					IQ_factor votoMaturita  ///
											highschoolGrad MaxEdu_Uni 

* Employment										
global adult30_outcome_W					PA_Empl SES_self HrsTot ///
											Reddito_1 Reddito_2 Reddito_3 Reddito_4 Reddito_5 

* Living status										
global adult30_outcome_L					mar_cohab mStatus_div childrenResp all_houseOwn live_parent

* Health									
global adult30_outcome_H					Maria /*Smoke*/ Cig BMI BMI_obese BMI_overweight goodHealth HCondition9 SickDays ///
										    /*i_RiskFight i_RiskDUI*/ RiskSuspended Drink1Age							

* Noncognitive										
global adult30_outcome_N					pos_LocusControl pos_Depress Stress StressWork ///
											SatisIncome SatisWork SatisHealth SatisFamily ///
											optimist pos_reci neg_reci	

* Social										
global adult30_outcome_S					MigrTaste Friends MigrFriend volunteer /*invFamMeal*/ votedMunicipal votedRegional 

* Age-40
global adult40_outcome_M					IQ_factor highschoolGrad votoMaturita votoMaturita_std MaxEdu_Uni PA_Empl HrsTot mar_cohab BMI_obese ///
											BMI_overweight pos_LocusControl pos_Depress volunteer votedMunicipal votedRegional Friends Trust

global adult40_outcome_E					IQ_factor votoMaturita  ///
											highschoolGrad MaxEdu_Uni 

* Employment										
global adult40_outcome_W					PA_Empl SES_self HrsTot ///
											Reddito_1 Reddito_2 Reddito_3 Reddito_4 Reddito_5 

* Living status										
global adult40_outcome_L					mar_cohab mStatus_div childrenResp all_houseOwn live_parent

* Health									
global adult40_outcome_H					Maria /*Smoke*/ Cig BMI BMI_obese BMI_overweight goodHealth HCondition9 SickDays ///
										    /*i_RiskFight i_RiskDUI*/ RiskSuspended Drink1Age							

* Noncognitive										
global adult40_outcome_N					pos_LocusControl pos_Depress Stress StressWork ///
											SatisIncome SatisWork SatisHealth SatisFamily ///
											optimist pos_reci neg_reci	

* Social										
global adult40_outcome_S					MigrTaste Friends MigrFriend volunteer /*invFamMeal*/ votedMunicipal votedRegional 




* ------------------- *
* Label for variables * 
* ------------------- *

** Label for tables
global IQ_factor_lab 					IQ Factor
global IQ_score_lab						IQ Score
global votoMaturita_lab					High School Grade
global votoMaturita_std_lab				High School Grade (Standardized)
global votoUni_lab						University Grade
global highschoolGrad_lab				Graduate from High School
global MaxEdu_Uni_lab					Max Edu: University
global MaxEdu_Grad_lab					Max Edu: Graduate School

global PA_Empl_lab						Employed
global SES_self_lab						Self-Employed
global HrsTot_lab						Hours Worked Per Week
global WageMonth_lab					Monthly Wage
global Reddito_1_lab					Income: 5,000 Euros of Less
global Reddito_2_lab					Income: 5,001-10,000 Euros
global Reddito_3_lab					Income: 10,001-25,000 Euros
global Reddito_4_lab					Income: 25,001-50,000 Euros
global Reddito_5_lab					Income: 50,001-100,000 Euros
global Reddito_6_lab					Income: 100,001-250,000 Euros
global Reddito_7_lab					Income: More than 250,000 Euros

global mar_cohab_lab 					Married or Cohabitating
global childrenResp_lab					Num. of Children in House
global all_houseOwn_lab					Own House
global live_parent_lab					Live With Parents
global mStatus_div_lab					Divorced

global Maria_lab						Tried Marijuana
global Smoke_lab						Smokes
global Cig_lab							Num. of Cigarettes Per Day
global BMI_lab							BMI
global goodHealth_lab					Good Health
global SickDays_lab						Num. of Days Sick Past Month
global i_RiskDUI_lab					Drove Under Influence 
global i_RiskFight_lab					Engaged in A Fight 
global RiskSuspended_lab				Ever Suspended from School
global Drink1Age_lab					Age At First Drink
global BMI_obese_lab					Not Obese
global BMI_overweight_lab				Not Overweight
global HCondition9_lab					No Problematic Health Condition

global LocusControl_lab					Locus of Control
global Depression_score_lab				Depression Score

global pos_LocusControl_lab				Locus of Control - positive
global pos_Depress_lab					Depression Score - positive
global pos_Depression_lab				Depression Score - positive

global StressWork_lab					Work is Source of Stress
global Stress_lab						Stress

global SatisIncome_lab					Satisfied with Income
global SatisWork_lab					Satisfied with Work
global SatisHealth_lab 					Satisfied with Health 
global SatisFamily_lab					Satisfied with Family
global optimist_lab						Optimistic Look in Life
global reciprocity1_lab					Return Favor 
global reciprocity2_lab					Put Someone in Difficulty
global reciprocity3_lab					Help Someone Kind To Me
global reciprocity4_lab 				Insult Back
global pos_reci_lab						Positive Reciprocity
global neg_reci_lab						Negative Reciprocity

global MigrTaste_lab					Favorable to Migrants
global Friends_lab						Number of Friends
global childFriends_lab					Number of Friends
global MigrFriend_lab					Has Migrant Friends
global volunteer_lab					Volunteers
global invFamMeal_lab					Child Eats Meal with Fam
global childinvFamMeal_lab				Child Eats Meal with Fam
global votedMunicipal_lab				Ever Voted for Municipal
global votedRegional_lab				Ever Voted for Regional
global votedNational_lab				Ever Voted for National

global pos_SDQ_score_lab				SDQ Composite
global pos_SDQEmot_lab					SDQ Emotional
global pos_SDQCond_lab					SDQ Conduct
global pos_SDQHype_lab					SDQ Hyper
global pos_SDQPeer_lab					SDQ Peer problems
global pos_SDQPsoc_lab					SDQ Pro-social
global SDQPsoc_score_lab				SDQ Pro-social

global pos_childSDQ_score_lab			SDQ Composite - Child
global pos_cSDQEmot_lab					SDQ Emotional - Child
global pos_cSDQCond_lab					SDQ Conduct - Child
global pos_cSDQHype_lab					SDQ Hyper - Child
global pos_cSDQPeer_lab					SDQ Peer problems - Child
global pos_cSDQPsoc_lab					SDQ Pro-social - Child
global childSDQPsoc_score_lab			SDQ Pro-social - Child

global distAsiloMunicipal1_lab			Closest Municipal Asilo
global distAsiloMunicipal2_lab			2nd-closest Municipal Asilo
global distAsiloPrivate1_lab			Closest Private Asilo
global distAsiloPrivate2_lab			2nd-closest Private Asilo
global distAsiloReligious1_lab			Closest Religious Asilo
global distAsiloReligious2_lab			2nd-closest Religious Asilo

global distMaternaMunicipal1_lab		Closest Municipal Materna
global distMaternaMunicipal2_lab		2nd-closest Municipal Materna
global distMaternaState1_lab			Closest State Materna
global distMaternaState2_lab			2nd-closest State Materna
global distMaternaPrivate1_lab			Closest Private Materna
global distMaternaPrivate2_lab			2nd-closest Private Materna
global distMaternaReligious1_lab		Closest Religious Materna
global distMaternaReligious2_lab		2nd-closest Religious Materna					

global childinvFriends_lab 				Num. of Friends
global childinvMusic_lab 				Musical Instrument at Home
global childinvReadTo_lab 				Frequency Reading To Child
global worryHome_lab 					Tell Worry at Home
global worryTeacher_lab 				Tell Worry to Teacher
global worryFriend_lab 					Tell Worry to Friends
global worryMyself_lab 					Keep Worry to Myself	
global childHealthPerc_lab 				Health is Good
global childSickDays_lab 				Number of Sick Days
global diffInterest_lab 				Not Excited to Learn
global diffSit_lab 						Problems Sitting Still
global likeSch_child_pos_lab 			How Much Child Likes School
global faceGeneral_lab 					Happy in General
global childFriends_lab					Num. of Friends
global Friends_lab						Num. of Friends
global cTalkOut_lab 					Doesn't Talk About Activities
global cTalkSchool_lab 					Doesn't Talk About School
global sport_lab 						Days of Sport (Weekly)
global dropoutSchool_lab 				Go To School
global likeSch_ado_pos_lab 				How Much Child Likes School
global MigrTaste_lab 					Bothered by Migrants
global Trust_lab						Trust Score
global candyGame_bin_lab				Candy Game: Willing to Share Candies

global Male_lab							Male
global Cohort_Migrants_lab 				Is a migrant
global lowbirthweight_lab 				Low birthweight
global birthpremature_lab 				Premature birth
global CAPI_lab 						CAPI
global teenMomBirth_lab 				Born to teenaged mother
global momBornProvince_lab 				Mom born in province
global momMaxEdu_low_lab 				Mom Max Edu: Low
global momMaxEdu_middle_lab 			Mom Max Edu: Middle School
global momMaxEdu_HS_lab 				Mom Max Edu: High School
global momMaxEdu_Uni_lab 				Mom Max Edu: University
global teenDadBirth_lab 				Born to teenaged father
global dadBornProvince_lab 				Father born in province
global dadMaxEdu_low_lab 				Dad Max Edu: Low
global dadMaxEdu_middle_lab 			Dad Max Edu: Middle School
global dadMaxEdu_HS_lab 				Dad Max Edu: High School
global dadMaxEdu_Uni_lab 				Dad Max Edu: University
global numSibling_1_lab 				Has 1 sibling
global numSibling_2_lab 				Has 2 siblings
global numSibling_more_lab 				Has more than 2 siblings
global cgCatholic_lab 					Caregiver was Catholic
global int_cgCatFaith_lab 				Caregiver was faithful and Catholic
global houseOwn_lab 					Caregiver owned house
global cgMigrant_lab 					Caregiver was a migrant
global cgReddito_1_lab 					Caregiver Income: 5,000 euros or less
global cgReddito_2_lab 					Caregiver Income: 5,001-10,000 euros
global cgReddito_3_lab 					Caregiver Income: 10,001-25,000 euros
global cgReddito_4_lab 					Caregiver Income: 25,001-50,000 euros
global cgReddito_5_lab 					Caregiver Income: 50,001-100,000 euros
global cgReddito_6_lab 					Caregiver Income: 100,001-250,000 euros
global cgReddito_7_lab 					Caregiver Income: > 250,000 euros
global cgRelig_lab						Caregiver was religious
global momBornProvince_lab				Mom born in province
global dadBornProvince_lab 				Dad born in province


								
