project , uses("../03_processed/srijan_workfile.dta") 
project , original("../02_scripts/05aa_latex_codebook.do")

	use "../03_processed/srijan_workfile.dta", clear
	run "../02_scripts/05aa_latex_codebook.do"

	capture drop __000000 
	
	*****************************************************************************************************
	**# Section 00: Codebook Layout 
	*****************************************************************************************************
	/*
	drop if surveyor == .a
	
	ds, has(type string) 
	local stringvars `r(varlist)'
	
	foreach var of local stringvars {
		replace `var' = "\#\#N/A\#\#" if `var' == "##N/A##"
	}
	
	*/
	
	
	#delimit ;
	
	local survey_sections vd id si ri sec1 sec2 sec3 sec4 sec5 sec6 sec7 cm asi ari sec8 sec9 sec10 acm ;
	
	
	local survey_sec1_roster edu ;
	local survey_sec2_roster water fuel fac houses ;
	local survey_sec5_roster time ;
	local survey_sec6_roster ntfp ;
	local survey_sec7_roster social gender ;

	
	local survey_sec8_roster vaccn ;
	local survey_sec9_roster health dis ;
	local survey_sec10_roster gath wed conf ;
	
	
	local survey_vd_title "[VD] Village Directory"	;
	local survey_id_title "[ID] Identifiers"	;
	local survey_si_title "[SI] Surveyor Information"	;
	local survey_ri_title "[RI] Respondent Information"	;
	local survey_sec1_title "[1] Village Demography"	;
	local survey_sec2_title "[2] Infrastructure"	;
	local survey_sec3_title "[3]Srijan Activity"	;
	local survey_sec4_title "[4] Migration"	;
	local survey_sec5_title "[5] Agriculture"	;
	local survey_sec6_title "[6] Forest Resources"	;
	local survey_sec7_title "[7] Public Policy"	;
	local survey_sec8_title "[8] Covid"	;
	local survey_sec9_title "[9] Health"	;
	local survey_sec10_title "[10] Conflicts and Social Issues"	;
	local survey_cm_title "[CM] Comments" ;
	

	local survey_asi_title "[ASI] ASHA Surveyor Information"	;
	local survey_ari_title "[ARI] ASHA Respondent Information"	;
	local survey_sec8_title "[8] Covid"	;
	local survey_sec9_title "[9] Health"	;
	local survey_sec10_title "[10] Conflicts and Social Issues"	;
	local survey_acm_title "[ACM] Comments" ;
	
	
	local survey_sec1_roster_edu_title "[EDU] Education Roster" ;
	local survey_sec2_roster_water_title "[DW] Drinking Water Roster" ;
	local survey_sec2_roster_fuel_title "[FUEL] Fuel Sources Roster" ;
	local survey_sec2_roster_fac_title "[FAC] Facilities Roster" ;
	local survey_sec2_roster_houses_title "[HS] Houses Roster" ;
	local survey_sec5_roster_time_title "[TL] Timeline Roster" ;
	local survey_sec6_roster_ntfp_title "[NTFP] NTFP Roster" ;
	local survey_sec7_roster_social_title "[SS] Social Security Roster" ;
	local survey_sec7_roster_gender_title "[GEN] Gender Roster" ;
	
	
	local survey_sec8_roster_vaccn_title "[VACN] Vaccine Awareness Roster" ;
	local survey_sec9_roster_health_title "[HLTH] Health Roster" ;
	local survey_sec9_roster_dis_title "[DIS] Disease Roster" ;
	local survey_sec10_roster_gath_title "[GAT] Gatherings Roster" ;
	local survey_sec10_roster_wed_title "[WED] Weddings Roster" ;
	local survey_sec10_roster_conf_title "[CON] Conflicts Roster" ;
	


	
	local survey_vd_vars
	vd_*
	x_vd_*
	;
	
	
	
	local survey_id_vars
	village_id 
	village_name 
	;
	
	
	local survey_si_vars
	interview__key 
	interview__id
	surveyor 
	surveyor_other
	date_time_start
	;
	
	
	local survey_ri_vars
	q001_resp_name
	q002_resp_age
	q003_resp_gender
	q004_resp_edu
	q005_resp_des
	q005b_resp_des_other
	q006_resp_caste
	q006b_resp_caste_other
	q006A_resp_cat
	q007_resp_land
	;
	
	local survey_sec1_vars
	q101_hh
	q102_pop
	x_female_frac_of_adults
	q000a_unit
	q103_caste_1 
	q103b_caste_1_other 
	q103A_caste_cat
	q104_*
	x_q104_*
	x_q105_*
	q105b_occ_caste_1_other
	q106_caste_2_indct
	q107_caste_2 
	q107b_caste_2_other 
	q107A_caste_cat 
	q108_* 
	x_q108_*
	x_q109_*
	q109b_occ_caste_2_other 
	q110_caste_3_indct 
	q111_* 
	x_q111_*
	q111A_*
	x_q111A_*
	x_q113_*
	q113b_occ_caste_3_other 
	x_caste_*_perc
	x_caste_*_occp
	q000b_unit 
	q114_* 
	x_q114_*
	q115_* 
	x_q115_*
	q116_*
	x_q116_*
	q117_*
	x_q117_*
	q118_*
	x_q118_*
	sum_land_*
	x_q126_*
	q000c_unit
	;
	
	
	local survey_sec1_roster_edu_vars
	q119_*
	q125_*
	x_q125_*
	q124_* 
	x_q124_*
	q123_*
	x_q123_*
	q122_* 
	x_q122_*
	q121_* 
	x_q121_*
	q120_*
	x_q120_*
	sum_edu_* 
	x_class12_*
	x_class10_*
	x_class08_*
	x_class05_*
	;
	
	
	local survey_sec2_vars
	q201_*
	q000d_unit 
	q212_electricity_summer 
	q213_electricity_winter 
	q217_*
	q000e_unit 
	q431_*
	q432_*
	q429_*
	q433_*
	scarcity 
	x_new_scarcity 
	x_summer_scarcity
	x_winter_scarcity
	q214_alt_water 
	q214b_alt_water_other 
	q215_dist_water 
	q216_time_water_alt
	q219_*
	x_q219_*
	q220_*
	x_q220_*
	total_houses
	;
	
	
	local survey_sec2_roster_water_vars
	q202_*
	q203_* 
	q204_* 
	q205_*
	q206_* 
	q207_* 
	q208_*
	q209_* 
	q210_* 
	q211_* 
	;
	
	local survey_sec2_roster_fuel_vars
	q218_*
	x_q218_*
	;
	
	
	local survey_sec2_roster_fac_vars
	q221_*
	q222_*
	;
	
	local survey_sec2_roster_houses_vars
	q430_*
	;

	
	local survey_sec3_vars
	q301_srijan_start 
	q302_srijan_end 
	q303_srijan_shg 
	q304_srijan_fpg 
	q305_*
	int_current_detail_indct 
	q305A_int_curr_des__0 
	q305A_int_curr_des__1 
	q306_*
	int_past_detail_indct 
	q306A_* 
	;
	
	local survey_sec4_vars
	q401_*
	q402_*
	q403_*
	q402b_restr_21_other
	q404_perm_migrant_hh
	x_q404_*
	q405_perm_migrant_pop 
	x_q405_*
	q406_* 
	q407_dest_2_indct 
	q408_* 
	q409_dest_3_indct 
	q410_*
	q411_returned_hh
	x_q411_*
	q412_returned_pop 
	x_q412_*
	q413_* 
	q413b_returned_occ_other 
	q414_*
	q414b_mig_skills_other 
	q415_residing_hh
	x_q415_*
	q416_residing_pop 
	x_q416_*
	q417_remigrated_hh
	x_q417_*
	q418_remigrated_pop 
	x_q418_*
	q419_migrated_new_hh
	q420_migrated_new_pop 
	q421_*
	q421b_mig_why_other
	q422_seasonal_migrant_hh
	q423_seasonal_migrant_pop 
	x_q423_*
	x_migrant_*
	q424_*
	q425_ss_dest_2_indct 
	q426_* 
	q427_ss_dest_3_indct 
	q428_*
	;
	
	
	local survey_sec5_vars
	q000f_unit
	q505_* 
	q505b_challenge_other 
	q506_* 
	q506b_challenge_other 
	q507_*
	x_no_transport_*
	q507b_irrigation_other 
	q508_gw_change 
	q509_* 
	q509_gw_reason_other 
	q510_*
	q510b_gw_issues_new_other
	;
	
	local survey_sec5_roster_time_vars
	q501_*
	x_q501_*
	q502_*
	x_q502_*
	q503_*
	q504_*
	;
	
	

	local survey_sec6_vars
	q601_*
	q601b_terrain_oth
	q602_*
	q602b_ntfp_other
	q000g_unit
	;
	
	
	local survey_sec6_roster_ntfp_vars
	NTFP_name_* 
	q603_* 
	q604_*
	x_q604_*
	q603A_* 
	q604A_*
	q605_* 
	q605b_ntfp_sale_other_1 
	q606_* 
	q606b_ntfp_diff_other_1 
	q607_low_price_why_1 
	q607b_low_price_other_1 
	;
	
	local survey_sec7_vars
	q000h_unit
	surveyor_2
	surveyor_other_2
	q001_resp_name_rs
	q002_resp_age_rs
	q004_resp_edu_rs
	q006_resp_caste_rs
	q006b_resp_caste_other_rs
	q007_resp_land_rs
	q704_empt_nrega_tot
	q708_*
	q708b_nrega_post_other
	q709_*
	q709b_nrega_pre_other
	;
	
	local survey_sec7_roster_social_vars
	q701_*
	x_q701_*
	q702_* 
	x_q702_*
	q703_*
	;
	
	
	local survey_sec7_roster_gender_vars
	q705_*
	q706_*
	q707_*
	;
	
	local survey_cm_vars
	q001_outcome
	q002_incomplete_reason
	q003_any_comment_indct
	q004_any_comment
	date_time_end
	;
	
	
	
	local survey_asi_vars
	surveyor_3
	surveyor_other_3
	date_time_start_2
	;
	
	local survey_ari_vars
	q001_resp_name_asha 
	q002_resp_age_asha 
	q004_resp_edu_asha 
	q005_resp_desig_asha
	q006_resp_desig_asha_other
	q006_resp_caste_asha
	q006b_resp_caste_other_asha 
	q006A_resp_asha_cat 
	q007_resp_land_asha
	;
	
	local survey_sec8_vars
	q801_masks_*
	q802_mask_*
	q803_test_*
	q803b_test_*
	q804_testing_*
	q805_type_*
	q806_tests_*
	q807_time_*
	q808_time_*
	q000i_unit
	q809_men_*
	x_q809_*
	q810_women_*
	x_q810_*
	q811_positive
	x_q811_*
	q812_men_*
	q813_women_*
	positive_sum_gender
	q814_died_*
	q815_men_*
	q816_women_*
	died_covid_sum_gender
	q817_blw18_*
	q818_18to44_*
	q819_abv44_*
	died_covid_sum_agewise
	q820_died_*
	q821_men_*
	q822_women_*
	died_any_sum_genderwise
	q823_blw18_*
	q824_18to44_*
	q825_above44_*
	q825_above44_*
	died_any_sum_agewise
	q826_vaccn_*
	q827_vaccn_*
	q828_vaccn_*
	q828_vaccn_dist
	q000j_unit
	q831_men_*
	x_q831_*
	q832_women_*
	x_q832_*
	total_vaccine_one
	q835_18to44_*
	q836_above44_*
	vaccine_one_agewise_sum
	q837_men_*
	x_q837_*
	q838_women_*
	x_q838_*
	total_vaccine_both
	q839_18to44_*
	q840_above44_*
	vaccine_both_sum_agewise
	;
	
	local survey_sec8_roster_vaccn_vars
	q829_vaccn_*
	q830_no_*
	q830b_no_*
	;
	
	local survey_sec9_vars
	q907_asha_*
	q907b_asha_*
	q912_pads_*
	q914_pads_*
	q913_pads_*
	q913b_pads_*
	q915_pads_*
	q916_pads_*
	q917_pads_*
	;
	
	
	local survey_sec9_roster_health_vars
	q901_perc_*
	q902_chng_*
	q903_perc_*
	q904_del_*
	q904b_del_*
	q906_chld_*
	q906b_chld_*
	;
	
	local survey_sec9_roster_dis_vars
	q908_usual_*
	q908b_usual_*
	q909_why_*
	q909b_why_*
	q910A_case_*
	q910_trtmnt_*
	q908b_trtmnt_*
	q911_chng_*
	q911b_reason_*
	;
	
	local survey_sec10_vars
	q1003_conflicts_*
	;
	
	local survey_sec10_roster_gath_vars
	q1001_gather_*
	q1002_gather_*
	q1003_gather_*
	q1004_perc_*
	q1005_social_*
	q1006_gather_*
	;
	
	local survey_sec10_roster_wed_vars
	q1007_wedding_*
	q1008_wedding_*
	q1009_wedding_*
	q1010_wedding_*
	q1011_wedding_*
	q1012_wedding_*
	q1013_wedding_*
	q1014_wedding_*
	weddings_sum_agewise_*
	;
	
	local survey_sec10_roster_conf_vars
	conflict_rank_*
	;
	
	local survey_acm_vars
	q001_outcome_2 
	q002_incomplete_reason_2 
	q003_any_comment_indct_2 
	q004_any_comment_2 
	date_time_end_2 
	sssys_irnd_asha 
	has__errors_asha 
	interview__status_asha 
	assignment__id_asha
	;
	
	
	#delimit cr
	*****************************************************************************************************
	**# Section 1: Modifying variables and labels  
	*****************************************************************************************************
	
	
	*****************************************************************************************************
	** Instead of 6 variables for occupation of educated we generate one variable containing this information 
	*****************************************************************************************************
	
	local edus  `" "school" "anganwadi" "ASHA" "panchayat-sec" "rozgar-sahayak" "kisan-mitr" "'
	local ques_oc q126_occ_edu
	
	forvalues i = 1/6 {
		local occp: word `i' of `edus'
		tostring q126_occ_edu__`i' , replace 
		replace q126_occ_edu__`i' = "`occp'" if  q126_occ_edu__`i' == "1"
		replace q126_occ_edu__`i' = " " if  q126_occ_edu__`i' == "0"
	}
	
	egen x_q126_occ_edu = concat(q126_occ_edu__1 q126_occ_edu__2 q126_occ_edu__3 q126_occ_edu__4 q126_occ_edu__5 q126_occ_edu__6), punct(" ") 
	 
	replace x_q126_occ_edu = itrim(x_q126_occ_edu)
	replace x_q126_occ_edu = "none of these" if x_q126_occ_edu == ""
	replace x_q126_occ_edu = "." if x_q126_occ_edu == ". . . . . ."
	label var x_q126_occ_edu "Occuption of Educated"
	 
	 
	*****************************************************************************************************
	**# Section 2: Creating popn perc variables for each major caste 
	*****************************************************************************************************
	
	label define missing_caste .a "Not Listed as Major Caste"
	
	levelsof q103_caste_1, local(castes_1)
	levelsof q107_caste_2, local(castes_2)
	levelsof q111_caste_3, local(castes_3)

	local major_castes: list castes_1 | castes_2
	local major_castes: list major_castes | castes_3
	local major_castes: list sort major_castes


	foreach castenum of local major_castes {
		local caste_name: label q103_caste_1 `castenum'
		gen x_caste_`castenum'_perc = x_q104_hh_caste_1_perc if q103_caste_1 == `castenum' & !missing(x_q104_hh_caste_1_perc)
		replace x_caste_`castenum'_perc = x_q108_hh_caste_2_perc if q107_caste_2 == `castenum'  & !missing(x_q108_hh_caste_2_perc)
		replace x_caste_`castenum'_perc = x_q113_hh_caste_3_perc if q111_caste_3 == `castenum' & !missing(x_q113_hh_caste_3_perc)
		replace x_caste_`castenum'_perc = .a if missing(x_caste_`castenum'_perc)
		label var x_caste_`castenum'_perc "Percentage of `caste_name'"
		label values x_caste_`castenum'_perc missing_caste
	}

		format x_caste_*_perc %5.2f
	
	foreach castenum of local major_castes {
		local caste_name: label q103_caste_1 `castenum'
		gen x_caste_`castenum'_occp = x_q105_first_occupation_caste_1 if q103_caste_1 == `castenum' & !missing(x_q105_first_occupation_caste_1)
		replace x_caste_`castenum'_occp = x_q109_first_occupation_caste_2 if q107_caste_2 == `castenum'  & !missing(x_q109_first_occupation_caste_2)
		replace x_caste_`castenum'_occp = x_q113_first_occupation_caste_3 if q111_caste_3 == `castenum' & !missing(x_q113_first_occupation_caste_3)
		replace x_caste_`castenum'_occp = .a if missing(x_caste_`castenum'_perc)
		label var x_caste_`castenum'_occp "Occupation of `caste_name'"
		label values x_caste_`castenum'_occp caste_occupations
	}


	*****************************************************************************************************
	**# Section 3: Dropping variables we dont need/reconstructed
	*****************************************************************************************************

	drop _m_* q105_occ_* q109_occ_* q113_occ_* q126_occ_edu__*
	
	*****************************************************************************************************
	**# Section 4 : Create Codebook
	*****************************************************************************************************

	capture erase "../06_outputs/codebook_srijan_data.tex"
	
	foreach sec of local survey_sections {
		local title `survey_`sec'_title'
		file open texfile using "../06_outputs/codebook_srijan_data.tex", write text append
		file write texfile _n "\section*{`title'}"
		file write texfile _n "\addcontentsline{toc}{section}{`title'}" _n(2)
		file close texfile
		unab unab_`sec'_var : `survey_`sec'_vars'
		local numvars: list sizeof unab_`sec'_var
		forval i = 1/`numvars' {
			local vars: word `i' of `unab_`sec'_var'
			foreach var of varlist `vars' {
				noi dis "Adding variable `var' to codebook..."
				qui latex_codebook `var' using "../06_outputs/codebook_srijan_data.tex" , append tabmiss
		}
		}
		foreach roster of local survey_`sec'_roster {
			local title `survey_`sec'_roster_`roster'_title'
			file open texfile using "../06_outputs/codebook_srijan_data.tex", write text append
			file write texfile _n "\subsection*{`title'}"
			file write texfile _n "\addcontentsline{toc}{subsection}{`title'}" _n(2)
			file close texfile
			unab unab_`roster'_var : `survey_`sec'_roster_`roster'_vars'
			local numvars: list sizeof unab_`roster'_var
			forval i = 1/`numvars' {
				local vars: word `i' of `unab_`roster'_var'
				foreach var of varlist `vars' {
					noi dis "Adding variable `var' to codebook..."
					qui latex_codebook `var' using "../06_outputs/codebook_srijan_data.tex" , append tabmiss
				}
			}
		}
	}	

project , creates("../06_outputs/codebook_srijan_data.tex")
