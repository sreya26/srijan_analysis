*********************************************************************************************************************
* !version 2.0 dated 18 July 2021, by Hemanshu Kumar 
*  -- modifications to work with Picard's -project- command
*  -- deparate the importing of census village amenities data to a different file
* !version 1.0 dated 6 April 2021, by Hemanshu Kumar
* This do-file is used for sampling SRIJAN villages 
* This file is part of the SRIJAN Project (headed by Rohini Somanathan, Priyanka Arora, Hemanshu Kumar, et al)
* adapted from code written by Priyanka Arora in srs_locationwise_updated.do and srs_locationwise.do
*********************************************************************************************************************

project , uses("../03_processed/village_amenities_data.dta")
project , original("../01_data/srijan_villages/village_list_anuppur_with_codes.csv")
project , original("../01_data/srijan_villages/village_list_chhindwara_with_codes.csv")
project , original("../01_data/srijan_villages/village_list_duni_with_codes.csv")
project , original("../01_data/srijan_villages/village_list_jaisinagar_with_codes.csv")
project , original("../01_data/srijan_villages/village_list_jashpur_with_codes.csv")
project , original("../01_data/srijan_villages/village_list_jatara_with_codes.csv")
project , original("../01_data/srijan_villages/village_list_karauli_with_codes.csv")
project , original("../01_data/srijan_villages/village_list_khatkar_with_codes.csv")
project , original("../01_data/srijan_villages/village_list_koriya_with_codes.csv")
project , original("../01_data/srijan_villages/village_list_kotma_with_codes.csv")
project , original("../01_data/srijan_villages/village_list_lakheri_with_codes.csv")
project , original("../01_data/srijan_villages/village_list_mohkhed_with_codes.csv")
project , original("../01_data/srijan_villages/village_list_nainwa_with_codes.csv")
project , original("../01_data/srijan_villages/village_list_newai_with_codes.csv")
project , original("../01_data/srijan_villages/village_list_pali_with_codes.csv")
project , original("../01_data/srijan_villages/village_list_pratapgarh_with_codes.csv")
project , original("../01_data/srijan_villages/village_list_shivpuri_with_codes.csv")
project , original("../01_data/srijan_villages/village_list_uniyara_with_codes.csv")

	*********************************************************************************************************************
	* 1. setting up some locals
	*********************************************************************************************************************
	
	* set the sampling methodology: simple random sampling (srs) or probability proportional to size (pps) sampling

	local sampling srs // can be "srs" or "pps"; we have decided to do srs sampling for this project

	* set the number of villages to be sampled at each location

	local num_villages 15 // 10 main villages + 5 replacements

	* set the population threshold below which to exclude villages from the sampling frame
	local min_pop 1
 
	* list of locations for sampling
	#delimit ;
	local locations 
			anuppur 		/* MP */
	/*		baran 			/* RJ */ omitted because SRIJAN started work at this location only post-COVID */ 
			chhindwara 		/* MP */
			duni			/* RJ */
			jaisinagar 		/* MP */
			jashpur 		/* CG */
			jatara 			/* MP */
			karauli 		/* RJ */
			khatkar			/* RJ */
			koriya 			/* CG */
			kotma			/* MP */
			lakheri			/* RJ */
			mohkhed 		/* MP */
			nainwa			/* RJ */
			newai			/* RJ */
			pali 			/* RJ */
			pratapgarh 		/* RJ */
			shivpuri		/* MP */
			uniyara			/* RJ */
			;
	#delimit cr

	use "../03_processed/village_amenities_data", clear
	*********************************************************************************************************************
	* 2. import the list of all SRIJAN villages, for each location
	*********************************************************************************************************************	
	
	foreach loc of local locations {
			dis as error "Opening SRIJAN village list file for location: `loc'"
			import delimited "../01_data/srijan_villages/village_list_`loc'_with_codes.csv", varnames(1) clear
			
			* check that all the expected variables are present
			confirm string variable district block panchayat revenuevillage villagestatusworkingnonworking
			confirm numeric variable villagecensuscode

			rename villagecensuscode village_code
			drop if missing(revenuevillage)

			count if missing(village_code)
			if r(N) != 0 dis as error "`=proper("`loc'")': There are `=r(N)' villages for which there are no census 2011 codes. Please put in artifical codes for these and re-run."
			
			* check that the census 2011 codes uniquely identify villages
			distinct village_code
			assert r(N) == r(ndistinct)
						
			tempfile srijan_`loc'
			save `srijan_`loc'', replace
		}


	*********************************************************************************************************************
	* 3. denote srijan villages in the census 2011 village amenities data
	*    also mark blocks and districts in which SRIJAN has operated
	*********************************************************************************************************************	

	use "../03_processed/village_amenities_data", clear
	gen byte is_srijan_village = 0
	gen srijan_location = ""
	
	foreach loc of local locations {
		merge 1:1 village_code using `srijan_`loc'', keepusing(district block panchayat revenuevillage) update
		replace is_srijan_village = 1 if inlist(_merge,2,3,4)
		replace srijan_location = "`loc'" if inlist(_merge,2,3,4)
		drop _merge
	}
	
	rename (district block panchayat revenuevillage) =_field // reminder that these variables came from field operators and not census village directory
	
	* drop villages that will not merge with census data, to exclude them from the sampling frame
	drop if village_code < 10000 // these villages actually have no census codes; the codes are created by us
	drop if village_code == 92991 // this is village Banasthali from the location Newai; the code was found in the LG directory but is not found in the census data

	* mark blocks and districts in which SRIJAN has operated
	
	local blocks_anuppur	`" "pushparajgarh" "'
	local blocks_baran		`" "antah" "'
	local blocks_chhindwara `" "bichhua","chaurai","chhindwara","pandhurna","sausar" "'
	local blocks_duni		`" "deoli","hindoli","todaraisingh","tonk" "'
	local blocks_jaisinagar `" "begamganj","jaisinagar","sagar","silwani" "'
	local blocks_jashpur 	`" "bagicha" "'
	local blocks_jatara  	`" "jatara","palera" "'
	local blocks_karauli 	`" "sapotra" "'
	local blocks_khatkar	`" "bundi","talera" "'
	local blocks_koriya		`" "bharatpur(janakpur)","manendragarh","sonhat" "'
	local blocks_kotma		`" "anuppur","burhar","jaithari","kotma" "'
	local blocks_lakheri	`" "keshorai patan" "'
	local blocks_mohkhed	`" "mohkhed" "'
	local blocks_nainwa		`" "nainwa" "'
	local blocks_newai		`" "niwai" "'
	local blocks_pali 		`" "bali","kotra" "'
	local blocks_pratapgarh	`" "arnod","peepalkhoont" "'
	local blocks_shivpuri 	`" "karera","khaniyadhana","pichhore" "'
	local blocks_uniyara	`" "sawai madhopur","uniara" "'
	
	local districts_anuppur 	`" "anuppur" "'
	local districts_baran		`" "baran" "'
	local districts_chhindwara 	`" "chhindwara" "'
	local districts_duni 		`" "bundi","tonk" "'
	local districts_jaisinagar 	`" "raisen","sagar" "'
	local districts_jashpur 	`" "jashpur" "'
	local districts_jatara  	`" "tikamgarh" "'
	local districts_karauli 	`" "karauli" "'
	local districts_khatkar		`" "bundi" "'
	local districts_koriya		`" "koriya" "'
	local districts_kotma		`" "anuppur","shahdol" "'
	local districts_lakheri		`" "bundi" "'
	local districts_mohkhed		`" "chhindwara" "'
	local districts_nainwa		`" "bundi" "'
	local districts_newai		`" "tonk" "'
	local districts_pali 		`" "pali","udaipur" "'
	local districts_pratapgarh	`" "pratapgarh" "'
	local districts_shivpuri 	`" "shivpuri" "'
	local districts_uniyara		`"  "sawai madhopur","tonk" "'

	gen byte is_srijan_block = 0
	gen byte is_srijan_district = 0
	gen locations_in_this_block = ""
	gen locations_in_this_dist = ""
	
	foreach loc of local locations {
			replace is_srijan_block = 1 if inlist(lower(block_name),`blocks_`loc'')
			replace locations_in_this_block = locations_in_this_block + "`loc'; " if inlist(lower(block_name),`blocks_`loc'')
			replace is_srijan_district = 1 if inlist(lower(district_name),`districts_`loc'')
			replace locations_in_this_dist = locations_in_this_dist + "`loc'; " if inlist(lower(district_name),`districts_`loc'')
	}
	
	foreach var of varlist locations_in_this_* {
		replace `var' = substr(`var',1,length(`var')-2) if !missing(`var') // remove the "; " at the end
	}
		
	save "../03_processed/village_amenities_srijan", replace


	*********************************************************************************************************************
	* 4. sampling at each location
	*********************************************************************************************************************	
	
	clear
	save "../03_processed/srijan_sample", replace emptyok
	
	use "../03_processed/village_amenities_srijan", clear

	keep 	state_name district_name subdistrict_name block_name panchayat_field village_name village_code ///
			srijan_location is_srijan_village is_srijan_block is_srijan_district ///
			locations_in_this_block locations_in_this_dist total_pop
	
	foreach loc of local locations {
		preserve
			keep if srijan_location == "`loc'"

			if "`sampling'" == "srs" {
				if `min_pop' !=0 {
					count if total_pop < `min_pop'
					if r(N) !=0 dis as err "Dropping `=r(N)' villages with population below `min_pop' in location `loc' from the sampling frame."
					drop if total_pop < `min_pop'
				}
				set seed 123
				gen random = runiform()
				sort random
				keep in 1/`num_villages'
				gen serial_no = _n
			}
			
			if "`sampling'" == "pps" {
			* dis as err "Drawing PPS random sample for location: `loc'"
				capture gsample `num_villages' [w=total_pop], wor
				if _rc !=0 {
						dis as err "PPS random sampling for `loc' returns an error!!!"
						restore
						continue
				}
			}
			
			* noi tab total_pop
			append using "../03_processed/srijan_sample"
			save "../03_processed/srijan_sample", replace
		restore 
	}

	* export a CSV file with the sample of SRIJAN villages
	
	use "../03_processed/srijan_sample", clear
	
	order srijan_location serial_no state_name district_name block_name panchayat_field village_code village_name total_pop
	
	rename panchayat_field panchayat_name
	
	foreach var of varlist *_name {
		replace `var' = proper(trim(itrim(`var')))
	}

	sort state_name srijan_location serial_no

	save "../03_processed/srijan_sample", replace

	export delimited srijan_location serial_no state_name district_name block_name panchayat_name village_code village_name total_pop using ///
		"../03_processed/srijan_sample.csv", replace
		
	
	*********************************************************************************************************************
	* 5. generate some characteristics of each village
	*********************************************************************************************************************	

	use "../03_processed/village_amenities_srijan", clear
	
	merge 1:1 village_code using "../03_processed/srijan_sample", keepusing(village_code) assert(1 3)
	gen sample = (_merge == 3)
	drop _merge
	
	gen sc_frac = (sc_pop/total_pop)
	gen st_frac = (st_pop/total_pop)
	gen sown_area_frac = (netsown_area/total_area)
	gen forest_area_frac = (forest_area/total_area)
	gen irrigated_frac = (irrigated_area/netsown_area)
	
	format *_frac %3.2f

	*********************************************************************************************************************
	* 6. some comparisons between the districts, the blocks, the SRIJAN villages in them, and the sampled SRIJAN villages
	*********************************************************************************************************************	

	dis as error _n "Some statistics:"

	local stats mean sd min p5 p10 p25 p50 p75 p90 p95 max count
	
	estpost tabstat st_frac if sample, stat(`stats') by(srijan_location) columns(statistics) nototal
	matrix A = e(mean)\e(sd)\e(min)\e(p5)\e(p10)\e(p25)\e(p50)\e(p75)\e(p90)\e(p95)\e(max)\e(count)
	noi esttab matrix(A, fmt(a2 a2 a2 a2 a2 a2 a2 a2 a2 a2 a2 %5.0fc) transpose), ///
		title("Village-level distribution of ST fraction across SRIJAN locations") nomtitles 
	
	qui tabstat st_frac [aweight=total_pop] if is_srijan_district, stat(`stats') format(%9.2gc) columns(var) save
	matrix A = r(StatTotal)
	qui tabstat st_frac [aweight=total_pop] if is_srijan_block, stat(`stats') format(%9.2gc) columns(var) save	
	matrix B = r(StatTotal)
	qui tabstat st_frac [aweight=total_pop] if is_srijan_village, stat(`stats') format(%9.2gc) columns(var) save
	matrix C = r(StatTotal)
	qui tabstat st_frac [aweight=total_pop] if sample, stat(`stats') format(%9.2gc) columns(var) save	
	matrix D = r(StatTotal)
	
	matrix S = A,B,C,D
	matrix colnames S = districts blocks villages sample
	matrix S = S'
	
	noi esttab matrix(S, fmt(a2 a2 a2 a2 a2 a2 a2 a2 a2 a2 a2 %5.0fc) transpose), title("Village-level distribution of ST fraction") nomtitles
	
	local stats mean sd min p5 p10 p25 p50 p75 p90 p95 max
	local statvars total_hh total_pop *_frac
	
	dis as error _n "Overall comparisons:"
	
		local ifblocks `" if is_srijan_block  "'
		local ifsrijan `" if is_srijan_village  "'
		local ifsample `" if sample == 1 "'

		count `ifblocks'
		local numvills_blocks = r(N)
		count `ifsrijan'
		local numvills_srijan = r(N)
		count `ifsample'
		local numvills_sample = r(N)

		dis as error "Location: `=proper("`loc'")' "
		dis as error "Comparison of CD blocks [`numvills_blocks' villages] vs. all SRIJAN villages [`numvills_srijan' villages] vs. sampled SRIJAN villages [`numvills_sample' villages]:"
		
		
		noi tabstat `statvars' `ifblocks', stat(`stats') format(%9.2gc)
		noi tabstat `statvars' `ifsrijan', stat(`stats') format(%9.2gc)
		noi tabstat `statvars' `ifsample', stat(`stats') format(%9.2gc)
	
	set more on
	
	/*
	dis as error _n "Location-wise comparisons:"
	
	
	foreach loc of local locations {

		local ifblocks `" if strpos(locations_in_this_block,"`loc'")"'
		local ifsrijan `" if is_srijan_village == 1 & srijan_location == "`loc'"  "'
		local ifsample `" if sample == 1 & srijan_location == "`loc'"  "'

		count `ifblocks'
		local numvills_blocks = r(N)
		count `ifsrijan'
		local numvills_srijan = r(N)
		count `ifsample'
		local numvills_sample = r(N)

		dis as error "Location: `=proper("`loc'")' "
		dis as error "Comparison of CD blocks [`numvills_blocks' villages] vs. all SRIJAN villages [`numvills_srijan' villages] vs. sampled SRIJAN villages [`numvills_sample' villages]:"
		
		
		noi tabstat `statvars' `ifblocks', stat(`stats') format(%9.2gc)
		noi tabstat `statvars' `ifsrijan', stat(`stats') format(%9.2gc)
		noi tabstat `statvars' `ifsample', stat(`stats') format(%9.2gc)
	}
	*/
	
	*********************************************************************************************************************
	* 7. investigating the errors in PPS sampling
	*********************************************************************************************************************	
	
	if "`sampling'" == "pps" {
		keep if is_srijan_village
		
		egen location_pop = total(total_pop) , by(srijan_location)
		gen pop_weight = total_pop/location_pop
		gsort srijan_location -pop_weight
		format %9.0gc total_pop location_pop
		format %4.3f pop_weight
		noi li srijan_location village_name village_code total_pop location_pop pop_weight if pop_weight>0.1, sepby(srijan_location) noobs
	}
	
	
project , creates("../03_processed/village_amenities_srijan.dta")
project , creates("../03_processed/srijan_sample.dta")
project , creates("../03_processed/srijan_sample.csv")
