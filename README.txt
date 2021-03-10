Phylogenetic Intersection Analysis accessories
==============================================
Scripts for manipulating PIA outputs
Allaby lab, University of Warwick
2021-03-10

Phylogenetic intersection analysis (PIA) takes standard-format BLAST output and a corresponding FASTA file. It assigns reads to phylogenetic intersections based on their BLAST hits, assuming that the true taxon will be inside that phylogenetic intersection. It is designed to be robust to the uneven representation of taxa in databases.

The scripts in this collection manipulate PIA outputs. Most are described in Cribdon et al. (PIA: More Accurate Taxonomic Assignment of Metagenomic Data Demonstrated on sedaDNA From the North Sea, Frontiers in Ecology and Evolution, 2020). For more information, email r.g.allaby@warwick.ac.uk.


PIA prerequisites
-----------------
-   Perl 5
-   Perl module List::MoreUtils
-   Perl module DB_File


Scripts
=======

Collate_Summary_Basics.pl
-------------------------
-   Collates Summary_Basic.txt files. It can optionally include a pre-PIA spreadsheet from MEGAN. The MEGAN spreadsheet must be in "taxonID_to_count" format.
-   It uses fullnamelineage.dmp from the NCBI: https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/new_taxdump/
-   It assumes that file is located in the current directory. If it's in another location, use option -f to say where.

To run:
perl Collate_spreadsheets.pl -f [optional path to fullnamelineage.dmp] -m [optional MEGAN spreadsheet] -o [optional output name] [at least one summary basic]

Output:
Single .txt containing all input data


Merge_Summary_Basics.pl
-----------------------
-   Simply combines Summary_Basic.txt files into a single one.
-   I use this for combining negative control files before filtering.

To run:
perl Merge_Summary_Basics.pl [at least one Summary Basic]


Filter_Summary_Basics_or_MEGAN_exs_by_control.pl
------------------------------------------------
-   Filters at least one PIA Summary Basic or MEGAN "-ex" file by a corresponding negative control. 
-   Taxa present in the control are not automatically excluded. Instead, this script script accepts taxa in the control if the ratio between the number of hits in the control and in the sample (control/sample) is below x. x is an option but defaults to 0.02.

To run:
perl Filter_Summary_Basics_or_MEGAN_exs_by_control.pl -t [optional new threshold] -c [control] [at least one sample] 

Output:
[input]_pruned.txt for each sample


Convert_Summary_Basics_or_MEGAN_exs_for_Krona.pl
----------------------------------------------
- Converts either PIA Summary Basics or MEGAN taxonID-to-count -ex files to something that Krona can use to make a taxonomy chart.
- The output file contains a single column: #taxID. Each ID represents one hit to that taxon.

To run:
perl Convert_Summary_Basics_or_MEGAN_exs_for_Krona.pl [at least one input file]

Output:
[input]_forKrona.txt for each input


Accuracy_testing/Extract_GIs_from_FASTA_headers.pl
--------------------------------------------------
-   Produces a list of GIs from a FASTA.
-   Assumes the identifier field is the first one in the FASTA headers. This is the case if you download sequences as a FASTA from the NCBI website.

To run:
perl Extract_GIs_from_FASTA_header.pl [FASTA]

Output:
[FASTA basename].GIs.txt


Accuracy_testing/Extract_read_taxon_FASTA_and_IDsnamed.pl
---------------------------------------------------------
-   For each read in the FASTA, merge in the taxonomic name and ID from the IDs.named.txt file.
-   Outputs a file containing every read by GI, followed by its ID and name.

To run:
perl Extract_read_taxon_FASTA_and_IDsnamed.pl [FASTA file] [corresponding IDs.named.txt file]

Output:
[FASTA]_read_taxa.txt


Accuracy_testing/Extract_read_taxon_intersects.pl
-------------------------------------------------
-   For each read in the intersects file that passes the taxonomic diversity check (i.e. would make it to the summary basic), list the result next to the read ID.
-   Outputs a file similar to the summary basic, but per read, not per taxon.

To run:
perl Extract_read_taxon_intersects.pl [intersects file] [optional minimum taxonomic diversity score; defaults to 0.1]

Output:
[intersects file]_read_taxa.txt


Accuracy_testing/gi2taxid.sh
----------------------------
Uses eUtils to look up the taxonomic ID each reference sequence (GI) is assigned to.

To run:
bash gi2taxid.sh [list of GIs] > [output name]

Output:
.txt listing corresponding IDs in the same order as the input GIs


Accuracy_testing/id2name.pl
---------------------------
Uses the names.dmp.dbm index file from the PIA to look up scientific names for a list of taxonomic IDs.

To use:
perl id2name.pl [path to names.dmp.dbm] [list of IDs in a text file]

Output:
[input file]_named.txt


Accuracy_testing/Reduce_FASTA_headers_to_identifiers.pl
-------------------------------------------------------
-   Does what it says on the tin.
-   Assumes the identifier field is the first one in the FASTA headers. This is the case if you download sequences as a FASTA from the NCBI website.

To run:
perl Reduce_FASTA_headers_to_identifiers.pl [FASTA]

Outputs:
[input FASTA basename].reduced.fasta
