* Author: Pietro Biroli

// Graphs of summary statistics for outcomes
* ---------------------------------------------------------------------------- *
* (item) Some Summary Statistics
global options  main(mean %5.2f) aux(sd %5.2f) unstack /// nostar 
nonote nomtitle nonumber replace tex nogaps

* (item) Make the Graphs 
global graphOptions over(maternaType, label(angle(45))) over(City) asyvars  ytitle("Mean") 
global graphExport replace width(800) height(600)

* -------------------------------- Children ---------------------------------- *
foreach var of varlist `outChild'{
		//local var childSDQ_score
		des `var'
		
		local lab: variable label `var' // save variable label in local `lab'
		local graph_title = "Children - " + "`lab'" //create the graph's title through concatenation
		
		preserve
		keep if(Cohort == 1)
		collapse (mean) mean_`var'= `var' (sd) sd_`var' = `var' (count) n=`var', by(maternaType City)
		replace sd_`var' = 0 if(sd_`var' == . )
		drop if (maternaType == 4 | maternaType >=.) // drop private or missing
		replace mean_`var' = . if n <=10 // replace to missing if too few obs
		replace n = . if n <=10 // replace to missing if too few obs
		
		generate hi = mean_`var' + invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate lo = mean_`var' - invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate zero = 0 //for putting the numbers on the x-axis

		generate se = sd_`var' / sqrt(n)

		generate maternaCity = maternaType      if City == 1
		replace  maternaCity = maternaType + 6  if City == 2
		replace  maternaCity = maternaType + 12 if City == 3
		
		twoway (bar mean_`var' maternaCity if maternaType==0) ///
     	 	 (bar mean_`var' maternaCity if maternaType==1)   ///
      		 (bar mean_`var' maternaCity if maternaType==2)   ///
      	 	 (bar mean_`var' maternaCity if maternaType==3)   ///
       	 	 (bar mean_`var' maternaCity if maternaType==4)   ///
       	 	 (scatter zero maternaCity, ms(i) mlab(n) mlabpos(6) mlabcolor(black)) /// mean_`var' 
       	 	 (rcap hi lo maternaCity, lcolor(red)), ///
        	 legend(order(1 "Not Attended" 2 "Municipal" 3 "State" 4 "Religious")) /// 5 "Private"
         	 xlabel(2.05 "Reggio" 7.975 "Parma" 14.0 "Padova", noticks) ///
         	 xtitle("City and Materna Type") ytitle("Mean") title("`graph_title'")  ///
			 /// MAYBE HERE PUT THE SCALE ONLY IF mean_`var'<=1 & mean_`var'>=0
			 note("Source: RCH survey. Plot of means and their standard errors." "Number of obs. in each category at the bottom") ///
			 yscale(range(-0.2 1))  ylabel(#8) ///

		restore, preserve
	
		graph export `var'_Child.png, $graphExport //export the graph
		
		restore, not
}

* -------------------------------- Migrants ---------------------------------- *
foreach var of varlist `outChild'{
		des `var'
		
		local lab: variable label `var' // save variable label in local `lab'
		local graph_title = "Migrant Children - " + "`lab'" //create the graph's title through concatenation
		
		preserve
		keep if(Cohort == 2)
		collapse (mean) mean_`var'= `var' (sd) sd_`var' = `var' (count) n=`var', by(maternaType City)
		replace sd_`var' = 0 if(sd_`var' == . )
		drop if (maternaType == 4 | maternaType >=.) // drop private or missing
		replace mean_`var' = . if n <=10 // replace to missing if too few obs
		replace n = . if n <=10 // replace to missing if too few obs
		
		generate hi = mean_`var' + invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate lo = mean_`var' - invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate zero = 0 //for putting the numbers on the x-axis

		generate se = sd_`var' / sqrt(n)

		generate maternaCity = maternaType      if City == 1
		replace  maternaCity = maternaType + 6  if City == 2
		replace  maternaCity = maternaType + 12 if City == 3
		
		twoway (bar mean_`var' maternaCity if maternaType==0) ///
     	 	 (bar mean_`var' maternaCity if maternaType==1)   ///
      		 (bar mean_`var' maternaCity if maternaType==2)   ///
      	 	 (bar mean_`var' maternaCity if maternaType==3)   ///
       	 	 (bar mean_`var' maternaCity if maternaType==4)   ///
       	 	 (scatter zero maternaCity, ms(i) mlab(n) mlabpos(6) mlabcolor(black)) /// mean_`var' 
       	 	 (rcap hi lo maternaCity, lcolor(red)), ///
        	 legend(order(1 "Not Attended" 2 "Municipal" 3 "State" 4 "Religious")) /// 5 "Private"
         	 xlabel(2.05 "Reggio" 7.975 "Parma" 14.0 "Padova", noticks) ///
         	 xtitle("City and Materna Type") ytitle("Mean") title("`graph_title'")  ///
			 /// MAYBE HERE PUT THE SCALE ONLY IF mean_`var'<=1 & mean_`var'>=0
			 note("Source: RCH survey. Plot of means and their standard errors." "Number of obs. in each category at the bottom") ///
			 yscale(range(-0.2 1))  ylabel(#8)

		restore, preserve
	
		graph export `var'_Migrant.png, $graphExport //export the graph
		
		restore, not
}

* ------------------------------ Adolescents --------------------------------- *
foreach var of varlist `outcomes'{
		des `var'
		local lab: variable label `var' // save variable label in local `lab'
		local graph_title = "Adolescents - " + "`lab'" //create the graph's title through concatenation
	
		preserve
		keep if(Cohort == 3)
		collapse (mean) mean_`var'= `var' (sd) sd_`var' = `var' (count) n=`var', by(maternaType City)
		replace sd_`var' = 0 if(sd_`var' == . )
		drop if (maternaType == 4 | maternaType >=.) // drop private or missing
		replace mean_`var' = . if n <=10 // replace to missing if too few obs
		replace n = . if n <=10 // replace to missing if too few obs
		
		generate hi = mean_`var' + invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate lo = mean_`var' - invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate zero = 0 //for putting the numbers on the x-axis

		generate se = sd_`var' / sqrt(n)

		generate maternaCity = maternaType      if City == 1
		replace  maternaCity = maternaType + 6  if City == 2
		replace  maternaCity = maternaType + 12 if City == 3
		
		twoway (bar mean_`var' maternaCity if maternaType==0) ///
     	 	 (bar mean_`var' maternaCity if maternaType==1)   ///
      		 (bar mean_`var' maternaCity if maternaType==2)   ///
      	 	 (bar mean_`var' maternaCity if maternaType==3)   ///
       	 	 (bar mean_`var' maternaCity if maternaType==4)   ///
       	 	 (scatter zero maternaCity, ms(i) mlab(n) mlabpos(6) mlabcolor(black)) /// mean_`var' 
       	 	 (rcap hi lo maternaCity, lcolor(red)), ///
        	 legend(order(1 "Not Attended" 2 "Municipal" 3 "State" 4 "Religious")) /// 5 "Private"
         	 xlabel(2.05 "Reggio" 7.975 "Parma" 14.0 "Padova", noticks) ///
         	 xtitle("City and Materna Type") ytitle("Mean") title("`graph_title'")  ///
			 /// MAYBE HERE PUT THE SCALE ONLY IF mean_`var'<=1 & mean_`var'>=0
			 note("Source: RCH survey. Plot of means and their standard errors." "Number of obs. in each category at the bottom") ///
			 yscale(range(-0.2 1))  ylabel(#8)
         	 
		restore, preserve
	
		graph export `var'_Ado.png, $graphExport //export the graph
		
		restore, not
}

* -------------------------------- Adult 30 ---------------------------------- *
foreach var of varlist `outAdult'{
		des `var'
		
		local lab: variable label `var' // save variable label in local `lab'
		local graph_title = "Adult 30 - " + "`lab'" //create the graph's title through concatenation
	
		preserve
		keep if(Cohort == 4)
		collapse (mean) mean_`var'= `var' (sd) sd_`var' = `var' (count) n=`var', by(maternaType City)
		replace sd_`var' = 0 if(sd_`var' == . )
		drop if (maternaType == 4 | maternaType >=.) // drop private or missing
		replace mean_`var' = . if n <=10 // replace to missing if too few obs
		replace n = . if n <=10 // replace to missing if too few obs
		
		generate hi = mean_`var' + invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate lo = mean_`var' - invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate zero = 0 //for putting the numbers on the x-axis

		generate se = sd_`var' / sqrt(n)

		generate maternaCity = maternaType      if City == 1
		replace  maternaCity = maternaType + 6  if City == 2
		replace  maternaCity = maternaType + 12 if City == 3
		
		twoway (bar mean_`var' maternaCity if maternaType==0) ///
     	 	 (bar mean_`var' maternaCity if maternaType==1)   ///
      		 (bar mean_`var' maternaCity if maternaType==2)   ///
      	 	 (bar mean_`var' maternaCity if maternaType==3)   ///
       	 	 (bar mean_`var' maternaCity if maternaType==4)   ///
       	 	 (scatter zero maternaCity, ms(i) mlab(n) mlabpos(6) mlabcolor(black)) /// mean_`var' 
       	 	 (rcap hi lo maternaCity, lcolor(red)), ///
        	 legend(order(1 "Not Attended" 2 "Municipal" 3 "State" 4 "Religious")) /// 5 "Private"
         	 xlabel(2.05 "Reggio" 7.975 "Parma" 14.0 "Padova", noticks) ///
         	 xtitle("City and Materna Type") ytitle("Mean") title("`graph_title'")  ///
			 /// MAYBE HERE PUT THE SCALE ONLY IF mean_`var'<=1 & mean_`var'>=0
			 note("Source: RCH survey. Plot of means and their standard errors." "Number of obs. in each category at the bottom") ///
			 yscale(range(-0.2 1))  ylabel(#8)
		
		restore, preserve
	
		graph export `var'_Adult30.png, $graphExport //export the graph
		
		restore, not
}

* -------------------------------- Adult 40 ---------------------------------- *
foreach var of varlist `outAdult'{
		des `var'

		local lab: variable label `var' // save variable label in local `lab'
		local graph_title = "Adult 40 - " + "`lab'" //create the graph's title through concatenation
	
		preserve
		keep if(Cohort == 5)
		collapse (mean) mean_`var'= `var' (sd) sd_`var' = `var' (count) n=`var', by(maternaType City)
		replace sd_`var' = 0 if(sd_`var' == . )
		drop if (maternaType == 4 | maternaType >=.) // drop private or missing
		replace mean_`var' = . if n <=10 // replace to missing if too few obs
		replace n = . if n <=10 // replace to missing if too few obs
		
		generate hi = mean_`var' + invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate lo = mean_`var' - invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate zero = 0 //for putting the numbers on the x-axis

		generate se = sd_`var' / sqrt(n)

		generate maternaCity = maternaType      if City == 1
		replace  maternaCity = maternaType + 6  if City == 2
		replace  maternaCity = maternaType + 12 if City == 3
		
		twoway (bar mean_`var' maternaCity if maternaType==0) ///
     	 	 (bar mean_`var' maternaCity if maternaType==1)   ///
      		 (bar mean_`var' maternaCity if maternaType==2)   ///
      	 	 (bar mean_`var' maternaCity if maternaType==3)   ///
       	 	 (bar mean_`var' maternaCity if maternaType==4)   ///
       	 	 (scatter zero maternaCity, ms(i) mlab(n) mlabpos(6) mlabcolor(black)) /// mean_`var' 
       	 	 (rcap hi lo maternaCity, lcolor(red)), ///
        	 legend(order(1 "Not Attended" 2 "Municipal" 3 "State" 4 "Religious")) /// 5 "Private"
         	 xlabel(2.05 "Reggio" 7.975 "Parma" 14.0 "Padova", noticks) ///
         	 xtitle("City and Materna Type") ytitle("Mean") title("`graph_title'")  ///
			 /// MAYBE HERE PUT THE SCALE ONLY IF mean_`var'<=1 & mean_`var'>=0
			 note("Source: RCH survey. Plot of means and their standard errors." "Number of obs. in each category at the bottom") ///
			 yscale(range(-0.2 1))  ylabel(#8)
		restore, preserve
	
		graph export `var'_Adult40.png, $graphExport //export the graph
		
		restore, not
}

* -------------------------------- Adult 50 ---------------------------------- *
foreach var of varlist `outAdult'{
		des `var'

		local lab: variable label `var' // save variable label in local `lab'
		local graph_title = "Adult 50 - " + "`lab'" //create the graph's title through concatenation
	
		preserve
		keep if(Cohort == 6)
		collapse (mean) mean_`var'= `var' (sd) sd_`var' = `var' (count) n=`var', by(maternaType City)
		replace sd_`var' = 0 if(sd_`var' == . )
		drop if (maternaType == 4 | maternaType >=.) // drop private or missing
		replace mean_`var' = . if n <=10 // replace to missing if too few obs
		replace n = . if n <=10 // replace to missing if too few obs
		
		generate hi = mean_`var' + invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate lo = mean_`var' - invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate zero = 0 //for putting the numbers on the x-axis

		generate se = sd_`var' / sqrt(n)

		generate maternaCity = maternaType      if City == 1
		replace  maternaCity = maternaType + 6  if City == 2
		replace  maternaCity = maternaType + 12 if City == 3
		
		twoway (bar mean_`var' maternaCity if maternaType==0) ///
     	 	 (bar mean_`var' maternaCity if maternaType==1)   ///
      		 (bar mean_`var' maternaCity if maternaType==2)   ///
      	 	 (bar mean_`var' maternaCity if maternaType==3)   ///
       	 	 (bar mean_`var' maternaCity if maternaType==4)   ///
       	 	 (scatter zero maternaCity, ms(i) mlab(n) mlabpos(6) mlabcolor(black)) /// mean_`var' 
       	 	 (rcap hi lo maternaCity, lcolor(red)), ///
        	 legend(order(1 "Not Attended" 2 "Municipal" 3 "State" 4 "Religious")) /// 5 "Private"
         	 xlabel(2.05 "Reggio" 7.975 "Parma" 14.0 "Padova", noticks) ///
         	 xtitle("City and Materna Type") ytitle("Mean") title("`graph_title'")  ///
			 /// MAYBE HERE PUT THE SCALE ONLY IF mean_`var'<=1 & mean_`var'>=0
			 note("Source: RCH survey. Plot of means and their standard errors." "Number of obs. in each category at the bottom") ///
			 yscale(range(-0.2 1))  ylabel(#8)

		restore, preserve
	
		graph export `var'_Adult50.png, $graphExport //export the graph
		
		restore, not
}

* ------------------------------- All Adults --------------------------------- *
foreach var of varlist `outAdult'{
		des `var'
		local lab: variable label `var' // save variable label in local `lab'
		local graph_title = "All Adults - " + "`lab'" //create the graph's title through concatenation
	
		preserve
		keep if(Cohort > 3)
		collapse (mean) mean_`var'= `var' (sd) sd_`var' = `var' (count) n=`var', by(maternaType City)
		replace sd_`var' = 0 if(sd_`var' == . )
		drop if (maternaType == 4 | maternaType >=.) // drop private or missing
		replace mean_`var' = . if n <=10 // replace to missing if too few obs
		replace n = . if n <=10 // replace to missing if too few obs
		
		generate hi = mean_`var' + invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate lo = mean_`var' - invttail(n,0.025)*(sd_`var' / sqrt(n))
		generate zero = 0 //for putting the numbers on the x-axis

		generate se = sd_`var' / sqrt(n)

		generate maternaCity = maternaType      if City == 1
		replace  maternaCity = maternaType + 6  if City == 2
		replace  maternaCity = maternaType + 12 if City == 3
		
		twoway (bar mean_`var' maternaCity if maternaType==0) ///
     	 	 (bar mean_`var' maternaCity if maternaType==1)   ///
      		 (bar mean_`var' maternaCity if maternaType==2)   ///
      	 	 (bar mean_`var' maternaCity if maternaType==3)   ///
       	 	 (bar mean_`var' maternaCity if maternaType==4)   ///
       	 	 (scatter zero maternaCity, ms(i) mlab(n) mlabpos(6) mlabcolor(black)) /// mean_`var' 
       	 	 (rcap hi lo maternaCity, lcolor(red)), ///
        	 legend(order(1 "Not Attended" 2 "Municipal" 3 "State" 4 "Religious")) /// 5 "Private"
         	 xlabel(2.05 "Reggio" 7.975 "Parma" 14.0 "Padova", noticks) ///
         	 xtitle("City and Materna Type") ytitle("Mean") title("`graph_title'")  ///
			 /// MAYBE HERE PUT THE SCALE ONLY IF mean_`var'<=1 & mean_`var'>=0
			 note("Source: RCH survey. Plot of means and their standard errors." "Number of obs. in each category at the bottom") ///
			 yscale(range(-0.2 1))  ylabel(#8)

		
		restore, preserve
	
		graph export `var'_AllAdults.png, $graphExport //export the graph
		
		restore, not
}

}
