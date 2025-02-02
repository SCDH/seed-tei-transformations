<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE stylesheet [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
    <!ENTITY nbsp "&#xa0;" >
    <!ENTITY emsp "&#x2003;" >
    <!ENTITY lb "&#xa;" >
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:app="http://scdh.wwu.de/transform/app#"
    xmlns:note="http://scdh.wwu.de/transform/note#" xmlns:seed="http://scdh.wwu.de/transform/seed#"
    xmlns:text="http://scdh.wwu.de/transform/text#"
    xmlns:common="http://scdh.wwu.de/transform/common#"
    xmlns:meta="http://scdh.wwu.de/transform/meta#" xmlns:wit="http://scdh.wwu.de/transform/wit#"
    xmlns:obt="http://scdh.wwu.de/oxbytei" exclude-result-prefixes="#all"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0" default-mode="preview">

    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <!-- optional: the URI of the project's central witness catalogue -->
    <xsl:param name="wit-catalog" as="xs:string" select="string()"/>

    <!-- A sequence of IDs of annotations to be transformed.
        If this is the empty sequence, all annotations are transformed. -->
    <xsl:param name="pages" as="xs:string*">
        <xsl:message>
            <xsl:text>obt:current-node() available? </xsl:text>
            <xsl:value-of select="function-available('obt:current-node')"/>
        </xsl:message>
        <xsl:message use-when="function-available('obt:current-node')">
            <xsl:variable name="current-node" select="obt:current-node(base-uri())"/>
            <xsl:choose>
                <xsl:when test="$current-node[text()]">
                    <xsl:text>current text node: </xsl:text>
                    <xsl:value-of select="$current-node"/>
                </xsl:when>
                <xsl:when test="$current-node[element()]">
                    <xsl:text>current element: </xsl:text>
                    <xsl:value-of select="name($current-node)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>other node</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:message>
        <xsl:sequence use-when="function-available('obt:current-node')"
            select="obt:current-node(base-uri())/preceding::pb[1]/@n"> </xsl:sequence>
        <xsl:sequence use-when="not(function-available('obt:current-node'))" select="()"/>
    </xsl:param>

    <xsl:variable name="current" as="node()*">
        <xsl:variable name="root" select="/"/>
        <xsl:choose>
            <!-- When there's a page number or several page numbers,
                            then this take the nodes between the pb with the page number and the next pb. -->
            <xsl:when test="not(empty($pages))">
                <xsl:for-each select="$pages">
                    <xsl:variable name="page-number" as="xs:string" select="."/>
                    <xsl:variable name="pb" as="node()" select="$root//pb[@n eq $page-number]"/>
                    <xsl:variable name="next-pb" as="node()*" select="$pb/following::pb[1]"/>
                    <xsl:sequence select="$pb, seed:subtrees-between-anchors($pb, $next-pb)"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <!-- otherwise transform the whole document -->
                <xsl:sequence select="root()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>


    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libi18n.xsl"
        package-version="0.1.0">
        <xsl:override>
            <xsl:variable name="i18n:default-language" as="xs:string"
                select="(/*/@xml:lang, 'ar')[1]"/>
        </xsl:override>
    </xsl:use-package>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libwit.xsl"
        package-version="1.0.0"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libbetween.xsl"
        package-version="1.0.0"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libentry2.xsl"
        package-version="1.0.0">
        <xsl:accept component="function" names="seed:note-based-apparatus-nodes-map#2"
            visibility="public"/>
        <xsl:accept component="function" names="seed:shorten-lemma#1" visibility="hidden"/>
    </xsl:use-package>

    <xsl:variable name="apparatus-entries" as="map(xs:string, map(*))"
        select="app:apparatus-entries($current) => seed:note-based-apparatus-nodes-map(true())"/>
    <xsl:variable name="editorial-notes" as="map(xs:string, map(*))"
        select="app:apparatus-entries($current, 'descendant-or-self::note[ancestor::text]', 2) => seed:note-based-apparatus-nodes-map(true())"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libapp2.xsl"
        package-version="1.0.0">

        <xsl:accept component="template" names="app:footnote-marks" visibility="public"/>
        <xsl:accept component="template" names="app:note-based-apparatus" visibility="public"/>

        <xsl:override>
            <xsl:variable name="app:entries-xpath-internal-parallel-segmentation" as="xs:string">
                <xsl:value-of>
                    <!-- choice+corr+sic+app+rdg was an old encoding of conjectures in ALEA -->
                    <xsl:text>descendant-or-self::app[not(parent::sic[parent::choice])]</xsl:text>
                    <xsl:text>| descendant::witDetail[not(parent::app)]</xsl:text>
                    <xsl:text>| descendant::corr[not(parent::choice)]</xsl:text>
                    <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
                    <xsl:text>| descendant::choice[sic and corr]</xsl:text>
                    <xsl:text>| descendant::unclear[not(parent::choice)]</xsl:text>
                    <xsl:text>| descendant::choice[unclear]</xsl:text>
                    <xsl:text>| descendant::gap</xsl:text>
                    <xsl:text>| descendant::supplied</xsl:text>
                </xsl:value-of>
            </xsl:variable>

            <xsl:variable name="app:entries-xpath-internal-double-end-point" as="xs:string">
                <xsl:value-of>
                    <!-- choice+corr+sic+app+rdg was an old encoding of conjectures in ALEA -->
                    <xsl:text>descendant-or-self::app[not(parent::sic[parent::choice])]</xsl:text>
                    <xsl:text>| descendant::witDetail[not(parent::app)]</xsl:text>
                    <xsl:text>| descendant::corr[not(parent::choice)]</xsl:text>
                    <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
                    <xsl:text>| descendant::choice[sic and corr]</xsl:text>
                    <xsl:text>| descendant::unclear[not(parent::choice)]</xsl:text>
                    <xsl:text>| descendant::choice[unclear]</xsl:text>
                    <xsl:text>| descendant::gap</xsl:text>
                    <xsl:text>| descendant::supplied</xsl:text>
                </xsl:value-of>
            </xsl:variable>

            <xsl:variable name="app:entries-xpath-external-double-end-point" as="xs:string">
                <xsl:value-of>
                    <xsl:text>descendant-or-self::app</xsl:text>
                    <xsl:text>| descendant::witDetail[not(parent::app)]</xsl:text>
                    <xsl:text>| descendant::corr[not(parent::choice)]</xsl:text>
                    <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
                    <xsl:text>| descendant::choice[sic and corr]</xsl:text>
                    <xsl:text>| descendant::unclear[not(parent::choice)]</xsl:text>
                    <xsl:text>| descendant::choice[unclear]</xsl:text>
                    <xsl:text>| descendant::gap</xsl:text>
                    <xsl:text>| descendant::supplied</xsl:text>
                </xsl:value-of>
            </xsl:variable>

            <xsl:variable name="app:entries-xpath-no-textcrit" as="xs:string">
                <xsl:value-of>
                    <xsl:text>descendant::corr[not(parent::choice)]</xsl:text>
                    <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
                    <xsl:text>| descendant::choice[sic and corr]</xsl:text>
                    <xsl:text>| descendant::unclear[not(parent::choice)]</xsl:text>
                    <xsl:text>| descendant::choice[unclear]</xsl:text>
                    <xsl:text>| descendant::gap</xsl:text>
                    <xsl:text>| descendant::supplied</xsl:text>
                </xsl:value-of>
            </xsl:variable>

            <!-- note with @target, but should be @targetEnd. TODO: remove after TEI has been fixed -->
            <xsl:template mode="app:lemma-text-nodes-dspt" match="note[@target] | noteGrp[@target]">
                <xsl:variable name="targetEnd" as="xs:string" select="substring(@target, 2)"/>
                <xsl:variable name="target-end-node" as="node()*"
                    select="//*[@xml:id eq $targetEnd]"/>
                <xsl:choose>
                    <xsl:when test="empty($target-end-node)">
                        <xsl:message>
                            <xsl:text>No anchor for message with @target: </xsl:text>
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

            <!-- drop mentioned -->
            <xsl:template mode="app:reading-text" match="mentioned"/>



            <!-- use libwit in apparatus -->
            <xsl:template name="app:sigla">
                <xsl:param name="context" as="node()"/>
                <xsl:call-template name="wit:sigla">
                    <xsl:with-param name="wit" select="$context/@wit"/>
                </xsl:call-template>
            </xsl:template>

        </xsl:override>
    </xsl:use-package>


    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/html/libmeta.xsl"
        package-version="1.0.0">
        <xsl:override>
            <xsl:variable name="wit:witnesses" as="element()*">
                <xsl:choose>
                    <xsl:when test="$wit-catalog eq string()">
                        <xsl:sequence select="//sourceDesc//witness[@xml:id]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- a sequence from external and local witnesses -->
                        <xsl:sequence select="
                                (doc($wit-catalog)/descendant::witness[@xml:id],
                                //sourceDesc//witness[@xml:id])"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
        </xsl:override>
    </xsl:use-package>


    <!--
    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libnote2.xsl"
        package-version="1.0.0">
        <xsl:accept component="function" names="note:editorial-notes#3" visibility="public"/>
        <xsl:accept component="template" names="note:note-based-editorial-notes" visibility="public"/>
        <xsl:accept component="template" names="note:footnote-marks" visibility="public"/>
        <xsl:accept component="mode" names="note:editorial-note" visibility="public"/>
        <xsl:accept component="function" names="seed:shorten-lemma#1" visibility="hidden"/>
        <xsl:accept component="function" names="seed:mk-entry-map#4" visibility="hidden"/>
        <!-\-xsl:accept component="variable" names="note:editorial-notes" visibility="public"/-\->

        <xsl:override>
            <!-\- note with @target, but should be @targetEnd. TODO: remove after TEI has been fixed -\->
            <xsl:template mode="note:text-nodes-dspt" match="note[@target] | noteGrp[@target]">
                <xsl:variable name="targetEnd" as="xs:string" select="substring(@target, 2)"/>
                <xsl:variable name="target-end-node" as="node()*"
                    select="//*[@xml:id eq $targetEnd]"/>
                <xsl:choose>
                    <xsl:when test="empty($target-end-node)">
                        <xsl:message>
                            <xsl:text>No anchor for message with @target: </xsl:text>
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

            <!-\- drop mentioned -\->
            <xsl:template mode="note:editorial-note" match="mentioned"/>

            <!-\- set note:editorial-notes for footnote marks in the text -\->
            <xsl:variable name="note:editorial-notes" as="map(xs:string, map(*))"
                select="seed:note-based-apparatus-nodes-map($editorial-notes, true())"/>

        </xsl:override>
    </xsl:use-package>
-->
    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libprose.xsl"
        package-version="1.0.0">
        <xsl:override>

            <xsl:template name="text:inline-marks">
                <xsl:call-template name="app:footnote-marks">
                    <xsl:with-param name="entries"
                        select="map:merge($apparatus-entries, $editorial-notes)"/>
                </xsl:call-template>
                <xsl:call-template name="app:footnote-marks">
                    <xsl:with-param name="entries" select="map:merge($editorial-notes)"/>
                </xsl:call-template>
            </xsl:template>

            <!-- print metrum -->
            <xsl:template match="@met" mode="text:text">
                <div class="verse-meter static-text">
                    <xsl:text>[</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text>]</xsl:text>
                </div>
            </xsl:template>

        </xsl:override>
    </xsl:use-package>

    <!--    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/librend.xsl"
        package-version="1.0.0"> </xsl:use-package>
-->


    <!-- 
    <xsl:import href="libbiblio.xsl"/>
    <xsl:include href="libsurah.xsl"/>
    -->
    <!-- include for overriding -->

    <xsl:param name="font-css" as="xs:string" select="''"/>
    <xsl:param name="font-name" as="xs:string" select="'Arabic Typesetting'"/>

    <xsl:template match="/ | TEI">
        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;&lb;</xsl:text>
        <xsl:for-each select="//xi:include">
            <xsl:message>
                <xsl:text>WARNING: </xsl:text>
                <xsl:text>XInclude element not expanded! @href="</xsl:text>
                <xsl:value-of select="@href"/>
                <xsl:text>" @xpointer="</xsl:text>
                <xsl:value-of select="@xpointer"/>
                <xsl:text>"</xsl:text>
            </xsl:message>
        </xsl:for-each>
        <html lang="{i18n:language(/*)}">
            <head>
                <meta charset="utf-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
                <xsl:variable name="work-id" as="xs:string"
                    select="(/*/@xml:id | //idno[@type eq 'local-work-id']/text())[1]"/>
                <title>
                    <xsl:value-of select="$work-id"/>
                    <xsl:text> :: ALEA Vorschau</xsl:text>
                </title>
                <style>
                    <xsl:if test="$font-css ne ''">
                        <xsl:value-of select="unparsed-text($font-css)"/>
                    </xsl:if>
                    .title {
                        color:red;
                    }
                    body {
                        direction: <xsl:value-of select="i18n:language-direction(/TEI/text)"/>;
                        font-family:"<xsl:value-of select="$font-name"/>";
                        width: 30em;
                        font-size: 1.2em;
                    }
                    .metadata {
                        direction: ltr;
                        text-align: right;
                        margin: 0 2em;
                    }
                    .variants {
                        direction: <xsl:value-of select="i18n:language-direction(/TEI/text)"/>;
                    }
                    .comments {
                        direction: <xsl:value-of select="i18n:language-direction(/TEI/text)"/>;
                    }
                    hr {
                        margin: 1em 2em;                    }
                    td {
                        text-align: <xsl:value-of select="i18n:language-align(/TEI/text)"/>;
                        justify-content: space-between;
                        justify-self: stretch;
                    }
                    td.line-number, td.apparatus-line-number, td.editorial-note-number {
                        vertical-align:top;
                        padding-left: 10px;
                        }
                    .line-number, .apparatus-line-number, .apparatus-note-number, .editorial-note-number {
                        text-align:right;
                        font-size: 0.7em;
                        padding-top: 0.3em;
                    }
                    div.apparatus-line,
                    div.editorial-note {
                        padding: 2px 0;
                        /* hanging indent for ltr */
                        /*
                        padding-right: 3em;
                        text-indent: -3em;
                        direction: rtl !important;
                        */
                        }
                    /*
                    section > p {
                        padding-right: 3em;
                        padding-left: 3em;
                        text-indent: -3em;
                    }
                    */
                    span.line-number, span.note-number {
                        display: inline-block;
                        min-width: 3em;
                    }
                    td.text-col1 {
                        padding-left: 40px;
                    }
                    sup {
                        font-size: 6pt
                    }
                    sup + sup:before {
                        content: " ";
                    }
                    .static-text, .apparatus-sep, .siglum {
                        color: gray;
                    }
                    abbr {
                        text-decoration: none;
                    }
                    .lemma-gap {
                        font-size:.8em;
                    }
                    span.caesura {
                        width: 4em;
                        text-align: center;
                    }
                    .supplied:not(.reading):before {
                        content: "[";
                    }
                    .supplied:not(.reading):after {
                    content: "]";
                    }
                    .verbatim-holy:before {
                        content: "﴿";
                    }
                    .verbatim-holy:after {
                        content: "﴾";
                    }
                    .verbatim:before {
                    content: "(";
                    }
                    .verbatim:after {
                    content: ")";
                    }
                    @font-face {
                        font-family:"Arabic Typesetting";
                        src:url("../../../arabt100.ttf");
                    }
                    @font-face {
                        font-family:"Amiri Regular";
                        src:url("../../../resources/css/Amiri-Regular.ttf");
                    }
                </style>
            </head>
            <body>
                <xsl:variable name="root" select="/*"/>
                <xsl:if test="true()">
                    <xsl:message use-when="system-property('debug') eq 'true'">
                        <xsl:text>Transformed page: </xsl:text>
                        <xsl:value-of select="$pages"/>
                    </xsl:message>
                </xsl:if>
                <section class="metadata">
                    <xsl:apply-templates select="/TEI/teiHeader" mode="meta:data"/>
                </section>
                <hr/>
                <section class="content">
                    <xsl:apply-templates select="$current" mode="text:text"/>
                </section>
                <hr/>
                <section class="variants">
                    <xsl:call-template name="app:note-based-apparatus">
                        <xsl:with-param name="entries" select="$apparatus-entries"/>
                    </xsl:call-template>
                </section>
                <hr/>
                <section class="comments">
                    <xsl:call-template name="app:note-based-apparatus">
                        <xsl:with-param name="entries" select="$editorial-notes"/>
                    </xsl:call-template>
                </section>
                <hr/>

                <xsl:call-template name="i18n:language-chooser"/>
                <xsl:call-template name="i18n:load-javascript"/>

                <!--
                <xsl:call-template name="surah-translations"/>
                -->
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
