<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:eg="http://www.tei-c.org/ns/Examples"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    version="3.0">

    <xsl:output method="xml" indent="true"/>

    <xsl:param name="outdir" as="xs:string" select="resolve-uri('examples/', static-base-uri())"/>

    <!-- project directory URI -->
    <xsl:param name="pdu" as="xs:string" select="resolve-uri('..', static-base-uri())"/>

    <xsl:param name="default-app-info" as="element(appInfo)" select="id('diplomatic-render')"/>

    <xsl:template match="document-node()">
        <xsl:call-template name="examples"/>
        <xsl:call-template name="ant-build-file"/>
    </xsl:template>


    <!-- output examples to separate result-documents -->
    <xsl:template name="examples">
        <xsl:context-item as="document-node(element(TEI))" use="required"/>
        <xsl:for-each select="/TEI/text/body//eg:egXML">
            <xsl:result-document href="{resolve-uri(@xml:id, $outdir)}.xml"
                exclude-result-prefixes="#all" indent="no">
                <xsl:choose>
                    <xsl:when test="@source">
                        <xsl:apply-templates mode="wrap" select="substring(@source, 2) => id()">
                            <xsl:with-param name="slotted-children" as="node()*" select="node()"
                                tunnel="true"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="example" select="node()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>

    <!-- mode for outputting part of a result-document containing the wrapping doc -->
    <xsl:mode name="wrap" on-no-match="shallow-copy"/>

    <!-- mode for outputting part of a result-document containing the example -->
    <xsl:mode name="example" on-no-match="shallow-copy"/>

    <xsl:template mode="wrap" match="eg:egXML">
        <xsl:apply-templates mode="wrap"/>
    </xsl:template>

    <xsl:template mode="wrap" match="*[@n eq 'slot']">
        <xsl:param name="slotted-children" as="node()*" tunnel="true"/>
        <xsl:copy>
            <xsl:apply-templates mode="wrap" select="@*"/>
            <xsl:apply-templates mode="example" select="$slotted-children"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template name="ant-build-file">
        <project basedir="." name="transform-examples" default="transform">

            <!-- default target -->
            <target name="transform">
                <xsl:apply-templates mode="antcall"/>
            </target>

            <xsl:apply-templates mode="target"/>

        </project>
    </xsl:template>

    <xsl:mode name="antcall" on-no-match="shallow-skip"/>

    <xsl:template mode="antcall" match="back"/>

    <xsl:template mode="antcall" match="eg:egXML[@xml:id]">
        <xsl:choose>
            <xsl:when test="@rendition">
                <xsl:variable name="context" as="element(eg:egXML)" select="."/>
                <xsl:for-each select="tokenize(@rendition)">
                    <antcall target="{$context/@xml:id}_{substring(., 2)}"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <antcall target="{@xml:id}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:mode name="target" on-no-match="shallow-skip"/>

    <xsl:template mode="target" match="eg:egXML[@xml:id]">
        <xsl:variable name="context" as="element(eg:egXML)" select="."/>
        <xsl:choose>
            <xsl:when test="@rendition">
                <xsl:for-each select="tokenize(@rendition)">
                    <xsl:variable name="rendition" as="xs:string" select="substring(., 2)"/>
                    <target name="{$context/@xml:id}_{$rendition}">
                        <xsl:call-template name="xslt-target">
                            <xsl:with-param name="example" as="element(eg:egXML)" select="$context"/>
                            <xsl:with-param name="rendition" as="element(appInfo)"
                                select="id($rendition, root($context))"/>
                        </xsl:call-template>
                    </target>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <target target="{@xml:id}">
                    <xsl:call-template name="xslt-target">
                        <xsl:with-param name="example" as="element(eg:egXML)" select="$context"/>
                    </xsl:call-template>
                </target>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="xslt-target">
        <xsl:param name="example" as="element(eg:egXML)"/>
        <xsl:param name="rendition" as="element(appInfo)" required="false"
            select="$default-app-info"/>
        <xslt>
            <xsl:attribute name="stylesheet" select="resolve-uri($rendition/@source, $pdu)"/>
            <xsl:attribute name="in" select="resolve-uri($example/@xml:id || '.xml', $outdir)"/>
            <xsl:attribute name="out"
                select="resolve-uri($example/@xml:id || '_' || $rendition/@xml:id || '.' || $rendition/@n, $outdir)"
            />
        </xslt>
    </xsl:template>

</xsl:stylesheet>
