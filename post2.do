*creation of different measurements of job quality based on work schedule irregularity:
*import variables: wkstat, uhrsworkt, uhrswork1, uhrswork2, ahrsworkt, ahrswork1, ahrswork2
---

/*
 WKSTAT		Full or part time status
10		Full-time schedules
11		Full-time hours (35+), usually full-time
12		Part-time for non-economic reasons, usually full-time
13		Not at work, usually full-time
14		Full-time hours, usually part-time for economic reasons
15		Full-time hours, usually part-time for non-economic reasons
20		Part-time for economic reasons
21		Part-time for economic reasons, usually full-time
22		Part-time hours, usually part-time for economic reasons
40		Part-time for non-economic reasons, usually part-time
41		Part-time hours, usually part-time for non-economic reasons
42		Not at work, usually part-time
50		Unemployed, seeking full-time work
60		Unemployed, seeking part-time work
99		NIU, blank, or not in labor force
*/
gen byte underemployed = inlist(wkstat, 14, 20, 22)
replace underemployed = . if wkstat >=50
*if underemployed = 0, then we assume individuals are satisfied with the amount of work they have. 
label var underemployed "underemployed for economic reasons?"
label define yesno 0 "no" 1 "yes" 
label val underemployed yesno 

---

gen byte hvaryall = inlist(uhrsworkt, 997)
gen byte hvarymain = inlist(uhrswork1, 997)
gen byte hvaryother = inlist(uhrswork2, 997) 
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

---

/*create a categorical variable: = 0 if underemployed, = 1 if reports having 
hours that vary, = 2 if both */
gen byte jobquality = 0 if underemployed==1 & hvarymain==0
replace jobquality = 1 if hvarymain==1 & underemployed==0
replace jobquality = 2 if underemployed==1 & hvarymain==1 
label var jobquality "job quality"
label define jobquality 0 "underemployed" 1 "hours vary, main job" 2 "both" 
label val jobquality jobquality 

---

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
by cpsidp: egen meanhrsmain = mean(hrsworkmain)
by cpsidp: egen sdhrsmain = sd(hrsworkmain)
label var meanhrsmain "individual average work hours p/w"
label var sdhrsmain "individual sd of work hours p/w"
order meanhrsmain, after(cpsidp)
order hrsworkmain, before(meanhrsmain)
order sdhrsmain, after(meanhrsmain)
---

gen byte sample = inrange(wkstat, 10, 42)
label var sample "sample for analysis: employed"
label define sample 0 "NIU, blank, not in labor force, unemployed" 1 "employed"
label val sample sample 
* run analysis only using this sample: for example: reg y x1 x2 if sample



