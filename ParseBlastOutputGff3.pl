#!/usr/bin/perl

# This perl program BLASTs uniqueKmersEndingGG.fasta against BLAST DB Drosophila2L and converts the BLAST output lines with 100% identity to GFF3 format.
# The lines with less than 100% identity are written to offTarget.txt.
# crispr.gff3 contains the GFF3 output.
use strict;
use warnings;
use diagnostics;
unless (open(GFF3, ">", 'crispr.gff3')) {
	die $!;
}
unless (open(OFFTARGET, ">", 'offTarget.txt')){
	die $!;
}
blastOligos();
sub blastOligos {
#
	my @commandAndParams = ('blastn','-task blastn','-db Drosophila2L', '-query ~/BIOL6308/LAB_11/uniqueKmersEndingGG.fasta', '-outfmt 6');
#print the BLAST command for debugging.
	print "@commandAndParams\n";
#run
	open(BLAST, "@commandAndParams |");
#process blast output line by line
	while (<BLAST>) {
#get rid of endline characters
		chomp;
#assigning the line of output from default variable $_
		my $blastOutputLine = $_;
		processBlastOutputLine($blastOutputLine);
	}
}
sub processBlastOutputLine {
	my ($blastOutputLine) = @_;
#if the output line isn't a comment line
	if ($blastOutputLine !~ /^#/) {
#split output line using tab separator
		my @blastColumns = split( "\t", $blastOutputLine);
#assign column positions to variables
		my ($queryId, $chrom, $identity, $length, $mismatches, $gaps, $qstar, $qEnd, $Start, $End) = @blastColumns;
		my $strand = '+';
		my $gffStart = 0;
		my $gffEnd = 0;
		if ($Start > $End ){
			$strand = '-';
			$gffStart = int $End;
			$gffEnd = int $Start;
		}
		else {
			$gffStart = int $Start;
			$gffEnd = int $End;
		}
#put variables required for gff3 record in an array in order that should appear in output file
		my @rowArray;
		@rowArray = ($chrom, ".", 'OLIGO', $gffStart, $gffEnd, ".", $strand, ".", "Name=$queryId;Note=Some info on this oligo");
#change field seaprator to tab
		local $, = "\t";
#checking for identity if 100% print to GFF3 file handle
		if($identity == 100){
			print GFF3 @rowArray, "\n";
		}
#if identity is less than 100% print to OFFTARGET file handle
		else {
			print OFFTARGET $blastOutputLine,"\n";
		}
	}
}
#close file handles.
close GFF3; 
close OFFTARGET;
