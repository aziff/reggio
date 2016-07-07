"""
Created on 25 June, 2016
@author: Sidharth Moktan

Desc:  
This code creates a .csv file containing all possible combinations of the baseline characteristics in groups of five.

Note: I reproduce these results in the python file "tuples_1.py" without using "itertools.combinations". Both methods yield 
the same set of combinations showing that we have captured all the possible combinations.
"""

import csv
import sys
import itertools

vars = 				["Male", "CAPI", "lowbirthweight", "birthpremature", "momMaxEdu_low", "momMaxEdu_middle",\
					"momMaxEdu_HS", "momMaxEdu_Uni", "momBornProvince", "teenMomBirth", "dadMaxEdu_low", "dadMaxEdu_middle", \
					"dadMaxEdu_HS", "dadMaxEdu_Uni", "dadBornProvince", "teenDadBirth", "cgRelig", "cgCatholic", "cgFaith_dummy", \
					"int_cgCatFaith", "houseOwn", "cgMigrant", "cgReddito_1", "cgReddito_2", "numSibling_0", "numSibling_1", \
					"numSibling_2", "numSibling_more"]
					
models = itertools.chain.from_iterable([itertools.combinations(vars, 5)])
models = list(models)

tuples = open('Y:\Analysis\Output\AIC_BIC\\tuples_2.csv','wb')
writer = csv.writer(tuples)
writer.writerow( (['All possible combinations of controls in groups of 5']) )


for i in range(98280):
	writer.writerow(models[i])
tuples.close()
