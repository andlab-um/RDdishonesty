# Dishonesty
# mDDM simulation
# adapted from Silvia Maire: https://osf.io/g76fn/
# Xinyi Julia Xu, 2022.11.13
# xinyi_x@outlook.com




#simulate behavior using fitted mDDM parameters and choices presented to subjects
rm(list=ls())

want = c("DEoptim", "Rcpp", "plyr", "parallel")
have = want %in% rownames(installed.packages())
if ( any(!have) ) { install.packages( want[!have] ) }
# Now load them all
lapply(want, require, character.only = TRUE)
rm(want, have)

dir= "/Users/orlacamus/Desktop/projects/dishonesty/fMRI/dishonesty_behav/DDM-related"
setwd(paste0(dir,"/parameter_recovery/simulateRT"))
saveNew = T #save new data or not

RcppParallel::setThreadOptions(numThreads = 1) #this is critical for running on Mac OS for some reason.

# load the c++ file containing the functions to simulate the tSSM ----
sourceCpp(paste0(dir,"/parameter_recovery/simDDMs/simulate_mDDM_lrt_Rcpp.cpp"))

# load behavioral data ----
Data = read.csv("/Users/orlacamus/Desktop/projects/dishonesty/fMRI/dishonesty_behav/behav_summary.csv")
mParams= read.csv(paste0(dir,'/fitting_code/results_mddm/fits_sw_mddm.csv'))

# Data = Data[Data$RT > 0.2,] #remove RTs < 200 ms # already: at least 400ms
## subject number: from 104 to 134; drop 107, 116, 129
drop_sub = c(107,116,129)
Data = Data[!Data$sub %in% drop_sub,]
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

for (r in c(2,3,4,5,6,7)){
#for (r in c(2,3)){
  data=Data[Data$run %in% c(r,r+1,r+2),]
  rtsM = matrix(NA, ncol = nsims)
  for (subj in unique(data$sub)){
    for (i in 1:length(data[data$sub==subj,]$RT)) {
      rtsM_temp = mddm_parallel_sim(mParams[mParams$sub_nr==subj&mParams$run==r,]$drate_m,mParams[mParams$sub_nr==subj&mParams$run==r,]$drate_c,mParams[mParams$sub_nr==subj&mParams$run==r,]$thres,mParams[mParams$sub_nr==subj&mParams$run==r,]$nDT,mParams[mParams$sub_nr==subj&mParams$run==r,]$bias,data[data$sub==subj,][i,]$error.correct,data[data$sub==subj,][i,]$former_diff,sd_n,nsims)
      rtsM=rbind(rtsM,rtsM_temp)
    }
  }
  rtsM=rtsM[-1,]    
#  mean rt correlation across 1000 simulated choice sets 
  tmp = cor(rtsM)
  mean1=mean(tmp[lower.tri(tmp)])
  simLie = rowMeans(rtsM > 0)
  mean_lie=mean((simLie >= 0.5) == data$lie)
  
  simRT=rtsM[,1]
  
  simsM = cbind(data,simRT, simLie,mean1,mean_lie)
  
  if (saveNew) {save(simsM, file=paste0("mDDM_choice_sims_",r,".RData"), version = 2)}
  
}


