<?xml version="1.0" encoding="UTF-8"?>
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libprose.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:text="http://scdh.wwu.de/transform/text#"
    xmlns:common="http://scdh.wwu.de/transform/common#"
    xmlns:i18n="http://scdh.wwu.de/transform/i18n#"
    xmlns:prose="http://scdh.wwu.de/transform/prose#"
    xmlns:source="http://scdh.wwu.de/transform/source#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    version="3.0" default-mode="text:text">


    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <!-- whether or not lb elements are evaluated in the HTML -->
    <xsl:param name="prose:linebreaks" as="xs:boolean" select="false()" required="false"/>

    <!-- the hyphenation mark to be inserted in <lb> inside a word -->
    <xsl:param name="prose:linebreaks-hyphen" as="xs:string" select="'-'" required="false"/>

    <!-- whether or not to output named anchors for headlines etc. required for toc -->
    <xsl:param name="prose:anchors" as="xs:boolean" select="false()" required="false"/>

    <!--
        A key for distinguishing text nodes in 'before', 'after' and 'both-ends' delimitation
        by in-word <lb>.
    -->
    <xsl:key name="text-delimited-by-in-word-lb" match="//text()">
        <xsl:variable name="this" as="text()" select="."/>
        <xsl:variable name="lb-before" as="element()?" select="preceding::lb[1][@break eq 'no']"/>
        <xsl:variable name="lb-after" as="element()?" select="following::lb[1][@break eq 'no']"/>
        <!-- make a sequence of values! -->
        <xsl:sequence>
            <xsl:if test="$lb-before">
                <xsl:variable name="text-before" as="node()*"
                    select="$lb-before/following::text() intersect $this/preceding::text()"/>
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>before: </xsl:text>
                    <xsl:value-of select="generate-id(.)"/>
                    <xsl:text> lb: </xsl:text>
                    <xsl:value-of select="generate-id($lb-before)"/>
                    <xsl:text> count of inter text nodes: </xsl:text>
                    <xsl:value-of select="count($text-before)"/>
                    <xsl:text> key value: </xsl:text>
                    <xsl:value-of select="normalize-space(string-join($text-before)) eq ''"/>
                    <xsl:text> content: "</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text>"</xsl:text>
                </xsl:message>
                <xsl:if test="normalize-space(string-join($text-before)) eq ''">before</xsl:if>
            </xsl:if>
            <xsl:if test="$lb-after">
                <xsl:variable name="text-after" as="node()*"
                    select="$this/following::text() intersect $lb-after/preceding::text()"/>
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>after: </xsl:text>
                    <xsl:value-of select="generate-id(.)"/>
                    <xsl:text> lb: </xsl:text>
                    <xsl:value-of select="generate-id($lb-after)"/>
                    <xsl:text> count of inter text nodes: </xsl:text>
                    <xsl:value-of select="count($text-after)"/>
                    <xsl:text> key value: </xsl:text>
                    <xsl:value-of select="normalize-space(string-join($text-after)) eq ''"/>
                    <xsl:text> content: "</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text>"</xsl:text>
                </xsl:message>
                <xsl:if test="normalize-space(string-join($text-after)) eq ''">after</xsl:if>
            </xsl:if>
            <xsl:if test="$lb-after and $lb-before">
                <xsl:variable name="text-before" as="node()*"
                    select="$lb-before/following::text() intersect $this/preceding::text()"/>
                <xsl:variable name="text-after" as="node()*"
                    select="$this/following::text() intersect $lb-after/preceding::text()"/>
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>both-ends: </xsl:text>
                    <xsl:value-of select="generate-id(.)"/>
                    <xsl:text> lb: </xsl:text>
                    <xsl:value-of select="generate-id($lb-before)"/>
                    <xsl:text> count of text nodes before: </xsl:text>
                    <xsl:value-of select="count($text-before)"/>
                    <xsl:text> count of text nodes after: </xsl:text>
                    <xsl:value-of select="count($text-after)"/>
                    <xsl:text> key value set: </xsl:text>
                    <xsl:value-of
                        select="normalize-space(string-join($text-before)) eq '' and normalize-space(string-join($text-after)) eq ''"/>
                    <xsl:text> content: "</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text>"</xsl:text>
                </xsl:message>
                <xsl:if
                    test="normalize-space(string-join($text-before)) eq '' and normalize-space(string-join($text-after)) eq ''"
                    >both-ends</xsl:if>
            </xsl:if>
        </xsl:sequence>
    </xsl:key>


    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libsource.xsl"
        package-version="1.0.0"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libcommon.xsl"
        package-version="0.1.0">
        <xsl:accept component="function" names="common:line-number#1" visibility="public"/>
    </xsl:use-package>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libtext.xsl"
        package-version="1.0.0">

        <xsl:accept component="template" names="text:*" visibility="public"/>
        <xsl:accept component="mode" names="*" visibility="public"/>
        <xsl:accept component="template" names="text:inline-marks" visibility="public"/>

        <xsl:override>

            <xsl:template match="div">
                <xsl:apply-templates mode="text:hook-before" select="."/>
                <section>
                    <xsl:call-template name="text:class-attribute"/>
                    <xsl:apply-templates select="@* | node()"/>
                </section>
                <xsl:apply-templates mode="text:hook-after" select="."/>
            </xsl:template>

            <xsl:template match="p">
                <xsl:apply-templates mode="text:hook-before" select="."/>
                <p>
                    <xsl:call-template name="text:class-attribute"/>
                    <xsl:apply-templates select="@* | node()"/>
                </p>
                <xsl:apply-templates mode="text:hook-after" select="."/>
            </xsl:template>

            <xsl:template match="head">
                <xsl:apply-templates mode="text:hook-before" select="."/>
                <xsl:variable name="level" as="xs:integer"
                    select="count(ancestor::*[matches(local-name(), 'div')])"/>
                <xsl:variable name="heading"
                    select="concat('h', if ($level eq 0) then 1 else $level)"/>
                <xsl:element name="{$heading}">
                    <xsl:call-template name="text:class-attribute"/>
                    <a class="target">
                        <xsl:attribute name="name" select="parent::*/@xml:id"/>
                        <xsl:if test="$prose:anchors">
                            <xsl:attribute name="href" select="'#' || parent::*/@xml:id"/>
                        </xsl:if>
                        <xsl:apply-templates select="@* | node()"/>
                    </a>
                    <xsl:apply-templates mode="text:hook-after" select="."/>
                </xsl:element>
            </xsl:template>

            <!-- output pb/@n in square brackets -->
            <xsl:template match="pb">
                <xsl:apply-templates mode="text:hook-before" select="."/>
                <span class="pb static-text">
                    <xsl:call-template name="text:class-attribute"/>
                    <xsl:apply-templates select="@*"/>
                    <xsl:text>[</xsl:text>
                    <xsl:value-of select="@n"/>
                    <xsl:text>]</xsl:text>
                </span>
                <xsl:apply-templates mode="text:hook-after" select="."/>
            </xsl:template>

            <!-- minimal support for verses -->

            <xsl:template match="lg[l]">
                <xsl:apply-templates mode="text:hook-before" select="."/>
                <div>
                    <xsl:call-template name="text:class-attribute">
                        <xsl:with-param name="additional" select="'stanza'"/>
                    </xsl:call-template>
                    <xsl:apply-templates select="@* | node()"/>
                </div>
                <xsl:apply-templates mode="text:hook-after" select="."/>
            </xsl:template>

            <xsl:template match="l">
                <xsl:apply-templates mode="text:hook-before" select="."/>
                <div>
                    <xsl:call-template name="text:class-attribute">
                        <xsl:with-param name="additional" select="'verse'"/>
                    </xsl:call-template>
                    <xsl:apply-templates select="@* | node()"/>
                </div>
                <xsl:apply-templates mode="text:hook-after" select="."/>
            </xsl:template>

            <xsl:template match="caesura">
                <xsl:apply-templates mode="text:hook-before" select="."/>
                <span>
                    <xsl:call-template name="text:class-attribute">
                        <xsl:with-param name="additional" select="'static-text'"/>
                    </xsl:call-template>
                    <xsl:apply-templates select="@*"/>
                    <!-- leave to hooks or css? -->
                    <xsl:text> || </xsl:text>
                </span>
                <xsl:apply-templates mode="text:hook-after" select="."/>
            </xsl:template>


            <!-- diplomatic presentation with linebreaks -->

            <!-- @break='no' means that lb is inside a token and therefore a hyphen must be inserted -->
            <xsl:template match="lb[$prose:linebreaks]">
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>text nodes from before key: </xsl:text>
                    <xsl:value-of select="key('text-delimited-by-in-word-lb', 'before') => count()"/>
                    <xsl:text> text nodes from after key: </xsl:text>
                    <xsl:value-of select="key('text-delimited-by-in-word-lb', 'after') => count()"/>
                    <xsl:text> text nodes from double key: </xsl:text>
                    <xsl:value-of
                        select="key('text-delimited-by-in-word-lb', 'both-ends') => count()"/>
                </xsl:message>
                <xsl:if test="@break eq 'no'">
                    <span class="hyphen">
                        <xsl:value-of select="$prose:linebreaks-hyphen"/>
                    </span>
                </xsl:if>
                <br/>
                <xsl:text>&#xa;</xsl:text>
                <span class="line-number">
                    <xsl:value-of select="common:line-number(.)"/>
                </span>
            </xsl:template>

            <!-- remove whitespace next to lb -->
            <xsl:template match="key('text-delimited-by-in-word-lb', 'both-ends')" priority="20">
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>cutting whitespace at both ends</xsl:text>
                </xsl:message>
                <xsl:call-template name="source:text-node">
                    <xsl:with-param name="content"
                        select="replace(., '^\s+', '') => replace('\s+$', '')"/>
                </xsl:call-template>
            </xsl:template>

            <xsl:template match="key('text-delimited-by-in-word-lb', 'after')" priority="10">
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>cutting whitespace at end</xsl:text>
                </xsl:message>
                <xsl:call-template name="source:text-node">
                    <xsl:with-param name="content" select="replace(., '\s+$', '')"/>
                </xsl:call-template>
            </xsl:template>

            <xsl:template match="key('text-delimited-by-in-word-lb', 'before')">
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>cutting whitespace a beginning</xsl:text>
                </xsl:message>
                <xsl:call-template name="source:text-node">
                    <xsl:with-param name="content" select="replace(., '^\s+', '')"/>
                </xsl:call-template>
            </xsl:template>

        </xsl:override>


    </xsl:use-package>



</xsl:package>
