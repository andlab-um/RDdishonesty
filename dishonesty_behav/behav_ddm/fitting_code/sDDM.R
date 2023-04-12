# Dishonesty
# sDDM fitting
# adapted from Silvia Maire: https://osf.io/g76fn/
# Xinyi Julia Xu, 2022.11.13
# xinyi_x@outlook.com



# Install required packages if necessary:
want = c("DEoptim", "Rcpp", "plyr", "parallel","brms","pracma")
have = want %in% rownames(installed.packages())
if ( any(!have) ) { install.packages( want[!have] ) }
# Now load them all
lapply(want, require, character.only = TRUE)
RcppParallel::setThreadOptions(numThreads = 1) #this is critical for running on Mac OS for some reason.

### --- how to run the sDDM:
# load the c++ file containing the functions to simulate the delayed DDM
sourceCpp("/media/haiyanwu/HDD2/xinyi_RanDishonesty/behav_ddm/fitDDMs/sDDM_Rcpp.cpp")

### read in behavioral data
Data = read.csv("/media/haiyanwu/HDD2/fmri2019/7.DDM-related/fMRI_sessionData_DDM.csv", header = T)

## subject number: from 104 to 134; drop 107, 116, 129
#drop_sub = c(107,116,129)
#Data = Data[!Data$sub %in% drop_sub,]
subL=c(104,105,108,109,110,111,112,113,114,115,117,120,121,122,124,125,126,127,130,131,133,134,135,137,138,139,140)

Data = Data[Data$sub %in% subL,]
dataBeh = Data[c('sub',
                 'run',
                 'ses',
                 'error.correct',
                 'former_diff',
                 'lie',
                 'RT')]
#dataBeh$absdiff = abs(dataBeh$diff)
dataBeh$logRT = log(dataBeh$RT)

### Select block
#idx = which(dataBeh$run!=1)
#dataBeh = dataBeh[idx,]

# assign negative RTs to honesty trials 
dataBeh$RTddm = dataBeh$RT
dataBeh$RTddm[dataBeh$lie==0] = dataBeh$RTddm[dataBeh$lie==0] * -1
ntrials = length(dataBeh$RT)

# bin the prob. density space of RTs
xpos = seq(-4,4,length.out=1024)
dt = xpos[2] - xpos[1]
dataBeh$RTddm_pos = 0
for (i in 1:ntrials) {
  dataBeh$RTddm_pos[i] = which.min(abs(xpos - dataBeh$RTddm[i]))
}

# define fitting functions ---- logliklihood_sDDM

ll_sddm <- function(params, subjdata, md, cd) {
  
  drate=params[1]

  nDT=params[2]

  
  
  probs = NULL
  for (i in 1:length(md)) {
    # how many simulations of each value difference pair?
    # 1000 is good, 5000 is better, and simulations indicate diminishing 
    rts = sddm_parallel(drate,nDT,md[i],cd[i],3000)
    #rts = rts[rts!=0]
    xdens = density(rts, from=-4, to=4, n=1024, bw=0.11)
    idx = which(subjdata$error.correct==md[i] & subjdata$former_diff==cd[i])
    probs = c(probs, dt*xdens$y[subjdata$RTddm_pos[idx]])
  }
  
  probs[probs==0] = 1e-100
  return (-sum(log(probs)))
  
}

fitSub <- function(subj_nr, alldata) {
  fit=matrix(0,1,6)
  idx = which(alldata$sub==subj_nr)
  subjdata = alldata[idx,]
  meanrt=mean(subjdata[,'RT'])
  
  data1 = ddply(subjdata, .(former_diff, error.correct), summarize, lie_rate= mean(lie))
  
  lower <- c(-2,0)
  upper <- c(2,meanrt)
  
  
  fit_subj = DEoptim(ll_sddm, lower, upper, DEoptim.control(itermax = 150), subjdata=subjdata, md=data1$error.correct,cd=data1$former_diff)
  fit[1,1:2] = fit_subj$optim$bestmem # readout the fitted params
  fit[1,3] = fit_subj$optim$bestval # -LL
  fit[1,4] = 2*fit_subj$optim$bestval + length(lower)*log(length(data1$error.correct)) # BIC
  fit[1,5] = 2*fit_subj$optim$bestval + 2*length(lower) #AIC
  fit[1,6] = mean(subjdata$sub)
  return(fit)
}

inputsubj = unique(dataBeh$sub)

numCores <- detectCores()
k=1
fits=matrix(0,length(inputsubj),6)

#for (r in c(2,3,4,5,6,7)){

for (i in inputsubj){
  print(paste0('fitting subj: ', i))
  fit = c(unlist(mclapply(i, fitSub, mc.cores = numCores, alldata=dataBeh)))
  fits[k,1:6]=fit
  k=k+1
}

#save now in case unlist fails
fitsF=fits
save(fitsF, file="/media/haiyanwu/HDD2/xinyi_RanDishonesty/behav_ddm/fitting_code/results_sddm/fits_all_sddm.RData")
write.csv(fitsF, file = "/media/haiyanwu/HDD2/xinyi_RanDishonesty/behav_ddm/fitting_code/results_sddm/fits_all_sddm.csv")

fitsF = as.data.frame(fitsF,ncol=7,byrow=TRUE)
names(fitsF)<-c("drate", 'nDT',"LL", "BIC", "AIC",'sub_nr')
#will overwrite previous save, but that is intended
save(fitsF, file="/media/haiyanwu/HDD2/xinyi_RanDishonesty/behav_ddm/fitting_code/results_sddm/fits_all_sddm.RData")
write.csv(fitsF, file = "/media/haiyanwu/HDD2/xinyi_RanDishonesty/behav_ddm/fitting_code/results_sddm/fits_all_sddm.csv")
