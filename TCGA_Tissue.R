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
library(recount)
library(GenomicRanges)
library(rtracklayer)



data_used="TCGA"
#compare to previous sex prediction
load("/dcl01/leek/data/sellis/barcoding/data/Tissue_regionsused_meta-predict.rda")
regions = sra_regions_used

## save as bedfile for region extraction in TCGA
#compare to previous sex prediction
gr = sra_regions_used
export.bed(gr, con="bwtools/TCGA_Tissue.bed")
## run scripts/run_bwtool_se.sh to extract regions
## run check_tsv_tcga to check file and merge
load("/dcl01/leek/data/sellis/barcoding/data/regions_tissue_TCGA.rda")






