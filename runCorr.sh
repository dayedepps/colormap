#!/bin/sh

# Author: Ehsan Haghshenas (ehaghshe[at]sfu[dot]ca)

if [ "$#" -lt 4 ]; then
   echo "USAGE: ./runCorr.sh pacbio.fasta illumina.fastq outPrefix threads"
   exit
fi

EXEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CURRDIR=`pwd`

BWA=$EXEDIR/bin/bwa-proovread
SAM=$EXEDIR/bin/samtools
SPALG=$EXEDIR/bin/spCorrection

mkdir -p $3
rm -f $3/*
ln -s -f $CURRDIR/$1 $3

$BWA index $3/$1
$BWA mem -aY -t $4 -A 5 -B 11 -O 2,1 -E 4,3 -k 8 -W 16 -w 40 -r 1 -D 0 -y 20 -L 30,30 -T 2.5 $3/$1 $2 > $3/$3_iter1.sam
$SAM view -bS $3/$3_iter1.sam | $SAM sort -@ $4 - | $SAM view -h -o $3/$3_iter1.sort.sam -
$SPALG -l $1 -a $3/$3_iter1.sort.sam -t $4 > $3/$3_iter1.fasta

$BWA index $3/$3_iter1.fasta
$BWA mem -aY -t $4 -A 5 -B 11 -O 2,1 -E 4,3 -k 8 -W 16 -w 40 -r 1 -D 0 -y 20 -L 30,30 -T 2.5 $3/$3_iter1.fasta $2 > $3/$3_iter2.sam
$SAM view -bS $3/$3_iter2.sam | $SAM sort -@ $4 - | $SAM view -h -o $3/$3_iter2.sort.sam -
$SPALG -l $3/$3_iter1.fasta -a $3/$3_iter2.sort.sam -t $4 > $3/$3_corr.fasta
