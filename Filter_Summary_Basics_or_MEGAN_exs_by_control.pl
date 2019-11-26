#!/usr/bin/perl 

	use strict;
	use warnings;
    use Getopt::Std;
	use Data::Dumper qw(Dumper);

# Filters at least one PIA Summary Basic or MEGAN "-ex" file by a corresponding negative control. Taxa present in the control are not automatically excluded. Instead, this script accepts taxa in the control if the number of control hits is below x % of the number of hits in the sample. x is an option but defaults to 0.02.
# To run:
# > perl Filter_Summary_Basics_or_MEGAN_exs_by_control.pl -t [optional new threshold] -c [control] [at least one sample] 


# Setting up
#-----------
my %options = ();
getopts('t:c:h', \%options);

if ($options{h}) { # If the help option is called, print the help text and exit.
    print "Usage: perl Filter_Summary_Basics_or_MEGAN_exs_by_control.pl [-tch] [summary basics or MEGAN ex files]

Option	Description			Explanation
-t	Threshold		Exclusion threshold. Defaults to 0.02%.
-c	Control file name			Control file to filter the samples against.
-h	Help				Print this message.

Other arguments	    Description
[sample files]    At least one summary basic or MEGAN ex file to filter.

";
	exit;
}

print "\n";
my $threshold = 0.02; # Default path to full taxonomy file (assumes that this is the PIA directory).
if ($options{t}) { # If the full taxonomy option is called, overwrite the default with the option input.
    $threshold = $options{t};
    print "Threshold set to 0.02 %. ";
}
print "Taxa pass if their number of hits in the negative control is <$threshold % of their hits in the sample file.\n\n";

unless ($options{c}) { # If the full taxonomy option is called, overwrite the default with the option input.
    print "Use -c to specify a control file.\n";
    exit;
}
my $control_filename = $options{c};


my @sample_filenames = @ARGV; # Any other arguments are sample files.


# Read in the control data
#-------------------------
open (my $control_filehandle, $control_filename) or die "Could not open control file $control_filename: $!\n";
my %control_data = ();

foreach my $line (readline($control_filehandle)) {
    
        if (index ($line, '#') != -1) { next; } # Skip any header lines.
        
        my @line = split ("\t", $line); # Split on tabs.
        my $count = pop @line;
        chomp $count;
        
        if ($count == 0) { next; } # MEGAN -ex files can have a count of 0 because it records (I think) parent nodes. Skip the taxon if this is the case.
        
        my $taxon = join ("\t", @line); # Join the rest of the line back together again to account for different numbers of fields.
        
        if (exists $control_data{$taxon} ) { # Save in the hash.
            $control_data{$taxon} = $control_data{$taxon} + $count;
        } else {
            $control_data{$taxon} = $count;
        }
}
close $control_filehandle;
#print "Control data:\n"; print Dumper \%control_data; print "\n\n";


# Read in the sample data
#------------------------
print "Working on samples:\n";
foreach my $sample_filename (@sample_filenames) {
    print "\t$sample_filename\n";
    
    open (my $sample_filehandle, $sample_filename) or die "Could not open sample file $sample_filename: $!\n";
    my @sample_header = ();
    my %sample_data = ();
    
    foreach my $line (readline($sample_filehandle)) {
            
            if (index ($line, '#') != -1) { # Save any header lines.
                push (@sample_header, $line);
                next;
            }
            
            my @line = split ("\t", $line); # Split on tabs.
            my $count = pop @line;
            chomp $count;
            
            if ($count == 0) { next; } # MEGAN -ex files can have a count of 0 because it records (I think) parent nodes. Skip the taxon if this is the case.
            
            my $taxon = join ("\t", @line); # Join the rest of the line back together again to account for different numbers of fields.
    
            if (exists $sample_data{$taxon} ) { # Save in the hash.
                $sample_data{$taxon} = $sample_data{$taxon} + $count;
            } else {
                $sample_data{$taxon} = $count;
            }
            
    }
    close $sample_filehandle;
    #print "Sample data:\n"; print Dumper \%sample_data; print "\n\n";
    
    
    # Look for control taxa in the sample data.
    foreach my $ID (keys %control_data) {
        if (exists $sample_data{$ID}) {
            my $count_ratio = $control_data{$ID} / $sample_data{$ID};
            #print "ID: $ID\tControl: $control_data{$ID}\tSample: $sample_data{$ID}\tRatio: $count_ratio\n";
            if ($count_ratio >= $threshold) { delete $sample_data{$ID}; } # If the ratio between counts in the control and sample is at least $threshold, delete this ID from the sample data.
        }
    }
    
    
    # Export the pruned sample data
    #------------------------------
    if (%sample_data) {
        my $output_filename = $sample_filename . '_pruned.txt';
        open (my $output_filehandle, '>', $output_filename) or die "Could not open $output_filename for writing: $!\n";
        
        print $output_filehandle "# Sample $sample_filename pruned using $control_filename and threshold $threshold\n#\n"; # Print a note detailing the pruning.
        
        if (@sample_header) {
            foreach my $header_line (@sample_header) { # Print the original header if there was one.
                print $output_filehandle $header_line;
            }
        }
        
        foreach my $ID_and_name (keys %sample_data) {
            print $output_filehandle "$ID_and_name\t" . $sample_data{$ID_and_name} . "\n";
        }
    } else {
        print "\t\tNo sample data survived pruning.\n";
    }
}

print "\nDone\n\n";
