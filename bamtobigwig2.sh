#!/bin/bash

# bamtobigwig.sh
# By Michael Gebhardt (mjgeby@gmail.com)
# Simon L. Dove Lab, Children's Hospital Boston, Harvard Medical School
# Nov 7, 2019
# This program will sort and then convert bam files to bigwig files through a bedgraph intermediate step.

# The bedgraph to big wig conversion is done via the bedgraphtoBigWig executable downloaded from USCS database:
# (http://hgdownload.soe.ucsc.edu/admin/exe/macOSX.x86_64/)
# Basic steps: 
# 1. Sort input bam files. 
# 2. Convert to the sorted bam to bedgraph, splitting by strand.
# 		Note: Need to know how cDNA library was constructed for proper strand 
# 		orientation/assignment 
# 3. Convert the bedgraph to the bigwig format.

# Program requirements: 
#	samtools
#	bedtools
#	bedGraphToBigWig (USCSC)
#	Modification to direct program to appropriate directory; directory should contain two new folders named "tracks" and "bigwig"

# Usage: ./bamtobigwig.sh experimentA experimentB

for f in *.bam ;
do
	REP=$1 	#Set the prefix to the first argument
	DIRPATH=~/../../Volumes/DoveExternalMG/202001_AML_RNASEQ_bigwig/mvaUT_pilY1/ # Define working directory
	
	echo "> Sorting bam file:" $REP		## Can include for debugging/monitoring progress
	
	samtools sort $REP > ./"sorted_"$REP	# Sort the input bam file
	
	echo ">> Splitting reads by strand for" $REP		## Can include for debugging/monitoring progress
	
	bedtools genomecov -bg -split -strand - -trackline -trackopts 'name='$REP'_plus color=0,0,255' -du -ibam $DIRPATH/sorted_$REP > $DIRPATH/tracks/$REP"_plus.bedGraph"	# parse plus strand reads
	bedtools genomecov -bg -split -strand + -trackline -trackopts 'name='$REP'_minus color=255,0,0' -du -ibam $DIRPATH/sorted_$REP > $DIRPATH/tracks/$REP"_minus.bedGraph"	# parse minus strand reads
	
	echo ">>> Converting bedgraph files to bigwig format for" $REP		## Can include for debugging/monitoring progress
	
	~/coding/bedGraphToBigWig $DIRPATH/tracks/$REP\_plus.bedGraph ~/Genome_Files/PAO1/PAO1_genomeTable.txt $DIRPATH/bigwig/$REP"_plus.bw"	# convert plus reads to bigwig format
	~/coding/bedGraphToBigWig $DIRPATH/tracks/$REP\_minus.bedGraph ~/Genome_Files/PAO1/PAO1_genomeTable.txt $DIRPATH/bigwig/$REP"_minus.bw"	# convert minus reads to bigwig format
	
	echo ">>>> Removing intermediate files"		## Can include for debugging/monitoring progress

	rm ./sorted_$REP
	rm $DIRPATH/tracks/$REP\_plus.bedGraph
	rm $DIRPATH/tracks/$REP\_minus.bedGraph
			
	shift

done