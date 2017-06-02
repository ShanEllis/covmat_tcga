#!/bin/sh

# Usage
# sh run_bwtool.sh sra
# sh run_bwtool.sh gtex
# sh run_bwtool_se.sh tcga

# Directories
MAINDIR=/dcl01/leek/data/recount-website
WDIR=/dcl01/leek/data/sellis/barcoding/TCGA/bwtool_SMTS
# WDIR=/dcl01/leek/data/sellis/barcoding/GTEx/bwtool
# WDIR=/dcl01/leek/data/sellis/barcoding/SRA/bwtool


# Define variables
PROJECT=$1

# Create log dir
mkdir -p ${WDIR}
mkdir -p ${WDIR}/logs

# Construct shell file
# For testing use: "head -n 10 |" before > ${WDIR}/bwtool_cmds_${PROJECT}.txt

if [[ "${PROJECT}" == "sra" ]]
then
    mkdir -p /dcl01/leek/data/sellis/barcoding/SRA/bwtool
    sh /dcl01/leek/data/recount-website/generate_sums.sh /dcl01/leek/data/bwtool/bwtool-1.0/bwtool /dcl01/leek/data/recount-website/genes/Gencode-v25.bed /dcl01/leek/data/sra/v2 /dcl01/leek/data/sellis/barcoding/SRA/bwtool/coverage_sra_SMTS > ${WDIR}/bwtool_cmds_${PROJECT}.txt
elif [[ "${PROJECT}" == "gtex" ]]
then
    mkdir -p /dcl01/leek/data/sellis/barcoding/GTEx/bwtool
    sh /dcl01/leek/data/recount-website/generate_sums.sh /dcl01/leek/data/bwtool/bwtool-1.0/bwtool /dcl01/leek/data/recount-website/genes/Gencode-v25.bed /dcl01/leek/data/gtex /dcl01/leek/data/sellis/barcoding/GTEx/bwtool/coverage_gtex_SMTS > ${WDIR}/bwtool_cmds_${PROJECT}.txt
elif [[ "${PROJECT}" == "tcga" ]]
then
    mkdir -p /dcl01/leek/data/sellis/barcoding/TCGA/bwtool
    sh /dcl01/leek/data/recount-website/generate_sums.sh /dcl01/leek/data/bwtool/bwtool-1.0/bwtool /dcl01/leek/data/sellis/barcoding/TCGA/TCGA_Tissue_v2.bed /dcl01/leek/data/tcga/v1 /dcl01/leek/data/sellis/barcoding/TCGA/bwtool_SMTS/coverage_tcga_SMTS > ${WDIR}/bwtool_cmds_${PROJECT}.txt
else
    echo "Specify a valid project: gtex, sra, tcga"
fi

# Count how many commands there are
LINES=$(wc -l ${WDIR}/bwtool_cmds_${PROJECT}.txt | cut -f1 -d " ")
echo "Including ${LINES} commands"

echo "Creating script for project ${PROJECT}"
sname="${PROJECT}.bwtool"
    
cat > ${WDIR}/.${sname}.sh <<EOF
#!/bin/bash
#$ -cwd
#$ -m a
#$ -l leek,mem_free=1G,h_vmem=2G,h_fsize=100G
#$ -N ${sname}
#$ -t 1:${LINES}
#$ -o ./logs/${PROJECT}.bwtool.o.\$TASK_ID.txt
#$ -e ./logs/${PROJECT}.bwtool.e.\$TASK_ID.txt

## Get the bwtool command
bwtoolcmd=\$(awk "NR==\${SGE_TASK_ID}" ${WDIR}/bwtool_cmds_${PROJECT}.txt)

## Extract the sample and print it
bwfile=\$(echo "\${bwtoolcmd}" | cut -f5 -d " ")
bwsample=\$(basename \${bwfile} .bw)

echo "**** Job starts sample \${bwsample} ****"
date

## Run bwtool
echo "\${bwtoolcmd}"
\${bwtoolcmd}

echo "**** Job ends ****"
date
EOF

call="qsub ${WDIR}/.${sname}.sh"
echo $call
$call


