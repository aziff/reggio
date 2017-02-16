/* --------------------------------------------------------------------------- *
* Calling IV function
* Created: 2/14/2017

* --------------------------------------------------------------------------- */
foreach city in Reggio{
	foreach cohort in child adol{
		
		*Preliminaries*
		clear all
		
		global klmReggio   : env klmReggio
		global data_reggio : env data_reggio
		global git_reggio  : env git_reggio
		global here : pwd
		
				
		*Call data and include relevant functions/macros*
		use "${data_reggio}/Reggio_reassigned"
		include "${here}/../macros" 
		include "${here}/function/ivanalysis"
		include "${here}/function/writematrix"
		
				
		*Keep relevant observations*
		if ("`cohort'"=="child") keep if Cohort<3
		if ("`cohort'"=="adol") keep if Cohort==3
		drop if asilo == 1
				

		***Manipulating instruments to prepare for ivregress***
		
		*Reggio Score Instrument*
		gen score25 = (score <= r(p25))
		gen score50 = (score > r(p25) & score <= r(p50))
		gen score75 = (score > r(p50) & score <= r(p75))
		
		label var score25 "25th pct of RA admission score"
		label var score50 "50th pct of RA admission score"
		label var score75 "75th pct of RA admission score"
		
		/*
		*Cost Instrument* -- Decided not to use because we get very little 
		 variation in cost. Cost is designed to vary by parent's income, but
		 we don't have a complete income variable (missing data). Further, our 
		 cost data doesn't capture variation in cost by school, only by school-type
		
		local maternaCost
		foreach t in Muni /*Reli Stat*/{
			rename Fees_med_full_materna`t'_3 effective_medianFee_materna`t'
			local maternaCost `maternaCost' effective_medianFee_materna`t'
		} 			/*_3, _2 and _1 correspond to ages 3, 2 and 1 respectively */

		local asiloCost
		foreach  t in Muni Reli{
			rename Fees_med_full_asilo`t'_1 effective_medianFee_asilo`t'
			local asiloCost `asiloCost' effective_medianFee_asilo`t'
		} 			/*_3, _2 and _1 correspond to ages 3, 2 and 1 respectively */
		*/
		
		*Define global macros*
		global ivlist					IV`cohort'
		global ifconditionIVchild		(`city' == 1) & (Cohort < 3) 
		global ifconditionIVadol		(`city' == 1) & (Cohort == 3) 
		
		global controlsNone
		global controlsIV`cohort'		${bic_`cohort'_baseline_vars}
		global controlsFull				${`cohort'_baseline_vars}
		
		global endog					maternaMuni
		global IVmaterna_root			grandDist score_sib momPA_Unempl dadPA_Unempl momPA_HouseWife momMigrant noDad fullTime cgHrsWork lone_parent ///
										distMaternaMunicipal1 distMaternaPrivate1 distMaternaReligious1
		global IVmaterna_components		score_sib score_unemp score_ado score_migr score_tea score_full score_student score_ore score_lone score_nonni ///
										distMaternaMunicipal1 distMaternaPrivate1 distMaternaReligious1
		global IVmaterna_fullscore		score distMaternaMunicipal1 distMaternaPrivate1 distMaternaReligious1
		global IVasilo					grandDist score_sib momPA_Unempl dadPA_Unempl momMigrant fullTime distAsiloMunicipal1 distAsiloPrivate1 distAsiloReligious1
		
		
		*----------------------------------------------------------------------*
		* Time to call the ivanalysis function
		*----------------------------------------------------------------------*
		global IVinstruments ${IVasilo}
		local stype_switch = 1
		
		foreach stype in Other None /*Stat Reli*/ {			
			foreach type in M E W L H N S {

				* ----------------------- *
				* For IV Analysis *
				* ----------------------- *
				* Open necessary files
				cap file close iv_`type'_`stype'
				file open iv_`type'_`stype' using "${git_reggio}/output/multiple-methods/combinedanalysis/csv/iv_`cohort'_`type'_`stype'.csv", write replace

				* Run Multiple Analysis
				di "Estimating `type' for Adult: IV Analysis"
				ivanalysis, stype("`stype'") type("`type'") ivlist("${ivlist}") cohort("`cohort'")
			
				* Close necessary files
				file close iv_`type'_`stype' 
				
			}
			
			local stype_switch = 0
		}
	}
}
