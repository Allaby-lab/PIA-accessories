#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper qw(Dumper);

# For each read in the intersects file that passes the taxonomic diversity check, list the result next to the read ID.
# > perl Extract_read_taxon_intersects.pl [intersects file] [optional minimum taxonomic diversity score; defaults to 0.1]

my $intersects_filename = $ARGV[0];
open (my $intersects_filehandle, $intersects_filename) or die "Cannot open intersects file: $!\n";			

my $min_taxdiv_score = $ARGV[1];
unless (defined $min_taxdiv_score) {
    $min_taxdiv_score = 0.1; # Default to 0.1, like in the PIA.
}
print "\nMin taxonomic diversity score: $min_taxdiv_score\n";

my %read_results = (); # Keys are read IDs. Values are intersect names and IDs in the format "ID\tname", like in the summary basic.

# Fetch reads that pass the diversity check.
foreach my $line (readline ($intersects_filehandle)){
	my @split_on_intersection = split (/intersection: /, $line); # Split on the intersection field.
    my @split_on_score = split (/ diversity score: |, phylo/, $line); # Split on the taxonomic diversity score field title followed by its comma-space. This is not an 'or'. It will split the line in two places and leave the score value as the middle element.

    if ($split_on_score[2] >= $min_taxdiv_score ){ # If the read passes the check,
        
        my @split_on_commas = split (',', $line);
        my $read_ID = substr ($split_on_commas[0], 7); # 'Query: ' is six characters. The first character we want is the 7th (counting from 0).
        
        my $intersection_field = $split_on_intersection[1];
        my @intersection_field = split (/ /, $intersection_field);
        my $ID = pop @intersection_field; # The ID is the last word.
        chomp $ID;
        $ID =~ tr/()//d; # Remove the parentheses from it (this is transliterate with delete).
        $intersection_field = join (" ", @intersection_field); # Join the remaining words back together. These are the taxon name.
        my $ID_and_name = $ID . "\t" . $intersection_field; # Join the ID and name with a tab.
        
        unless ($ID_and_name eq "0\tnone found" or $ID_and_name eq "1\troot") { # Intersects that weren't found or that equal the root of the tree are not useful. Ignore these.
            $read_results{$read_ID} = $ID_and_name;
        }
    }
}
close $intersects_filehandle;

my $output_filename = $intersects_filename."_read_taxa.txt";
open (my $output_filehandle, '>', $output_filename) or die "Cannot open $output_filename for writing: $!\n";

print $output_filehandle "#Intersects file: $intersects_filename\n#Query\tID\tName\n"; # Print a header first.

foreach my $read (keys %read_results) {
    print $output_filehandle $read . "\t$read_results{$read}\n";
}

print "\nDone\n\n";