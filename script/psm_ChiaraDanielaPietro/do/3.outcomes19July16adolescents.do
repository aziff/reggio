clear all
set more off
capture log close

********************************************************************************
*** COHORT 
//global dir "C:\Users\Pronzato\Dropbox\ReggioChildren"
global dir "C:\Users\pbiroli\Dropbox\ReggioChildren"
//global dir "/mnt/Data/Dropbox/ReggioChildren"


use "$dir/SURVEY_DATA_COLLECTION/data/Reggio.dta", clear

*** only 1994

keep if Cohort == 3
count

/* TUTTI GLI OUTCOMES 
*** desc sum & drop

log using "$dir/Analysis/chiara&daniela/do/listvariables adolescents 19July16.smcl", replace

desc
sum

log close


*** DIFFICULTIES (5)

difficultiesSit byte    %8.0g      LABU       Ability to sit still in a group when asked (difficulties in primary school)
difficultiesI~t byte    %8.0g      LABU       Lack of excitement to learn (difficulties in primary school)
difficultiesO~y byte    %8.0g      LABU       Ability to obey rules and directions (difficulties in primary school)
difficultiesEat byte    %8.0g      LABU       Fussy eater (difficulties in primary school)
difficulties    byte    %55.0g     difficulties

                                              dv: Difficulties encountered when starting primary schoo											  												
*** EXTRA ACTIVITIES (1) 
											
childinvFriends byte    %10.0g              * Do you know who his/her friends are?

*** S&D (31)

childSDQPsoc1   byte    %8.0g      V56010_1   Considerate of other people's feelings
childSDQHype1   byte    %8.0g      V56010_2 * Restless, overactive, cannot stay still for long
childSDQEmot1   byte    %8.0g      V56010_3 * Often complains of headaches, stomach-aches or sickness
childSDQPsoc2   byte    %8.0g      V56010_4 * Shares readily with other children, for example toys, treats, pencils
childSDQCond1   byte    %8.0g      V56010_5   Often loses temper or is in a bad mood
childSDQPeer1   byte    %8.0g      V56010_6   Rather solitary, prefers to play alone
childSDQCond2   byte    %8.0g      V56010_7 * Generally well behaved, usually does what adults request
childSDQEmot2   byte    %8.0g      V56010_8   Frequently worried or often seems worried
childSDQPsoc3   byte    %8.0g      V56010_9 * Helpful if someone is hurt, upset or feeling ill
childSDQHype2   byte    %8.0g      V530_A     Constantly fidgeting or squirming
childSDQPeer2   byte    %8.0g      V531_A     Has at least one good friend
childSDQCond3   byte    %8.0g      V532_A   * Often fights with other children or bullies them
childSDQEmot3   byte    %8.0g      V533_A     Often unhappy, depressed or tearful
childSDQPeer3   byte    %8.0g      V534_A     Generally liked by other children
childSDQHype3   byte    %8.0g      V535_A     Easily distracted, concentration wanders
childSDQEmot4   byte    %8.0g      V536_A   * Nervous or clingy in new situations, easily loses confidence
childSDQPsoc4   byte    %8.0g      V537_A     Kind to younger children
childSDQCond4   byte    %8.0g      V538_A     Often lies or cheats
childSDQPeer4   byte    %8.0g      V539_A     Picked on or bullied by other children
childSDQPsoc5   byte    %8.0g      V540_A   * Often offers to help others (parents, teachers, other children)
childSDQHype4   byte    %8.0g      V541_A     Thinks things out before acting
childSDQCond5   byte    %8.0g      V542_A   * Steals from home, school or elsewhere
childSDQPeer5   byte    %8.0g      V543_A     Gets along better with adults than with other children
childSDQEmot5   byte    %8.0g      V544_A     Many fears, easily scared
childSDQHype5   byte    %8.0g      V545_A   * Good attention span, sees work through to the end

childSDQEmot_~e byte    %9.0g                 SDQ emotional symptoms score - Mother reports
childSDQCond_~e byte    %9.0g                 SDQ conduct problems score - Mother reports
childSDQHype_~e byte    %9.0g                 SDQ hyperactivity/inattention score - Mother reports
childSDQPeer_~e byte    %9.0g                 SDQ peer problems score - Mother reports
childSDQPsoc_~e byte    %9.0g                 SDQ prosocial score - Mother reports
childSDQ_score  byte    %9.0g                 SDQ Total difficulties score - Mother reports

*** HEALTH AND HABITS (26)

childHealth     byte    %8.0g      V38110     Child general health (high = sick) - Mother reports
childSickDays   byte    %8.0g      V38120   * Child number of sick days
childSleep      byte    %10.0g                On average, how many hours do you sleep a night? CHILD
childHeight     int     %10.0g                Child Height
childWeight     int     %10.0g                Child Weight
childDoctor     byte    %8.0g      V38150   * How long has it been since your child last visited a doctor or dentist for a
                                                rou
childAsthma_d~g byte    %8.0g      LABW       asthma (has your child ever been diagnosed with...)
childAllerg_d~g byte    %8.0g      LABW       allergies (has your child ever been diagnosed with...)
childDigest_d~g byte    %8.0g      LABW       digestive problems (has your child ever been diagnosed with...)
childEmot_diag  byte    %8.0g      LABW       emotional problems (has your child ever been diagnosed with...)
childSleep_diag byte    %8.0g      LABW       sleeping problems (has your child ever been diagnosed with...)
childGums_diag  byte    %8.0g      LABW     * gum disease (gingivitis; periodontal disease) or tooth loss because of
                                                cavities
childOther_diag byte    %8.0g      LABW       other (e.g.cancer, leukemia, diabetes, etc.) (has your child ever been
                                                diagnosed
childNone_diag  byte    %8.0g      LABW       none of these (has your child ever been diagnosed with...)

childBreakfast  byte    %8.0g      V40120_2 * In a typical week, how many times do you have breakfast? CHILD
childFruit      byte    %8.0g      V56130_2 * Frequency eating fruit, child
childSnackNo    byte    %8.0g      LABY       Never Snack (usually eat as snack, child)
childSnackFruit byte    %8.0g      LABY       Eat fruit as snack, child
childSnackIce   byte    %8.0g      LABY       Ice cream (usually eat as snack, child)
childSnackCandy byte    %8.0g      LABY       Candies, sweets, chocolate bars (usually eat as snack, child)
childSnackRoll  byte    %8.0g      LABY       Cookies, roll cakes, baked goods (usually eat as snack, child)
childSnackChips byte    %8.0g      LABY       Chips, crackers (usually eat as snack, child)
childSnackOther byte    %8.0g      LABY       Other (specify_________) (usually eat as snack, child)
sportTogether   byte    %8.0g      V41150   * Frequencty done sport together (high = a lot)
childBMI        float   %9.0g                 BMI child
childTotal_diag byte    %9.0g                 Total number of diagnosed health problems, child
                                                child												

*** COGNITIVE (14)

IQ1             byte    %9.0g                 
IQ2             byte    %9.0g                 
IQ3             byte    %9.0g                 
IQ4             byte    %9.0g                 
IQ5             byte    %9.0g                 
IQ6             byte    %9.0g                 
IQ7             byte    %9.0g                 
IQ8             byte    %9.0g                 
IQ9             byte    %9.0g                 
IQ10            byte    %9.0g                 
IQ11            byte    %9.0g                 
IQ12            byte    %9.0g                 
                 
IQ_factor       float   %9.0g                 dv: Respondent mental ability. Raven matrices - factor score
IQ_score        float   %9.0g                 Respondent mental ability. % of correct answers (Raven matrices)

*** ALTRE

desc childinvOutWho childinvOutWhen childinvOutWhere childinvTalkSchool
sum childinvOutWho childinvOutWhen childinvOutWhere childinvTalkSchool
tab1 childinvOutWho childinvOutWhen childinvOutWhere childinvTalkSchool

desc childinvTalkOut childinvTalkmom childinvTalkdad  childinvFriendsMeet childinvFriendsGender
sum  childinvTalkOut childinvTalkdad childinvTalkmom childinvFriendsGender childinvFriendsMeet
tab1  childinvTalkOut childinvTalkdad childinvTalkmom childinvFriendsGender childinvFriendsMeet

desc childinvPeerpres likeSchool_ado likeMath_ado likeItal likeScience likeLang childinvSex dropoutSchool
sum childinvPeerpres likeSchool_ado likeMath_ado likeItal likeScience likeLang childinvSex dropoutSchool
tab1 childinvPeerpres likeSchool_ado likeMath_ado likeItal likeScience likeLang childinvSex dropoutSchool

tab1 impSchool uniGoProb  
tab1 Health Breakfast Fruit 
tab1 SnackFruit SnackIce  goSchoolbus goSchoolfoot goSchoolbike  takeCareOth volunteer club facebookSocNet  discrNo  
tab1 SnackCandy SnackRoll SnackChips goSchoolCar goSchoolmoto
tab1 MigrFriend MigrMeetNo 
tab1 optimist optimist2 SextalkMom SextalkDad SextalkSib SextalkRelative SextalkGirl SextalkBoy SextalkOther
tab1 pessimist pessimist2 single  SextalkNo SmokeEver Smoke Maria Drink RiskSuspended 
  
* OK sport Friends TimeUseless Stress MigrProgram MigrTaste MigrGood closeMom closeDad Locus3 reciprocity1 reciprocity3 SatisHealth SatisSchool
* OK SatisFamily Depress05 Depress08 Smoke1Age Drink1Age ProbMarry25 ProbGrad ProbRich ProbLive80 ProbBabies Trust2 Trust3 Trust
* DC PC_hrs videoG_hrs TV_hrs screen_hrs Weight SocialMeet TimeSelf TimeParent TimeRelat TimeStudy TimeFriend TimeFree TimeRest
* DC MigrIntegr MigrAttitude Locus1 Locus2 reciprocity2 reciprocity4 Depress01 Depress02 Depress03 Depress04 Depress06 Depress07
* DC Depress09 Depress10 Depression Cig DrinkNum RiskLie RiskDanger RiskSkip RiskRob RiskFight RiskNota RiskPirate RiskDUI Trust1
 
 */
 
*** qui butto i _bin

ren MigrClassIntegr_bin MigrClassIntegr_binn
drop *_bin
ren  MigrClassIntegr_binn MigrClassIntegr_bin
     
*** 1) dummy dal verso giusto 

gen BMI_cat_bin = (BMI_cat == 1)

sum childNone_diag childSnackFruit childSnackIce IQ1 IQ2 IQ3 IQ4 IQ5 IQ6 IQ7 IQ8 IQ9 IQ10 IQ11 IQ12 ///
childinvSex dropoutSchool SnackFruit SnackIce  goSchoolbus goSchoolfoot goSchoolbike  takeCareOth volunteer club facebookSocNet  discrNo ///
MigrFriend optimist optimist2 SextalkMom SextalkDad SextalkSib SextalkRelative SextalkGirl SextalkBoy SextalkOther MigrClassIntegr_bin BMI_cat_bin Satisfied

desc childNone_diag childSnackFruit childSnackIce IQ1 IQ2 IQ3 IQ4 IQ5 IQ6 IQ7 IQ8 IQ9 IQ10 IQ11 IQ12 ///
childinvSex dropoutSchool SnackFruit SnackIce  goSchoolbus goSchoolfoot goSchoolbike  takeCareOth volunteer club facebookSocNet  discrNo ///
MigrFriend optimist optimist2 SextalkMom SextalkDad SextalkSib SextalkRelative SextalkGirl SextalkBoy SextalkOther MigrClassIntegr_bin BMI_cat_bin Satisfied

*** 2) dummy to be flipped
local varFlip difficultiesSit difficultiesInterest difficultiesObey difficultiesEat ///
childAsthma_diag childAllerg_diag childDigest_diag childEmot_diag childSleep_diag childGums_diag childOther_diag childSnackNo childSnackCan childSnackRoll  ///
childSnackChips childSnackOther  SnackCandy SnackRoll SnackChips goSchoolCar goSchoolmoto MigrMeetNo ///
pessimist pessimist2 single  SextalkNo SmokeEver Smoke Maria Drink RiskSuspended

sum `varFlip'
desc `varFlip'
foreach j in `varFlip'{
   replace `j'= 1-`j'
   label var `j' "`varFlip' flipped"
} 

sum difficultiesSit difficultiesInterest difficultiesObey difficultiesEat ///
childAsthma_* childAllerg_* childDigest_* childEmot_diag childSleep_diag childGums_diag childOther_diag childSnackNo childSnackCan childSnackRoll  ///
childSnackChips childSnackOther SnackCandy SnackRoll SnackChips goSchoolCar goSchoolmoto MigrMeetNo ///
pessimist pessimist2 single  SextalkNo SmokeEver Smoke Maria Drink RiskSuspended

*** 3) dummy to be created 
local varCreate childSleep childHeight childBreakfast childFruit sportTogether ///
IQ_score IQ_factor childSDQHype1 childSDQHype2 childSDQHype3 childSDQEmot1 childSDQEmot2 ///
childSDQEmot3 childSDQEmot4 childSDQEmot5 childSDQCond1 childSDQCond3 childSDQCond4 childSDQCond5 childSDQPeer1 childSDQPeer4 childSDQPeer5 ///
childinvTalkdad  childinvFriendsMeet ///
sport Friends TimeUseless Stress MigrProgram MigrTaste MigrGood closeMom closeDad Locus3 reciprocity1 reciprocity3 SatisHealth SatisSchool ///
SatisFamily Depress05 Depress08 Smoke1Age Drink1Age ProbMarry25 ProbGrad ProbRich ProbLive80 ProbBabies Trust2 Trust3 Trust

sum  `varCreate'
desc `varCreate'

tab childinvFriendsGender
tab childinvFriendsGender, nol
gen childinvFriendsGender_bin = (childinvFriendsGender == 0) if(childinvFriendsGender < .)

replace Smoke1Age = 999 if (Smoke1Age == .)
replace Drink1Age = 999 if(Drink1Age == .)

foreach j of varlist `varCreate' {

sum `j', d
gen dummy1 = (`j' > r(p50))
gen dummy2 = (`j' >= r(p50))
replace dummy1 = . if(`j' == .)
replace dummy2 = . if(`j' == .)
sum dummy1
gen diff1 = abs(r(mean)-0.5)
sum dummy2
gen diff2 = abs(r(mean)-0.5)
gen `j'_bin = dummy1 if(diff1 <= diff2)
replace `j'_bin = dummy2 if(diff1 > diff2)
drop dummy1 dummy2 diff1 diff2

} 

sum  childSleep_bin childHeight_bin childBreakfast_bin childFruit_bin sportTogether_bin ///
IQ_score_bin IQ_factor_bin childSDQHype1_bin childSDQHype2_bin childSDQHype3_bin childSDQEmot1_bin childSDQEmot2_bin ///
childSDQEmot3_bin childSDQEmot4_bin childSDQEmot5_bin childSDQCond1_bin childSDQCond3_bin childSDQCond4_bin childSDQCond5_bin childSDQPeer1_bin childSDQPeer4_bin childSDQPeer5_bin ///
childinvTalkdad_bin  childinvFriendsMeet_bin childinvFriendsGender_bin ///
sport_bin Friends_bin TimeUseless_bin Stress_bin MigrProgram_bin MigrTaste_bin MigrGood_bin closeMom_bin closeDad_bin Locus3_bin reciprocity1_bin reciprocity3_bin SatisHealth_bin SatisSchool_bin ///
SatisFamily_bin Depress05_bin Depress08_bin Smoke1Age_bin Drink1Age_bin ProbMarry25_bin ProbGrad_bin ProbRich_bin ProbLive80_bin ProbBabies_bin Trust2_bin Trust3_bin Trust_bin

*** dummy da creare e capovolgere
pwcorr childSDQ_score childSDQ_factor SDQ_score SDQ_factor 

local varCreflip childinvFriends difficulties childinvTV_hrs childinvVideoG_hrs childHealth childSickDays childWeight childDoctor childBMI childTotal_diag ///
likeRead likeMath_child likeGym goodBoySchool likeTV likeDraw likeSport lendFriend favorReturn funFamily ///
childinvCom  childinvOut ///
childSDQPsoc1 childSDQPsoc2 childSDQPsoc3 childSDQPsoc4 childSDQPsoc5 ///
childSDQHype4 childSDQHype5 childSDQCond2 childSDQPeer2 childSDQPeer3 ///
childSDQ????_score childSDQ_score childSDQ_factor SDQ_score SDQ_factor ///
childinvOutWho childinvOutWhen childinvOutWhere childinvTalkSchool childinvTalkOut childinvTalkmom ///
childinvPeerpres likeSchool_ado likeMath_ado likeItal likeScience likeLang impSchool uniGoProb Health Breakfast Fruit ///
PC_hrs videoG_hrs TV_hrs screen_hrs Weight SocialMeet TimeSelf TimeParent TimeRelat TimeStudy TimeFriend TimeFree TimeRest ///
MigrIntegr MigrAttitude Locus1 Locus2 Locus4 LocusControl reciprocity2 reciprocity4 Depress01 Depress02 Depress03 Depress04 Depress06 Depress07 ///
Depress09 Depress10 Depression Cig DrinkNum RiskLie RiskDanger RiskSkip RiskRob RiskFight RiskNota RiskPirate RiskDUI Trust1

des `varCreflip'
sum `varCreflip'

replace Cig = -999 if(Cig == .)
replace DrinkNum = -999 if(DrinkNum == .)

foreach j of varlist `varCreflip' {

sum `j', d
gen dummy1 = (`j' > r(p50))
gen dummy2 = (`j' >= r(p50))
replace dummy1 = . if(`j' == .)
replace dummy2 = . if(`j' == .)
sum dummy1
gen diff1 = abs(r(mean)-0.5)
sum dummy2
gen diff2 = abs(r(mean)-0.5)
gen `j'_bin = dummy1 if(diff1 <= diff2)
replace `j'_bin = dummy2 if(diff1 > diff2)
drop dummy1 dummy2 diff1 diff2
replace `j'_bin= 1-`j'_bin
} 

sum difficulties_bin childHealth_bin childSickDays_bin childWeight_bin childDoctor_bin childBMI_bin childTotal_diag_bin ///
childSDQPsoc1_bin childSDQPsoc2_bin childSDQPsoc3_bin childSDQPsoc4_bin childSDQPsoc5_bin ///
childSDQHype4_bin childSDQHype5_bin childSDQCond2_bin childSDQPeer2_bin childSDQPeer3_bin childSDQ*score_bin ///
childinvOutWho_bin childinvOutWhen_bin childinvOutWhere_bin childinvTalkSchool_bin childinvTalkOut_bin childinvTalkmom_bin ///
childinvPeerpres_bin likeSchool_ado_bin likeMath_ado_bin likeItal_bin likeScience_bin likeLang_bin impSchool_bin uniGoProb_bin Health_bin Breakfast_bin Fruit_bin ///
PC_hrs_bin videoG_hrs_bin TV_hrs_bin screen_hrs_bin Weight_bin SocialMeet_bin TimeSelf_bin TimeParent_bin TimeRelat_bin TimeStudy_bin TimeFriend_bin TimeFree_bin TimeRest_bin ///
MigrIntegr_bin MigrAttitude_bin Locus1_bin Locus2_bin Locus4_bin LocusControl_bin reciprocity2_bin reciprocity4_bin Depress01_bin Depress02_bin Depress03_bin Depress04_bin Depress06_bin Depress07_bin ///
Depress09_bin Depress10_bin Depression_bin Cig_bin DrinkNum_bin RiskLie_bin RiskDanger_bin RiskSkip_bin RiskRob_bin RiskFight_bin RiskNota_bin RiskPirate_bin RiskDUI_bin Trust1_bin

*** elenco completo

sum childNone_diag childSnackFruit childSnackIce IQ1 IQ2 IQ3 IQ4 IQ5 IQ6 IQ7 IQ8 IQ9 IQ10 IQ11 IQ12 ///
childinvSex dropoutSchool SnackFruit SnackIce  goSchoolbus goSchoolfoot goSchoolbike  takeCareOth volunteer club facebookSocNet  discrNo ///
MigrFriend optimist optimist2 SextalkMom SextalkDad SextalkSib SextalkRelative SextalkGirl SextalkBoy SextalkOther MigrClassIntegr_bin BMI_cat_bin ///
difficultiesSit difficultiesInterest difficultiesObey difficultiesEat ///
childAsthma_* childAllerg_* childDigest_* childEmot_diag childSleep_diag childGums_diag childOther_diag childSnackNo childSnackCan childSnackRoll  ///
childSnackChips childSnackOther SnackCandy SnackRoll SnackChips goSchoolCar goSchoolmoto MigrMeetNo ///
pessimist pessimist2 single  SextalkNo SmokeEver Smoke Maria Drink RiskSuspended ///
childinvFriends_bin ///
childSleep_bin childHeight_bin childBreakfast_bin childFruit_bin sportTogether_bin ///
IQ_score_bin IQ_factor_bin childSDQHype1_bin childSDQHype2_bin childSDQHype3_bin childSDQEmot1_bin childSDQEmot2_bin ///
childSDQEmot3_bin childSDQEmot4_bin childSDQEmot5_bin childSDQCond1_bin childSDQCond3_bin childSDQCond4_bin childSDQCond5_bin childSDQPeer1_bin childSDQPeer4_bin childSDQPeer5_bin ///
childinvTalkdad_bin  childinvFriendsMeet_bin childinvFriendsGender_bin ///
sport_bin Friends_bin TimeUseless_bin Stress_bin MigrProgram_bin MigrTaste_bin MigrGood_bin closeMom_bin closeDad_bin Locus3_bin reciprocity1_bin reciprocity3_bin SatisHealth_bin SatisSchool_bin ///
SatisFamily_bin Depress05_bin Depress08_bin Smoke1Age_bin Drink1Age_bin ProbMarry25_bin ProbGrad_bin ProbRich_bin ProbLive80_bin ProbBabies_bin Trust2_bin Trust3_bin Trust_bin ///
difficulties_bin childHealth_bin childSickDays_bin childWeight_bin childDoctor_bin childBMI_bin childTotal_diag_bin ///
childSDQPsoc1_bin childSDQPsoc2_bin childSDQPsoc3_bin childSDQPsoc4_bin childSDQPsoc5_bin ///
childSDQHype4_bin childSDQHype5_bin childSDQCond2_bin childSDQPeer2_bin childSDQPeer3_bin childSDQ*score_bin ///
childinvOutWho_bin childinvOutWhen_bin childinvOutWhere_bin childinvTalkSchool_bin childinvTalkOut_bin childinvTalkmom_bin ///
childinvPeerpres_bin likeSchool_ado_bin likeMath_ado_bin likeItal_bin likeScience_bin likeLang_bin impSchool_bin uniGoProb_bin Health_bin Breakfast_bin Fruit_bin ///
PC_hrs_bin videoG_hrs_bin TV_hrs_bin screen_hrs_bin Weight_bin SocialMeet_bin TimeSelf_bin TimeParent_bin TimeRelat_bin TimeStudy_bin TimeFriend_bin TimeFree_bin TimeRest_bin ///
MigrIntegr_bin MigrAttitude_bin Locus1_bin Locus2_bin Locus4_bin LocusControl_bin reciprocity2_bin reciprocity4_bin Depress01_bin Depress02_bin Depress03_bin Depress04_bin Depress06_bin Depress07_bin ///
Depress09_bin Depress10_bin Depression_bin Cig_bin DrinkNum_bin RiskLie_bin RiskDanger_bin RiskSkip_bin RiskRob_bin RiskFight_bin RiskNota_bin RiskPirate_bin RiskDUI_bin Trust1_bin ///
childSDQ_score_bin childSDQ_factor_bin SDQ_score_bin SDQ_factor_bin Satisfied ///


label var Friends_bin "Many friends"
label var childinvTalkOut_bin "Talks about activities"
label var childinvTalkSchool_bin "Talks about school"
label var closeDad_bin "Close to dad"
label var closeMom_bin "Close to mom"
label var childSDQ_score_bin "Low SDQ score"
label var BMI_cat_bin "Normal BMI"
label var childHealth_bin "Good health"
label var childNone_diag "No illness"
label var childSnackNo "Never snacks"
label var childSnackFruit "Fruit as snack"
label var SmokeEver "Never smoked"
label var Drink "Doesn't drink"
label var difficultiesInterest "Excited to learn"
label var difficultiesSit "Can sit still"
label var dropoutSchool "Attending school"
label var likeSchool_ado_bin "Likes school"
label var Satisfied "Satisfied"
label var Depression_bin "Low depression score"
label var Trust_bin "High trust"
      
save "$dir/Analysis/chiara&daniela/do/Reggio1994outcomes.dta", replace
