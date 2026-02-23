<?xml version="1.0" encoding="UTF-8"?>
<!-- make transformation.scenarios from scenarios defined in xpr

USAGE:

target/bin/xslt.sh -xsl:utils/scenarios.xsl -s:SEED_TEI_Transformations.xpr

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="3.0">

    <xsl:output method="xml" indent="true"/>

    <xsl:param name="extension-url" as="xs:string"
        select="'${pluginDirURL(de.wwu.scdh.tei.seed-tei-transformations)}'"/>

    <xsl:param name="edition" as="xs:string" select="'ee'"/>

    <xsl:template match="/">
        <serialized xml:space="preserve">
            <serializableOrderedMap>
                <entry>
                    <String>scenarios</String>
                    <scenario-array>
                        <xsl:apply-templates select="//scenario-array/scenario"/>
                    </scenario-array>
                </entry>
            </serializableOrderedMap>
        </serialized>
    </xsl:template>

    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:template match="field[@name = 'configSystemID']/String/text()">
        <xsl:call-template name="replace-edition">
            <xsl:with-param name="config">
                <xsl:call-template name="replace-url"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="field[@name = 'inputXSLURL']/String/text()">
        <xsl:call-template name="replace-url"/>
    </xsl:template>

    <!--
        There may be ${pdu} parameter values,
        but only within the xsl directory this is assumed to be extension-internal.
    -->
    <xsl:template
        match="transformationParameter/field[@name = 'value']/String/text()[matches(., '^\$\{pdu\}/xsl/')]">
        <xsl:call-template name="replace-url"/>
    </xsl:template>


    <xsl:template name="replace-url">
        <xsl:context-item as="text()" use="required"/>
        <xsl:analyze-string select="." regex="{'^\$\{pdu\}'}">
            <xsl:matching-substring>
                <xsl:value-of select="$extension-url"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template name="replace-edition">
        <xsl:param name="config" as="xs:string"/>
        <xsl:analyze-string select="$config" regex="saxon\.[hpe]e\.">
            <xsl:matching-substring>
                <xsl:text>saxon.</xsl:text>
                <xsl:value-of select="$edition"/>
                <xsl:text>.</xsl:text>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

</xsl:stylesheet>
