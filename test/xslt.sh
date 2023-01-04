#!/bin/sh

java -Ddebug="true" -cp target/lib/Saxon-HE-${saxon.version}.jar:target/lib/xmlresolver-${xmlresolver.version}.jar net.sf.saxon.Transform $@
