/* ---------------------------------------------------------------------------- *
* Programming a function for the OLS for Reggio analysis
* Author: Jessica Yu Kyung Koh
* Edited: 09/01/2016

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
		
	- agelist(string)
	  : This shows the list of the ages that are to be added up in the columns of the tables.
	    For example, the regression results for Reggio vs. Other Cities for each age cohort will be
		presented by each column in the table.
	  
	- usegroup(string)
	  : This option is defined in order to name the tex file of the output. 
	
	- keep(varlist)
	  : This is to only keep the necessary variables that will be shown in the tables. 
	
* ---------------------------------------------------------------------------- */

capture program drop multipleanalysis
capture program define multipleanalysis

version 13
syntax, type(string) comparisonlist(string) usegroup(string) 
	
	
	***** Create a local for the label (Going to be filled out in the loop)
	local coeflabel
	
	***** Loop through the outcomes in a category and store diff-in-diff results for each age group
	foreach comp in ${comparisonlist} {
		foreach var in ${adult_outcome_`type'} {		
			sum `var' if ${ifcondition`comp'}
			if r(N) > 0 {
				eststo `var' : quietly reg `var' ${X`comp'} ${controls} if ${ifcondition`comp'}, robust
				local coeflabel `coeflabel' `var' "${`var'_lab}"
			}
		}	

	***** Store the initial results in the initial format (Output in each column) 
		esttab, se nostar keep(${keep`comp'})
		matrix C`comp' = r(coefs)
	}
	
	***** Clear eststo to make a new table. 
	eststo clear
	
	***** Loop through each row to produce the transposed final table
	foreach	comp in ${comparisonlist} {
		local rnames : rownames C`comp'
		local models : coleq C`comp'
		local models : list uniq models
		local i 0

		foreach name of local rnames {
		   local ++i
		   local j 0
		   capture matrix drop b
		   capture matrix drop se
		   foreach model of local models {
			   local ++j
			   matrix tmp = C`comp'[`i', 2*`j'-1]
			   if tmp[1,1] < . {
				  matrix colnames tmp = `model'
				  matrix b = nullmat(b), tmp
				  matrix tmp[1,1] = C`comp'[`i', 2*`j']
				  matrix se = nullmat(se), tmp
			  }
		  }
		  ereturn post b
		  quietly estadd matrix se
		  eststo ${`name'`comp'_c}
		}
	}

	***** Output the table to the tex file
	esttab using "${here}/../../output/multiple-methods/multiple-`usegroup'-`type'.tex", replace se mtitle ///
				coeflabels(`coeflabel') noobs nonotes booktabs 

end
