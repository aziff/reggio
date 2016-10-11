import csv
import sys

"""
This code creates a .csv file containing all possible combinations of the baseline characteristics in groups of five.
"""

vars = 					["Male", "CAPI", "numSiblings", 
						"momMaxEdu_middle", "momMaxEdu_HS", "momMaxEdu_Uni", "momMaxEdu_Grad","momBornProvince", 
						"dadMaxEdu_middle", "dadMaxEdu_HS", "dadMaxEdu_Uni", "dadMaxEdu_Grad","dadBornProvince"]

print vars

num_vars = len(vars)
print num_vars

tuples = open('Y:\Analysis\AIC_BIC_Analysis\Tuples\Output\\tuples_Adult.csv','wb')
writer = csv.writer(tuples,delimiter=' ')
writer.writerow( (['tuple']) )
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