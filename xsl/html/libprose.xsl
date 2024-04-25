<?xml version="1.0" encoding="UTF-8"?>
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libprose.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:text="http://scdh.wwu.de/transform/text#"
    xmlns:common="http://scdh.wwu.de/transform/common#"
    xmlns:i18n="http://scdh.wwu.de/transform/i18n#"
    xmlns:prose="http://scdh.wwu.de/transform/prose#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    version="3.0" default-mode="text:text">


    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <!-- whether or not lb elements are evaluated in the HTML -->
    <xsl:param name="prose:linebreaks" as="xs:boolean" select="false()" required="false"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libtext.xsl"
        package-version="1.0.0">

        <xsl:accept component="variable" names="i18n:default-language" visibility="abstract"/>
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
                <xsl:variable name="level" as="xs:integer" select="count(ancestor::*[matches(local-name(), 'div')])"/>
                <xsl:variable name="heading"
                    select="concat('h', if ($level eq 0) then 1 else $level)"/>
                <xsl:element name="{$heading}">
                    <xsl:call-template name="text:class-attribute"/>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:element>
                <xsl:apply-templates mode="text:hook-after" select="."/>
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

            <xsl:template match="lb[$prose:linebreaks]">
                <br/>
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

        </xsl:override>


    </xsl:use-package>



</xsl:package>
