#!/usr/bin/perl 

	use strict;
	use warnings;
	use Data::Dumper qw(Dumper);

# Version 1.0, 2020-06-01

# Converts either PIA Summary Basics or Summary Reads to CSV files that can be imported into MEGAN.
# To open the CSVs in MEGAN, go to go to "File -> Import -> Text (CSV) Format...". Keep the default format and separator. Tick the classification "Taxonomy" and, if available, tick "Parse accessions ids" and accept the default taxonomy analysis settings.
# MEGAN imports Summary Basics CSVs without further analysis. However, it will try to run LCA on Summary Reads CSVs. To effectively turn LCA off, keep the min score at 50, change top percent to 0.001, change min support percent to 0, and keep min support at 1.
# Once you've imported a CSV, remember to uncollapse the tree to view fully.
#
# To run:
# > perl Convert_Summary_Basics_or_Reads_for_MEGAN.pl [at least one input file]

my @input_filenames = @ARGV;

print "\nWorking on:\n";

foreach my $input_filename (@input_filenames) {
    print "\t$input_filename\n";

    my $output_filename = substr ($input_filename, 0, -3); # Trim off the ".txt".
    $output_filename = $input_filename . '_forMEGAN.csv'; # Add a new extension.
    open (my $output_filehandle, '>', $output_filename) or die "Could not open $output_filename for writing: $!\n";
    
    my $basic_or_reads = 'b'; # Assume input files are Summary Basics.
    open (my $input_filehandle, $input_filename) or die "Could not open $input_filename: $!\n";
        while(1) { # Run until last is called.
            my $line = readline($input_filehandle);
            if (! defined $line) { last; } # Exit the loop at the end of the file.
            
            chomp $line; # Makes matching easier and we might be adding a new field on the end.
            
            if (index ($line, '#') != -1) { # If you see a line specific to Summary Reads files, correct $basic_or_reads to mean a Summary Reads file.
                if ($line eq "# Read	ID	Name") {
                    $basic_or_reads = 'r';
                }
                next; # Don't process header lines any further.
            }
            
            my @line = split("\t", $line); # Split the line on tabs.
            
            if ($basic_or_reads eq 'b') { # If the input was a Summary Basics,
                if ($line[1] eq 'none') { # Unassigned reads should not be in a Summary Basic. But just in case: if PIA can't assign a read, it gives it the name 'none found', but MEGAN uses 'Not assigned'.
                    $line[1] = 'Not assigned';
                }
                print $output_filehandle "$line[1],$line[2]\n" # Export the taxon name and read count.
            } elsif ($basic_or_reads eq 'r') { # If the input was a Summary Reads,
                print $output_filehandle "$line[0],$line[1],50\n" # Export the read name, ID, and a stand-in bitscore of 50 (the default minimum pass score for the LCA).
            } else {
                print "\t\tUnknown input format. Check header is correct. Summary Basics should contain '#\tID\tName\tReads' and Summary Reads '#\tRead\tID\tName'.\n";
            }
            
            
        }
        close $input_filehandle;
        close $output_filehandle;

}


print "\nFinished converting.\n\n";