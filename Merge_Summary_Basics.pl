#!/usr/bin/perl

use strict;
use warnings;

######################################################
############## Merge_Summary_Basics.pl ###############
############## Becky Cribdon, UoW 2013 ###############
######################################################
############## Version 0.2, 2019-11-26 ###############
######################################################

# This script combines Summary_Basic.txt files into one.
# Run as follows:
# >perl Merge_Summary_Basics.pl [at least one summary basic]


print "\n\n##### Merging summary basics #####\n\n";

# Read in the summary basics and add data to a single hash
#---------------------------------------------------------
my @summary_basic_filenames = @ARGV; # Any other inputs are summary basics.
my %taxa_and_hits = ();

foreach my $sumbasic_filename (@summary_basic_filenames) {
        open (my $sumbasic_filehandle, $sumbasic_filename) or die "Could not open summary basic file $sumbasic_filename: $!\n";
        foreach my $line (readline($sumbasic_filehandle)) {
            
            if (index ($line, '#') != -1) { next; } # If the line contains a hash symbol, which indicates the header line, skip it.

            chomp $line;
            my @line = split("\t", $line);
        
            my $ID_and_name = $line[0] . "\t" . $line[1]; # The first two columns are ID and name.
            my $hit_count = $line[2]; # The final column is count.
            if (exists $taxa_and_hits{$ID_and_name}) {
                $taxa_and_hits{$ID_and_name} = $taxa_and_hits{$ID_and_name} + $hit_count;
            } else {
                $taxa_and_hits{$ID_and_name} = $hit_count;
            }
        }
        close $sumbasic_filehandle;
}


# Print hash to a new file
#-------------------------
my $output_filename = 'Merged_summary_basic.txt';
open( my $output_filehandle, '>', $output_filename) or die "Cannot open $output_filename for writing.\n$!\n";

my $timestamp = localtime();
print $output_filehandle "#Combined summary basic $timestamp\n"; # Print a header first.

foreach my $taxon (keys %taxa_and_hits) { # If there weren't any hits in any summary basic, this hash will be empty. But that shouldn't throw an error.
            print $output_filehandle "$taxon\t$taxa_and_hits{$taxon}\n";
}

print "\nOutputted as $output_filename.\n\n";