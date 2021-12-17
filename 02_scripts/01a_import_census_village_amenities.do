*********************************************************************************************************************
*! version 1.0 dated 18 July 2021 by Hemanshu Kumar | first version to comply with Picard's -project- command
* -- contains code that was earlier part of srijan_sampling.do 
* This do-file is used to import census 2011 village amenities data 
* This file is part of the SRIJAN Project (headed by Rohini Somanathan, Priyanka Arora, Hemanshu Kumar, et al)
*********************************************************************************************************************

project , original("../01_data/census_2011_data/census_2011_village_amenities/DCHB_Village_Release_0800.csv")
project , original("../01_data/census_2011_data/census_2011_village_amenities/DCHB_Village_Release_2200.csv")
project , original("../01_data/census_2011_data/census_2011_village_amenities/DCHB_Village_Release_2300.csv")


	* list of states to which the locations belong
	#delimit ;
	local state_codes 
			08 /* Rajasthan */ 
			22 /* Chhattisgarh */
			23 /* Madhya Pradesh */
			;
	#delimit cr

	clear
	save "../03_processed/village_amenities_data", replace emptyok
	
	foreach st of local state_codes {
		import delimited "../01_data/census_2011_data/census_2011_village_amenities/DCHB_Village_Release_`st'00.csv", clear bindquotes(strict)
		drop if missing(statename)
		keep 	*statecode statename district* subdistrict* village* cdblock* grampanchayat* ///
				totalhouseholds totalpopulationofvillage totalscheduledcastespopulationof totalscheduledtribespopulationof ///
				totalgeographicalareainhectares forestareainhectares netareasowninhectares areairrigatedbysourceinhectares

		missings dropvars _all, force // drops any variables that have all values missing
		destring *area*, ignore("NA-") replace
		append using "../03_processed/village_amenities_data"
		save "../03_processed/village_amenities_data", replace		
	}

	* check that the census 2011 codes uniquely identify villages 
	
	use "../03_processed/village_amenities_data", clear
	distinct villagecode
	assert r(N) == r(ndistinct)
	
	* rename and label some variables and keep only those that are needed

	rename ?statecode state_code
	rename statename state_name
	rename districtcode district_code
	rename districtname district_name
	rename subdistrictcode subdistrict_code
	rename subdistrictname subdistrict_name
	rename cdblockcode block_code
	rename cdblockname block_name
	rename villagecode village_code
	rename villagename village_name
	* rename grampanchayatcode gp_code
	rename grampanchayatname gp_name
		
	label var state_code "State Code"
	
	foreach var of varlist *_code *_name {
		local lab: variable label `var'
		local lab = "Census 2011 `lab'"
		label var `var' "`lab'"
	}
	
	foreach var of varlist state_name district_name subdistrict_name block_name village_name {
		replace `var' = trim(itrim(`var'))
	}
	
	rename totalhouseholds total_hh
	rename totalpopulationofvillage total_pop
	rename totalscheduledcastespopulationof sc_pop
	rename totalscheduledtribespopulationof st_pop
	rename totalgeographicalareainhectares total_area
	rename netareasowninhectares netsown_area
	rename forestareainhectares forest_area
	rename areairrigatedbysourceinhectares irrigated_area

	keep *_code *_name total_* *_pop *_area
	
	compress
	save "../03_processed/village_amenities_data", replace
	

project , creates("../03_processed/village_amenities_data.dta")
