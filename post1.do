
*select subsample of 2014, 2015; we will use the year, month, and cpsidp for now. 
*load data:
do cps_00004

note: Creation of Variable "Group" to use in longitudinal analysis of the ///
same individuals for t = 8 months. 

decode month, gen(mnth)
label define year 2014 "2014" 2015 "2015"
label val year year
decode year, gen(yr)
gen date = yr + mnth
sort cpsidp year month 

label var date "concatenated year and month"
*note: must set this variable as a date variable for future use to xtset the data


by cpsidp: gen length = _N
keep if length==8
*now our dataset has 8 months of data per individual. 

 
forval i = 1/9 {
	by cpsidp: egen rotate`i' = total(month>=`i') if month < (`i' + 4)
}
*note: based on the condition that individuals fall between month==`i' and month==`i'+4 , 
*inclusive, rotate* will = 8 because there will be 8 of the same cpsidp values that satisfies this. 



*group variable will take on values of 1 through 9, representing which rotational group the 
*individual belongs to. 
gen byte group = .
forval i = 1/9 {
	replace group = `i' if length==8 & rotate`i'==8
}



label var length "Survey months available"

label define rotate 1 "Jan-Apr" 2 "Feb-May" 3 "Mar-Jun" 4 "Apr-Jul" 5 "May-Aug" ///
6 "Jun-Sep" 7 "Jul-Oct" 8 "Aug-Nov" 9 "Sep-Dec" 

forval i = 1/9 {
	label var rotate`i' "Rotation group `i' == 8"
	label val rotate`i' rotate
}

label var group "Group Number"
label val group rotate

datasignature set 

save "/Users/Lum/Desktop/SummerResearch/8surveymonthspp.dta"


