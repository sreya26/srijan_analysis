*************************************************************************************************************************************
*! version 1.0  | 21 July 2021 | Hemanshu Kumar & Sreya Majumder 
*  this file is part of the SRIJAN project headed by Rohini Somanathan, Priyanka Arora and Hemanshu Kumar
*************************************************************************************************************************************  

project , uses("../04_temp/errorcheck_workfile_with_overrides.dta")


****************************************************************************************************
* we create a program that will accomplish basic tasks for all errors:
* -- count villages with the error
* -- display an error message on screen
* -- list the problematic observations (and show the error message) in a text log file
* -- generate a binary variable to store the error
****************************************************************************************************

capture program drop throw_error
program define throw_error 
	syntax if/ , Message(string) GENerate(name) [LISTvars(varlist)]

	confirm new variable `generate'
	
	qui count if (`if')
	local N = r(N)
	
	if `N' != 0 {
		log on errors
		dis as error _n `"`message' in `N' village(s):"'
		noi list surveyor village_id village_name `listvars' if (`if') , noobs linesize(160) abbr(32) string(32)
		log off errors
	}
	
	gen byte `generate' = (`if')
	label define `=upper("`generate'")' 0 "OK" 1 "`message'"
	label values `generate' `=upper("`generate'")'
	label var `generate' "`message'."
	
end



	****************************************************************************************************
	**# Start of main code 
	* Open the errors workfile and the error log file.
	****************************************************************************************************

	use "../04_temp/errorcheck_workfile_with_overrides", clear

	note: This dataset incorporates error checks, as specified till 10 August 2021 14:30.
	
	capture drop __000000 
	destring village_id, replace
		
	capture log close errors
	log using "../06_outputs/01_error_checking/error_log.txt" , name(errors) text nomsg replace
	notes
	
	noisily dis "There are a total of " _N " villages in this dataset."
	
	log off errors

	
	format surveyor %16.0f
	
	
	****************************************************************************************************
	**# Section 00: List of unmerged village IDs
	****************************************************************************************************
	
	throw_error if (_m_asha == 1) , message("We have main survey data but have no ASHA data") gen(error_sec00_01) 
	throw_error if (_m_asha == 2) , message("We have ASHA data but no main survey data") gen(error_sec00_02) 

	
	****************************************************************************************************
	**# Section 1 #01. Household size must lie in a certain range (2 to 10)
	****************************************************************************************************

	throw_error if (hh_size < 2 | hh_size > 10) & _m_asha != 2 , message("Household size lies outside 2-10") gen(error_sec1_01) list(hh_size)
	
	*****************************************************************************************************
	**# Section 1 #02. Caste name should be consistent with the caste category entered in the code sheet. 
	*****************************************************************************************************
	
	
	rename (x_q103_caste_1_firstdig x_q107_caste_2_firstdig x_q111_caste_3_firstdig) (q103_first_digit q107_first_digit q111_first_digit)

	** 1st, 2nd and 3rd major castes in the village
	local caste_ques q103 q107 q111
	forval i=1/3 {
		local qnum: word `i' of `caste_ques'
		format `qnum'_caste_`i' `qnum'A_caste_cat %16.0f
		throw_error if (`qnum'_first_digit != x_`qnum'A_caste_cat_corrected) & !inlist(`qnum'_caste_`i',501,888) & overd_sec1_02_`qnum' == 0 & x_`qnum'A_caste_cat_corrected != .z, ///
			message("Caste name inconsistent with caste category in `qnum'") gen(error_sec1_02_`qnum') list(`qnum'_caste_`i' `qnum'A_caste_cat)
	}
	
	** respondent's caste
	
	format q006_resp_caste q006A_resp_cat %16.0f
	throw_error if (x_q006_resp_caste_firstdig != x_q006A_resp_cat_corrected) & !inlist(q006_resp_caste,501,888) & overd_sec1_02_006 == 0 & x_q006A_resp_cat_corrected != .z , ///
		message("Respondent caste name inconsistent with caste category") gen(error_sec1_02_006) list(q006_resp_caste q006A_resp_cat)
		
	*****************************************************************************************************
	**# Section 1 #03. People at the higher end of the land distribution cannot exceed 20% 
	*****************************************************************************************************
	
	format x_q118_large_land_hh_perc %6.2f 
	throw_error if x_q118_large_land_hh_perc > 20 & _m_asha != 2 & overd_sec1_03 == 0, ///
		message("People at the higher end of the land distribution exceeds 20%") gen(error_sec1_03) list(x_q118_large_land_hh_perc)
		

	******************************************************************************************************
	**# Section 1 #04. Percentage of landless HHs must be consistent with percentage of HHs doing agriculture
	* question asks what percentage of households currently living in the village are landless 
	* q501_agri_hh_p_1 refers to the period after April 2020 so we use this for the check 
	******************************************************************************************************

	tempvar sum
	egen `sum' = rowtotal(x_q501_agri_hh_perc_1 x_q114_landless_hh_perc)
	format `sum' x_q501_agri_hh_perc_1 x_q114_landless_hh_perc %6.2f
	
	throw_error if `sum' > 120 & overd_sec1_04 == 0, message("Sum of landless HHs and HHs dependent on agriculture exceeds 120%") ///
				gen(error_sec1_04) list(x_q501_agri_hh_perc_1 x_q114_landless_hh_perc `sum')
		


	******************************************************************************************************
	**# Section 1 #05. where landless and marginal farmers tend to be numerous, we should find
	* -- high migration
	* -- high NREGA enrolment
	* -- high casual labour
	* -- high seasonal migrants
	* we visualize this using scatter plots
	******************************************************************************************************
	
	label var q704_empt_nrega_tot "Employment in NREGA (%)"

	twoway scatter x_migrant_perc x_landless_and_marginal_perc , mlabel(village_name) mlabsize(tiny) name(migrant, replace)
	twoway scatter x_q423_seasonal_migrant_perc x_landless_and_marginal_perc , mlabel(village_name) mlabsize(tiny) name(seasonal, replace)	
	twoway scatter q704_empt_nrega_tot x_landless_and_marginal_perc , mlabel(village_name) mlabsize(tiny) name(nrega, replace)
	twoway scatter x_q502_agri_lab_1_perc x_landless_and_marginal_perc , mlabel(village_name) mlabsize(tiny) name(casual_labour, replace)
	
	foreach graph in migrant seasonal nrega casual_labour {
		graph export "../06_outputs/01_error_checking/sec1_05_`graph'.png", name(`graph') replace
	}
	
	******************************************************************************************************
	**# Section 1 #06. Women’s education to be typically lower than that of men
	******************************************************************************************************

	local edu class05 class08 class10 class12 
	foreach class of local edu {
		format x_`class'_1 x_`class'_2 %5.1f
		throw_error if x_`class'_1 > x_`class'_2 & overd_sec1_06_`class' == 0, ///
			message(Women's education higher than men's for `class') gen(error_sec1_06_`class') list(x_`class'_1 x_`class'_2)
	}

	format x_q125_graduate_perc_x_1 x_q125_graduate_perc_x_2 %5.1f
	throw_error if x_q125_graduate_perc_x_1 > x_q125_graduate_perc_x_2 & overd_sec1_06_graduate == 0, ///
		message("More graduate women than men") gen(error_sec1_06_graduate) list(x_q125_graduate_perc_x_1 x_q125_graduate_perc_x_2)
	
	******************************************************************************************************
	**# Section 1 #08. Sum of all educational levels should be always less than 100% in case of percentage
	******************************************************************************************************

	local sexes women men

	forval i = 1/2 {
		local sex: word `i' of `sexes'
		qui egen sumedu`i' = rowtotal(x_q120_below_class5_perc_x_`i' x_q121_class5_perc_x_`i' x_q122_class8_perc_x_`i' x_q123_class10_perc_x_`i' x_q124_class12_perc_x_`i')
		format sumedu`i' %6.2f
		
		throw_error if sumedu`i' >= 100 & q125_graduate_n_x_`i' != 0, ///
			message("Though there are some graduate `sex', total of other education levels is 100%") gen(error_sec1_08_0`i') ///
			list(q125_graduate_n_x_`i' sumedu`i')
	}

	******************************************************************************************************
	**# Section 2 #01. Check if number of drinking water sources is too large
	******************************************************************************************************

		local source_codes		1				2		3		4		5			6			7
		local sources `" "common taps"  "handpumps"  "ponds" "wells" "rivers etc" "pvt tap" "govt provided pvt tap" "'
	
		******************************************************************************************************
		* for common water taps
		******************************************************************************************************

		* for common top water and private tap water from borewell/government number of sources should not be greater than number of households

		local tap_codes 1 6 7

		foreach x of local tap_codes {
			local source_name: word `x' of `sources'
			
			throw_error if q202_source_num_`x' > q101_hh & q202_source_num_`x' != .z  & _m_asha != 2, ///
				message("No. of `source_name' for drinking water too large") gen(error_sec2_01_`x') ///
				list(q101_hh q202_source_num_`x')
		}

		******************************************************************************************************
		* for handpumps
		******************************************************************************************************
		
		throw_error if q202_source_num_2 > 25 & q202_source_num_2 != .z & overd_sec2_01_2 == 0  & _m_asha != 2, ///
			message("No. of handpumps for drinking water exceeds 25") gen(error_sec2_01_2) list(q202_source_num_2)
			

			
		******************************************************************************************************
		* for ponds
		******************************************************************************************************
		
		capture confirm numeric var q202_source_num_3
		if _rc == 0 {
			throw_error if q202_source_num_3!=.z & q202_source_num_3 > 5  & _m_asha != 2, ///
				message("No. of ponds exceeds 5") gen(error_sec2_01_3) list(q202_source_num_4)
		}
		
		******************************************************************************************************
		* for wells
		******************************************************************************************************
			
		throw_error if q202_source_num_4!=.z & (q202_source_num_4 > max(q101_hh,100))  & _m_asha != 2, /// this is based on the distribution as of July 21
			message("No. of wells is too high") gen(error_sec2_01_4) list(q202_source_num_4) 

			
		******************************************************************************************************
		* for lakes rivers streams
		******************************************************************************************************

		throw_error if q202_source_num_5!=.z & q202_source_num_5 > 1  & _m_asha != 2, ///
			message("There is more than one river, lake and stream") gen(error_sec2_01_5) list(q202_source_num_5)



	******************************************************************************************************
	**# Section 2 #02. Fewer sources of drinking water lead to insufficient water availability in summer 
	* and more sources lead to sufficient water during the year.
	******************************************************************************************************

	forvalues x = 1/7 {
		capture confirm int variable q202_source_num_`x'
		if _rc == 111 continue
		
		local source_name: word `x' of `sources'
		
		throw_error if q203_source_func_summer_`x' > q204_source_func_winter_`x' & overd_sec2_02_`x' == 0, ///
			message("No. of functional `source_name' in the summer exceeds those in winter") gen(error_sec2_02_`x') ///
			list(q203_source_func_summer_`x' q204_source_func_winter_`x')
	}
	
	
	******************************************************************************************************
	**# Section 2 #03. Time taken to fetch water
	* 			(a) zero not okay
	*			(b) non-zero values below 5 may mean entry was in hours not minutes
	******************************************************************************************************

	local seasons summer winter
	local questions 208 209
	
	forvalues x = 1/7 {
		capture confirm int variable q202_source_num_`x'
		if _rc == 111 continue
		
		local source_name: word `x' of `sources'

		forval i = 1/2 { 
			local season: word `i' of `seasons'
			local num: word `i' of `questions'
			
			throw_error if (q`num'_water_time_`season'_`x' == 0) & !inlist(`x',6,7), ///  * exception for private taps
				message("Time spent on `source_name' in `season' is zero") gen(error_sec2_03a_`x'_`season') ///
				list(q`num'_water_time_`season'_`x')				
			
			throw_error if q`num'_water_time_`season'_`x' < 5 & q`num'_water_time_`season'_`x' > 0, ///
				message("Are these hours? Time entered for `source_name' in `season' is less than 5 mins") gen(error_sec2_03b_`x'_`season') ///
				list(q`num'_water_time_`season'_`x')				
		}
	}
	
	
	******************************************************************************************************
	**# Section 2 #05. Water time taken in summer must be greater than in winter
	******************************************************************************************************
	
	forvalues x = 1/7 {
		capture confirm int variable q202_source_num_`x'
		if _rc == 111 continue 

		local source_name: word `x' of `sources'
		
		throw_error if q208_water_time_summer_`x' < q209_water_time_winter_`x' & q209_water_time_winter_`x'!=.z & overd_sec2_05_`x' == 0 , ///
			message("Time taken getting water from `source_name' is less in summer than in winter") gen(error_sec2_05_`x') ///
			list(q208_water_time_summer_`x' q209_water_time_winter_`x')
			
	}

	******************************************************************************************************
	**# Section 2 #07. Degree of water sufficiency from a source should be higher in winter than summer
	******************************************************************************************************
	
	forvalues x = 1/7 {
		capture confirm int variable q202_source_num_`x'
		if _rc == 111 continue

		local source_name: word `x' of `sources'
		format q211_water_suff_winter_`x' q210_water_suff_summer_`x' %25.0f
		
		throw_error if q211_water_suff_winter_`x' > q210_water_suff_summer_`x' & q211_water_suff_winter_`x'!=.z & overd_sec2_07_`x' == 0, ///
			message("Degree of water sufficiency from `source_name' is higher in summer than winter") ///
			gen(error_sec2_07_`x') list(q211_water_suff_winter_`x' q210_water_suff_summer_`x')
			
	}


	******************************************************************************************************
	**# Section 2 #08. HHs using LPG as primary source of fuel should be less than equal to HHs with LPG connection.
	******************************************************************************************************
	
	tempvar sum
	egen `sum' = rowtotal(x_q219_lpg_ujjwala_perc x_q220_lpg_other_perc)
	format `sum' x_q219_lpg_ujjwala_perc x_q220_lpg_other_perc x_q218_fuel_primary_hh_perc_4 %6.2f
	
	throw_error if x_q218_fuel_primary_hh_perc_4 > `sum' & !missing(x_q218_fuel_primary_hh_perc_4), ///
		message("HHs using LPG as primary fuel source exceed HHs with LPG connection") ///
		gen(error_sec2_08) list(x_q218_fuel_primary_hh_perc_4 x_q219_lpg_ujjwala_perc x_q220_lpg_other_perc `sum')
	

	******************************************************************************************************
	**# Section 2 #09. Distance of health facilities are consistent with each other
	******************************************************************************************************

	format q222_distance_facility_9 q222_distance_facility_10 q222_distance_facility_11 %6.2f
		
	throw_error if !((q222_distance_facility_9 <= q222_distance_facility_10) & (q222_distance_facility_10 <= q222_distance_facility_11)) & q222_distance_facility_9!=.z & q222_distance_facility_11 !=.z & q222_distance_facility_10 != .z, ///
		message("Distance of health facilities is inconsistent") gen(error_sec2_09) ///
		list(q222_distance_facility_9 q222_distance_facility_10 q222_distance_facility_11)

		
	******************************************************************************************************
	**# Section 2 #10. Distance of Panchayat center, block HQ and District HQ should be in ascending order.
	******************************************************************************************************

	format q222_distance_facility_2 q222_distance_facility_3 q222_distance_facility_4 %6.2f
	
	throw_error if !((q222_distance_facility_2 <= q222_distance_facility_3) & (q222_distance_facility_3 <= q222_distance_facility_4)) & q222_distance_facility_2  != .z  & q222_distance_facility_4  != .z & q222_distance_facility_3  != .z & overd_sec2_10 == 0, ///
		message("Distance of Panchayat centre, block and District HQ not in ascending order") ///
		gen(error_sec2_10) list(q222_distance_facility_2 q222_distance_facility_3 q222_distance_facility_4)
		

	******************************************************************************************************
	**# Section 2 #11. number of school facilities are consistent with each other 
	* 	i.e. high schools should not be greater than middle schools should not be greater than primary schools
	******************************************************************************************************

	throw_error if !((q221_number_facility_6 >= q221_number_facility_7) & (q221_number_facility_7 >= q221_number_facility_8)) & q221_number_facility_7  != .z & q221_number_facility_8 != .z & q221_number_facility_6 != .z & overd_sec2_11 == 0, ///
		message("No. of school facilities are inconsistent") gen(error_sec2_11) ///
		list(q221_number_facility_6 q221_number_facility_7 q221_number_facility_8)


		
	******************************************************************************************************
	**# Section 4 #01. Lockdown is least likely to have been in place during October 2020 - February 2021
	******************************************************************************************************
	
	tempvar err_lockdown
	
	egen `err_lockdown' = anymatch(q401_lockdown_months__10 - q401_lockdown_months__14), values(1)
	
	throw_error if `err_lockdown' , message("Some months with no official lockdown are reported as such") ///
				gen(error_sec4_01) list(q401_lockdown_months__10 - q401_lockdown_months__14)
	
	******************************************************************************************************
	**# Section 4 #03. migrants returned back and number stayed in village should be equal to total number of migration
	******************************************************************************************************

	tempvar sum
	egen `sum' = rowtotal(q417_remigrated_hh q415_residing_hh)
	
	throw_error if q411_returned_hh != `sum' & q417_remigrated_hh  != .z & q415_residing_hh  != .z  & _m_asha != 2 ///
				, message("Inconsistent number for migration") ///
				gen(error_sec4_03) list(q411_returned_hh q417_remigrated_hh q415_residing_hh `sum')
	

	******************************************************************************************************
	**# Section 4 #04. Migrant destination is usually within the state in case of seasonal migration.
	******************************************************************************************************

	local states 		`" "Rajasthan" "Chhattisgarh" "Madhya Pradesh" "'
	local st_abs				RJ			CG				MP
	local state_codes 			8			22				23			
	local vill_code_lo		  64088        431192		  451361	
	local vill_code_hi       108883		   451360		  506425
	
	
	forval i=1/3 {
		local state: word `i' of `states'
		local st: word `i' of `st_abs'
		local st_code: word `i' of `state_codes'
		local lo: word `i' of `vill_code_lo'
		local hi: word `i' of `vill_code_hi'
		
		tempvar num_`st' num_nonmiss diff
		egen `num_nonmiss' = rownonmiss(q406_mig_dest_state_1 q408_mig_dest_state_2 q410_mig_dest_state_3)
		egen `num_`st'' = anycount(q406_mig_dest_state_1 q408_mig_dest_state_2 q410_mig_dest_state_3), value(`st_code')
		gen `diff' = `num_nonmiss' - `num_`st'' // 0 if all nonmissing states are this specific state
		
		throw_error if `diff' == 0 & inrange(village_id,`lo',`hi') & overd_sec4_04_`st' == 0  & _m_asha != 2, /// 
			/// i.e. all non-missing states are the home state
			message("May have misinterpreted q404-q410 as seasonal migration in `st'") gen(error_sec4_04_`st')
	}	
	
	
	******************************************************************************************************
	**# Section 4 #05. current year wages in casual labour are higher than past year
	******************************************************************************************************

	throw_error if q504_agri_wages_1 < q504_agri_wages_2 , ///
		message("Current year casual labour wage less than past year") gen(error_sec4_05) ///
		list(q504_agri_wages_1 q504_agri_wages_2)
	
	******************************************************************************************************
	**# Section 4 #07. NREGA and IAY 
	******************************************************************************************************
	
	tempvar iay_in_nrega
	gen byte `iay_in_nrega' = (q708_nrega_type_post__10 == 1 | q709_nrega_type_pre__10 == 1)
	
	throw_error if q433_hh_iay == 0 & `iay_in_nrega' == 1 , ///
		message("IAY work done in NREGA but no houses built in IAY") gen(error_sec4_07) ///
		list(q708_nrega_type_post__10 q709_nrega_type_pre__10 q433_hh_iay)
		

		
	******************************************************************************************************
	**# Section 6 #02. In most cases, Mahua, Tendu, Chironji, Honey are collected for sale.
	******************************************************************************************************

	* all NTFP ids except 1 which corresponds to firewood

	local ntfp_codes	1		2			3			4			5				6				7			8		9		888
	local ntfps `" "Firewood" "Saal leaf" "Tendu leaf" "Mahua" "Seasonal fruits" "Medicinal herbs" "Honey" "Chironji" "Gond" "Other" "'
	
	local num_ntfp: word count ntfp_codes
	forval i = 2/`num_ntfp' {
		local code: word `i' of `ntfp_codes'
		local ntfp: word `i' of `ntfps'
		
		capture confirm int variable q603_ntfp_hh_p_`code'
		if _rc == 111 continue
		
		format x_q604_ntfp_sale_hh_perc_`code' %6.2f
		throw_error if x_q604_ntfp_sale_hh_perc_`code' == 0, ///
			message("`ntfp' not collected for sale") gen(error_sec6_02_`code') ///
			list(x_q604_ntfp_sale_hh_perc_`code')		
	}
	
	******************************************************************************************************
	**# Section 6 #03. Tendu is purchased by "Forest Committee" or "Forest Department" in most cases
	******************************************************************************************************

	throw_error if q605_ntfp_sale_where__6_3 == 0 & q605_ntfp_sale_where__5_3 == 0 & overd_sec6_03 == 0, ///
		message("Tendu leaf not purchased by forest committee or forest department") gen(error_sec6_03) ///
		list(q605_ntfp_sale_where__6_3 q605_ntfp_sale_where__5_3)
		

	******************************************************************************************************
	**# Section 6 #04. If villagers have access to forest then higher percentage collect firewood for cooking fuel
	******************************************************************************************************
	
	unab perc_vars: x_q218_fuel_primary_hh_perc_*
	local firewood_percvar x_q218_fuel_primary_hh_perc_1
	local other_percvars: list perc_vars - firewood_percvar
	
	format x_q218_fuel_primary_hh_perc_* %6.2f
	
	tempvar max_perc
	egen `max_perc' = rowmax(`other_percvars')
	
	throw_error if inrange(q602_ntfp_list__1,1,10) & x_q218_fuel_primary_hh_perc_1 < `max_perc' & !missing(`max_perc'), ///
		message("Village accesses firewood from forest but it is not the largest fuel source") gen(error_sec6_04) ///
		list(x_q218_fuel_primary_hh_perc_*)

		
		
	******************************************************************************************************
	**# Error checks for ASHA SURVEY
	******************************************************************************************************

		
	******************************************************************************************************
	**# ASHA #01. Vaccination dates for 18+ and 45+
	* 00/00 refers to vaccination having not started yet
	* 99/mm refers to date of vaccination not known
	******************************************************************************************************

	* month values cannot be greater than 12
	
	foreach var of varlist q827_vaccn_start_45plus q826_vaccn_start_18plus {
		throw_error if x_`var'_m > 12 & !missing(`var') & overd_m_q826_vaccn_start_18plus == 0, ///
		message("Month of vaccination error for `var'") gen(error_m_`var') list(`var')
	}
	
	* date cannot be greater than 31 for the following months
	
	rename x_q827_vaccn_start_45plus_* q827_vaccn_start_45plus_*
	rename x_q826_vaccn_start_18plus_* q826_vaccn_start_18plus_*
	
	foreach var of varlist q827_vaccn_start_45plus q826_vaccn_start_18plus {
		throw_error if inlist(`var'_m,1,3,5,7,8,10,12) & !inrange(`var'_d,1,31) & `var'_d != 99, /// 
			message("Date of vaccination error (31 days) for `var'") gen(error_31_`var') list(`var')
	}
	
	* date cannot be greater than 30 for the following months 
	
	foreach var of varlist q827_vaccn_start_45plus q826_vaccn_start_18plus {
		throw_error if inlist(`var'_m,4,6,9,11) & !inrange(`var'_d,1,30) &`var'_d != 99, ///
			message("Date of vaccination error (30 days) for `var'") gen(error_30_`var') list(`var' `var')
	}
	
	* date cannot be greater than 28 for the month of Feb 2021
	
	foreach var of varlist q827_vaccn_start_45plus q826_vaccn_start_18plus {
		throw_error if `var'_m == 2 & `var'_d > 28 &`var'_d != 99, ///
			message("Date of vaccination error (Feb) for `var'") gen(error_28_`var') list(`var')
	}
	
		
	******************************************************************************************************
	**# ASHA #02. Caste name and category to be consistent for the respondent
	******************************************************************************************************
	
	format q006_resp_caste_asha q006A_resp_asha_cat %16.0f
	throw_error if (x_q006_resp_caste_asha_firstdig != x_q006A_resp_asha_cat_corrected) & !inlist(q006_resp_caste_asha,501,888), ///
		message("ASHA respondent caste name inconsistent with caste category") gen(error_asha_resp) ///
		list(q006_resp_caste_asha q006A_resp_asha_cat)
		
	******************************************************************************************************
	**# Section 8 #01. match between distance to testing centre and distance as per q222 
	******************************************************************************************************
		
	local margins 		x 		2		3		5 		// maximal kilometre difference between distance to testing centre and panchayat/block/district 
	local facilities 	town panchayat block district
		
	forval x = 2/4 {
		
		local facility: word `x' of `facilities'
		local margin: 	word `x' of `margins'
		throw_error if q803_test_location == `x' & abs(q804_testing_dist - q222_distance_facility_`x') > `margin', ///
			message("Distance to nearest test centre and distance to `facility' facility mismatch") ///
			gen(error_sec_8_01_`x') list(q804_testing_dist q222_distance_facility_`x' )
	}
	
	******************************************************************************************************
	**# Section 8 #02. Rapid Antigen tests should be free of cost
	******************************************************************************************************
	
	throw_error if q805_type_tests == 2 & q806_tests_free != 1, message("Rapid antigen test is not free") ///
		gen(error_sec8_02) list(q805_type_tests q806_tests_free)
	
	******************************************************************************************************
	**# Section 8 #03. Rapid antigen test reports should come back the same day
	******************************************************************************************************
	
	throw_error if q805_type_tests == 2 & q808_time_result != 0, message("Rapid antigen test result time is not 0 days") ///
		gen(error_sec8_03) list(q805_type_tests q808_time_result)
	
	******************************************************************************************************
	**# Section 8 #04. No. of persons getting tested cannot exceed total persons, by gender
	******************************************************************************************************

	throw_error if q809_men_tested_n > q119_ppl_num_2 & !missing(q809_men_tested_n), ///
		message("No. of men getting tested is more than total number of men") gen(error_sec8_04_2) ///
		list(q809_men_tested_n q119_ppl_num_2)
	
	throw_error if q810_women_tested_n > q119_ppl_num_1 & !missing(q810_women_tested_n), ///
		message("No. of women getting tested is more than total number of women") gen(error_sec8_04_1) ///
		list(q810_women_tested_n q119_ppl_num_1)

	******************************************************************************************************
	**# Section 8 #05. No. of persons who tested positive cannot exceed those who were tested
	******************************************************************************************************

	tempvar tested_sum
	egen `tested_sum' = rowtotal(x_q809_men_tested_perc x_q810_women_tested_perc)
	
	throw_error if x_q811_positive_perc > `tested_sum' & !missing(x_q811_positive_perc), ///
		message("No. of people who tested positive greater than number taking test") gen(error_sec8_05) ///
		list(x_q811_positive_perc x_q809_men_tested_perc x_q810_women_tested_perc `tested_sum')
	
	******************************************************************************************************
	**# Section 8 #06. No. who tested positive should sum up from individual genders
	******************************************************************************************************
	
	tempvar positive_sum
	egen `positive_sum' = rowtotal(q812_men_positive q813_women_positive)
	
	throw_error if q811_positive != `positive_sum' & q812_men_positive != .z & `positive_sum' != 0, ///
		message("No. of positive men and women does not sum up to total no. of positives") ///
		gen(error_sec8_06) list(q811_positive q812_men_positive q813_women_positive `positive_sum')
	
	******************************************************************************************************
	**# Section 8 #07. COVID deaths cannot exceed those who tested positive
	******************************************************************************************************
	
	throw_error if q814_died_covid > q811_positive & !missing(q814_died_covid) , ///
		message("COVID deaths greater than no. that tested positive") ///
		gen(error_sec8_07) list(q814_died_covid q811_positive)
	
	
	******************************************************************************************************
	**# Section 8 #08. COVID deaths should add up correctly 
	* (a) by age-group, and 
	* (b) by gender
	******************************************************************************************************
	
	tempvar gender_died agewise_died
	
	egen `gender_died' = rowtotal(q815_men_died_covid q816_women_died_covid)
	
	egen `agewise_died' = rowtotal(q817_blw18_died_covid q818_18to44_died_covid q819_abv44_died_covid)
		
	throw_error if q814_died_covid != `agewise_died' & !missing(q814_died_covid), /// 
		message("COVID deaths do not equal age-wise total") gen(error_sec8_08a) ///
		list(q814_died_covid q817_blw18_died_covid q818_18to44_died_covid q819_abv44_died_covid `agewise_died')
	
	throw_error if q814_died_covid != `gender_died' & !missing(q814_died_covid), ///
		message("COVID deaths do not equal gender-wise total") gen(error_sec8_08b) ///
		list(q814_died_covid q815_men_died_covid q816_women_died_covid `gender_died')

		
	******************************************************************************************************
	**# Section 8 #09. Total deaths cannot be less than COVID deaths
	******************************************************************************************************
	
	throw_error if q820_died_any < q814_died_covid, message ("Total deaths are less than COVID deaths") ///
		gen(error_sec8_09) list (q820_died_any q814_died_covid)

		
	******************************************************************************************************
	**# Section 8 #10. Total deaths from any disease should add up correctly
	* (a) by age-group
	* (b) by gender
	******************************************************************************************************
	
	tempvar any_gender any_agewise
	
	egen `any_gender' = rowtotal(q821_men_died_any q822_women_died_any)
	
	egen `any_agewise' = rowtotal(q823_blw18_died_any q824_18to44_died_any q825_above44_died_any)
	
	throw_error if q820_died_any != `any_agewise' & !missing(q820_died_any) , ///
		message("Total deaths from any disease do not equal age-wise total") ///
		gen (error_sec_8_10a) list(q820_died_any q823_blw18_died_any q824_18to44_died_any q825_above44_died_any `any_agewise')
	
	throw_error if q820_died_any != `any_gender' & !missing(q820_died_any) , ///
		message("Total deaths from any disease do not equal gender-wise total") ///
		gen (error_sec_8_10b) list(q820_died_any q821_men_died_any  q822_women_died_any `any_gender')
	
	******************************************************************************************************
	**# Section 8 #11. Vaccination should have started for 18-44 age-group later than for 45+ age-group
	* this is currently true in the dataset, it is throwing up an error only for those obs where dd/mm format was entered incorrectly
	******************************************************************************************************
	
	rename  q827_vaccn_start_45plus_* x_q827_vaccn_start_45plus_*
	rename  q826_vaccn_start_18plus_* x_q826_vaccn_start_18plus_*
	
	throw_error if x_q826_vaccn_start_18plus_m < x_q827_vaccn_start_45plus_m & !missing(x_q827_vaccn_start_45plus_m) & x_q826_vaccn_start_18plus_m !=0, ///
		message("Vaccination month for 18+ is earlier than that for 45+") gen(error_sec_8_11) ///
		list(x_q826_vaccn_start_18plus_m x_q827_vaccn_start_45plus_m)
		
		
	******************************************************************************************************
	**# Section 8 #12. Gender-wise: those with at least one vaccine shot cannot be fewer than those with both
	******************************************************************************************************
	
		throw_error if q831_men_vaccine_one_n > q119_ppl_num_2 & !missing(q831_men_vaccine_one_n), message("Number of men vaccinated cannot be greated than total number of men above 18") ///
			gen(error_total_men) list(q831_men_vaccine_one_n q119_ppl_num_2)
	
		throw_error if q832_women_vaccine_one_n > q119_ppl_num_1 & !missing(q831_men_vaccine_one_n), message("Number of women vaccinated cannot be greated than total number of women above 18") ///
			gen(error_total_women) list(q832_women_vaccine_one_n q119_ppl_num_1)
		
		throw_error if x_q831_men_vaccine_one_perc < x_q837_men_vaccine_both_perc, ///
			message ("Men with at least one dose lower than men with both doses") ///
			gen(error_sec_8_12_men) list(x_q831_men_vaccine_one_perc x_q837_men_vaccine_both_perc)

		throw_error if x_q832_women_vaccine_one_perc < x_q838_women_vaccine_both_perc, ///
			message ("Women with at least one dose lower than women with both doses") ///
			gen(error_sec_8_12_women) list(x_q832_women_vaccine_one_perc x_q838_women_vaccine_both_perc)
	
	
	******************************************************************************************************
	**# Section 8 #13. Age group-wise: those with at least one vaccine shot cannot be fewer than those with both
	******************************************************************************************************
	
	local num n p
	
	foreach x of local num {
		throw_error if q835_18to44_vaccine_`x' < q839_18to44_vaccine_both_`x' & !missing(q839_18to44_vaccine_both_`x'), ///
			message ("18-44 yr olds (`x') with at least one dose lower than those with both doses") ///
			gen(error_sec_8_13_18to44_`x') list (q835_18to44_vaccine_`x' q839_18to44_vaccine_both_`x')
	}
	
	foreach x of local num {
		throw_error if q836_above44_vaccine_`x' < q840_above44_vaccine_both_`x' & !missing(q840_above44_vaccine_both_`x'), ///
			message ("Above 44 agegroup (`x') with single dose lower than those with both doses") ///
			gen(error_sec_8_13_above44_`x') list (q836_above44_vaccine_`x' q840_above44_vaccine_both_`x')
	}
	
	******************************************************************************************************
	**# Section 8 #14. Vaccination totals by gender and age should match (at least one dose)
	******************************************************************************************************
	
	tempvar gender_vaccn_one_n age_vaccn_one_n
	
	egen `gender_vaccn_one_n' = rowtotal(q831_men_vaccine_one_n q832_women_vaccine_one_n)
	egen `age_vaccn_one_n' = rowtotal(q835_18to44_vaccine_n q836_above44_vaccine_n)
	
	throw_error if `gender_vaccn_one_n' != `age_vaccn_one_n', ///
		message ("Total vaccinations (count) of at least one dose as per gender and age wise distribution does not match") gen(error_sec_8_14_n) ///
		list(q831_men_vaccine_one_n q832_women_vaccine_one_n q835_18to44_vaccine_n q836_above44_vaccine_n)
	
	******************************************************************************************************
	**# Section 8 #15. Vaccination totals by gender and age should match (both doses)
	******************************************************************************************************
	
	tempvar gender_vaccn_both_n age_vaccn_both_n

	egen `gender_vaccn_both_n' = rowtotal(q837_men_vaccine_both_n q838_women_vaccine_both_n)
	egen `age_vaccn_both_n' = rowtotal(q839_18to44_vaccine_both_n q840_above44_vaccine_both_n)

	throw_error if `gender_vaccn_both_n' != `age_vaccn_both_n', ///
		message ("Total vaccination (count) of both doses as per gender and age wise distribution does not match") gen(error_sec_8_15_n) ///
		list(q837_men_vaccine_both_n q838_women_vaccine_both_n q839_18to44_vaccine_both_n q840_above44_vaccine_both_n)
		
	******************************************************************************************************
	**# Section 8 #16. Percentage willing to be vaccinated cannot be lower than those who got vaccinated
	* note: q829 is in levels (more than 25 less than 50 etc) and does not have actual percentage values listed for each village (other than 0 and 100%)
	* coarse estimate of % willingness calculated in 03b_create_errorcheck_workfile.do
	******************************************************************************************************	
	
	throw_error if x_vaccn_min_18to44 < q835_18to44_vaccine_p & !missing(q835_18to44_vaccine_p), ///
		message ("Percentage willing to get vaccinated lower than perc vaccinated with atleast one dose") ///
		gen(error_sec_8_16_18to44) list(x_vaccn_min_18to44 q835_18to44_vaccine_p)
	
	throw_error if x_vaccn_above44 < q836_above44_vaccine_p & !missing(q836_above44_vaccine_p), ///
		message("Percentage willing to get vaccinated lower than perc with at least one dose") ///
		gen(error_sec_8_16_above44) list(x_vaccn_above44 q836_above44_vaccine_p)
	
	
	******************************************************************************************************
	**# Section 8 #17. We expect smaller numbers of younger age-group (18-44) people to be vaccinated
	******************************************************************************************************
	
	local num n p
	
	foreach x of local num {
		throw_error if q840_above44_vaccine_both_`x' < q839_18to44_vaccine_both_`x' & overd_sec_8_17_`x' == 0, ///
			message ("Total (`x') with double dose higher for 18-44 age group ") ///
			gen(error_sec_8_17_`x') list(q840_above44_vaccine_both_`x' q839_18to44_vaccine_both_`x')
	}
	
	
	
	******************************************************************************************************
	**# Section 10 #01
	******************************************************************************************************
	
	throw_error if (q916_pads_govt_p + q917_pads_mkt_p) > 100 & !missing(q916_pads_govt_p , q917_pads_mkt_p), ///
		message("Percentage of market bought pads and govt supplies pads greater than 100") ///
		gen(error_sec_10_01) list(q916_pads_govt_p q917_pads_mkt_p)
	
	
	******************************************************************************************************
	**# Section 10 #02
	******************************************************************************************************
	

	forval i = 1/2 {
		throw_error if q1008_wedding_girls_`i' != x_wedding_girls_`i' & !missing(q1008_wedding_girls_`i'), ///
			message("Agewise sum of girls' wedding is inconsistent'") gen(error_sec_10_02_`i') ///
			list(q1008_wedding_girls_`i' q1014_wedding_girls_16_below_`i' q1013_wedding_girls_16_`i' q1012_wedding_girls_18_`i' ///
				q1011_wedding_girls_20_`i' q1010_wedding_girls_23_`i' q1009_wedding_girls_25_`i')
	
	}
	
	******************************************************************************************************
	**# Section Miscellaneous 
	******************************************************************************************************
	
	throw_error if x_new_scarcity == 0 & scarcity == 1, message("error computing scarcity variables") gen(error_scarcity) list(scarcity x_new_scarcity)
	
	throw_error if q004_resp_edu == .a , message("Unexplained missingness") gen(error_missing_respedu) list(q004_resp_edu)
	throw_error if q432_hh_pucca_n == 0 & q431_hh_houses > 0, message("Number of Pucca Houses 0, hhs in pucca house non-zero: label is wrong for q431 possibly") gen(error_pucca_house) list(q431_hh_houses q432_hh_pucca_n)
	
	foreach i of numlist 1/9 888 {
		throw_error if q602_ntfp_list__`i' == .a, message("unexplained missingness") gen(error_missing_ntfp_`i') list(q602_ntfp_list__`i')
	}
	
	throw_error if q305_int_current__101 == .a, message("unexplained missingness for all q305 variables") gen(error_missing_q305) list(q305_int_current__101)
	throw_error if q507_irrigation__1 == .a, message("unexplained missingness for all q507 variables") gen(error_missing_q507) list(q507_irrigation__1)
	
	******************************************************************************************************
	**# List all errors, one village at a time
	******************************************************************************************************
	log on errors
	dis as err "Here is a village-wise listing of errors: "
	log off errors
	
	sort village_id
	
	tempvar any_error
	egen `any_error' = anymatch(error_*), value(1)
	
	keep if `any_error'
	forval i = 1/`=_N' {
		preserve
			keep surveyor village_id village_name error_*
			order surveyor village_id village_name error_*
			keep in `i'
			log on errors
			display as err  _n "village ID: " village_id[1] _n "village name: " village_name[1]
			
			foreach var of varlist error_* {
				if  `var'[1] == 1 display as err "`var'"	
			}
			log off errors
		restore
	}

	log close errors	
** most error checks include comparisons across multiple variables, retaining the relevant variables

	#delimit;
		keep village_id village_name surveyor error_* 
			hh_size q103_caste_1 q107_caste_2 q111_caste_3 
			x_q103A_caste_cat_corrected x_q107A_caste_cat_corrected x_q111A_caste_cat_corrected 
			x_q006A_resp_cat_corrected q006_resp_caste
			x_q118_large_land_hh_perc x_q501_agri_hh_perc_1 x_q114_landless_hh_perc
			x_class05_* x_class08_*  x_class10_* x_class12_* x_q125_graduate_perc_x_* 
			sumedu1 sumedu2 q202_source_num_* q203_source_func_summer_* q204_source_func_winter_*
			q208_water_time_summer_* q209_water_time_winter_* x_q218_fuel_primary_hh_perc_* 
			x_q219_lpg_ujjwala_perc  x_q220_lpg_other_perc
			q222_distance_facility_9 q222_distance_facility_10 q222_distance_facility_11
			q222_distance_facility_2  q222_distance_facility_3  q222_distance_facility_4
			q221_number_facility_6  q221_number_facility_7  q221_number_facility_8
			q401_lockdown_months__* q411_returned_hh  q417_remigrated_hh  q415_residing_hh
			q504_agri_wages_1  q504_agri_wages_2 q708_nrega_type_post__10 q709_nrega_type_pre__10 q433_hh_iay
			q502_agri_lab_1  q502_agri_lab_2 q503_agri_days_1  q503_agri_days_2
			x_q604_ntfp_sale_hh_perc_* q605_ntfp_sale_where__6_3 q602_ntfp_list__1 ; 
	#delimit cr

	save "../03_processed/srijan_errors", replace

	keep village_id village_name surveyor error_*
	
	export delimited using "../06_outputs/01_error_checking/srijan_errors.csv", replace
		
project , creates("../03_processed/srijan_errors.dta")
project , creates("../06_outputs/01_error_checking/srijan_errors.csv") 
project , creates("../06_outputs/01_error_checking/error_log.txt")
project , creates("../06_outputs/01_error_checking/sec1_05_migrant.png")
project , creates("../06_outputs/01_error_checking/sec1_05_seasonal.png")
project , creates("../06_outputs/01_error_checking/sec1_05_nrega.png")
project , creates("../06_outputs/01_error_checking/sec1_05_casual_labour.png")
