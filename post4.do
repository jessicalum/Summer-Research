*we are going to create a map of some statistics to understand trends by state. 
/*
1. READ THIS: *http://www.stata.com/support/faqs/graphics/spmap-and-maps/
2. in the above, it mentions this website which will give you the geographic data: 
3. go to http://www.nws.noaa.gov/geodata/catalog/national/html/us_state.htm
4. under "Available Version(s), click on "Download Compressed Shapefile s_11au16.zip"
5. place the file in your working directory where all your Summer Research data is. 
6. unzip the file. 
*/

*make files in Stata format: a database file, usdb.dta, and a coordinates file, uscoord.dta 
shp2dta using s_11au16, database(usdb) coordinates(uscoord)

*merge the usdb data and your dataset: note in order to merge it you must do the following: 
*in the usdb dataset: 
use usdb
gen statefip = real(FIPS)
duplicates drop statefip, force 
*save the data

*---

*open your dataset with the ipums variables: 

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

*--- 

Merge the map data file and your CPS data to create the map: 
duplicates drop statefip 
merge 1:1 statefip using usdb
*check that all the states are merged properly. 
keep if _merge==3


spmap sdhrsstate using uscoord if id !=1, id(id) fcolor(Blues) legend(symy(*4) symx(*4) size(*4))
spmap avgsdhrs using uscoord if id !=1, id(id) fcolor(Blues) legend(symy(*4) symx(*4) size(*4))
