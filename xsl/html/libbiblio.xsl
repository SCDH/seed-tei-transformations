<?xml version="1.0" encoding="UTF-8"?>
<!-- An XSLT package for printing references by pulling in information from the bibliography.

This library offers a named template as an entry point for printing
a bibliographic reference.

USAGE:


    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libbiblio.xsl"
        package-version="1.0.0"/>
        
    <xsl:template match="bibl">
        <xsl:call-template name="biblio:reference"/>
    </xsl:template>


-->
<!DOCTYPE stylesheet [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
    <!ENTITY nbsp "&#xa0;" >
    <!ENTITY emsp "&#x2003;" >
    <!ENTITY lb "&#xa;" >
]>
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libbiblio.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ref="http://scdh.wwu.de/transform/ref#"
    xmlns:i18n="http://scdh.wwu.de/transform/i18n#"
    xmlns:biblio="http://scdh.wwu.de/transform/biblio#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    version="3.0">

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libi18n.xsl"
        package-version="0.1.0">
        <xsl:accept component="variable" names="i18n:default-language" visibility="abstract"/>
    </xsl:use-package>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libref.xsl"
        package-version="1.0.0"/>

    <!-- whether or not to pull in bibliographic entry for an empty <bibl> element with @corresp -->
    <xsl:param name="biblio:empty-reference-autotext" as="xs:boolean" select="true()"/>


    <xsl:mode name="biblio:reference" on-no-match="shallow-skip" visibility="public"/>

    <!-- a starting point for switching to mode biblio:reference which's templates will called on the context item -->
    <xsl:template name="biblio:reference" visibility="final">
        <xsl:context-item as="element(bibl)" use="required"/>
        <xsl:apply-templates select="." mode="biblio:reference"/>
    </xsl:template>

    <!-- bibliographic reference that pulls in text from the bibliography -->
    <xsl:template
        match="bibl[@corresp and matches(string-join(child::node() except child::biblScope, ''), '^\W*$') and $biblio:empty-reference-autotext]"
        mode="biblio:reference">
        <xsl:variable name="biblnode" select="."/>
        <xsl:variable name="ref" as="element()*"
            select="(ref:references-from-attribute(@corresp)[1] => ref:dereference(.)) treat as element()*"/>
        <xsl:variable name="ref-lang" select="i18n:language(($ref, .)[1])"/>
        <span class="bibliographic-reference" lang="{i18n:language(($ref, .)[1])}"
            style="direction:{i18n:language-direction(($ref, .)[1])};">
            <!-- This must be paired with pdf character entity,
                        because directional embeddings are an embedded CFG! -->
            <xsl:value-of select="i18n:direction-embedding(($ref, .)[1])"/>
            <!-- [normalize-space((text()|*) except bibl) eq ''] -->
            <xsl:choose>
                <xsl:when test="count($ref) gt 0">
                    <xsl:apply-templates select="$ref" mode="biblio:entry-from-biblio">
                        <xsl:with-param name="tpBiblScope" as="element()*" select="biblScope"
                            tunnel="true"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@corresp"/>
                </xsl:otherwise>
            </xsl:choose>
            <!-- biblScope and other children -->
            <xsl:apply-templates mode="biblio:entry"/>
            <xsl:text>&pdf;</xsl:text>
            <xsl:call-template name="i18n:ltr-to-rtl-extra-space">
                <xsl:with-param name="first-direction"
                    select="i18n:language-direction(($ref, .)[1])"/>
                <xsl:with-param name="then-direction" select="i18n:language-direction(.)"/>
            </xsl:call-template>
        </span>
    </xsl:template>

    <!-- default template for bibliographic references: use markup and text in it -->
    <xsl:template match="bibl" mode="biblio:reference">
        <xsl:variable name="biblnode" select="."/>
        <span class="bibliographic-reference" lang="{i18n:language(.)}"
            style="direction:{i18n:language-direction(.)};">
            <!-- This must be paired with pdf character entity,
                        because directional embeddings are an embedded CFG! -->
            <xsl:value-of select="i18n:direction-embedding(.)"/>
            <!-- [normalize-space((text()|*) except bibl) eq ''] -->
            <xsl:apply-templates mode="biblio:entry"/>
            <xsl:text>&pdf;</xsl:text>
        </span>
    </xsl:template>

    <!-- mode for printing a bibliographic entry from children of bibl -->
    <xsl:mode name="biblio:entry" on-no-match="shallow-skip" visibility="public"/>

    <!-- mode for printing a bibliographic entry pulled in from the bibliography -->
    <xsl:mode name="biblio:entry-from-biblio" on-no-match="shallow-skip" visibility="public"/>

    <!-- Exclude whitespace nodes from the bibliographic reference,
        because they break the interpunctation at the end.
        This may lead to unwanted effects with some bibliographies. -->
    <xsl:template match="text()[ancestor::listBibl and matches(., '^\s+$')]"
        mode="biblio:entry biblio:entry-from-biblio"/>

    <xsl:template match="biblScope[@unit][@from and @to]"
        mode="biblio:entry biblio:entry-from-biblio">
        <xsl:text>, </xsl:text>
        <span class="bibl-scope">
            <span class="static-text" data-i18n-key="{@unit}">&lre;<xsl:value-of select="@unit"
                />&pdf;</span>
            <xsl:text> </xsl:text>
            <xsl:value-of select="@from"/>
            <xsl:text>-</xsl:text>
            <xsl:value-of select="@to"/>
        </span>
    </xsl:template>

    <xsl:template match="biblScope[@unit]" mode="biblio:entry biblio:entry-from-biblio">
        <xsl:text>, </xsl:text>
        <span class="bibl-scope">
            <span class="static-text" data-i18n-key="{@unit}">&lre;<xsl:value-of select="@unit"
                />&pdf;</span>
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>

    <xsl:template match="biblScope" mode="biblio:entry biblio:entry-from-biblio">
        <xsl:text>, </xsl:text>
        <span class="bibl-scope">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>

    <xsl:template match="title" mode="biblio:entry biblio:entry-from-biblio">
        <span class="biblio title">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>

    <xsl:template match="author" mode="biblio:entry biblio:entry-from-biblio">
        <span class="biblio author">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>

    <xsl:template match="editor" mode="biblio:entry biblio:entry-from-biblio">
        <span class="biblio editor">
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>


    <xsl:template match="text()" mode="biblio:entry biblio:entry-from-biblio">
        <xsl:value-of select="."/>
    </xsl:template>

</xsl:package>
