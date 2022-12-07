<?xml version="1.0" encoding="UTF-8"?>
<!-- A TEI document may contain full witness information
    or only stubs that relate to a witnesses in central catalog.

    This is an XSLT library to deal with this.
    It hides away the details of the witness catalog and provides lookup functions.
    It takes an XPath expression as parameter that tells, where the information is stored.
-->
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libwit.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:wit="http://scdh.wwu.de/transform/wit#"
    xmlns:app="http://scdh.wwu.de/transform/app#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs wit"
    version="3.0">

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libwit.xsl"
        package-version="1.0.0"/>

    <xsl:expose component="template" names="app:sigla" visibility="public"/>

    <xsl:template name="app:sigla">
        <xsl:param name="wit" as="xs:string"/>
        <span class="siglum">
            <xsl:for-each select="wit:get-witness-siglum-seq($wit)">
                <xsl:value-of select="."/>
                <xsl:if test="position() ne last()">
                    <span data-i18n-key="witness-sep">, </span>
                </xsl:if>
            </xsl:for-each>
        </span>
    </xsl:template>

</xsl:package>
