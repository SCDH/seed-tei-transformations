<?xml version="1.0" encoding="UTF-8"?>
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libprose.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:text="http://scdh.wwu.de/transform/text#"
    xmlns:common="http://scdh.wwu.de/transform/common#"
    xmlns:i18n="http://scdh.wwu.de/transform/i18n#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    version="3.0" default-mode="text:text">


    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libtext.xsl"
        package-version="1.0.0">

        <xsl:accept component="mode" names="text:text" visibility="public"/>

        <xsl:override>

            <xsl:template match="text()">
                <xsl:value-of select="."/>
            </xsl:template>

            <xsl:template match="div">
                <section>
                    <xsl:call-template name="text:standard-attributes"/>
                    <xsl:apply-templates/>
                </section>
            </xsl:template>

            <xsl:template match="p">
                <p>
                    <xsl:call-template name="text:standard-attributes"/>
                    <xsl:apply-templates/>
                </p>
            </xsl:template>

            <xsl:template match="head">
                <xsl:variable name="heading"
                    select="concat('h', count(ancestor::*[matches(local-name(), 'div')]))"/>
                <xsl:element name="{$heading}">
                    <xsl:call-template name="text:standard-attributes"/>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:template>

            <!-- output pb/@n in square brackets -->
            <xsl:template match="pb">
                <xsl:text>[</xsl:text>
                <xsl:value-of select="@n"/>
                <xsl:text>]</xsl:text>
            </xsl:template>

        </xsl:override>


    </xsl:use-package>



</xsl:package>
