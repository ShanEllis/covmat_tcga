## import colors to use
  bright= c(red=rgb(222,45,38, maxColorValue=255), #de2d26
            pink=rgb( 255, 102, 153, maxColorValue=255), #ff6699
            orange=rgb(232,121,12, maxColorValue=255),   #e8790c
            yellow=rgb(255,222,13, maxColorValue=255), #ffde0d          
            green=rgb(12,189,24, maxColorValue=255),  #0cbd18           
            teal=rgb(59,196,199, maxColorValue=255), #3bc4c7
            blue=rgb(58,158,234, maxColorValue=255), #3a9eea
            purple=rgb(148,12,232, maxColorValue=255)) #940ce8  
### sex prediction in TCGA
load("data/merge_input_Sex.rda")
# regions = merge_input$regiondata
save(coverageMatrix_chrX,coverageMatrix_chrY,file="data/TCGA_sex.rda")

data_used="TCGA"
#compare to previous sex prediction
load("data/Sex_regionsused_meta-predict.rda")
regions = sra_regions_used

library(recount)
library(GenomicRanges)
system.time ( coverageMatrix_chrX_v1 <- coverage_matrix('TCGA', 'chrX', regions) ) #155min
coverageMatrix_chrX %>% dim()
 # regionsY = regions[seqnames(regions)=="chrY"]
system.time( coverageMatrix_chrY_v1 <- coverage_matrix(project='TCGA', chr='chrY', regions=regions) ) #155min
recount::all_metadata('TCGA') -> md 
save(coverageMatrix_chrX_v1,coverageMatrix_chrY_v1,file="/dcl01/leek/data/sellis/barcoding/data/TCGA_sex_origprediction.rda")

