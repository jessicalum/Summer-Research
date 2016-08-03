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

matrix table1 = J(3, 6, 0)

xtsum meanhrsmain sdhrsmain hrsworkmain if jobquality==0
matrix table1[1, 1] = r(mean)
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

matrix rownames table1 = jobquality0 jobquality1 jobquality2
matrix colnames table1 = mean overall_sd betw_sd within_sd within_min within_max

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
