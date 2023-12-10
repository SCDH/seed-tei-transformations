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
    xmlns:html="http://scdh.wwu.de/transform/html#"
    xmlns:biblio="http://scdh.wwu.de/transform/biblio#"
    xmlns:ref="http://scdh.wwu.de/transform/ref#" xmlns:test="http://scdh.wwu.de/transform/test#"
    exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0" default-mode="preview">

    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <!-- whether to use the HTML template from libhtml and make a full HTML file -->
    <xsl:param name="use-libhtml" as="xs:boolean" select="true()"/>

    <!-- optional: the URI of the projects central witness catalogue -->
    <xsl:param name="wit-catalog" as="xs:string?"
        select="resolve-uri('../../../WitnessCatalogue.xml', base-uri())"/>

    <xsl:variable name="witnesses" as="element()*" visibility="public">
        <xsl:choose>
            <xsl:when test="empty($wit-catalog) or not(doc-available($wit-catalog))">
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>no witness catalog </xsl:text>
                    <xsl:value-of select="$wit-catalog"/>
                </xsl:message>
                <xsl:sequence>
                    <xsl:try select="//sourceDesc//witness[@xml:id]">
                        <xsl:catch errors="*" select="()"/>
                    </xsl:try>
                </xsl:sequence>
            </xsl:when>
            <xsl:otherwise>
                <!-- a sequence from external and local witnesses -->
                <xsl:sequence>
                    <xsl:try select="(doc($wit-catalog)/descendant::witness[@xml:id],
                        //sourceDesc//witness[@xml:id])">
                        <xsl:catch errors="*"
                            select="doc($wit-catalog)/descendant::witness[@xml:id]"/>
                    </xsl:try>
                </xsl:sequence>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="language" as="xs:string" visibility="public">
        <xsl:try select="/*/@xml:lang">
            <xsl:catch errors="*" select="'ar'"/>
        </xsl:try>
    </xsl:variable>


    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libi18n.xsl"
        package-version="0.1.0">
        <xsl:override>
            <xsl:variable name="i18n:default-language" as="xs:string" select="$language"/>
        </xsl:override>
    </xsl:use-package>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libwit.xsl"
        package-version="1.0.0"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libref.xsl"
        package-version="1.0.0"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libentry2.xsl"
        package-version="1.0.0">
        <xsl:accept component="function" names="seed:note-based-apparatus-nodes-map#2"
            visibility="public"/>
        <xsl:accept component="function" names="seed:shorten-lemma#1" visibility="hidden"/>
        <xsl:accept component="mode" names="seed:lemma-text-nodes" visibility="hidden"/>
    </xsl:use-package>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libapp2.xsl"
        package-version="1.0.0">

        <xsl:accept component="mode" names="seed:lemma-text-nodes" visibility="public"/>
        <xsl:accept component="function" names="app:apparatus-entries#1" visibility="public"/>
        <xsl:accept component="function" names="app:apparatus-entries#3" visibility="public"/>

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

            <xsl:template mode="app:reading-annotation" match="unclear[not(@reason)]">
                <span class="static-text" data-i18n-key="unclear">
                    <xsl:text>unclear</xsl:text>
                </span>
            </xsl:template>

            <xsl:template mode="app:reading-text" match="bibl">
                <xsl:call-template name="biblio:reference"/>
            </xsl:template>

            <xsl:template mode="app:reading-text" match="term[@xml:lang ne 'ar']">
                <i>
                    <xsl:if test="@sameAs">
                        <xsl:attribute name="data-help-key" select="@sameAs"/>
                    </xsl:if>
                    <xsl:apply-templates mode="#current"/>
                </i>
            </xsl:template>

            <xsl:template mode="app:pre-reading-text" priority="2"
                match="span[some $t in tokenize(@ana) satisfies $t eq 'tag:Tadmin']/note[normalize-space(node() except child::bibl) eq '']">
                <xsl:variable name="context" as="element()" select="."/>
                <xsl:variable name="term" as="item()*"
                    select="ref:process-reference('tag:Tadmin', .) => ref:dereference($context)"/>
                <span class="pre-reading-text static-text" data-help-key="Tadmin">
                    <xsl:apply-templates mode="app:reading-text"
                        select="$term/desc[@xml:lang eq 'en']/term[1]"/>
                    <span>: </span>
                </span>
            </xsl:template>

            <xsl:template mode="app:pre-reading-text"
                match="span[some $t in tokenize(@ana) satisfies $t eq 'tag:Isarah']/note[normalize-space(node() except child::bibl) eq '']">
                <xsl:variable name="context" as="element()" select="."/>
                <xsl:variable name="term" as="item()*"
                    select="ref:process-reference('tag:Isarah', .) => ref:dereference($context)"/>
                <span class="pre-reading-text static-text" data-help-key="Isarah">
                    <xsl:apply-templates mode="app:reading-text"
                        select="$term/desc[@xml:lang eq 'en']/term[1]"/>
                    <span>: </span>
                </span>
            </xsl:template>

        </xsl:override>

    </xsl:use-package>

    <!-- apparatus criticus -->
    <xsl:variable name="apparatus-entries" as="map(*)*" visibility="public"
        select="app:apparatus-entries(root())"/>

    <!-- apparatus comment. -->
    <xsl:variable name="editorial-notes" as="map(*)*" visibility="public"
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

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/html/aleabiblio.xsl"
        package-version="1.0.0"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libhtml.xsl"
        package-version="1.0.0">

        <xsl:accept component="mode" names="html:html" visibility="public"/>
        <xsl:accept component="template" names="html:*" visibility="public"/>

        <xsl:override>

            <!-- this makes the page content -->
            <xsl:template name="html:content">
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
                <xsl:call-template name="i18n:language-chooser"/>
                <xsl:call-template name="i18n:load-javascript"/>
                <xsl:call-template name="surah-translations"/>
            </xsl:template>

            <!-- a sequence of CSS files -->
            <xsl:param name="html:css" as="xs:string*"
                select="resolve-uri('diwan.css', static-base-uri())"/>

            <xsl:template name="html:title" visibility="public">
                <xsl:value-of select="(/*/@xml:id, //title ! normalize-space())[1]"/>
                <xsl:text> :: ALEA</xsl:text>
            </xsl:template>

        </xsl:override>
    </xsl:use-package>


    <xsl:mode name="preview" on-no-match="shallow-copy" visibility="public"/>

    <!-- if parameter $use-libhtml is true, switch to html:html mode -->
    <xsl:template match="/ | TEI" priority="10">
        <xsl:choose>
            <xsl:when test="$use-libhtml">
                <xsl:apply-templates mode="html:html" select="root()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="html:content"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



    <!-- a utility just for unit testing the apparatus -->
    <xsl:template name="test:single-app-entry" visibility="final">
        <xsl:variable name="entries"
            select="app:apparatus-entries(.) => seed:note-based-apparatus-nodes-map(true())"/>
        <xsl:call-template name="app:note-based-apparatus">
            <xsl:with-param name="entries" select="$entries"/>
        </xsl:call-template>
    </xsl:template>

    <!-- a utility just for unit testing the apparatus -->
    <xsl:template name="test:single-editorial-note" visibility="final">
        <xsl:variable name="entries"
            select="app:apparatus-entries(., 'descendant-or-self::note[ancestor::text]', 2) => seed:note-based-apparatus-nodes-map(true())"/>
        <xsl:call-template name="app:note-based-apparatus">
            <xsl:with-param name="entries" select="$entries"/>
        </xsl:call-template>
    </xsl:template>


</xsl:package>
