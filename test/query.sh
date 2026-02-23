#!/bin/sh

CP=$CLASSPATH
for j in ${project.build.directory}/lib/*.jar; do
    CP=$CP:$j
done

java -Ddebug="true" -cp $CP net.sf.saxon.Query $@
