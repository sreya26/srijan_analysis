*********************************************************************************************************************
* This do-file is used for sampling non-SRIJAN villages 
* This file is part of the SRIJAN Project (headed by Rohini Somanathan, Priyanka Arora, Hemanshu Kumar, et al)
* version 2.0 dated 18 July 2021, by Hemanshu Kumar | modifications to make the program comply with Picard's -project- command
* version 1.0 dated 15 April 2021, by Hemanshu Kumar
* this code is used to sample non-SRIJAN villages that are neighbours of (or close to) sampled SRIJAN villages
* the set of neighbours was created by Saarthak Anand by looking at administrative maps in the relevant District Census Handbook (DCHB) pdfs for 2011. 
*********************************************************************************************************************

project , original("../01_data/sampling/srijan_village_neighbours.xlsx")
project , uses("../03_processed/village_amenities_srijan.dta")
project , uses("../03_processed/srijan_sample.dta")

	clear

	* specify number of villages to sample in each location
	local num_villages 15


	*********************************************************************************************************************
	* 1. read in information on non-SRIJAN villages that are close to the sampled SRIJAN villages
	* * the file with neighbour information was created by Saarthak Anand by visual examination of census 2011 administrative maps
	*********************************************************************************************************************	

	import excel using "../01_data/sampling/srijan_village_neighbours.xlsx", clear firstrow
	keep srijan_location serial_no district_name block_name village_code village_name total_pop n?_name n?_code n?_block n?_pop n?_dist

	reshape long n@_name n@_code n@_block n@_pop n@_dist, i(srijan_location serial_no district_name block_name village_code village_name total_pop) j(num)
	
	drop if missing(n_name)
	
	*********************************************************************************************************************
	* 2. preliminary checks, on missing information and inclusion of uninhabited villages
	*********************************************************************************************************************	
		
	* check if any information is missing
	assert !missing(n_code)
	assert !missing(n_block)
	assert !missing(n_pop)
	assert !missing(n_dist)
	
	* no neighbouring village should have a zero population
	assert n_pop != 0

	*********************************************************************************************************************
	* 3. drop any neighbours from non-SRIJAN districts
	*********************************************************************************************************************

	rename village_code srijan_village_code
	rename n_code village_code
	merge m:1 village_code using "../03_processed/village_amenities_srijan", keepusing(is_srijan_district)
	
	capture assert inlist(_merge,2,3)
	if _rc !=0 {
		dis as error _n "FATAL ERROR!!" _n "Some neighbouring villages have census codes that do not appear in the village amenities data!"
		br if _merge == 1
		exit
	}
	
	keep if _merge == 3
	drop _merge
	
	count if is_srijan_district == 0

	rename village_code n_code
	rename srijan_village_code village_code
	
	if `=r(N)' > 0 {
		dis as error _n "Warning!!" _n "The following neighbour villages are from non-SRIJAN districts, and will be dropped:"
		noi list srijan_location serial_no village_code village_name n_code n_name if is_srijan_district == 0
		drop if is_srijan_district == 0
	}
	
	drop is_srijan_district
	
	tempfile srijan_neighbours_long
	save `srijan_neighbours_long'
	
	*********************************************************************************************************************
	* 4. confirm that the neighbouring villages are not SRIJAN villages
	*********************************************************************************************************************
	
	* first make a list of unique neighbour villages

	drop srijan_location serial_no total_pop
	
	duplicates drop n_code, force
	drop if missing(n_name)
	
	order n_dist n_block n_code n_name
	keep n_dist n_block n_code n_name
	
	rename n_block neighbour_block
	rename n_code village_code
	rename n_name neighbour_village
	rename n_dist neighbour_distance

	tempfile neighbours
	save `neighbours'

	* now for a list of SRIJAN villages
	
	use "../03_processed/village_amenities_srijan", clear
	keep if is_srijan_village
	
	keep district_name block_name village_name village_code
	tempfile srijan_villages
	save `srijan_villages'
	
	* now merge the two; there should be no matches
	
	use `neighbours'
	capture merge 1:1 village_code using `srijan_villages', keepusing(district_name block_name village_name) assert(1 2)

	if _rc!=0 {
		dis as error _n "FATAL ERROR!!" _n "There are some neighbour villages that also appear in the SRIJAN village list."
		noi tab _merge
		br if _merge == 3
		exit
	}

	*********************************************************************************************************************
	* 5. confirm that the neighbouring villages are correctly coded
	* * this boils down to a simple check of whether the name corresponding to the village code in the census is the same
	* * and a similar check for block names
	*********************************************************************************************************************	
	
	use `neighbours', clear
	merge 1:1 village_code using "../03_processed/village_amenities_srijan", keepusing(village_name block_name) assert(2 3) keep(3) nogen
	capture assert trim(itrim(lower(neighbour_village))) == trim(itrim(lower(village_name))) 
	
	if _rc !=0 {
		dis as error _n "FATAL ERROR!!" _n "There are some mismatches in the neighbour village names between the census VD information and our file."
		br if (trim(itrim(lower(neighbour_village))) ~= trim(itrim(lower(village_name))))
		exit
	}

	capture assert trim(itrim(lower(neighbour_block))) == trim(itrim(lower(block_name)))
	if _rc !=0 {
		dis as error _n "FATAL ERROR!!" _n "There are some mismatches in the neighbour village block names between the census VD information and our file."
		br if (trim(itrim(lower(neighbour_block))) ~= trim(itrim(lower(block_name))))
		exit
	}
	
	*********************************************************************************************************************
	* 6. confirm that a non-SRIJAN village does not appear more than once in the list of neighbours of the same SRIJAN village
	*********************************************************************************************************************	
	
	use `srijan_neighbours_long', clear
	duplicates tag srijan_location village_code n_code, gen(tag)
	capture assert tag == 0

	if _rc != 0 {
		dis as error _n "FATAL ERROR!!" _n "The following villages occur in the list of neighbours of the same SRIJAN village more than once:"
		sort srijan_location village_code
		noi list srijan_location village_code village_name n_code n_name if tag
		exit
	}


	*********************************************************************************************************************
	* 7. if a village is a neighbour of more than one SRIJAN village, it should not be the ONLY neighbour 
	* in more than one of those SRIJAN villages
	*********************************************************************************************************************	
	
	use `srijan_neighbours_long', clear
	egen total_neighbours = count(n_code), by(village_code)
	
	duplicates tag n_code, gen(tag)
	egen num_solo = total(total_neighbours == 1), by(n_code)
	
	capture assert num_solo <=1 if tag
	
	if _rc != 0 {
		dis as error _n "FATAL ERROR!!" _n "We have some situations where a village is a neighbour of more than one SRIJAN village and "
		dis as error "moreover, it is the ONLY neighbour of more than one of those SRIJAN villages."
		sort srijan_location n_code n_name village_code village_name
		noi list srijan_location village_code village_name n_code n_name if tag & num_solo>1
		exit
	}
	
	*********************************************************************************************************************
	* 8. merge in census information for neighbouring villages
	* and generate sampling preference order across neighbours of each SRIJAN village
	* our sampling preference order is lexicographic, as follows:
	* * choose non-SRIJAN village at lowest distance (starting with neighbours with shared boundaries, which are coded as 0 distance) 
	* * within that, prefer a village in the same district to that in a different district
	* * within that, prefer a village in the same block to that in a different block
	* * within that, prefer a village that is closest in population size
	*********************************************************************************************************************	
	
	use `neighbours', clear
*	drop district_name neighbour_block
	merge 1:1 village_code using "../03_processed/village_amenities_srijan", assert(2 3) keep(3) ///
		keepusing(district_name block_name village_name total_pop) nogen
	drop neighbour_village
	order district_name block_name village_code village_name total_pop
	rename * neighbour_*
	
	tempfile neighbour_census_details
	save `neighbour_census_details'
	
	use `srijan_neighbours_long', clear
	rename (district_name block_name village_code village_name total_pop) srijan_=
	drop num n_name n_pop n_block
	rename n_code neighbour_village_code
	rename n_dist neighbour_distance
	merge m:1 neighbour_village_code using `neighbour_census_details', assert(3) nogen
	
	gen neighbour_pop_diff = abs(srijan_total_pop - neighbour_total_pop)
	gen in_diff_district = (trim(itrim(lower(srijan_district_name))) != trim(itrim(lower(neighbour_district_name))))
	gen in_diff_block = (trim(itrim(lower(srijan_block_name))))
	
	sort srijan_location serial_no neighbour_distance in_diff_district in_diff_block neighbour_pop_diff
	by srijan_location serial_no: gen sample_pref_order = _n

	*********************************************************************************************************************
	* 9. display a warning when a non-SRIJAN neighbour occurs at the same preference rank for
	* multiple SRIJAN villages. This does not necessarily need to be fixed.
	*********************************************************************************************************************	
	
	duplicates tag srijan_location sample_pref_order neighbour_village_code, gen(tag)
	capture assert tag == 0
	if _rc != 0 {
		dis as error _n "Warning!! " _n "We have situations where a non-SRIJAN neighbour occurs at the same preference rank for multiple SRIJAN villages:"
		noi tab tag
		sort srijan_location tag neighbour_village_code
		list srijan_location serial_no srijan_village_code srijan_village_name neighbour_village_code neighbour_village_name neighbour_distance neighbour_pop_diff sample_pref_order ///
			if tag, sepby(srijan_location neighbour_village_code) // prefix "noisily" to the above line if you want to display the actual list
	}
	
	drop tag
	
	*********************************************************************************************************************
	* 10. create sample of non-SRIJAN villages
	* we do this in order of preference ranks for each location
	*********************************************************************************************************************	
		
	sort srijan_location sample_pref_order serial_no
	
	* a bit of ridiculous code just to identify the first and last observation for each SRIJAN location

	gen first_obs = 0
	gen last_obs = 0
	
	by srijan_location: replace first_obs = 1 if _n == 1
	replace first_obs = _n*first_obs // will become the observation number for first observations, and zero otherwise
	replace last_obs = _n if first_obs[_n+1] != 0 // if the next observation is the first observation of some (the next) location, then this must be the last observation of the (current) location 

	local first_obs
	local last_obs

	levelsof srijan_location, local(locations) clean
	
	foreach loc of local locations {
		sum first_obs if srijan_location == "`loc'"
		local first_obs `first_obs' `=r(max)'
		sum last_obs if srijan_location == "`loc'"
		local last_obs `last_obs' `=r(max)'
	}
	
	drop first_obs last_obs // the variables aren't needed any more
	
	* now we sample non-SRIJAN villages (in the order of preference ranks for each location, due to the sorting above)
	* each time we sample a non-SRIJAN village, we eliminate its original SRIJAN village, and the non-SRIJAN village itself,
	* from availability for subsequent sampling
	
	local num_locations: word count `locations'

	gen byte srijan_completed = 0
	gen byte nonsrijan_sampled = 0
	gen byte in_sample = 0
	
	forval i=1/`num_locations' {
		local first_ob: word `i' of `first_obs'
		local last_ob: word `i' of `last_obs'
		local loc: word `i' of `locations'
		
		forval j = `first_ob'/`last_ob' {
			if srijan_completed[`j'] == 0 & nonsrijan_sampled[`j'] == 0 {
					local srijan_village = srijan_village_code[`j']
					local nonsrijan_village = neighbour_village_code[`j']
					replace srijan_completed = 1 if srijan_village_code == `srijan_village' // eliminate this SRIJAN village from the set for which sampling is needed
					replace nonsrijan_sampled = 1 if neighbour_village_code == `nonsrijan_village' // elimite this non-SRIJAN village from the set from which villages can be sampled
					replace in_sample = 1 in `j'
			}
		}
	}
	
	keep if in_sample
	drop srijan_completed nonsrijan_sampled in_sample
	
	sort srijan_location serial_no
	
	tempfile nonsrijan_sample
	save `nonsrijan_sample'

	*********************************************************************************************************************
	* 11. confirm that the list of non-SRIJAN sampled villages is unique across locations 
	* (the algorithm above only ensures they are unique within each location)
	* this may potentially be an issue in some locations in Rajasthan which are rather close to each other
	*********************************************************************************************************************	

	duplicates tag neighbour_village_code, gen(tag)
	capture assert tag == 0
	
	if _rc !=0 {
		dis as error _n "FATAL ERROR!!" _n "There are some non-SRIJAN villages that have been sampled across locations:"
		noi list neighbour_village_code neighbour_village_name srijan_location serial_no srijan_village_code srijan_village_name if tag
		exit
	}
	
	*********************************************************************************************************************
	* 12. confirm that we have succeeded in finding a non-SRIJAN village to sample, for each SRIJAN sample village
	*********************************************************************************************************************	
	
	import excel using "../01_data/sampling/srijan_village_neighbours.xlsx", clear firstrow
	keep srijan_location serial_no district_name block_name village_code village_name
	rename (district_name block_name village_code village_name) srijan_=

	merge 1:1 srijan_village_code using `nonsrijan_sample', assert(1 3)
	
	capture assert _merge == 3
	
	if _rc !=0 {
		dis as error _n "FATAL ERROR!!" _n "There are some SRIJAN villages for which we have not been able to find a non-SRIJAN village to sample:"
		noi list srijan_location serial_no srijan_village_code srijan_village_name if _merge == 1
		exit
	}
	
	drop _merge
	
	sort srijan_location serial_no
	
	export delimited srijan_location srijan_district_name srijan_block_name serial_no srijan_village_code srijan_village_name ///
			neighbour_village_code neighbour_village_name neighbour_district_name neighbour_block_name neighbour_distance ///
			using "../03_processed/nonsrijan_sample.csv", replace
			
	*********************************************************************************************************************
	* 13. mark sampled villages in census data
	*********************************************************************************************************************	
	
	use "../03_processed/village_amenities_srijan", clear
	
	merge 1:1 village_code using "../03_processed/srijan_sample", assert(1 3) keepusing()
	gen sampled_srijan = (_merge == 3)
	drop _merge
	
	rename srijan_location srijan_location_master
	
	tempfile master
	save `master'
	
	use `nonsrijan_sample', clear
	keep srijan_location neighbour_village_code
	rename neighbour_village_code village_code
	tempfile using
	save `using'
	
	use `master', clear
	merge 1:1 village_code using `using', assert(1 3) keepusing(srijan_location)
	gen sampled_nonsrijan = (_merge == 3)
	drop _merge
	
	replace srijan_location_master = srijan_location if !missing(srijan_location)
	drop srijan_location
	rename srijan_location_master srijan_location
	
	save "../03_processed/village_amenities_srijan_withsample", replace

	keep village_code village_name is_srijan_village is_srijan_block is_srijan_district srijan_location sampled_srijan sampled_nonsrijan
	keep if is_srijan_district | sampled_nonsrijan
	
	export delimited using "../03_processed/srijan_and_sample_villages_list.csv", replace
	

project , creates("../03_processed/nonsrijan_sample.csv")	
project , creates("../03_processed/village_amenities_srijan_withsample.dta")
project , creates("../03_processed/srijan_and_sample_villages_list.csv")

	
