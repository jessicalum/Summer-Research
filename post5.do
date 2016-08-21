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




*creating interactive graphs:


*create the graphs for each month surveyed:
*This is because the maps have to be named in a specific way: map001 - map024
local x 0
forval i = 2014/2015 {
	forval j = 1/12	{
		use SRmasterv6, clear
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



use SRmasterv6, clear

local x 0
forval i = 2014/2015 {
	forval j = 1/12	{
	kdensity sdhrsstatem`j'`i',  xlabel(7(1)25) xmtick(7(1)25) ylabel(0(0.2)1)
	local ++x
	graph export "kdens_00`x'.png", replace
	}
}
*go in and manually rename the graphs named kdens_0010-0024 as kdens_010-024
local GraphPath /Users/ChanKLum/Desktop/SummerResearch/
shell "/Users/ChanKLum/Desktop/SummerResearch/ffmpeg" -i `GraphPath'kdens_%03d.png -b:v 512k `GraphPath'kdens.mpg
shell "/Users/ChanKLum/Desktop/SummerResearch/ffmpeg" -r 10 -i `GraphPath'kdens.mpg -t 10 -r 10 `GraphPath'kdens.gif
