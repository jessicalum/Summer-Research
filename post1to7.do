/*
1. download the subsample 2014-2015 of the CPS. Variables needed are the preselected ones, 
ahrsworkt ahrswork1 ahrswork2 uhrsworkt uhrswork1 uhrswork2 wkstat, multjob, numjob, statefip, region.

2. Set the working directory, import the data into Stata.

3. //www.nws.noaa.gov/geodata/catalog/national/html/us_state.htm
under "Available Version(s), click on "Download Compressed Shapefile s_11au16.zip"
place the file in your working directory where all your Summer Research data is. 
unzip the file. 


4. install the needed ado-files:
ssc install tsspell
ssc install triplot
ssc install spmap
ssc install shp2dta
ssc install mif2dta


5. make files in Stata format: a database file, usdb.dta, and a coordinates file, uscoord.dta:
 shp2dta using s_11au16, database(usdb) coordinates(uscoord) genid(id)

6. change the file path in this do-file to your file path 

7. download ffmpeg to make gifs: https://ffmpeg.org/
Now you are ready to execute this do-file and you will be all caught up as of 08/20/2016
*/

*POST1
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


*POST2
gen byte underemployed = inlist(wkstat, 14, 20, 22)
replace underemployed = . if wkstat >=50
*if underemployed = 0, then we assume individuals are satisfied with the amount of work they have. 
label var underemployed "underemployed for economic reasons?"
label define yesno 0 "no" 1 "yes" 
label val underemployed yesno 

*---

gen byte hvaryall = inlist(uhrsworkt, 997) if !missing(uhrsworkt)
gen byte hvarymain = inlist(uhrswork1, 997) if !missing(uhrswork1)
gen byte hvaryother = inlist(uhrswork2, 997) if !missing(uhrswork2)
label var hvaryall "hours p/w usually vary, all jobs"
label var hvarymain "hours p/w usually vary, main job"
label var hvaryother "hours p/w usually vary, other job(s)"
label val hvaryall yesno
label val hvarymain yesno
label val hvaryother yesno
/*
hours usually worked at all jobs: UHRSWORKT == 997 Hours vary
hours usually worked per week at main job UHRSWORK1 == 997 Hours vary
hours usually worked per week, other job(s) 997 hours vary UHRSWORK2
*/

*---

/*create a categorical variable: = 0 if underemployed, = 1 if reports having 
hours that vary, = 2 if both */
gen byte jobquality = 0 if underemployed==1 & hvarymain==0
replace jobquality = 1 if hvarymain==1 & underemployed==0
replace jobquality = 2 if underemployed==1 & hvarymain==1 
label var jobquality "job quality"
label define jobquality 0 "underemployed" 1 "hours vary, main job" 2 "both" 
label val jobquality jobquality 

*---

/*
note to self:
find out why NIU: look at previous question in questionnaire
 UHRSWORKT		Hours usually worked per week at all jobs
997		Hours vary
999		NIU
 UHRSWORK1		Hours usually worked per week at main job
000		0 hours
997		Hours vary
999		NIU/Missing
 UHRSWORK2		Hours usually worked per week, other job(s)
997		Hours vary
998		Missing
999		NIU
 AHRSWORK1		Hours worked last week, main job
999		NIU
 AHRSWORK2		Hours worked last week, other job(s)
999		NIU
*/

clonevar hrsworkall = ahrsworkt if ahrsworkt<999
clonevar hrsworkmain = ahrswork1 if ahrswork1<999
clonevar hrsworkother = ahrswork2 if ahrswork2<999
sum hrswork* 
*note: hrsworkall has a max value of 198, which makes no sense because the maximum hours 
*in a week is 168. 
*generate an individual mean and sd:
sort cpsidp
by cpsidp: egen meanhrsmain = mean(hrsworkmain)
by cpsidp: egen sdhrsmain = sd(hrsworkmain)
label var meanhrsmain "individual average work hours p/w"
label var sdhrsmain "individual sd of work hours p/w"
order meanhrsmain, after(cpsidp)
order hrsworkmain, before(meanhrsmain)
order sdhrsmain, after(meanhrsmain)
*---

gen byte sample = inrange(wkstat, 10, 42)
label var sample "sample for analysis: employed"
label define sample 0 "NIU, blank, not in labor force, unemployed" 1 "employed"
label val sample sample 

*POST3
/*info for panel data methods which also mention the interpretation of the output when using
commands used for descriptive statistics of panel data below: 
http://cameron.econ.ucdavis.edu/stata/trpanel.pdf
*/

/*
Stata documentation on xttab and xtsum commands 
http://www.stata.com/manuals13/xtxttab.pdf
http://www.stata.com/manuals13/xtxtsum.pdf
*/

xtset cpsidp seqdate
xtdescribe
*xtsum interpretation: http://www.stata.com/statalist/archive/2003-07/msg00369.html
*xtsum interpretation: http://www.stata.com/manuals13/xtxtsum.pdf

xtsum hrsworkmain if hvarymain
xtsum hrsworkmain
*this shows that those who have varied work hours have a higher 
*standard deviation but also work less hours on average
*this trend is the same if we replace hrsworkmain with hrsworkother. 

xttab underemployed
*3.07% on average were underemployed
*10.21% were ever underemployed
*35.44% of those who were underemployed were always underemployed 

xttab underemployed if hvarymain==1
*for those who report having varied work hours: 
*5.73% on average were underemployed
*8.91% were ever underemployed
*66.52% of those who were underemployed were always underemployed 

xttab underemployed if hvarymain==0
*for those who report not having varied work hours:
*2.87% on average were underemployed
*9.37% were ever underemployed
*38.47% of those who were underemployed were always underemployed 

xttab hvarymain 
*3.31% on average had varied work hours
*12.47% ever had varied work hours
*26.54% of those who had varied work hours always had varied work hours

xttab hvarymain if underemployed==0
*of those who are not underemployed:
*6.88% on average had varied work hours
*22.27% ever had varied work hours
*36.06% of those who had varied work hours always had varied work hours

xttab hvarymain if underemployed==1
*of those who are underemployed:
*13.19% on average had varied work hours
*20.09% ever had varied work hours
*69.51% of those who had varied work hours always had varied work hours


/*
we will be making a table of statistics reported from the xtsum commands. 
each time you use xtsum..., you can type 
   return list
and it will show that it has stored certain values. Below, I've listed the scalars and what they mean.
For example, the scalar r(mean) holds the overall mean displayed in the output after using the xtsum command. 
xtsum, xttab and commands you are familiar with such as describe, summarize, and tab are called r-class commands.
Everytime you use an r-class command, Stata replaces the previous scalars with statistics form the current command used. 
Hence, we must save them and put them into a matrix to be able to see statistics from several uses of xtsum
next to each other to further our understanding of different subgroups. 
      r(mean)        mean
      r(sd)          overall standard deviation
      r(min)         overall minimum
      r(max)         overall maximum
      r(sd_b)        between standard deviation
      r(min_b)       between minimum
      r(max_b)       between maximum
      r(sd_w)        within standard deviation
      r(min_w)       within minimum
      r(max_w)       within maximum
*/

*create a matrix called table1, with 3 rows, 6 columns, and values of 0 in the cells in them:
matrix table1 = J(3, 6, 0)

*view the empty matrix:
matrix list table1


xtsum meanhrsmain sdhrsmain hrsworkmain if jobquality==0
*view the temporarily stored scalars:
return list
*fill in the first row, first column with the value stored in r(mean)
matrix table1[1, 1] = r(mean)
*fill in the first row, second column with the value stored in r(sd) 
matrix table1[1, 2] = r(sd) 
matrix table1[1, 3] = r(sd_b)
matrix table1[1, 4] = r(sd_w)
matrix table1[1, 5] = r(min_w)
matrix table1[1, 6] = r(max_w)


xtsum meanhrsmain sdhrsmain hrsworkmain if jobquality==1
matrix table1[2, 1] = r(mean)
matrix table1[2, 2] = r(sd) 
matrix table1[2, 3] = r(sd_b)
matrix table1[2, 4] = r(sd_w)
matrix table1[2, 5] = r(min_w)
matrix table1[2, 6] = r(max_w)


xtsum meanhrsmain sdhrsmain hrsworkmain if jobquality==2
matrix table1[3, 1] = r(mean)
matrix table1[3, 2] = r(sd) 
matrix table1[3, 3] = r(sd_b)
matrix table1[3, 4] = r(sd_w)
matrix table1[3, 5] = r(min_w)
matrix table1[3, 6] = r(max_w)

*change the names of each row:
matrix rownames table1 = jobquality0 jobquality1 jobquality2

*change the column names: 
matrix colnames table1 = mean overall_sd betw_sd within_sd within_min within_max

*view the filled-in matrix:
matrix list table1




xtsum hrsworkmain 
*mean 37.76, between variation> within variation

xtsum hrsworkmain if underemployed==1
*mean 22.97 between variation> within variation

xtsum hrsworkmain if underemployed==0
*mean 38.25 between variation> within variation


/*
Note on the interpretation of the within values after xtsum: 
xtsum provides the same information as summarize and more. It decomposes the variable xit into
a between (xi) and within (xit ? xi + x, the global mean x being added back in make results
comparable). The global mean is constant, hence if the within min is very negative, 
it is because xi (the individual average) is larger than the individual observation 
for that time period. If the max is very large it is because the individual observation is much 
larger than the individual mean. 
*/
save SRtest
*POST4

use usdb, clear
gen statefip = real(FIPS)
duplicates drop statefip, force 
save usdb, replace
*save the data

*---

*open your dataset with the CPS variables: 
use SRtest, clear
*generate aggregate data by state over time: 
sort statefip
by statefip: egen meanhrsstate = mean(hrsworkmain)
label var meanhrsstate "Mean hours worked by state" 
by statefip: egen sdhrsstate = sd(hrsworkmain)
label var sdhrsstate "SD of hours worked by state"

*one map to consider is the sd per individual over time. then average the sd for each state. this would
*create one value per state:
bysort cpsidp: egen sdhrspp = sd(hrsworkmain)
label var sdhrspp "individual sd of hrsworkedmain over time"
bysort statefip: egen avgsdhrs = mean(sdhrspp)
label var avgsdhrs "state averages of individual sd"
*note the difference between avgsdhrs and sdhrsstate.
*save this dataset 
save SRtest, replace
*--- 

*Merge the map data file and your CPS data to create the map: 
duplicates drop statefip, force 
merge 1:1 statefip using usdb
*check that all the states are merged properly. 
keep if _merge==3




spmap sdhrsstate using uscoord if id !=1 & id!=4 & id!=54 & id!=55, id(id) fcolor(Blues) legend(symy(*2) symx(*2) size(*2))
spmap avgsdhrs using uscoord if id !=1 & id!=4 & id!=54 & id!=55, id(id) fcolor(Blues) legend(symy(*2) symx(*2) size(*2))
spmap meanhrsstate using uscoord if id !=1 & id!=4 & id!=54 & id!=55, id(id) fcolor(Blues) legend(symy(*2) symx(*2) size(*2))
save SRspmap, replace


*POST5
use SRtest, clear

sort statefip
forval j=2014/2015{
	forval i = 1/12{
	by statefip: egen meanhrsstatem`i'`j' = mean(hrsworkmain) if month==`i' & year==`j'
	label var meanhrsstatem`i'`j' "Mean hours worked by state, m`i'y`j'" 
	by statefip: egen sdhrsstatem`i'`j' = sd(hrsworkmain) if month==`i' & year==`j'
	label var sdhrsstatem`i'`j' "SD of hours worked by state, m`i'y`j'"
}
}

*example of one map of January 2015 statistics across the U.S. using spmap: 

preserve
sort statefip year month
duplicates drop sdhrsstatem52015, force
drop in 1
merge 1:1 statefip using usdbforpost5
*refer to post4.do and the information in the comment about post4.do under the issue of Meeting & Assignments to understand what the usdb file is. 
keep if _merge==3
spmap sdhrsstatem52015 using uscoord if id !=1 & id!=4 & id!=54 & id!=55, id(id) fcolor(Blues) legend(symy(*2) symx(*2) size(*2)) note(t=13)




*creating interactive graphs:


*create the graphs for each month surveyed:
*This is because the maps have to be named in a specific way: map001 - map024
local x 0
forval i = 2014/2015 {
	forval j = 1/12	{
		use SRtest, clear
		sort statefip year month
		duplicates drop sdhrsstatem`j'`i', force
		drop in 1
		merge 1:1 statefip using usdbforpost5
		spmap sdhrsstatem`j'`i' using uscoord if id !=1 & id!=4 & id!=54 & id!=55, id(id) fcolor(Blues) legend(symy(*2) symx(*2) size(*2)) note(Date = `i'm`j')
		local ++x
		graph export "map00`x'.png", replace
	}
}

*show the files in your working directory to check if graphs were made
ls

*go in and manually rename the files named map0010-map0024 as map010-map024.

*note: must download ffmpeg: https://ffmpeg.org/
*note: use shell if on a Mac, use winexec if on Windows. Adjust file paths. 
*note that map%03d refers to the fact that I named the maps with 0's in front followed by 3 digits after the word "map". 

local Graphpath /Users/ChanKLum/Desktop/SummerResearch/
shell "/Users/ChanKLum/Desktop/SummerResearch/ffmpeg" -i `GraphPath'map%03d.png -b:v 512k `GraphPath'map.mpg
shell "/Users/ChanKLum/Desktop/SummerResearch/ffmpeg" -r 10 -i `GraphPath'map.mpg -t 10 -r 10 `GraphPath'map.gif



use SRtest, clear

local x 0
forval i = 2014/2015 {
	forval j = 1/12	{
	kdensity sdhrsstatem`j'`i',  xlabel(7(1)25) xmtick(7(1)25) ylabel(0(0.2)1)
	local ++x
	graph export "kdens_00`x'.png", replace
	}
}
*go in and manually rename the graphs named kdens_0010-0024 as kdens_010-024
local GraphPath /Users/Jessicalum/Downloads/
shell "/Users/Jessicalum/Downloads/SnowLeopard_Lion_Mountain_Lion_Mavericks_Yosemite_El-Captain_15.08.2016/ffmpeg" -i `GraphPath'kdens_%03d.png -b:v 512k `GraphPath'kdens.mpg
shell "/Users/Jessicalum/Downloads/SnowLeopard_Lion_Mountain_Lion_Mavericks_Yosemite_El-Captain_15.08.2016/ffmpeg" -r 10 -i `GraphPath'kdens.mpg -t 10 -r 10 `GraphPath'kdens.gif

*POST6
use SRtest, clear
gen byte parttime = inlist(wkstat, 14, 15, 20, 22, 40, 41, 42) if wkstat<50

order underemployed, after(cpsidp)
order hvarymain, after(underemployed)
order hrsworkmain, after(hvarymain)
order parttime, after(hrsworkmain) 

*---

tsspell underemployed ,cond(underemployed==1) seq(underempseq) spell(underempspell) end(underempend)
*label these variables. 
order underemployed, before(underempseq)
order cpsidp, before(underemployed) 

*generate the maximum amount of spells:
sort cpsidp
by cpsidp: egen underempmaxspell = max(underempspell) if !missing(underemployed)

*generate the length of the spells:
by cpsidp: egen underemplongspell = max(underempseq) if !missing(underemployed)
xttab  underemplongspell if  underempmaxspell==1
*this shows us that 33 people have a maximum spell length of 8 months
*which means that for all 8 months they were surveyed, they were underemployed. 
*23 people have a max spell length of 7 months, etc. 
*---

tsspell hvarymain ,cond(hvarymain==1) seq(hvarymseq) spell(hvarymspell) end(hvarymend)
order hvarymain, before(hvarymseq)
order cpsidp, before(hvarymain)

*generate the maximum amount of spells:
by cpsidp: egen hvarymmaxspell = max(hvarymspell) if !missing(hvarymain)

*generate the length of the spells:
by cpsidp: egen hvarymlongspell = max(hvarymseq) if !missing(hvarymain)

xttab hvarymlongspell if hvarymmaxspell==1
*for those who have only one spell of reporting having consecutive months of
*varied work hours, 117 people have 8 months varied work hours
*82 people reported having 7 continuous months of varied work hours, etc. 


*--- 

tsspell parttime ,cond(parttime==1) seq(parttimeseq) spell(parttimespell) end(parttimeend)
*label these variables
order parttime, before(parttimeseq)
order cpsidp, before(parttime)

*generate the maximum amount of spells:
by cpsidp: egen parttimemaxspell = max(parttimespell) if !missing(parttime)

*generate the length of the spells:
by cpsidp: egen parttimelongspell = max(parttimeseq) if !missing(parttime)

xttab parttimelongspell if parttimemaxspell==1
* 1752 people have at most 1 continuous 8-month spell of having usually part-time hours. 

*---

*generate an indicator for those who report being usually part-time for economic reasons
gen byte parttime2 = inlist(wkstat, 14, 20, 22) if wkstat<50
label var parttime2 "usually part-time for econ reasons"
label val parttime2 yesno

xttab parttime2 if parttime==1
*of those who report being usually part-time, 4406 people are so because of economic reasons
*and 13,342 of them are not part-time for economic reasons 

tsspell parttime2 ,cond(parttime2==1) seq(parttime2seq) spell(parttime2spell) end(parttime2end)
*label these variables
order parttime2, before(parttime2seq)
order cpsidp, before(parttime2)

*generate the maximum amount of spells:
by cpsidp: egen parttime2maxspell = max(parttime2spell) if !missing(parttime2)

*generate the length of the spells:
by cpsidp: egen parttime2longspell = max(parttime2seq) if !missing(parttime2)

xttab parttime2longspell if parttime2maxspell==1
*33 people have one continuous 8-month spell of being parttime for economic reasons


*POST7.do
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
*assert test==1
*note assertion is false, therefore we will find out why
list statefip mnthyr test if test!=1
*this tells us that Utah, North Carolina, and Montana have a test value of .9999999 which is close to 1, so we can still make the triplot. 




forval i = 1/9 {
	triplot pctpart pctfull pctneith if mnthyr==`i', separate(statefip) legend(off) note(t=`i')
	graph export triplot_00`i'.png, replace
}

forval i = 10/24 {
	triplot pctpart pctfull pctneith if mnthyr==`i', separate(statefip) legend(off) note(t=`i')
	graph export triplot_0`i'.png, replace
}

local Graphpath /Users/Jessicalum/Downloads/
shell "/Users/Jessicalum/Downloads/SnowLeopard_Lion_Mountain_Lion_Mavericks_Yosemite_El-Captain_15.08.2016/ffmpeg" -i `GraphPath'triplot_%03d.png -b:v 512k `GraphPath'triplot.mpg
shell "/Users/Jessicalum/Downloads/SnowLeopard_Lion_Mountain_Lion_Mavericks_Yosemite_El-Captain_15.08.2016/ffmpeg" -r 10 -i `GraphPath'triplot.mpg -t 10 -r 10 `GraphPath'triplot.gif



sort region mnthyr
by region mnthyr: egen meanhrsworkedmy = mean(hrsworkmain) 
by region mnthyr: egen meansdhrsmy = mean(sdhrsmain) 
by region mnthyr: egen meanmeanhrsmy = mean(meanhrsmain) 

save SRtest, replace

preserve
duplicates drop region mnthyr, force
xtset region mnthyr

*look at changes over time of average hours worked by region:
xtline meanhrsworkedmy, overlay
graph export overallavg.png, replace
*trends in all regions are much less smooth, however we see a sharp decrease in September 2015 for all regions. 
*find out why. 


*look at changes over time of the average of individuals' standard deviation by region: 
xtline meansdhrsmy, overlay
graph export stdev.png, replace
*overall increase in meansdhrsD until November 2014, where we see a steep drop continuing until
*the lowest point in January 2015, then a steady increase until September 2015 where there is a drop once again. 

*look at changes over time of the regional averages of individual's average hours worked per week: 
xtline meanmeanhrsmy, overlay
graph export avg.png, replace
*West South Central Division maintains a steady value over time. 
