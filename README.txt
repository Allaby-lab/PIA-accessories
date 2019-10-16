Phylogenetic Intersection Analysis accessories
==============================================
Scripts for manipulating PIA outputs
Allaby lab, University of Warwick
2019-10-16

Phylogenetic intersection analysis (PIA) takes standard-format BLAST output and a corresponding FASTA file. It assigns reads to phylogenetic intersections based on their BLAST hits, assuming that the true taxon will be inside that phylogenetic intersection. It is designed to be robust to the uneven representation of taxa in databases.

The scripts in this collection manipulate PIA outputs. Most will be described in a forthcoming paper. For more information, email r.cribdon@warwick.ac.uk.


PIA prerequisites
-----------------
-   Perl 5
-   Perl module List::MoreUtils
-   Perl module DB_File


Scripts
=======

Collate_summary_basics.pl
-------------------------
-   Collates Summary_Basic.txt files. It can optionally include a pre-PIA spreadsheet from MEGAN. The MEGAN spreadsheet must be in "taxonID_to_count" format.
-   It uses fullnamelineage.dmp from the NCBI: https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/new_taxdump/
-   It assumes that file is located at /Reference_files/fullnamelineage.dmp. If it's in another location, use option -f to say where.

To run:
>perl Collate_spreadsheets.pl -f [optional path to fullnamelineage.dmp] -m [optional MEGAN spreadsheet] -o [optional output name] [at least one summary basic]

Output:
-   Single .txt containing all input data


Convert_Summary_Basic_or_MEGAN_ex_for_Krona.pl
----------------------------------------------
-   Converts either a PIA summary basic file or a MEGAN taxonID-to-count file to something that Krona can use to make a taxonomy chart.
-   The output file contains a single column: #taxID. Each ID represents one hit to that taxon.

To run:
>perl Convert_Summary_Basic_or_MEGAN_ex_for_Krona.pl [input file] [output file name]

Output:
-   .txt file containing every taxonomic ID in the input file x times, where x is the number of hits.


Filter_Summary_Basic_or_MEGAN_ex_by_control.pl
----------------------------------------------
-   Filters one PIA Summary Basic or MEGAN "-ex" file by a corresponding negative control. 
-   Taxa present in the control are not automatically excluded. Instead, this script accepts taxa in the control if the number of control hits is below x % of the number of hits in the sample. x is an option but defaults to 0.02.

To run:
>perl Filter_Summary_Basic_or_MEGAN_ex_by_control.pl [control] [sample] [threshold]

Output:
-   [sample]_pruned.txt


Make_post-PIA_FASTA.pl
----------------------
-   Decides which reads in the intersects file would pass to the summary basic and looks up their names in the original FASTA. Outputs a subset of that FASTA with just those passing reads.
-   Assumes the normal PIA file structure and the default minimum taxonomic diversity score of 0.1.
-   Can also re-create the original summary basic if you uncomment sections. This was used for testing.

To run:
>perl Make_post-PIA_FASTA_PIA5.pl [original FASTA]

Output:
-   [original FASTA]_postPIA.fasta


Accuracy_testing/Extract_GIs_from_FASTA_headers.pl
--------------------------------------------------
-   Produces a list of GIs from a FASTA.
-   Assumes the identifier field is the first one in the FASTA headers. This is the case if you download sequences as a FASTA from the NCBI website.

To run:
>perl Extract_GIs_from_FASTA_header.pl [FASTA]


Output:
-   [FASTA basename].GIs.txt


Accuracy_testing/Extract_read_taxon_FASTA_and_IDsnamed.pl
---------------------------------------------------------
-   For each read in the FASTA, merge in the taxonomic name and ID from the IDs.named.txt file.
-   Outputs a file containing every read by GI, followed by its ID and name.

To run:
>perl Extract_read_taxon_FASTA_and_IDsnamed.pl [FASTA file] [corresponding IDs.named.txt file]

Output:
-   [FASTA]_read_taxa.txt


Accuracy_testing/Extract_read_taxon_intersects.pl
-------------------------------------------------
-   For each read in the intersects file that passes the taxonomic diversity check (i.e. would make it to the summary basic), list the result next to the read ID.
-   Outputs a file similar to the summary basic, but per read, not per taxon.

To run:
>perl Extract_read_taxon_intersects.pl [intersects file] [optional minimum taxonomic diversity score; defaults to 0.1]

Output:
-   [intersects file]_read_taxa.txt


Accuracy_testing/gi2taxid.sh
----------------------------
Uses eUtils to look up the taxonomic ID each reference sequence (GI) is assigned to.

To run:
>bash gi2taxid.sh [list of GIs] > [output name]

Output:
-   .txt listing corresponding IDs in the same order as the input GIs


Accuracy_testing/id2name.pl
---------------------------
Uses the names.dmp.dbm index file from the PIA to look up scientific names for a list of taxonomic IDs.

To use:
>perl id2name.pl [path to names.dmp.dbm] [list of IDs in a text file]


Output:
-   [input file]_named.txt


Accuracy_testing/Reduce_FASTA_headers_to_identifiers.pl
-------------------------------------------------------
-   Does what it says on the tin.
-   Assumes the identifier field is the first one in the FASTA headers. This is the case if you download sequences as a FASTA from the NCBI website.

To run:
>perl Reduce_FASTA_headers_to_identifiers.pl [FASTA]

Outputs:
-   [input FASTA basename].reduced.fasta
