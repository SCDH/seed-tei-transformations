<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT module of the preview: apparatus and commentary -->
<!DOCTYPE package [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
    <!ENTITY sp   "&#x20;" >
    <!ENTITY nbsp "&#xa0;" >
    <!ENTITY emsp "&#x2003;" >
    <!ENTITY lb "&#xa;" >
]>
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libnote2.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:app="http://scdh.wwu.de/transform/app#"
    xmlns:note="http://scdh.wwu.de/transform/note#" xmlns:seed="http://scdh.wwu.de/transform/seed#"
    xmlns:common="http://scdh.wwu.de/transform/common#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    version="3.1">

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libi18n.xsl"
        package-version="0.1.0">
        <xsl:accept component="function"
            names="i18n:language#1 i18n:language-direction#1 i18n:language-align#1 i18n:direction-embedding#1"
            visibility="private"/>
    </xsl:use-package>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libbetween.xsl"
        package-version="1.0.0">
        <xsl:accept component="function" names="seed:subtrees-between-anchors#2"
            visibility="private"/>
    </xsl:use-package>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libentry2.xsl"
        package-version="1.0.0">
        <xsl:accept component="function" names="seed:mk-entry-map#4" visibility="final"/>
        <xsl:accept component="function" names="seed:shorten-lemma#1" visibility="public"/>
        <xsl:accept component="mode" names="seed:lemma-text-nodes" visibility="public"/>
    </xsl:use-package>

    <xsl:expose component="function" names="note:*" visibility="public"/>
    <xsl:expose component="mode" names="note:*" visibility="public"/>
    <xsl:expose component="template" names="note:*" visibility="public"/>

    <!-- function for making a sequence of mappings from editorial notes -->
    <xsl:function name="note:editorial-notes" as="map(*)*">
        <xsl:param name="context" as="node()"/>
        <xsl:param name="editorial-nodes-xpath" as="xs:string"/>
        <xsl:param name="type" as="xs:integer"/>
        <xsl:variable name="notes" as="node()*">
            <xsl:evaluate as="node()*" context-item="$context" expand-text="true"
                xpath="$editorial-nodes-xpath"/>
        </xsl:variable>
        <xsl:sequence select="$notes ! note:mk-note-map(., position(), $type)"/>
    </xsl:function>

    <!-- template that generates the editorial notes -->
    <xsl:template name="note:line-based-editorial-notes" visibility="abstract">
        <xsl:param name="notes" as="map(*)*"/>
    </xsl:template>

    <!-- template that generates the editorial notes -->
    <xsl:template name="note:note-based-editorial-notes" visibility="abstract">
        <xsl:param name="notes" as="map(*)*"/>
    </xsl:template>

    <!-- template for making the lemma text with some logic for handling empty lemmas -->
    <xsl:template name="note:editorial-note-lemma" visibility="abstract">
        <xsl:param name="entry" as="map(*)"/>
    </xsl:template>

    <!-- make a map for a given note -->
    <xsl:function name="note:mk-note-map" as="map(*)">
        <xsl:param name="note" as="node()"/>
        <xsl:param name="number" as="xs:integer"/>
        <xsl:param name="type" as="xs:integer"/>
        <xsl:variable name="lemma-text-nodes" as="text()*">
            <xsl:apply-templates select="$note" mode="note:text-nodes-dspt"/>
        </xsl:variable>
        <xsl:sequence select="seed:mk-entry-map($note, $number, $type, $lemma-text-nodes)"/>
    </xsl:function>

    <xsl:mode name="note:text-nodes-dspt" on-no-match="shallow-skip" visiblity="public"/>

    <!-- if there is no @targetEnd, the referring passage is the whole parent element -->
    <xsl:template mode="note:text-nodes-dspt"
        match="note[not(@targetEnd)] | noteGrp[not(@targetEnd)]">
        <xsl:apply-templates mode="seed:lemma-text-nodes" select="parent::*"/>
    </xsl:template>

    <!-- note with @targetEnd -->
    <xsl:template mode="note:text-nodes-dspt" match="note[@targetEnd] | noteGrp[@targetEnd]">
        <xsl:variable name="targetEnd" as="xs:string" select="substring(@targetEnd, 2)"/>
        <xsl:variable name="target-end-node" as="node()" select="//*[@xml:id eq $targetEnd]"/>
        <xsl:choose>
            <xsl:when test="empty($target-end-node)">
                <xsl:message>
                    <xsl:text>No anchor for message with @targetEnd: </xsl:text>
                    <xsl:value-of select="$targetEnd"/>
                </xsl:message>
            </xsl:when>
            <xsl:when test="following-sibling::*[@xml:id eq $targetEnd]">
                <xsl:apply-templates mode="seed:lemma-text-nodes"
                    select="seed:subtrees-between-anchors(., $target-end-node)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="seed:lemma-text-nodes"
                    select="seed:subtrees-between-anchors($target-end-node, .)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- default rule -->
    <xsl:template mode="note:text-nodes-dspt" match="*">
        <xsl:message>
            <xsl:text>WARNING: </xsl:text>
            <xsl:text>no matching rule in mode 'editorial-note-text-nodes-dspt' for </xsl:text>
            <xsl:value-of select="name(.)"/>
        </xsl:message>
        <xsl:apply-templates mode="seed:lemma-text-nodes"/>
    </xsl:template>


    <!-- MODE: note-text-repetition
        These templates are generate the text repeated in front of the note.-->

    <xsl:mode name="note:text-repetition" on-no-match="shallow-skip" visibility="public"/>

    <xsl:template mode="note:text-repetition"
        match="app[//variantEncoding[@method ne 'parallel-segmentation']]"/>

    <xsl:template match="rdg" mode="note:text-repetition"/>

    <xsl:template match="choice[corr]/sic" mode="note:text-repetition"/>

    <xsl:template match="witDetail" mode="note:text-repetition"/>

    <xsl:template match="note" mode="note:text-repetition"/>

    <!-- this fixes issue #38 on the surface -->
    <xsl:template match="caesura" mode="note:text-repetition" as="text()">
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template match="text()" mode="note:text-repetition" as="text()">
        <xsl:sequence select="."/>
    </xsl:template>


    <!-- mode: editorial-note -->

    <xsl:mode name="note:editorial-note" on-no-match="shallow-skip" visibility="public"/>

    <xsl:template mode="note:editorial-note" match="text()">
        <xsl:value-of select="."/>
    </xsl:template>

    <!-- change language if necessary -->
    <xsl:template match="*[@xml:lang]" mode="note:editorial-note">
        <!-- This must be paired with pdf character entity,
                        because directional embeddings are an embedded CFG! -->
        <xsl:value-of select="i18n:direction-embedding(.)"/>
        <xsl:apply-templates mode="note:editorial-note"/>
        <xsl:text>&pdf;</xsl:text>
        <xsl:if
            test="i18n:language-direction(.) eq 'ltr' and i18n:language-direction(parent::*) ne 'ltr' and $i18n:ltr-to-rtl-extra-space">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>

</xsl:package>
