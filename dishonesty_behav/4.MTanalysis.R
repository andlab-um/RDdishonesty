# Dishonesty
# Final Mouse tracking analysis code
# Xinyi Julia Xu, 2021.12.04
# xinyi_x@outlook.com
   
---------------------------------------------
## Preparations
    
require(data.table)
require(lme4)
require(stargazer)
require(coxme)
require(ez)    
# Load libraries
  
library(abind)
library(mousetrap)
library(ggplot2)
library(dplyr)
library(readbulk)
library(afex)

# Custom ggplot2 theme

theme_set(theme_classic()+ 
            theme(
              axis.line = element_line(colour = "black"),
              axis.ticks = element_line(colour = "black"),
              axis.text = element_text(colour = "black"),
              panel.background = element_rect(fill = "white"),
              panel.border = element_blank()
            ))
rm(list=ls())
options(width=90)

# Import dataset
setwd("~/Desktop/projects/dishonesty/fMRI/dishonesty_behav/4.temporal_analysis")
mt <- read.csv("/Users/orlacamus/Desktop/projects/dishonesty/fMRI/dishonesty_behav/mt_data.csv")
sub = c(104,105,108,109,110,111,112,113,114,115,117,120,121,122,124,125,126,127,130,131,133,134,135,137,138,139,140)#27
mt <- mt[mt$sub %in% sub,]
mt_data <- mt_import_wide(mt,xpos_label = "X",
                     ypos_label = "Y",
                     timestamps_label = "T",
                     pos_sep = "_")

############# Preprocessing #########################
# Spatial transformations: Remap trajectories

mt_data <- mt_remap_symmetric(mt_data)

# Spatial normalization

mt_data <- mt_align_start_end(mt_data)


# Time-normalize trajectories

mt_data <- mt_time_normalize(mt_data) 

# Calculate measures

mt_data <- mt_measures(mt_data)





# Export the measures and time-normalized trajectories

write.csv(mt_data$measures, file = "Measures_dishonesty_fMRI.csv")
write.csv(mt_data$tn_trajectories, file = "tn_trajectories.csv",fileEncoding = "utf-8")
#write.csv(mt_data$data, file = "mt_data-output.csv",fileEncoding = 'utf-8')



################## save the data as 'mt_data.RData' #############
################## read the data as 'mt_data.RData' #############
################## Analysis:  #################################

p <- list()

for (i in c(1,2,3)){
  temp=mt_subset(mt_data,ses==i)
  
  p[[i]]=mt_plot_aggregate(temp, use="tn_trajectories",
                    x="steps", y="xpos", color="lie",
                    subject_id="sub", points=TRUE)+
    scale_color_manual(values=c("red","dark blue"))+
    scale_x_continuous(name='') +
    scale_y_continuous(name='')+
    theme(axis.text.x = element_text(size=20),
          axis.text.y = element_text(size=20),
          axis.title=element_text(size=20),
          plot.title = element_text(size=15,hjust = 0.5),
          panel.background = element_rect(fill = "white"),
          axis.line = element_line(colour = "black")) 
    
  
  # Aggregate time-normalized trajectories per condition
  # separately per participant
  av_tn_trajectories <- mt_aggregate_per_subject(temp,
                                                 use="tn_trajectories", use2_variables="lie",
                                                 subject_id="sub")
  
  # Paired t-tests on coordinates
  
  xpos_t_tests <- 
    with(av_tn_trajectories,
         sapply(unique(steps),function(i){
           t.test(xpos[lie==1 & steps==i],
                  xpos[lie==0 & steps==i],
                  paired = TRUE)$p.value})
    )
  # Retrieve all significant t-tests
  
  #print(mean(which(xpos_t_tests<.05),na.rm=TRUE))
  print(which(xpos_t_tests<.01),na.rm=TRUE)
  mean(which(xpos_t_tests<.01),na.rm=TRUE)
  
  
  
  
  
  
  agg_mad <- mt_aggregate_per_subject(temp, 
                                      use_variables="MAD", use2_variables="lie",
                                      subject_id="sub")
  
  t=t.test(agg_mad[agg_mad$lie==1,]$MAD,agg_mad[agg_mad$lie==0,]$MAD,paired = TRUE)
  print(t[["p.value"]])
  #print(mean(agg_mad$MAD))
  
  #——————————————
  agg_ad <- mt_aggregate_per_subject(temp, 
                                      use_variables="AD", use2_variables="lie",
                                      subject_id="sub")
  
  t=t.test(agg_ad[agg_ad$lie==1,]$AD,agg_ad[agg_ad$lie==0,]$AD,paired = TRUE)
  print(t[["p.value"]])
  #print(mean(agg_mad$MAD))
  
  #——————————
  agg_auc <- mt_aggregate_per_subject(temp, 
                                      use_variables="AUC", use2_variables="lie",
                                      subject_id="sub")
  
  t=t.test(agg_auc[agg_auc$lie==1,]$AUC,agg_auc[agg_auc$lie==0,]$AUC,paired = TRUE)
  print(t[["p.value"]])
  #print(mean(agg_mad$MAD))

}
library(gridExtra)
do.call(grid.arrange,p)
grid.arrange(grobs=p,ncol=3)


#===================================================
measures=data.frame()

for (i in c(1,2,3)){
  temp = mt_subset(mt_data, mt_data$data[['ses']] %in% c(i), check = "measures")
  temp=cbind(temp$measures,temp$data$lie,temp$data$sub)
  temp=temp[,c('MAD','AD','AUC','temp$data$lie','temp$data$sub')]
  temp=cbind(temp,rep(i,nrow(temp)))
  measures=rbind(measures,temp)
  
  
}
colnames(measures) <- c("MAD", "AD", "AUC","lie","sub","ses")





agg_measures <- measures %>% group_by(sub,ses,lie) %>% 
  summarise(n = n(),
            mad = mean(MAD),
            ad = mean(AD),
            auc = mean(AUC),
            mad_se = sd(MAD) / sqrt(n),
            ad_se = sd(AD) / sqrt(n),
            auc_se = sd(AUC) / sqrt(n))



agg_measures2<- agg_measures %>% group_by(ses,lie) %>% 
  summarise(n = n(),
            MAD = mean(mad),
            AD = mean(ad),
            AUC = mean(auc),
            mad_se = sd(mad) / sqrt(n),
            ad_se = sd(ad) / sqrt(n),
            auc_se = sd(auc) / sqrt(n))

agg_measures2=cbind(agg_measures2,rep(1,nrow(agg_measures2)),rep(1,nrow(agg_measures2)))

agg_measures2$...10=0.5
agg_measures2$...11=0.5


f_MAD = ggplot(data = agg_measures2, aes(x = ses, y = MAD, fill=as.factor(lie)) ) + 
#f_MAD = ggplot(data = agg_measures2, aes(x = ses, y = MAD, fill=as.factor(lie),alpha=as.factor(...10)) ) + 
  geom_bar(stat="identity",position='dodge')+
  geom_errorbar(position=position_dodge(.9), aes(ymin=MAD-mad_se, ymax=MAD+mad_se),width=0, size=1) +
  scale_x_continuous(name='',breaks=seq(1,3,by=1)) + # have tick marks for each session
  #scale_y_continuous(name='Proportion of lying',limits = c(0, 1), breaks=seq(0, 1, by = 0.1)) + 
  scale_fill_manual(values=c("#c9342c", "#2f5597"))+
  scale_alpha_manual(values = c("0.5"=0.5, "1"=1), guide='none')+
  theme(axis.text.x = element_text(size=20),
        axis.text.y = element_text(size=20),
        axis.title=element_text(size=20),
        plot.title = element_text(size=20,hjust = 0.5),
        panel.background = element_rect(fill = "white"),
        axis.line = element_line(colour = "black")) 


print(f_MAD)
ggsave('/Users/orlacamus/Downloads/mad.svg',width = 4.5,height = 4)

f_AD = ggplot(data = agg_measures2, aes(x = ses, y = AD, fill=as.factor(lie))) + 
  geom_bar(stat="identity",position='dodge')+
  geom_errorbar(position=position_dodge(.9), aes(ymin=AD-ad_se, ymax=AD+ad_se),width=0, size=1) +
  scale_x_continuous(name='',breaks=seq(1,3,by=1)) + # have tick marks for each session
  #scale_y_continuous(name='Proportion of lying',limits = c(0, 1), breaks=seq(0, 1, by = 0.1)) + 
  scale_fill_manual(values=c("#c9342c", "#2f5597"))+
  scale_alpha_manual(values = c("0.5"=0.5, "1"=1), guide='none')+
  theme(axis.text.x = element_text(size=20),
        axis.text.y = element_text(size=20),
        axis.title=element_text(size=20),
        plot.title = element_text(size=20,hjust = 0.5),
        panel.background = element_rect(fill = "white"),
        axis.line = element_line(colour = "black")) 


print(f_AD)
ggsave('/Users/orlacamus/Downloads/ad.svg',width = 5,height = 4)

f_AUC = ggplot(data = agg_measures2, aes(x = ses, y = AUC, fill=as.factor(lie)) ) + 
  geom_bar(stat="identity",position='dodge')+
  geom_errorbar(position=position_dodge(.9), aes(ymin=AUC-auc_se, ymax=AUC+auc_se),width=0, size=1) +
  scale_x_continuous(name='',breaks=seq(1,3,by=1)) + # have tick marks for each session
  #scale_y_continuous(name='Proportion of lying',limits = c(0, 1), breaks=seq(0, 1, by = 0.1)) + 
  scale_fill_manual(values=c("#c9342c", "#2f5597"))+
  scale_alpha_manual(values = c("0.5"=0.5, "1"=1), guide='none')+
  theme(axis.text.x = element_text(size=20),
        axis.text.y = element_text(size=20),
        axis.title=element_text(size=20),
        plot.title = element_text(size=20,hjust = 0.5),
        panel.background = element_rect(fill = "white"),
        axis.line = element_line(colour = "black")) 


print(f_AUC)


ggsave('/Users/orlacamus/Downloads/auc.svg',width = 4.5,height = 4)



# Aggregate trajectories
tot_data=mt_data
mt_plot_aggregate(mt_data, use="tn_trajectories",
                  x="xpos",y="ypos",
                  color="lie",subject_id="sub")+
  scale_color_manual(values=c("darkorange","steelblue"))
 

mt_plot_aggregate(tot_data, use="tn_trajectories",
                  x="xpos",y="ypos",
                  color="ses",subject_id="sub")+
  scale_color_manual(values=c("darkorange","steelblue",'black'))

# Aggregate analyses: block level
# Aggregate MAD/AD/AUC/RT values per participant and condition




# Create data.frame that contains the trial variables and mouse-tracking indices

results <- merge(mt_data$data, mt_data$measures, by="mt_id")


# Run linear mixed model with Block as a fixed effect and a random intercept and slope per participant
mixed(MAD ~ (1+ses|sub)+ses, data=results)

mixed(RT.x ~ (1+ses|sub) +ses, data=results)
mixed(AUC ~ ses+(1|sub), data=results)


# Aggregate trajectories: correct level
# Figure2 correct_step_trajectories
mt_plot_aggregate(mt_data, use="tn_trajectories",
                  x="steps", y="xpos", color="lie",
                  subject_id="sub", points=TRUE)+
  scale_color_manual(values=c("darkorange","steelblue"))

# Aggregate time-normalized trajectories per condition
# separately per participant
av_tn_trajectories <- mt_aggregate_per_subject(tot_data,
                                               use="tn_trajectories", use2_variables="lie",
                                               subject_id="sub")


# Paired t-tests on coordinates
xpos_t_tests <- 
  with(av_tn_trajectories,
       sapply(unique(steps),function(i){
         t.test(xpos[lie==1 & steps==i],
                xpos[lie==0 & steps==i],
                paired = TRUE)$p.value})
  )
# Retrieve all significant t-tests
which(xpos_t_tests<.05)


