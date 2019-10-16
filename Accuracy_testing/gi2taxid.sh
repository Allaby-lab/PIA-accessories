#!/bin/bash

file=$1

while IFS= read -r line
do
   #echo "$line"
   cleaned=${line//[$'\t\r\n']}
   
   #echo -n -e "$cleaned\t"

   curl -s "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=${cleaned}&rettype=fasta&retmode=xml" |\
   grep TSeq_taxid |\
   cut -d '>' -f 2 |\
   cut -d '<' -f 1 |\
   tr -d "\n"
   echo


done < "$file"
