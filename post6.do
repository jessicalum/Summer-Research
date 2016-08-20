use SRmasterv4, clear
/*
create more indicators of work schedule irregularity
using tsspell: 
1.create a variable of the spells of underemployment one has.
2.the spells reporting the times one reports having hrsvarymain==1. 
3.measure spells of part-time work/ part-time work for economic reasons. 
*/

gen byte parttime = inlist(wkstat, 14, 15, 20, 22, 40, 41, 42) if wkstat<50


*order the vars in the varlist for ease of understanding in data browser
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


*generate an indicator for usually full-time or usually part-time 
gen byte parttime = inlist(wkstat, 14, 15, 20, 22, 40, 41, 42) if wkstat<50

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








