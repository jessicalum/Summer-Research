*we are going to create a map of some statistics to understand trends by state. 
/*
1. READ THIS: *http://www.stata.com/support/faqs/graphics/spmap-and-maps/
2. in the above, it mentions this website which will give you the geographic data: 
3. go to http://www.nws.noaa.gov/geodata/catalog/national/html/us_state.htm
4. under "Available Version(s), click on "Download Compressed Shapefile s_10nv15.zip
5. place the file in your working directory where all your Summer Research data is. 
6. unzip the file. 
*/



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



*merge the usdb data and your dataset: note in order to merge it you must do the following: 
*in the usdb dataset: 
gen statefip = real(FIPS)
duplicates drop statefip, force 
*save the data

*in your dataset: 
duplicates drop statefip 
merge 1:1 statefip using usdb
*check that all the states are merged properly. 
keep if _merge==3
keep statefip OBJECTID STATE NAME FIP LON LAT Shape_Leng Shape_Area id meanhrsstate sdhrsstate sdhrspp avgsdhrs



*must sort by id or stateid or whatever identifies each observation 
sort statefip
spmap meanhrsstate using uscoord if id !=1 & id!=56, id(id) fcolor(Blues)
spmap sdhrsstate using uscoord if id !=1 & id!=56, id(id) fcolor(Blues)
save "/Users/ChanKLum/Downloads/s_10nv15/testspmap.dta"
*note spmap can only work with wide form data. 
*THIS HAS TO BE DROPPED AND REMADE WITH STATEFIP INSTEAD OF ID 

spmap sdhrsstate using uscoord if id !=1 & id!=56, id(id) fcolor(Blues) legend(symy(*4) symx(*4) size(*4))
*this makes the legend bigger.

spmap avgsdhrs using uscoord if id !=1 & id!=56, id(id) fcolor(Blues) legend(symy(*4) symx(*4) size(*4))
