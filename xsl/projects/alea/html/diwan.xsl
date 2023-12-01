<?xml version="1.0" encoding="UTF-8"?>
<!-- ALEA Preview for Diwan

This XSLT package makes the HTML preview for poems from the Diwan of Ibn Nubatah al Misri.
The poem will have line numbering and the apparatus will be line-based apparatus.

USAGE:

target/bin/xslt.sh \
    -config:saxon.he.xml \
    -xsl:xsl/projects/alea/html/diwan.xsl \
    -s:test/alea/Diwan/lam/lam3/lam3.tei.xml.BB.xml \
    wit-catalog=file:/home/clueck/Projekte/edition-ibn-nubatah/WitnessCatalogue.xml

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
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/html/diwan.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:app="http://scdh.wwu.de/transform/app#"
    xmlns:seed="http://scdh.wwu.de/transform/seed#" xmlns:text="http://scdh.wwu.de/transform/text#"
    xmlns:common="http://scdh.wwu.de/transform/common#"
    xmlns:meta="http://scdh.wwu.de/transform/meta#" xmlns:wit="http://scdh.wwu.de/transform/wit#"
    exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0" default-mode="preview">

    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <!-- optional: the URI of the projects central witness catalogue -->
    <xsl:param name="wit-catalog" as="xs:string" select="string()"/>

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
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libentry2.xsl"
        package-version="1.0.0">
        <xsl:accept component="function" names="seed:note-based-apparatus-nodes-map#2"
            visibility="public"/>
        <xsl:accept component="function" names="seed:shorten-lemma#1" visibility="hidden"/>
    </xsl:use-package>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libapp2.xsl"
        package-version="1.0.0">

        <xsl:override>

            <!-- apparatus entries made for parallel segementation -->
            <xsl:variable name="app:entries-xpath-internal-parallel-segmentation" as="xs:string"
                visibility="public">
                <xsl:value-of>
                    <xsl:text>descendant::app[not(parent::sic[parent::choice])]</xsl:text>
                    <xsl:text>| descendant::witDetail[not(parent::app)]</xsl:text>
                    <xsl:text>| descendant::corr[not(parent::choice)]</xsl:text>
                    <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
                    <xsl:text>| descendant::choice[sic and corr]</xsl:text>
                    <xsl:text>| descendant::unclear[not(parent::choice | ancestor::rdg)]</xsl:text>
                    <xsl:text>| descendant::choice[unclear]</xsl:text>
                    <xsl:text>| descendant::gap[not(ancestor::rdg)]</xsl:text>
                    <xsl:text>| descendant::space[not(ancestor::rdg)]</xsl:text>
                    <xsl:text>| descendant::supplied</xsl:text>
                </xsl:value-of>
            </xsl:variable>

            <!-- XPath describing apparatus entries made for internal double end-point variant encoding -->
            <xsl:variable name="app:entries-xpath-internal-double-end-point" as="xs:string"
                visibility="public">
                <xsl:value-of>
                    <xsl:text>descendant::app[not(parent::sic[parent::choice])]</xsl:text>
                    <xsl:text>| descendant::witDetail[not(parent::app)]</xsl:text>
                    <xsl:text>| descendant::corr[not(parent::choice)]</xsl:text>
                    <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
                    <xsl:text>| descendant::choice[sic and corr]</xsl:text>
                    <xsl:text>| descendant::unclear[not(parent::choice | ancestor::rdg)]</xsl:text>
                    <xsl:text>| descendant::choice[unclear]</xsl:text>
                    <xsl:text>| descendant::gap[not(ancestor::rdg)]</xsl:text>
                    <xsl:text>| descendant::space[not(ancestor::rdg)]</xsl:text>
                    <xsl:text>| descendant::supplied</xsl:text>
                </xsl:value-of>
            </xsl:variable>

            <!-- XPath describing apparatus entries made for external double end-point variant encoding -->
            <xsl:variable name="app:entries-xpath-external-double-end-point" as="xs:string"
                visibility="public">
                <xsl:value-of>
                    <xsl:text>descendant::app</xsl:text>
                    <xsl:text>| descendant::witDetail[not(parent::app)]</xsl:text>
                    <xsl:text>| descendant::corr[not(parent::choice)]</xsl:text>
                    <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
                    <xsl:text>| descendant::choice[sic and corr]</xsl:text>
                    <xsl:text>| descendant::unclear[not(parent::choice | ancestor::rdg)]</xsl:text>
                    <xsl:text>| descendant::choice[unclear]</xsl:text>
                    <xsl:text>| descendant::gap[not(ancestor::rdg)]</xsl:text>
                    <xsl:text>| descendant::space[not(ancestor::rdg)]</xsl:text>
                    <xsl:text>| descendant::supplied</xsl:text>
                </xsl:value-of>
            </xsl:variable>

            <!-- when no variant encoding is present -->
            <xsl:variable name="app:entries-xpath-no-textcrit" as="xs:string" visibility="public">
                <xsl:value-of>
                    <xsl:text>descendant::corr[not(parent::choice)]</xsl:text>
                    <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
                    <xsl:text>| descendant::choice[sic and corr]</xsl:text>
                    <xsl:text>| descendant::unclear[not(parent::choice)]</xsl:text>
                    <xsl:text>| descendant::choice[unclear]</xsl:text>
                    <xsl:text>| descendant::gap</xsl:text>
                    <xsl:text>| descendant::space</xsl:text>
                    <xsl:text>| descendant::supplied</xsl:text>
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



    <!--xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libapp2.xsl"
        package-version="1.0.0">
        <xsl:accept component="*" names="*" visibility="hidden"/>
        <xsl:accept component="template" names="app:note-based-apparatus" visibility="private"/>
        <xsl:accept component="function" names="app:apparatus-entries#3" visibility="private"/>
    </xsl:use-package-->

    <!-- apparatus criticus -->
    <xsl:variable name="apparatus-entries" as="map(*)*" visibility="public"
        select="app:apparatus-entries(root())"/>

    <!-- apparatus comment. -->
    <xsl:variable name="editorial-notes" as="map(*)*"
        select="app:apparatus-entries(root(), 'descendant-or-self::note[ancestor::text]', 2)"/>


    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libcouplet.xsl"
        package-version="1.0.0"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/html/libmeta.xsl"
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

    <xsl:mode name="preview" on-no-match="shallow-copy"/>

    <xsl:template match="/ | TEI">
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
                    .line-number, .apparatus-line-number, .editor-note-number {
                        text-align:right;
                        font-size: 0.7em;
                        padding-top: 0.3em;
                    }
                    div.apparatus-line,
                    div.editorial-note {
                        padding: 2px 0;
                    }
                    /*
                    section > p {
                        padding-right: 3em;
                        padding-left: 3em;
                        text-indent: -3em;
                    }
                    */
                    span.line-number {
                        display: inline-block;
                        min-width: 3em;
                    }
                    td.text-col1 {
                        padding-left: 40px;
                    }
                    sup {
                        font-size: 6pt
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
                <section class="metadata">
                    <xsl:apply-templates select="/TEI/teiHeader" mode="meta:data"/>
                </section>
                <hr/>
                <section class="content">
                    <xsl:apply-templates select="/TEI/text/body" mode="text:text"/>
                </section>
                <hr/>
                <section class="variants">
                    <xsl:call-template name="app:line-based-apparatus">
                        <xsl:with-param name="entries" select="$apparatus-entries"/>
                    </xsl:call-template>
                </section>
                <hr/>
                <section class="comments">
                    <xsl:call-template name="app:line-based-apparatus">
                        <xsl:with-param name="entries" select="$editorial-notes"/>
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

</xsl:package>
