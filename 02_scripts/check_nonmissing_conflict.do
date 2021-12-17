use "../04_temp/srijan_village_survey_data_main_appended", clear
ds village_id, not

local inmain "`r(varlist)'"

use "../04_temp/srijan_village_survey_data_asha_appended", clear
tempfile asha
save `asha'

ds village_id, not

local inasha "`r(varlist)'"

local common: list inmain & inasha

dis "`common'"

use "../04_temp/srijan_village_survey_data_main_appended", clear

foreach var of varlist `common' {
	rename `var' m_`var'
}

merge 1:1 village_id using `asha'
keep if village_id == "0484185"

foreach var of varlist `common' {
	li m_`var' `var' if m_`var' ~= `var' & !missing(m_`var')
}

/*
use "../04_temp/srijan_version_V1", clear
ds
local inmainv1 "`r(varlist)'"

use "../04_temp/srijan_asha_version_V2", clear
drop if village_id == "0460858"
ds
local inashav2 "`r(varlist)'"
tempfile asha
save `asha'

local inboth: list inmainv1 & inashav2

dis "`inboth'"

use "../04_temp/srijan_version_V1", clear

foreach var of varlist `inboth' {
	if "`var'" ~= "village_id" rename `var' m_`var' 
}

merge 1:1 village_id using `asha'
keep if village_id == "0495183"

foreach var of varlist `inboth' {
	if "`var'" ~= "village_id" li m_`var' `var' if m_`var' ~= `var'
}
*/
