#!/bin/sh

CP=$CLASSPATH
for j in ${project.build.directory}/lib/*.jar; do
    CP=$CP:$j
done


java -Ddebug="true" -Dhttp://apache.org/xml/features/xinclude/fixup-base-uris=true -cp $CP net.sf.saxon.Transform $@
