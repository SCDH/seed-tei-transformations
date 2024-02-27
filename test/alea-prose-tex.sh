#!/bin/sh

INPUT=$1

OUTPUT=/tmp/test.tex

SEED_DIR=$(dirname $(realpath $0))/..

STYLESHEET=$SEED_DIR/xsl/projects/alea/latex/prose.xsl

PARAMS="wit-catalog=$(realpath test/alea/WitnessCatalogue.xml) {http://scdh.wwu.de/transform/edmac#}pstart-opt=[\noindent\setRL]"

#FONTPARAMS="font=ArabicTypesetting fontsize=15pt fontscale=1.4"

XSLT_CMD=$SEED_DIR/target/bin/xslt.sh

#echo "$XSLT_CMD -config:$SEED_DIR/saxon.he.xml -xsl:$STYLESHEET -s:$INPUT $PARAMS -o:$OUTPUT && latexmk -lualatex $OUTPUT"
set -x

$XSLT_CMD -config:$SEED_DIR/saxon.he.xml -xsl:$STYLESHEET -s:$INPUT $PARAMS $FONTPARAMS -o:$OUTPUT && cd $(dirname $OUTPUT) && latexmk -lualatex $OUTPUT

cd $OLDPWD

echo "Output written to $OUTPUT"
