<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/2005/xpath-functions"
    xmlns:wit="http://scdh.wwu.de/transform/wit#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" expand-text="yes"
    exclude-result-prefixes="#all" version="3.0">

    <xsl:output method="text" indent="false"/>

    <!-- whether to flatten or to keep the nested structure of <listWit> elements -->
    <xsl:param name="wit:flatten" as="xs:boolean" select="true()"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libwit.xsl"
        package-version="1.0.0">

        <xsl:override>
            <xsl:variable name="wit:witnesses" as="element()*"
                select="//sourceDesc//witness[@xml:id]"/>
        </xsl:override>

    </xsl:use-package>


    <xsl:template match="/">
        <xsl:variable name="json-xml">
            <map>
                <xsl:apply-templates
                    select="descendant::sourceDesc/(descendant::listWit[not(ancestor::listWit)] | descendant::witness[not(ancestor::listWit)])"
                />
            </map>
        </xsl:variable>
        <xsl:value-of select="xml-to-json($json-xml, map {'indent': false()})"/>
    </xsl:template>

    <xsl:mode on-no-match="shallow-skip"/>

    <!-- if a listWit does not have an ID the structure is flattened -->
    <xsl:template match="listWit[not(@xml:id) or $wit:flatten]">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="listWit[@xml:id and not($wit:flatten)]">
        <map key="{@xml:id}">
            <string key="type">list</string>
            <xsl:if test="listWit">
                <map key="lists">
                    <xsl:apply-templates select="listWit"/>
                </map>
            </xsl:if>
            <xsl:if test="witness">
                <map key="witnesses">
                    <xsl:apply-templates select="witness"/>
                </map>
            </xsl:if>
        </map>
    </xsl:template>

    <xsl:template match="witness[@xml:id]">
        <map key="{@xml:id}">
            <string key="type">witness</string>
            <string key="siglum">
                <xsl:value-of select="string-join(wit:get-witness-siglum-seq(@xml:id), ', ')"/>
            </string>
            <string key="description">
                <xsl:value-of select="string-join(wit:get-witness-description-seq(@xml:id), ' | ')"
                />
            </string>
            <xsl:variable name="list" as="xs:string*" select="ancestor::listWit[@xml:id]/@xml:id"/>
            <xsl:if test="$list">
                <array key="list">
                    <xsl:for-each select="$list">
                        <string>
                            <xsl:value-of select="."/>
                        </string>
                    </xsl:for-each>
                </array>
            </xsl:if>
        </map>
    </xsl:template>

</xsl:stylesheet>
