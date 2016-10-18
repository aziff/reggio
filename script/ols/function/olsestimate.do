/* ---------------------------------------------------------------------------- *
* Programming a function for the OLS for Reggio analysis
* Author: Jessica Yu Kyung Koh
* Edited: 10/14/2016

* Note: This function performs OLS analysis and creates tables
        for each outcome category. The outcome variables are listed in the table
		in each row. Note that esttab command usually stores each outcome in 
		each column of the table. Hence, the purpose of this program is to transpose
		that format. 
		
* Options: 
	- type(string)
	  : This shows the type of outcome category as defined in macros.do.
	    For example, adult outcome variables for education category is stored in the global
		variable called "adult_outcome_E" in macros.do. This option types in "E" in order to
		capture the education category for adult outcome variables. 
		
	- list(string)
	  : This shows the list of options that are to be added up in the columns of the tables.
	    For example, the regression results for Reggio vs. Other Cities for each age cohort will be
		presented by each column in the table.
	  
	- usegroup(string)
	  : This option is defined in order to name the tex file of the output. 
	
	- keep(varlist)
	  : This is to only keep the necessary variables that will be shown in the tables. 
	  
	- cohort(string)
	  : This is to specify what age cohort is being used in the estimation.
	
* ---------------------------------------------------------------------------- */

capture program drop olsestimate
capture program define olsestimate

version 13
syntax, type(string) list(string) usegroup(string) keep(varlist) cohort(string)
	
	
	***** Create a local for the label (Going to be filled out in the loop)
	local coeflabel

	***** Loop through the outcomes in a category and store diff-in-diff results for each age group
	foreach item in ${list} {
		foreach var in ${`cohort'_outcome_`type'} {	
			sum `var' if ${ifcondition`item'}
			if r(N) > 0 {
				eststo `var' : quietly reg `var' ${X} ${controls`item'} if ${ifcondition`item'}, robust
				local coeflabel `coeflabel' `var' "${`var'_lab}"
			}
		}	

	***** Store the initial results in the initial format (Output in each column) 
		esttab, se nostar keep(`keep')
		matrix C`item' = r(coefs)
	}

	***** Clear eststo to make a new table. 
	eststo clear

	***** Loop through each row to produce the transposed final table
	foreach	item in ${list} {
		local rnames : rownames C`item'
		local models : coleq C`item'
		local models : list uniq models
		local i 0

		foreach name of local rnames {
		   local ++i
		   local j 0
		   capture matrix drop b
		   capture matrix drop se
		   foreach model of local models {
			   local ++j
			   matrix tmp = C`item'[`i', 2*`j'-1]
			   if tmp[1,1] < . {
				  matrix colnames tmp = `model'
				  matrix b = nullmat(b), tmp
				  matrix tmp[1,1] = C`item'[`i', 2*`j']
				  matrix se = nullmat(se), tmp
			  }
		  }
		  ereturn post b
		  quietly estadd matrix se
		  eststo `item'
		}
	}

	***** Output the table to the tex file
	esttab using "${here}/../../output/ols/ols-`usegroup'-`type'-`cohort'.tex", replace b(a2) se(2) mtitle ///
				coeflabels(`coeflabel') noobs nonotes /*addnotes("`Note'")*/ booktabs

end
