<?xml version="1.0" encoding="UTF-8"?>
<!-- generic XSLT package for basic text formatting

This is to be imported once into your main stylesheet if you want basic formatting
in the base text, the apparatus and in the editorial notes. -->
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/librend.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:text="http://scdh.wwu.de/transform/text#"
    xmlns:app="http://scdh.wwu.de/transform/app#" xmlns:note="http://scdh.wwu.de/transform/note#"
    xmlns:i18n="http://scdh.wwu.de/transform/i18n#" exclude-result-prefixes="#all"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libi18n.xsl"
        package-version="0.1.0">
        <xsl:accept component="template" names="i18n:lang-attributes" visibility="private"/>
    </xsl:use-package>


    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <xsl:mode name="text:text" visibility="public"/>
    <xsl:mode name="app:reading-text" visibility="public"/>
    <xsl:mode name="note:editorial" visibility="public"/>

    <xsl:template mode="text:text app:reading-text note:editorial" match="hi[@rend eq 'bold']">
        <b>
            <xsl:call-template name="i18n:lang-attributes">
                <xsl:with-param name="context" select="."/>
            </xsl:call-template>
            <xsl:apply-templates mode="#current"/>
        </b>
    </xsl:template>

    <xsl:template mode="text:text app:reading-text note:editorial" match="hi[@rend eq 'italic']">
        <i>
            <xsl:call-template name="i18n:lang-attributes">
                <xsl:with-param name="context" select="."/>
            </xsl:call-template>
            <xsl:apply-templates mode="#current"/>
        </i>
    </xsl:template>

    <xsl:template mode="text:text app:reading-text note:editorial" match="hi[@rend eq 'underline']">
        <u>
            <xsl:call-template name="i18n:lang-attributes">
                <xsl:with-param name="context" select="."/>
            </xsl:call-template>
            <xsl:apply-templates mode="#current"/>
        </u>
    </xsl:template>

    <xsl:template mode="text:text app:reading-text note:editorial"
        match="hi[@rend eq 'superscript']">
        <sup>
            <xsl:call-template name="i18n:lang-attributes">
                <xsl:with-param name="context" select="."/>
            </xsl:call-template>
            <xsl:apply-templates mode="#current"/>
        </sup>
    </xsl:template>

    <xsl:template mode="text:text app:reading-text note:editorial"
        match="title[@type eq 'lemma'] | q | quote">
        <xsl:variable name="content">
            <xsl:apply-templates mode="#current"/>
        </xsl:variable>
        <span>
            <xsl:call-template name="i18n:lang-attributes">
                <xsl:with-param name="context" select="."/>
            </xsl:call-template>
            <xsl:value-of select="concat('“', normalize-space($content), '”')"/>
        </span>
    </xsl:template>

    <xsl:template mode="text:text app:reading-text note:editorial"
        match="seg[matches(@type, 'booktitle')] | title">
        <i>
            <xsl:call-template name="i18n:lang-attributes">
                <xsl:with-param name="context" select="."/>
            </xsl:call-template>
            <xsl:apply-templates mode="#current"/>
        </i>
    </xsl:template>

</xsl:package>
