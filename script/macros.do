* ---------------------------------------------------------------------------- *
* Globals and locals for Reggio analysis
* Authors: Reggio Team
* Edited: 2016/08/23
* ---------------------------------------------------------------------------- * 

* --------- *
* Directory *
* --------- *
global klmReggio   : env klmReggio
global data_reggio : env data_reggio
global git_reggio  : env git_reggio
global current 	"${git_reggio}/script"
global output	"${current}/../output"


* -------------- *
* Classification *
* -------------- *
global cohorts					Child Migrant Adolescent Adult30 Adult40 Adult50
global cities					Reggio Parma Padova
global schools					Municipal State Religious Private None
	
* ------------------ *
* Baseline variables *
* ------------------ *
global child_baseline_vars  		Male Cohort_Migrants lowbirthweight birthpremature CAPI ///
								teenMomBirth momBornProvince ///
								momMaxEdu_low momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni  ///
								teenDadBirth dadBornProvince ///
								dadMaxEdu_low dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni  ///
								numSibling_1 numSibling_2 numSibling_more cgCatholic int_cgCatFaith houseOwn cgMigrant ///
								cgReddito_1 cgReddito_2 cgReddito_3 cgReddito_4 cgReddito_5 cgReddito_6 cgReddito_7 ///
								momWork_fulltime06 momWork_parttime06 momSchool06  
								// We assume that household income abd family house ownership for children cohorts can be considered as "baseline"
								
global adol_baseline_vars  		Male lowbirthweight birthpremature CAPI ///
								teenMomBirth momBornProvince ///
								momMaxEdu_low momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni  ///
								teenDadBirth dadBornProvince ///
								dadMaxEdu_low dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni  ///
								numSibling_1 numSibling_2 numSibling_more cgCatholic int_cgCatFaith cgMigrant ///
								momWork_fulltime06 momWork_parttime06 momSchool06		 						
								
								
global adult_baseline_vars		Male CAPI ///
								momBornProvince ///
								momMaxEdu_low momMaxEdu_middle momMaxEdu_HS momMaxEdu_Uni  ///
								dadBornProvince  ///
								dadMaxEdu_low dadMaxEdu_middle dadMaxEdu_HS dadMaxEdu_Uni  ///
								numSibling_1 numSibling_2 numSibling_more cgRelig ///
								momWork_fulltime06 momWork_parttime06 momSchool06
								
								
global Child_baseline_vars				$child_baseline_vars							
global Migrant_baseline_vars			$child_baseline_vars yrCity ageCity
global Adolescent_baseline_vars			$adol_baseline_vars
global Adult30_baseline_vars 			$adult_baseline_vars
global Adult40_baseline_vars 			$adult_baseline_vars
global Adult50_baseline_vars		 	$adult_baseline_vars

								
* BIC-selected baseline variables 
global bic_child_baseline_vars				Male CAPI Cohort_Migrants numSibling_more houseOwn cgMigrant cgReddito_7
global bic_adol_baseline_vars				Male CAPI momMaxEdu_low dadMaxEdu_Uni numSibling_2 cgCatholic
global bic_adult_baseline_vars		    	Male CAPI momMaxEdu_middle dadMaxEdu_Uni numSibling_2 numSibling_more


* ------------------------------------------- *											
* Outcomes for each category: Younger Cohorts *
* ------------------------------------------- *
global child_outcome_CN         		IQ_factor IQ_score ///
										pos_childSDQ_score pos_childSDQPsoc_score pos_childSDQPeer_score pos_childSDQHype_score pos_childSDQEmot_score pos_childSDQCond_score 
								 
global child_outcome_S	 		 		childinvFriends childinvMusic  ///
										worryHome worryTeacher worryFriend worryMyself 
								 
global child_outcome_H 			 		BMI_obese BMI_overweight childHealthPerc childSickDays 

global child_outcome_B			 		difficultiesInterest difficultiesSit likeSchool_child_pos faceGeneral 
                                 
                                   
global adol_outcome_CN          		IQ_factor IQ_score ///
										pos_childSDQ_score pos_childSDQPsoc_score pos_childSDQPeer_score pos_childSDQHype_score pos_childSDQEmot_score pos_childSDQCond_score ///
										pos_SDQ_score pos_SDQPsoc_score pos_SDQPeer_score pos_SDQHype_score pos_SDQEmot_score pos_SDQCond_score LocusControl pos_Depression_score 

global adol_outcome_S 					Friends childinvTalkOut childinvTalkSchool
								 
global adol_outcome_H            		BMI_obese BMI_overweight childHealthPerc childSickDays ///
										RiskSuspended Cig 
								 
global adol_outcome_B           		difficultiesInterest difficultiesSit dropoutSchool likeSchool_ado_pos MigrTaste_cat Trust sport 
								 
* ----------------------------------------- *											
* Outcomes for each category: Adult Cohorts *
* ----------------------------------------- *								 
* Cognitive skills and education
global adult_outcome_E					IQ_factor votoMaturita votoUni ///
										highschoolGrad MaxEdu_Uni MaxEdu_Grad

* Employment										
global adult_outcome_W					PA_Empl SES_self HrsTot WageMonth ///
										Reddito_1 Reddito_2 Reddito_3 Reddito_4 Reddito_5 Reddito_6 Reddito_7

* Living status										
global adult_outcome_L					mStatus_married_cohab mStatus_div childrenResp all_houseOwn live_parent

* Health									
global adult_outcome_H					Maria /*Smoke*/ Cig BMI BMI_obese BMI_overweight goodHealth SickDays ///
										/*i_RiskFight i_RiskDUI*/ RiskSuspended Drink1Age							

* Noncognitive										
global adult_outcome_N					pos_LocusControl pos_Depression_score Stress StressWork ///
										SatisIncome SatisWork SatisHealth SatisFamily ///
										optimist reciprocity1 reciprocity2 reciprocity3 reciprocity4	

* Social										
global adult_outcome_S					MigrTaste Friends MigrFriend volunteer invFamMeal childinvFamMeal ///
										votedMunicipal votedRegional votedNational

* Religion
global adult_outcome_R					Faith


* ------------------- *
* Label for variables * 
* ------------------- *

** Label for tables
global IQ_factor_lab 					IQ Factor
global IQ_score_lab						IQ Score
global votoMaturita_lab					High School Grade
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

global mStatus_married_cohab_lab 		Married or Cohabitating
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
global BMI_obese_lab					Obese
global BMI_overweight_lab				Overweight

global LocusControl_lab					Locus of Control
global Depression_score_lab				Depression Score

global pos_LocusControl_lab				Locus of Control - positive
global pos_Depression_score_lab			Depression Score - positive

global StressWork_lab					Work is Source of Stress

global SatisIncome_lab					Satisfied with Income
global SatisWork_lab					Satisfied with Work
global SatisHealth_lab 					Satisfied with Health 
global SatisFamily_lab					Satisfied with Family
global optimist_lab						Optimistic Look in Life
global reciprocity1_lab					Return Favor 
global reciprocity2_lab					Put Someone in Difficulty
global reciprocity3_lab					Help Someone Kind To Me
global reciprocity4_lab 				Insult Back

global MigrTaste_lab					Favorable to Migrants
global Friends_lab						Number of Friends
global MigrFriend_lab					Has Migrant Friends
global volunteer_lab					Volunteers
global invFamMeal_lab					Child Eats Meal with Fam
global votedMunicipal_lab				Ever Voted for Municipal
global votedRegional_lab				Ever Voted for Regional
global votedNational_lab				Ever Voted for National

global pos_SDQ_score_lab				SDQ Composite
global pos_SDQEmot_score_lab			SDQ Emotional
global pos_SDQCond_score_lab			SDQ Conduct
global pos_SDQHype_score_lab			SDQ Hyper
global pos_SDQPeer_score_lab			SDQ Peer problems
global pos_SDQPsoc_score_lab			SDQ Pro-social

global pos_childSDQ_score_lab			SDQ Composite - Child
global pos_childSDQEmot_score_lab		SDQ Emotional - Child
global pos_childSDQCond_score_lab		SDQ Conduct - Child
global pos_childSDQHype_score_lab		SDQ Hyper - Child
global pos_childSDQPeer_score_lab		SDQ Peer problems - Child
global pos_childSDQPsoc_score_lab		SDQ Pro-social - Child

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
global difficultiesInterest_lab 		Not Excited to Learn
global difficultiesSit_lab 				Problems Sitting Still
global likeSchool_child_pos_lab 		How Much Child Likes School
global faceGeneral_lab 					Happy in General
global Friends_lab						Num. of Friends
global childinvTalkOut_lab 				Doesn't Talk About Activities
global childinvTalkSchool_lab 			Doesn't Talk About School
global sport_lab 						Days of Sport (Weekly)
global dropoutSchool_lab 				Go To School
global likeSchool_ado_pos_lab 			How Much Child Likes School
global MigrTaste_cat_lab 				Bothered by Migrants
global Trust_lab						Trust Score
