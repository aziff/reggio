# -*- coding: utf-8 -*-
"""
Created on Tues May 10 2016

@author: JessiaYK
"""
from paths import paths
import pandas as pd
import os


command = '''
\\begin{{center}}
	\\input{{{}rslt_{}_cat{}}}
\\end{{center}}
'''

command_counts = '''
\\begin{{center}}
	\\input{{{}rslt_{}_counts}}
\\end{{center}}
'''

command_counts_cat = '''
\\begin{{center}}
	\\input{{{}rslt_{}_counts_n{}a{}}}
\\end{{center}}
'''

command_main = '''
\\begin{{center}}
	\\input{{{}rslt_{}_main{}}}
\\end{{center}}
'''


f = open(os.path.join(paths.tmp_tables, 'test.tex'), 'w')

head = '''
\\input{Preamble} \n
\\title{ABC Treatment Effects: Preliminary Estimates} \n
\\date{\\today} \n
\\begin{document} \n
\\maketitle \n
\\tableofcontents \n
\\clearpage \n\n
'''
# write in head
f.write(head)


# column spacing
f.write('\\def\\arraystretch{0.6}\n\n')
f.write('\\setlength\\tabcolsep{0.3em}\n\n')


f.write('\\section{{Combining Functions, Aggregated}}\n\n')
# write in all other models
for sex in ['pooled', 'male', 'female']:
    f.write(command_counts.format(pathext, sex))


f.write('\\section{{Combining Functions, by Category}}\n\n')
for sex in ['pooled', 'male', 'female']:
    #f.write('\\subsection{{{}}}\n\n'.format(sex.capitalize()))
    for n in [25, 50, 75]: #25, 50, 75 are the options
        for a in [5, 10, 100]:    # 5, 10, 100 are the options
            if pathext == 'carefam_2sided/' and a == 100:
                pass
            else:
                f.write(command_counts_cat.format(pathext, sex, n, a))
    
f.write('\\section{{Main Results}}\n\n')
# write in all other models
for sex in ['pooled', 'male', 'female']:
    for m in [1,2,3]:
        f.write(command_main.format(pathext, sex, m))


# write in all other models
for sex in ['pooled', 'male', 'female']:
    f.write('\\section{{Treatment Effects for {} Sample}}\n\n'.format(sex.capitalize()))
    for i, cat in enumerate(outcomes.category.drop_duplicates().tolist()):
        f.write(command.format(pathext, sex, i))

f.write('\\end{document}')
f.close()
