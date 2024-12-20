#!/bin/sh

INPUT=$1

OUTPUT=/tmp/test.tex

XSLT_LOG=$OUTPUT.transform.log

SEED_DIR=$(dirname $(realpath $0))/..

EDITION=$(realpath ~/Projekte/edition-ibn-nubatah)

STYLESHEET=$SEED_DIR/xsl/projects/alea/latex/prose.xsl

PARAMS="wit-catalog=$EDITION/WitnessCatalogue.xml {http://scdh.wwu.de/transform/edmac#}pstart-opt=\noindent {http://scdh.wwu.de/transform/edmac#}section-workaround=true {http://scdh.wwu.de/transform/rend#}indices-csv=person,place,org,event,surah,poem"

FONTPARAMS="font=ArabicTypesetting fontsize=15pt fontscale=1.4 fontfeatures=,AutoFakeBold=2.5"

XSLT_CMD=$SEED_DIR/target/bin/xslt.sh

#echo "$XSLT_CMD -config:$SEED_DIR/saxon.he.xml -xsl:$STYLESHEET -s:$INPUT $PARAMS -o:$OUTPUT && latexmk -lualatex $OUTPUT"
set -x

$XSLT_CMD -config:$SEED_DIR/saxon.he.xml -xsl:$STYLESHEET -xi -s:$INPUT $PARAMS $FONTPARAMS -o:$OUTPUT  2> $XSLT_LOG && cd $(dirname $OUTPUT) && latexmk -lualatex $OUTPUT

cd $OLDPWD

echo "Output written to $OUTPUT"
