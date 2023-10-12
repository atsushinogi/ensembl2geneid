#!/home/next_generation_seq/snp/software/perl/bin/perl

use strict;
use Data::Dumper;
use IO::File;
use Text::CSV_XS;
use Tabix;
use IO::File;
use FindBin;

my $gene_region 	= "ref_GRCh38.p2_top_level.gene.gff3.gz";
my $gene_region_idx 	= "ref_GRCh38.p2_top_level.gene.gff3.gz.tbi";
my $gene_region_tbx 	= Tabix->new( -index => $gene_region_idx, -data => $gene_region );

{
    open(my $input, $ARGV[0]);
    my @ensg_recs = <$input>;
    close($input);

    open(my $output, ">", $ARGV[1]);
    foreach (@ensg_recs) {
	chomp;
	my ($chr, $gene, $ensg, $start, $end) = split /\t/;

	my @refseq_recs = ();
	( @refseq_recs ) = execTabixByPos( $gene_region_tbx, $chr, $start, $end );

	next if (@refseq_recs == 0);

	foreach (@refseq_recs) {
	    my ($chr2, $gene2, $geneid, $start2, $end2) = split /\t/;

	    next if ($gene ne $gene2 and $chr.":".$start."-".$end ne $chr2.":".$start2."-".$end2);

	    print $output join("\t", (
			   $chr, $start, $end, $gene, $ensg,
			   $chr2, $start2, $end2, $gene2, $geneid
			   ))."\n";
	}
    }
    close($output);
}

sub execTabixByPos( $$$$ ) {
	my ( $tabix_obj, $seqid, $start_pos, $end_pos ) = @_;
	my @result = ();
	my $res_obj = $tabix_obj->query( $seqid, $start_pos, $end_pos );
	while ( my $rec = $tabix_obj->read( $res_obj ) ) {
		push @result, $rec;
	}
	return ( @result );
}
