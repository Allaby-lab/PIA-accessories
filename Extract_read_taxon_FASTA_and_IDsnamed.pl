#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper qw(Dumper);

# For each read in the intersects file that passes the taxonomic diversity check, list the result next to the read ID.
# > perl Extract_read_taxon_FASTA_and_IDsnamed.pl [FASTA file] [corresponding IDs.txt.named.txt file]

my $FASTA_filename = $ARGV[0];
my $taxa_filename = $ARGV[1];


my @identifier_fields = ();
open (my $FASTA_filehandle, $FASTA_filename) or die "Cannot open FASTA file $FASTA_filename: $!\n";		
while (1) { # Run this loop until "last" is called.
    my $line = <$FASTA_filehandle>; # Read the next line from the nodes file.
    if (! defined $line) { last }; # If there is no next line, exit the loop. You've processed the whole file.
    
    
    if (index ($line, '>') != -1) { # Only work on header lines.
        
        $line = substr($line, 1); # Trim off the first character. That's the >.
        
        my @line = split(/\|/, $line); # Split on |s. These are special characters.
        pop @line; # Remove the last element. That's everything after the final |.
        my $identifier = join ('|', @line);
        $identifier = $identifier . '|';
        
        push (@identifier_fields, $identifier); # Store in the array. Arrays maintain order.
    }
}
close $FASTA_filehandle;


my @taxa = ();
open (my $taxa_filehandle, $taxa_filename) or die "Cannot open IDs.txt.named.txt file $taxa_filename: $!\n";			
while (1) { # Run this loop until "last" is called.
    my $line = <$taxa_filehandle>; # Read the next line from the nodes file.
    if (! defined $line) { last }; # If there is no next line, exit the loop. You've processed the whole file.

    chomp $line;
    push (@taxa, $line); # Store in the array. Arrays maintain order.
}
close $taxa_filehandle;


my $read_count = @identifier_fields;
my $taxon_count = @taxa;
#print "\nRead count: $read_count\tTaxon count: $taxon_count\n";

if ( $read_count != $taxon_count ) {
    print "\nUnequal number of FASTA and IDs.txt.named.txt. Aborting.\n\n";
} else {

    my $output_filename = $FASTA_filename."_read_taxa.txt";
    open (my $output_filehandle, '>', $output_filename) or die "Cannot open $output_filename for writing: $!\n";
    
    foreach my $read (@identifier_fields) {
        my $taxon = shift @taxa;
        print $output_filehandle "$read\t$taxon\n";
    }

    print "\nPrinted output to $output_filename\n\n";
}