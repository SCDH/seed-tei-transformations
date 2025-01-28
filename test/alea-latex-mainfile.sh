#!/bin/sh

# USAGE: $0 SOURCE RELATIVE_OUTPUT SUBFILES

INPUT=$1

SUBFILES=$3

seed="${SEED_TEI_TRANSFORMATIONS:=$(dirname $(realpath $0))/..}"

edition="${EDITION:=$(realpath ~/Projekte/edition-ibn-nubatah)}"

mkdir -p $edition/tex

OUTPUT=$edition/tex/$2

#OUTPUT=$EDITION/Test/test.tex

XSLT_LOG=$OUTPUT.transform.log


STYLESHEET=$seed/xsl/projects/alea/latex/preamble.xsl

PARAMS="{http://scdh.wwu.de/transform/edmac#}section-workaround=true {http://scdh.wwu.de/transform/rend#}index-styles=alea.ist"

FONTPARAMS="font=ArabicTypesetting fontsize=20pt fontfeatures=AutoFakeBold=1.0"

XSLT_CMD=$seed/target/bin/xslt.sh

set -x

$XSLT_CMD -config:$seed/saxon.he.xml -xsl:$STYLESHEET -xi -it:{http://scdh.wwu.de/transform/preamble#}mainfile -s:$INPUT $PARAMS $FONTPARAMS {http://scdh.wwu.de/transform/preamble#}subfiles-csv=$SUBFILES -o:$OUTPUT  2> $XSLT_LOG
