#!/usr/bin/perl 

	use strict;
	use warnings;
	use Data::Dumper qw(Dumper);

# 2020-05-22
# Converts either PIA Summary Basics or MEGAN taxonID-to-count -ex files to something that Krona can use to make a taxonomy chart.
# The output file contains a single column: #taxID. Each ID represents one hit to that taxon.
# To run:
# > perl Convert_Summary_Basic_or_MEGAN_ex_for_Krona.pl [at least one input file]

my @input_filenames = @ARGV;

print "Working on:\n";

foreach my $input_filename (@input_filenames) {
    print "\t$input_filename\n";

    my $output_filename = $input_filename . '_forKrona.txt'; # If an output filename is not given, make it an extention of the input filename.
    
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
    close $output_filehandle;

}


print "\n\nFinished converting. Remember to specify '-t 1' when running Krona.\n\n";