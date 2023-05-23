<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT package for edited text (main text)

This package is not intended to be used directly. Use a derived package for the
main text instead, e.g. libprose.xsl for prose or libcouplet.xsl for verses with
caesura. Or derive your own.

This package provides basic components for the main text (edited text), such as
inserting footnote marks that link to the apparatus and comment sections.

To get such footnote marks, you will have to override the variable the template
text:inline-marks.

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
        <xsl:accept component="variable" names="i18n:default-language" visibility="abstract"/>
        <xsl:accept component="function" names="i18n:language#1" visibility="private"/>
        <xsl:accept component="function" names="i18n:language-direction#1" visibility="private"/>
        <xsl:accept component="function" names="i18n:language-code-to-direction#1"
            visibility="private"/>
    </xsl:use-package>

    <xsl:mode name="text:hook-before" on-no-match="deep-skip" visibility="public"/>
    <xsl:mode name="text:hook-after" on-no-match="deep-skip" visibility="public"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/librend.xsl"
        package-version="1.0.0">
        <xsl:accept component="mode" names="text:text" visibility="public"/>
        <xsl:accept component="template" names="text:*" visibility="public"/>
        <xsl:override default-mode="text:text">
            <!-- text:hook-before and text:hook-after are modes that offer hooks for
                inserting project-specific things before and after an element -->

            <!-- parts of the document -->

            <!-- parts that should not be generate output in mode text:text -->
            <xsl:template match="teiHeader"/>

            <xsl:template match="text">
                <div class="text">
                    <xsl:if test="not(@xml:lang)">
                        <!-- assert that the language is set -->
                        <xsl:variable name="lang" select="i18n:language(.)"/>
                        <xsl:attribute name="xml:lang" select="$lang"/>
                        <xsl:attribute name="lang" select="$lang"/>
                        <xsl:attribute name="dir" select="i18n:language-code-to-direction($lang)"/>
                    </xsl:if>
                    <xsl:apply-templates select="@* | node()"/>
                </div>
            </xsl:template>

            <xsl:template match="body | front | back">
                <div>
                    <xsl:call-template name="text:class-attribute"/>
                    <xsl:apply-templates select="@* | node()"/>
                </div>
            </xsl:template>


            <!-- markup that has to be invisible in the edited text -->

            <xsl:template match="note">
                <xsl:apply-templates mode="text:hook-before" select="."/>
                <xsl:call-template name="text:inline-marks"/>
                <xsl:apply-templates mode="text:hook-after" select="."/>
            </xsl:template>

            <!-- rdg: Do not output reading (variant) in all modes generating edited text. -->
            <xsl:template match="rdg"/>

            <xsl:template match="witDetail"/>

            <xsl:template match="app">
                <xsl:apply-templates mode="text:hook-before" select="."/>
                <xsl:apply-templates select="lem"/>
                <xsl:call-template name="text:inline-marks"/>
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
                <!-- use hook instead? -->
                <xsl:text>[...]</xsl:text>
                <xsl:call-template name="text:inline-marks"/>
                <xsl:apply-templates mode="text:hook-after" select="."/>
            </xsl:template>

            <xsl:template match="unclear">
                <xsl:apply-templates mode="text:hook-before" select="."/>
                <span class="unclear">
                    <xsl:apply-templates select="@* | node()"/>
                </span>
                <xsl:apply-templates mode="text:hook-after" select="."/>
                <xsl:call-template name="text:inline-marks"/>
            </xsl:template>

            <xsl:template match="choice[child::sic and child::corr]">
                <xsl:apply-templates mode="text:hook-before" select="."/>
                <span class="choice-with-sic-and-corr">
                    <xsl:apply-templates select="@* | corr"/>
                </span>
                <xsl:apply-templates mode="text:hook-after" select="."/>
                <xsl:call-template name="text:inline-marks"/>
            </xsl:template>

            <xsl:template match="sic[not(parent::choice)]">
                <xsl:apply-templates mode="text:hook-before" select="."/>
                <span class="sic">
                    <xsl:apply-templates select="@* | node()"/>
                </span>
                <xsl:apply-templates mode="text:hook-after" select="."/>
                <xsl:call-template name="text:inline-marks"/>
            </xsl:template>

            <xsl:template match="corr[not(parent::choice)]">
                <xsl:apply-templates mode="text:hook-before" select="."/>
                <span class="corr">
                    <xsl:apply-templates select="@* | node()"/>
                </span>
                <xsl:apply-templates mode="text:hook-after" select="."/>
                <xsl:call-template name="text:inline-marks"/>
            </xsl:template>

            <xsl:template match="supplied[not(parent::choice)]">
                <xsl:apply-templates mode="text:hook-before" select="."/>
                <span class="supplied">
                    <xsl:apply-templates select="@* | node()"/>
                </span>
                <xsl:apply-templates mode="text:hook-after" select="."/>
                <xsl:call-template name="text:inline-marks"/>
            </xsl:template>

            <!-- support for quotes, which may need a footnote about the source -->
            <xsl:template match="quote | q">
                <xsl:apply-templates mode="text:hook-before" select="."/>
                <span>
                    <xsl:call-template name="text:class-attribute"/>
                    <xsl:apply-templates select="@* | node()"/>
                </span>
                <xsl:apply-templates mode="text:hook-after" select="."/>
                <xsl:call-template name="text:inline-marks"/>
            </xsl:template>



            <xsl:template match="@xml:id">
                <xsl:attribute name="id" select="."/>
            </xsl:template>

            <xsl:template match="@xml:lang">
                <xsl:attribute name="xml:lang" select="."/>
                <xsl:attribute name="lang" select="."/>
                <xsl:attribute name="dir" select="i18n:language-direction(.)"/>
            </xsl:template>

            <xsl:template match="@n">
                <xsl:attribute name="data-tei-n" select="."/>
            </xsl:template>

            <xsl:template match="@type">
                <xsl:attribute name="data-tei-type" select="."/>
            </xsl:template>
        </xsl:override>
    </xsl:use-package>


    <xsl:function name="text:non-lemma-nodes" as="node()*">
        <xsl:param name="element" as="node()"/>
        <xsl:sequence select="$element/descendant-or-self::rdg/descendant-or-self::node()"/>
    </xsl:function>

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

    <!-- you probably want to override this for adding footnote marks etc. to the text -->
    <xsl:template name="text:inline-marks" visibility="public"/>


</xsl:package>
