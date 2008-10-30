#!/usr/bin/perl -w
#
# A script 
#  extractexamples.pl <INFILES> <PREFIX>
# which 
# - processes every input .tex file
# - extracts all tikzpicture-environments which are inside of a codeexample
# - generates <PREFIX>_<index>.tex
#
# Furthermore, it processes every LaTeX Comment which is DIRECTLY before the codeexample to export:
#
# % \usepackage{array}
# \begin{codeexample}[]
# \begin{tikzpicture}
# ...
#
# will be interpreted as required preamble-information for the gallery. Thus,
# \usepackage{array} will be included into the particular output file.
# 
# See the associated Makefile which also exports each thing into pdf and png.

$#ARGV > 0 or die('expected INFILES PREFIX.');

$OUTPREFIX=$ARGV[$#ARGV];

$header = 
'\documentclass{minimal}

\usepackage{pgfplots}

';

$plotcoord_cmd='
\addplot coordinates {
(5,8.312e-02)    (17,2.547e-02)   (49,7.407e-03)
(129,2.102e-03)  (321,5.874e-04)  (769,1.623e-04)
(1793,4.442e-05) (4097,1.207e-05) (9217,3.261e-06)
};

\addplot coordinates{
(7,8.472e-02)    (31,3.044e-02)    (111,1.022e-02)
(351,3.303e-03)  (1023,1.039e-03)  (2815,3.196e-04)
(7423,9.658e-05) (18943,2.873e-05) (47103,8.437e-06)
};

\addplot coordinates{
(9,7.881e-02)     (49,3.243e-02)    (209,1.232e-02)
(769,4.454e-03)   (2561,1.551e-03)  (7937,5.236e-04)
(23297,1.723e-04) (65537,5.545e-05) (178177,1.751e-05)
};

\addplot coordinates{
(11,6.887e-02)    (71,3.177e-02)     (351,1.341e-02)
(1471,5.334e-03)  (5503,2.027e-03)   (18943,7.415e-04)
(61183,2.628e-04) (187903,9.063e-05) (553983,3.053e-05)
};

\addplot coordinates{
(13,5.755e-02)     (97,2.925e-02)     (545,1.351e-02)
(2561,5.842e-03)   (10625,2.397e-03)  (40193,9.414e-04)
(141569,3.564e-04) (471041,1.308e-04) 
(1496065,4.670e-05)
};
';

$i = 0;

for($j = 0; $j<$#ARGV; ++$j ) {
	open FILE,$ARGV[$j] or die("could not open ".$ARGV[$j]);

	@S = stat(FILE);
	$fileSize = $S[7];
	read(FILE,$content,$fileSize) or die("could not read everything");
	close(FILE);

	@matches = ( $content =~ m/(% [^\n]*\n)*\\begin{codeexample}\[\]*\n(\\begin{tikzpicture}.*?\\end{tikzpicture})/gs );

	for( $q=0; $q<=$#matches/2; $q++ ) {
		$prefix = $matches[2*$q];
		$prefix = "" if not defined($prefix);
		next if ($prefix =~ m/NO GALLERY/);
		$prefix =~ s/% //;
		$match = $matches[2*$q+1];
		$match =~ s/\\plotcoords/$plotcoord_cmd/o;
		$outfile = $OUTPREFIX."_".($i++).".tex";
#print "$i PREFIX: ".$prefix."\n";
#print "$i : ".$match."\n\n";
#next;
		open(OUTFILE,">",$outfile) or die( "could not open $outfile for writing");
		print OUTFILE $header;
		print OUTFILE $prefix;
		print OUTFILE "\n\\begin{document}\n";
		print OUTFILE $match;
		print OUTFILE "\n\\end{document}\n";
		close(OUTFILE);
	}

}
print "Exported ".$i." examples.\n";
exit 0
