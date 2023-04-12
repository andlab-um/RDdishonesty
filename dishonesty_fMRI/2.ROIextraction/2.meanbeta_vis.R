# Dishonesty
# mean beta extraction visualization
# Xinyi Julia Xu, 2022.11.11
# xinyi_x@outlook.com

rm(list=ls())
setwd("/Users/orlacamus/Desktop/projects/dishonesty/fMRI/dishonesty_fMRI/2.ROIextraction")
# Install required packages if necessary:
want = c("data.table", "lme4", "Matrix","ez","ggplot2","dplyr",'ggpubr','patchwork','tidyr',' reticulate','tidyverse','readxl')
have = want %in% rownames(installed.packages())
if ( any(!have) ) { install.packages( want[!have] ) }
# Now load them all
lapply(want, require, character.only = TRUE)
library(reticulate)
library(svglite)

subL=c(104,105,108,109,110,111,112,113,114,115,117,120,121,122,124,125,126,127,130,131,133,134,135,137,138,139,140)

ROIs=c('hippocampus','vmPFC','mPFC','ventral_striatum','rDLPFC','dlPFC','reward_z10','reward_z5',
       'rewant_z10','rewant_z5','moral_z10','moral_z5','monrew_z10','monrew_z5','memory_z10','memory_z5',
       'maintenance_z10','maintenance_z5','errors_z10','errors_z5','consis_z10','consis_z5','conf_z10','conf_z5','cc_z10','cc_z5','lDLPFC','dacc',
       'BA6','BA9','BA21','BA24','BA23','BA13','BA32','BA47','BAHip','OFC')

ROIs=c('BA6','dlPFC','BA23',
       'BA32','BA24','OFC','ventral_striatum')

for (i in c(1:length(ROIs))){
  t=read_excel("ROI_1b.xlsx",sheet=ROIs[i])
  
  
  colnames(t)=c('subjno','1','2','3','4','5','6','7','8','9')
  
  temp_lie=data.frame(t$subjno,t$`1`,t$`4`,t$`7`)########
  colnames(temp_lie)=c('subjno','1','2','3')
  
  temp_hon=data.frame(t$subjno,t$`2`,t$`5`,t$`8`)########
  colnames(temp_hon)=c('subjno','1','2','3')
  
  
  file_lie = temp_lie[temp_lie$subjno %in% subL,]
  file_lie=temp_lie
  data_lie=file_lie %>% pivot_longer(cols = -"subjno")
  data_lie$condition='dishonesty'
  
  file_hon = temp_hon[temp_hon$subjno %in% subL,]
  file_hon=temp_hon
  data_hon=file_hon %>% pivot_longer(cols = -"subjno")
  data_hon$condition='honesty'
  
  print(ROIs[i])
  print(t.test(file_lie$`1`,file_hon$`1`,paired=TRUE)$p.value)
  print(t.test(file_lie$`2`,file_hon$`2`,paired=TRUE)$p.value)
  print(t.test(file_lie$`3`,file_hon$`3`,paired=TRUE)$p.value)
  
  data=rbind(data_lie,data_hon)
  
  
  colnames(data)=c('subjno','session','beta','condition')
  data$session=as.factor(data$session)

  #out=lmer(beta~session+(1|subjno),data=data)
  #s=summary(out)
  #if (coef(s)['session',5]<0.05){
  #  print(ROIs[i])
  #  print(coef(s)['session',1])
  #}
  agg <- data %>% group_by(session,condition) %>% dplyr::summarise(mean = mean(beta),sd=sd(beta),n = n(),se=sd(beta)/sqrt(n))
  
  f=ggplot(data = agg, aes(x = factor(session), y=mean,group=condition)) + 
    #geom_jitter(data = data, aes(x = factor(session), y=beta),size=2,width = 0.15, shape=21, fill="#BC3C29FF",colour="#BC3C29FF",alpha=0.3) +
    geom_line(aes(color=condition),lwd= 1)  + 
    geom_point(data = agg, aes(x = factor(session), y=mean, group=condition,color=condition),size=5, shape=16,alpha=1) +
    scale_fill_manual(values=c("dark blue","#c9342c")) +
    scale_color_manual(values=c("dark blue","#c9342c")) +
    geom_errorbar(width=0.2, alpha=0.8,size=1,data = agg,aes(ymin=mean-se, ymax=mean+se,colour=condition),position = position_nudge(x = 0)) +
    scale_x_discrete(name='session') + # have tick marks for each session
    scale_y_continuous(name='Mean activity \n(beta value)') + 
    ggtitle(ROIs[i]) +
    theme(axis.text.x = element_text(size=25),
          axis.text.y = element_text(size=25),
          axis.title=element_text(size=25),
          plot.title = element_text(size=10,hjust = 0.5),
          panel.background = element_rect(fill = "white"),
          axis.line = element_line(colour = "black"))
  
  ggsave(file=paste0('/Users/orlacamus/Downloads/',ROIs[i],".svg"), plot=f, width=6, height=6)
  
  
} 


ROIs=c('BA6',"dlPFC",'BA23','BA32','BA24','OFC')
#p+plot_layout(ncol = 6)

### GLM2: each session x lie/honest
for (i in c(1:length(ROIs))){
  t=read_excel("ROI_1b.xlsx",sheet=ROIs[i])
  print(ROIs[i])
  colnames(t)=c('subjno','1','2','3','4','5','6','7','8','9')
  ses1=t.test(t$`1`,t$`2`,paired = TRUE)
  ses2=t.test(t$`4`,t$`5`,paired = TRUE)
  ses3=t.test(t$`7`,t$`8`,paired = TRUE)
  test_lie=t.test(t$`7`,t$`1`,paired = TRUE)
  test_hon=t.test(t$`8`,t$`2`,paired = TRUE)
  #print(ses1$p.value)
  #print(ses2$p.value)
  #print(ses3$p.value)
  #print(test_lie$p.value)
  print(test_lie)
  print(test_hon)
  
  temp_hon=data.frame(t$subjno,t$`2`,t$`5`,t$`8`)########
  colnames(temp_hon)=c('subjno','1','2','3')
  temp_lie=data.frame(t$subjno,t$`1`,t$`4`,t$`7`)########
  colnames(temp_lie)=c('subjno','1','2','3')
  
  
  
  data_lie=temp_lie %>% pivot_longer(cols = -"subjno")
  colnames(data_lie)=c('subjno','session','beta')
  data_lie$session=as.factor(data_lie$session)
  
  data_hon=temp_hon %>% pivot_longer(cols = -"subjno")
  colnames(data_hon)=c('subjno','session','beta')
  data_hon$session=as.numeric(data_hon$session)
  
  #out=lm(beta~session,data=data_lie)
  #s=summary(out)
  #print(s)
  
}



