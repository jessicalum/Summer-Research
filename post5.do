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
duplicates drop sdhrsstatem122015, force
drop in 1
spmap sdhrsstatem12015 using uscoord if id !=1, id(id) fcolor(Blues) legend(symy(*2) symx(*2) size(*2))
restore

*creating interactive graphs:
*create the graphs for each month surveyed


forval i=2014/2015  {
	forval j = 1/9	{
	use SRmasterv4, clear
	sort statefip year month
	duplicates drop sdhrsstatem`j'`i', force
	drop in 1
	merge 1:1 statefip using usdbforpost5
	spmap sdhrsstatem`j'`i' using uscoord if id !=1, id(id) fcolor(Blues) legend(symy(*2) symx(*2) size(*2))
	graph export "map00`j'`i'.png", replace
}
}


forval i=2014/2015  {
	forval j = 10/12	{
	use SRmasterv4, clear
	sort statefip year month
	duplicates drop sdhrsstatem`j'`i', force
	drop in 1
	merge 1:1 statefip using usdbforpost5
	spmap sdhrsstatem`j'`i' using uscoord if id !=1, id(id) fcolor(Blues) legend(symy(*2) symx(*2) size(*2))
	graph export "map0`j'`i'.png", replace
}
}

*Important:
*rename all the graphs as map_001 - map_024. 


*show the files in your working directory to check if graphs were made
ls

*note: must download ffmpeg: https://ffmpeg.org/
*note: use shell if on a Mac, use winexec and adjust file paths if on Windows. 
cd /Users/ChanKLum/Desktop/SummerResearch/
shell "/Users/ChanKLum/Desktop/SummerResearch/ffmpeg" -i `GraphPath'map_%03d.png -b:v 512k `GraphPath'map.mpg
shell "/Users/ChanKLum/Desktop/SummerResearch/ffmpeg" -r 10 -i `GraphPath'map.mpg -t 10 -r 10 `GraphPath'map.gif
