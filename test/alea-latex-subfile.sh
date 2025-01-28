#!/bin/sh

# USAGE: SOURCE RELATIVE_OUTPUT RELATIVE_MAINFILE

INPUT=$1

MAINFILE=$3

seed="${SEED_TEI_TRANSFORMATIONS:=$(dirname $(realpath $0))/..}"

edition="${EDITION:=$(realpath ~/Projekte/edition-ibn-nubatah)}"

mkdir -p $edition/tex

OUTPUT=$edition/tex/$2

XSLT_LOG=$OUTPUT.transform.log


STYLESHEET=$seed/xsl/projects/alea/latex/prose.xsl

PARAMS="wit-catalog=$EDITION/WitnessCatalogue.xml {http://scdh.wwu.de/transform/edmac#}pstart-opt=\noindent {http://scdh.wwu.de/transform/edmac#}section-workaround=true {http://scdh.wwu.de/transform/rend#}index-styles=alea.ist"

FONTPARAMS="font=ArabicTypesetting fontsize=20pt fontfeatures=AutoFakeBold=1.0"

XSLT_CMD=$seed/target/bin/xslt.sh

set -x

$XSLT_CMD -config:$seed/saxon.he.xml -xsl:$STYLESHEET -xi -s:$INPUT $PARAMS $FONTPARAMS {http://scdh.wwu.de/transform/preamble#}mainfile=$MAINFILE -o:$OUTPUT  2> $XSLT_LOG # && cd $(dirname $OUTPUT) && latexmk -lualatex $OUTPUT

#cd $OLDPWD

echo "Output written to $OUTPUT"
