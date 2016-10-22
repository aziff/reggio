clear all
set more off
capture log close

********************************************************************************
*** COHORT 2006

use "C:\Users\Pronzato\Dropbox\ReggioChildren\SURVEY_DATA_COLLECTION\data\Reggio.dta", clear

*** only 2006 

keep if Cohort == 1
count

*** desc sum & drop

log using "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\do\listvariables children 15July16.smcl", replace

desc
sum

log close

/* TUTTI GLI OUTCOMES (5+10+6+31+26+16+11+20=135)

*** DIFFICULTIES (5)

difficultiesSit byte    %8.0g      LABU       Ability to sit still in a group when asked (difficulties in primary school)
difficultiesI~t byte    %8.0g      LABU       Lack of excitement to learn (difficulties in primary school)
difficultiesO~y byte    %8.0g      LABU       Ability to obey rules and directions (difficulties in primary school)
difficultiesEat byte    %8.0g      LABU       Fussy eater (difficulties in primary school)
difficulties    byte    %55.0g     difficulties

                                              dv: Difficulties encountered when starting primary school
											  
*** THINGS AT HOME (10)

childinvReadTo  byte    %8.0g      V37110   * Frequency reading to child
childinvMusic   byte    %8.0g      V37120   * Music instrument at home
childinvCom     byte    %8.0g      V37130     Is there a computer at home that the child can use?
childinvTV_hrs  byte    %10.0g              * In a typical day, how many hours does your child spend watching television?
childinvVideo~s byte    %10.0g              * In a typical day, how many hours does your child spend watching video games?
childinvOut     byte    %8.0g      V37150   * Frequency taking child out (high = never)
childinvFamMeal byte    %8.0g      V37190   * Frequency eating a meal together
childinvChore~m byte    %8.0g      V37200_1 * How often is your child expected to do the following? Clean up his/her room?
childinvChore~p byte    %8.0g      V37200_2 * How often is your child expected to do the following? Do routine chores such
                                                as
childinvChore~w byte    %8.0g      V37200_3 * How often is your child expected to do the following? Do homework
                                                voluntarily?
												
*** EXTRA ACTIVITIES (6)
											
childinvReadS~f byte    %8.0g      V37210     Frequency reading by herself
childinvSport   byte    %8.0g      LABA       Child does sport
childinvDance   byte    %8.0g      LABA       Child does dances
childinvTheater byte    %8.0g      LABA       Child does theater
childinvOther   byte    %8.0g      LABA       Does your child participate in the following activities? Other, specify
childFriends byte    %10.0g              * Number of child's friends

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
*** THINGS AT SCHOOL (16)

likeSchool_ch~d byte    %8.0g      V60000_1   Child dislikes school
likeRead        byte    %8.0g      V60000_2   Child dislikes reading
likeMath_child  byte    %8.0g      V60000_3   Child dislikes Math
likeGym         byte    %8.0g      V60000_4 * Child dislikes gym
goodBoySchool   byte    %8.0g      V60090_1   Child not a good boy in class
bullied         byte    %8.0g      V60090_2 * How often do other children bully you?
alienated       byte    %8.0g      V60090_3 * How often do you feel left out of things by children at school?
doGrowUp        byte    %8.0g      LABAA      And finally, what would you like to be when you grow up?
likeTV          byte    %8.0g      V60310_1 * Child dislikes TV
likeDraw        byte    %8.0g      V60310_2   Child dislikes drawing
likeSport       byte    %8.0g      V60310_3   Child dislikes sports
FriendsGender   byte    %12.0g     FriendsGender
                                            * Are your friends mostly boys, mostly girls or a mixture of boys and girls?
bestFriend      byte    %8.0g      V60380     Do you have any best friends?
lendFriend      byte    %8.0g      V60391     Child doesn't lends to friends
favorReturn     byte    %8.0g      V60392     Child doesn't return a favor
revengeReturn   byte    %8.0g      V60393   * Child doesn't seek revenge

*** FEELINGS (11)

funFamily       byte    %8.0g      V60394     Child doesn't have fun in family
worryMyself     byte    %8.0g      LABAB      I keep it to myself (what you do when worried)
worryFriend     byte    %8.0g      LABAB      I tell a friend (what you do when worried)
worryHome       byte    %8.0g      LABAB      I tell someone at home (what you do when worried)
worryTeacher    byte    %8.0g      LABAB      I tell a teacher (what you do when worried)
faceMe          byte    %10.0g                Happy child
faceFamily      byte    %10.0g                Happy family
faceSchool      byte    %10.0g                Happy school
faceGeneral     byte    %10.0g                Happy in general
brushTeeth      byte    %10.0g                How many times do you brush your teeth a day?
candyGame       byte    %13.0g     candy    * How many candies are you willing to give to a classmate?


*** COGNITIVE (20)

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
IQ13            byte    %9.0g                 
IQ14            byte    %9.0g                 
IQ15            byte    %9.0g                 
IQ16            byte    %9.0g                 
IQ17            byte    %9.0g                 
IQ18            byte    %9.0g                 
IQ_factor       float   %9.0g                 dv: Respondent mental ability. Raven matrices - factor score
IQ_score        float   %9.0g                 Respondent mental ability. % of correct answers (Raven matrices)


*/

*** dummy dal verso giusto 

sum childinvMusic childinvSport childinvDance childinvTheater childinvOther  childNone_diag childSnackFruit childSnackIce worryFriend worryHome ///
worryTeacher IQ1 IQ2 IQ3 IQ4 IQ5 IQ6 IQ7 IQ8 IQ9 IQ10 IQ11 IQ12 IQ13 IQ14 IQ15 IQ16 IQ17 IQ18 bestFriend

desc  childinvMusic childinvSport childinvDance childinvTheater childinvOther  childNone_diag childSnackFruit childSnackIce worryFriend worryHome ///
worryTeacher IQ1 IQ2 IQ3 IQ4 IQ5 IQ6 IQ7 IQ8 IQ9 IQ10 IQ11 IQ12 IQ13 IQ14 IQ15 IQ16 IQ17 IQ18 bestFriend

*** dummy da capovolgere 

sum difficultiesSit difficultiesInterest difficultiesObey difficultiesEat ///
childAsthma_* childAllerg_* childDigest_* childEmot_diag childSleep_diag childGums_diag childOther_diag childSnackNo childSnackCan childSnackRoll  ///
childSnackChips childSnackOther  worryMyself 

desc difficultiesSit difficultiesInterest difficultiesObey difficultiesEat ///
childAsthma_* childAllerg_* childDigest_* childEmot_diag childSleep_diag childGums_diag childOther_diag childSnackNo childSnackCan childSnackRoll  ///
childSnackChips childSnackOther  worryMyself

foreach j in difficultiesSit difficultiesInterest difficultiesObey difficultiesEat ///
childAsthma_ childAllerg_ childDigest_ childEmot_diag childSleep_diag childGums_diag childOther_diag childSnackNo childSnackCan childSnackRoll  ///
childSnackChips childSnackOther  worryMyself {

replace `j'= 1-`j'

} 

sum difficultiesSit difficultiesInterest difficultiesObey difficultiesEat ///
childAsthma_* childAllerg_* childDigest_* childEmot_diag childSleep_diag childGums_diag childOther_diag childSnackNo childSnackCan childSnackRoll  ///
childSnackChips childSnackOther  worryMyself 

*** dummy da creare 

sum childinvReadTo  childinvFamMeal childinvChoresRoom childinvChoresHelp childinvChoresHomew childinvReadSelf  childFriends ///
childSleep childHeight childBreakfast childFruit sportTogether bullied alienated revengeReturn faceMe faceFamily faceSchool faceGeneral  brushTeeth ///
candyGame IQ_score IQ_factor childSDQHype1 childSDQHype2 childSDQHype3 childSDQEmot1 childSDQEmot2 ///
childSDQEmot3 childSDQEmot4 childSDQEmot5 childSDQCond1 childSDQCond3 childSDQCond4 childSDQCond5 childSDQPeer1 childSDQPeer4 childSDQPeer5

desc childinvReadTo  childinvFamMeal childinvChoresRoom childinvChoresHelp childinvChoresHomew childinvReadSelf  childFriends ///
childSleep childHeight childBreakfast childFruit sportTogether bullied alienated revengeReturn faceMe faceFamily faceSchool faceGeneral  brushTeeth ///
candyGame IQ_score IQ_factor childSDQHype1 childSDQHype2 childSDQHype3 childSDQEmot1 childSDQEmot2 ///
childSDQEmot3 childSDQEmot4 childSDQEmot5 childSDQCond1 childSDQCond3 childSDQCond4 childSDQCond5 childSDQPeer1 childSDQPeer4 childSDQPeer5

tab doGrowUp, m
tab doGrowUp, gen(doGrowUp)
replace doGrowUp1 = 0 if(doGrowUp1 == .)
drop doGrowUp
ren doGrowUp1 doGrowUp

tab FriendsGender
tab FriendsGender, nol
gen mix = (FriendsGender == 0)
drop FriendsGender
ren mix FriendsGender 

foreach j in childinvReadTo  childinvFamMeal childinvChoresRoom childinvChoresHelp childinvChoresHomew childinvReadSelf  childFriends ///
childSleep childHeight childBreakfast childFruit sportTogether bullied alienated revengeReturn faceMe faceFamily faceSchool faceGeneral  brushTeeth ///
candyGame IQ_score IQ_factor childSDQHype1 childSDQHype2 childSDQHype3 childSDQEmot1 childSDQEmot2 ///
childSDQEmot3 childSDQEmot4 childSDQEmot5 childSDQCond1 childSDQCond3 childSDQCond4 childSDQCond5 childSDQPeer1 childSDQPeer4 childSDQPeer5 {

sum `j', d
gen dummy1 = (`j' > r(p50))
gen dummy2 = (`j' >= r(p50))
sum dummy1
gen diff1 = abs(r(mean)-0.5)
sum dummy2
gen diff2 = abs(r(mean)-0.5)
replace `j' = dummy1 if(diff1 <= diff2)
replace `j' = dummy2 if(diff1 > diff2)
drop dummy1 dummy2 diff1 diff2

} 

sum childinvReadTo  childinvFamMeal childinvChoresRoom childinvChoresHelp childinvChoresHomew childinvReadSelf  childFriends ///
childSleep childHeight childBreakfast childFruit sportTogether bullied alienated revengeReturn faceMe faceFamily faceSchool faceGeneral  brushTeeth ///
candyGame IQ_score IQ_factor childSDQHype1 childSDQHype2 childSDQHype3 childSDQEmot1 childSDQEmot2 ///
childSDQEmot3 childSDQEmot4 childSDQEmot5 childSDQCond1 childSDQCond3 childSDQCond4 childSDQCond5 childSDQPeer1 childSDQPeer4 childSDQPeer5 ///
doGrowUp FriendsGender

*** dummy da creare e capovolgere

desc difficulties childinvTV_hrs childinvVideoG_hrs childHealth childSickDays childWeight childDoctor childBMI childTotal_diag ///
likeSchool_ch* likeRead likeMath_child likeGym goodBoySchool likeTV likeDraw likeSport lendFriend favorReturn funFamily ///
childinvCom  childinvOut ///
childSDQPsoc1 childSDQPsoc2 childSDQPsoc3 childSDQPsoc4 childSDQPsoc5 ///
childSDQHype4 childSDQHype5 childSDQCond2 childSDQPeer2 childSDQPeer3 childSDQ*score

sum difficulties childinvTV_hrs childinvVideoG_hrs childHealth childSickDays childWeight childDoctor childBMI childTotal_diag ///
likeSchool_ch* likeRead likeMath_child likeGym goodBoySchool likeTV likeDraw likeSport lendFriend favorReturn funFamily ///
childinvCom  childinvOut ///
childSDQPsoc1 childSDQPsoc2 childSDQPsoc3 childSDQPsoc4 childSDQPsoc5 ///
childSDQHype4 childSDQHype5 childSDQCond2 childSDQPeer2 childSDQPeer3 childSDQ*score

foreach j in difficulties childinvTV_hrs childinvVideoG_hrs childHealth childSickDays childWeight childDoctor childBMI childTotal_diag ///
likeSchool_ch likeRead likeMath_child likeGym goodBoySchool likeTV likeDraw likeSport lendFriend favorReturn funFamily ///
childinvCom  childinvOut ///
childSDQPsoc1 childSDQPsoc2 childSDQPsoc3 childSDQPsoc4 childSDQPsoc5 childSDQPeer_score childSDQPsoc_score ///
childSDQHype4 childSDQHype5 childSDQCond2 childSDQPeer2 childSDQPeer3 childSDQ_score childSDQEmot_score childSDQHype_score childSDQCond_score {

sum `j', d
gen dummy1 = (`j' > r(p50))
gen dummy2 = (`j' >= r(p50))
sum dummy1
gen diff1 = abs(r(mean)-0.5)
sum dummy2
gen diff2 = abs(r(mean)-0.5)
replace `j' = dummy1 if(diff1 <= diff2)
replace `j' = dummy2 if(diff1 > diff2)
drop dummy1 dummy2 diff1 diff2
replace `j'= 1-`j'


} 

sum difficulties childinvTV_hrs childinvVideoG_hrs childHealth childSickDays childWeight childDoctor childBMI childTotal_diag ///
likeSchool_ch* likeRead likeMath_child likeGym goodBoySchool likeTV likeDraw likeSport lendFriend favorReturn funFamily ///
childinvCom  childinvOut ///
childSDQPsoc1 childSDQPsoc2 childSDQPsoc3 childSDQPsoc4 childSDQPsoc5 ///
childSDQHype4 childSDQHype5 childSDQCond2 childSDQPeer2 childSDQPeer3 childSDQ*score

*** elenco completo

sum difficultiesSit difficultiesInterest difficultiesObey difficultiesEat difficulties ///
childinvReadTo childinvMusic childinvCom childinvTV_hrs childinvVideoG_hrs childinvOut childinvFamMeal childinvChoresRoom childinvChoresHelp ///
childinvChoresHomew ///
childinvReadSelf childinvSport childinvDance childinvTheater childinvOther childFriends ///
childSDQPsoc* childSDQHype* childSDQEmot* childSDQCond* childSDQPeer* childSDQ*score ///
childHealth childSickDays childSleep childHeight  childWeight childDoctor childAsthma_* childAllerg_* childDigest_* childEmot_diag ///
childSleep_diag childGums_diag childOther_diag childNone_diag childBreakfast childFruit  childSnackNo childSnackFruit childSnackIce ///
childSnackCan childSnackRoll  childSnackChips childSnackOther sportTogether childBMI childTotal_diag /// 
likeSchool_ch* likeRead likeMath_child likeGym goodBoySchool bullied alienated doGrowUp likeTV likeDraw likeSport /// 
FriendsGender  bestFriend lendFriend favorReturn revengeReturn   ///
funFamily worryMyself worryFriend worryHome worryTeacher faceMe faceFamily faceSchool faceGeneral  brushTeeth    candyGame   ///
IQ1 IQ2 IQ3 IQ4 IQ5 IQ6 IQ7 IQ8 IQ9 IQ10 IQ11 IQ12 IQ13 IQ14 IQ15 IQ16 IQ17 IQ18 IQ_score IQ_factor
      
save "C:\Users\Pronzato\Dropbox\ReggioChildren\Analysis\chiara&daniela\do\Reggio2006outcomes.dta", replace


 
