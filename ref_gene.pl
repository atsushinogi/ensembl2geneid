#!/bio/local/gcc/bin/perl -w

use strict;
use warnings;
use bigint;
use DBI;

sub get_hash_ref {
    my ($hash, $key, $ref) = @_;
    if (!exists($hash->{$key})) {
        $hash->{$key} = $ref;
    }
    return $hash->{$key};
}

{
    open(my $input, $ARGV[0]);

    my %gene = ();
    while (<$input>) {
	chomp;
	my @cols = split(/\t/, $_, -1);
	next if (@cols < 9);
	my ($nc, undef, $type, $start, $end, undef, undef, undef, $attr) = @cols;
	next if ($nc !~ /NC_0/);
	next if ($type ne "gene");

	my $gene = "";
	my $geneid = "";
	foreach (split(/;/, $attr)) {
	    if (/gene=/) {
		s/gene=//;
		$gene = $_;
	    }
	    if (/Dbxref/) {
		s/Dbxref=//;
		foreach (split(/,/, $_)) {
		    if (/GeneID/) {
			s/GeneID://;
			$geneid = $_;
			last;
		    }
		}
	    }
	}
	next if ($gene eq "" || $geneid eq "");

	$nc =~ s/NC_0*(.*)\..*/$1/;
	my $chr = $nc;
	if ($chr eq "23") {
	    $chr = "X";
	} elsif ($chr eq "24") {
	    $chr = "Y";
	} elsif ($chr eq "12920") {
	    $chr = "MT";
	}

	my $key = sprintf("%05d%09d%09d%10d", $nc, $start, $end, $geneid);
	my $ref = &get_hash_ref(\%gene, $key, [ $chr, $gene, $geneid, $start, $end ]);
    }
    close($input);

    open(my $output, ">", $ARGV[1]);
    foreach (sort keys %gene) {
	my $ref = $gene{$_};
	print $output join("\t", @$ref)."\n";
    }
    close($output)
}
