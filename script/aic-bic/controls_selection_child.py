# -*- coding: utf-8 -*-
"""
Created on Tue Oct 11 17:52:54 2016

@author: yukyungkoh (modified from Joshua Shea's code)

Desctiption: this code estimates a linear model for each outcome 

Function:   model_select
Desc:       Selects the set of X variables with that yields the lowest RMSE
            when regressing Y on X.
            
Args:       'data' is the dataset you want to use.
            'yvar' is the outcome/endogenous variable in the regression.
            'xvars' is the list of X variables you permute over.

"""

import os
from paths import paths
import pandas as pd
from pandas.io.stata import StataReader
import numpy as np
import statsmodels.api as sm
from patsy import dmatrices
import itertools
from joblib import Parallel, delayed

# import data
reader = StataReader(paths.reggio)
data = reader.data(convert_dates=False, convert_categoricals=False)
data = data.set_index('intnr')
data = data.sort_index()

usedata = {}
usedata['child'] = data.loc[((data.Cohort==1) | (data.Cohort==2)) & (data.Reggio==1), :] 							# Limit to child cohort in Reggio only

# bring in outcomes files, and find the ABC-only/CARE-only ones
outcomes = {}
for cohort in ['child']:
	outcomes['{}'.format(cohort)]  = pd.read_csv(paths.outcomes['{}'.format(cohort)] , index_col='variable')

# bring in bank of control variables
bank = {}
for cohort in ['child']:
	bank['{}'.format(cohort)]  = pd.read_csv(paths.controls['{}'.format(cohort)])
	bank['{}'.format(cohort)] = list(bank['{}'.format(cohort)].loc[:, 'variable'])

# define model selection function
def model_select(data, yvar, xvars, cohort):

	data_mod = usedata['{}'.format(cohort)]
	
	print "Estimating AIC/BIC for {} : {}...".format(cohort, yvar)    
	
	output_aic = []
	output_bic = []
	cols = []  
	
	models = itertools.chain.from_iterable([itertools.combinations(xvars, 3)])
	
	for i,m in enumerate(models):
	
		fmla = '{} ~ Male + CAPI + asilo + Cohort_Migrants + {}'.format(yvar, ' + '.join(m))
		 
		# perform OLS
		try:
			endog, exog = dmatrices(fmla, data_mod, return_type='dataframe')
			model = sm.OLS(endog, exog)
			fit = None
			fit = model.fit()
	
			model_aic = fit.aic
			model_bic = fit.bic
	
		except:
			model_aic = np.inf
			model_bic = np.inf
		
		output_aic = output_aic + [model_aic]
		output_bic = output_bic + [model_bic]
		cols = cols + [i]

	
	output_aic = pd.DataFrame(output_aic, index = pd.Index(cols, name = 'model'), columns = pd.MultiIndex.from_tuples([('aic', yvar)], names = ['stat', 'var'])).T
	output_bic = pd.DataFrame(output_bic, index = pd.Index(cols, name = 'model'), columns = pd.MultiIndex.from_tuples([('bic', yvar)], names = ['stat', 'var'])).T
	
	output = pd.concat([output_aic, output_bic], axis = 0)    
	
	return output

best_aic = {}
best_bic = {}
	
for cohort in ['child']:
	selection = Parallel(n_jobs=1)(
		delayed(model_select)(data, yvar, bank['{}'.format(cohort)], cohort) for yvar in outcomes['{}'.format(cohort)].index) 
	selection = pd.concat(selection, axis=0)
	selection.sort_index(inplace=True)

	# estimate rankings by AIC and BIC
	selection = selection.rank(axis=1).groupby(level=0).sum()
	best = selection.idxmin(axis = 1)
	model_list = list(itertools.chain.from_iterable([itertools.combinations(bank['{}'.format(cohort)], 3)]))
	best_aic["{}".format(cohort)] = model_list[selection.idxmin(axis = 1)[0]]
	best_bic["{}".format(cohort)] = model_list[selection.idxmin(axis = 1)[1]]

	print 'Best AIC:', ('Male', 'CAPI') + best_aic['{}'.format(cohort)]
	print 'Best BIC:', ('Male', 'CAPI') + best_bic['{}'.format(cohort)]

record = open('best_controls_child.txt', 'wb')

record.write('The best controls according to AIC and BIC criteria for each age group is: \n')        
record.write('\n Reggio Children Best AIC: {}'.format(' '.join(('Male', 'CAPI', 'asilo', 'Cohort_Migrants') + best_aic['child'])))
record.write('\n Reggio Children Best BIC: {}'.format(' '.join(('Male', 'CAPI', 'asilo', 'Cohort_Migrants') + best_bic['child'])))
record.close()