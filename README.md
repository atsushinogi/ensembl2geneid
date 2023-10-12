Ensembl ID, Gene ID 対応表
=========================

Ensembl ID または Gene Symbol から対応する Entrez GeneID を取得する。

### GENCODE サイトよりEnsembl gene IDアノテーションファイル取得

ftp://ftp.sanger.ac.uk/pub/gencode/Gencode_human/release_23/gencode.v23.annotation.gff3.gz

### RefSeq よりGeneIDアノテーションファイル取得

ftp://ftp.ncbi.nlm.nih.gov/genomes/H_sapiens/GFF/ref_GRCh38.p2_top_level.gff3.gz

### 遺伝子領域のアノテーション行に限定

    $ ./gencode_gene.pl gencode.v23.annotation.gff3 gencode.v23.annotation.gene.gff3
    $ ./ref_gene.pl ref_GRCh38.p2_top_level.gff3 ref_GRCh38.p2_top_level.gene.gff3

### ensembl と GeneID アノテーションの各行で座標の重なりを比較してマージ

    $ bgzip ref_GRCh38.p2_top_level.gene.gff3
    $ tabix -p gff ref_GRCh38.p2_top_level.gene.gff3.gz
    $ ./ref_gencode_region.pl gencode.v23.annotation.gene.gff3 ensembl_geneid.txt

### 以下の条件１または条件２を満たすものから、ensembl⇔GeneID変換表が得られる。

     条件1： 遺伝子領域の始点、終点座標が一致する。
     条件2： 遺伝子領域が部分的に重なっており、かつ遺伝子名が一致する。
