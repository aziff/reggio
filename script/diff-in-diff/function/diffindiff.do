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
	- ifcondition(string)
	- comparison(string)
	- keep(varlist)
	
* ---------------------------------------------------------------------------- */

capture program drop diffindiff
capture program define diffindiff

version 13
syntax, type(string) ifcondition(string) comparison(string) keep(varlist)

	* Create a local for the label (Going to be filled out in the loop)
	local coeflabel

	* Loop through the outcomes in a category and store diff-in-diff results
	foreach var in ${adult_outcome_`type'} {		
		sum `var' if `ifcondition'
		if r(N) > 0 {
			eststo `var' : quietly reg `var' ${X} ${controls} if `ifcondition'
			local coeflabel `coeflabel' `var' "${`var'_lab}"
		}
	}	

	* Store the initial results in the initial format (Output in each column) 
	esttab, se nostar keep(`keep')

	matrix C = r(coefs)

	eststo clear
	local rnames : rownames C
	local models : coleq C
	local models : list uniq models
	local i 0

	* Loop through each row to produce the transposed final table
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

	* Output the table to the tex file
	esttab using "${current}/../../output/did/did-`comparison'-`type'.tex", replace se mtitle ///
				coeflabels(`coeflabel') noobs nonotes addnotes("Note: This table shows")

end
