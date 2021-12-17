

*****************************************************************************************************
	** Instead of 27 variables for srijan current interventions, we create 1 variable (IS THIS USEFUL?)
	*****************************************************************************************************
	
	/*
	foreach var of varlist q305_int_* {
		local labels: variable label `var'
		gen string_`var' = "`labels'" if `var' == 1
		gen `includepos'_`var' = strpos(string_`var',":")
		replace string_`var' = substr(string_`var', `includepos'_`var'+1,.) if `includepos'_`var' > 0
}

	 egen srijan_intervention = concat(string_q305_int_current__101 string_q305_int_current__102  string_q305_int_current__103 string_q305_int_current__104 string_q305_int_current__201  string_q305_int_current__202  string_q305_int_current__203  string_q305_int_current__204 string_q305_int_current__205  string_q305_int_current__206 string_q305_int_current__207 string_q305_int_current__208 string_q305_int_current__209 string_q305_int_current__301 string_q305_int_current__302 string_q305_int_current__303 string_q305_int_current__304 string_q305_int_current__305 string_q305_int_current__306 string_q305_int_current__401 string_q305_int_current__402 string_q305_int_current__403 string_q305_int_current__404 string_q305_int_current__405 string_q305_int_current__406 string_q305_int_current__407 string_q305_int_current__408), punct(" ") 
	 
	replace srijan_intervention = itrim(srijan_intervention)

	drop string_* q305_int_*
	*/
