
*select subsample of 2014, 2015; we will use the year, month, and cpsidp for now. 
*load data:
do cps_00004

note: Creation of Variable "Group" to use in longitudinal analysis of the ///
same individuals for t = 8 months. 

sort cpsidp year month


by cpsidp: gen length = _N
keep if length==8
*now our dataset has 8 months of data per individual. 


by cpsidp: gen seqdate = _n
*note:to set this variable as a date variable for future use to xtset the data in order to set the time units as monthly:
xtset cpsidp seqdate
/*note cpsidp denotes individual identifier. If the analysis we use later on needs the panel to consist of households 
or states or something else, then we have to xtset cpsid seqdate or xtset statefips seqdate, where cpsid is the household
id variable and statefips is the state variable. */
 
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


label define rotate1 8 "Jan-Apr" 
label define rotate2 8 "Feb-May" 
label define rotate3 8 "Mar-Jun" 
label define rotate4 8 "Apr-Jul" 
label define rotate5 8 "May-Aug"
label define rotate6 8 "Jun-Sep" 
label define rotate7 8 "Jul-Oct" 
label define rotate8 8 "Aug-Nov" 
label define rotate9 8 "Sep-Dec" 


forval i = 1/9 {
	replace rotate`i' = . if rotate`i'!=8 
	label var rotate`i' "Rotation group `i' == 8"
	label val rotate`i' rotate`i'
}


label var group "Group Number"
label define rgroup 1 "Jan-Apr" 2 "Feb-May" 3 "Mar-Jun" 4 "Apr-Jul" /// 
5 "May-Aug" 6 "Jun-Sep" 7 "Jul-Oct" 8 "Aug-Nov" 9 "Sep-Dec" 
label val group rgroup

datasignature set 

save "/Users/Lum/Desktop/SummerResearch/8surveymonthspp.dta"


