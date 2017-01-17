import os
from treedict import TreeDict

filedir = os.path.join(os.path.dirname(__file__))

paths = TreeDict()
paths.reggio = os.path.join(filedir, '..', '..', 'data', 'Reggio_reassigned.dta') # for testing
paths.outcomes = {}
paths.outcomes['adult'] = os.path.join(filedir, '..', '..', 'outcome', 'outcomes_adult.csv')
paths.outcomes['adol'] = os.path.join(filedir, '..', '..', 'outcome', 'outcomes_adol.csv')
paths.outcomes['child'] = os.path.join(filedir, '..', '..', 'outcome', 'outcomes_child.csv')

paths.controls = {}
paths.controls['adult'] = os.path.join(filedir, 'controls_adult.csv')
paths.controls['adol'] = os.path.join(filedir, 'controls_adol.csv')
paths.controls['child'] = os.path.join(filedir, 'controls_child.csv')

