*************************************************************************************************************************************
*! version 1.0  | 21 July 2021 | Sreya Majumder & Hemanshu Kumar
*  this file is part of the SRIJAN project headed by Rohini Somanathan, Priyanka Arora and Hemanshu Kumar
*************************************************************************************************************************************  

project , uses("../03_processed/srijan_village_survey_data.dta")
project , uses("../03_processed/village_amenities_srijan_withsample.dta")



	use "../03_processed/srijan_village_survey_data", clear
	notes
	
	***************************************************************************************************
	**# SECTION 1: CREATING RELEVANT VARIABLES 
	***************************************************************************************************
	
	***************************************************************************************************
	**## Village Demography
	***************************************************************************************************
	***************************************************************************************************
	**### 00. Merging with srijan sample data to bring in location variables 
	***************************************************************************************************
	
	rename village_id village_code
	destring village_code, replace
	
	merge 1:1 village_code using "../03_processed/village_amenities_srijan_withsample.dta", keep(match) nogen

	
	rename village_code village_id 
	
	foreach var of varlist state_name district_name subdistrict_name block_name state_code district_code subdistrict_code block_code total_area total_hh total_pop sc_pop st_pop forest_area netsown_area irrigated_area gp_name locations_in_this_block locations_in_this_dist serial_no panchayat_name srijan_location {
		rename `var' vd_`var'
	}
	
	
	gen x_vd_sc_pop_perc = vd_sc_pop/vd_total_pop * 100
	label variable x_vd_sc_pop_perc "Percentage Scheduled Castes of Total Popn"
	format x_vd_sc_pop_perc %5.2f
	
	gen x_vd_st_pop_perc = vd_st_pop/vd_total_pop * 100
	label variable x_vd_st_pop_perc "Percentage of Scheduled Tribes of Total Popn"
	format x_vd_st_pop_perc %5.2f
	
	gen x_vd_forest_area_perc = vd_forest_area/vd_total_area * 100
	label variable x_vd_forest_area_perc "Percentage of Forest Area of Total Area"
	format x_vd_forest_area_perc %5.2f
	
	gen x_vd_netsown_area_perc = vd_netsown_area/vd_total_area * 100
	label variable x_vd_netsown_area_perc "Percentage of Netsown Area of Total Area"
	format x_vd_netsown_area_perc %5.2f
	
	
	labmask vd_state_code, val(vd_state_name)
	labmask vd_district_code, val(vd_district_name)
	labmask vd_subdistrict_code, val(vd_subdistrict_name)

	drop vd_state_name vd_district_name vd_subdistrict_name *_field

	*********************************************************************************************************************************
	**### 1. average hh size and female fraction of adult population in each village
	** Also restructuring major caste occupations variables from 16 indicators for each occp, to one variable per caste and rank type
	*********************************************************************************************************************************

	gen hh_size = q102_pop/q101_hh
	order hh_size, after(q101_hh)
		
	gen x_female_frac_of_adults = q119_ppl_num_1 / (q119_ppl_num_1 + q119_ppl_num_2) 
	label var x_female_frac_of_adults "Femal Fraction of Adults"
	order x_female_frac_of_adults, after(q119_ppl_num_2)
	
	*** CASTE OCCUPATION VARIABLES
	
	local ques 105 109 113 

	forvalues n = 1/3 {
		local q: word `n' of `ques'
		gen x_q`q'_first_occupation_caste_`n' = 0
		foreach i of numlist 1/15 888 {
			local q: word `n' of `ques'
			replace x_q`q'_first_occupation_caste_`n' = `i' if q`q'_occ_caste_`n'__`i' == 1
			replace x_q`q'_first_occupation_caste_`n' = q`q'_occ_caste_`n'__`i' if missing(q`q'_occ_caste_`n'__`i')
			label var x_q`q'_first_occupation_caste_`n' "First Major Occupation of q`q'_caste_`n'"
		}
	}

	forvalues n = 1/3 {
		local q: word `n' of `ques'
		gen x_q`q'_second_occupation_caste_`n' = 0
		foreach i of numlist 1/15 888 {
			local q: word `n' of `ques'
			replace x_q`q'_second_occupation_caste_`n' = `i' if q`q'_occ_caste_`n'__`i' == 2
			replace x_q`q'_second_occupation_caste_`n' = q`q'_occ_caste_`n'__`i' if missing(q`q'_occ_caste_`n'__`i')
			label var x_q`q'_second_occupation_caste_`n' "Second Major Occupation of q`q'_caste_`n'"
		}
	}


	#delimit ;
	label define caste_occupations 1 "Farming (own land)" 
						2 "Farming (leaseout/sharecrop/rented out)" 
						3 "Farming (lease in/sharecrop/rented in land)" 
						4 "Mixed Farming (Own and leased land)" 
						5 "Petty business without employees" 
						6 "Own Business with employees"
						7 "Casual Agricultural laborer"
						8 "Casual laborer outside agriculture"
						9 "MNREGA laborer"
						10 "Regular agricultural laborer"
						11 "Animal husbandry, Fishery, Beekeeping etc"
						12 "Engaged in collection and sale of Non Timber Forest Produce"
						13 "Government salaried"
						14 "Non-governement salaried"
						15 "Bonded labor"
						888 "Other"
						.a "Not Listed as Major Caste"
						.z  "Valid Missing"
						;
	#delimit cr
						
	label values x_q105_first_occupation_caste_1 x_q109_first_occupation_caste_2 x_q113_first_occupation_caste_3 caste_occupations
	label values x_q105_second_occupation_caste_1 x_q109_second_occupation_caste_2 x_q113_second_occupation_caste_3 caste_occupations

	order x_q105_first_occupation_caste_1 x_q105_second_occupation_caste_1 x_q109_first_occupation_caste_2 x_q109_second_occupation_caste_2 x_q113_first_occupation_caste_3 x_q113_second_occupation_caste_3, after(q113b_occ_caste_3_other)
		
	***************************************************************************************************
	**### 2. to enable matching of caste with caste category 
	** restructuring caste occupation variables 
	***************************************************************************************************

	** obtaining first digits of caste names

	foreach var of varlist  q103_caste_1 q107_caste_2 q111_caste_3 q006_resp_caste q006_resp_caste_asha {
		gen x_`var'_firstdig = real(substr(string(`var', "%5.0g"), 1, 1))
	}

	** in the original variables, ST is coded as 2 and SC as 1; we reverse this to subsequently more easily match caste with corresponding category
	
	foreach var of varlist q107A_caste_cat q103A_caste_cat q111A_caste_cat q006A_resp_cat q006A_resp_asha_cat {
		gen x_`var'_corrected = 1 if `var' == 2
		replace x_`var'_corrected = 2 if `var' == 1
		replace x_`var'_corrected = `var' if `var' > 2
		label define x_`var'_corrected 1 "Scheduled Tribe (ST)" 2 "Scheduled Caste (SC)" 3 "Other Backward Caste (OBC)" 4 "General"
		label values x_`var'_corrected x_`var'_corrected
		label var x_`var'_corrected "Corrected caste categories"
	}
	
	label var x_q103A_caste_cat_corrected "Caste 1 Category"
	label var x_q107A_caste_cat_corrected "Caste 2 Category"
	label var x_q111A_caste_cat_corrected "Caste 3 Category"


	***************************************************************************************************
	**### 3. percentage variables for caste and landholding variables
	***************************************************************************************************
	
	
	gen x_q104_hh_caste_1_perc = (q104_hh_caste_1_n/q101_hh) * 100
	replace x_q104_hh_caste_1_perc = q104_hh_caste_1_p if missing(q104_hh_caste_1_n)

	
	gen x_q108_hh_caste_2_perc = (q108_hh_caste_2_n/q101_hh) * 100
	replace x_q108_hh_caste_2_perc = q108_hh_caste_2_p if missing(q108_hh_caste_2_n)
	
	
	gen x_q113_hh_caste_3_perc = (q113_hh_caste_3_n/q101_hh) * 100
	replace x_q113_hh_caste_3_perc = q113_hh_caste_3_p if missing(q113_hh_caste_3_n)
	
	** correcting caste indicators 
	
	replace q106_caste_2_indct = 2 if missing(q106_caste_2_indct) & x_q104_hh_caste_1_perc == 100
	
	tempvar caste_sum 
	egen `caste_sum' = rowtotal(x_q104_hh_caste_1_perc x_q108_hh_caste_2_perc) 
	
	replace q110_caste_3_indct = 2 if missing(q110_caste_3_indct) & `caste_sum' == 100
	
	
	** landholding variables 
	
	gen x_q114_landless_hh_perc = (q114_landless_hh_n/q101_hh) * 100
	replace x_q114_landless_hh_perc = q114_landless_hh_p if missing(q114_landless_hh_n)

	gen x_q115_marginal_land_hh_perc = (q115_marginal_land_hh_n/q101_hh) * 100
	replace x_q115_marginal_land_hh_perc = q115_marginal_land_hh_p if missing(q115_marginal_land_hh_n)
	
	gen x_q116_small_land_hh_perc = (q116_small_land_hh_n/q101_hh) * 100
	replace x_q116_small_land_hh_perc = q116_small_land_hh_p if missing(q116_small_land_hh_n)
	
	gen x_q117_medium_land_hh_perc = (q117_medium_land_hh_n/q101_hh) * 100 
	replace x_q117_medium_land_hh_perc = q117_medium_land_hh_p if missing(q117_medium_land_hh_n)
	
	gen x_q118_large_land_hh_perc = (q118_large_land_hh_n/q101_hh) * 100
	replace x_q118_large_land_hh_perc = q118_large_land_hh_p if missing(q118_large_land_hh_n)
	
	
	egen x_landless_and_marginal_perc = rowtotal(x_q114_landless_hh_perc x_q115_marginal_land_hh_perc)
	label var x_landless_and_marginal_perc "Landless and marginal farmer HHs (%)"
	format x_landless_and_marginal_perc %5.2f

	
	***************************************************************************************************
	**## Infrastructure
	***************************************************************************************************
	***************************************************************************************************
	**### 4. Water Scarcity
	***************************************************************************************************
	** Conditions for original scarcity variable are incorrect 
	
	egen x_summer_scarcity = anymatch(q210_water_suff_summer_*), values(2 3 4)
	label var x_summer_scarcity "Summer Scarcity"
	
	
	egen x_winter_scarcity = anymatch(q211_water_suff_winter_*),  values(2 3 4)
	label var x_winter_scarcity "Winter Scarcity"
	
	
	egen x_new_scarcity = anymatch(x_summer_scarcity x_winter_scarcity), values(1)
	label var x_new_scarcity "Scarcity"
	
	order x_summer_scarcity x_winter_scarcity x_new_scarcity, after(scarcity)

	***************************************************************************************************
	**### 5. creating percentage education variables
	***************************************************************************************************

	local edu_ques q120_below_class5 q121_class5 q122_class8 q123_class10 q124_class12 

	forval y = 1/2 {
		foreach stub of local edu_ques {
			gen x_`stub'_perc_x_`y' = (`stub'_n_x_`y'/q119_ppl_num_`y') * 100
			replace x_`stub'_perc_x_`y' = `stub'_p_x_`y' if missing(`stub'_n_x_`y')
			order x_`stub'_perc_x_`y', after(`stub'_p_x_`y')
		}
		
		** graduation only recorded in numbers
		gen x_q125_graduate_perc_x_`y' = (q125_graduate_n_x_`y'/q119_ppl_num_`y') * 100
		order x_q125_graduate_perc_x_`y', after(q125_graduate_n_x_`y')
		
	}

	
	***************************************************************************************************
	**### 6. creating educational attainment variables
	***************************************************************************************************
	
	forvalues x = 1/2 {
		egen x_class12_`x' = rowtotal(x_q124_class12_perc_x_`x' x_q125_graduate_perc_x_`x')
		label var x_class12_`x' "Educational Attainment"
		egen x_class10_`x' = rowtotal(x_q123_class10_perc_x_`x' x_class12_`x')
		label var x_class10_`x' "Educational Attainment"
		egen x_class08_`x' = rowtotal(x_q122_class8_perc_x_`x' x_class10_`x')
		label var x_class08_`x' "Educational Attainment"
		egen x_class05_`x' = rowtotal(x_q121_class5_perc_x_`x' x_class08_`x')
		label var x_class05_`x' "Educational Attainment"
		
	}

	
	***************************************************************************************************
	**### 7. Fuel LPG
	***************************************************************************************************
	
	forvalues i = 1/8 {
		capture confirm int variable q218_fuel_primary_hh_n_`i'
		if _rc == 111 continue
		gen x_q218_fuel_primary_hh_perc_`i' = (q218_fuel_primary_hh_n_`i'/q101_hh) * 100
		replace x_q218_fuel_primary_hh_perc_`i' = q218_fuel_primary_hh_p_`i' if missing(q218_fuel_primary_hh_n_`i')
		order x_q218_fuel_primary_hh_perc_`i', after(q218_fuel_primary_hh_p_`i')
	}
	

	gen x_q219_lpg_ujjwala_perc = (q219_lpg_ujjwala_n/q101_hh) * 100
	replace x_q219_lpg_ujjwala_perc = q219_lpg_ujjwala_p if missing(q219_lpg_ujjwala_n)

	gen x_q220_lpg_other_perc = (q220_lpg_other_n/q101_hh) * 100
	replace x_q220_lpg_other_perc = q220_lpg_other_p if missing(q220_lpg_other_n)

	***************************************************************************************************
	**## Migration
	***************************************************************************************************
	***************************************************************************************************
	**### 8. Migrant percentages
	***************************************************************************************************
	
	replace q405_perm_migrant_pop = 0 if q404_perm_migrant_hh == 0 //currently it is missing

	
	gen x_q404_perm_migrant_hh_perc = q404_perm_migrant_hh / q101_hh * 100
	label var x_q404_perm_migrant_hh_perc "Permanent migrants hhs (%)"
	format x_q404_perm_migrant_hh_perc %5.2f
	order x_q404_perm_migrant_hh_perc, after(q404_perm_migrant_hh)
	
	gen x_q405_perm_migrant_perc = q405_perm_migrant_pop / q102_pop * 100
	replace x_q405_perm_migrant_perc = 0 if q404_perm_migrant_hh == 0
	label var x_q405_perm_migrant_perc "Permanent migrants (%)"
	format x_q405_perm_migrant_perc %5.2f
	order x_q405_perm_migrant_perc, after(q405_perm_migrant_pop)
	
	
	gen x_q411_returned_hh_perc = q411_returned_hh/q404_perm_migrant_hh * 100
	label var x_q411_returned_hh_perc "Returned migrants hhs (%)"
	format x_q411_returned_hh_perc %5.2f
	order x_q411_returned_hh_perc, after(q411_returned_hh)
	
	gen x_q412_returned_pop_perc = q412_returned_pop/q405_perm_migrant_pop * 100
	label var x_q412_returned_pop_perc "Returned migrants (%)"
	format x_q412_returned_pop_perc %5.2f
	order x_q412_returned_pop_perc, after(q412_returned_pop)
	
	gen x_q415_residing_hh_perc = q415_residing_hh/q404_perm_migrant_hh * 100
	label var x_q415_residing_hh_perc "Residing migrant hh (%)"
	format x_q415_residing_hh_perc %5.2f
	order x_q415_residing_hh_perc, after(q415_residing_hh)
	
	gen x_q416_residing_pop_perc = q416_residing_pop/q405_perm_migrant_pop * 100
	label var x_q416_residing_pop_perc "Residing migrants (%)"
	format x_q416_residing_pop_perc %5.2f
	order x_q416_residing_pop_perc, after(q416_residing_pop)
	
	gen x_q417_remigrated_hh_perc = q417_remigrated_hh/q404_perm_migrant_hh * 100
	label var x_q417_remigrated_hh_perc "Remigrated migrant hh (%)"
	format x_q417_remigrated_hh_perc %5.2f
	order x_q417_remigrated_hh_perc, after(q417_remigrated_hh)
	
	gen x_q418_remigrated_pop_perc = q418_remigrated_pop/q405_perm_migrant_pop * 100
	label var x_q418_remigrated_pop_perc "Remigrated migrants (%)"
	format x_q418_remigrated_pop_perc %5.2f
	order x_q418_remigrated_pop_perc, after(q418_remigrated_pop)
	
	
	gen x_q423_seasonal_migrant_perc = q423_seasonal_migrant_pop / q102_pop * 100
	label var x_q423_seasonal_migrant_perc "Seasonal migrants (%)"
	format x_q423_seasonal_migrant_perc %5.2f
	order x_q423_seasonal_migrant_perc, after(q423_seasonal_migrant_pop)
	
	egen x_migrant_perc = rowtotal(x_q405_perm_migrant_perc x_q423_seasonal_migrant_perc)
	label var x_migrant_perc "Migrant population (%)"
	format x_migrant_perc %5.2f
	order x_migrant_perc, after(q423_seasonal_migrant_pop) 
	
	***************************************************************************************************
	**## Agriculture
	***************************************************************************************************
	***************************************************************************************************
	**### 9. Perc variables for those engaged in agriculture 
	***************************************************************************************************
	
	gen x_q501_agri_hh_perc_1 = (q501_agri_hh_n_1/q101_hh) * 100
	replace x_q501_agri_hh_perc_1 = q501_agri_hh_p_1 if missing(q501_agri_hh_n_1)
	format x_q501_agri_hh_perc_1 %5.2f
	order x_q501_agri_hh_perc_1, after(q501_agri_hh_p_1)

	gen x_q501_agri_hh_perc_2 = (q501_agri_hh_n_2/q101_hh) * 100
	replace x_q501_agri_hh_perc_2 = q501_agri_hh_p_2 if missing(q501_agri_hh_n_2)
	format x_q501_agri_hh_perc_2 %5.2f
	order x_q501_agri_hh_perc_2, after(q501_agri_hh_p_2)

	gen x_q502_agri_lab_1_perc = q502_agri_lab_1/q102_pop * 100
	label var x_q502_agri_lab_1_perc "Agricultural labour (%) since April 2020"
	format x_q502_agri_lab_1_perc %5.2f
	order x_q502_agri_lab_1_perc, after(q502_agri_lab_1)
	
	gen x_q502_agri_lab_2_perc = q502_agri_lab_2/q102_pop * 100
	label var x_q502_agri_lab_2_perc "Agricultural labour (%) before April 2020"
	format x_q502_agri_lab_2_perc %5.2f
	order x_q502_agri_lab_2_perc, after(q502_agri_lab_2)
	
	*** NUMBER OF MONTHS OF NO TRANSPORT
	
	egen x_no_transport_months = rowtotal(q402_no_*)
	label var x_no_transport_months "Months of No Transportation"
	order x_no_transport_months, after(q402_no_transptn__21)
	
	***************************************************************************************************
	**## Forest Resources
	***************************************************************************************************
	***************************************************************************************************
	**### 10. NTFP 
	***************************************************************************************************

	foreach i of numlist 1/9 888 {
		capture confirm int variable q603_ntfp_hh_p_`i'
		if _rc == 111 continue
		gen x_q604_ntfp_sale_hh_perc_`i' = (q604_ntfp_sale_hh_n_`i'/q101_hh)*100
		replace x_q604_ntfp_sale_hh_perc_`i' = q604_ntfp_sale_hh_p_`i' if missing(q604_ntfp_sale_hh_n_`i')
		order x_q604_ntfp_sale_hh_perc_`i', after(q604_ntfp_sale_hh_p_`i')
		
	}

	replace NTFP_name_1 = "Firewood" if NTFP_name_1 == "जलावन की लकड़ी"
	replace NTFP_name_2 = "Saal/Siali Leaf"  if NTFP_name_2 == "साल/सियाली पत्ता"
	replace NTFP_name_3 = "Tendu leaf"  if NTFP_name_3 == "तेंदू पत्ता"
	replace NTFP_name_4 = "Mahua"  if NTFP_name_4 == "महुआ"
	replace NTFP_name_5 = "Seasonal fruits"  if NTFP_name_5 == "मौसमी फल"
	replace NTFP_name_6 = "Medicinal herbs and plants"  if NTFP_name_6 == "औषधीय जड़ी-बूटियां और पौधे"
	replace NTFP_name_7 = "Honey" if NTFP_name_7 == "शहद"
	replace NTFP_name_8 = "Chironji" if NTFP_name_8 == "चिरोंजी / गुठली"
	replace NTFP_name_9 = "Gond" if NTFP_name_9 == "गोंद"
	
	
	***************************************************************************************************
	**## 11. Imputed gender-wise population of village 
	***************************************************************************************************
	
	gen x_imputed_female_pop = x_female_frac_of_adults * q102_pop
	gen x_imputed_male_pop = q102_pop - x_imputed_female_pop

	***************************************************************************************************
	**## 12.ASHA survey dates : Dates for Vaccination must be in dd/mm form
	** V2 has dates in dd/mm form
	** V1 does not have dates in this format
	***************************************************************************************************
	
	foreach var of varlist q827_vaccn_start_45plus q826_vaccn_start_18plus {
		replace `var' = substr(`var',1,length(`var')-2)+"/"+substr(`var',-2,.) if strpos(`var',"/") == 0 & !missing(`var') & `var' != "0"
	}
	
	
	* date of vaccination
	foreach var of varlist q827_vaccn_start_45plus q826_vaccn_start_18plus {
		gen x_`var'_d = real(substr((`var'), 1, length(`var')-3))
	}
	
	* month of vaccination
	foreach var of varlist q827_vaccn_start_45plus q826_vaccn_start_18plus {
		gen x_`var'_m = real(substr((`var'), -2, .))
	}
	
	***************************************************************************************************
	**## COVID
	***************************************************************************************************
	***************************************************************************************************
	**### 13. Vaccination: Some gender-wise population percentages 
	***************************************************************************************************

	gen x_q831_men_vaccine_one_perc = q831_men_vaccine_one_p
	replace x_q831_men_vaccine_one_perc = q831_men_vaccine_one_n/q119_ppl_num_2 * 100 if missing(q831_men_vaccine_one_p)
	
	gen x_q832_women_vaccine_one_perc = q832_women_vaccine_one_p
	replace x_q832_women_vaccine_one_perc = q832_women_vaccine_one_n/q119_ppl_num_1 * 100 if missing(q832_women_vaccine_one_p)
	
	gen x_q837_men_vaccine_both_perc = q837_men_vaccine_both_p
	replace x_q837_men_vaccine_both_perc = q837_men_vaccine_both_n/q119_ppl_num_2 * 100 if missing(q837_men_vaccine_both_p)
	
	gen x_q838_women_vaccine_both_perc = q838_women_vaccine_both_p
	replace x_q838_women_vaccine_both_perc = q838_women_vaccine_both_n/q119_ppl_num_1 * 100 if missing(q838_women_vaccine_both_p)
	
	
	***************************************************************************************************
	**### 14. Vaccine willingness
	***************************************************************************************************
	* logic: Percentage willing to get vaccinated for each of the categories should be greater than percentage with at least one dose
	* coarsely converting levels to plausible % becomes unviable/arbitrary if we take minimum value in each range
	* since we'd want willingness to be always greater, taking maximum value in the range possible 
	
	egen x_vaccn_min_18to44 = rowmin(q829_vaccn_will_1 q829_vaccn_will_2) 
	gen x_vaccn_above44 = q829_vaccn_will_3
	
	foreach var of varlist x_vaccn_min_18to44 x_vaccn_above44{
		replace `var' = 0 if `var' == 1 //vaccn_will = 1 corresponds to 0%
		replace `var' = 25 if `var' == 2 //vaccn will = 2 corresponds to range 1-25%
		replace `var' = 50 if `var' == 3 //vaccn_will = 3 corresponds to range 26-50%
		replace `var' = 75 if `var' == 4 // vaccn_will = 4 corresponds to range 51-75%
		replace `var' = 99 if `var' == 5 // vaccn_will = 5 corresponds to range 76-99%
		replace `var' = 100 if `var' == 6 // vaccn_will = 6 corresponds to 100%
	}

	
	***************************************************************************************************
	**### 15. Covid Tested and Covid Positive: some perc variables  
	***************************************************************************************************
	
	gen x_q811_positive_perc = q811_positive/q102_pop * 100 
	label var x_q811_positive_perc "Perc of Popn that Tested Positive"
	format x_q811_positive_perc %5.2f
	order x_q811_positive_perc, after(q811_positive)
	
	gen x_q809_men_tested_perc = q809_men_tested_p
	replace x_q809_men_tested_perc = q809_men_tested_n/q119_ppl_num_2 * 100 if missing(q809_men_tested_p)
	
	gen x_q810_women_tested_perc = q810_women_tested_p
	replace x_q810_women_tested_perc = q810_women_tested_n/q119_ppl_num_1 * 100 if missing(q810_women_tested_p)
	
	
	***************************************************************************************************
	**## Conflicts and Social Issues
	***************************************************************************************************
	***************************************************************************************************
	**### 16. Weddings
	***************************************************************************************************
	
	forval i = 1/2 {
		egen x_wedding_girls_`i' = rowtotal(q1014_wedding_girls_16_below_`i' q1013_wedding_girls_16_`i' q1012_wedding_girls_18_`i' q1011_wedding_girls_20_`i' q1010_wedding_girls_23_`i' q1009_wedding_girls_25_`i')
	}
	
	order x_wedding_*, after(q1014_wedding_girls_16_below_2)
	
	***************************************************************************************************
	**## Social Security
	***************************************************************************************************
	***************************************************************************************************
	**### 17. Ration Assitance
	***************************************************************************************************
	
	forvalues i = 1/5 {
		gen x_q701_received_perc_`i' = q701_received_p_`i' if !missing(q701_received_p_1)
		replace x_q701_received_perc_`i' = q701_received_n_`i'/q101_hh * 100 if missing(q701_received_p_1)
	 }
	 
	 label var x_q701_received_perc_1 "free ration under Garib Kalyan Yojna"
	 label var x_q701_received_perc_2 "Women Jan Dhan Benefit"
	 label var x_q701_received_perc_3 "PM Kisan Sammaan Yojna"
	 label var x_q701_received_perc_4 "ration/cash (Mid Day Meal) from Schools"
	 label var x_q701_received_perc_5 "ration/meal (Mid Day Meal) from awc"
	 
	 order x_q701_*, after(q701_received_n_5)
	 
	 *** total months of ration assistance
	
	 egen x_q702_months_1 = rowtotal(q702_ration_months__*_1)
	 egen x_q702_months_2 = rowtotal(q702_ration_months__*_2)
	 egen x_q702_months_3 = rowtotal(q702_ration_months__*_3)
	 egen x_q702_months_4 = rowtotal(q702_ration_months__*_4)
	 egen x_q702_months_5 = rowtotal(q702_ration_months__*_5)
	 
	 label var x_q702_months_1 "free ration under Garib Kalyan Yojna"
	 label var x_q702_months_2 "Women Jan Dhan Benefit"
	 label var x_q702_months_3 "PM Kisan Sammaan Yojna"
	 label var x_q702_months_4 "ration/cash (Mid Day Meal) from Schools"
	 label var x_q702_months_5 "ration/meal (Mid Day Meal) from awc"
	 
	order x_q702_*, after(q702_ration_months__21_5)
	
	***************************************************************************************************
	**# SECTION 2: LABELLING ROSTER VARIABLES
	***************************************************************************************************	
	*****************************************************************************************************
	**## Labelling PERC Variables created above 
	*****************************************************************************************************
	
	#delimit ;
	
	local perc_varlist q104_hh_caste_1 q108_hh_caste_2 q113_hh_caste_3 q114_landless_hh q115_marginal_land_hh q116_small_land_hh //
	q117_medium_land_hh q118_large_land_hh q219_lpg_ujjwala q220_lpg_other q809_men_tested q810_women_tested q831_men_vaccine_one //
	q832_women_vaccine_one q837_men_vaccine_both q838_women_vaccine_both; 
	
	#delimit cr
	
	 foreach y of local perc_varlist {
	 	local p_label: variable label `y'_p
		order x_`y'_perc , after(`y'_p)
		label var x_`y'_perc "`p_label'"
		format x_`y'_perc %5.2f
   }
	
	order x_landless_and_marginal_perc, after(x_q115_marginal_land_hh_perc) ///ADD TO CODEBOOK

	*****************************************************************************************************
	**## Labelling Roster Variables: EDU 
	*****************************************************************************************************
	
	local edu_code             1                       2
	local edu      `" "women above 18 years"    "men above 18 years" "'
	local ques_edu q119_ppl_num q125_graduate_n_x q124_class12_p_x q124_class12_n_x q123_class10_p_x q123_class10_n_x q122_class8_p_x q122_class8_n_x q121_class5_p_x q121_class5_n_x q120_below_class5_p_x  q120_below_class5_n_x sum_edu_n x_q120_below_class5_perc_x x_q121_class5_perc_x x_q122_class8_perc_x x_q123_class10_perc_x x_q124_class12_perc_x x_q125_graduate_perc_x
	
	
	foreach i of local edu_code {
		local label: word `i' of `edu'
		foreach q of local ques_edu {
			label var `q'_`i' "`q' of `label'"
		}
	}
	

	*****************************************************************************************************
	**## Labelling Roster Variables: DW
	*****************************************************************************************************
	
	local dw_code     1				2		3		 4		   5			6			7
	local dw `" "common taps"  "handpumps"  "ponds" "wells" "rivers etc" "pvt tap" "govt provided pvt tap" "'
	
	local ques_dw q202_source_num q203_source_func_summer q204_source_func_winter q205_water_hh_summer_p q205_water_hh_summer_n q206_water_hh_winter_p q206_water_hh_winter_n q207_water_dist q208_water_time_summer q209_water_time_winter q210_water_suff_summer q211_water_suff_winter
	
	
	foreach i of local dw_code {
		local label: word `i' of `dw'
		foreach q of local ques_dw {
			capture confirm var `q'_`i'
			if _rc != 0 {
				dis as error "the variable `q'_`i' does not exist"
				continue
			}
			
			label var `q'_`i' "`q': `label'"
		}
	}
	
	*****************************************************************************************************
	**## Labelling Roster Variables: FUEL
	*****************************************************************************************************
	
	local fuel_code  1              2                      3                       4         5           6      7       8
	local fuel `" "firewood"  "crop residue/cowdung"  "firewood and cowdung cake" "LPG" "electricity" "solar" "coal" "biogas" "'
	
	local ques_fuel q218_fuel_primary_hh_p q218_fuel_primary_hh_n x_q218_fuel_primary_hh_perc
	
	
	foreach i of local fuel_code {
		local label: word `i' of `fuel'
		foreach q of local ques_fuel {
			capture confirm var `q'_`i'
			if _rc != 0 {
				dis as error "the variable `q'_`i' does not exist"
				continue
			}
			
			label var `q'_`i' "`q': `label'"
		}
	}
	
	*****************************************************************************************************
	**## Labelling Roster Variables: FAC
	*****************************************************************************************************
	
	
	local fac_code 1  2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 
	local fac `" "nearest town" "panchayat centre" "block centre" "district headquarter" "awc and mini awc" "primary school" "middle school" "secondary/senior secondary school"  "PHC" "CHC" "hospital" "fair price shop (PDS)" "mandi" "government procurement centre"  "bank kiosk"  "bank" "post office" "metalled road" "primary-health sub-centre" "'
                                                                         
	local ques_fac q221_number_facility q222_distance_facility
	
	foreach i of local fac_code {
		local label: word `i' of `fac'
		foreach q of local ques_fac {
			capture confirm var `q'_`i'
			if _rc != 0 {
				dis as error "the variable `q'_`i' does not exist"
				continue
			}
			
			label var `q'_`i' "`q': `label'"
		}
	}
	
	
	*****************************************************************************************************
	**## Labelling Roster Variables: HOUSES
	*****************************************************************************************************
	
	local house_code          1                                       2                                 3                                     4
	local house  `" "extension or new house on own land"  "new house on common village land"  "new house on forest land" "new house on rented/acquired common land since April 2020" "' 
	
	local ques_hous q430_new_houses
	
	foreach i of local house_code {
		local label: word `i' of `house'
		foreach q of local ques_hous {
			capture confirm var `q'_`i'
			if _rc != 0 {
				dis as error "the variable `q'_`i' does not exist"
				continue
			}
			
			label var `q'_`i' "new houses built: `label'"
		}
	}	
	
	
	*****************************************************************************************************
	**## Labelling Roster Variables: TIMELINE
	*****************************************************************************************************
	
	local time_code 		1				2
	local time `" "after April 2020" "before April 2020" "'
	local ques_time q501_agri_hh_p q501_agri_hh_n x_q501_agri_hh_perc q502_agri_lab q503_agri_days q504_agri_wages
	
	foreach i of local time_code {
		local label: word `i' of `time'
		foreach q of local ques_time {
			capture confirm var `q'_`i'
			if _rc != 0 {
				dis as error "the variable `q'_`i' does not exist"
				continue
			}
			
			label var `q'_`i' "`q': `label'"
		}
	}	
	
	
	*****************************************************************************************************
	**## Labelling Roster Variables: NTFP
	*****************************************************************************************************
	
	local ntfp_code  1          2                    3        4        5                   6                       7       8          9      
	local ntfp `" "firewood" "saal/siali leaf" "tendu leaf" "mahua" "seasonal fruit" "medicinal herbs and plants" "honey" "chironji" "gond" "'
	
	local ques_ntfp NTFP_name q603_ntfp_hh_p q603_ntfp_hh_n q604_ntfp_sale_hh_p q604_ntfp_sale_hh_n q603A_ntfp_hh_now_p q603A_ntfp_hh_now_n q604A_ntfp_sale_hh_now_p q604A_ntfp_sale_hh_now_n q607_low_price_why q607b_low_price_other q605b_ntfp_sale_other q606b_ntfp_diff_other x_q604_ntfp_sale_hh_perc
	
	
	
	foreach i of local ntfp_code {
		local label: word `i' of `ntfp'
		foreach q of local ques_ntfp {
			capture confirm var `q'_`i'
			if _rc != 0 {
				dis as error "the variable `q'_`i' does not exist"
				continue
			}
			
			label var `q'_`i' "`q': `label'"
			label var `q'_888 "`q': other ntfp"
		}
	}	
	
	
	
	local ntfp_where_code     1                        2     				3								4						5				6
	local ntfp_where `" "directly to market" "cooperative societies" "intermediaries in village" "intermediaries outside village" "forest dept" "forest comittee" "'

	local ques_ntfp_oth q605_ntfp_sale_where
	
	
	foreach j of local ntfp_where_code {
		local where: word `j' of `ntfp_where'
		foreach i of local ntfp_code {
			local label: word `i' of `ntfp'
		foreach q of local ques_ntfp_oth {
			capture confirm var `q'__`j'_`i'
			if _rc != 0 {
				dis as error "the variable `q'__`j'_`i' does not exist"
				continue
			}
			
			label var `q'__`j'_`i' " `label' sold: `where'"
			label var `q'__888_`i' "`label' sold: other"
			label var `q'__`j'_888 "other ntfp sold: `where'"
			label var `q'__888_888 "other ntfp sold: other"
		}
	}	
	}
	
	
	local ntfp_dif_code     0                        1    										2			 3                    4 									5
	local ntfp_dif `" "no difficulties" "unable to access market(lack of transport)" "lack of demand" "low prices" "excess commission by intermediaries" "absence of intermediaries" "'
	local ques_ntfp_dif q606_ntfp_sale_diff
	
	foreach j of local ntfp_dif_code {
		local k = `j'+1
		local dif: word `k' of `ntfp_dif'
		foreach i of local ntfp_code {
			local label: word `i' of `ntfp'
		foreach q of local ques_ntfp_dif {
			capture confirm var `q'__`j'_`i'
			if _rc != 0 {
				dis as error "the variable `q'__`j'_`i' does not exist"
				continue
			}
			
			label var `q'__`j'_`i' "difficulty selling `label': `dif'"
			label var `q'__888_`i' "difficulty selling `label': other"
			label var `q'__`j'_888 "difficulty selling other ntfp: `dif'"
			label var `q'__888_888 "difficulty selling other ntfp: other"
		}
	}	
	}
	
	
	*****************************************************************************************************
	**## Labelling Roster Variables: SOCIAL SECURITY 
	*****************************************************************************************************
	
	local social_code                  1   								2						3									4															5
	local social `" "free ration under Garib Kalyan Yojna" "Women Jan Dhan Benefit" "PM Kisan Sammaan Yojna" "ration/cash (Mid Day Meal) from Schools" "ration/meal (Mid Day Meal) from awc" "'
	local ques_social q701_received_p q701_received_n
	

		
	foreach i of local social_code {
		local label: word `i' of `social'
		foreach q of local ques_social {
			capture confirm var `q'_`i'
			if _rc != 0 {
				dis as error "the variable `q'_`i' does not exist"
				continue
			}
			
			label var `q'_`i' "received ration: `label'"
		}
		forvalues k = 3/21 {
			label var q702_ration_months__`k'_`i' "received ration: `label'"
		}
	}	
	
	
	
	local social_other_code 0 1 2 3 
	local social_other `" "none of the above"  "village community" "NGO" "panchayat" "'
	local ques_social_other q703_ration_other
	
	foreach j of local social_other_code {
		local k = `j'+1
		local where: word `k' of `social_other'
		foreach i of local social_code {
			local label: word `i' of `social'
		foreach q of local ques_social_other {
			capture confirm var `q'__`j'_`i'
			if _rc != 0 {
				dis as error "the variable `q'__`j'_`i' does not exist"
				continue
			}
			
			label var `q'__`j'_`i' "`label' received:`where'"
		}
	}	
	}
	
	*****************************************************************************************************
	**## Labelling Roster Variables: GENDER
	*****************************************************************************************************
	
	local gender_code 1 2 
	local gender     `" "men"  "women" "' 
	local ques_gen q705_empt_nrega q706_empt_chng q707_perc_chng_empt
		
	foreach i of local gender_code {
		local label: word `i' of `gender'
		foreach q of local ques_gen {
			capture confirm var `q'_`i'
			if _rc != 0 {
				dis as error "the variable `q'_`i' does not exist"
				continue
			}
			
			label var `q'_`i' "`q': `label'"
		}
	}	
	
	
	*****************************************************************************************************
	**## Labelling Roster Variables: VACCN
	*****************************************************************************************************
	
	local vaccn_code             1                2						3							4
	local vaccn `" "women aged 18 to 44" "men aged 18 to 44" "people  aged 45 to 59" "people aged 60 and above" "'
	local ques_vaccn q830b_no_vaccn_rsn_oth q829_vaccn_will 
	
	local rsn_code		1 2 3 4 5 6 7 8 9 
	local rsn   `" "fear of vaccn side effects" "lack of trust in COVID vaccine" "lack of trust in any vaccine" "no need for a vaccine" "waiting for more experience with vaccine" "large distance to centre" "fear of infection while travelling/at centre" "fear of infertility" "fear of death due to vaccine" "'
	local ques_rsn  q830_no_vaccn_rsn
	
	
	foreach i of local vaccn_code {
		local label: word `i' of `vaccn'
		foreach q of local ques_vaccn {
			capture confirm var `q'_`i'
			if _rc != 0 {
				dis as error "the variable `q'_`i' does not exist"
				continue
			}
			
			label var `q'_`i' "`q': `label'"
		}
	}	
	
	
	
	foreach j of local rsn_code {
		local why: word `j' of `rsn'
		foreach i of local vaccn_code {
			local label: word `i' of `vaccn'
		foreach q of local ques_rsn {
			capture confirm var `q'__`j'_`i'
			if _rc != 0 {
				dis as error "the variable `q'__`j'_`i' does not exist"
				continue
			}
			
			label var `q'__`j'_`i' " `label' no vaccn: `why'"
			label var `q'__888_`i' " `label' no vaccn: other"
		}
	}	
	}
	
	
	*****************************************************************************************************
	**## Labelling Roster Variables: HEALTH
	*****************************************************************************************************
	
	local health_code 					1							2
	local health      `" "inst child deliveries" "on-time child vaccn" "'

	
	local health_other_code  1					2								3						4						5						6
	local health_other `" "midwives" "older exp female relative" "informal help (ASHA)" "local pvt nurse" "pvt clinic/hosp" "jholachhap doctor" "'
	
	local ques_health q901_perc_chld_inst q902_chng_hlth_serv q903_perc_chng_hlth q904b_del_assist_other q906_chld_vaccn_assist q906b_chld_vaccn_asst_oth
	local ques_health_oth q904_del_assist
	
	
	foreach i of local health_code {
		local label: word `i' of `health'
		foreach q of local ques_health {
			capture confirm var `q'_`i'
			if _rc != 0 {
				dis as error "the variable `q'_`i' does not exist"
				continue
			}
			
			label var `q'_`i' "`q': `label'"
		}
	}	
	
	
	foreach j of local health_other_code {
		local from: word `j' of `health_other'
		foreach i of local health_code {
			local label: word `i' of `health'
		foreach q of local ques_health_oth {
			capture confirm var `q'__`j'_`i'
			if _rc != 0 {
				dis as error "the variable `q'__`j'_`i' does not exist"
				continue
			}
			label var `q'__`j'_`i' "decreased `label' assistance: `from'"
			label var `q'__888_`i' "decreased`label' assistance: other"
		}
	}
	}
	
	label define health 0 "couldn't access healthcare" 1 "public hospital/health care" 2 "pvt hosp/clinic" 3 "jholachhap doctor" 4 "chemist" 5 "treatment by self/relatives/friends" 6 "medication from ANM/ASHA" 888 "other"
 
	label values q908_usual_trtmnt_1 health
	label values q908_usual_trtmnt_2 health
	label values q908_usual_trtmnt_3 health
	
	*****************************************************************************************************
	**## Labelling Roster Variables: DISEASE
	*****************************************************************************************************
	
	local disease_code       1  						2			3			4
	local disease `" "mild/regular illnesses" "chronic illnesses" "cancer" "COVID symptoms" "'
	
	local ques_dis q908_usual_trtmnt q908_trtmnt_now q908b_usual_trtmnt_other q909b_why_no_pub_oth q910A_case_indct q910_trtmnt_now q908b_trtmnt_now_other q911b_reason_other
	
	
	foreach i of local disease_code {
		local label: word `i' of `disease'
		foreach q of local ques_dis {
			capture confirm var `q'_`i'
			if _rc != 0 {
				dis as error "the variable `q'_`i' does not exist"
				continue
			}
			
			label var `q'_`i' "`q': `label'"
		}
	}	
	
	
	local why_code   			1						2							3							4					5								6									7
	local why_dis  `" "distance/transport issues" "absenteeism of doctors" "lack of medical infrastructure" "crowded" "lack of cleanliness/hygiene" "delayed medical attention in emergency" "did not receive proper treatment" "'
	local ques_diswhy q909_why_no_public
	
	foreach j of local why_code {
		local why: word `j' of `why_dis'
		foreach i of local disease_code {
			local label: word `i' of `disease'
		foreach q of local ques_diswhy {
			capture confirm var `q'__`j'_`i'
			if _rc != 0 {
				dis as error "the variable `q'__`j'_`i' does not exist"
				continue
			}
			label var `q'__`j'_`i' "no public hosp `label': `why'"
			label var `q'__888_`i' "no public hosp `label': other"
		}
	}
	}
	
	
	
	local chng_code  1 2 3 4 5 6 7 8 9 10 11 
	local chng  `" "distance/transport issues" "absenteeism of doctors" "lack of medical infrastructure" "crowded" "lack of cleanliness/hygiene" "delayed medical attention in emergency" "did not receive proper treatment" "fear of COVID infection" "denied admission" "fear of getting COVID test done" "fear of getting COVID vaccine" "'
	local ques_chng q911_chng_trtmnt
	
	
		
	foreach j of local chng_code {
		local why: word `j' of `chng'
		foreach i of local disease_code {
			local label: word `i' of `disease'
		foreach q of local ques_chng {
			capture confirm var `q'__`j'_`i'
			if _rc != 0 {
				dis as error "the variable `q'__`j'_`i' does not exist"
				continue
			}
			label var `q'__`j'_`i' "no treatment `label': `why'"
			label var `q'__888_`i' "no treatment `label': other"
		}
	}
	}
	
	
	
	*****************************************************************************************************
	**## Labelling Roster Variables: GATHERING 
	*****************************************************************************************************
	
	
	local gather_code   1						2					3
	local gather `" "religious gathering" "political gathering" "social gathering" "'
	local ques_gather q1001_gather_indct q1002_gather_name q1003_gather_pop q1004_perc_mask_gather q1005_social_dist q1006_gather_place
	
	
		
	foreach i of local gather_code {
		local label: word `i' of `gather'
		foreach q of local ques_gather {
			capture confirm var `q'_`i'
			if _rc != 0 {
				dis as error "the variable `q'_`i' does not exist"
				continue
			}
			
			label var `q'_`i' "`q': `label'"
		}
	}	
	
	
	*****************************************************************************************************
	**## Labelling Roster Variables: WEDDINGS
	*****************************************************************************************************
	
	local wedding_code  			1								2
	local wedding  `" "in one year after April 2020" "in one year before April 2020" "'
	local ques_wed q1007_wedding_total q1008_wedding_girls q1009_wedding_girls_25 q1010_wedding_girls_23 q1011_wedding_girls_20 q1012_wedding_girls_18 q1013_wedding_girls_16 q1014_wedding_girls_16_below weddings_sum_agewise
	
	
	foreach i of local wedding_code {
		local label: word `i' of `wedding'
		foreach q of local ques_wed {
			capture confirm var `q'_`i'
			if _rc != 0 {
				dis as error "the variable `q'_`i' does not exist"
				continue
			}
			
			label var `q'_`i' "`q': `label'"
		}
	}	
	
	
	*****************************************************************************************************
	**## Labelling Roster Variables: CONFLICTS 
	*****************************************************************************************************
	
	local conflict_code 1 2 3 4 5 6 7 8 
	local conflict `" "conflict related to family land/property" "intrahousehold conflict (joint families)" "domestic violence" "alcohol abuse" "conflict related to business/trade" "religion/caste-based conflict" "water shortage conflict" "ntfp collection conflict" "' 
	local ques_conflict conflict_rank
	
	foreach i of local conflict_code {
		local label: word `i' of `conflict'
		foreach q of local ques_conflict {
			capture confirm var `q'_`i'
			if _rc != 0 {
				dis as error "the variable `q'_`i' does not exist"
				continue
			}
			
			label var `q'_`i' "`q': `label'"
		}
	}	
	
	

	
	
	drop is_srijan_village is_srijan_block is_srijan_district sampled_srijan sampled_nonsrijan random //not required
	
	order interview__key interview__id village_id village_name surveyor surveyor_other date_time_start vd_* x_vd_*
	
	save "../03_processed/srijan_workfile", replace

project , creates("../03_processed/srijan_workfile.dta") 
