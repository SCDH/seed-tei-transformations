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
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libnote2.xsl"
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
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libnote2.xsl"
        package-version="1.0.0">

        <xsl:accept component="function" names="note:*" visibility="public"/>
        <xsl:accept component="mode" names="note:*" visibility="public"/>
        <xsl:accept component="template" names="note:*" visibility="public"/>
        <xsl:accept component="function" names="seed:mk-entry-map#4" visibility="final"/>
        <xsl:accept component="function" names="seed:shorten-lemma#1" visibility="public"/>
        <xsl:accept component="mode" names="seed:lemma-text-nodes" visibility="public"/>
        <xsl:accept component="variable" names="note:editorial-notes" visibility="public"/>

        <xsl:override>

            <!-- template that generates the editorial notes -->
            <xsl:template name="note:line-based-editorial-notes" visibility="public">
                <xsl:param name="notes" as="map(*)*"/>
                <div class="editorial-notes">
                    <xsl:for-each-group select="$notes" group-by="map:get(., 'line-number')">
                        <xsl:for-each select="current-group()">
                            <xsl:variable name="note" select="map:get(., 'entry')"/>
                            <div class="editorial-note">
                                <span class="editorial-note-line-number line-number">
                                    <xsl:value-of select="current-grouping-key()"/>
                                    <xsl:text>&sp;</xsl:text>
                                </span>
                                <span class="editorial-note-lemma">
                                    <xsl:call-template name="note:editorial-note-lemma">
                                        <xsl:with-param name="entry" select="."/>
                                    </xsl:call-template>
                                </span>
                                <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">]</span>
                                <span class="note-text" lang="{i18n:language($note)}"
                                    style="direction:{i18n:language-direction($note)}; text-align:{i18n:language-align($note)};">
                                    <!-- This must be paired with pdf character entity,
                                because directional embeddings are an embedded CFG! -->
                                    <xsl:value-of select="i18n:direction-embedding($note)"/>
                                    <xsl:apply-templates mode="note:editorial-note" select="$note"/>
                                    <xsl:text>&pdf;</xsl:text>
                                    <xsl:if
                                        test="i18n:language-direction($note) eq 'ltr' and i18n:language-direction($note/parent::*) ne 'ltr' and $i18n:ltr-to-rtl-extra-space">
                                        <xsl:text> </xsl:text>
                                    </xsl:if>
                                </span>
                            </div>
                        </xsl:for-each>
                    </xsl:for-each-group>
                </div>
            </xsl:template>

            <!-- template that generates the editorial notes -->
            <xsl:template name="note:note-based-editorial-notes" visibility="public">
                <xsl:param name="notes" as="map(*)*"/>
                <div class="editorial-notes">
                    <xsl:for-each select="$notes">
                        <xsl:variable name="note" select="map:get(., 'entry')"/>
                        <xsl:variable name="number" select="map:get(., 'number')"/>
                        <xsl:variable name="entry-id" select="map:get(., 'entry-id')"/>
                        <div class="editorial-note">
                            <span class="editorial-note-number note-number">
                                <a name="app-{$entry-id}" href="#{$entry-id}">
                                    <xsl:value-of select="$number"/>
                                </a>
                            </span>
                            <xsl:text>&sp;</xsl:text>
                            <span class="editorial-note-lemma">
                                <xsl:call-template name="note:editorial-note-lemma">
                                    <xsl:with-param name="entry" select="."/>
                                </xsl:call-template>
                            </span>
                            <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">]</span>
                            <span class="note-text" lang="{i18n:language($note)}"
                                style="direction:{i18n:language-direction($note)}; text-align:{i18n:language-align($note)};">
                                <!-- This must be paired with pdf character entity,
                                because directional embeddings are an embedded CFG! -->
                                <xsl:value-of select="i18n:direction-embedding($note)"/>
                                <xsl:apply-templates mode="note:editorial-note" select="$note"/>
                                <xsl:text>&pdf;</xsl:text>
                                <xsl:if
                                    test="i18n:language-direction($note) eq 'ltr' and i18n:language-direction($note/parent::*) ne 'ltr' and $i18n:ltr-to-rtl-extra-space">
                                    <xsl:text> </xsl:text>
                                </xsl:if>
                            </span>
                        </div>
                    </xsl:for-each>
                </div>
            </xsl:template>

            <!-- make a link to an editorial note if there is one for the context item.
                The global variable note:editorial-notes must be set for this. -->
            <xsl:template name="note:footnote-marks" visibility="public">
                <xsl:variable name="element-id"
                    select="if (@xml:id) then @xml:id else generate-id()"/>
                <xsl:if test="map:contains($note:editorial-notes, $element-id)">
                    <xsl:variable name="entry" select="map:get($note:editorial-notes, $element-id)"/>
                    <sup class="apparatus-footnote-mark footnote-mark">
                        <a name="{$element-id}" href="#app-{$element-id}">
                            <xsl:value-of select="map:get($entry, 'number')"/>
                        </a>
                    </sup>
                </xsl:if>
            </xsl:template>

            <xsl:template name="note:inline-alternatives" visibility="private">
                <!-- TODO -->
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

</xsl:package>
