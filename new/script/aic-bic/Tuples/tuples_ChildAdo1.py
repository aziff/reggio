import csv
import sys

"""
This code creates a .csv file containing all possible combinations of the baseline characteristics in groups of five.

Note: I reproduce these results in the python file "tuples_2.py" using "itertools.combinations". Both methods yield 
the same set of combinations showing that we have captured all the possible combinations  
"""

vars = 				["Male", "CAPI", "lowbirthweight", "birthpremature", "momMaxEdu_low", "momMaxEdu_middle",\
					"momMaxEdu_HS", "momMaxEdu_Uni", "momBornProvince", "teenMomBirth", "dadMaxEdu_low", "dadMaxEdu_middle", \
					"dadMaxEdu_HS", "dadMaxEdu_Uni", "dadBornProvince", "teenDadBirth", "cgRelig", "cgCatholic", "cgFaith_dummy", \
					"int_cgCatFaith", "houseOwn", "cgMigrant", "cgReddito_1", "cgReddito_2", "numSibling_0", "numSibling_1", \
					"numSibling_2", "numSibling_more"]


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
