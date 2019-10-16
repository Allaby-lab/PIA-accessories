#!/usr/bin/perl

use strict;
use warnings;

# Does what it says on the tin.
# Assumes that the identifier field is the first one in the FASTA headers, which is the case if you download sequences in a FASTA from the NCBI website.
# > perl Reduce_FASTA_headers_to_identifiers.pl [FASTA]


my $input_filename = $ARGV[0];
print "\nReducing headers for $input_filename\n\n";

my @GIs = ();

open (my $input_filehandle, $input_filename) or die "Could not open $input_filename: $!\n";

my $output_filename = substr($input_filename, 0 , -5);
$output_filename = $output_filename . 'reduced.fasta';
open (my $output_filehandle, '>', $output_filename) or die "Could not open $output_filename for writing: $!\n";


while (1) { # Run this loop until "last" is called.
        my $line = <$input_filehandle>; # Read the next line from the nodes file.
        if (! defined $line) { last }; # If there is no next line, exit the loop. You've processed the whole file.
        
        if (index ($line, '>') != -1) { # Only work on header lines.
            #print $line;
            my @line = split(/\|/, $line); # Split on |s. These are special characters.
            pop @line; # Remove the last element. That's everything after the final |.
            my $identifier = join ('|', @line);
            $identifier = $identifier . '|';
            
            print $output_filehandle "$identifier\n";
        } else {
            print $output_filehandle $line;
        }
}

print "\nDone\n\n";