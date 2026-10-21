#!/usr/bin/perl

# ClosestGene.pl

use strict;
use warnings;

my ($peakfile, $outfile);
$peakfile = $ARGV[0];
$outfile = $ARGV[1];

open PEAKS, $peakfile or die "Unable to open file $peakfile for reading data: $!\n";
open OUT, ">$outfile"
   or die "Can't open '$outfile' for output: $!";
print OUT "Peak Number\tEnrichment Factor\tChromosome\tMax Position\tStart\tEnd\tSize\tGene Locus\tDistance\tStrand\tGene Name\tGene Product\tCOG\n";

my $linecount = 0;
my (@line, @closeline);
my ($peaknum, $currentline, $savedline, $peakdis, $newpeaknum, $newpeakdis);
$peaknum = 0;

while (<PEAKS>) {
  chomp;
  $linecount ++;
  if ($linecount == 1) {next;}
  $currentline = $_;
  @line = split ( /\t/, $currentline);
  $newpeaknum = $line[0];
  $newpeakdis = $line[8];
  if (abs($newpeakdis) > 500) {
    next;
  }
  if ($peaknum == 0) {
    $peaknum = $newpeaknum;
    $peakdis = $newpeakdis;
    $savedline = $currentline;
  }
  elsif ($newpeaknum == $peaknum) {
    if (abs($newpeakdis) < abs($peakdis)) {
      $peakdis = $newpeakdis;
      $savedline = $currentline;
    }
  }
  else {
    print OUT "$savedline\n";
    $peaknum = $newpeaknum;
    $peakdis = $newpeakdis;
    $savedline = $currentline;
  }
}
close PEAKS;
print OUT "$savedline\n";
close OUT;



	
