#!/bin/sh

JARS=${project.build.directory}/lib/Saxon-HE-${saxon.version}.jar
JARS=$JARS:${project.build.directory}/lib/xmlresolver-${xmlresolver.version}.jar
JARS=$JARS:${project.build.directory}/lib/xercesImpl-${xerces.version}.jar

java -Ddebug="true" -Dhttp://apache.org/xml/features/xinclude/fixup-base-uris=true -cp $JARS net.sf.saxon.Transform $@
