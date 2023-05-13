#!/bin/sh

ant -lib target/lib/Saxon-HE-${saxon.version}.jar -lib target/lib/xmlresolver-${xmlresolver.version}.jar -Dxspec.version=${xspec.version} $@
