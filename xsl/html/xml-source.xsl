<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT for formatted output of an XML source file to HTML

USAGE:
java -jar=saxon.jar -config:saxon.xml -xsl:xsl/html/xml-source.xsl -s:SOURCE_DOC -o:OUTPUT.html

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:text="http://scdh.wwu.de/transform/text#"
    xmlns:html="http://scdh.wwu.de/transform/html#" xmlns:i18n="http://scdh.wwu.de/transform/i18n#"
    xmlns:source="http://scdh.wwu.de/transform/source#" xmlns:eg="http://www.tei-c.org/ns/Examples"
    exclude-result-prefixes="#all" version="3.1" default-mode="source:source">

    <xsl:output method="html" encoding="UTF-8"/>

    <!-- whether to use the HTML template from libhtml and make a full HTML file -->
    <xsl:param name="use-libhtml" as="xs:boolean" select="true()"/>

    <xsl:param name="source:element-name-color" as="xs:string" select="'darkblue'"/>
    <xsl:param name="source:attribute-name-color" as="xs:string" select="'darkorange'"/>
    <xsl:param name="source:attribute-value-color" as="xs:string" select="'brown'"/>
    <xsl:param name="source:namespace-color" as="xs:string" select="'deepskyblue'"/>
    <xsl:param name="source:angle-brackets-color" as="xs:string" select="'darkblue'"/>
    <xsl:param name="source:equals-color" as="xs:string" select="'red'"/>
    <xsl:param name="source:quotes-color" as="xs:string" select="'brown'"/>
    <xsl:param name="source:comment-delimiter-color" as="xs:string" select="'forestgreen'"/>
    <xsl:param name="source:comment-value-color" as="xs:string" select="'forestgreen'"/>
    <xsl:param name="source:pi-namespace-color" as="xs:string" select="'darkviolet'"/>
    <xsl:param name="source:xml-declaration-color" as="xs:string" select="'darkviolet'"/>
    <xsl:param name="source:text-color" as="xs:string" select="'black'"/>

    <xsl:param name="default-language" as="xs:string" select="'en'"/>

    <!-- if true (default), <eg:egXML> will not be contained in the output, but its children will -->
    <xsl:param name="drop-egxml" as="xs:boolean" select="true()" static="true"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libi18n.xsl"
        package-version="0.1.0">
        <xsl:override>
            <xsl:variable name="i18n:default-language" as="xs:string" select="$default-language"/>
        </xsl:override>
    </xsl:use-package>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libhtml.xsl"
        package-version="1.0.0">

        <xsl:accept component="mode" names="html:html" visibility="public"/>
        <xsl:accept component="template" names="html:*" visibility="public"/>

        <xsl:override>

            <xsl:template name="html:content">
                <div class="document" style="font-family:monospace;">
                    <xsl:call-template name="source:xml-declaration"/>
                    <xsl:apply-templates mode="source:source"/>
                </div>
            </xsl:template>

        </xsl:override>
    </xsl:use-package>


    <xsl:mode name="source" on-no-match="shallow-skip" visibility="public"/>

    <!-- if parameter $use-libhtml is true, switch to html:html mode -->
    <xsl:template match="document-node()" mode="source:source">
        <xsl:choose>
            <xsl:when test="$use-libhtml">
                <xsl:apply-templates mode="html:html" select="root()"/>
            </xsl:when>
            <xsl:otherwise>
                <div class="document" style="font-family:monospace;">
                    <xsl:call-template name="source:xml-declaration"/>
                    <xsl:apply-templates mode="source:source"
                        select="/node() | /comment() | /processing-instruction()"/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:mode name="source:source" on-no-match="shallow-skip"/>

    <xsl:template mode="source:source" match="eg:egXML" use-when="$drop-egxml">
        <xsl:apply-templates mode="source:source"/>
    </xsl:template>

    <xsl:template match="element()" mode="source:source">
        <span class="angle-brackets" style="color:{$source:angle-brackets-color}">
            <xsl:text>&lt;</xsl:text>
        </span>
        <span class="element-name" style="color:{$source:element-name-color};">
            <xsl:value-of select="name(.)"/>
        </span>
        <xsl:apply-templates mode="source:source" select="namespace::* | attribute::*"/>
        <span class="angle-brackets" style="color:{$source:angle-brackets-color}">
            <xsl:text>&gt;</xsl:text>
        </span>
        <xsl:apply-templates mode="source:source" select="node()"/>
        <span class="angle-brackets" style="color:{$source:angle-brackets-color}">
            <xsl:text>&lt;/</xsl:text>
        </span>
        <span class="element-name" style="color:{$source:element-name-color};">
            <xsl:value-of select="name(.)"/>
        </span>
        <span class="angle-brackets" style="color:{$source:angle-brackets-color}">
            <xsl:text>&gt;</xsl:text>
        </span>
    </xsl:template>

    <xsl:template match="element()[not(node())]" mode="source:source">
        <span class="angle-brackets" style="color:{$source:angle-brackets-color}">
            <xsl:text>&lt;</xsl:text>
        </span>
        <span class="element-name" style="color:{$source:element-name-color};">
            <xsl:value-of select="name(.)"/>
        </span>
        <xsl:apply-templates mode="source:source" select="namespace::* | attribute::*"/>
        <span class="angle-brackets" style="color:{$source:angle-brackets-color}">
            <xsl:text>/&gt;</xsl:text>
        </span>
    </xsl:template>

    <xsl:template mode="source:source" match="attribute()">
        <xsl:text> </xsl:text>
        <span class="attribute-name" style="color:{$source:attribute-name-color}">
            <xsl:value-of select="name(.)"/>
        </span>
        <xsl:call-template name="source:attribute-value"/>
    </xsl:template>

    <xsl:template name="source:attribute-value">
        <xsl:context-item as="item()" use="required"/>
        <span class="attribute-equals" style="color:{$source:equals-color}">
            <xsl:text>=</xsl:text>
        </span>
        <span class="attribute-quotes" style="color:{$source:quotes-color}">
            <xsl:text>"</xsl:text>
        </span>
        <span class="attribute-value" style="color:{$source:attribute-value-color}">
            <xsl:call-template name="source:text"/>
        </span>
        <span class="attribute-quotes" style="color:{$source:quotes-color}">
            <xsl:text>"</xsl:text>
        </span>
    </xsl:template>

    <xsl:template mode="source:source" match="namespace::*">
        <xsl:variable name="prefix" select="name(.)"/>
        <xsl:variable name="ns_name" select="."/>
        <xsl:if test="not(parent::*/parent::*/namespace::*[name(.) eq $prefix and . eq $ns_name])">
            <xsl:choose>
                <xsl:when test="name(.) ne ''">
                    <xsl:text> </xsl:text>
                    <span class="attribute-name" style="color:{$source:namespace-color}">
                        <xsl:text>xmlns:</xsl:text>
                        <xsl:value-of select="name(.)"/>
                    </span>
                    <xsl:call-template name="source:attribute-value"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- handle default namespace -->
                    <xsl:text> </xsl:text>
                    <span class="attribute-name" style="color:{$source:namespace-color}">
                        <xsl:text>xmlns</xsl:text>
                    </span>
                    <xsl:call-template name="source:attribute-value"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>


    <xsl:template mode="source:source" match="text()">
        <span class="text" style="color:{$source:text-color}">
            <xsl:call-template name="source:text"/>
        </span>
    </xsl:template>

    <xsl:template name="source:text">
        <xsl:context-item use="required" as="item()"/>
        <xsl:analyze-string select="string(.)" regex="&#xa;&#xd;?(&#x20;*)">
            <xsl:matching-substring>
                <br/>
                <xsl:if test="regex-group(1) => string-length() gt 0">
                    <span class="identation"
                        style="margin-left:{regex-group(1) => string-length()}em;"/>
                </xsl:if>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <!--xsl:analyze-string select="." regex="&amp;[^;]+;">
                    <xsl:matching-substring>
                        <span class="entity" style="color:{$source:entity-color}">
                            <xsl:value-of select="."/>
                        </span>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string-->
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template mode="source:source" match="comment()">
        <span class="angle-brackets" style="color:{$source:comment-delimiter-color}">
            <xsl:text>&lt;!--</xsl:text>
        </span>
        <span class="pi" style="color:{$source:comment-value-color};">
            <xsl:call-template name="source:text"/>
        </span>
        <span class="angle-brackets" style="color:{$source:comment-delimiter-color}">
            <xsl:text>--&gt;</xsl:text>
        </span>
    </xsl:template>

    <xsl:template mode="source:source" match="processing-instruction()">
        <?msg Nice! :p?>
        <span class="angle-brackets" style="color:{$source:pi-namespace-color}">
            <xsl:text>&lt;?</xsl:text>
        </span>
        <span class="pi-name" style="color:{$source:pi-namespace-color};">
            <xsl:value-of select="name(.)"/>
            <xsl:text> </xsl:text>
        </span>
        <span class="pi" style="color:{$source:text-color};">
            <xsl:value-of select="."/>
        </span>
        <span class="angle-brackets" style="color:{$source:pi-namespace-color}">
            <xsl:text>?&gt;</xsl:text>
        </span>
    </xsl:template>

    <xsl:template name="source:xml-declaration">
        <?msg really??>
        <xsl:context-item as="document-node()" use="required"/>
        <xsl:variable name="unparsed" select="base-uri() => unparsed-text()"/>
        <xsl:variable name="decl" as="xs:string?">
            <xsl:analyze-string select="$unparsed" regex="^\s*(&lt;\?xml\s[^\?]+\?&gt;)">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(1)"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:if test="$decl ne ''">
            <span class="xml-declaration" style="color:{$source:xml-declaration-color}">
                <xsl:value-of select="$decl"/>
            </span>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
