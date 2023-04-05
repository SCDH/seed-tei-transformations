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
    xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:app="http://scdh.wwu.de/transform/app#"
    xmlns:seed="http://scdh.wwu.de/transform/seed#" xmlns:text="http://scdh.wwu.de/transform/text#"
    xmlns:common="http://scdh.wwu.de/transform/common#"
    xmlns:meta="http://scdh.wwu.de/transform/meta#" xmlns:wit="http://scdh.wwu.de/transform/wit#"
    xmlns:obt="http://scdh.wwu.de/oxbytei" exclude-result-prefixes="#all"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0" default-mode="preview">

    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <!-- optional: the URI of the projects central witness catalogue -->
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


    <xsl:variable name="witnesses" as="element()*">
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


    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libi18n.xsl"
        package-version="0.1.0">
        <xsl:override>
            <xsl:variable name="i18n:default-language" as="xs:string" select="/*/@xml:lang"/>
        </xsl:override>
    </xsl:use-package>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libwit.xsl"
        package-version="1.0.0"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libbetween.xsl"
        package-version="1.0.0"/>



    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libapp2.xsl"
        package-version="1.0.0">

        <xsl:accept component="function" names="app:note-based-apparatus-nodes-map#2"
            visibility="public"/>

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
                </xsl:value-of>
            </xsl:variable>

            <!-- XPath how to get a pLike container given an app entry.
                Note: this should not evaluate to an empty sequence. -->
            <xsl:variable name="app:entry-container-xpath" as="xs:string">
                <xsl:value-of>
                    <xsl:text>ancestor::p</xsl:text>
                    <xsl:text>| ancestor::l</xsl:text>
                    <xsl:text>| ancestor::head</xsl:text>
                </xsl:value-of>
            </xsl:variable>

            <xsl:variable name="app:text-nodes-mutet-ancestors" as="xs:string">
                <xsl:value-of>
                    <xsl:text>ancestor::rdg</xsl:text>
                    <xsl:text>| ancestor::sic[parent::choice]</xsl:text>
                </xsl:value-of>
            </xsl:variable>

            <!-- use libwit in apparatus -->
            <xsl:template name="app:sigla">
                <xsl:param name="wit" as="node()"/>
                <xsl:call-template name="wit:sigla">
                    <xsl:with-param name="wit" select="$wit"/>
                </xsl:call-template>
            </xsl:template>

        </xsl:override>
    </xsl:use-package>

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

    <xsl:variable name="apparatus-entries" as="map(*)*" select="app:apparatus-entries($current)"/>


    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libprose.xsl"
        package-version="1.0.0">

        <xsl:override>

            <xsl:variable name="text:apparatus-entries" as="map(xs:string, map(*))"
                select="app:note-based-apparatus-nodes-map($apparatus-entries, true())"/>

        </xsl:override>

    </xsl:use-package>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/librend.xsl"
        package-version="1.0.0"> </xsl:use-package>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/libmeta.xsl"
        package-version="1.0.0">
        <xsl:override>
            <xsl:variable name="wit:witnesses" as="element()*" select="$witnesses"/>
        </xsl:override>
    </xsl:use-package>


    <!-- 
    <xsl:import href="libnote2.xsl"/>
    <xsl:import href="libwit.xsl"/>
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
                        width: 40em;
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
                    .line-number, .apparatus-line-number, .apparatus-note-number, .editor-note-number {
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
                    <xsl:call-template name="app:note-based-apparatus-for-context">
                        <xsl:with-param name="app-context" select="$current"/>
                    </xsl:call-template>
                </section>
                <hr/>
                <!--
                <section class="comments">
                    <xsl:call-template name="scdhx:editorial-notes">
                        <xsl:with-param name="notes"
                            select="scdhx:editorial-notes(//text/body, 'descendant::note')"/>
                    </xsl:call-template>
                </section>
                -->
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
