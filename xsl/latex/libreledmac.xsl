<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT package with components for using reledmac for critical editions -->
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libreledmac.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    version="3.0">

    <!-- modes for generating IDs used as labels in reledmac -->

    <xsl:mode name="edlabel-start" on-no-match="shallow-skip" visibility="public"/>
    <xsl:mode name="edlabel-end" on-no-match="shallow-skip" visibility="public"/>

    <xsl:template mode="edlabel-start"
        match="app[//variantEncoding/@method eq 'parallel-segmentation']">
        <xsl:value-of select="concat(generate-id(), '-start')"/>
    </xsl:template>

    <xsl:template mode="edlabel-end"
        match="app[//variantEncoding/@method eq 'parallel-segmentation']">
        <xsl:value-of select="concat(generate-id(), '-end')"/>
    </xsl:template>

    <xsl:template mode="edlabel-start"
        match="app[//variantEncoding/@method ne 'parallel-segmentation' and @from]">
        <xsl:message>
            <xsl:text>start edlabel </xsl:text>
            <xsl:value-of select="@from"/>
        </xsl:message>
        <xsl:value-of select="substring(@from, 2)"/>
    </xsl:template>

    <xsl:template mode="edlabel-end"
        match="app[//variantEncoding/@method ne 'parallel-segmentation']">
        <xsl:value-of select="generate-id()"/>
    </xsl:template>

    <xsl:template mode="edlabel-start" match="*">
        <xsl:message terminate="yes">
            <xsl:text>ERROR: no rule for making start edlabel for </xsl:text>
            <xsl:value-of select="name(.)"/>
            <xsl:text> in </xsl:text>
            <xsl:value-of select="//variantEncoding/@method"/>
        </xsl:message>
    </xsl:template>

    <xsl:template mode="edlabel-end" match="*">
        <xsl:message terminate="yes">
            <xsl:text>ERROR: no rule for making end edlabel for </xsl:text>
            <xsl:value-of select="name(.)"/>
            <xsl:text> in </xsl:text>
            <xsl:value-of select="//variantEncoding/@method"/>
        </xsl:message>
    </xsl:template>

</xsl:package>
