import os
from treedict import TreeDict

filedir = os.path.join(os.path.dirname(__file__))

paths = TreeDict()
paths.abccare = os.path.join(filedir, '..', '..', 'data', 'Reggio_prepared.dta') # for testing
paths.outcomes = os.path.join(filedir, '..', '..', 'outcome', 'outcomes_adult.csv')
paths.controls = os.path.join(filedir, 'controls_adults.csv')

