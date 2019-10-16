#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper qw(Dumper);

# Produces a list of GIs from a FASTA.
# Assumes the identifier field is the first one in the FASTA headers. This is the case if you download sequences as a FASTA from the NCBI website.

# To run:
# > perl Extract_GIs_from_FASTA_header.pl [FASTA]


my $input_filename = $ARGV[0];
print "\nExtracting GIs from $input_filename\n\n";

my @GIs = ();

open (my $input_filehandle, $input_filename) or die "Could not open $input_filename: $!\n";

while (1) { # Run this loop until "last" is called.
        my $line = <$input_filehandle>; # Read the next line from the nodes file.
        if (! defined $line) { last }; # If there is no next line, exit the loop. You've processed the whole file.
        
        if (index ($line, '>') != -1) {
            my @line = split(/gi\|/, $line); # Split on GI field. '|' is a special character. [1] contains the GI.
            my @GI_with_extras = split (/\|/, $line[1]);
            my $GI = $GI_with_extras[0];
            push (@GIs, $GI);
        }
}
close $input_filehandle;



my $output_filename = substr($input_filename, 0, -5);
$output_filename = $output_filename . 'GIs.txt';
open (my $output_filehandle, '>', $output_filename) or die "Could not open $output_filename for writing: $!\n";

foreach my $GI (@GIs) {
    print $output_filehandle "$GI\n";
}

print "\nDone\n\n";