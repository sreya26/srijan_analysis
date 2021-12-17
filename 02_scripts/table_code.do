 
	use "../03_processed/srijan_workfile.dta", clear

	collect clear
	putdocx clear
	putdocx begin 
	
	*************************************************************************************************************************************  
	** Small Program to use the table command more efficiently
	*************************************************************************************************************************************
	
	capture program drop make_table
	program define make_table
		syntax varlist, Title(string) [Type(string)]
		
		if "`type'" != "freq" {
			local tab_opts stat(mean `varlist') stat(sd `varlist') stat(min `varlist') stat(max `varlist') nformat(%5.2f)
			table, `tab_opts'
			collect layout  (var) (result)
			collect style cell (result), halign(center) valign(center)
			collect style putdocx, layout(autofitcontents) title("`title'")
			putdocx collect 
		}
		
		if "`type'" == "freq" {
			local tab_opts stat(fvfrequency `varlist') stat(fvpercent `varlist') nformat(%5.2f)
			table, `tab_opts'
			collect layout (var) (result)
			collect style cell (result), halign(center) valign(center)
			collect style putdocx, layout(autofitcontents) title("`title'")
			putdocx collect 

		}
		
	end
	
	*************************************************************************************************************************************
	**# Surveyed Srijan Districts
	*************************************************************************************************************************************  
	
	make_table vd_district_code, title("Surveyed Districts") type(freq)
 
	*make_table q301_srijan_start, title("SRIJAN Start Year") type(freq)
 	

	*************************************************************************************************************************************
	**# Caste Variables 
	*************************************************************************************************************************************  
	
	make_table x_q104_hh_caste_1_perc x_q108_hh_caste_2_perc x_q113_hh_caste_3_perc, title("Percentage of Households belonging to Major Castes")



	
	make_table x_q103A_caste_cat_corrected x_q107A_caste_cat_corrected x_q111A_caste_cat_corrected, title("Frequency of Major Caste Categories") type(freq)
	

	make_table q103_caste_1, title("First Major Caste") type(freq)
	

	make_table x_q105_first_occupation_caste_1, title("Frequency of First Major Occupation of First Major Castes") type(freq)
	
	
	make_table x_q105_second_occupation_caste_1, title("Frequency of Second Major Occupation of First Major Caste") type(freq)

	*************************************************************************************************************************************  
	**# Popn and Landholding Variables 
	*************************************************************************************************************************************  
	
	
	make_table q101_hh q102_pop x_q114_landless_hh_perc x_q115_marginal_land_hh_perc x_q116_small_land_hh_perc x_q117_medium_land_hh_perc x_q118_large_land_hh_perc, title("Population and Landholding")
	
	
	*************************************************************************************************************************************  
	**# Education Variables 
	*************************************************************************************************************************************
	

	make_table x_class05_1 x_class05_2 x_class08_1  x_class08_2 x_class10_1 x_class10_2 x_class12_1 x_class12_2, title("Educational Attainment") //change labels 
	
	
	collect clear 
	
	table if q126_occ_edu__1 == 1, statistic(fvfrequency q126_occ_edu__1) nformat(%5.2f) name(occp_edu) 
	table if q126_occ_edu__2 == 1, statistic(fvfrequency q126_occ_edu__2) nformat(%5.2f) name(occp_edu) append
	table if q126_occ_edu__3 == 1, statistic(fvfrequency q126_occ_edu__3) nformat(%5.2f) name(occp_edu) append
	table if q126_occ_edu__4 == 1, statistic(fvfrequency q126_occ_edu__4) nformat(%5.2f) name(occp_edu) append
	table if q126_occ_edu__5 == 1, statistic(fvfrequency q126_occ_edu__5) nformat(%5.2f) name(occp_edu) append
	table if q126_occ_edu__6 == 1, statistic(fvfrequency q126_occ_edu__6) nformat(%5.2f) name(occp_edu) append

	collect dims
	collect layout  (var) (result)
	collect style putdocx, layout(autofitcontents) title("Occupation of Educated")
	putdocx collect 


	*************************************************************************************************************************************  
	**# Infrastructure Variables 
	*************************************************************************************************************************************  
	
	make_table scarcity q212_electricity_summer q213_electricity_winter q431_hh_houses q432_hh_pucca_n q429_new_houses q433_hh_iay, ///
	title("Infrastructure: Water Scarcity, Electricity and Houses")
	
	
	gen drinking_water_1 = 0
	
	foreach i of numlist 1/7 {
		replace drinking_water_1 = `i' if q201_drinking_water__`i' == 1
		
	}
	
	label define drink_water 1 "common tap water" 2 "handpumps/tubewells" 3 "ponds" 4 "wells" 5 "Rivers/Streams/Lakes" 6 "pvt tap water" 7 "pvt tap water(govt)" 

	label values drinking_water_1 drink_water
	
	
	
	make_table drinking_water_1, title("First Major Drinking Water Source") type(freq)

	
	make_table q214_alt_water, title("Alternate Water Sources if Scarcity") type(freq)
	

	make_table q222_distance_facility_1 q222_distance_facility_2 q222_distance_facility_3 q222_distance_facility_4 q222_distance_facility_11 q222_distance_facility_18, ///
	title("Infrastructure: Distance to Facilities")

	
	make_table q221_number_facility_5 q221_number_facility_6 q221_number_facility_7 q221_number_facility_8 q221_number_facility_9 q221_number_facility_10 q221_number_facility_12 q221_number_facility_14 q221_number_facility_15 q221_number_facility_16 q221_number_facility_17 q221_number_facility_19, ///
	title("Infrastructure: Number of Facilities in Village")

		
	make_table q222_distance_facility_5 q222_distance_facility_6 q222_distance_facility_7 q222_distance_facility_8 q222_distance_facility_9 q222_distance_facility_10 q222_distance_facility_12 q222_distance_facility_14 q222_distance_facility_15 q222_distance_facility_16 q222_distance_facility_17 q222_distance_facility_19, title("Infrastructure: Distance to Facilities")

	
	

	make_table x_no_transport_months, title("Months where no Transport was Available: March (2020) - September (2021)") type(freq)

	
	*************************************************************************************************************************************  
	**# Migration Variables 
	*************************************************************************************************************************************  
	

	make_table x_q404_perm_migrant_hh_perc x_q405_perm_migrant_perc /*q422_seasonal_migrant_perc*/ x_q423_seasonal_migrant_perc, title("Percentage involved in Perm/Seasonal Migration")
	
	
	
	make_table q404_perm_migrant_hh q405_perm_migrant_pop q411_returned_hh q412_returned_pop q415_residing_hh q416_residing_pop q417_remigrated_hh q418_remigrated_pop q419_migrated_new_hh q420_migrated_new_pop, title("Migration")


	*************************************************************************************************************************************  
	**# Variable to capture extent of reverse migration in villages
	*************************************************************************************************************************************  
	
	
	gen migration = 1 if q404_perm_migrant_hh == q411_returned_hh & q405_perm_migrant_pop == q412_returned_pop & !missing(q404_perm_migrant_hh)
	replace migration = 2 if q404_perm_migrant_hh > q411_returned_hh | q405_perm_migrant_pop > q412_returned_pop & !missing(q404_perm_migrant_hh)
	replace migration = 3 if q404_perm_migrant_hh == 0 
	

	label define mig_lab 1 "complete reverse migration" 2 "partial reverse migration" 3 "no permanent migration"
	label values migration mig_lab
	
	make_table migration, title("Frequency of Migration Types") type(freq)
	
	
	*************************************************************************************************************************************  
	**# Transforming migrant occupation variables for better readability
	*************************************************************************************************************************************  
	
	
	gen returned_occupation_1 = 0
	
	foreach i of numlist 1/13 888 {
		replace returned_occupation_1 = `i' if q413_returned_occ__`i' == 1
	}

	label define mig_occp 1 "did not find work" 2 "did not want to work" 3 "worked on own farm" 4 "worked on fallow land" 5 "agricultural labourer" 6 "non agricultural labourer" 7 "labourer in public services" 8 "MNREGA" 9 "started petty business" 10 "joined family business" 11 "joined pvt service/local job" 12 "collection and sale of NTFP" 13 "animal husbandry, fishery etc" 888 "other"

	label values returned_occupation_1 mig_occp

	
	gen returned_occupation_2 = 0
	
	foreach i of numlist 1/13 888 {
		replace returned_occupation_2 = `i' if q413_returned_occ__`i' == 2
	}
	
	
	label values returned_occupation_2 mig_occp


	make_table returned_occupation_1, title("Main Occupation of Migrants upon Return") type(freq)
	
	make_table returned_occupation_2, title("Second Main Occupation of Migrants upon Return") type(freq)
	
	*************************************************************************************************************************************  
	**# Migrant skills
	*************************************************************************************************************************************  
	
	
	collect clear

	table if q414_mig_skills__0 > 0, statistic(fvfrequency q414_mig_skills__0) nformat(%5.2f) name(migskills) 
	table if q414_mig_skills__4 > 0, statistic(fvfrequency q414_mig_skills__4) nformat(%5.2f) name(migskills) append
	table if q414_mig_skills__7 > 0, statistic(fvfrequency q414_mig_skills__7) nformat(%5.2f) name(migskills) append
	table if q414_mig_skills__8 > 0, statistic(fvfrequency q414_mig_skills__8) nformat(%5.2f) name(migskills) append
	table if q414_mig_skills__10 > 0, statistic(fvfrequency q414_mig_skills__10) nformat(%5.2f) name(migskills) append
	table if q414_mig_skills__11 > 0, statistic(fvfrequency q414_mig_skills__11) nformat(%5.2f) name(migskills) append
	table if q414_mig_skills__888 > 0, statistic(fvfrequency q414_mig_skills__888) nformat(%5.2f) name(migskills) append

	collect layout (var) (result)
	collect style putdocx, layout(autofitcontents) title("Migration Skills")
	putdocx collect 
	
	
	*************************************************************************************************************************************  
	**# Agriculture Variables 
	*************************************************************************************************************************************  
	
	make_table x_q501_agri_hh_perc_1 x_q501_agri_hh_perc_2 x_q502_agri_lab_1_perc x_q502_agri_lab_2_perc, title("Agriculture")
	
	*************************************************************************************************************************************  
	**# NTFP Variables 
	*************************************************************************************************************************************  
	
	egen ntfp_dependence = rowmax(q602_ntfp_list__1 q602_ntfp_list__2 q602_ntfp_list__3 q602_ntfp_list__5 q602_ntfp_list__4 q602_ntfp_list__6 q602_ntfp_list__7 q602_ntfp_list__8 q602_ntfp_list__9 q602_ntfp_list__888)
	replace ntfp_dependence = 1 if ntfp_dependence != .z
	replace ntfp_dependence = 0 if ntfp_dependence == .z

	label define ntfp 0 "not dependent on NTFP" 1 "dependent on NTFP"
	label values ntfp_dependence ntfp 
 
 
	make_table ntfp_dependence, title("NTFP Dependence") type(freq)

	
	gen ntfp_1 = 0
	
	foreach i of numlist 1/9 888 {
		replace ntfp_1 = `i' if q602_ntfp_list__`i' == 1
		
	}
	
	label define ntfp_type 1 "firewood" 2 "saal/siali leaf" 3 "tendu leaf" 4 "mahua" 5 "seasonal fruit" 6 "medicinal herbs and plants" 7 "honey" 8 "chironji" 9 "gond" 888 "other"

	label values ntfp_1 ntfp_type
	
	
	
	make_table ntfp_1, title("First Major NTFP collected by hhs") type(freq)

	*************************************************************************************************************************************  
	**# SOCIAL SECURITY: NREGA
	*************************************************************************************************************************************  
	
	
	make_table q704_empt_nrega_tot q705_empt_nrega_1 q705_empt_nrega_2 q707_perc_chng_empt_1 q707_perc_chng_empt_2, title("Social Security: Employment")


	*************************************************************************************************************************************  
	**# SOCIAL SECURITY: Ration Assitance
	*************************************************************************************************************************************  
	
	

	 
	 make_table x_q701_received_perc_1 x_q701_received_perc_2 x_q701_received_perc_3 x_q701_received_perc_4 x_q701_received_perc_5, title("Ration Assistance")

	 
	 
	 make_table x_q702_months_1 x_q702_months_2 x_q702_months_3 x_q702_months_4 x_q702_months_5, title("Ration Assistance: Number of Months March (2020) - September (2021)")


	*************************************************************************************************************************************  
	**# Covid and Vaaccination
	*************************************************************************************************************************************  
	make_table q804_testing_dist q811_positive q814_died_covid q820_died_any q828_vaccn_dist, title("COVID")
	

    make_table q803_test_location, title("Location of Nearest Covid Testing Centre") type(freq)
 
	make_table q831_men_vaccine_one_n q832_women_vaccine_one_n q837_men_vaccine_both_n q838_women_vaccine_both_n, title("VACCN: Number") /// count?

	make_table q831_men_vaccine_one_p q832_women_vaccine_one_p q837_men_vaccine_both_p q838_women_vaccine_both_p, title("VACCN: Perc") /// count?

	*************************************************************************************************************************************  
	**# HEALTH
	*************************************************************************************************************************************  
	
	make_table q901_perc_chld_inst_1, title("Percentage of Institutional Delivery") type(freq)
	
	
	make_table q916_pads_govt_p q917_pads_mkt_p q912_pads_month_pre_asha q914_pads_month_post_asha, title("HEALTH: Sanitary Napkins") // count?

	
	collect clear
	
	table if q907_asha_add__1 == 1, statistic(fvfrequency q907_asha_add__1) nformat(%5.2f) name(asha) 
	table if q907_asha_add__2 == 1, statistic(fvfrequency q907_asha_add__2) nformat(%5.2f) name(asha) append
	table if q907_asha_add__3 == 1, statistic(fvfrequency q907_asha_add__3) nformat(%5.2f) name(asha) append
	table if q907_asha_add__5 == 1, statistic(fvfrequency q907_asha_add__5) nformat(%5.2f) name(asha) append
	table if q907_asha_add__6 == 1, statistic(fvfrequency q907_asha_add__6) nformat(%5.2f) name(asha) append
	table if q907_asha_add__7 == 1, statistic(fvfrequency q907_asha_add__7) nformat(%5.2f) name(asha) append

	collect layout  (var) (result)
	collect style putdocx, layout(autofitcontents) title("Additional Tasks of ASHA Worker")
	putdocx collect 


	*************************************************************************************************************************************  
	**# WEDDINGS
	*************************************************************************************************************************************  
	
	make_table q1007_wedding_total_1 q1007_wedding_total_2, title("WEDDINGS") // count 

	*************************************************************************************************************************************  
	**# ADDITIONAL STATS
	************************************************************************************************************************************* 
 
	make_table x_vd_sc_pop_perc x_vd_st_pop_perc x_vd_forest_area_perc x_vd_netsown_area_perc, title("VD Variables")
	
	
	*************************************************************************************************************************************  
	**# Primary Fuel Sources
	************************************************************************************************************************************* 
	collect clear
	
	table if q217_fuel__1 > 0, statistic(fvfrequency q217_fuel__1) nformat(%5.2f) name(fuel_sources) 
	table if q217_fuel__2 > 0, statistic(fvfrequency q217_fuel__2) nformat(%5.2f) name(fuel_sources) append
	table if q217_fuel__3 > 0, statistic(fvfrequency q217_fuel__3) nformat(%5.2f) name(fuel_sources) append
	table if q217_fuel__4 > 0, statistic(fvfrequency q217_fuel__4) nformat(%5.2f) name(fuel_sources) append
	table if q217_fuel__5 > 0, statistic(fvfrequency q217_fuel__5) nformat(%5.2f) name(fuel_sources) append
	table if q217_fuel__7 > 0, statistic(fvfrequency q217_fuel__7) nformat(%5.2f) name(fuel_sources) append
	table if q217_fuel__8 > 0, statistic(fvfrequency q217_fuel__8) nformat(%5.2f) name(fuel_sources) append
	*table if q217_fuel__888 > 0, statistic(fvfrequency q217_fuel__888) nformat(%5.2f) name(fuel_sources) append



	collect layout  (var) (result)
	collect style cell (result), halign(center) valign(center)
	collect style putdocx, layout(autofitcontents) title("Source of Cooking Fuel")
	putdocx collect 
	
	*************************************************************************************************************************************  
	**# Lockdown Months and Types of Restrictions
	************************************************************************************************************************************* 
	
	egen lockdown_months = rowtotal(q401_lockdown_months__*) //mean lockdown months is 6, min is 0, max is 11
	
	
	collect clear
	
	table if q403_restr_21__1 > 0, statistic(fvfrequency q403_restr_21__1) nformat(%5.2f) name(mov_rest)
	table if q403_restr_21__2 > 0, statistic(fvfrequency q403_restr_21__2) nformat(%5.2f) name(mov_rest) append
	table if q403_restr_21__3 > 0, statistic(fvfrequency q403_restr_21__3) nformat(%5.2f) name(mov_rest) append
	table if q403_restr_21__4 > 0, statistic(fvfrequency q403_restr_21__4) nformat(%5.2f) name(mov_rest) append
	table if q403_restr_21__5 > 0, statistic(fvfrequency q403_restr_21__5) nformat(%5.2f) name(mov_rest) append
	table if q403_restr_21__6 > 0, statistic(fvfrequency q403_restr_21__6) nformat(%5.2f) name(mov_rest) append
	table if q403_restr_21__888 > 0, statistic(fvfrequency q403_restr_21__888) nformat(%5.2f) name(mov_rest) append

	
	collect layout  (var) (result)
	collect style cell (result), halign(center) valign(center)
	collect style putdocx, layout(autofitcontents) title("Movement Restrictions during Pandemic")
	putdocx collect 

	*************************************************************************************************************************************  
	**# Reasons for Remigration
	************************************************************************************************************************************* 
	
	collect clear 
	
	table if q421_mig_why__1 > 0, statistic(fvfrequency q421_mig_why__1) nformat(%5.2f) name(mig_why)
	
	foreach i of numlist 1/11 888 {
		table if q421_mig_why__`i' > 0, statistic(fvfrequency q421_mig_why__`i') nformat(%5.2f) name(mig_why) append
	}
	
	
	collect layout  (var) (result)
	collect style cell (result), halign(center) valign(center)
	collect style putdocx, layout(autofitcontents) title("Reasons for new migration/remigration")
	putdocx collect 

	*************************************************************************************************************************************  
	**# Agricultural Challenges
	************************************************************************************************************************************* 
	** challenges faced by agri labourers
	
	collect clear
	table if q505_challenge_lab__0 > 0, statistic(fvfrequency q505_challenge_lab__0)  name(agri_chl)
	
	foreach i of numlist 1/5 888 {
		qui count if q505_challenge_lab__`i' > 0 & !missing(q505_challenge_lab__`i')
		if `r(N)' == 0 continue
		table if q505_challenge_lab__`i' > 0, statistic(fvfrequency q505_challenge_lab__`i') name(agri_chl) append
		}
	
	
	collect layout  (var) (result)
	collect style cell (result), halign(center) valign(center)
	collect style putdocx, layout(autofitcontents) title("Challenges faced by Agri Labourers")
	putdocx collect 
	
	** challenges faced by farmers
	
	collect clear 
	table if q506_challenge_farm__0 > 0, statistic(fvfrequency q506_challenge_farm__0) name(farm_chal)
	
	foreach i of numlist 1/10 888 {
		qui count if q506_challenge_farm__`i' > 0 & !missing(q506_challenge_farm__`i')
		if `r(N)' == 0 continue
		table if q506_challenge_farm__`i' > 0, statistic(fvfrequency q506_challenge_farm__`i') name(farm_chal) append
		}
	
	
	collect layout  (var) (result)
	collect style cell (result), halign(center) valign(center)
	collect style putdocx, layout(autofitcontents) title("Challenges faced by Farmers")
	putdocx collect 
	
	
	** irrigation
	
	collect clear
	table if q507_irrigation__1 > 0, statistic(fvfrequency q507_irrigation__1) name(irri_source)
	
	foreach i of numlist 2/6 888{
		qui count if q507_irrigation__`i' > 0 & !missing(q507_irrigation__`i')
		if `r(N)' == 0 continue
		table if q507_irrigation__`i' > 0, statistic(fvfrequency q507_irrigation__`i') name(irri_source) append
	}
	
	collect layout  (var) (result)
	collect style cell (result), halign(center) valign(center)
	collect style putdocx, layout(autofitcontents) title("Sources of Irrigation")
	putdocx collect 
	
	** ground water depletion
	collect clear
	table if q510_gw_issues_new__0 > 0, statistic(fvfrequency q510_gw_issues_new__0) name(gw_issues)
	
	foreach i of numlist 1/7 888 {
		qui count if q510_gw_issues_new__`i' > 0 & !missing(q510_gw_issues_new__`i')
		if `r(N)' == 0 continue
		table if q510_gw_issues_new__`i' > 0, statistic(fvfrequency q510_gw_issues_new__`i') name(gw_issues) append
	}
	
	collect layout  (var) (result)
	collect style cell (result), halign(center) valign(center)
	collect style putdocx, layout(autofitcontents) title("New Problems: Ground Water Depletion")
	putdocx collect 
	
	
	*************************************************************************************************************************************  
	**# NREGA WORK 
	************************************************************************************************************************************* 
 
	collect clear
	table if q708_nrega_type_post__0 > 0, statistic(fvfrequency q708_nrega_type_post__0)  name(nrega_work)
	table if q709_nrega_type_pre__0 > 0, statistic(fvfrequency q709_nrega_type_pre__0)  name(nrega_work) append

	
	foreach i of numlist 1/12 888{
		qui count if q708_nrega_type_post__`i' > 0 & !missing(q708_nrega_type_post__`i')
		if `r(N)' == 0 continue
		qui count if q709_nrega_type_pre__`i' > 0 & !missing(q709_nrega_type_pre__`i')
		if `r(N)' == 0 continue
		table if q708_nrega_type_post__`i' > 0, statistic(fvfrequency q708_nrega_type_post__`i')  name(nrega_work) append
		table if q709_nrega_type_pre__`i' > 0, statistic(fvfrequency q709_nrega_type_pre__`i') name(nrega_work) append
	}
	
	collect layout  (var) (result)
	collect style cell (result), halign(center) valign(center)
	collect style putdocx, layout(autofitcontents) title("Work Done under NREGA")
	putdocx collect 
 
 
	*************************************************************************************************************************************  
	**# Conflicts
	************************************************************************************************************************************* 
 
	collect clear
	table if conflict_rank_1 > 0, statistic(fvfrequency conflict_rank_1) name(conflict)
	table if conflict_rank_2 > 0, statistic(fvfrequency conflict_rank_2) name(conflict) append
	table if conflict_rank_3 > 0, statistic(fvfrequency conflict_rank_3) name(conflict) append
	table if conflict_rank_4 > 0, statistic(fvfrequency conflict_rank_4) name(conflict) append

	
 
	collect layout  (var) (result)
	collect style cell (result), halign(center) valign(center)
	collect style putdocx, layout(autofitcontents) title("Conflicts and their Ranks")
	putdocx collect 
 
 
	*************************************************************************************************************************************  
	**# SRIJAN INTERVENTIONS
	************************************************************************************************************************************* 

	make_table q303_srijan_shg q304_srijan_fpg, title("SRIJAN SHG/FPG")
 
	collect clear
	table if q305_int_current__101 > 0, statistic(fvfrequency q305_int_current__101) name(srijan_int)
 
 
 	
	foreach i of numlist 102/104 201/209 301/306 401/408 {
		qui count if q305_int_current__`i' > 0 & !missing(q305_int_current__`i')
		if `r(N)' == 0 continue
		table if q305_int_current__`i' > 0, statistic(fvfrequency q305_int_current__`i') name(srijan_int) append
	}
	
	collect layout  (var) (result)
	collect style cell (result), halign(center) valign(center)
	collect style putdocx, layout(autofitcontents) title("Srijan Interventions")
	putdocx collect 
 
 
	*************************************************************************************************************************************  
	**# Health
	************************************************************************************************************************************* 
 

	
	collect clear
	table, statistic(fvfrequency q908_usual_trtmnt_1) name(health)
	table, statistic(fvfrequency q908_usual_trtmnt_2) name(health) append
	table, statistic(fvfrequency q908_usual_trtmnt_3) name(health) append

	
	collect layout  (var) (result)
	collect style cell (result), halign(center) valign(center)
	collect style putdocx, layout(autofitcontents) title("Usual Treatment")
	putdocx collect 
 
	
	label values q910_trtmnt_now_1 health
	label values q910_trtmnt_now_2 health
	label values q910_trtmnt_now_3 health


	collect clear
	table, statistic(fvfrequency q910_trtmnt_now_1) name(health_now)
	table, statistic(fvfrequency q910_trtmnt_now_2) name(health_now) append
	table, statistic(fvfrequency q910_trtmnt_now_3) name(health_now) append

	
	collect layout  (var) (result)
	collect style cell (result), halign(center) valign(center)
	collect style putdocx, layout(autofitcontents) title("Treatment Now")
	putdocx collect 
	
	
	make_table q902_chng_hlth_serv_2, title("Change in On-time Vaccn") type(freq)
	make_table q902_chng_hlth_serv_1, title("Change in Institutional Delivery") type(freq)
	
	
	
	
	
	putdocx save report, replace
	
	*************************************************************************************************************************************  
	**# A closer look at the different castes
	************************************************************************************************************************************* 
	/*
	
	use "../03_processed/srijan_workfile.dta", clear
	
	label define missing_caste .a "Not Listed as Major Caste"
	
	levelsof q103_caste_1, local(castes_1)
	levelsof q107_caste_2, local(castes_2)
	levelsof q111_caste_3, local(castes_3)

	local major_castes: list castes_1 | castes_2
	local major_castes: list major_castes | castes_3
	local major_castes: list sort major_castes


	foreach castenum of local major_castes {
		local caste_name: label q103_caste_1 `castenum'
		gen caste_`castenum'_perc = q104_hh_caste_1_perc if q103_caste_1 == `castenum' & !missing(q104_hh_caste_1_perc)
		replace caste_`castenum'_perc = q108_hh_caste_2_perc if q107_caste_2 == `castenum'  & !missing(q108_hh_caste_2_perc)
		replace caste_`castenum'_perc = q113_hh_caste_3_perc if q111_caste_3 == `castenum' & !missing(q113_hh_caste_3_perc)
		replace caste_`castenum'_perc = .a if missing(caste_`castenum'_perc)
		label var caste_`castenum'_perc "Percentage of `caste_name' [CONSTRUCTED]"
		label values caste_`castenum'_perc missing_caste
	}

		format caste_*_perc %5.2f
	
	foreach castenum of local major_castes {
		local caste_name: label q103_caste_1 `castenum'
		gen caste_`castenum'_occp = q105_first_occupation_caste_1 if q103_caste_1 == `castenum' & !missing(q105_first_occupation_caste_1)
		replace caste_`castenum'_occp = q109_first_occupation_caste_2 if q107_caste_2 == `castenum'  & !missing(q109_first_occupation_caste_2)
		replace caste_`castenum'_occp = q113_first_occupation_caste_3 if q111_caste_3 == `castenum' & !missing(q113_first_occupation_caste_3)
		replace caste_`castenum'_occp = .a if missing(caste_`castenum'_perc)
		label var caste_`castenum'_occp "Occupation of `caste_name' [CONSTRUCTED]"
		label values caste_`castenum'_occp caste_occupations
	}

	keep village_name village_id caste_*
	
	keep caste_*_perc
	
	
	foreach v of var caste_*_perc {
	local l`v' : variable label `v'
        if `"`l`v''"' == "" {
 		local l`v' "`v'"
  	}
 }
 
  collapse (count) caste_*
 
   foreach v of var caste_*_perc {
 	label var `v' `"`l`v''"'
  }
  
  
  
  table, stat(mean caste_*)
  
  collect export "table_caste", as(docx) replace
	
*/
	
 