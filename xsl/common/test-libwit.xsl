<?xml version="1.0" encoding="UTF-8"?>
<!-- libwit.xsl has an abstract variable, this package defines it for testing purpose -->
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/test-libwit.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:wit="http://scdh.wwu.de/transform/wit#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs wit"
    version="3.0">

    <xsl:param name="wit-catalog" as="xs:string" select="'../../test/samples/witnesses.xml'"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libwit.xsl"
        package-version="1.0.0">
        <xsl:accept component="*" names="*" visibility="public"/>
        <xsl:override>
            <xsl:variable name="wit:witnesses" as="element()*">
                <xsl:choose>
                    <xsl:when test="$wit-catalog eq string()">
                        <xsl:sequence select="//sourceDesc//witness[@xml:id]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- a sequence from external and local witnesses -->
                        <xsl:sequence select="
                            (//sourceDesc//witness[@xml:id],
                            doc($wit-catalog)/descendant::witness[@xml:id])
                            [descendant::abbr[@type eq 'siglum']]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
        </xsl:override>
    </xsl:use-package>

</xsl:package>
