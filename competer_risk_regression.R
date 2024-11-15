library(cmprsk)  
library(aod)  
training_cohort <- read.table("train.csv", sep = ",", head = T,row.names=1)  
fstatus <- training_cohort$Group  
ftime <- training_cohort$DFS  

source("functions/univariate_crr.R")  

Covariate <- cbind(training_cohort$Sig,training_cohort$CA199,training_cohort$Tstage,N)  
Covariate_SHR <- crr(ftime,fstatus,Covariate)  
Covariate_clinic <- cbind(training_cohort$CA199,training_cohort$Tstage,N)  
Covariate_clinic_SHR <- crr(ftime,fstatus,Covariate_clinic)  
summary(Covariate_SHR)  
summary(Covariate_clinic_SHR)  
wald.test(Covariate_SHR$var,Covariate_SHR$coef,Terms=4:7)  
wald.test(Covariate_clinic_SHR$var,Covariate_clinic_SHR$coef,Terms=3:6)