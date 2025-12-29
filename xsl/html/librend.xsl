<?xml version="1.0" encoding="UTF-8"?>
<!-- replacement of common/librend.xsl for basic text formatting in HTML output

NOTE: This MUST be a replacement of common/librend.xsl, not a deriving package!
The reason is the constraints on the package hierarchy, which does not allow to
merge modes from deriving packages.

common/libapp2 and html/librend add to the same mode 


This is to be imported once into your main stylesheet if you want basic formatting
in the base text, the apparatus and in the editorial notes. -->
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/librend.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:text="http://scdh.wwu.de/transform/text#"
    xmlns:app="http://scdh.wwu.de/transform/app#" xmlns:note="http://scdh.wwu.de/transform/note#"
    xmlns:i18n="http://scdh.wwu.de/transform/i18n#" exclude-result-prefixes="#all"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/librend-base.xsl"
        package-version="1.0.0">
        <xsl:accept component="*" names="*" visibility="public"/>
        <xsl:override>

            <xsl:template mode="text:text app:reading-text note:editorial" match="*[@rendition]"
                priority="0.6">
                <span>
                    <xsl:call-template name="text:class-attribute"/>
                    <xsl:apply-templates mode="#current" select="@* | node()"/>
                </span>
            </xsl:template>

            <xsl:template mode="text:text app:reading-text note:editorial"
                match="hi[@rend eq 'bold']">
                <b>
                    <xsl:call-template name="text:class-attribute-opt"/>
                    <xsl:apply-templates mode="#current" select="@* | node()"/>
                </b>
            </xsl:template>

            <xsl:template mode="text:text app:reading-text note:editorial"
                match="hi[@rend eq 'italic']">
                <i>
                    <xsl:call-template name="text:class-attribute-opt"/>
                    <xsl:apply-templates mode="#current" select="@* | node()"/>
                </i>
            </xsl:template>

            <xsl:template mode="text:text app:reading-text note:editorial"
                match="hi[@rend = ('underline', 'ul')]">
                <u>
                    <xsl:call-template name="text:class-attribute-opt"/>
                    <xsl:apply-templates mode="#current" select="@* | node()"/>
                </u>
            </xsl:template>

            <xsl:template mode="text:text app:reading-text note:editorial"
                match="hi[@rend eq 'superscript']">
                <sup>
                    <xsl:call-template name="text:class-attribute-opt"/>
                    <xsl:apply-templates mode="#current" select="@* | node()"/>
                </sup>
            </xsl:template>

            <!-- segmentation offers hooks for project-specific insertions -->
            <xsl:template mode="text:text app:reading-text note:editorial"
                match="seg | s | w | c | pc">
                <span>
                    <xsl:call-template name="text:class-attribute"/>
                    <xsl:apply-templates mode="#current" select="@* | node()"/>
                </span>
            </xsl:template>

            <!-- space left by scribe (lacuna) -->
            <xsl:template mode="text:text app:reading-text" match="space">
                <span class="static-text space">[...]</span>
            </xsl:template>

            <!-- space left by scribe with quantity annotation -->
            <xsl:template mode="app:reading-text" match="space[@quantity]">
                <xsl:try>
                    <xsl:variable name="quantity" as="xs:integer" select="xs:integer(@quantity)"/>
                    <xsl:choose>
                        <xsl:when test="$quantity gt 3">
                            <span class="static-text space">[...</span>
                            <span class="quantity-annotation" style="vertical-align: super">
                                <xsl:value-of select="@quantity || ' ' || @unit"/>
                            </span>
                            <xsl:for-each select="4 to min(($quantity, 10))">
                                <xsl:text>.</xsl:text>
                            </xsl:for-each>
                            <span class="static-text space">]</span>
                        </xsl:when>
                        <xsl:otherwise>
                            <span class="static-text space">[..</span>
                            <span class="quantity-annotation" style="vertical-align: super">
                                <xsl:value-of select="@quantity || ' ' || @unit"/>
                            </span>
                            <span class="static-text space">.]</span>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:catch>
                        <span class="static-text space">[..</span>
                        <span class="quantity-annotation" style="vertical-align: super">
                            <xsl:value-of select="@quantity || ' ' || @unit"/>
                        </span>
                        <span class="static-text space">.]</span>
                    </xsl:catch>
                </xsl:try>
            </xsl:template>

            <!-- drop attributes for which there is not special rule -->
            <xsl:template mode="text:text app:reading-text note:editorial" match="@*"/>

            <xsl:template name="text:class-attribute" visibility="public">
                <xsl:param name="context" as="element()" select="." required="false"/>
                <xsl:param name="additional" as="xs:string*" select="()" required="false"/>
                <xsl:attribute name="class"
                    select="($context/local-name(), $additional, $context/@type, tokenize($context/@rendition) ! substring(., 2)) => string-join(' ')"
                />
            </xsl:template>

            <xsl:template name="text:class-attribute-opt" visibility="public">
                <xsl:param name="context" as="element()" select="." required="false"/>
                <xsl:param name="additional" as="xs:string*" select="()" required="false"/>
                <xsl:if test="$context/@type or $context/@rendition or $additional">
                    <xsl:attribute name="class"
                        select="($additional, $context/@type, tokenize($context/@rendition) ! substring(., 2)) => string-join(' ')"
                    />
                </xsl:if>
            </xsl:template>

        </xsl:override>
    </xsl:use-package>

</xsl:package>
