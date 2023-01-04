<?xml version="1.0" encoding="UTF-8"?>
<!-- A TEI document may contain full witness information
    or only stubs that relate to a witnesses in central catalog.

    This is an XSLT library to deal with this.
    It hides away the details of the witness catalog and provides lookup functions.

    See used package .../xsl/common/libwit.xsl
-->
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libwit.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:wit="http://scdh.wwu.de/transform/wit#"
    xmlns:app="http://scdh.wwu.de/transform/app#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    version="3.0">

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libwit.xsl"
        package-version="1.0.0">
        <xsl:accept component="function" names="wit:sigla-for-idrefs#1" visibility="public"/>
        <xsl:accept component="variable" names="wit:*" visibility="public"/>
        <xsl:accept component="variable" names="wit:witnesses" visibility="abstract"/>
    </xsl:use-package>

    <xsl:expose component="template" names="wit:sigla" visibility="public"/>
    <xsl:expose component="template" names="app:sigla" visibility="public"/>

    <xsl:template name="wit:sigla">
        <xsl:param name="wit" as="node()"/>
        <span class="siglum">
            <xsl:for-each select="wit:sigla-for-idrefs($wit)">
                <xsl:value-of select="."/>
                <xsl:if test="position() ne last()">
                    <span data-i18n-key="witness-sep">, </span>
                </xsl:if>
            </xsl:for-each>
        </span>
    </xsl:template>

    <!-- this can be used to override the named template in libapp2.xsl -->
    <xsl:template name="app:sigla" visibility="public">
        <xsl:param name="wit" as="node()"/>
        <xsl:call-template name="wit:sigla">
            <xsl:with-param name="wit" select="$wit"/>
        </xsl:call-template>
    </xsl:template>

</xsl:package>
