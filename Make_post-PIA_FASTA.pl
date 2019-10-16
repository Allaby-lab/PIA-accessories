#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper qw(Dumper); # Only used for commented-out test prints.


# Decides which reads in the intersects file would pass to the summary basic and looks up their names in the original FASTA. Outputs a subset of that FASTA with just those passing reads.
# Assumes the normal PIA file structure and the default minimum taxonomic diversity score of 0.1.
# Can also re-create the original summary basic if you get in here and uncomment sections. This was used for testing.
# > perl Make_post-PIA_FASTA_PIA5.pl [original FASTA]


my $original_fasta_filename = $ARGV[0];

my $intersects_filename = substr ($original_fasta_filename, 0, -5);
$intersects_filename = $intersects_filename . 'fasta.header_out';
$intersects_filename = $intersects_filename . "/$intersects_filename.intersects.txt";


# Pick out the names of reads from the intersects file that would end up in summary basic. This is a filtering step.
open(my $intersects_filehandle, $intersects_filename) or die "Cannot open $intersects_filename\n$!\n";
my @intersects_file = ();
my %reads_to_keep = ();

#my %intersects = (); # FOR MAKING A TEST SUMMARY BASIC. Keys are intersect names and IDs in the format "name (ID)". Values are the number of times that name (ID) occurs.
    
my $new_SB_filename = $original_fasta_filename . '_test_summary_basic.txt'; # FOR MAKING A TEST SUMMARY BASIC


while (1) { # Run this loop until "last" is called.
    my $line = <$intersects_filehandle>;
    if (! defined $line) { last }; # If there is no next line, exit the loop. You've processed the whole file.
    
    chomp $line;
	my @split_on_intersection = split (/intersection: /, $line); # Split on the intersection field.
	my @split_on_score = split(/ diversity score: |, phylo/, $line); # Split on the taxonomic diversity score field title followed by its comma-space. This is not an 'or'. It will split the line in two places and leave the score value as the middle element.
	if ($split_on_score[2] >= 0.1 ){ # $split_on_score[2] is the taxa diversity score.
        unless ($split_on_intersection[1] eq 'none found (0)' or $split_on_intersection[1] eq "1\troot") { # Intersects that weren't found or that equal the root of the tree are not useful. Ignore these.
            my @split_on_query = split (/Query: |, top hit: /, $line);
			$reads_to_keep{$split_on_query[1]} = undef; # Save the names of the reads in %reads_to_keep.
            
            #-------------------------------------------------------
            # FOR MAKING A TEST SUMMARY BASIC
            ## Change the format of the intersection field for outputting.
            #my $intersection_field = $split_on_intersection[1];
            #my @intersection_field = split (/ /, $intersection_field);
            #my $ID = pop @intersection_field; # The ID is the last word.
            #chomp $ID;
            #$ID =~ tr/()//d; # Remove the parentheses from it (this is transliterate with delete).
            #$intersection_field = join (" ", @intersection_field); # Join the remaining words back together. These are the taxon name.
            #my $ID_and_name = $ID . "\t" . $intersection_field; # Join the ID and name with a tab.
            #
            #if (exists $intersects{$ID_and_name}) {
            #    $intersects{$ID_and_name} = $intersects{$ID_and_name} + 1;
            #} else {
            #    $intersects{$ID_and_name} = 1;
            #}
            #-------------------------------------------------------

        }
    }
}
close $intersects_filehandle;


#-------------------------------------------------------
# FOR MAKING A TEST SUMMARY BASIC:
#
##print "Intersects hash:\n\n"; print Dumper \%intersects; print "\n\n";
#
#my @test_name = split ("\/",$intersects_filename); # Pick out the sample name from $intersecs_filename to use in the output file.
#my $test_name = 'TEST_' . $test_name[0];
#
##my $summary_basic_filename = $name."_Summary_Basic.txt";
#my $summary_basic_filename = 'test_summary_basic.txt';
#open (my $summary_basic_filehandle, '>', $test_name . '_Summary_Basic.txt') or die "Cannot write test summary basic file $test_name: $!\n";
#print $summary_basic_filehandle "#Series:\t$test_name\n"; # Output $name as a header.
#
#foreach my $intersect (keys %intersects) {
#    unless ($intersect eq "0\tnone found" or $intersect eq "1\troot") { # Intersects that weren't found or that equal the root of the tree are not useful. Ignore these.
#         print $summary_basic_filehandle "$intersect\t$intersects{$intersect}\n";
#    }
#}
#close $summary_basic_filehandle;
#-------------------------------------------------------
    
#print "Reads to keep:\n\n"; print Dumper \%reads_to_keep; print "\n\n";

# Look through the FASTA and pull out reads matching those in @reads_to_keep.
my $new_fasta_filename = $original_fasta_filename . '_postPIA.fasta';

open(my $original_fasta_filehandle, $original_fasta_filename) or die "Cannot open $original_fasta_filename\n$!\n";
open(my $new_fasta_filehandle, '>', $new_fasta_filename) or die "Cannot open $new_fasta_filename for writing\n$!\n";

$/ = ">"; # Set the record separator to "\n>", which separates FASTA records.

while (1) { # Run this loop until "last" is called.
    my $record = <$original_fasta_filehandle>;
    if (! defined $record) { last }; # If there is no next line, exit the loop. You've processed the whole file.
    
    my @record = split ("\n", $record);
    my $read_name = $record[0];
    if (exists $reads_to_keep{$read_name} ) {
        #print "Found a good read!\n";
        $record =~ s/>//g; # Remove the '>' character off the end.
        print $new_fasta_filehandle '>' . $record;
    }
}

print "\nFinished processing $original_fasta_filename\n\n";