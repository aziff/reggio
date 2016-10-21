
clear
set obs 200

gen x = 1 in 1/60
replace x = 0 in 61/100
gen treatment = 1 in 1/100

replace x = 1 in 101/135
replace x = 0 in 136/200
replace treatment = 0 in 101/200

gen y = 3*treatment + invnorm(uniform())

sum x if treatment == 1
gen mean1 = r(mean)
sum x if treatment == 0
gen mean0 = r(mean)

/*
gen weight = 1 if(treatment == 1)
replace weight = mean1/mean0 if(treatment == 0 & x == 1)
replace weight = (1-mean1)/(1-mean0) if(treatment == 0 & x == 0)
*/

probit treatment x
predict p

gen weight = 1/p if(treatment == 1)
replace weight = 1/(1-p) if(treatment == 0)

sum x p if treatment == 1 [iweight = weight]  
sum x p if treatment == 0 [iweight = weight]  







