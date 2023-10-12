#!/bio/local/gcc/bin/perl -w

use strict;
use warnings;

my $gencode_annotation = $ARGV[0];

my %ensg_recs = ();
sub get_gencode {
    open(my $input, $gencode_annotation);
    while (<$input>) {
	next if (/^#/);
	chomp;
	my ($chr, undef, $type, $start, $end, undef, undef, undef, $anno) = split("\t", $_, -1);
	next if ($type ne "gene");
	$chr =~ s/chr//;
	$chr =~ s/M/MT/;

	my ($gene, $ensg);
	foreach (split(";", $anno)) {
	    /^(.*)=(.*)/;
	    if ($1 eq "gene_id") {
		$ensg = $2;
	    } elsif ($1 eq "gene_name") {
		$gene = $2;
	    }
	}
	$ensg_recs{$ensg} = join("\t", ($chr, $gene, $ensg, $start, $end));
    }
    close($input);
}

{
    &get_gencode;
    &output;
}

sub output {
    open(my $output, ">", $ARGV[1]);
    foreach my $ensg (keys %ensg_recs) {
	print $output $ensg_recs{$ensg}."\n";
    }
    close($output);
}
