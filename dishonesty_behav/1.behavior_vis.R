# Dishonesty
# Behavioral results
# Xinyi Julia Xu, 2022.11.13
# xinyi_x@outlook.com

rm(list=ls())
setwd("~/Desktop/projects/dishonesty/fMRI/dishonesty_behav")

# function summarySE is in package Rmisc, but Rmisc contains plyr which conflicts with dplyr
# https://stackoverflow.com/questions/26923862/why-are-my-dplyr-group-by-summarize-not-working-properly-name-collision-with
# difference between summarySEwithin & summarise:  idvar is used to normalize rather than groupby 
# if want to use plyr, import before dplyr


# Install required packages if necessary:
want = c("data.table", "lme4", "Matrix", "stargazer","coxme","survival","bdsmatrix","ez","ggplot2","lmerTest","dplyr",'yarrr','patchwork','ggsignif','ggExtra','quickpsy')
have = want %in% rownames(installed.packages())
if ( any(!have) ) { install.packages( want[!have] ) }
# Now load them all
lapply(want, require, character.only = TRUE)

# Read data
dt <- fread("/users/orlacamus/desktop/projects/dishonesty/fMRI/dishonesty_behav/behav_summary.csv")

a=which(colnames(dt)=='error-correct')
colnames(dt)[a] <- 'error.correct'


subL=c(104,105,108,109,110,111,112,113,114,115,117,120,121,122,124,125,126,127,130,131,133,134,135,137,138,139,140)

dt = dt[dt$sub %in% subL,]

dataBeh = dt[,c('sub',
                 'run',
                 'ses',
                 'ind',
                 'error.correct',
                 'former_diff',
                 'lie',
                 'RT')]


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
})


rm(want,have,dt)

# Lie rates

lieProp <- dataBeh %>% dplyr::group_by(sub,ses) %>%
  dplyr::summarise(lierate=mean(lie)) 
#=============================================================
lieProp <- dataBeh %>% dplyr::group_by(sub) %>%
  summarise(lierate=mean(lie)) 
lieProp = lieProp[lieProp$lie==1,]

mean(lieProp$lierate)
median(lieProp$lierate)
sd(lieProp$lierate)
# fig S1: lying rate of each subject

lieProp <- dataBeh %>% group_by(sub,lie) %>%
  summarise(cnt = n()) %>%
  mutate(freq = formattable::percent(cnt / sum(cnt))) %>%
  arrange(freq)

lieProp = lieProp[lieProp$lie==1,]
print(lieProp_stats <- lieProp %>% ungroup %>%
        summarise(mean = mean(freq),
                  sd= sd(freq),
                  median=median(freq)))




library(formattable)
row_no=nrow(lieProp)
lieProp[nrow(lieProp) + 1,1] = 107
lieProp[nrow(lieProp) + 1,1] = 119
lieProp[nrow(lieProp) + 1,1] = 128
lieProp[nrow(lieProp) + 1,1] = 132

lieProp[,2] = 1

for (r in c(1,2,3,4)){
  lieProp[row_no+r,3] = 0
  lieProp[row_no+r,4] = percent(0)
}



scale_factor=2
f_lieProp = ggplot(data = lieProp, aes(x = reorder(sub,freq), y = freq,fill=factor(ifelse(sub %in% c(106,118,123,136),"Highlighted","Normal"))) ) + 
  geom_bar(stat="identity",width = 0.8) +
  scale_fill_manual(name = "sub", values=c("grey50","#2f5597")) +
#  scale_fill_manual(name = "sub", values=c("#2f5597","#2f5597")) +
  scale_x_discrete(name='subject number') + # have tick marks for each session
  scale_y_continuous(name='Proportion of dishonesty',limits = c(0, 1), breaks=seq(0, 1, by = 0.1)) + 
  ggtitle("dishonesty rates across subjects") +
  
  
  theme(axis.text.x = element_text(size=scale_factor*20),
        axis.text.y = element_text(size=scale_factor*20),
        axis.title=element_text(size=scale_factor*30),
        plot.title = element_text(size=scale_factor*30,hjust = 0.5),
        panel.background = element_rect(fill = "white"),
        axis.line = element_line(colour = "black")) 

f_lieProp

ggsave('/Users/orlacamus/Downloads/lierate.svg',width=20,height=6,scale=scale_factor)
print(f_lieProp)
rm(lieProp)
#============================================================




# fig: psychometric curve
lieDist <- dataBeh %>% group_by(consis_diff, money_diff, lie) %>%
  dplyr::summarise(cnt = n()) %>%
  mutate(freq = formattable::percent(cnt / sum(cnt))) %>%
  arrange(freq)

lieDist=lieDist[lieDist$lie==1,]


###########
dataBeh[dataBeh$consis_diff>0,"consis"]=1
dataBeh[dataBeh$consis_diff<0,"consis"]=-1
dataBeh[dataBeh$consis_diff==0,"consis"]=0

lie_mon <- dataBeh %>% group_by(money_diff, consis,lie) %>%
  dplyr::summarise(cnt = n()) %>%
  mutate(freq = formattable::percent(cnt / sum(cnt))) %>%
  arrange(freq)
lie_mon=lie_mon[lie_mon$lie==1,]



# /////////////////////////////////////////////
pData <- ggplot(lie_mon[lie_mon$consis==0,], aes(x = money_diff, y = freq)) + 
  geom_point()
pData

#D77A61
FE9000

fit1 <- quickpsy(dataBeh[dataBeh$consis==1,], x=money_diff, k=lie,lapses=0.1,prob=0.425,fun = logistic_fun) 
fit2 <- quickpsy(dataBeh[dataBeh$consis==0,], x=money_diff, k=lie,lapses=0.2,fun = logistic_fun) 
fit3 <- quickpsy(dataBeh[dataBeh$consis==-1,], x=money_diff, k=lie,lapses=0.47,prob=0.25,fun = logistic_fun) 
p <- ggplot()+
  geom_point(data = fit1$avbootstrap, aes(x = money_diff, y = prob),color='#8faadc',alpha=0.1) +
  geom_point(data = fit1$averages, aes(x = money_diff, y = prob),color='#2f5597',size=3) +
  #geom_point(data = fit2$averages, aes(x = money_diff, y = prob)) +
  geom_point(data = fit3$avbootstrap, aes(x = money_diff, y = prob),color='#FE9000',alpha=0.1) +
  geom_point(data = fit3$averages, aes(x = money_diff, y = prob),color='#FE9000',size=3) +
  
  geom_line(data = fit1$curves, aes(x = x, y = y),color='#2f5597',size=1)+
  #geom_line(data = fit2$curves, aes(x = x, y = y))+
  geom_line(data = fit3$curves, aes(x = x, y = y),color='#FE9000',size=1)+
  geom_segment(data = fit1$thresholds, aes(x = thre, y = -0.05, xend = thre, yend = prob),color='#2f5597',size=1)+
  #geom_segment(data = fit2$thresholds, aes(x = thre, y = 0, xend = thre, yend = prob))+
  geom_segment(data = fit3$thresholds, aes(x = thre, y = -0.05, xend = thre, yend = prob),color='#FE9000',size=1)+
  scale_x_continuous(breaks=seq(-8, 8, 2),name = 'money difference (error - correct)')+
  scale_y_continuous(limits = c(-0.05, 1),breaks=seq(0,1,0.2),expand = c(0,0),name = 'probability of dishonesty')+
  theme(axis.text.x = element_text(size=20),
        axis.text.y = element_text(size=20),
        axis.title=element_text(size=20),
        plot.title = element_text(size=20,hjust = 0.5),
        panel.background = element_rect(fill = "white"),
        axis.line = element_line(colour = "black")) 
p


ggsave('/Users/orlacamus/Downloads/psychometric.svg',width=6,height=4)



f_psym<- ggplot(lie_mon, aes(x=money_diff,y=freq,group=consis)) +
  geom_point(aes(x=money_diff,y=freq,group=consis))+
  geom_smooth(aes(color=as.factor(consis)),method = 'loess')+
  scale_colour_manual(values = c("#8faadc", "#2f5597","black")) +
  scale_x_continuous(name='reward difference',breaks=-8:8) +
  theme(axis.text.x = element_text(size=14),
        axis.text.y = element_text(size=14),
        axis.title=element_text(size=20),
        plot.title = element_text(size=20,hjust = 0.5),
        panel.background = element_rect(fill = "white"),
        axis.line = element_line(colour = "black")) 

f_psym


aov(freq ~ consis + money_diff, data = lie_mon)
summary(aov)
lFit <- lm(freq ~ consis + money_diff, data = lie_mon)
summary(lFit)
confint(lFit,level = 0.95)
coef(lFit)


lFit <- glm(lie ~ consis_diff + money_diff, data = dataBeh,family = "binomial")
summary(lFit)
confint(lFit,level = 0.95)
coef(lFit)

rm(lie_mon)

#=============================================================
# fig: RT

#detach(package:plyr)
rt_perRun <- dataBeh %>% group_by(ses, sub) %>% 
  summarise(rt_temp = mean(RT),
            sd_temp = sd(RT),
            n_temp = n(),
            se_temp = sd_temp / sqrt(n_temp)) %>%
  group_by(ses) %>% 
  summarise(rt = mean(rt_temp),
            sd = sd(rt_temp),
            n = n(),
            se = sd / sqrt(n)) 

rt_perRun2 <- dataBeh %>% group_by(ses, sub) %>% 
  summarise(rt = mean(RT),
            sd = sd(RT),
            n = n(),
            se = sd / sqrt(n)) 


scale_factor=2
f_RTperRun = ggplot(data = rt_perRun2, aes(x = factor(ses), y = rt,group=sub) ) + 
  
  geom_line(colour="gray70",lwd= scale_factor*0.5,alpha=0.5)  + 
  geom_point(size=scale_factor*2, shape=19, fill="#8faadc",colour="#8faadc") +
  geom_point(size=scale_factor*6, shape=19, fill="#2f5597",colour="#2f5597",data = rt_perRun, aes(x = factor(ses), y = rt,group=1)) +
  geom_errorbar(width=0, size=scale_factor*1,data = rt_perRun,aes(ymin=rt-se, ymax=rt+se,group=1),colour="#2f5597") +
  scale_x_discrete(breaks=1:3,name='session') + # have tick marks for each session
  scale_y_continuous(name='reaction times') + 
#  geom_line(data = cbind(dataBeh, y.hat = predict(lFit)), aes(x = run, y = y.hat,group=sub), col="darkred", lwd = 1.5)+
  ggtitle("") +
  #geom_signif(comparisons=list(c(1,2),c(2,3)),
  #            annotation=c('*','***'),textsize=10,
  #            aes(y=3)) +
  geom_signif(comparisons=list(c(2,3)),textsize=scale_factor*6,vjust=scale_factor*0.3,
              annotation=c('**'),
              aes(y_position=2.6)) +
  geom_signif(comparisons=list(c(1,2)),textsize=scale_factor*6,vjust=scale_factor*0.3,
              annotation=c('**'),
              aes(y_position=2.6)) +
  geom_signif(comparisons=list(c(1,3)),textsize=scale_factor*6,vjust=scale_factor*0.3,
              annotation=c('***'),
              aes(y_position=2.8)) +
  theme(axis.text.x = element_text(size=scale_factor*20),
        axis.text.y = element_text(size=scale_factor*20),
        axis.title=element_text(size=scale_factor*20),
        plot.title = element_text(size=scale_factor*20,hjust = 0.5),
        panel.background = element_rect(fill = "white"),
        axis.line = element_line(colour = "black")) 



print(f_RTperRun)

ggsave('/Users/orlacamus/Downloads/rt-session.svg',width=3,height=3,scale=scale_factor)


# fig RT
rtLie <- dataBeh %>% group_by(lie, sub) %>% 
  summarise(rt_temp = mean(RT),
            sd_temp = sd(RT),
            n_temp= n(),
            se_temp = sd_temp / sqrt(n_temp)) %>%
  summarise(rt = mean(rt_temp),
            sd = sd(rt_temp),
            n = n(),
            se = sd / sqrt(n))
  
  

rtLie2 <- dataBeh %>% group_by(lie, sub) %>% 
  summarise(rt = mean(RT),
            sd = sd(RT),
            n = n(),
            se = sd / sqrt(n)) %>%
  arrange(lie)




f_RTLie = pirateplot(rt ~ lie, data = rtLie2,
                     xlab = "",
                     ylab = "RT",
                     inf.f.col = c("#8faadc","#2f5597"), 
                     inf.b.col = "black",
                     cex.axis = 1.3,
                     cex.lab =  1.5,
                     cex.names = 1,
                     point.cex = 1,
                     bar.f.o = .5, # Bar
                     bar.f.col = c(gray(.4),gray(.6)), # bar filling color
                     bean.f.o = 0,
                     bean.b.o = 0) +
  segments(x0 = rep(1,length(rtLie[rtLie$lie==0,])), 
         y0 = rtLie[rtLie$lie==0,]$rt,
         x1 = rep(2,length(rtLie[rtLie$lie==1,])), 
         y1 = rtLie[rtLie$lie==1,]$rt,
         col = gray(0,0.1))
rtLie2$type='0'
rtLie2[rtLie2$lie==1,]$type='dishonesty'
rtLie2[rtLie2$lie==0,]$type='honesty'
scale_factor=2
f_RTLie=ggplot(data=rtLie2,aes(x=factor(lie), y=rt)) +
  geom_point(size=2, shape=21, fill='gray70',colour="white",alpha=0.6) +
  geom_line(colour="gray70",lwd= 0.5,alpha=0.5,aes(group=sub))  + 
  geom_bar(stat='identity',data=rtLie,aes(y=rt,x=lie),alpha=0.6,size = 0.5, width = 0.9,color=c('white'),fill=c('gray40','gray70'),position = position_nudge(x = 1))+
  geom_crossbar(data=rtLie,aes(ymin = rt-se, ymax = rt+se), width = 0.7,fill=c("#6195C8", "dark blue"))+
  geom_errorbar(data=rtLie,aes(x=lie,ymin=rt,ymax=rt),size=0.9,width=0.9,position = position_nudge(x = 1))+

#  scale_y_continuous(name='RT',limits = c(0.8, 2.5), breaks=seq(0.8, 2.5, by = 0.2)) +
  scale_y_continuous(name='reaction times')+
  scale_x_discrete(labels=c("honesty","dishonesty"),name='')+
  ggtitle("") +
  theme(axis.text.x = element_text(size=15*scale_factor),
        axis.text.y = element_text(size=20*scale_factor),
        axis.title=element_text(size=20*scale_factor),
        plot.title = element_text(size=20*scale_factor,hjust = 0.5),
        panel.background = element_rect(fill = "white"),
        axis.line = element_line(colour = "black")) +
  geom_signif(y_position=2.5, xmin=1, xmax=2,
              annotation="*", tip_length=0,textsize=5*scale_factor,size=1)
 
f_RTLie
ggsave('/Users/orlacamus/Downloads/rt-lie.svg',width=3,height=3,scale=scale_factor)


