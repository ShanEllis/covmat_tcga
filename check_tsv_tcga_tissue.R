# qrsh -l mem_free=2G,h_vmem=3G -pe local 25
# module load R/3.3.x

library(rtracklayer)
library('R.utils')
library('BiocParallel')

load('/dcl01/leek/data/sellis/barcoding/data/build_predictor_SMTS_nocovars.rda')
regions = predictor$regiondata

  
## Parallel environment
bp <- MulticoreParam(workers = 25, outfile = Sys.getenv('SGE_STDERR_PATH'))
tsv <- dir('/dcl01/leek/data/sellis/barcoding/TCGA/bwtool_SMTS/coverage_tcga_SMTS', pattern = 'tsv', full.names = TRUE)
names(tsv) <- gsub('.sum.tsv', '', dir('/dcl01/leek/data/sellis/barcoding/TCGA/bwtool/coverage_tcga_SMTS', pattern = 'tsv'))
#LibraryLayout
# tsv <- dir('/dcl01/leek/data/sellis/barcoding/TCGA/bwtool_LibraryLayout/coverage_tcga_LibraryLayout', pattern = 'tsv', full.names = TRUE)
# names(tsv) <- gsub('.sum.tsv', '', dir('/dcl01/leek/data/sellis/barcoding/TCGA/bwtool_LibraryLayout/coverage_tcga_LibraryLayout', pattern = 'tsv'))

# tsv <- dir('/dcl01/leek/data/sellis/barcoding/GTEx/bwtool/coverage_gtex_LibraryLayout', pattern = 'tsv', full.names = TRUE)
# names(tsv) <- gsub('.sum.tsv', '', dir('/dcl01/leek/data/sellis/barcoding/GTEx/bwtool/coverage_gtex_LibraryLayout', pattern = 'tsv'))


system.time( tsv_lines <- bplapply(tsv, countLines, BPPARAM = bp) )
all(tsv_lines == length(regions))


## after ensuring that all files are complete (and have the same number of extracted regions)
## can merge them together

multmerge = function(mypath){
	filenames=list.files(path=mypath, full.names=TRUE)
	datalist = lapply(filenames, function(x){
		read.table(file=x,header=F,sep='\t') 
	})
	Reduce(function(x,y) {cbind(x,y[,4])}, datalist)
}

mymergeddata = multmerge('/dcl01/leek/data/sellis/barcoding/TCGA/bwtool_SMTS/coverage_tcga_SMTS')
filenames=list.files(path='/dcl01/leek/data/sellis/barcoding/TCGA/bwtool_SMTS/coverage_tcga_SMTS', full.names=FALSE)

# mymergeddata = multmerge('/dcl01/leek/data/sellis/barcoding/TCGA/bwtool_LibraryLayout/coverage_tcga_LibraryLayout')
# filenames=list.files(path='/dcl01/leek/data/sellis/barcoding/TCGA/bwtool_LibraryLayout/coverage_tcga_LibraryLayout', full.names=FALSE)

# mymergeddata = multmerge('/dcl01/leek/data/sellis/barcoding/GTEx/bwtool/coverage_gtex_LibraryLayout')
# filenames=list.files(path='/dcl01/leek/data/sellis/barcoding/GTEx/bwtool/coverage_gtex_LibraryLayout', full.names=FALSE)

filenames = gsub('.sum.tsv', '', filenames)
colnames(mymergeddata)[4:ncol(mymergeddata)] <- filenames

cov_tcga = mymergeddata

save(cov_tcga, file="/dcl01/leek/data/sellis/barcoding/data/regions_SMTS_TCGA.rda")
# save(cov_tcga, file="/dcl01/leek/data/sellis/barcoding/data/regions_LibraryLayout_TCGA.rda")
#save(cov_gtex, file="/dcl01/leek/data/sellis/barcoding/data/regions_LibraryLayout_GTEx.rda")
