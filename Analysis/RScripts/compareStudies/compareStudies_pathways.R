#Author: Farnaz Fouladi
#Date: 08-17-2020
#Description: p-value versus p-value plots for pathways

#BioLockJ configuration: Ali Sorgen
#Date: 09-30-2020
# rm(list=ls())

#Libraries
library(ggplot2)
library(gridExtra)
library(ggsignif)
library(ggrepel)
library(stringr)

pipeRoot = dirname(dirname(getwd()))
output = file.path(dirname(getwd()),"output/")
# output<-"./output/"
taxa<-"Pathway"
moduleDir <- dirname(getwd())
funcScript <- paste0(moduleDir,"/resources/functions.R")
source(funcScript)
# source("./Rcode/RYGB_IntegratedAnalysis/functions.R")

dir.create(paste0(dirname(getwd()),"/input/"))
input = file.path(dirname(getwd()),"input/")

BSInput <- paste0(pipeRoot,"/",str_subset(dir(pipeRoot), "BSpathway"),"/output/MixedLinearModels/humann2/",taxa,"_BS_MixedLinearModelResults.txt")
file.copy(from = BSInput, to = input)

PallejaInput <- paste0(pipeRoot,"/",str_subset(dir(pipeRoot), "Pallejapathway"),"/output/MixedLinearModels/humann2/",taxa,"_Palleja_MixedLinearModelResults.txt")
file.copy(from = PallejaInput, to = input)


#BS 1M 6M 1Y
#Palleja 3M 1Y 

studies<-c("BS-p1M","BS-p6M","BS-p1Y",
           "Palleja-p3M","Palleja-p1Y")
studyNames<-c("BS-1 month","BS-6 months","BS-1 year","Palleja-3 months","Palleja-1 year")

r<-vector()
pval<-vector()
plotList<-list()
studyPairs<-vector()
compariosn<-vector()
compariosnTime<-vector()
index<-1


favs<-vector(length=2)

for (s in 1:length(studies)){
  
  if (s!=length(studies)){
    
    otherStudies<-c((s+1):length(studies))
    
    for (s1 in otherStudies){
      
      path <- input
      # path<-paste0(output,"MixedLinearModels/humann2/")
      df<-compareStudies(path,taxa,strsplit(studies[s],"-")[[1]][1],strsplit(studies[s1],"-")[[1]][1],strsplit(studies[s],"-")[[1]][2],strsplit(studies[s1],"-")[[1]][2])
      
      r[index]<-correlationBetweenStudies(df)[[1]]
      pval[index]<-correlationBetweenStudies(df)[[2]]
      index<-index+1
      
    }
  }
}

pval<-p.adjust(pval,method = "BH")
count=0

for (s in 1:length(studies)){
  
  if (s!=length(studies)){
    otherStudies<-c((s+1):length(studies))
    
    for (s1 in otherStudies){
      
      count<-count+1
      df<-compareStudies(path,taxa,strsplit(studies[s],"-")[[1]][1],strsplit(studies[s1],"-")[[1]][1],strsplit(studies[s],"-")[[1]][2],strsplit(studies[s1],"-")[[1]][2])
      xlab=paste0(studyNames[s]," vs. baseline")
      ylab=paste0(studyNames[s1]," vs. baseline")
      plot<-plotPairwiseStudiesMetagenomics(df,xlab,ylab,r[count],pval[count])
      plotList[[count]]<-plot
      studyPairs[count]<-paste0(studies[s],"_",studies[s1])
      if(strsplit(studies[s],"-")[[1]][1] == strsplit(studies[s1],"-")[[1]][1])
        compariosn[[count]]<-"Same study"
      else
        compariosn[[count]]<-"Different study"
      
      if(strsplit(studies[s],"-")[[1]][2] == strsplit(studies[s1],"-")[[1]][2])
        compariosnTime[[count]]<-"Same timepoint"
      else
        compariosnTime[[count]]<-"Different timepoint"
      
      # add the specific images used in the main figure in a favs list
      if (xlab == paste0("BS-1 month"," vs. baseline") & ylab == paste0("Palleja-3 months"," vs. baseline")){
        #fig 3D
        favs[1] <- count
      }
      if (xlab == paste0("BS-1 month"," vs. baseline") & ylab == paste0("BS-6 months"," vs. baseline")){
        #fig 3E
        favs[2] <- count
      }
    }
  }
}


df<-data.frame(studyPairs,compariosn,compariosnTime,pval,r)
write.table(df, paste0(output,taxa,"_PairwiseComaprison_MetagenomicsData.txt"),sep="\t",row.names = FALSE)

#Wilcoxon test for comparing coefficients
p1<-wilcox.test(df$r[df$compariosn=="Different study" & df$compariosnTime=="Different timepoint"],
                df$r[df$compariosn=="Different study" & df$compariosnTime=="Same timepoint"])

p2<-wilcox.test(df$r[df$compariosn=="Different study" & df$compariosnTime=="Different timepoint"],
                df$r[df$compariosn=="Same study" & df$compariosnTime=="Different timepoint"])

p3<-wilcox.test(df$r[df$compariosn=="Different study" & df$compariosnTime=="Same timepoint"],
                df$r[df$compariosn=="Same study" & df$compariosnTime=="Different timepoint"])

p4<-wilcox.test(df$r[df$compariosn=="Different study"],
                df$r[df$compariosn=="Same study" & df$compariosnTime=="Different timepoint"])

#Adjusting p-values from wilcoxon test
adjustedp<-p.adjust(c(p1$p.value,p2$p.value,p3$p.value,p4$p.value),method = "BH")
capture.output(p1, p2, p3, p4, adjustedp, file = paste0(output,taxa,"_wilcoxResults.txt"))

#No significant difference between different time points
plot1<-ggplot(data=df,aes(x=compariosn,y=r))+
  geom_boxplot(aes(color=compariosnTime),position = position_dodge(0.6), width = 0.5, size = 0.4,outlier.shape = NA)+
  geom_jitter(aes(color=compariosnTime),size=0.8,position = position_dodge(0.6))+labs(x="",y="Spearman Coefficient",color="")+
  geom_signif(y_position = c(1),xmin = c(0.9),xmax=c(2),annotations = c("*"),tip_length=0.03,vjust = 0.5,textsize =4)+
  lims(y=c(0,1))


pdf(paste0(output,taxa,"_scatterPlots_MetagenomicsBSAndPalleja.pdf"),width = 10,height = 10)
theme_set(theme_classic(base_size = 9))

grid.arrange(plotList[[1]],plotList[[2]],plotList[[3]],
             plotList[[4]],plotList[[5]],plotList[[6]],
             plotList[[7]],plotList[[8]],plotList[[9]],ncol=3,nrow=3)

grid.arrange(plotList[[10]],ncol=3,nrow=3)
dev.off()

### pick out the favs that were used in the main figure
pdf(paste0(output,taxa,"_mainFigure3de.pdf"),width = 7,height = 3)
theme_set(theme_classic(base_size = 9))
grid.arrange(plotList[[favs[1]]], plotList[[favs[2]]],ncol=2,nrow=1)
dev.off()


pdf(paste0(output,taxa,"_coefficientsFromScatterPlots_MetagenomicsBSAndPalleja.pdf"),width = 5,height = 5)
theme_set(theme_classic(base_size = 14))
print(plot1)
dev.off()

