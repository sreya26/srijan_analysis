*************************************************************************************************************************************
*! version 1.0  | 29 July 2021 | Sreya Majumder
*  this file is part of the SRIJAN project headed by Rohini Somanathan, Priyanka Arora and Hemanshu Kumar
*************************************************************************************************************************************  
	
local last_override 48
local override_timedate "15 December 2021 18:12pm"
	
project , uses("../03_processed/srijan_workfile.dta")

	***************************************************************************************************
	**# a tiny program to create the override variable
	***************************************************************************************************
	
	capture program drop error_override
	program define error_override
		syntax [if/], GENerate(name)
		
		confirm new variable `generate'
		
		if "`if'" != "" {
			qui count if (`if')
			local N = r(N)
			if `N' == 0 {
				dis as error "No errors overriden by current condition"
			}
			gen byte `generate' = (`if')
		}
		
		if "`if'" == "" {
			gen byte `generate' = 0
		}
		
		
	end
	
	
	***************************************************************************************************
	* the main code begins here
	***************************************************************************************************

	use "../03_processed/srijan_workfile", clear
	notes
	
	***************************************************************************************************
	**# Section 1
	***************************************************************************************************

	error_override, gen(overd_sec1_01)
	error_override, gen(overd_sec1_02_q103)
	error_override if inlist(village_id, 456755), gen(overd_sec1_02_q107)
	*Reason: Chadar/Bulkar, SC
	
	error_override if village_id == 455636 | village_id == 456149 , gen(overd_sec1_02_q111)
	*Reason: Holds true for this village. Verified with multiple respondents including the village sarpanch.
	
	error_override if inlist(village_id,456149,91343), gen(overd_sec1_02_006)
	*Reason: Holds true for this village. Verified with multiple respondents including the village sarpanch.
	
	error_override if inlist(village_id,502065), gen(overd_sec1_03)
	*Reason: This village has many large farmers. 
	
	error_override if inlist(village_id, 494974,456755), gen(overd_sec1_04)
	*Reason: The landless work as sharecroppers.
	*Reason (456755) : This is correct. Sum is close enough o 120
	
	error_override if inlist(village_id,431303,433654,495187,456735), gen(overd_sec1_06_class05)
	*Reason: Women are indeed more educated than men
	
	error_override if inlist(village_id,431265,431303,431625,433654,495187,502052,456735), gen(overd_sec1_06_class08)
	*Reason: This is indeed true for these areas. Men here start working at an early age and women continue their education. 
	
	error_override if inlist(village_id,502047,501790,431625,433654,495187,501854,501791,456735), gen(overd_sec1_06_class10)
	*Reason: Holds true for this village. Verified
	*Reason (501791) : high school  is far, so there are few educated men, married women are more educated
	
	error_override if inlist(village_id, 431733, 501790, 108768,431625,495187,501854,502290,502061,456735), gen(overd_sec1_06_class12)
	*Reason: Holds true for this village. Verified
	*Reason 108768 : This is indeed true for these areas. Men here start working at an early age and women continue their education.
	
	error_override if inlist(village_id, 502047, 495053, 501790, 108768,433654,456735), gen(overd_sec1_06_graduate)
	*Reason 502047: One graduate woman. No men who have graduated.
	*Reason 495053: Holds true for this village. Verified
	*Reason 108768: This is indeed true for these areas. Men here start working at an early age and women continue their education.
	
	
	error_override, gen(overd_sec1_08_01)
	error_override, gen(overd_sec1_08_02)
	
	***************************************************************************************************
	**# Section 2
	***************************************************************************************************
	
	error_override, gen(overd_sec2_01_1)
	error_override if inlist(village_id,501861,91368,108181,108196,431274,431278,501801,501791,456776,456743,433694,105810), gen(overd_sec2_01_2)
	
	*Reason: Holds true for this village. Verified
	*Reason: There are indeed these many handpumps in the village.
	*Reason (431274): There are indeed these many handpumps in the village. Used as alternatives for wells.
	*Reason (501801,456776,456743,433694,105810): There are indeed more than 25 handpumps in this village. 
	
	error_override, gen(overd_sec2_01_4)
	error_override, gen(overd_sec2_01_5)
	error_override, gen(overd_sec2_01_6)
	error_override, gen(overd_sec2_01_7)
	


	forval i = 1/6 {
		error_override, gen(overd_sec2_02_`i')
	}
	error_override if inlist(village_id,502078,502188), gen(overd_sec2_02_7)
	*Reason: The taps were provided this year before summer. Hence no observation for winter.
	*Reason: Jal Nal Yojna was introduced in this village only this summer. Hence it takes a value zero for last winter season.
	
	
	error_override, gen(overd_sec2_03a_1_summer)
	error_override, gen(overd_sec2_03b_1_summer)
	error_override, gen(overd_sec2_03a_1_winter)
	error_override, gen(overd_sec2_03b_1_winter)
	
	error_override, gen(overd_sec2_03a_2_summer)
	error_override, gen(overd_sec2_03b_2_summer)
	error_override, gen(overd_sec2_03a_2_winter)
	error_override, gen(overd_sec2_03b_2_winter)
	
	error_override if inlist(village_id,501725), gen(overd_sec2_03a_4_summer)
	*Reason: Because none of the wells functions during the summer months
	
	
	error_override, gen(overd_sec2_03b_4_summer)
	error_override, gen(overd_sec2_03a_4_winter)
	error_override, gen(overd_sec2_03b_4_winter)
	
	error_override, gen(overd_sec2_03a_5_summer)
	error_override, gen(overd_sec2_03b_5_summer)
	error_override, gen(overd_sec2_03a_5_winter)
	error_override, gen(overd_sec2_03b_5_winter)
	
	error_override, gen(overd_sec2_03a_6_summer)
	error_override, gen(overd_sec2_03b_6_summer)
	error_override, gen(overd_sec2_03a_6_winter)
	error_override, gen(overd_sec2_03b_6_winter)
	
	error_override, gen(overd_sec2_03a_7_summer)
	error_override, gen(overd_sec2_03b_7_summer)
	error_override, gen(overd_sec2_03a_7_winter)
	error_override, gen(overd_sec2_03b_7_winter)
	
	error_override, gen(overd_sec2_05_1)
	error_override if village_id == 455659, gen(overd_sec2_05_2)
	*Reason: It takes them longer in winter due to cold weather.
	
	error_override, gen(overd_sec2_05_3)
	
	error_override if inlist(village_id,455659,501725), gen(overd_sec2_05_4)
	*Reason: It takes them longer in winter due to cold weather.
	*Reason: Because none of the wells functions during the summer months
	
	error_override, gen(overd_sec2_05_5)
	error_override, gen(overd_sec2_05_6)
	error_override, gen(overd_sec2_05_7)
	
	foreach i of numlist 1/5 7 {
		error_override, gen(overd_sec2_07_`i')		
	}

	error_override if village_id == 431265, gen(overd_sec2_07_6)
	*Reason: The water supply plant is solar powered hence the supply is insufficient during winter.
	
	error_override, gen(overd_sec2_08)
	error_override, gen(overd_sec2_09)
	error_override if inlist(village_id, 460858), gen(overd_sec2_10)
	*Reason: This is indeed true
	
	
	error_override if village_id == 91359, gen(overd_sec2_11)
	*Reason: Primary school is located at the village border and often considered to be a part of the other village
	
	***************************************************************************************************
	**# Section 4
	***************************************************************************************************
	
	
	error_override, gen(overd_sec4_01)
	error_override, gen(overd_sec4_03)
	
	error_override if inlist(village_id, 91359,108090,108094,105842,105822,108149,108172,108181,108196,105832), gen(overd_sec4_04_RJ)
	
	*Reason: Most of the people move out to nearby areas in Rajasthan only. They work in workshops that produce material out of stone and marble. Hence not really seasonal. 
	
	
	error_override if inlist(village_id,431244,431631,433674,431303), gen(overd_sec4_04_CG)
	
	*Reason: They migrate to nearby areas and work as casual labourers. But the work and migration pattern is not seasonal.
	
	error_override if inlist(village_id,501790,501746,484230,460858,460770), gen(overd_sec4_04_MP)
	*Reason 501746: There is no migration at all from here. 
	*Reason 484230, 460858, 460770: People migrate to nearby areas within the state such as Bhopal and Indore 
	
	error_override, gen(overd_sec4_05)
	error_override, gen(overd_sec4_07)
	
	***************************************************************************************************
	**# Section 6
	***************************************************************************************************
	
	
	error_override if inlist(village_id,108094, 108149,108172,108181,108212,495196,460785,460765), gen(overd_sec6_03)
	*Reason: Due to the absence of both, they often sell to intermediaries.
	*Reason: They themselves make bidi out of it. 
	*Reason(460785): They sell bidi's directly 
	
	
	error_override, gen(overd_sec6_04)
	
	***************************************************************************************************
	**# Section 8
	***************************************************************************************************
	
	error_override if inlist(village_id, 460765), gen(overd_sec_8_17_p)
	error_override if inlist(village_id,77018,91359,91354,108094,105810,105842,108212,431274,431625,433654,433681,501801,501746,502190,495450,495196,495189,495185,495183,495041,460765) , gen(overd_sec_8_17_n)

	*Reason: Only some health workers had received both vaccine doses and they are less than 45 yrs old.
	
	error_override if inlist(village_id,502190), gen(overd_m_q826_vaccn_start_18plus)
	


	note: This dataset incorporates error overrides 1-`last_override', as specified till `override_timedate'.
	
	save "../04_temp/errorcheck_workfile_with_overrides", replace
	
project , creates("../04_temp/errorcheck_workfile_with_overrides.dta")	 
	       
	
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	
	

	
	
	
	
	 
	
	
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 
	 

	

	
	

	
	
	
	
	
	
	
	
	
