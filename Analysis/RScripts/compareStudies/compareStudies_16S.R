#Author: Farnaz Fouladi
#Date: 08-17-2020
#Description: p-value versus p-value plots for 16S datasets

#BioLockJ configuration: Ali Sorgen
#Date: 09-30-2020
rm(list=ls())

#Libraries
library(ggplot2)
library(gridExtra)
library(ggsignif)
library(ggrepel)
library(stringr)

pipeRoot <- dirname(dirname(getwd()))
moduleDir <- dirname(getwd())
outDir <- file.path(moduleDir, "output")
inputDir = file.path(moduleDir,"input")
dir.create(inputDir, showWarnings = FALSE)
message("Input tables will collected into an input folder: ", inputDir)

taxaLevel <- "Genus"
funcScript <- file.path(file.path(moduleDir, "resources"),"functions.R")
source(funcScript)

#AfsharInput <- paste0(pipeRoot,"/",str_subset(dir(pipeRoot), "AfsharDADA"),"/output/MixedLinearModels/",)
fileNameAf <- paste0(taxaLevel,"_Afshar_MixedLinearModelResults.txt")
moduleAf <- file.path(dir(pipeRoot, "AfsharDADA", full.names = TRUE))
AfsharInput <- file.path(file.path(file.path(moduleAf, "output"),"MixedLinearModels"),fileNameAf)
message("Grabbing input file: ", fileNameAf)
message("from module: ", moduleAf)
file.copy(from = AfsharInput, to = inputDir)

#AssalInput <- paste0(pipeRoot,"/",str_subset(dir(pipeRoot), "AssalDADA"),"/output/MixedLinearModels/",taxaLevel,"_Assal_MixedLinearModelResults.txt")
fileNameAs <- paste0(taxaLevel,"_Assal_MixedLinearModelResults.txt")
moduleAs <- file.path(dir(pipeRoot, "AssalDADA", full.names = TRUE))
AssalInput <- file.path(file.path(file.path(moduleAs, "output"),"MixedLinearModels"),fileNameAs)
message("Grabbing input file: ", fileNameAs)
message("from module: ", moduleAs)
file.copy(from = AssalInput, to = inputDir)

#BSInput <- paste0(pipeRoot,"/",str_subset(dir(pipeRoot), "BSDADA"),"/output/MixedLinearModels/",taxaLevel,"_BS_MixedLinearModelResults.txt")
fileNameBs <- paste0(taxaLevel,"_BS_MixedLinearModelResults.txt")
moduleBs <- file.path(dir(pipeRoot, "BSDADA", full.names = TRUE))
BsInput <- file.path(file.path(file.path(moduleBs, "output"),"MixedLinearModels"),fileNameBs)
message("Grabbing input file: ", fileNameBs)
message("from module: ", moduleBs)
file.copy(from = BsInput, to = inputDir)

#IlhanInput <- paste0(pipeRoot,"/",str_subset(dir(pipeRoot), "IlhanDADA"),"/output/MixedLinearModels/",taxaLevel,"_Ilhan_MixedLinearModelResults.txt")
fileNameIl <- paste0(taxaLevel,"_Ilhan_MixedLinearModelResults.txt")
moduleIl <- file.path(dir(pipeRoot, "IlhanDADA", full.names = TRUE))
IlhanInput <- file.path(file.path(file.path(moduleIl, "output"),"MixedLinearModels"),fileNameIl)
message("Grabbing input file: ", fileNameIl)
message("from module: ", moduleIl)
file.copy(from = IlhanInput, to = inputDir)

#BS 1M 6M
#Assal 3M 1Y 2Y
#Ilhan 6M 1Y
#Afshar 6M

studies<-c("BS-p1M","BS-p6M","Assal-p3M","Assal-p1Y","Assal-p2Y","Ilhan-p6M","Ilhan-p1Y","Afshar-p6M")
studyNames<-c("BS-1 month","BS-6 months","Assal-3 months","Assal-1 year","Assal-2 years","Ilhan-6 months","Ilhan-1 year","Afshar-Post surgery")

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
      
      df<-compareStudies(inputDir,taxaLevel,strsplit(studies[s],"-")[[1]][1],strsplit(studies[s1],"-")[[1]][1],strsplit(studies[s],"-")[[1]][2],strsplit(studies[s1],"-")[[1]][2])
      
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
      df<-compareStudies(inputDir,taxaLevel,strsplit(studies[s],"-")[[1]][1],strsplit(studies[s1],"-")[[1]][1],strsplit(studies[s],"-")[[1]][2],strsplit(studies[s1],"-")[[1]][2])
      xlab=paste0(studyNames[s]," vs. baseline")
      ylab=paste0(studyNames[s1]," vs. baseline")
      plot<-plotPairwiseStudies(df,xlab,ylab,r[count],pval[count])
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
      if (xlab == paste0("BS-1 month"," vs. baseline") & ylab == paste0("Assal-3 months"," vs. baseline")){
        #fig 1 C
        favs[1] <- count
      }
      if (xlab == paste0("Assal-3 months"," vs. baseline") & ylab == paste0("Assal-1 year"," vs. baseline")){
        #fig 1 D
        favs[2] <- count
      }
    }
  }
}

df<-data.frame(studyPairs,compariosn,compariosnTime,pval,r)
pairOutFile <- file.path(outDir, paste0(taxaLevel,"_PairwiseComparison.txt"))
message("Saving table of pairwise comparisons: ", pairOutFile)
write.table(df, pairOutFile, sep="\t", row.names = FALSE)

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
outFileWilRes <- file.path(outDir, paste0(taxaLevel, "_wilcoxResults.txt"))
message("Creating output file: ", outFileWilRes)
adjusted<-p.adjust(c(p1$p.value,p2$p.value,p3$p.value,p4$p.value),method = "BH")
capture.output(p1, p2, p3, p4, adjusted, file = outFileWilRes)

#No significant difference between different time points
plot1<-ggplot(data=df,aes(x=compariosn,y=r))+
  geom_boxplot(aes(color=compariosnTime),position = position_dodge(0.6), width = 0.5, size = 0.4,outlier.shape = NA)+
  geom_jitter(aes(color=compariosnTime),size=0.8,position = position_dodge(0.6))+labs(x="",y="Spearman Coefficient",color="")+
  geom_signif(y_position = c(0.75,0.8),xmin = c(0.9,1.1),xmax=c(2,2),annotations = c("*","*"),tip_length=0.03,vjust = 0.5,textsize =4)


scatPlotOut <- file.path(outDir, paste0(taxaLevel,"_scatterPlots.pdf"))
message("Saving scatter plots to file: ", scatPlotOut)
pdf(scatPlotOut, width = 10, height = 10)
theme_set(theme_classic(base_size = 9))
for (i in c(1,10,19)){
  grid.arrange(plotList[[i]],plotList[[i+1]],plotList[[i+2]],
               plotList[[i+3]],plotList[[i+4]],plotList[[i+5]],
               plotList[[i+6]],plotList[[i+7]],plotList[[i+8]],ncol=3,nrow=3)
}
grid.arrange(plotList[[28]],ncol=3,nrow=3)
dev.off()

### pick out the favs that were used in the main figure
fig1Pics <- file.path(outDir, paste0(taxaLevel,"_mainFigure1cd.pdf"))
message("Saving specific plots to individual file to compare to figure 1, see file: ", fig1Pics)
pdf(fig1Pics, width = 5, height = 9)
theme_set(theme_classic(base_size = 9))
grid.arrange(plotList[[favs[1]]], plotList[[favs[2]]],ncol=1,nrow=2)
dev.off()

coefOut <- file.path(outDir, paste0(taxaLevel,"_coefficientsFromScatterPlots.pdf"))
message("Saving coefficients from scatter plots: ", coefOut)
pdf(coefOut, width = 5,height = 5)
theme_set(theme_classic(base_size = 14))
print(plot1)
dev.off()

#plot coefficients for each study

df$study1<-sapply(as.character(df$studyPairs),function(x){strsplit(x,"-")[[1]][1]})
df$study2<-sapply(sapply(as.character(df$studyPairs),function(x){strsplit(x,"-")[[1]][2]}),
                  function(x){strsplit(x,"_")[[1]][2]})

#Extracting coefficients for each study
r.BS<-df$r[df$study1=="BS"]
r.Assal<-c(df$r[df$study1=="Assal"],df$r[df$study1=="BS"& df$study2=="Assal"])
r.Ilhan<-c(df$r[df$study1=="Ilhan"],df$r[df$study1=="BS"& df$study2=="Ilhan"],
           df$r[df$study1=="Assal"& df$study2=="Ilhan"])
r.Afshar<-c(df$r[df$study1=="Afshar"],df$r[df$study1=="BS"& df$study2=="Afshar"],
            df$r[df$study1=="Assal"& df$study2=="Afshar"],df$r[df$study1=="Ilhan"& df$study2=="Afshar"])


study1=c(rep("BS",length(r.BS)),
         rep("Assal",length(r.Assal)),
         rep("Ilhan",length(r.Ilhan)),
         rep("Afshar",length(r.Afshar)))


study2<-c(df$study2[df$study1=="BS"],
          df$study2[df$study1=="Assal"],
          rep("BS",sum(df$study1=="BS"& df$study2=="Assal")),
          df$study2[df$study1=="Ilhan"],
          rep("BS",sum(df$study1=="BS"& df$study2=="Ilhan")),
          rep("Assal",sum(df$study1=="Assal"& df$study2=="Ilhan")),
          rep("BS",sum(df$study1=="BS"& df$study2=="Afshar")),
          rep("Assal",sum(df$study1=="Assal"& df$study2=="Afshar")),
          rep("Ilhan",sum(df$study1=="Ilhan"& df$study2=="Afshar")))

df2<-data.frame(r=c(r.BS,r.Assal,r.Ilhan,r.Afshar),study1,study2)

theme_set(theme_gray(base_size = 14))
plot<-ggplot(data=df2,aes(x=factor(study2),y=r))+geom_boxplot()+geom_jitter(position = position_jitter(width=0.1))+facet_wrap(vars(study1))+
  labs(x="Studies",y="Spearman Coefficient")
boxPlotFile <- file.path(outDir, paste0(taxaLevel,"_BoxPlotCorrelations.pdf"))
message("Saving box plots to file: ", boxPlotFile)
pdf(boxPlotFile, width = 5,height = 5)
print(plot)
dev.off()

message("")
message("All done!")
message("")

sessionInfo()
