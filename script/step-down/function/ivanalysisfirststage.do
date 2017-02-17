/* ---------------------------------------------------------------------------- *
* Programming an IV function for Reggio analysis (Step-down)
* Author: Sidharth Moktan, Jessica Yu Kyung Koh
* Edited: 2/16/2017

* Note: The purpose of this function is to generate csv file that contains
        point estimates, standard errors, p-values, and # of observations for
		different methodology. Since some methods we use are not regression 
		analysis, we cannot use commands like "estout" or "esttab". 
		
		The csv files created will be merged in other do files to produce
		presentable tables that combine methodologies. 
* ---------------------------------------------------------------------------- */
capture program drop firstStageIV
capture program define firstStageIV

version 13
syntax, stype(string) ivlist(string) cohort(string)

	*-------------*
	*First Stage:
	*-------------*
	foreach comp in ${ivlist} {
		reg $endog $IVinstruments ${controls`comp'} if ${ifcondition`comp'}, robust
		
		mat firstStage = r(table)
	
		local firstStage_N					:di %3.0f `= e(N)'
		local firstStage_R					:di %3.2f `= e(r2)'
		local firstStage_adjR				:di %3.2f `= e(r2_a)'
		local firstStage_F					:di %3.2f `= e(F)'
		
		local header_switch header
		local ivcount = 1
		foreach instrument in $IVinstruments{
			local firstStageItems
			local firstStageNames
			
			local firstStage_`ivcount' 		:di %3.2f `= firstStage[1,`ivcount']'
			local firstStage_`ivcount'_se 	:di %3.2f `=  firstStage[2,`ivcount']'
			local firstStage_`ivcount'_p	:di %3.2f `= firstStage[4,`ivcount']'
			
			
			local firstStageItems 	`firstStageItems' `firstStage_`ivcount'', `firstStage_`ivcount'_se', `firstStage_`ivcount'_p', ///
									`firstStage_N', `firstStage_R', `firstStage_adjR', `firstStage_F'
									
			local firstStageNames	`firstStageNames' coef se p N R adjR F 
					
			mat first = [`firstStageItems']
			mat colname first = `firstStageNames'
		
			writematrix, output(ivfirststage_`cohort') rowname("${`instrument'_lab}") matrix(first) `header_switch'
			
			local header_switch
			local ivcount = `ivcount'+1
		}
	}	
	
	
end
