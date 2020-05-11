#!/usr/bin/perl

use strict;
use warnings;
use Getopt::Std;

######################################################
############## Merge_Summary_Basics.pl ###############
############## Becky Cribdon, UoW 2013 ###############
######################################################
############## Version 0.5, 2020-05-11 ###############
######################################################

# This script combines Summary_Basic.txt files into one.
# Run as follows:
# >perl Merge_Summary_Basics.pl [at least one summary basic]

my %options = ();
getopts('ho:', \%options);

if ($options{h}) { # If the help option is called, print the help text and exit.
    print "Usage: perl Merge_Summary_Basics.pl [-ho] [at least one Summary Basic]

Option	Description			Explanation
-h	Help				Print this message.
-o	Output file name                Output file name. Defaults to the first Summary Basic with '_merged.txt'.


Other arguments	    Description
[at least one Summary Basic]    Can be pruned or not.

";
	exit;
}

my @output_filename = split ('_', $ARGV[0]); # Start with the first input file name.
my $output_filename = join ('_', @output_filename[0..1], $output_filename[3], 'merged', $output_filename[-1]); # Trim out replicate-specific parts and add 'merged'.
if ($options{o}) { # If the output name option is called, overwrite the default with the option input.
    $output_filename = $options{o};
    print "\n-o: Using output base name '$output_filename'\n";
}



# Read in the summary basics and add data to a single hash
#---------------------------------------------------------
my @summary_basic_filenames = @ARGV; # Any other inputs are summary basics.
my %taxa_and_hits = ();
my $last_sumbasic_filename = '';

print "\nMerging:\n\n";

foreach my $sumbasic_filename (@summary_basic_filenames) {
        
        print "\t$sumbasic_filename\n";
        
        if ($sumbasic_filename eq $last_sumbasic_filename) { print "\n\n### WARNING: Two consecutive summary basics have the same file name. Did you mean to merge them?\n\n"; }
        
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
        
        $last_sumbasic_filename = $sumbasic_filename;
}


# Print hash to a new file
#-------------------------
open( my $output_filehandle, '>', $output_filename) or die "Cannot open $output_filename for writing.\n$!\n";

my $timestamp = localtime();
print $output_filehandle "#Combined Summary Basic $timestamp\n"; # Print a header first.

foreach my $taxon (keys %taxa_and_hits) { # If there weren't any hits in any summary basic, this hash will be empty. But that shouldn't throw an error.
            print $output_filehandle "$taxon\t$taxa_and_hits{$taxon}\n";
}

print "\nOutputted as $output_filename.\n\n";