*generate graphs to show prevalence of workschedule irregularity
*triplot example of composition of usually part-time, usually full-time,
* unemployed/ not in labor force, for each month
*goal: to create a gif to show how composition of each state changes over time. 
use SRmasterv6, clear
gen mnthyr=.
forval i = 2014/2015 {
	forval j = 1/12 {
	replace mnthyr = `j' if year==`i' & month==`j'
	}
	}
forval i = 1/12{
	replace mnthyr = `i' + 12 if mnthyr==`i' & year == 2015
}

*indicator for fulltime and unemployed/out of labor force
gen fulltime = 1 - parttime 
label val fulltime yesno 
gen neither = 1 if parttime==. 

*gen running sum to identify the total amount of people who are fulltime, parttime, neither
bysort statefip mnthyr: egen totalpart = sum(parttime)
by statefip mnthyr: egen totalfull = sum(fulltime)
by statefip mnthyr: egen totalneither = sum(neither) 

*gen proportion of state:
by statefip mnthyr: egen pctpart = max(totalpart)
by statefip mnthyr: egen pctfull = max(totalfull)
by statefip mnthyr: egen pctneith = max(totalneither) 

by statefip mnthyr: replace pctpart = pctpart/ _N
by statefip mnthyr: replace pctfull = pctfull/ _N
by statefip mnthyr: replace pctneith = pctneith/ _N

assert pctpart<1
assert pctfull<1 
assert pctneith<1


*test to see sum of 3 is equal to or close to 1
egen test = rowtotal(pctpart pctfull pctneith) 
assert test==1
*note assertion is false, therefore we will find out why
list statefip mnthyr test if test!=1
*this tells us that Utah, North Carolina, and Montana have a test value of .9999999 which is close to 1, so we can still make the triplot. 




forval i = 1/9 {
	triplot pctpart pctfull pctneith if mnthyr==`i', separate(statefip) legend(off) note(t=`i')
	graph export triplot_00`i'.png
}

forval i = 10/24 {
	triplot pctpart pctfull pctneith if mnthyr==`i', separate(statefip) legend(off) note(t=`i')
	graph export triplot_0`i'.png
}

cd /Users/ChanKLum/Desktop/SummerResearch/
shell "/Users/ChanKLum/Desktop/SummerResearch/ffmpeg" -i `GraphPath'triplot_%03d.png -b:v 512k `GraphPath'triplot.mpg
shell "/Users/ChanKLum/Desktop/SummerResearch/ffmpeg" -r 10 -i `GraphPath'triplot.mpg -t 10 -r 10 `GraphPath'triplot.gif



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

