*generate graphs to show prevalence of workschedule irregularity
*triplot example of composition of usually part-time, usually full-time,
* unemployed/ not in labor force 

use SRmasterv4, clear

*indicator for fulltime and unemployed/out of labor force
gen fulltime = 1 - parttime 
label val fulltime yesno 
gen neither = 1 if parttime==. 

*gen running sum to identify the total amount of people who are fulltime, parttime, neither
bysort statefip: egen totpart = sum(parttime)
by statefip: egen totfull = sum(fulltime)
by statefip: egen totneither = sum(neither) 

*gen proportion of state:
by statefip: egen percpart = max(totpart)
by statefip: egen percfull = max(totfull)
by statefip: egen percneith = max(totneither) 

by statefip: replace percpart = percpart/ _N
by statefip: replace percfull = percfull/ _N
by statefip: replace percneith = percneith/ _N

assert percpart<1
assert percfull<1 
assert percneith<1


*test to see sum of 3 is equal to or close to 1
egen test = rowtotal(percpart percfull percneith) 
assert test==1

triplot percpart percfull percneith, separate(statefip) 

*note, generate one graph per month. see if it shifts significantly.
*If not, this may not be the best graph to show changes in composition of worker status
*over time by state. 


*--- 
*look at changes over time by region:
gen mnthyr=.
forval i = 2014/2015 {
	forval j = 1/12 {
	replace mnthyr = `j' if year==`i' & month==`j'
	}
	}
forval i = 1/12{
	replace mnthyr = `i' + 12 if mnthyr==`i' & year == 2015
}



sort region mnthyr
by region mnthyr: egen meanhrsworkedmy = mean(hrsworkmain) 
by region mnthyr: egen meansdhrsmy = mean(sdhrsmain) 
by region mnthyr: egen meanmeanhrsmy = mean(meanhrsmain) 

preserve
duplicates drop region mnthyr, force
xtset region mnthyr

*look at changes over time of average hours worked by region:
xtline meanhrsworkedmy, overlay
*trends in all regions are much less smooth, however we see a sharp decrease in September 2015 for all regions. 
*find out why. 


*look at changes over time of the average of individuals' standard deviation by region: 
xtline meansdhrsmy, overlay
*overall increase in meansdhrsD until November 2014, where we see a steep drop continuing until
*the lowest point in January 2015, then a steady increase until September 2015 where there is a drop once again. 

*look at changes over time of the regional averages of individual's average hours worked per week: 
xtline meanmeanhrsmy, overlay
*West South Central Division maintains a steady value over time. 

restore

