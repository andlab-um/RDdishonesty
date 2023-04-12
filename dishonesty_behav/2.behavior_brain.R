# Dishonesty
# Behavioral ~ brain
# Xinyi Julia Xu, 2022.11.11
# xinyi_x@outlook.com

rm(list=ls())
setwd("~/Desktop/projects/dishonesty/fMRI/dishonesty_behav")

# function summarySE is in package Rmisc, but Rmisc contains plyr which conflicts with dplyr
# https://stackoverflow.com/questions/26923862/why-are-my-dplyr-group-by-summarize-not-working-properly-name-collision-with
# difference between summarySEwithin & summarise:  idvar is used to normalize rather than groupby 
# if want to use plyr, import before dplyr


# Install required packages if necessary:
want = c("data.table", "lme4", "Matrix","ez","ggplot2","dplyr",'ggpubr','patchwork','tidyr',' reticulate','tidyverse','readxl')
have = want %in% rownames(installed.packages())
if ( any(!have) ) { install.packages( want[!have] ) }
# Now load them all
lapply(want, require, character.only = TRUE)
library(reticulate)
library(svglite)

# Read data
dt <- fread("/users/orlacamus/desktop/projects/dishonesty/fMRI/dishonesty_behav/behav_summary.csv")

a=which(colnames(dt)=='error-correct')
colnames(dt)[a] <- 'error.correct'

subL = c(104,105,108,109,110,111,112,113,114,115,117,120,121,122,124,125,126,127,130,131,133,134,135,137,138,139,140)

dt = dt[dt$sub %in% subL,]

dataBeh = dt[,c('sub',
                 'run',
                 'ses',
                 'ind',
                 'error.correct',
                 'former_diff',
                 'lie',
                 'RT',
                 'MAD',
                 'AD',
                 'AUC')]


# Reclass variables
dataBeh <- within(dataBeh, {
  sub <- as.integer(sub)
  RT <- as.numeric(RT)
  index <- as.integer(ind)
  run <- as.integer(run)
  ses <- as.integer(ses)
  money_diff <- as.integer(error.correct) 
  consis_diff <- as.integer(former_diff) 
  lie <- as.numeric(lie)
  MAD <- as.numeric(MAD)
  AD <- as.numeric(AD)
  AUC <- as.numeric(AUC)
})

# Lie rates
MT=dataBeh %>% group_by(sub,ses) %>%
  dplyr::summarise(MAD = mean(MAD),AD = mean(AD),AUC = mean(AUC))
MT=MT[MT$ses==3,]


rm(want,have,dt)

lieProp <- dataBeh %>% group_by(sub,ses,lie) %>%
  dplyr::summarise(cnt = n()) %>%
  mutate(freq = cnt / sum(cnt)) %>%
  arrange(freq)

lieProp = lieProp[lieProp$lie==1,]

lieProp <-lieProp[order(lieProp$sub,lieProp$ses),]


deltaRT=dataBeh %>% group_by(sub,ses,lie) %>%
  summarise(meanRT = mean(RT))

# beta change along the sessions within ROIs

ROIs=c('hippocampus','vmPFC','dlPFC','dacc','BA6','BA9','BA21','BA24','BA23','BA13','BA32','BA47','OFC')

sesno=3

ddm=read_csv('/Users/orlacamus/Desktop/projects/dishonesty/fMRI/dishonesty_behav/DDM-related/fitting_code/results_tddm/fits_all_tddm.csv')
ddm=ddm[ddm$sub_nr %in% subL,]



sesno=3
for (sesno in c(1,2,3)){
  temp=data.frame(ddm)
  temp=data.frame(MT)
  for (i in c(1:length(ROIs))){
    r=read_excel("/Users/orlacamus/Desktop/projects/dishonesty/fMRI/dishonesty_fMRI/2.ROIextraction/ROI_1b.xlsx",sheet=ROIs[i])
    colnames(r)=c('subjno','1','2','3','4','5','6','7','8','9')
    r=r[r$subjno%in% subL,]
    temp[ROIs[i]]=r[,sesno*3+1]
  }
  col='#70309f'
  for (d in c('drate_m','drate_c')){
#  for (d in c('MAD','AD','AUC')){ 
    l=d
    if (d=='drate_m'){
      col='#70309f'
      l='drift rate of reward'
    }
    if (d=='drate_c'){
      col='#578737'
      l='drift rate of consistency'
    }
   
#  for (d in c('beta_M','beta_C')){
    for (roi in ROIs){

      corr=cor.test(temp[,d],temp[,roi])
      if (corr$p.value<0.05){
        print(roi)
        print(d)
        f=ggplot(data=temp,aes(x=temp[,d],y=temp[,roi]))+
          geom_point(color='black',size=2)+
          geom_smooth(method='lm',color='black',se=FALSE)+
          scale_y_continuous(name='')+
          scale_x_continuous(name='')+
          stat_cor(method = "pearson",label.x.npc = 0.2,label.y.npc=0.2,size=5,color='black')+
          theme(axis.text.x = element_text(size=26),
                axis.text.y = element_text(size=26),
                axis.title=element_text(size=1),
                plot.title = element_text(size=1,hjust = 0.5),
                panel.background = element_rect(fill = "white"),
                axis.line = element_line(colour = "black"))
        ggsave(file=paste0('/Users/orlacamus/Downloads/',roi,'-',d,"-GLM1b-lie-hon.png"), plot=f, width=4, height=4)
      }
    }
  }
}


# correlation between DDM parameters and betas in session 3
temp_lie=data.frame(ddm)
temp_hon=data.frame(ddm)
ROIs=c('BA6','dlPFC','BA23',
       'BA32','BA24','OFC','ventral_striatum','vmPFC')
sesno=3

for (i in c(1:length(ROIs))){
  r=read_excel("/Users/orlacamus/Desktop/projects/dishonesty/fMRI/dishonesty_fMRI/2.ROIextraction/ROI_1b.xlsx",sheet=ROIs[i])
  colnames(r)=c('subjno','1','2','3','4','5','6','7','8','9')
  r=r[r$subjno%in% subL,]
  temp_lie[ROIs[i]]=r[,sesno*3-1]
  temp_hon[ROIs[i]]=r[,sesno*3]
}
col='#70309f'
for (d in c('drate_m','drate_c')){
  
  l=d
  if (d=='drate_m'){
    col='#70309f'
    l='drift rate of reward'
  }
  if (d=='drate_c'){
    col='#578737'
    l='drift rate of consistency'
  }
  
  ROIs=c('BA24')
  for (roi in ROIs){
    
    corr_lie=cor.test(temp_lie[,d],temp_lie[,roi])
    corr_hon=cor.test(temp_hon[,d],temp_hon[,roi])
    temp_lie$condition='lie'
    temp_hon$condition='hon'
    temp=rbind(temp_lie,temp_hon)
    print(corr_lie)
    print(corr_hon)
    #if (corr_lie$p.value<0.05|corr_hon$p.value<0.05){
    #  print(roi)
    #  print(d)
      
      f=ggplot()+
        geom_point(data=temp_lie,aes(x=temp_lie[,d],y=temp_lie[,roi]),color='dark blue',size=2)+
        geom_smooth(data=temp_lie,aes(x=temp_lie[,d],y=temp_lie[,roi]),method='lm',color='dark blue',se=FALSE)+
        geom_point(data=temp_hon,aes(x=temp_hon[,d],y=temp_hon[,roi]),color='red',size=2)+
        geom_smooth(data=temp_hon,aes(x=temp_hon[,d],y=temp_hon[,roi]),method='lm',color='red',se=FALSE)+
        scale_y_continuous(name='')+
        scale_x_continuous(name='')+
        stat_cor(data=temp_lie,aes(x=temp_lie[,d],y=temp_lie[,roi]),method = "pearson",label.x.npc = 0.4,label.y.npc=0.2,size=5,color='dark blue')+
        stat_cor(data=temp_hon,aes(x=temp_hon[,d],y=temp_hon[,roi]),method = "pearson",label.x.npc = 0.4,label.y.npc=0.1,size=5,color='red')+
        theme(axis.text.x = element_text(size=26),
              axis.text.y = element_text(size=26),
              axis.title=element_text(size=1),
              plot.title = element_text(size=1,hjust = 0.5),
              panel.background = element_rect(fill = "white"),
              axis.line = element_line(colour = "black"))
      #ggsave(file=paste0('/Users/orlacamus/Downloads/',roi,'-',d,"-GLM1b-combine.png"), plot=f, width=4, height=4)
    }
  }





# mediation: drift rate of reward --> AUC --> beta in ROIs

library(mediation) #Mediation package
library(rockchalk) #Graphing simple slopes; moderation
library(multilevel) #Sobel Test
library(bda) #Another Sobel Test option
library(gvlma) #Testing Model Assumptions 
library(stargazer) #Handy regression tables


MT$drate_m=ddm$drate_m
MT$OFC=temp_lie$OFC
#lie:AUC
fitM <- lm(AUC ~ drate_m,data=MT) #IV on M; Hours since dawn predicting coffee consumption
fitY <- lm(OFC ~ AUC + drate_m,data=MT) #IV and M on DV; Hours since dawn and coffee predicting wakefulness
summary(fitM)
summary(fitY)
gvlma(fitM) #data is positively skewed; could log transform (see Chap. 10 on assumptions)
gvlma(fitY)
fitMed <- mediate(fitM, fitY, treat="drate_m", mediator="AUC")
summary(fitMed)
plot(fitMed)
#Bootstrap
fitMedBoot <- mediate(fitM, fitY, boot=T,  treat="drate_m", mediator="AUC")
summary(fitMedBoot)




# questionnaire

dq <- fread("/users/orlacamus/desktop/projects/dishonesty/fMRI/dishonesty_behav/RD_questionnaire_summary.csv",fill=TRUE)

subL = c(104,105,108,109,110,111,112,113,114,115,117,120,121,122,124,125,126,127,130,131,133,134,135,137,138,139,140)

ques = dq[dq$subno %in% subL,]


lieProp <- dataBeh %>% dplyr::group_by(sub) %>%
  dplyr::summarise(lierate=mean(lie)) 
lieProp = lieProp[lieProp$lie==1,]
lieprop = lieProp[order(lieProp$sub),]


temp=ques
temp$AUC=MT$AUC
f=ggplot(data=temp,aes(x=IRI,y=AUC))+
  
  geom_smooth(method='lm',color='#AFE1AF',size=2,fill='#AFE1AF')+
  geom_point(size=3,color='#50C878')+
  scale_y_continuous(name='AUC in session 3')+
  scale_x_continuous(name='IRI')+
  stat_cor(method = "pearson",label.x.npc = "left",size=8)+
  theme(axis.text.x = element_text(size=20),
        axis.text.y = element_text(size=20),
        axis.title=element_text(size=20),
        plot.title = element_text(size=20,hjust = 0.5),
        panel.background = element_rect(fill = "white"),
        axis.line = element_line(colour = "black"))
f
ggsave(file=paste0("/Users/orlacamus/Downloads/IRI-AUC.svg"), plot=f, width=6, height=6)


temp=ques
temp$freq=lieprop$freq
f=ggplot(data=temp,aes(x=SVO,y=freq))+
  
  geom_smooth(method='lm',color='#FFEA00',size=2,fill='#FFEA00')+
  geom_point(size=3,color='#FDDA0D')+
  scale_y_continuous(name='total dishonesty rate')+
  scale_x_continuous(name='SVO')+
  stat_cor(method = "pearson",label.x.npc = "left",size=8)+
  theme(axis.text.x = element_text(size=20),
        axis.text.y = element_text(size=20),
        axis.title=element_text(size=20),
        plot.title = element_text(size=20,hjust = 0.5),
        panel.background = element_rect(fill = "white"),
        axis.line = element_line(colour = "black"))
f
ggsave(file=paste0("/Users/orlacamus/Downloads/SVO-lierate.svg"), plot=f, width=6, height=6)


