<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT module of the preview: apparatus and commentary -->
<!DOCTYPE package [
    <!ENTITY lb "&#xa;" >
]>
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libnote2.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:app="http://scdh.wwu.de/transform/app#"
    xmlns:note="http://scdh.wwu.de/transform/note#" xmlns:seed="http://scdh.wwu.de/transform/seed#"
    xmlns:common="http://scdh.wwu.de/transform/common#"
    xmlns:edmac="http://scdh.wwu.de/transform/edmac#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    version="3.1">

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libi18n.xsl"
        package-version="1.0.0">
        <xsl:accept component="function"
            names="i18n:language#1 i18n:language-direction#1 i18n:language-align#1 i18n:direction-embedding#1"
            visibility="private"/>
    </xsl:use-package>

    <!-- override this with a map when you need footnote signs to note entries. See seed:note-based-apparatus-nodes-map#2 -->
    <xsl:variable name="note:editorial-notes" as="map(xs:string, map(*))" select="map {}"
        visibility="public"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libreledmac.xsl"
        package-version="1.0.0"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libnote2.xsl"
        package-version="1.0.0">

        <xsl:accept component="function" names="note:*" visibility="public"/>
        <xsl:accept component="mode" names="note:*" visibility="public"/>
        <xsl:accept component="template" names="note:*" visibility="public"/>
        <xsl:accept component="function" names="seed:mk-entry-map#4" visibility="final"/>
        <xsl:accept component="function" names="seed:shorten-lemma#1" visibility="public"/>
        <xsl:accept component="mode" names="seed:lemma-text-nodes" visibility="public"/>

        <xsl:override>

            <!-- template that generates the editorial notes -->
            <!-- never needed for LaTeX, leaving empty -->
            <xsl:template name="note:line-based-editorial-notes" visibility="public">
                <xsl:param name="notes" as="map(*)*"/>
            </xsl:template>

            <!-- template that generates the editorial notes -->
            <!-- never needed for LaTeX, leaving empty -->
            <xsl:template name="note:note-based-editorial-notes" visibility="public">
                <xsl:param name="notes" as="map(*)*"/>
            </xsl:template>

            <!-- template for making the lemma text with some logic for handling empty lemmas -->
            <xsl:template name="note:editorial-note-lemma" visibility="public">
                <xsl:param name="entry" as="map(*)"/>
                <span class="apparatus-lemma">
                    <xsl:variable name="full-lemma" as="xs:string"
                        select="map:get($entry, 'lemma-text-nodes') => seed:shorten-lemma()"/>
                    <xsl:choose>
                        <xsl:when test="$full-lemma ne ''">
                            <xsl:value-of select="$full-lemma"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- FIXME -->
                            <xsl:text>empty</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </xsl:template>

        </xsl:override>
    </xsl:use-package>

    <xsl:template name="note:editorial-note">
        <xsl:param name="entry" as="map(xs:string, item()*)" visibility="public"/>
        <xsl:text>\lemma{</xsl:text>
        <xsl:call-template name="note:editorial-note-lemma">
            <xsl:with-param name="entry" select="$entry"/>
        </xsl:call-template>
        <xsl:text>}</xsl:text>
        <!--xsl:text>\appsep{lem-rdg-sep}</xsl:text-->
        <xsl:text>\</xsl:text>
        <xsl:value-of select="edmac:footnote-macro($entry)"/>
        <xsl:text>{</xsl:text>
        <xsl:apply-templates mode="note:editorial-note" select="map:get(., 'entry')">
            <xsl:with-param name="apparatus-entry-map" as="map(*)" select="." tunnel="true"/>
        </xsl:apply-templates>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <!-- make a footnote with an editorial notes if there are some for the context element -->
    <xsl:template name="note:inline-editorial-notes" visibility="public">
        <xsl:variable name="element-id" select="generate-id()"/>
        <xsl:if test="map:contains($note:editorial-notes, $element-id)">
            <xsl:variable name="entry" select="map:get($note:editorial-notes, $element-id)"/>
            <xsl:variable name="entries" select="map:get($entry, 'entries')"/>
            <xsl:text>%&lb;\edtext{\edlabel{</xsl:text>
            <xsl:message use-when="system-property('debug') eq 'true'">
                <xsl:text>Making end edlabel for </xsl:text>
                <xsl:value-of select="map:get($entries[1], 'entry') => name()"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="map:get($entries[1], 'entry')/@xml:id"/>
            </xsl:message>
            <xsl:variable name="edlabel-end">
                <xsl:apply-templates mode="edmac:edlabel-end" select="map:get($entries[1], 'entry')"/>
            </xsl:variable>
            <xsl:value-of select="$edlabel-end"/>
            <xsl:text>}}{%&lb;</xsl:text>
            <!-- make the references by \xxref{startlabel}{endlabel} -->
            <xsl:text>\xxref{</xsl:text>
            <xsl:apply-templates mode="edmac:edlabel-start" select="map:get($entries[1], 'entry')"/>
            <xsl:text>}{</xsl:text>
            <xsl:value-of select="$edlabel-end"/>
            <xsl:text>}</xsl:text>
            <xsl:for-each select="$entries">
                <!-- make \lemma and \Afootnote -->
                <xsl:call-template name="note:editorial-note">
                    <xsl:with-param name="entry" select="."/>
                </xsl:call-template>
            </xsl:for-each>
            <xsl:text>} %&lb;</xsl:text>
        </xsl:if>
    </xsl:template>

</xsl:package>
