

	** creating a variable to capture villages exclusively inhabited by Scheduled Tribes 
	** and another for occupation types of main caste

	*** DEMOGRAPHIC TYPES 

	gen exclusive_ST = 1 if q103A_caste_cat_corrected == 1 & missing(q107A_caste_cat_corrected)
	replace exclusive_ST = 1 if q107A_caste_cat_corrected == 1 & q103A_caste_cat_corrected == 1 & missing(q111A_caste_cat_corrected)
	replace exclusive_ST = 1 if q107A_caste_cat_corrected == 1 & q103A_caste_cat_corrected == 1 & q111A_caste_cat_corrected == 1
	replace exclusive_ST = 2 if missing(exclusive_ST)

	local ques 105 109 113 

	forvalues n = 1/3 {
		local q: word `n' of `ques'
		gen q`q'_first_occupation_caste_`n' = 0
		foreach i of numlist 1/15 888 {
			local q: word `n' of `ques'
			replace q`q'_first_occupation_caste_`n' = `i' if q`q'_occ_caste_`n'__`i' == 1
			replace q`q'_first_occupation_caste_`n' = q`q'_occ_caste_`n'__`i' if missing(q`q'_occ_caste_`n'__`i')
			label var q`q'_first_occupation_caste_`n' "First Major Occupation of q`q'_caste_`n' [CONSTRUCTED]"
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
						
	label values q105_first_occupation_caste_1 q109_first_occupation_caste_2 q113_first_occupation_caste_3 caste_occupations

	** no of villages which are exclusively inhabited by STs/mixed village
	tab exclusive_ST

	exclusive_S |
			  T |      Freq.     Percent        Cum.
	------------+-----------------------------------
			  1 |         20       18.02       18.02
			  2 |         91       81.98      100.00
	------------+-----------------------------------
		  Total |        111      100.00

. 
	** additional information on villages exclusively inhabuted by STs
	noi list village_name q103_caste_1 q107_caste_2 q111_caste_3 district_name if exclusive_ST == 1

		 +---------------------------------------------------------------------------+
		 |      village_name   q103_c~1    q107_caste_2    q111_caste_3   district~e |
		 |---------------------------------------------------------------------------|
	 14. |       Thandi Beri     Garasi   valid missing               .         Pali |
	 16. |     Champa Ki Nal       Bhil         Garasia   valid missing      Udaipur |
	 18. |           Akyawar     Garasi   valid missing               .      Udaipur |
	 19. |       Heral Khurd     Garasi   valid missing               .      Udaipur |
	 20. |      Tuli Ka Khet     Garasi   valid missing               .      Udaipur |
		 |---------------------------------------------------------------------------|
	 21. |   Kataro Ki Bhain     Bhil-M   valid missing               .   Pratapgarh |
	 22. | Himoton Ki Harbar      Mina,   valid missing               .   Pratapgarh |
	 23. |           Limbodi      Mina,   valid missing               .   Pratapgarh |
	 24. |               Mau     Bhil-M   valid missing               .   Pratapgarh |
	 26. |           Sandani      Mina,   valid missing               .   Pratapgarh |
		 |---------------------------------------------------------------------------|
	 30. |         Pingthali      Mina,   valid missing               .   Pratapgarh |
	 37. |       Deogarhkhoh      Baiga   valid missing               .       Koriya |
	 38. |         Bodritola       Gond   valid missing               .       Koriya |
	 39. |        Dahiyadand      Kawar   valid missing               .       Koriya |
	 42. |            Kutama      Oraon          Panika   Korwa, Kodaku      Jashpur |
		 |---------------------------------------------------------------------------|
	 50. |          Majhgaon      Oraon   Korwa, Kodaku   valid missing      Jashpur |
	 58. |           Simarra     Sahari   valid missing               .     Shivpuri |
	 78. |     Mehlari Bakol       Gond          Mawasi   valid missing   Chhindwara |
	102. |            Titahi       Gond           Baiga         Agariya      Anuppur |
	109. |        Gutti Para        Kol            Gond          Panika      Anuppur |
		 +---------------------------------------------------------------------------+

	** first major occupation of major castes in exclusive ST villages 
	noi list village_name q105_first_occupation_caste_1 q109_first_occupation_caste_2 q113_first_occupation_caste_3 if exclusive_ST == 1

		 +--------------------------------------------------------------------------------------------------------------------------------+
		 |      village_name        q105_first_occupation_caste_1        q109_first_occupation_caste_2      q113_first_occupation_caste_3 |
		 |--------------------------------------------------------------------------------------------------------------------------------|
	 14. |       Thandi Beri   Casual laborer outside agriculture                        Valid Missing                                  . |
	 16. |     Champa Ki Nal   Casual laborer outside agriculture   Casual laborer outside agriculture                      Valid Missing |
	 18. |           Akyawar                   Farming (own land)                        Valid Missing                                  . |
	 19. |       Heral Khurd   Casual laborer outside agriculture                        Valid Missing                                  . |
	 20. |      Tuli Ka Khet   Casual laborer outside agriculture                        Valid Missing                                  . |
		 |--------------------------------------------------------------------------------------------------------------------------------|
	 21. |   Kataro Ki Bhain                   Farming (own land)                        Valid Missing                                  . |
	 22. | Himoton Ki Harbar                   Farming (own land)                        Valid Missing                                  . |
	 23. |           Limbodi                   Farming (own land)                        Valid Missing                                  . |
	 24. |               Mau                   Farming (own land)                        Valid Missing                                  . |
	 26. |           Sandani   Casual laborer outside agriculture                        Valid Missing                                  . |
		 |--------------------------------------------------------------------------------------------------------------------------------|
	 30. |         Pingthali                   Farming (own land)                        Valid Missing                                  . |
	 37. |       Deogarhkhoh                   Farming (own land)                        Valid Missing                                  . |
	 38. |         Bodritola                   Farming (own land)                        Valid Missing                                  . |
	 39. |        Dahiyadand                   Farming (own land)                        Valid Missing                                  . |
	 42. |            Kutama                   Farming (own land)                   Farming (own land)                 Farming (own land) |
		 |--------------------------------------------------------------------------------------------------------------------------------|
	 50. |          Majhgaon                   Farming (own land)                   Farming (own land)                      Valid Missing |
	 58. |           Simarra                   Farming (own land)                        Valid Missing                                  . |
	 78. |     Mehlari Bakol                   Farming (own land)                   Farming (own land)                      Valid Missing |
	102. |            Titahi                   Farming (own land)                   Farming (own land)   Petty business without employees |
	109. |        Gutti Para                   Farming (own land)                   Farming (own land)                 Farming (own land) |
		 +--------------------------------------------------------------------------------------------------------------------------------+



	** Household size, total popn, perc of landless hhs, perc of large land hhs according to village type
	tabstat q101_hh q102_pop q114_landless_hh_perc q115_marginal_land_hh_perc q116_small_land_hh_perc q117_medium_land_hh_perc q118_large_land_hh_perc, by(exclusive_ST) stat(mean sd min max) 

	Summary statistics: Mean, SD, Min, Max
	Group variable: exclusive_ST 

	exclusive_ST |   q101_hh  q102_pop  q114_l~c  q115_m~c  q116_s~c  q117_m~c  q118_l~c
	-------------+----------------------------------------------------------------------
			   1 |     126.3     631.5  5.038935  52.12958  25.58134  13.96142  3.288725
				 |  117.3026  663.2842     13.89  35.46345  24.86654  19.17378  5.388742
				 |        22       150         0  5.434783         0         0         0
				 |       500      3000        60       100  83.33334  76.08696  14.01869
	-------------+----------------------------------------------------------------------
			   2 |       273  1302.494  10.24204  44.83801  26.56636  13.47449    4.8791
				 |  253.3158  1279.281  14.22045  28.67505  20.59149  13.73297  5.967203
				 |        15        85         0         0         0         0         0
				 |      1200      5990  63.80952       100       100  71.59091  33.33333
	-------------+----------------------------------------------------------------------
		   Total |  245.5794  1177.075    9.2695  46.20092  26.38225   13.5655  4.581834
				 |  240.4777  1214.786  14.24084  30.01168  21.33054  14.79674  5.872151
				 |        15        85         0         0         0         0         0
				 |      1200      5990  63.80952       100       100  76.08696  33.33333
	------------------------------------------------------------------------------------


	 ** % of households engaged in agriculture after April 2020 (1), Before April 2020 (2), according to village type 
	
	 tabstat q501_agri_hh_perc_1 q501_agri_hh_perc_2, by(exclusive_ST) stat(mean sd min max) 
	 
	Summary statistics: Mean, SD, Min, Max
	Group variable: exclusive_ST 

	exclusive_ST |  q501~c_1  q501~c_2
	-------------+--------------------
			   1 |  92.94565  91.19565
				 |  17.08093  20.79138
				 |        40        25
				 |       100       100
	-------------+--------------------
			   2 |  87.50351  86.25599
				 |  16.87064  17.71975
				 |  33.33333  33.33333
				 |       100       100
	-------------+--------------------
		   Total |  88.52073  87.17929
				 |  16.96339  18.32959
				 |  33.33333        25
				 |       100       100
	----------------------------------
	
	** educational attainment according to village type 
	
	tabstat class05_1 class05_2 class08_1 class08_2 class10_1 class10_2 class12_1 class12_2, by (exclusive_ST) stat(mean sd min max)
	
	Summary statistics: Mean, SD, Min, Max
	Group variable: exclusive_ST 

	exclusive_ST |  clas~5_1  clas~5_2  clas~8_1  clas~8_2  clas~0_1  clas~0_2  clas~2_1  clas~2_2
	-------------+--------------------------------------------------------------------------------
			   1 |  36.24509  55.15654  24.06683  35.11719  11.65653  19.75101  4.829064  9.682426
				 |  17.75175  20.81371  15.32198  18.17224  8.415259  14.15553  4.621046  7.672056
				 |  14.16667  26.27118       2.8  8.888889         0         5         0  2.222222
				 |  80.95238  93.33333  52.38095        75  27.38095  58.33333        15  33.33333
	-------------+--------------------------------------------------------------------------------
			   2 |  46.27138  62.49466  29.92983  45.29494  16.13732  28.90843  8.311679  15.57923
				 |  24.15307  25.08533  19.18635  22.49334  13.00299  18.22029  7.742404  11.32274
				 |         0         0         0         0         0         0         0         0
				 |        90  97.77778        75        90        55        84        30        60
	-------------+--------------------------------------------------------------------------------
		   Total |  44.46484  61.17248  28.87343  43.46111  15.32997  27.25845  7.684181  14.51674
				 |  23.38201   24.4482  18.62417  22.05538  12.39197    17.853   7.38526   10.9656
				 |         0         0         0         0         0         0         0         0
				 |        90  97.77778        75        90        55        84        30        60
	----------------------------------------------------------------------------------------------

	* availability of infrastructure according to village type 
	tabstat scarcity q212_electricity_summer q213_electricity_winter q431_hh_houses q804_testing_dist q828_vaccn_dist, by (exclusive_ST) stat(mean sd min max)
	
	Summary statistics: Mean, SD, Min, Max
	Group variable: exclusive_ST 

	exclusive_ST |  scarcity  q212_e~r  q213_e~r  q431_h~s  q804_t~t  q828_v~t
	-------------+------------------------------------------------------------
			   1 |       .85        12     12.75    102.75      12.4       6.4
				 |  .3663475  8.194992  7.711065  95.36571   10.5999   5.62326
				 |         0         0         0        22         2         0
				 |         1        24        24       450        45        20
	-------------+------------------------------------------------------------
			   2 |  .7840909  16.32759  15.86207  220.7586  10.49425  5.747126
				 |  .4138094  6.711595  6.513264  198.2237  8.423215  6.206183
				 |         0         0         0        15         0         0
				 |         1        24        24       800        35        35
	-------------+------------------------------------------------------------
		   Total |  .7962963  15.51869  15.28037  198.7009  10.85047  5.869159
				 |  .4046288  7.173367  6.823647  188.8002  8.846494  6.081342
				 |         0         0         0        15         0         0
				 |         1        24        24       800        45        35
	--------------------------------------------------------------------------

	* migration patterns according to village type 
	tabstat q404_perm_migrant_hh q411_returned_hh q415_residing_hh q417_remigrated_hh q419_migrated_new_hh, by (exclusive_ST) stat(mean sd min max)

	Summary statistics: Mean, SD, Min, Max
	Group variable: exclusive_ST 

	exclusive_ST |  q404_p~h  q411_r~h  q415_r~h  q417_r~h  q419_m~h
	-------------+--------------------------------------------------
			   1 |     27.65     33.75   19.6875   14.0625       1.2
				 |  34.04838  35.24107   29.3092  24.83135  4.467426
				 |         0         1         0         0         0
				 |       120       120       110       100        20
	-------------+--------------------------------------------------
			   2 |  46.71264  42.46429  12.35366  31.14634  2.482759
				 |  88.17028  83.54776  17.18841  77.97897  5.848598
				 |         0         0         0         0         0
				 |       600       550       100       450        40
	-------------+--------------------------------------------------
		   Total |  43.14953     41.07  13.55102  28.35714  2.242991
				 |  81.06017  77.78554  19.67159   72.2035  5.619778
				 |         0         0         0         0         0
				 |       600       550       110       450        40
	----------------------------------------------------------------

	** NREGA patterns according to village type 
	tabstat q704_empt_nrega_tot q707_perc_chng_empt_1 q707_perc_chng_empt_2, by (exclusive_ST) stat(mean sd min max)
	
	Summary statistics: Mean, SD, Min, Max
	Group variable: exclusive_ST 

	exclusive_ST |  q704_e~t  q707_p~1  q707_p~2
	-------------+------------------------------
			   1 |      83.8  22.22222        23
				 |  16.13626  12.77476  18.13529
				 |        50        10         5
				 |       100        50        60
	-------------+------------------------------
			   2 |  65.18391   25.9434  23.74545
				 |  25.04532  18.78462  18.04954
				 |         0         1         3
				 |       100       100       100
	-------------+------------------------------
		   Total |  68.66355  25.40323  23.63077
				 |  24.67293   17.9986   17.9222
				 |         0         1         3
				 |       100       100       100
	--------------------------------------------
	
	** impact of covid according to village type
	tabstat q811_positive q814_died_covid, by (exclusive_ST) stat(mean sd min max count)
	
	exclusive_ST |  q811_p~e  q814_d~d
	-------------+--------------------
			   1 |        .7       .05
				 |  1.592747  .2236068
				 |         0         0
				 |         6         1
				 |        20        20
	-------------+--------------------
			   2 |  2.574713  .1609195
				 |  6.535471  .7132233
				 |         0         0
				 |        55         6
				 |        87        87
	-------------+--------------------
		   Total |  2.224299  .1401869
				 |  5.970538  .6508137
				 |         0         0
				 |        55         6
				 |       107       107
	----------------------------------

	** vaccination takeup according to village type 
	tabstat q831_men_vaccine_one_p q832_women_vaccine_one_p q837_men_vaccine_both_p q838_women_vaccine_both_p, by (exclusive_ST) stat(mean sd min max count)
	
	Summary statistics: Mean, SD, Min, Max, N
	Group variable: exclusive_ST 

	exclusive_ST |  q831_m~p  q832_w~p  q837_m~p  q838_w~p
	-------------+----------------------------------------
			   1 |      73.5     67.75    35.625    34.125
				 |  23.71256  24.05203   28.4652  29.95443
				 |        25        40        10         2
				 |        98        99        90        88
				 |         8         8         8         8
	-------------+----------------------------------------
			   2 |  61.35714  58.89286  28.53571  24.78571
				 |  22.67519  23.51412  25.20506  22.77646
				 |         0         1         0         0
				 |        90        93       100        99
				 |        28        28        28        28
	-------------+----------------------------------------
		   Total |  64.05556  60.86111  30.11111  26.86111
				 |  23.13679  23.58347  25.71134  24.39573
				 |         0         1         0         0
				 |        98        99       100        99
				 |        36        36        36        36
	------------------------------------------------------
	
	
	
	
	tabstat q831_men_vaccine_one_n q832_women_vaccine_one_n q837_men_vaccine_both_n q838_women_vaccine_both_n, by (exclusive_ST) stat(mean sd min max count)
	Summary statistics: Mean, SD, Min, Max, N
	Group variable: exclusive_ST 

	exclusive_ST |  q831_m~n  q832_w~n  q837_m~n  q838_w~n
	-------------+----------------------------------------
			   1 |  26.66667        19         3  3.833333
				 |  27.97835  17.66352  4.824182   4.70654
				 |         1         2         0         0
				 |       105        60        15        12
				 |        12        12        12        12
	-------------+----------------------------------------
			   2 |  115.7797  87.67797  26.15254   21.9661
				 |  235.0207  178.3547  56.85517  44.74216
				 |         2         0         0         0
				 |      1700      1300       400       300
				 |        59        59        59        59
	-------------+----------------------------------------
		   Total |  100.7183  76.07042  22.23944  18.90141
				 |  216.8414  164.5543  52.52033  41.34011
				 |         1         0         0         0
				 |      1700      1300       400       300
				 |        71        71        71        71
	------------------------------------------------------


	*** DRINKING WATER TYPES : Scarcity (1/0)


	gen first_prim_water_source = 0
	forvalues i = 1/7 {
		replace first_prim_water_source = `i' if q201_drinking_water__`i' == 1
	}

		label define water_source 1 "common tap water" 2  "handpumps" 3 "ponds" 4 "wells" 5 "rivers etc" 6 "pvt tap" 7 "govt provided pvt tap" 
		label values first_prim_water_source water_source


	** distance/time taken to procure water from alternative sources in villages which face scarcity of water from primary sources
	tabstat q215_dist_water q216_time_water_alt if scarcity == 1, stat(mean sd min max) 

	   Stats |  q215_d~r  q216_t~t
	---------+--------------------
		Mean |       1.1        43
		  SD |  1.083974  46.04346
		 Min |        .5         0
		 Max |         3       120
	------------------------------



	*** MIGRATION TYPES: 
	gen migration = 1 if q404_perm_migrant_hh == q411_returned_hh & q405_perm_migrant_pop == q412_returned_pop & !missing(q404_perm_migrant_hh)
	replace migration = 2 if q404_perm_migrant_hh > q411_returned_hh | q405_perm_migrant_pop > q412_returned_pop & !missing(q404_perm_migrant_hh)
	replace migration = 3 if q404_perm_migrant_hh == 0 


	label define mig_lab 1 "complete reverse migration" 2 "partial reverse migration" 3 "no permanent migration"
	label values migration mig_lab
	tab migration

					 migration |      Freq.     Percent        Cum.
	---------------------------+-----------------------------------
	complete reverse migration |         66       61.11       61.11
	 partial reverse migration |         35       32.41       93.52
		no permanent migration |          7        6.48      100.00
	---------------------------+-----------------------------------
						 Total |        108      100.00


	** remigration patterns according to migration type 
	tabstat q415_residing_hh q416_residing_pop q417_remigrated_hh q418_remigrated_pop q419_migrated_new_hh q420_migrated_new_pop, by(migration) stat(mean sd min max) 

	Summary statistics: Mean, SD, Min, Max
	Group variable: migration 

	migration |  q415_r~h  q416_r~p  q417_r~h  q418_r~p  q419_m~h  q420_m~p
	----------+------------------------------------------------------------
			1 |  13.93939  18.98485  20.59091  28.71212  2.045455  2.727273
			  |  19.22489    29.053  55.08678  71.07001  5.858411  7.494707
			  |         0         0         0         0         0         0
			  |       110       180       300       400        40        50
	----------+------------------------------------------------------------
			2 |     12.75   17.3125    44.375  60.53125  3.088235  4.411765
			  |  20.85433  25.52853  97.75834  121.4209  5.653466  10.11485
			  |         0         0         0         0         0         0
			  |       100       100       450       455        20        50
	----------+------------------------------------------------------------
			3 |         .         .         .         .         0         0
			  |         .         .         .         .         0         0
			  |         .         .         .         .         0         0
			  |         .         .         .         .         0         0
	----------+------------------------------------------------------------
		Total |  13.55102  18.43878  28.35714  39.10204  2.242991  3.084112
			  |  19.67159  27.83014   72.2035   91.2211  5.619778  8.219996
			  |         0         0         0         0         0         0
			  |       110       180       450       455        40        50
	-----------------------------------------------------------------------

	*** NTFP Reliance:
	
	gen ntfp_reliance = 0 if q601_terrain__3 == 0
	replace ntfp_reliance = 1 if q601_terrain__3 != 0 & !missing(q601_terrain__3)
	label define ntfp 0 "no reliance on NTFP(no forest)" 1 "reliance on NTFP"
	label values ntfp_reliance ntfp

	tab ntfp_reliance

					 ntfp_reliance |      Freq.     Percent        Cum.
	-------------------------------+-----------------------------------
	no reliance on NTFP(no forest) |         33       30.84       30.84
				  reliance on NTFP |         74       69.16      100.00
	-------------------------------+-----------------------------------
							 Total |        107      100.00


	gen ntfp_1 = 0
	gen ntfp_2 = 0
	gen ntfp_3 = 0

	foreach i of numlist 1/9 888 {
			replace ntfp_1 = `i' if q602_ntfp_list__`i' == 1
			replace ntfp_2 = `i' if q602_ntfp_list__`i' == 2
			replace ntfp_3 = `i' if q602_ntfp_list__`i' == 3
		}

	label define ntfp_lab 1 "firewood" 2 "saal/siali leaf" 3 "tendu leaf" 4 "mahua" 5 "seasonal fruit" 6 "medicinal herbs and plants" 7 "honey" 8 "chironji" 9 "gond" 888 "other"
	label values ntfp_1 ntfp_2 ntfp_3 ntfp_lab


	gen drinking_water_1 = 0

	foreach i of numlist 1/7 {
			replace drinking_water_1 = `i' if q201_drinking_water__`i' == 1
			
		}

	label define drink_lab 1 "common taps" 2  "handpumps" 3 "ponds" 4 "wells" 5 "rivers etc" 6 "pvt tap" 7 "govt provided pvt tap"
	label values drinking_water_1 drink_lab


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

