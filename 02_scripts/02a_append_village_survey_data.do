*************************************************************************************************************************************
*! version 1.0  | 19 July 2021 | Hemanshu Kumar 
*  this file is part of the SRIJAN project headed by Rohini Somanathan, Priyanka Arora and Hemanshu Kumar
*************************************************************************************************************************************  


project , original("../01_data/village_survey_data/asha survey/V1/conflicts.dta")
project , original("../01_data/village_survey_data/asha survey/V1/disease_roster.dta")
project , original("../01_data/village_survey_data/asha survey/V1/gathering_roster.dta")
project , original("../01_data/village_survey_data/asha survey/V1/health_roster.dta")
project , original("../01_data/village_survey_data/asha survey/V1/srijan_project_asha.dta")
project , original("../01_data/village_survey_data/asha survey/V1/vaccn_awareness.dta")
project , original("../01_data/village_survey_data/asha survey/V1/wedding_roster.dta")


project , original("../01_data/village_survey_data/asha survey/V2/conflicts.dta")
project , original("../01_data/village_survey_data/asha survey/V2/disease_roster.dta")
project , original("../01_data/village_survey_data/asha survey/V2/gathering_roster.dta")
project , original("../01_data/village_survey_data/asha survey/V2/health_roster.dta")
project , original("../01_data/village_survey_data/asha survey/V2/srijan_project_asha.dta")
project , original("../01_data/village_survey_data/asha survey/V2/vaccn_awareness.dta")
project , original("../01_data/village_survey_data/asha survey/V2/wedding_roster.dta")


project , original("../01_data/village_survey_data/main survey/V1/conflicts.dta")
project , original("../01_data/village_survey_data/main survey/V1/covid.dta")
project , original("../01_data/village_survey_data/main survey/V1/disease_roster.dta")
project , original("../01_data/village_survey_data/main survey/V1/drinking_water.dta")
project , original("../01_data/village_survey_data/main survey/V1/edu.dta")
project , original("../01_data/village_survey_data/main survey/V1/facilities.dta")
project , original("../01_data/village_survey_data/main survey/V1/fuel_source.dta")
project , original("../01_data/village_survey_data/main survey/V1/gathering_roster.dta")
project , original("../01_data/village_survey_data/main survey/V1/gender.dta")
project , original("../01_data/village_survey_data/main survey/V1/health_roster.dta")
project , original("../01_data/village_survey_data/main survey/V1/houses.dta")
project , original("../01_data/village_survey_data/main survey/V1/marriage_roster.dta")
project , original("../01_data/village_survey_data/main survey/V1/ntfp.dta")
project , original("../01_data/village_survey_data/main survey/V1/social_security.dta")
project , original("../01_data/village_survey_data/main survey/V1/srijan_project.dta")
project , original("../01_data/village_survey_data/main survey/V1/timeline.dta")
project , original("../01_data/village_survey_data/main survey/V1/vaccn_awareness.dta")



project , original("../01_data/village_survey_data/main survey/V2/drinking_water.dta")
project , original("../01_data/village_survey_data/main survey/V2/edu.dta")
project , original("../01_data/village_survey_data/main survey/V2/facilities.dta")
project , original("../01_data/village_survey_data/main survey/V2/fuel_source.dta")
project , original("../01_data/village_survey_data/main survey/V2/gender.dta")
project , original("../01_data/village_survey_data/main survey/V2/houses.dta")
project , original("../01_data/village_survey_data/main survey/V2/ntfp.dta")
project , original("../01_data/village_survey_data/main survey/V2/social_security.dta")
project , original("../01_data/village_survey_data/main survey/V2/srijan_project.dta")
project , original("../01_data/village_survey_data/main survey/V2/timeline.dta")



project , original("02aa_import_village_survey_programs.do")


	run "02aa_import_village_survey_programs.do"


	******************************************************************************************************
	**# 1. Import data from each version of the main survey, append those, and fix some variables
	******************************************************************************************************	
	
	local versions V1 V2

	foreach ver of local versions {
		import_village_data, version(`ver') datafolder("../01_data/village_survey_data/main survey") tempfolder("../04_temp")
	}

	clear
	save "../04_temp/srijan_village_survey_data_main_appended", replace emptyok
	

	foreach ver of local versions {
		append using "../04_temp/srijan_version_`ver'"
	} 

	compress

	* two questions, q305A and q306A were wrongly created as list questions, and with no list cap
	* we get rid of the empty variables created

	forval i = 0/199 {
		foreach var of varlist q305A_int_curr_des__`i' q306A_int_past_des__`i' {
			capture assert missing(`var') | `var' == "##N/A##"
			if _rc == 0 drop `var'
		}
	}
	
	replace q001_resp_name_asha = "" if q001_resp_name_asha == "##N/A##"
	
	save "../04_temp/srijan_village_survey_data_main_appended", replace


	******************************************************************************************************
	**# 2. Import data from each version of the ASHA worker survey, fix some variables, and append the data
	******************************************************************************************************	
	
	local versions V1 V2
	foreach ver of local versions {
		import_village_data, version(`ver') datafolder("../01_data/village_survey_data/asha survey") tempfolder("../04_temp") asha 
	}
	
	** changing variables for ASHA version 2	
	use "../04_temp/srijan_asha_version_V1", clear
	
	tostring q827_vaccn_start_45plus q826_vaccn_start_18plus, replace	
	rename q912_pads_month_pre q912_pads_month_pre_girls	
	rename q914_pads_month_post q914_pads_month_post_girls
	
	save "../04_temp/srijan_asha_version_V1", replace
	
	** changing variables for ASHA version 2
	
	use "../04_temp/srijan_asha_version_V2", clear
	
	rename q912_pads_month_pre q912_pads_month_pre_asha
	rename q914_pads_months_post q914_pads_month_post_asha	
	save "../04_temp/srijan_asha_version_V2", replace
	
	** generating empty datasets to append both versions
	
	clear
	save "../04_temp/srijan_village_survey_data_asha_appended", replace emptyok
	
	** appending versions of ASHA survey
	
	foreach ver of local versions {
		append using "../04_temp/srijan_asha_version_`ver'"
	} 
	
	** renaming variables in ASHA survey
	
	foreach var of varlist assignment__id interview__status has__errors sssys_irnd interview__key interview__id village_name {
			rename `var' `var'_asha
	}

	compress	
	save "../04_temp/srijan_village_survey_data_asha_appended", replace
	
	******************************************************************************************************
	**# 3. Merge data from the main survey with the ASHA survey
	******************************************************************************************************	
		
	use "../04_temp/srijan_village_survey_data_main_appended", clear
	merge 1:1 village_id using "../04_temp/srijan_village_survey_data_asha_appended", update gen(_m_asha) assert (1 2 4 5)
	
	assert village_id == "0484185" if _m_asha == 5 // the surveyor name for the ASHA survey (surveyor_3) conflicts here; this is fine

	
	save "../04_temp/srijan_village_survey_data_merged", replace
	
project , creates("../04_temp/srijan_version_V1.dta")
project , creates("../04_temp/srijan_version_V2.dta")
project , creates("../04_temp/srijan_asha_version_V1.dta")
project , creates("../04_temp/srijan_asha_version_V2.dta")
project, creates("../04_temp/srijan_village_survey_data_main_appended.dta")
project, creates("../04_temp/srijan_village_survey_data_asha_appended.dta")
project, creates("../04_temp/srijan_village_survey_data_merged.dta")


