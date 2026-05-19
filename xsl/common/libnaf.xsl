<?xml version="1.0" encoding="UTF-8"?>
<!-- Utilities for Name Authority Files

Potentially, this package should know and list all NAFs.
However, it comes with reasonable guessing.
-->
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libnaf.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:naf="http://scdh.wwu.de/transform/naf#"
    exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0" default-mode="naf:label">

    <xsl:mode name="naf:label" on-no-match="shallow-skip" visibility="public"/>

    <xsl:template match="idno[@type]" priority="10">
        <xsl:value-of select="@type"/>
    </xsl:template>

    <xsl:template match="idno[@xml:base]">
        <xsl:variable name="from-templates" as="xs:string*">
            <xsl:apply-templates select="@xml:base"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$from-templates">
                <xsl:value-of select="$from-templates"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="(replace(@xml:base, '(^[a-z]*://?)', '') => replace('/.*$', '') => tokenize('\.'))[last() - 1]"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:package>
