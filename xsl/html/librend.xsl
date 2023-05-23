<?xml version="1.0" encoding="UTF-8"?>
<!-- replacement of common/librend.xsl for basic text formatting in HTML output

This is to be imported once into your main stylesheet if you want basic formatting
in the base text, the apparatus and in the editorial notes. -->
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/librend.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:text="http://scdh.wwu.de/transform/text#"
    xmlns:app="http://scdh.wwu.de/transform/app#" xmlns:note="http://scdh.wwu.de/transform/note#"
    xmlns:i18n="http://scdh.wwu.de/transform/i18n#" exclude-result-prefixes="#all"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

    <xsl:mode name="text:text" on-no-match="text-only-copy" visibility="public"/>
    <xsl:mode name="app:reading-text" on-no-match="text-only-copy" visibility="public"/>
    <xsl:mode name="note:editorial" on-no-match="text-only-copy" visibility="public"/>


    <xsl:template mode="text:text app:reading-text note:editorial" match="hi[@rend eq 'bold']">
        <b>
            <xsl:call-template name="text:class-attribute-opt"/>
            <xsl:apply-templates mode="#current" select="@* | node()"/>
        </b>
    </xsl:template>

    <xsl:template mode="text:text app:reading-text note:editorial" match="hi[@rend eq 'italic']">
        <i>
            <xsl:call-template name="text:class-attribute-opt"/>
            <xsl:apply-templates mode="#current" select="@* | node()"/>
        </i>
    </xsl:template>

    <xsl:template mode="text:text app:reading-text note:editorial" match="hi[@rend eq 'underline']">
        <u>
            <xsl:call-template name="text:class-attribute-opt"/>
            <xsl:apply-templates mode="#current" select="@* | node()"/>
        </u>
    </xsl:template>

    <xsl:template mode="text:text app:reading-text note:editorial"
        match="hi[@rend eq 'superscript']">
        <sup>
            <xsl:call-template name="text:class-attribute-opt"/>
            <xsl:apply-templates mode="#current" select="@* | node()"/>
        </sup>
    </xsl:template>

    <!-- segmentation offers hooks for project-specific insertions -->
    <xsl:template mode="text:text app:reading-text note:editorial" match="seg | s | w | c | pc">
        <span>
            <xsl:call-template name="text:class-attribute"/>
            <xsl:apply-templates mode="#current" select="@* | node()"/>
        </span>
    </xsl:template>

    <!-- drop attributes for which there is not special rule -->
    <xsl:template mode="text:text app:reading-text note:editorial" match="@*"/>

    <xsl:template name="text:class-attribute" visibility="public">
        <xsl:param name="additional" as="xs:string*" select="()" required="false"/>
        <xsl:attribute name="class"
            select="(name(), $additional, @type, tokenize(@rendition) ! substring(., 2)) => string-join(' ')"/>
    </xsl:template>

    <xsl:template name="text:class-attribute-opt" visibility="public">
        <xsl:param name="additional" as="xs:string*" select="()" required="false"/>
        <xsl:if test="@type or @rendition or $additional">
            <xsl:attribute name="class"
                select="($additional, @type, tokenize(@rendition) ! substring(., 2)) => string-join(' ')"
            />
        </xsl:if>
    </xsl:template>

</xsl:package>
