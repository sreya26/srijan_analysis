****************************************************************************************************
* this do-file aims to give .z or "N/A" values to all situations in the data where there is a valid
* reason for a missing value
****************************************************************************************************

	
project , uses("../04_temp/srijan_village_survey_data_merged.dta")
	

*******************************************************************************************************
* a small program to do the actual work of replacing raw missing values ("." or "") with ".z" and "N/A"
*******************************************************************************************************
	
capture program drop validate_missing
program define validate_missing
	syntax varname if , [Label(string)]
	if "`label'" == "" local label "valid missing"
	capture confirm var `varlist' 
	if _rc != 0 {
		dis as error "the variable `varlist' does not exist"
		exit
	}
	capture confirm numeric var `varlist'
	if _rc == 0 {
		replace `varlist' = .z `if'
		label define `varlist' .z "`label'", add
		label values `varlist' `varlist'
	}
	capture confirm string var `varlist'
	if _rc == 0 {
		replace `varlist' = "N/A" `if'
	}
	
end
	

****************************************************************************************************
** the main code starts here
****************************************************************************************************
	
	use "../04_temp/srijan_village_survey_data_merged.dta", clear
	note: This dataset incorporates missing value validations, as specified till 10 August 2021 14:30. 
	
	notes

	****************************************************************************************************
	**# MAIN SURVEY
	****************************************************************************************************
	
	****************************************************************************************************
	**## Section 1
	****************************************************************************************************


	****************************************************************************************************	
	**### 1.1 q103b_caste_1_other, q107b_caste_2_other and q111b_caste_3_other will be missing if the 
	* corresponding qXXX_caste_? varible is not "other" (888)
	****************************************************************************************************	
	local caste_ques q103 q107 q111
	forval i = 1/3 {
		local qnum: word `i' of `caste_ques'
		validate_missing `qnum'b_caste_`i'_other if `qnum'_caste_`i' != 888

	}
	
	****************************************************************************************************

	****************************************************************************************************	
	**### 1.2 q105b_occ_caste_1_other, q109b_occ_caste_2_other, and q113b_occ_caste_1_other will be missing 
	* if the corresponding qXXX_occ_caste_?_888 is not selected
	****************************************************************************************************	
	
	local caste_ques q105 q109 q113
	forval i = 1/3 {
		local qnum: word `i' of `caste_ques'
		validate_missing `qnum'b_occ_caste_`i'_other if `qnum'_occ_caste_`i'__888 == 0
	}

	
	****************************************************************************************************
	**### 1.3 q107_caste_2 variables will be missing if no hhs reported belonging to a second major caste
	**   Or if the number of hhs belonging to q103_caste_1 is equal to the total number of households in the village 
	**   Or the percentage of hhs belonging to q103_caste_1 is equal to 100% in the village
	****************************************************************************************************
	
	foreach var of varlist q107_caste_2 q107A_caste_cat q108_hh_caste_2_p q108_hh_caste_2_n q109_occ_caste_2__* {
		validate_missing `var'  if q104_hh_caste_1_n  == q101_hh | q104_hh_caste_1_p  == 100		
	}
	
	
	****************************************************************************************************
	**### 1.4 q111_caste_3 variables will be missing if no one in the village reported belonging to a third major caste
	**   or if the sum of HHs belonging to 103_caste_1 and 107_caste_2 in the village is equal to the total number of households in the village 
	*    or if the percentage of hhs belonging to 103_caste_1 and 107_caste_2 sums up to 100% in the village
	****************************************************************************************************	
	
	foreach var of varlist q111_caste_3 q111A_caste_cat q113_hh_caste_3_p q113_hh_caste_3_n q113_occ_caste_3__* {
		validate_missing `var' if (q108_hh_caste_2_n + q104_hh_caste_1_n) == q101_hh | ///
			(q108_hh_caste_2_p + q104_hh_caste_1_p) == 100	| ///
			q107_caste_2 == .z
	}
	
	
	****************************************************************************************************
	**## Section 2 and 3
	****************************************************************************************************

	****************************************************************************************************	
	**### 2.1 Number of drinking water sources in the village will be missing if no drinking water sources are listed for the village
	****************************************************************************************************	
	
	unab q202s: q202_source_num_?
	
	foreach var of local q202s {
		local num = substr("`var'",-1,.)
		validate_missing `var' if q201_drinking_water__`num' == 0
	}

	
	****************************************************************************************************
	**### 2.2 time taken to fetch water from water source and sufficiency of water from water source in summer will be missing
	**   if no households use the source as primary drinking water source in summer
	****************************************************************************************************
	
	local vars water_time_summer water_suff_summer
	local questions 208 210 
	
	forvalues x = 1/7 {
		capture confirm int variable q208_water_time_summer_`x'
		if _rc == 111 continue
		
		forval i = 1/2 { 
			local var: word `i' of `vars'
			local num: word `i' of `questions'
			validate_missing q`num'_`var'_`x' if q205_water_hh_summer_p_`x' == 0 | q205_water_hh_summer_n_`x' == 0
		}
	}

	
	****************************************************************************************************
	**### 2.3 time taken to fetch water from water source and sufficiency of water from water source in winter will be missing
	**   if no households use the source as primary drinking water source in winter
	****************************************************************************************************	

	local vars water_time_winter water_suff_winter
	local questions 209 211 
	
	forvalues x = 1/7 {
		capture confirm int variable q209_water_time_winter_`x'
		if _rc == 111 continue
		
		forval i = 1/2 { 
			local var: word `i' of `vars'
			local num: word `i' of `questions'
			validate_missing q`num'_`var'_`x' if q206_water_hh_winter_p_`x' == 0 | q206_water_hh_winter_n_`x' == 0
		}
	}

	
	****************************************************************************************************
	**### 2.4 variables for alternate water sources will be missing if there is no water scarcity in the village 
	****************************************************************************************************	

	foreach var of varlist q214_alt_water q214b_alt_water_other q215_dist_water q216_time_water_alt {
		validate_missing `var' if scarcity == 0
	}

	
	****************************************************************************************************
	**### 2.5 q217_fuel_other will be missing if no "other" sources of fuel are listed in the village
	****************************************************************************************************	
	validate_missing q217_fuel_other if q217_fuel__888 == 0
	
	****************************************************************************************************
	**## 2.6 q221_number_facility i.e number of facilities within the village will be missing for the following rowcodes: 
	* facility is not in village (rowcode 0)
	* nearest town (rowcode 1)
	* panchayat centre (rowcode 2)
	* block centre (rowcode 3)
	* district headquarter (rowcode 4)
	* mandi (rowcode 13)
	* metalled road (rowcode 18)
	****************************************************************************************************
	
	local vars q221_number_facility_1 q221_number_facility_2 q221_number_facility_3 q221_number_facility_4 q221_number_facility_13 q221_number_facility_18

	foreach var of local vars {
		validate_missing `var' if `var' == `var'
	}
		
	****************************************************************************************************
	**### 2.7 q222_distance_facility will be missing for the rowcodes in ques 2.6
	* For other rowcodes: q222_distance_facility will be missing for each facility that is in the village 
	*  i.e q221_number_facility_`x' != 0
	****************************************************************************************************
	
	local facilities 5 6 7 8 9 10 11 12 14 15 16 17 
	foreach x of local facilities {
		validate_missing q222_distance_facility_`x'  if q221_number_facility_`x' != 0
	}
	
	
	****************************************************************************************************
	**### 2.8 The number of new houses built under Indira Awas Yojna will be missing if no new houses 
	*     were built in the village since April 2020
	****************************************************************************************************
	
	validate_missing q433_hh_iay if q429_new_houses  == 0 
	
	****************************************************************************************************
	**### 2.9 number of new houses built on own land/common village land/forest land/rented land since April 2020 
	*     will be missing if no new houses were built in the village since April 2020
	****************************************************************************************************
	
	forvalues x = 1/4 {
		validate_missing q430_new_houses_`x' if q429_new_houses  == 0 
	}
	
	
	****************************************************************************************************
	**### 3.1 Current active interventions by SRIJAN in the village will be missing if SRIJAN has stopped working in the village
	****************************************************************************************************
	
	foreach x of numlist 101/104 201/209 301/306 401/408 {
		capture confirm int variable q305_int_current__`x'
		if _rc == 111 continue
		validate_missing q305_int_current__`x' if q302_srijan_end != "0000"
	}
	
	
	****************************************************************************************************
	**### 3.2 Choice to list details about current interventions listed in q305_int_current__ will be missing 
	*     if SRIJAN has stopped working in the village
	****************************************************************************************************
	
	validate_missing int_current_detail_indct if q302_srijan_end != "0000"
	
	****************************************************************************************************
	**### 3.3 detailed discription of current SRIJAN interventions listed in q305_int_current__ will be missing 
	*     if respondent chose to not add details in ques 3.2
	****************************************************************************************************
		
	foreach var of varlist q305A_int_curr_des__* {
		validate_missing `var' if int_current_detail_indct == 2 | q302_srijan_end != "0000"
	}
	
	****************************************************************************************************
	**### 3.4 detailed discription of past SRIJAN interventions will be missing if respondent chose to not 
	*     add details of past SRIJAN interventions (int_past_detail_indct == 2)
	****************************************************************************************************
	
	foreach var of varlist q306A_int_past_des__* {	
		validate_missing `var' if int_past_detail_indct == 2
	}
		
		
		
		
	****************************************************************************************************
	**## Section 4
	****************************************************************************************************

	****************************************************************************************************	
	**### 4.1 q402b_restr_21_other will be missing if 888 in q403_restr_21 wasn't selected
	****************************************************************************************************
	
	validate_missing q402b_restr_21_other if q403_restr_21__888 == 0

	
	****************************************************************************************************
	**### 4.2 First major states of perm migration and indicator for second major dest of perm migration 
	*     will be missing if in a year no households have someone working outside the village for most of 
	*     the year (q404_perm_migrant_hh) and if no individual works outside the village (q405_perm_migrant_pop)
	****************************************************************************************************
	
	foreach var of varlist q406_mig_dest_state_1 q407_dest_2_indct {
		validate_missing `var' if q405_perm_migrant_pop == 0 & q404_perm_migrant_hh == 0
	}
	
	
	****************************************************************************************************	
	**### 4.3 and 4.4 Second major states of perm migration and indicator for third major dest of perm migration 
	*             will be missing if no second major dest of migration was listed for the village
	****************************************************************************************************
	
	foreach var of varlist q408_mig_dest_state_2 q409_dest_3_indct {
		validate_missing `var' if q407_dest_2_indct == 2
	}
	
	****************************************************************************************************
	**### 4.5 Third major states of perm migration will be missing if no third major dest of perm migration 
	*     was listed for the village
	****************************************************************************************************
	
	validate_missing q410_mig_dest_state_3 if q409_dest_3_indct == 2
	
	
	****************************************************************************************************
	**### 4.6 Number of households who have someone who returned to the village between April 2020 and March 2021 
	*     will be missing if no households had someone working outside the village for most of the year
	****************************************************************************************************
	
	validate_missing q411_returned_hh if q404_perm_migrant_hh ==  0
	
	
	****************************************************************************************************
	**### 4.7 No. of ppl who returned to the village between April 2020 and March 2021 will be missing if the 
	*     number of hhs who had someone return to village is zero
	****************************************************************************************************
	
	validate_missing q412_returned_pop if q411_returned_hh == 0

	****************************************************************************************************	
	**### 4.7 Three major occupations that migrants were involved on their return to the village will be missing 
	*     if number of hhs who had someone return is zero
	****************************************************************************************************
	
	foreach x of numlist 1/13 888 {
		capture confirm int variable q413_returned_occ__`x'
		if _rc == 111 continue
		validate_missing q413_returned_occ__`x' if q411_returned_hh == 0
	}

	****************************************************************************************************
	**### 4.8 q413b_returned_occ_other will be missing if no "other" occupation was listed
	****************************************************************************************************
	
	validate_missing q413b_returned_occ_other if q413_returned_occ__888 == 0
	
	****************************************************************************************************
	**### 4.9 q414b_mig_skills_other wil be missing if no "other" skill was listed
	****************************************************************************************************
	
	validate_missing q414b_mig_skills_other if q414_mig_skills__888 == 0
	
	****************************************************************************************************
	**### 4.10 Variables capturing those households for which people returned to village and remained/remigrated will be missing if 
	** 	no households had someone working outside the village for most of the year and if no household had migrants return to the village
	****************************************************************************************************
	
	foreach var of varlist q415_residing_hh q417_remigrated_hh {
		validate_missing `var' if q411_returned_hh == 0 | q404_perm_migrant_hh ==  0
	}
	
	****************************************************************************************************
	**### 4.11 Variables capturing no of people who returned to village and remained/remigrated will be missing 
	* 	if no migrant returned to the village 
	****************************************************************************************************	

	foreach var of varlist q416_residing_pop q418_remigrated_pop {
		validate_missing `var' if q412_returned_pop  == 0
	}

	****************************************************************************************************
	**### 4.12 Reasons for migration will be missing if of those people who returned to the village, none went 
	*      back again to work outside the village (q418_remigrated_pop), and if no one went to work outside 
	*      the village for the first time after the lockdown (q420_migrated_new_pop)
	****************************************************************************************************
	
	foreach x of numlist 1/11 888 {
		capture confirm int variable q421_mig_why__`x'
		if _rc == 111 continue
		validate_missing q421_mig_why__`x' if q418_remigrated_pop == 0 & q420_migrated_new_pop == 0 	
	}
	
	****************************************************************************************************
	**### 4.13 q421b_mig_why_other wil be missing if no "other" reason for migration was listed
	****************************************************************************************************

	validate_missing q421b_mig_why_other if q421_mig_why__888 == 0
	
	****************************************************************************************************
	**### 4.14 and 4.15 First major states for seasonal migration and indicator for second major dest for 
	*               seasonal migration will be missing if no hhs or individuals participated in seasonal migration
	****************************************************************************************************
	
	foreach var of varlist q424_ss_mig_dest_state_1 q425_ss_dest_2_indct {
		validate_missing `var' if q422_seasonal_migrant_hh == 0 & q423_seasonal_migrant_pop == 0
	}
	
	****************************************************************************************************
	**### 4.16 Second major states for seasonal migration and indicator for third major dest for seasonal 
	*      migration will be missing if no one in the village reported seasonal migration to a second major dest
	****************************************************************************************************
	
	foreach var of varlist q426_ss_mig_dest_state_2 q427_ss_dest_3_indct {
		validate_missing `var' if q425_ss_dest_2_indct == 2
	}

	****************************************************************************************************
	**### 4.17 Third major states for seasonal migration will be missing if no one in the village reported 
	*      seasonal migration to a third major dest
	****************************************************************************************************
	
	validate_missing q428_ss_mig_dest_state_3 if q427_ss_dest_3_indct == 2

	
	
	
	****************************************************************************************************
	**## Section 5
	****************************************************************************************************

	****************************************************************************************************	
	**### 5.1 q502_agri_lab q503_agri_days will be missing if no HHs or individuals in the village are engaged in agriculture
	****************************************************************************************************
	
	local vars q502_agri_lab q503_agri_days
	
	foreach var of local vars  {
		forval i = 1/2 {
			validate_missing `var'_`i'  if q501_agri_hh_p_`i' == 0 | q501_agri_hh_n_`i' == 0
		}
	}
	
	****************************************************************************************************
	**### 5.2 q504_agri_wages will be missing if no one in the village was employed as an agricultural labourer
	****************************************************************************************************
	
	forval i = 1/2 {
		validate_missing q504_agri_wages_`i' if q502_agri_lab_`i' == 0 
	}
	
	****************************************************************************************************
	**### 5.3 q505b_challenge_other will be missing if no "other" major challenges were faced by 
	*     agricultural labourers during the lockdown in 2020
	****************************************************************************************************
	
	validate_missing q505b_challenge_other if q505_challenge_lab__888 == 0
	
	****************************************************************************************************	
	**### 5.4 q506b_challenge_other will be missing if no "other" major challenges were faced by farmers 
	*     during the lockdown in 2020 
	****************************************************************************************************
	
	validate_missing q506b_challenge_other if q506_challenge_farm__888 == 0
	
	****************************************************************************************************
	**### 5.5 q507b_irrigation_other will be missing if no "other" major sources for irrigation were listed
	****************************************************************************************************
	
	validate_missing q507b_irrigation_other if q507_irrigation__888 == 0
	
	****************************************************************************************************
	**### 5.6 Reason for change in groundwater level will be missing if compared to usual times, 
	*     there has been no change in the groundwater level since April 2020?
	****************************************************************************************************	
	
	foreach x of numlist 1/7 888 {
		capture confirm int variable q509_gw_reason__`x'
		if _rc == 111 continue
		
		validate_missing q509_gw_reason__`x' if q508_gw_change == 3
	}
	
	****************************************************************************************************
	**### 5.7 New major problems faced due to groundwater reduction will be missing if there has been no change 
	*     in groundwater, or if it has been increasing since/before 2020
	****************************************************************************************************
	
	foreach x of numlist 0/7 888 {
		capture confirm int variable q510_gw_issues_new__`x'
		if _rc == 111 continue
	
		validate_missing q510_gw_issues_new__`x' if q508_gw_change != 1 & q508_gw_change != 2
	
	}
	
	****************************************************************************************************
	**### 5.8 q510b_gw_issues_new_other will be missing if no "other" major problems due to groundwater reduction was listed
	****************************************************************************************************
	
	validate_missing q510b_gw_issues_new_other if q510_gw_issues_new__888 == 0

	
	****************************************************************************************************
	**## Section 6
	****************************************************************************************************

	
	****************************************************************************************************	
	**### 6.1 q601b_terrain_oth will be missing if no "other" geographical terrain was listed
	****************************************************************************************************	
	validate_missing q601b_terrain_oth if q601_terrain__888 == 0
	
	****************************************************************************************************
	**### 6.2 NTFP collected will be missing if geographical terrain was not listed as forest
	****************************************************************************************************
	
	foreach x of numlist 1/9 888 {
		capture confirm int variable q602_ntfp_list__`x'
		if _rc == 111 continue		
		validate_missing q602_ntfp_list__`x' if q601_terrain__3 == 0
	}
	
	****************************************************************************************************
	**### 6.3 Where NTFP was sold will be missing if numb/perc of households who collect NTFP for sale is zero
	****************************************************************************************************
	
	forval x = 1/9 {
		capture confirm int variable q604_ntfp_sale_hh_p_`x'
		if _rc == 111 continue
		foreach i of numlist 1/6 888 {
			capture confirm int variable q605_ntfp_sale_where__`i'_`x'
			if _rc == 111 continue 
			validate_missing q605_ntfp_sale_where__`i'_`x' if q604A_ntfp_sale_hh_now_p_`x' == 0 | q604A_ntfp_sale_hh_now_n_`x' == 0
		}
	}

	
	****************************************************************************************************
	**### 6.3 Difficulties faced while selling NTFP during lockdown in 2020 will be missing if numb/perc of 
	*	HHs who collect NTFP for sale is zero
	****************************************************************************************************	

	forval x = 1/9 {
		capture confirm int variable q604_ntfp_sale_hh_p_`x'
		if _rc == 111 continue
		foreach i of numlist 0/5 888 {
			capture confirm int variable q606_ntfp_sale_diff__`i'_`x'
			if _rc == 111 continue 
			validate_missing q606_ntfp_sale_diff__`i'_`x' if q604A_ntfp_sale_hh_now_p_`x' == 0 | q604A_ntfp_sale_hh_now_n_`x' == 0
		}
	}
	
	
	****************************************************************************************************
	**### 6.4 q605b_ntfp_sale_other_? will be missing if no "other" places listed for selling NTFP
	****************************************************************************************************
	
	forval x = 1/9 {
		capture confirm int variable q605b_ntfp_sale_other_`x'
		if _rc == 111 continue
		validate_missing q605b_ntfp_sale_other_`x' if q605_ntfp_sale_where__888_`x' == 0
	}
	
	
	****************************************************************************************************
	**### 6.5 q606b_ntfp_diff_other_`x' will be missing if no "other" difficulties faced while selling NTFP during lockdown
	****************************************************************************************************
	
	forval x = 1/9 {
		capture confirm int variable q606b_ntfp_diff_other_`x'
		if _rc == 111 continue	
		validate_missing q606b_ntfp_diff_other_`x' if q606_ntfp_sale_diff__888_`x' == 0
	}
	
	
	****************************************************************************************************
	**### 6.6 q607_low_price_why_? will be missing if respondent did not state low price as a difficulty faced 
	*     while selling NTFP during lockdown period
	****************************************************************************************************
	
	forval x = 1/9 {
		capture confirm int variable q607_low_price_why_`x'
		if _rc == 111 continue
		
		validate_missing q607_low_price_why_`x' if q606_ntfp_sale_diff__3_`x' == 0
		
	}
	
	****************************************************************************************************
	**### 6.7 q607b_low_price_other_? will be missing if respondent listed no "other" reason for low price of NTFP
	****************************************************************************************************
	
	forval x = 1/9 {
		capture confirm int variable q607b_low_price_other_`x'
		if _rc == 111 continue	
		validate_missing q607b_low_price_other_`x' if q607_low_price_why_`x' != 888
	}
	
	
	
	****************************************************************************************************
	**## Section 7 
	****************************************************************************************************

	****************************************************************************************************	
	**### 7.1 q702_ration_months__* will be missing if ration received from Women Jan Dhan Benefit (Rs 500 one time) 
	** or PM Kisan Sammaan Yojna (Rs 2000 one time)
	** or if no number/perc of hhs in village reported receiving ration from any of the following ration sources -
	** Free Ration under Garib Kalyan Yojna
	** Ration or cash in lieu of Mid Day Meal from Schools
	** Ration and meal packets in lieu of Mid Day Meal from Anganwadi Centre
	****************************************************************************************************	

	forval x = 1/5 {
		capture confirm int variable q701_received_p_`x'
		if _rc == 111 continue 
		forval i = 3/21 {
			capture confirm int variable q702_ration_months__`i'_`x'
			if _rc == 111 continue
			validate_missing q702_ration_months__`i'_`x'  if `x' == 2 | `x' == 3 | q701_received_p_`x' == 0 | q701_received_n_`x' == 0
		}
	}
	
	
	****************************************************************************************************
	**### 7.2 q703_ration_other__?_? will be missing if ration source is not Free Ration under Garib Kalyan Yojna 
	*     or if no numb/perc of hhs in village reported receiving ration from this source
	****************************************************************************************************
	
	forval x = 1/5 {
		capture confirm int variable q701_received_p_`x'
		if _rc == 111 continue 
		forval i = 0/3 {
			capture confirm int variable q703_ration_other__`i'_`x'
			if _rc == 111 continue	
			validate_missing q703_ration_other__`i'_`x' if `x' != 1 | q701_received_p_`x' == 0 | q701_received_n_`x' == 0
		}
	}

	
	****************************************************************************************************
	**### 7.3 q705_empt_nrega_* q706_empt_chng_* will be missing if no HHs in village benefitted from NREGA employment
	****************************************************************************************************

	
	foreach var of varlist q705_empt_nrega_* q706_empt_chng_* {
		validate_missing `var' if q704_empt_nrega_tot == 0
	}

	
	****************************************************************************************************
	**### 7.3 and 7.4 q707_perc_chng_empt_? will be missing if no HHs reported change in NREGA employment since 2020 
	*             or if no HHs benefitted from NREGA employment
	****************************************************************************************************
	
	forval i = 1/2 {
		validate_missing q707_perc_chng_empt_`i' if q706_empt_chng_`i' == 2 | q704_empt_nrega_tot == 0
	}

	
	****************************************************************************************************
	**### 7.5 q708b_nrega_post_other will be missing if nobody listed any "other" type of work completed under NREGA post April 2020
	****************************************************************************************************
	
	validate_missing q708b_nrega_post_other if q708_nrega_type_post__888 == 0 
	
	****************************************************************************************************
	**### 7.6 q709b_nrega_pre_other will be missing if nobody listed any "other" type of work completed under NREGA pre April 2020
	****************************************************************************************************
	
	validate_missing q709b_nrega_pre_other if q709_nrega_type_pre__888 == 0

	
	
	****************************************************************************************************
	**# ASHA SURVEY
	****************************************************************************************************
	
	****************************************************************************************************
	**## Section 8
	****************************************************************************************************

	****************************************************************************************************	
	**### 8.1 q803b_test_location_other will be missing if no "other" location for nearest COVID testing centre 
	****************************************************************************************************
	
	validate_missing q803b_test_location_other if q803_test_location != 888

	
	****************************************************************************************************
	**### 8.2 q812_men_positive q813_women_positive will be missing if no one in the village tested positive since April 2021
	****************************************************************************************************
	
	foreach var of varlist q812_men_positive q813_women_positive {
		validate_missing `var' if q811_positive == 0
	}
	
	****************************************************************************************************
	**### 8.3 Following variables will be missing if no COVID deaths since April 2020
	****************************************************************************************************
	
	foreach var of varlist q815_men_died_covid q816_women_died_covid q817_blw18_died_covid q818_18to44_died_covid q819_abv44_died_covid {
		validate_missing `var' if q814_died_covid == 0
	}

	****************************************************************************************************
	**### 8.4 Following variables will be missing if no deaths since April 2020
	****************************************************************************************************

	
	foreach var of varlist q821_men_died_any q822_women_died_any q823_blw18_died_any q824_18to44_died_any q825_above44_died_any {
		validate_missing `var' if q820_died_any  == 0
	}

	
	****************************************************************************************************
	**### 8.5 Reason for no vaccination will be missing if 100% of the village willing to be vaccinated
	****************************************************************************************************
	
	forval x = 1/4 {
		foreach i of numlist 1/9 888 {
			validate_missing q830_no_vaccn_rsn__`i'_`x' if q829_vaccn_will_`x' == 6
		}
	}
	
	****************************************************************************************************
	**### 8.6 q830b_no_vaccn_rsn_oth_? will be missing if no "other" reason for not participating in vaccination
	****************************************************************************************************
	
	forval x = 1/4 {
		capture confirm int variable q830b_no_vaccn_rsn_oth_`x'
		if _rc == 111 continue 
		validate_missing q830b_no_vaccn_rsn_oth_`x' if q830_no_vaccn_rsn__888_`x' != 1
	}

	****************************************************************************************************
	**### 8.7 The following variables will be missing if q000j_unit = 2 (answers in numbers)
	****************************************************************************************************

	local p_varlist q831_men_vaccine_one_p q832_women_vaccine_one_p q835_18to44_vaccine_p q836_above44_vaccine_p ///
					q837_men_vaccine_both_p q838_women_vaccine_both_p q839_18to44_vaccine_both_p q840_above44_vaccine_both_p

	foreach var of varlist `p_varlist' {
		validate_missing `var' if q000j_unit == 2
	}
	

	****************************************************************************************************
	**### 8.8 The following variables will be missing if q000j_unit = 1 (answers in percentages)
	****************************************************************************************************

	local n_varlist q831_men_vaccine_one_n q832_women_vaccine_one_n q835_18to44_vaccine_n q836_above44_vaccine_n ///
					q837_men_vaccine_both_n q838_women_vaccine_both_n q839_18to44_vaccine_both_n q840_above44_vaccine_both_n ///
					total_vaccine_one vaccine_one_agewise_sum total_vaccine_both vaccine_both_sum_agewise

	foreach var of varlist `n_varlist' {
		validate_missing `var' if q000j_unit == 1
	}
	

	
	
	****************************************************************************************************
	**## Section 9
	****************************************************************************************************

	****************************************************************************************************	
	**### 9.1 q901_perc_chld_inst_2 will be missing since rowcode 2 corresponds to questions regarding child vaccinations
	** rowcode 1 corresponds to questions regarding institutional child deliveries 
	****************************************************************************************************
	
	forval x = 1/2 {
		validate_missing q901_perc_chld_inst_`x' if `x' == 2
	}

	
	****************************************************************************************************
	**### 9.2 q903_perc_chng_hlth_? will be missing if there was no change in institutional deliveries/child 
	* 		vaccinations relative to pre-pandemic level
	****************************************************************************************************
	
	forval x = 1/2 {
		validate_missing q903_perc_chng_hlth_`x' if q902_chng_hlth_serv_`x' == 3
	}

	
	****************************************************************************************************
	**### 9.3 q904_del_assist__?_2 will be missing since this rowcode corresponds to questions abt child vaccinations
	* will be missing if village did not report a decrease in percentage of institutional deliveries 
	****************************************************************************************************
	
	forval x = 1/2 {
		foreach i of numlist 1/6 888 {
			validate_missing q904_del_assist__`i'_`x' if `x' == 2 | q902_chng_hlth_serv_`x' != 4 & q902_chng_hlth_serv_`x' != 5
		}
	}
	
	****************************************************************************************************
	**### 9.4 q904b_del_assist_other_2 will be missing since this rowcode corresponds to questions abt child vaccinations
	** will be missing if no "other" source of assitance during delivery
	****************************************************************************************************
	
	forval x = 1/2 {
		validate_missing q904b_del_assist_other_`x' if q904_del_assist__888_`x' == 0
	}

	
	****************************************************************************************************
	**### 9.5 q906_chld_vaccn_assist_1 will be missing since this rowcode corresponds to questions abt institutional deliveries
	* will be missing if village did not report a decrease in percentage of child vaccinations
	****************************************************************************************************
	
	forval x = 1/2 {
			validate_missing q906_chld_vaccn_assist_`x' if `x' == 1 | q902_chng_hlth_serv_`x' != 4 & q902_chng_hlth_serv_`x' != 5
		
	}

	
	****************************************************************************************************
	**### 9.6 q906b_chld_vaccn_asst_oth_1 will be missing since this rowcode corresponds to questions abt institutional deliveris
	* will be missing if no "other" source of assistance for child vaccination
	****************************************************************************************************
	
	forval x = 1/2 {
		validate_missing q906b_chld_vaccn_asst_oth_`x' if q906_chld_vaccn_assist_`x' != 888 //check
	}

	****************************************************************************************************
	**### 9.7 q907b_asha_add_other will be missing if no "other" additional task reported by ASHA worker during pandemic in 2021
	****************************************************************************************************
	
	validate_missing q907b_asha_add_other if q907_asha_add__888 == 0
	
	****************************************************************************************************
	**### 9.8 q908_usual_trtmnt_4 i.e place where treatment was usually sought will be missing since this rowcode corresponds to COVID symptoms
	****************************************************************************************************
	
	forval x = 1/4 {
		validate_missing q908_usual_trtmnt_`x' if `x' == 4
	}
	
	****************************************************************************************************
	**### 9.9 q908b_usual_trtmnt_other_? will be missing if no "other" place where treatment was usually sought for symptoms
	****************************************************************************************************
	
	forval x = 1/4 {
		validate_missing q908b_usual_trtmnt_other_`x' if q908_usual_trtmnt_`x' != 888
	}
	
	****************************************************************************************************
	**### 9.10 q909_why_no_public__`i'_4 i.e reason for not usually going to public hospital will be missing for COVID symptoms
	** will be missing also if public hospital was earlier listed as usual place of treatment
	****************************************************************************************************
	
	forval x = 1/4 {
		foreach i of numlist 1/7 888{
			validate_missing q909_why_no_public__`i'_`x' if `x' == 4 | q908_usual_trtmnt_`x' == 1		
			}
	}
	
	****************************************************************************************************
	**### 9.11 q909b_why_no_pub_oth_? will be missing if no "other" reason for not seeking public healthcare
	****************************************************************************************************
	
	forval x = 1/4 {
			validate_missing q909b_why_no_pub_oth_`x' if q909_why_no_public__888_`x' == 0
	}
	
	****************************************************************************************************
	**### 9.12 q910A_case_indct_4 asks whether any cases of regular/chronic illnesses or cancer, 
	*		will be missing for COVID symptoms
	****************************************************************************************************
	
	forval x = 1/4 {
			validate_missing q910A_case_indct_`x' if `x' == 4
	}
	
	****************************************************************************************************
	**### 9.13 q910_trtmnt_now_4 will be missing for COVID symptoms
	** will be missing if no cases of regular/chronic illnesses or cancer reported in the village between April 2021 and June 2021
	****************************************************************************************************
	
	forval x = 1/4 {
			validate_missing q910_trtmnt_now_`x' if q910A_case_indct_`x' != 1 & `x' != 4
	}
	
	****************************************************************************************************
	**### 9.14 q908b_trtmnt_now_other_? will be missing if no "other" source of treatment between April 2021 and June 2021
	****************************************************************************************************
	
	forval x = 1/4 {
		validate_missing q908b_trtmnt_now_other_`x' if q910_trtmnt_now_`x' != 888
	}

	
	****************************************************************************************************
	**### 9.15 q911_chng_trtmnt__?_? will be missing usual source of treatment is the same as current source of treatment
	* will be missing for COVID symptoms
	* will be missing if no cases of regular/chronic illnesses or cancer reported in the village 
	* between April 2021 and June 2021
	****************************************************************************************************
	
	forval x = 1/4 {
		foreach i of numlist 1/10 888 {
			validate_missing q911_chng_trtmnt__`i'_`x' if q908_usual_trtmnt_`x' == q910_trtmnt_now_`x' | `x' == 4 | q910A_case_indct_`x' != 1
		}
	}
	
	****************************************************************************************************
	**### 9.16 q911b_reason_other_? will be missing if no "other" reason for change in treatment relative to usual
	****************************************************************************************************
	
	forval x = 1/7 {
		validate_missing q911b_reason_other_`x' if q911_chng_trtmnt__888_`x' == 0
	}
	
	
	****************************************************************************************************
	**### 9.17
	* Note: q912 and q914 in ASHA ques V1 was asked about girls 
	* q912 and q914 in ASHA ques V2 was asked about asha workers
	* depending on which village was surveyed using which verison of the ques -
	* q913_pads_where__? will be missing if girls did not receive sanitary napkins both pre and post pandemic OR
	* q913_pads_where__? will be missing if asha workers did not receive sanitary napkins both pre and post pandemic
	****************************************************************************************************
	
	
	foreach i of numlist 1/3 888 {
		validate_missing q913_pads_where__`i' if (q912_pads_month_pre_girls + q914_pads_month_post_girls) == 0 | (q912_pads_month_pre_asha + q914_pads_month_post_asha) == 0

		}
	
	****************************************************************************************************
	**### 9.18 q913b_pads_where_other will be missing if no "other" place from which sanitary napkin was received
	****************************************************************************************************
	
	validate_missing q913b_pads_where_other if q913_pads_where__888 == 0
	
	****************************************************************************************************
	**### 9.19 q915_pads_free will be missing if girls/asha workers (depending on ques version) never received any sanitary napkins 
	****************************************************************************************************
	
	validate_missing q915_pads_free if (q912_pads_month_pre_girls + q914_pads_month_post_girls) == 0 | ///
		(q912_pads_month_pre_asha + q914_pads_month_post_asha) == 0


		
	****************************************************************************************************
	**## Section 10
	****************************************************************************************************

	****************************************************************************************************	
	**### 10.1 Following variables will be missing if no religious/political/social gatherings took place in the last year
	****************************************************************************************************
	
	local gather q1002_gather_name q1003_gather_pop q1004_perc_mask_gather q1005_social_dist q1006_gather_place
	
	foreach y of local gather {
		forval x = 1/3{
			validate_missing `y'_`x' if q1001_gather_indct_`x' !=1
		}		
	}

	
	****************************************************************************************************
	**### 10.2 q1008_wedding_girls_? will be missing if no weddings took place in the village
	****************************************************************************************************
	
	forval x = 1/2 {
		validate_missing q1008_wedding_girls_`x' if q1007_wedding_total_`x' == 0
	}
	
	****************************************************************************************************
	**### 10.3 q1009_wedding_girls_25_? will be missing if no weddings of girls took place in the village
	****************************************************************************************************
	
	forval x = 1/2 {
		validate_missing q1009_wedding_girls_25_`x' if q1008_wedding_girls_`x' == 0
	}
	
	

	save "../03_processed/srijan_village_survey_data", replace

project , creates("../03_processed/srijan_village_survey_data.dta")	
