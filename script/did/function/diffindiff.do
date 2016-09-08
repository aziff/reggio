/* ---------------------------------------------------------------------------- *
* Programming a function for the Diff-in-Diff for Reggio analysis
* Author: Jessica Yu Kyung Koh
* Edited: 08/29/2016

* Note: This function performs a diff-in-diff analysis and creates tables
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
		
	- ifcondition(string)
	  : This ifcondition limits the sample to the ones that are used in the diff-in-diff analysis.
	    For example, if we want to do diff-in-diff between Religious schools and Municipal schools in Padova,
		the ifcondition should be "Padova == 1 & (maternaMuni == 1 | maternaReli ==1)"
	  
	- comparison(string)
	  : This option is defined in order to name the tex file of the output. 
	
	- keep(varlist)
	  : This is to only keep the necessary variables that will be shown in the tables. 
	
* ---------------------------------------------------------------------------- */

capture program drop diffindiff
capture program define diffindiff

version 13
syntax, type(string) ifcondition(string) comparison(string) keep(varlist)
	
	
	***** Create a local for the label (Going to be filled out in the loop)
	local coeflabel
	
	***** Create a local for footnote that will be included in the output
	# delimit ;
	local Note			"\specialcell{\underline{Note:} This table shows the diff-in-diff estimates for ${`comparison'_note}. \\
									Standard errors are reported in parenthesis. Stars show statistical significance as follows: \\
									* p < 0.05, ** p < 0.01, *** p < 0.001.}" ;
	# delimit cr
	
	di "Note: `Note'"
	di "Comparison Note: ${`comparison'_note}"

	***** Loop through the outcomes in a category and store diff-in-diff results
	foreach var in ${adult_outcome_`type'} {		
		sum `var' if `ifcondition'
		if r(N) > 0 {
			eststo `var' : quietly reg `var' ${X} ${controls} if `ifcondition'
			local coeflabel `coeflabel' `var' "${`var'_lab}"
		}
	}	

	***** Store the initial results in the initial format (Output in each column) 
	esttab, se nostar keep(`keep')

	matrix C = r(coefs)

	eststo clear
	local rnames : rownames C
	local models : coleq C
	local models : list uniq models
	local i 0

	***** Loop through each row to produce the transposed final table
	foreach name of local rnames {
	   local ++i
	   local j 0
	   capture matrix drop b
	   capture matrix drop se
	   foreach model of local models {
		   local ++j
		   matrix tmp = C[`i', 2*`j'-1]
		   if tmp[1,1] < . {
			  matrix colnames tmp = `model'
			  matrix b = nullmat(b), tmp
			  matrix tmp[1,1] = C[`i', 2*`j']
			  matrix se = nullmat(se), tmp
		  }
	  }
	  ereturn post b
	  quietly estadd matrix se
	  eststo `name'
	}

	***** Output the table to the tex file
	esttab using "${current}/../../output/did/did-`comparison'-`type'.tex", replace se mtitle ///
				coeflabels(`coeflabel') noobs nonotes addnotes("`Note'") booktabs

end
