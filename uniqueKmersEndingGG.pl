#!/usr/bin/perl

# This perl program finds kmers in the 2L chromosome of Drosophila melanogaster, sets the window size to 23 and checks for kmers ending in GG, loads them to a hash and prints out the first 1000 that occur once.
use strict;
use warnings;
use diagnostics;
#Call subroutine to load all sequences into a string.
my $sequenceRef = loadSequence("/scratch/Drosophila/dmel-2L-chromosome-r5.54.fasta");
#set the window size
my $windowSize = 23;
#set the step size
my $stepSize = 1;
#initialise hash
my %kmerHash;
#Loop through and get sequences using sliding window
for (
#Initialise window start
		my $windowStart = 0;
#Check to make sure you're not past the end of the string
		$windowStart <= ( length($$sequenceRef) - $windowSize );
#Move the sliding window
		$windowStart += $stepSize
    )
{
#Get the substring
	my $windowSeq = substr($$sequenceRef, $windowStart, $windowSize);
	for ($windowSeq =~/([ATGC]{21}.*GG)/g) {
#add substring to kmer hash
		$kmerHash{$1}++;
	}
}
#Open a filehandle for writing
	open(KMERS, ">", 'uniqueKmersEndingGG.fasta') or die $!;
	my $counter = 0;
#loop through the Kmer hash
	foreach my $kmer (keys %kmerHash){
		if ($kmerHash{$kmer} ==1) {
			$counter ++;
			if ($counter <1001) {
#print the kmer and count
				print KMERS ">crispr_", $counter, "\n", $kmer, "\n";
			}
		}
	}
#Load the FASTA sequence into a scalar reference
	sub loadSequence {
#Get the parameters passed to the subroutine
		my ($sequenceFile) = @_;
#Intialise the sequence
		my $sequence = "";
#Open the filehandle
		open( FASTA, "<", $sequenceFile ) or die "Can't open", $!;
#Loop through the file line by line
	while (<FASTA>) {
		my $line = $_;
		chomp($line);
#If it's not a header line
		if ($line !~ /^>/) {
#Append sequence line.
			$sequence .= $line;
		}
	}
#return a reference to the sequence variable
	return \$sequence;
}
#close filehandles
close KMERS;
close FASTA;
