library(survminer)  
cutpoint <- read.table("cut_point.csv", sep = ",", head = T,row.names=1)  
cut_point <- surv_cutpoint(data = cutpoint, time = "time", event = "status", variables = "Sig",  
                           minprop = 0.1, progressbar = TRUE)  
plot(cut_point,  legend = "")  
cut_point