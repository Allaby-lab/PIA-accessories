#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper qw(Dumper);
use DB_File;
use Fcntl;


# > perl id2name.pl [names file DBM index] [list of IDs in a text file]

my $namesfileDBM = $ARGV[0];
my %namesfileDBM = (); # Set up a hash to hold the names DBM file.
tie (%namesfileDBM, "DB_File", $namesfileDBM, O_RDONLY, 0666, $DB_BTREE) or die "Can't open $namesfileDBM: $!\n";

my $input_filename = $ARGV[1];
print "\nLooking up names of IDs in $input_filename\n\n";
open (my $input_filehandle, $input_filename) or die "Could not open $input_filename: $!\n";

my %taxa = ();

while (1) { # Run this loop until "last" is called.
        my $line = <$input_filehandle>; # Read the next line from the nodes file.
        if (! defined $line) { last }; # If there is no next line, exit the loop. You've processed the whole file.
        
        if (index ($line, '#') != -1) { next }; # Skip lines containing '#'. They are headers.
        
        chomp $line; # Remove the newline.
        my @line = split ("\t", $line); # Split the line on tabs. It might only have one element.
        my $ID = shift @line; # The ID must be the 0th field.
        
        my $hits;
        if (@line) { # If there is anything left,
            $hits = $line[-1]; # The hit count must be the last field.
        } else {
            $hits = '';
        }
        
        my $rest_of_line;
        if (@line) {
            $rest_of_line = join ("\t", @line);
        } else {
            $rest_of_line = undef;
        }
        
        my $ID_and_name;
        if (exists $namesfileDBM{$ID}) {
            $ID_and_name = "$ID\t" . $namesfileDBM{$ID};
        } else {
            print "\t$ID not found!\n";
            $ID_and_name = "$ID\tnone";
        }
        
        # There might be multiple entries for the same taxon, so combine where necessary.
        if (exists $taxa{$ID_and_name}) {
            $taxa{$ID_and_name} = $taxa{$ID_and_name} + $hits;
        } else {
           $taxa{$ID_and_name} = $hits;
        }
}
close $input_filehandle;


#my $number_of_taxa = keys %taxa;
#print "Number of taxa: $number_of_taxa\n";

my $output_filename = substr($input_filename, 0, -3);
$output_filename = $output_filename . "named.txt";
open (my $output_filehandle, '>', $output_filename) or die "Could not open $output_filename for writing: $!\n";

foreach my $ID_and_name (keys %taxa) {
    print $output_filehandle "$ID_and_name\t" . $taxa{$ID_and_name} . "\n"; # First print the ID and name, then the hits. End with a newline.
}

print "\nDone\n\n";