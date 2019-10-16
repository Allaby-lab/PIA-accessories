#!/usr/bin/perl 

	use strict;
	use warnings;
	use Data::Dumper qw(Dumper);

# Converts either a PIA summary basic file or a MEGAN taxonID-to-count file to something that Krona can use to make a taxonomy chart.
# The output file contains a single column: #taxID. Each ID represents one hit to that taxon.
# To run:
# > perl Convert_Summary_Basic_or_MEGAN_ex_for_Krona.pl [input file] [output file name]

my $input_filename = $ARGV[0];
my $output_filename = $ARGV[1];
if (! defined $output_filename) { $output_filename = $input_filename . '_forKrona.txt'; } # If an output filename is not given, make it an extention of the input filename.

# Read in data from the input file.
open (my $input_filehandle, $input_filename) or die "Could not open summary basic $input_filename: $!\n";
my %taxa_and_hits = ();

foreach my $line (readline($input_filehandle)) {
            
        if (index ($line, '#') != -1) { next; } # If the line contains a hash symbol, which indicates the header line in summary basics, skip it.

        chomp $line;
        my @line = split("\t", $line);
        
        my $ID = $line[0]; # The zeroth column is ID.
        
        my $hit_count = $line[-1]; # The final column is hit count. Summary basics have an extra column in the middle.
        
        if (exists $taxa_and_hits{$ID}) { # Unlike summary basics, I'm not sure whether there can be duplicate IDs in a MEGAN ex file. This if collates duplicates.
                $taxa_and_hits{$ID} = $taxa_and_hits{$ID} + $hit_count;
            } else {
                $taxa_and_hits{$ID} = $hit_count;
        }
}
close $input_filehandle;
#print Dumper \%taxa_and_hits;


# Export to the output file
open (my $output_filehandle, '>', $output_filename) or die "Coult not open $output_filename for writing: $!\n";

print $output_filehandle "#taxID\n"; # Print the header first.

foreach my $ID (keys %taxa_and_hits) {
    my $hit_count = $taxa_and_hits{$ID};
    my @hit_array = ($ID) x $hit_count;
    foreach my $hit (@hit_array) {
        print $output_filehandle "$hit\n";
    }
}


print "\n\nFinished converting. Remember to specify '-t 1' when running Krona.\n\n";