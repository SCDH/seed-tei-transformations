<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT package for edited text (main text)

This package is not intended to be used directly. Use a derived package for the
main text instead, e.g. libprose.xsl for prose or libcouplet.xsl for verses with
caesura. Or derive your own.

This package provides basic components for the main text (edited text), such as
inserting footnote marks that link to the apparatus and comment sections.

To get such footnote marks, you will have to override the variable
$text:apparatus-entries, which is a map. The package for generating the apparatus
should provide a function that provides the correct map. So does libapp2 by
providing app:note-based-apparatus-nodes-map#2

Note, that there is a default mode in this package.

-->
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libtext.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:text="http://scdh.wwu.de/transform/text#"
    exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0" default-mode="text:text">

    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libi18n.xsl"
        package-version="0.1.0">
        <xsl:accept component="function" names="i18n:language#1" visibility="private"/>
    </xsl:use-package>

    <!-- override this with a map when you need footnote signs to apparatus entries. See app:note-based-apparatus-nodes-map#2 -->
    <xsl:variable name="text:apparatus-entries" as="map(xs:string, map(*))" select="map {}"
        visibility="public"/>

    <xsl:mode name="text:text" visibility="public"/>

    <!-- text:hook-before and text:hook-after are modes that offer hooks for
        inserting project-specific things before and after an element -->
    <xsl:mode name="text:hook-before" on-no-match="deep-skip" visibility="public"/>
    <xsl:mode name="text:hook-after" on-no-match="deep-skip" visibility="public"/>


    <!-- parts of the document -->

    <!-- parts that should not be generate output in mode text:text -->
    <xsl:template match="teiHeader"/>

    <xsl:template match="body | front | back">
        <div class="{name()}">
            <xsl:apply-templates select="@* | node()"/>
        </div>
    </xsl:template>


    <!-- markup that has to be invisible in the edited text -->

    <xsl:template match="note">
        <xsl:apply-templates mode="text:hook-before" select="."/>
        <xsl:call-template name="text:apparatus-links"/>
        <xsl:apply-templates mode="text:hook-after" select="."/>
    </xsl:template>

    <!-- rdg: Do not output reading (variant) in all modes generating edited text. -->
    <xsl:template match="rdg"/>

    <xsl:function name="text:non-lemma-nodes" as="node()*">
        <xsl:param name="element" as="node()"/>
        <xsl:sequence select="$element/descendant-or-self::rdg/descendant-or-self::node()"/>
    </xsl:function>

    <xsl:template match="witDetail"/>

    <xsl:template match="app">
        <xsl:apply-templates mode="text:hook-before" select="."/>
        <xsl:apply-templates select="lem"/>
        <xsl:call-template name="text:apparatus-links"/>
        <xsl:apply-templates mode="text:hook-after" select="."/>
    </xsl:template>

    <xsl:template match="lem[//variantEncoding/@medthod ne 'parallel-segmentation']"/>

    <xsl:template
        match="lem[//variantEncoding/@method eq 'parallel-segmentation' and empty(node())]">
        <!-- FIXME: some error here eg. on BBgim8.tei -->
        <!--xsl:text>[!!!]</xsl:text-->
    </xsl:template>

    <xsl:template match="gap">
        <xsl:apply-templates mode="text:hook-before" select="."/>
        <xsl:text>[...]</xsl:text>
        <xsl:apply-templates mode="text:hook-after" select="."/>
    </xsl:template>

    <xsl:template match="unclear">
        <xsl:apply-templates mode="text:hook-before" select="."/>
        <!--xsl:text>[? </xsl:text-->
        <xsl:apply-templates/>
        <!--xsl:text> ?]</xsl:text-->
        <xsl:apply-templates mode="text:hook-after" select="."/>
    </xsl:template>

    <xsl:template match="choice[child::sic and child::corr]">
        <xsl:apply-templates mode="text:hook-before" select="."/>
        <xsl:apply-templates select="corr"/>
        <xsl:apply-templates mode="text:hook-after" select="."/>
    </xsl:template>

    <xsl:template match="sic[not(parent::choice)]">
        <xsl:apply-templates mode="text:hook-before" select="."/>
        <xsl:apply-templates/>
        <xsl:apply-templates mode="text:hook-after" select="."/>
    </xsl:template>

    <xsl:template match="corr[not(parent::choice)]">
        <xsl:apply-templates mode="text:hook-before" select="."/>
        <xsl:apply-templates/>
        <xsl:apply-templates mode="text:hook-after" select="."/>
    </xsl:template>

    <!-- segmentation offers hooks for project-specific insertions -->
    <xsl:template match="seg | s | w | c | pc">
        <xsl:apply-templates mode="text:hook-before" select="."/>
        <span class="{name()}">
            <xsl:apply-templates select="@* | node()"/>
        </span>
        <xsl:apply-templates mode="text:hook-after" select="."/>
    </xsl:template>

    <xsl:template match="@xml:id">
        <xsl:attribute name="id" select="."/>
    </xsl:template>

    <xsl:template match="@xml:lang">
        <xsl:attribute name="xml:lang" select="."/>
        <xsl:attribute name="lang" select="."/>
    </xsl:template>

    <xsl:template match="@n">
        <xsl:attribute name="data-tei-n" select="."/>
    </xsl:template>

    <xsl:template match="@type">
        <xsl:attribute name="data-tei-type" select="."/>
    </xsl:template>

    <xsl:template name="text:tag-start" visibility="public"/>

    <xsl:template name="text:tag-end" visibility="public"/>

    <xsl:template name="text:standard-attributes" visibility="private">
        <xsl:if test="@xml:id">
            <xsl:attribute name="id" select="@xml:id"/>
        </xsl:if>
        <xsl:if test="@xml:lang">
            <xsl:attribute name="lang" select="@xml:lang"/>
            <xsl:attribute name="xml:lang" select="@xml:lang"/>
        </xsl:if>
    </xsl:template>

    <!-- make a link to an apparatus entry if there is one for the context element -->
    <xsl:template name="text:apparatus-links" visibility="public">
        <xsl:variable name="element-id" select="if (@xml:id) then @xml:id else generate-id()"/>
        <xsl:if test="map:contains($text:apparatus-entries, $element-id)">
            <xsl:variable name="entry" select="map:get($text:apparatus-entries, $element-id)"/>
            <sup class="apparatus-footnote-mark footnote-mark">
                <a name="text-{$element-id}" href="#{$element-id}">
                    <xsl:value-of select="map:get($entry, 'number')"/>
                </a>
            </sup>
        </xsl:if>
    </xsl:template>

</xsl:package>
