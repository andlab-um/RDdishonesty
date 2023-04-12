# Dishonesty
# DDM comparison
# Xinyi Julia Xu, 2022.11.10
# xinyi_x@outlook.com

rm(list=ls())
setwd("~/Desktop/projects/dishonesty/fMRI/dishonesty_behav")

# function summarySE is in package Rmisc, but Rmisc contains plyr which conflicts with dplyr
# https://stackoverflow.com/questions/26923862/why-are-my-dplyr-group-by-summarize-not-working-properly-name-collision-with
# difference between summarySEwithin & summarise:  idvar is used to normalize rather than groupby 
# if want to use plyr, import before dplyr


# Install required packages if necessary:
want = c("data.table", "lme4", "Matrix", "stargazer","coxme","survival","bdsmatrix","ez","ggplot2","lmerTest","dplyr",'yarrr','gridExtra','ggsignif')
have = want %in% rownames(installed.packages())
if ( any(!have) ) { install.packages( want[!have] ) }
# Now load them all
lapply(want, require, character.only = TRUE)



subL = c(104,105,108,109,110,111,112,113,114,115,117,120,121,122,124,125,126,127,130,131,133,134,135,137,138,139,140)



# Read the data
mddm <- fread("DDM-related/fitting_code/results_mddm/fits_all_mddm.csv")
tddm <- fread("DDM-related/fitting_code/results_tddm/fits_all_tddm.csv")
sddm <- fread("DDM-related/fitting_code/results_sddm/fits_all_sddm.csv")
latddm <- fread("DDM-related/fitting_code/results_latddm/fits_all_latddm.csv")

mddm = mddm[mddm$sub %in% subL,]
tddm = tddm[tddm$sub %in% subL,]
sddm = sddm[sddm$sub %in% subL,]
latddm = latddm[latddm$sub %in% subL,]
BIC=data.frame(unique(mddm$sub))
BIC$mddm=mddm$BIC
BIC$tddm=tddm$BIC
BIC$sddm=sddm$BIC
BIC$latddm=latddm$BIC

colnames(BIC)[1]='subj'
BIC$diff=BIC$tddm-BIC$latddm
BIC$better=0
for (i in c(1:length(BIC$diff))){
  
  if (BIC$diff[i]>0){
    BIC$better[i]=1
  }
  if (BIC$diff[i]<0){
    BIC$better[i]=-1
  }
  
}

t.test(BIC$tddm,BIC$mddm,paired = TRUE)
t.test(BIC$tddm,BIC$sddm,paired = TRUE)
t.test(BIC$tddm,BIC$latddm,paired = TRUE)
mean(BIC$tddm)
std(BIC$tddm)
sum(BIC$tddm)
max(BIC$tddm)
min(BIC$tddm)

mean(BIC$mddm)
std(BIC$mddm)
sum(BIC$mddm)
max(BIC$mddm)
min(BIC$mddm)

mean(BIC$latddm)
std(BIC$latddm)
sum(BIC$latddm)
max(BIC$latddm)
min(BIC$latddm)


mean(BIC$sddm)
std(BIC$sddm)
sum(BIC$sddm)
max(BIC$sddm)
min(BIC$sddm)


cor.test(tddm$drate_m,tddm$drate_c,method = 'spearman')
cor.test(tddm$drate_m,tddm$drate_c)
cor.test(tddm$drate_m,tddm$lat_m,method = 'spearman')
cor.test(tddm$drate_m,tddm$lat_c,method = 'spearman')

cor.test(tddm$drate_c,tddm$lat_m,method = 'spearman')
cor.test(tddm$drate_c,tddm$lat_c,method = 'spearman')
cor.test(tddm$lat_m,tddm$lat_c,method = 'spearman')


# BIC

scale_factor=4/3
long_BIC=BIC %>% pivot_longer(cols = -"subj")
agg=long_BIC %>% group_by(name) %>% summarise(mean = mean(value),sd=sd(value),n = n(),se=sd(value)/sqrt(n))

f_BIC = ggplot(data = long_BIC, aes(x = name, y = value,fill=name) ) + 
  
  geom_violin(color='white')+
  geom_boxplot(width = 0.2) +
#  geom_point(size=scale_factor*2, shape=19, fill="#8faadc",colour="#8faadc") +
  scale_fill_manual(name = "subject number", values=c('#a5a5a580',"#a5a5a580",'#a5a5a580',"#307abf")) +
  scale_x_discrete(name='DDM candidates') + # have tick marks for each session
  scale_y_continuous(name='BIC') + 
  coord_flip()+
#  ggtitle("BIC difference across subjects") +
 #geom_signif(comparisons=list(c(1,4)),textsize=scale_factor*6,vjust=scale_factor*0.3,
 #            annotation=c('***'),
 #            aes(y_position=2500)) +
 #geom_signif(comparisons=list(c(2,4)),textsize=scale_factor*6,vjust=scale_factor*0.3,
 #            annotation=c('***'),
 #            aes(y_position=2750)) +
 #geom_signif(comparisons=list(c(3,4)),textsize=scale_factor*6,vjust=scale_factor*0.3,
 #            annotation=c('***'),
 #            aes(y_position=3000)) +
  
  theme(axis.text.x = element_text(size=25),
        axis.text.y = element_text(size=25),
        axis.title=element_text(size=25),
        plot.title = element_text(size=25,hjust = 0.5),
        panel.background = element_rect(fill = "white"),
        axis.line = element_line(colour = "black")) 
f_BIC
ggsave('/Users/orlacamus/Downloads/ddm_comparison.svg',width = 10,height = 6)


BIC_order=BIC[order(BIC$subj, increasing = TRUE)]
f_BIC = ggplot(data = BIC, aes(x = reorder(subj,diff), y = diff,fill=as.factor(better)) ) + 
  geom_bar(stat="identity",width = 0.8) +
  scale_fill_manual(name = "subject number", values=c('#307abf',"#a5a5a5")) +
  scale_x_discrete(name='subject number') + # have tick marks for each session
  scale_y_continuous(name='BIC difference (tDDM - latDDM)') + 
  ggtitle("BIC difference across subjects") +
  
  
  theme(axis.text.x = element_text(size=20),
        axis.text.y = element_text(size=25),
        axis.title=element_text(size=35),
        plot.title = element_text(size=35,hjust = 0.5),
        panel.background = element_rect(fill = "white"),
        axis.line = element_line(colour = "black")) 


f_BIC

ggsave('/Users/orlacamus/Downloads/ddm_comparison.svg',width = 16,height = 8)


# parameters

dataDDM=tddm



t.test(dataDDM$drate_m,dataDDM$drate_c,paired = TRUE)
t.test(dataDDM$lat_m,dataDDM$lat_c,paired = TRUE)
mean(dataDDM$drate_c)
sd(dataDDM$drate_c)
mean(dataDDM$lat_m)
sd(dataDDM$lat_m)
mean(dataDDM$lat_c)
sd(dataDDM$lat_c)
t.test(dataDDM$drate_m,mu=0)
t.test(dataDDM$drate_c,mu=0)
t.test(dataDDM$lat_m,mu=0)
t.test(dataDDM$lat_c,mu=0)
plot(dataDDM$drate_m,dataDDM$drate_c)

dataDDM
tempdata=dataDDM %>% rename(consistency=drate_c,reward=drate_m) %>% select(reward,consistency,sub_nr) %>% pivot_longer(cols = -"sub_nr")
colnames(tempdata)=c('subjno','drate','value')


f_drate=pirateplot(value ~ drate, data = tempdata,
                     ylab = '',xlab='',
                     sortx = "alphabetical",
                     inf.f.col = c("#578737","#70309f"), 
                     inf.b.col = "black",
                     cex.axis = 2,
                     cex.lab =  2,
                     cex.names = 2,
                     point.cex = 1.8,
                     bar.f.o = .5, # Bar
                     bar.f.col = c(gray(.8),gray(.8)), # bar filling color
                     bean.f.o = 0,
                     bean.b.o = 0)

segments(y0=dataDDM$drate_c,x0=1,
         y1=dataDDM$drate_m,x1=2,col=gray(0,0.1))


f_drate <- recordPlot() # p contains all plotting information


svg("/Users/orlacamus/Downloads/drate.svg",width = 4, height = 4)
f_drate
dev.off()




tempdata=dataDDM %>% rename(consistency=lat_c,reward=lat_m) %>% select(reward,consistency,sub_nr) %>% pivot_longer(cols = -"sub_nr")
colnames(tempdata)=c('subjno','lat','value')

f_lat=pirateplot(value ~ lat, data = tempdata,
                 ylab = '',xlab='',
                 inf.f.col = c("#578737","#70309f"), 
                 inf.b.col = "black",
                 cex.axis = 2,
                 cex.lab =  2,
                 cex.names = 2,
                 point.cex = 1.5,
                 bar.f.o = .5, # Bar
                 bar.f.col = c(gray(.8),gray(.8)), # bar filling color
                 bean.f.o = 0,
                 bean.b.o = 0)
segments(y0=dataDDM$lat_c,x0=1,
        y1=dataDDM$lat_m,x1=2,col=gray(0,0.1))


f_drate <- recordPlot() # p contains all plotting information


svg("/Users/orlacamus/Downloads/drate.svg",width = 4, height = 4)
f_drate
dev.off()


f=ggplot()+
  geom_point(aes(x=drate_c,y=drate_m) ,data = tddm,color='#f9c007',size=4)+
  scale_x_continuous(name='drift rate of consistency') + # have tick marks for each session
  scale_y_continuous(name='drift rate of money') + 
  theme_light(base_size = 25)
ggsave("/Users/orlacamus/Downloads/parameters.svg",width = 6, height = 5)
f



