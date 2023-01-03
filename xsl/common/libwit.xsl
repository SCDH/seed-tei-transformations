<?xml version="1.0" encoding="UTF-8"?>
<!-- A TEI document may contain full witness information
    or only stubs that relate to a witnesses in central catalog.

    This is an XSLT library to deal with this.
    It hides away the details of the witness catalog and provides lookup functions.
    It takes an XPath expression as parameter that tells, where the information is stored.
-->
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libwit.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:wit="http://scdh.wwu.de/transform/wit#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs wit"
    version="3.0">

    <xsl:expose component="function" names="wit:*" visibility="public"/>
    <xsl:expose component="variable" names="wit:*" visibility="public"/>
    <xsl:expose component="variable" names="wit:witnesses" visibility="abstract"/>

    <!-- OVERRIDE! -->
    <xsl:variable name="wit:witnesses" as="element()*" visibility="abstract"/>

    <!-- XPath where to get the siglum of a witness -->
    <xsl:variable name="wit:siglum-xpath" as="xs:string" visibility="public">
        <xsl:text>descendant::abbr[@type eq 'siglum'][1]</xsl:text>
    </xsl:variable>

    <!-- XPath where to get the description of a witness -->
    <xsl:variable name="wit:description-xpath" as="xs:string" visibility="public">
        <xsl:text>string-join(descendant::text(), '') => normalize-space()</xsl:text>
    </xsl:variable>

    <!-- returns a list of space separated sigla for a list of IDREFs eg. from @wit -->
    <xsl:function name="wit:get-witness-siglum" as="xs:string">
        <xsl:param name="id" as="xs:string"/>
        <xsl:value-of select="wit:get-witness-siglum($id, ' ')"/>
    </xsl:function>

    <!-- returns a list of arbitrarily separated sigla for a list of IDREFs eg. from @wit -->
    <xsl:function name="wit:get-witness-siglum" as="xs:string">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="sep" as="xs:string"/>
        <xsl:value-of select="string-join(wit:get-witness-siglum-seq($id), $sep)"/>
    </xsl:function>

    <!-- lookup the sigla for a list of IDs or IDREFs eg. form @wit -->
    <xsl:function name="wit:get-witness-siglum-seq" as="xs:string*">
        <xsl:param name="id" as="xs:string"/>
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>count of witnesses: </xsl:text>
            <xsl:value-of select="count($wit:witnesses)"/>
        </xsl:message>
        <xsl:for-each select="tokenize($id)">
            <xsl:variable name="theId" select="wit:normalize-id(.)"/>
            <xsl:variable name="witness" select="$wit:witnesses[@xml:id eq $theId]"/>
            <xsl:choose>
                <xsl:when test="$witness">
                    <xsl:evaluate as="xs:string" context-item="$witness" expand-text="true"
                        xpath="$wit:siglum-xpath"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$theId"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>

    <!-- lookup the descriptions for a list of IDs or IDREFs eg. form @wit -->
    <xsl:function name="wit:get-witness-description-seq" as="xs:string*">
        <xsl:param name="id" as="xs:string"/>
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>count of witnesses: </xsl:text>
            <xsl:value-of select="count($wit:witnesses)"/>
        </xsl:message>
        <xsl:for-each select="tokenize($id)">
            <xsl:variable name="theId" select="wit:normalize-id(.)"/>
            <xsl:variable name="witness" select="$wit:witnesses[@xml:id eq $theId]"/>
            <xsl:choose>
                <xsl:when test="$witness">
                    <xsl:evaluate as="xs:string" context-item="$witness" expand-text="true"
                        xpath="$wit:description-xpath"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$theId"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>

    <!-- get the ID in an ID or an IDREF -->
    <xsl:function name="wit:normalize-id" visibility="private">
        <xsl:param name="in" as="xs:string"/>
        <xsl:value-of select="replace(normalize-space($in), '^#', '')"/>
    </xsl:function>

</xsl:package>
