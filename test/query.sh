#!/bin/sh

JARS=${project.build.directory}/lib/Saxon-HE-${saxon.version}.jar
JARS=$JARS:${project.build.directory}/lib/xmlresolver-${xmlresolver.version}.jar

java -Ddebug="true" -cp $JARS net.sf.saxon.Query $@
