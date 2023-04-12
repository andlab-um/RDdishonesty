# Dishonesty
# tDDM simulation
# adapted from Silvia Maire: https://osf.io/g76fn/
# Xinyi Julia Xu, 2022.11.13
# xinyi_x@outlook.com





#simulate behavior using fitted tDDM parameters and choices presented to subjects
rm(list=ls())

want = c("DEoptim", "Rcpp", "plyr", "parallel")
have = want %in% rownames(installed.packages())
if ( any(!have) ) { install.packages( want[!have] ) }
# Now load them all
lapply(want, require, character.only = TRUE)
rm(want, have)

dir='/media/haiyanwu/HDD2/xinyi_RanDishonesty/behav_ddm/'
setwd("/media/haiyanwu/HDD2/xinyi_RanDishonesty/behav_ddm/parameter_recovery/")
saveNew = T #save new data or not

RcppParallel::setThreadOptions(numThreads = 1) #this is critical for running on Mac OS for some reason.

# load the c++ file containing the functions to simulate the tDDM ----
sourceCpp("/media/haiyanwu/HDD2/xinyi_RanDishonesty/behav_ddm/fitDDMs/tDDM_Rcpp.cpp")

# load behavioral data ----
Data = read.csv("/media/haiyanwu/HDD2/xinyi_RanDishonesty/behav_ddm/behav_summary.csv", header = T)
subL=c(104,105,108,109,110,111,112,113,114,115,117,120,121,122,124,125,126,127,130,131,133,134,135,137,138,139,140)
Data = Data[Data$sub %in% subL,]


tParams= read.csv(paste0(dir,'/fitting_code/results_tddm/fits_all_tddm.csv'))

Data = Data[c('sub',
              'run',
              'ses',
              'error.correct',
              'former_diff',
              'lie',
              'RT')]
#recode RTs to pos or neg

Data$RTddm = Data$RT
Data$RTddm[Data$lie==0] = Data$RTddm[Data$lie==0] * -1
sd_n = 1.4
nsims=1000


rtsT = matrix(NA, ncol = nsims)
for (subj in unique(Data$sub)){
  for (i in 1:length(Data[Data$sub==subj,]$RT)) {
    rtsT_temp = tddm_parallel(tParams[tParams$sub_nr==subj,]$drate_m,tParams[tParams$sub_nr==subj,]$drate_c,tParams[tParams$sub_nr==subj,]$lat_m,tParams[tParams$sub_nr==subj,]$lat_c,Data[Data$sub==subj,][i,]$error.correct,Data[Data$sub==subj,][i,]$former_diff,nsims)
    rtsT=rbind(rtsT,rtsT_temp)
  }
}
rtsT=rtsT[-1,]    
simLieProb = rowMeans(rtsT > 0)
simRT=rtsT[,1]

simsT = cbind(Data,simRT, simLieProb)
simsT$simLie=0
simsT[simsT$simLieProb>0.5,]$simLie=1
if (saveNew) {write.csv(simsT, file="tDDM_choice_simsT.csv")}
if (saveNew) {write.csv(rtsT, file="tDDM_RT_simsT.csv")}
if (saveNew) {save(simsT, file="tDDM_choice_simsT.RData")}
if (saveNew) {write.csv(rtsT, file="tDDM_RT_simsT.csv")}




