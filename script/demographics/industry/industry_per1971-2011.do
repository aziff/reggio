local males_start 		I1
local males_end			O6
local females_start 	I1
local females_end		O10
local total_start		I1
local total_end			O14

forvalues y = 1971(10)2011 {

	foreach s in males females total {
		cd ${input_data}
		import excel using "indusrty_1971_2011.xlsx", clear sheet("`y'") cellrange(I1:``s'_end')
		sxpose, clear
		
		if "`s'" == "males" {
			drop _var3 _var1
			
			gen sex = "Male"
			
			rename _var2 Name
			rename _var4 Padova
			rename _var5 Parma
			rename _var6 Reggio
			
			foreach v in Padova Parma Reggio {
				drop if substr(`v',-1,1) == "a"
				destring(`v'), replace
			}
		}
		else if "`s'" == "females" {
			keep _var2 _var8 _var9 _var10
			
			gen sex = "Female"
			
			rename _var2 Name
			rename _var8 Padova
			rename _var9 Parma
			rename _var10 Reggio
			
			foreach v in Padova Parma Reggio {
				drop if substr(`v',-1,1) == "a"
				destring(`v'), replace
			}
		
		}
		else {
			keep _var2 _var12 _var13 _var14
			
			gen sex = "Total"
			
			rename _var2 Name
			rename _var12 Padova
			rename _var13 Parma
			rename _var14 Reggio
			
			foreach v in Padova Parma Reggio {
				drop if substr(`v',-1,1) == "a"
				destring(`v'), replace
			}
		
		}
			
		tempfile per`y'`s'
		save	`per`y'`s''
			
	}
	
	append using `per`y'females'
	append using `per`y'males'
			
	gen source 		= "Industry" 
	gen year 		= `y'
	gen Variable 	= "per"

	lab var Name 				"Category"
	lab var year 				"Year"
	lab var Variable 			"Statistic"
	lab var Reggio				"Reggio Emilia"
	lab var Padova				"Padova"
	lab var Parma				"Parma"
		
	
	tempfile total_per`y'
	save	`total_per`y''
	
}

forvalues y = 1981(10)2011 {
	append using `total_per`y''
}

tempfile industry_per
save	`industry_per'
