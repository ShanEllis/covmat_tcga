library(rtracklayer)
# qrsh -l mem_free=2G,h_vmem=3G -pe local 25
# module load R/3.3.x

library('R.utils')
library('BiocParallel')

## Parallel environment
bp <- MulticoreParam(workers = 25, outfile = Sys.getenv('SGE_STDERR_PATH'))
tsv <- dir('/dcl01/leek/data/sellis/barcoding/TCGA/bwtool_Sex/coverage_tcga_Sex', pattern = 'tsv', full.names = TRUE)
names(tsv) <- gsub('.sum.tsv', '', dir('/dcl01/leek/data/sellis/barcoding/TCGA/bwtool_Sex/coverage_tcga_Sex', pattern = 'tsv'))

system.time( tsv_lines <- bplapply(tsv, countLines, BPPARAM = bp) )
all(tsv_lines == 80)


## after ensuring that all files are complete (and have the same number of extracted regions)
## can merge them together

multmerge = function(mypath){
	filenames=list.files(path=mypath, full.names=TRUE)
	datalist = lapply(filenames, function(x){
		read.table(file=x,header=F,sep='\t') 
	})
	Reduce(function(x,y) {cbind(x,y[,4])}, datalist)
}

mymergeddata = multmerge('/dcl01/leek/data/sellis/barcoding/TCGA/bwtool_Sex/coverage_tcga_Sex')

filenames=list.files(path='/dcl01/leek/data/sellis/barcoding/TCGA/bwtool_Sex/coverage_tcga_Sex', full.names=FALSE)
filenames = gsub('.sum.tsv', '', filenames)
colnames(mymergeddata)[4:ncol(mymergeddata)] <- filenames

cov_tcga = mymergeddata

save(cov_tcga, file="/dcl01/leek/data/sellis/barcoding/data/regions_Sex_TCGA.rda")
