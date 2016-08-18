use SRmasterv6, clear

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
restore



*creating interactive graphs:
*create the graphs for each month surveyed


*It looks like a lot however they are just the same loops with different months and years.
*This is because the maps have to be named in a specific way: map001 - map024
forval j = 1/9	{
	use SRmasterv6, clear
	sort statefip year month
	duplicates drop sdhrsstatem`j'2014, force
	drop in 1
	merge 1:1 statefip using usdbforpost5
	spmap sdhrsstatem`j'2014 using uscoord if id !=1 & id!=4 & id!=54 & id!=55, id(id) fcolor(Blues) legend(symy(*2) symx(*2) size(*2)) note(Date = 2014m`j')
	graph export "map00`j'.png", replace
}


forval j = 1/9	{
	use SRmasterv6, clear
	sort statefip year month
	duplicates drop sdhrsstatem`j'2015, force
	drop in 1
	merge 1:1 statefip using usdbforpost5
	spmap sdhrsstatem`j'2015 using uscoord if id !=1 & id!=4 & id!=54 & id!=55, id(id) fcolor(Blues) legend(symy(*2) symx(*2) size(*2)) note(Date = 2015m`j')
	local a = `j'+12
	graph export "map0`a'.png", replace
}

forval j = 10/12	{
	use SRmasterv6, clear
	sort statefip year month
	duplicates drop sdhrsstatem`j'2014, force
	drop in 1
	merge 1:1 statefip using usdbforpost5
	spmap sdhrsstatem`j'2014 using uscoord if id !=1 & id!=4 & id!=54 & id!=55, id(id) fcolor(Blues) legend(symy(*2) symx(*2) size(*2)) note(Date = 2014m`j')
	graph export "map0`j'.png", replace
}

forval j = 10/12	{
	use SRmasterv6, clear
	sort statefip year month
	duplicates drop sdhrsstatem`j'2015, force
	drop in 1
	merge 1:1 statefip using usdbforpost5
	spmap sdhrsstatem`j'2015 using uscoord if id !=1 & id!=4 & id!=54 & id!=55, id(id) fcolor(Blues) legend(symy(*2) symx(*2) size(*2)) note(Date = 2015m`j')
	local b = `j'+12
	graph export "map0`b'.png", replace
}


*show the files in your working directory to check if graphs were made
ls

*note: must download ffmpeg: https://ffmpeg.org/
*note: use shell if on a Mac, use winexec and adjust file paths if on Windows. 
cd /Users/ChanKLum/Desktop/SummerResearch/
shell "/Users/ChanKLum/Desktop/SummerResearch/ffmpeg" -i `GraphPath'map%03d.png -b:v 512k `GraphPath'map.mpg
shell "/Users/ChanKLum/Desktop/SummerResearch/ffmpeg" -r 10 -i `GraphPath'map.mpg -t 10 -r 10 `GraphPath'map.gif



use SRmasterv6, clear

	forval j = 1/9	{
	kdensity sdhrsstatem`j'2014,  xlabel(7(1)25) xmtick(7(1)25) ylabel(0(0.2)1)
	graph export "kdens_00`j'`i'.png", replace
}

	forval j = 1/9	{
	kdensity sdhrsstatem`j'2015, xlabel(7(1)25) xmtick(7(1)25) ylabel(0(0.2)1)
	local a = `j'+12
	graph export "kdens_0`a'.png", replace
}

	forval j = 10/12	{
	kdensity sdhrsstatem`j'2014, xlabel(7(1)25) xmtick(7(1)25) ylabel(0(0.2)1)
	graph export "kdens_0`j'.png", replace
}

	forval j = 10/12	{
	kdensity sdhrsstatem`j'2015, xlabel(7(1)25) xmtick(7(1)25) ylabel(0(0.2)1)
	local b = `j'+12
	graph export "kdens_0`b'.png", replace
}


cd /Users/ChanKLum/Desktop/SummerResearch/
shell "/Users/ChanKLum/Desktop/SummerResearch/ffmpeg" -i `GraphPath'kdens_%03d.png -b:v 512k `GraphPath'kdens.mpg
shell "/Users/ChanKLum/Desktop/SummerResearch/ffmpeg" -r 10 -i `GraphPath'kdens.mpg -t 10 -r 10 `GraphPath'kdens.gif
