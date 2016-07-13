import csv
import sys

"""
This code creates a .csv file containing all possible combinations of the baseline characteristics in groups of five.

Note: I reproduce these results in the python file "tuples_2.py" using "itertools.combinations". Both methods yield 
the same set of combinations showing that we have captured all the possible combinations  
"""

adult_baseline_vars = 	["Male", "CAPI", "numSiblings" ,"momMaxEdu_low", "momMaxEdu_middle", "momMaxEdu_HS", "momMaxEdu_Uni", \
						"momMaxEdu_Grad","momBornProvince", "dadMaxEdu_low", "dadMaxEdu_middle", "dadMaxEdu_HS", "dadMaxEdu_Uni", \
						"dadMaxEdu_Grad","dadBornProvince"]
						
outcomesAdult = 	["IQ_factor","IQ_score", "p50IQ_score", "p75IQ_score", "votoMaturita", "votoUni", "highschoolGrad", "MaxEdu_Uni", \
					"MaxEdu_Grad", "PA_Empl", "IncomeCat","Pension","SES_self", "HrsTot", "WageMonth", "Reddito_1", "Reddito_2", \
					"Reddito_3", "Reddito_4", "Reddito_5", "Reddito_6", "Reddito_7", "mStatus_married_cohab", "childrenResp", "all_houseOwn",\
					"live_parent", "Maria", "Smoke", "Cig", "sport", "BMI", "Health", "SickDays", "HealthPerc", "i_RiskFight", "i_RiskDUI", \
					"RiskSuspended", "Drink1Age", "LocusControl", "Depression_score", "SDQ_score", "MigrTaste_cat" "binSatisIncome",\
					"binSatisWork", "binSatisHealth", "binSatisFamily", "optimist",	"reciprocity1bin", "reciprocity2bin", "reciprocity3bin",\
					"reciprocity4bin"]
					
totalOutcomes = 	adult_baseline_vars+outcomesAdult			

print totalOutcomes


"""					
num_vars = len(vars)
print num_vars

tuples = open('Y:\Analysis\Output\AIC_BIC\\tuples.csv','wb')
writer = csv.writer(tuples,delimiter=' ')
writer.writerow( (['All possible combinations of controls in groups of 5']) )
for i in range(num_vars):
	for j in range(i+1,num_vars):
		for k in range(j+1,num_vars):
			for l in range(k+1,num_vars):
				for m in range(l+1,num_vars):
					writer.writerow([vars[i], vars[j], vars[k], vars[l], vars[m]])
					m=m+1
				l=l+1
			k=k+1
		j=j+1
	i=i+1	
tuples.close()
