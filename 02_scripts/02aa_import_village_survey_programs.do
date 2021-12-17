*************************************************************************************************************************************
*! version 1.0  | 19 July 2021 | Sreya Majumder and Hemanshu Kumar
*  this file is part of the SRIJAN project headed by Rohini Somanathan, Priyanka Arora and Hemanshu Kumar
*************************************************************************************************************************************  



***************************************************************************************************
** program to reshape rosters in the survey data
***************************************************************************************************

capture program drop reshape_roster
program define reshape_roster
	syntax anything, i(varlist) j(varname)
	
	if strpos("`: type `j''","str")>0 local string = "string"
		else local string
	
	unab x: `anything'
	local y
	foreach var of local x {
		local var = "`=substr("`var'",1,5)'@`=substr("`var'",6,.)'"
		local y "`y' `var'"
	}

	reshape wide `y', i(`i') j(`j') `string'

	* if `j' is a string variable it must be because the original j variable is two digit; we adjust accordingly
	
	
	foreach var of local y {
		local prefix = "`=substr("`var'",1,5)'"
		local suffix = "`=substr("`var'",7,.)'"
		rename `prefix'#`suffix' `prefix'`suffix'_#
		
	}
end


***************************************************************************************************
** program to import data for each version of the village survey
***************************************************************************************************

capture program drop import_village_data
program define import_village_data
	syntax , VERsion(name) DATAfolder(string) TEMPfolder(string) [ASHA]
	
	if "`asha'" != "" {
		local rosters conflicts disease_roster gathering_roster health_roster vaccn_awareness wedding_roster
	}
	
	if "`asha'" == "" {
		local rosters edu drinking_water facilities fuel_source gender houses ntfp social_security timeline 

	if "`version'" == "V1" {
		local rosters `rosters'	covid disease_roster gathering_roster health_roster marriage_roster vaccn_awareness
	}
	}
	
	**************************************
	** Roster in section 2: edu
	**************************************
	
	local this_roster edu
	
	if `:list this_roster in rosters' == 1 {
		use "`datafolder'/`version'/edu", clear
		reshape_roster q* sum_edu_n, i(interview__id interview__key) j(edu__id)
		save "`tempfolder'/reshaped_edu_`version'", replace
	}
	
	**************************************
	** Roster in section 1.4: conflicts
	**************************************

	local this_roster conflicts
	
	if `:list this_roster in rosters' == 1 {
		use "`datafolder'/`version'/conflicts", clear	
		reshape_roster conflict_rank, i(interview__id interview__key) j(conflicts__id)
		save "`tempfolder'/reshaped_conflicts_`version'", replace
		
	}
	
	**************************************
	** Roster in section 4: covid
	**************************************

	local this_roster covid
	
	if `:list this_roster in rosters' == 1 {	
		use "`datafolder'/`version'/covid", clear
		reshape_roster q*, i(interview__id interview__key) j(covid__id)
		save "`tempfolder'/reshaped_covid_`version'", replace
	}

	**************************************
	** Roster in section 4: disease
	**************************************

	local this_roster disease_roster
	
	if `:list this_roster in rosters' == 1 {
		use "`datafolder'/`version'/disease_roster", clear
		reshape_roster q*, i(interview__id interview__key) j(disease_roster__id)	
		save "`tempfolder'/reshaped_disease_roster_`version'", replace
	}

	**************************************
	** Roster in section 4: drinking water
	**************************************

	local this_roster drinking_water	
	
	if `:list this_roster in rosters' == 1 {	
		use "`datafolder'/`version'/drinking_water", clear
		reshape_roster q* , i(interview__id interview__key) j(drinking_water__id)
		save "`tempfolder'/reshaped_drinking_water_`version'", replace
	}

	*********************************************
	** Roster in section 5: facilities
	*********************************************

	local this_roster facilities
	
	if `:list this_roster in rosters' == 1 {
		use "`datafolder'/`version'/facilities", clear
		reshape_roster q* , i(interview__id interview__key) j(facilities__id)
		save "`tempfolder'/reshaped_facilities_`version'", replace
	}
	
	*********************************************
	** Roster in section 5: fuel source
	*********************************************
	
	local this_roster fuel_source
	
	if `:list this_roster in rosters' == 1 {
		use "`datafolder'/`version'/fuel_source", clear
		reshape_roster q*, i(interview__id interview__key) j(fuel_source__id)
		save "`tempfolder'/reshaped_fuel_source_`version'", replace
	}
	
	*********************************************
	** Roster in section 5: gathering
	*********************************************

	local this_roster gathering_roster
	
	if `:list this_roster in rosters' == 1 {	
		use "`datafolder'/`version'/gathering_roster", clear
		reshape_roster q* , i(interview__id interview__key) j(gathering_roster__id)
		save "`tempfolder'/reshaped_gathering_roster_`version'", replace
	}
	
	*********************************************
	** Roster in section 5: gender
	*********************************************

	local this_roster gender	

	if `:list this_roster in rosters' == 1 {
		use "`datafolder'/`version'/gender", clear
		reshape_roster q* , i(interview__id interview__key) j(gender__id)
		save "`tempfolder'/reshaped_gender_`version'", replace
	}
	
	*********************************************
	** Roster in section 5: health
	*********************************************

	local this_roster health_roster
	
	if `:list this_roster in rosters' == 1 {	
		use "`datafolder'/`version'/health_roster", clear
		reshape_roster q* , i(interview__id interview__key) j(health_roster__id)
		save "`tempfolder'/reshaped_health_roster_`version'", replace
	}
	
	*********************************************
	** Roster in section 5: houses
	*********************************************

	local this_roster houses
	
	if `:list this_roster in rosters' == 1 {
		use "`datafolder'/`version'/houses", clear
		reshape_roster q* , i(interview__id interview__key) j(houses__id)
		save "`tempfolder'/reshaped_houses_`version'", replace
	}
	
	*********************************************
	** Roster in section 5: marriage
	*********************************************

	local this_roster marriage_roster
	
	if `:list this_roster in rosters' == 1 {	
		use "`datafolder'/`version'/marriage_roster", clear
		reshape_roster q* , i(interview__id interview__key) j(marriage_roster__id)
		save "`tempfolder'/reshaped_marriage_roster_`version'", replace
	}
	
	*********************************************
	** Roster in section 5: ntfp
	*********************************************

	local this_roster ntfp
	
	if `:list this_roster in rosters' == 1 {
		use "`datafolder'/`version'/ntfp", clear
		reshape_roster q* NTFP_name, i(interview__id interview__key) j(ntfp__id)	
		save "`tempfolder'/reshaped_ntfp_`version'", replace
	}
	
	*********************************************
	** Roster in section 5: social security
	*********************************************

	local this_roster social_security
	
	if `:list this_roster in rosters' == 1 {	
		use "`datafolder'/`version'/social_security", clear
		reshape_roster q* , i(interview__id interview__key) j(social_security__id)
		save "`tempfolder'/reshaped_social_security_`version'", replace
	}
	
	*********************************************
	** Roster in section 5: timeline
	*********************************************

	local this_roster timeline
	
	if `:list this_roster in rosters' == 1 {
		use "`datafolder'/`version'/timeline", clear
		reshape_roster q* , i(interview__id interview__key) j(timeline__id)
		save "`tempfolder'/reshaped_timeline_`version'", replace
	}
	
	*********************************************
	** Roster in section 5: vaccination awareness
	*********************************************

	local this_roster vaccn_awareness
	
	if `:list this_roster in rosters' == 1 {
		use "`datafolder'/`version'/vaccn_awareness", clear
		reshape_roster q* , i(interview__id interview__key) j(vaccn_awareness__id)
		save "`tempfolder'/reshaped_vaccn_awareness_`version'", replace
	}

	*********************************************
	** Roster: weddings
	*********************************************
	local this_roster wedding_roster
	
	if `:list this_roster in rosters' == 1 {
		use "`datafolder'/`version'/wedding_roster", clear
		reshape_roster q* weddings_sum_agewise, i(interview__id interview__key) j(wedding_roster__id)
		save "`tempfolder'/reshaped_wedding_roster_`version'", replace
	}

	***************************************************************************************************
	** now we merge the main dataset with all the rosters and delete intermediate files
	***************************************************************************************************
	
	if "`datafolder'" == "../01_data/village_survey_data/main survey" {
		use "`datafolder'/`version'/srijan_project", clear
	
		foreach roster of local rosters {
			merge 1:1 interview__id interview__key using "../04_temp/reshaped_`roster'_`version'", gen(_m_`roster') assert(1 3)
			erase "../04_temp/reshaped_`roster'_`version'.dta"
		}
	
		note: This dataset has been created from data exported  on `=c(filedate)' for main questionnaire version `version'.
		gen main_version = "`version'"
		label var main_version "Main survey version"
		compress
		save "../04_temp/srijan_version_`version'", replace
	}
	
	if "`datafolder'" == "../01_data/village_survey_data/asha survey" {
		use "`datafolder'/`version'/srijan_project_asha", clear
	
		foreach roster of local rosters {
			merge 1:1 interview__id interview__key using "../04_temp/reshaped_`roster'_`version'", gen(_m_asha_`roster') assert(1 3)
			erase "../04_temp/reshaped_`roster'_`version'.dta"
		}
	
	
		note: This dataset has been created from data exported  on `=c(filedate)' for asha questionnaire version `version'.
		gen asha_version = "`version'"
		label var asha_version "ASHA survey version"
		compress
		save "../04_temp/srijan_asha_version_`version'", replace
	}
end

