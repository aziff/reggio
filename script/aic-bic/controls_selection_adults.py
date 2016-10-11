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
usedata['reggio'] = data.loc[(data.Cohort==4) | (data.Cohort==5) | (data.Cohort==6), :] 		# Limit to adult cohorts only

# bring in outcomes files, and find the ABC-only/CARE-only ones
outcomes = pd.read_csv(paths.outcomes, index_col='variable')

# bring in bank of control variables
bank = pd.read_csv(paths.controls)
bank = list(bank.loc[:, 'variable'])

# define model selection function
def model_select(data, yvar, xvars, spec):

	data_mod = usedata['{}'.format(spec)]
	
	print "Estimating AIC/BIC for {}...".format(yvar)    
	
	output_aic = []
	output_bic = []
	cols = []  
	
	models = itertools.chain.from_iterable([itertools.combinations(xvars, 3)])
	
	for i,m in enumerate(models):
	
		fmla = '{} ~ Male + CAPI + {}'.format(yvar, ' + '.join(m))
		 
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
	
for spec in ['reggio']:
	selection = Parallel(n_jobs=1)(
		delayed(model_select)(data, yvar, bank, spec) for yvar in outcomes.index) 
	selection = pd.concat(selection, axis=0)
	selection.sort_index(inplace=True)

	# estimate rankings by AIC and BIC
	selection = selection.rank(axis=1).groupby(level=0).sum()
	best = selection.idxmin(axis = 1)
	model_list = list(itertools.chain.from_iterable([itertools.combinations(bank, 4)]))
	best_aic["{}".format(spec)] = model_list[selection.idxmin(axis = 1)[0]]
	best_bic["{}".format(spec)] = model_list[selection.idxmin(axis = 1)[1]]

	print 'Best AIC:', ('Male', 'CAPI') + best_aic['{}'.format(spec)]
	print 'Best BIC:', ('Male', 'CAPI') + best_bic['{}'.format(spec)]

record = open('best_controls.txt', 'wb')
        
record.write('Reggio Best AIC: {} \n\n'.format(' '.join(('Male', 'CAPI') + best_aic['reggio'])))
record.write('Reggio Best BIC: {}'.format(' '.join(('Male', 'CAPI') + best_bic['reggio'])))
record.close()