<?xml version="1.0" encoding="UTF-8"?>
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libprose.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://scdh.wwu.de/transform/i18n#"
    xmlns:register="http://scdh.wwu.de/transform/register#"
    xmlns:naf="http://scdh.wwu.de/transform/naf#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    version="3.0">

    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <xsl:param name="register:sortable" as="xs:boolean" select="true()"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libnaf.xsl"
        package-version="1.0.0"/>

    <xsl:template name="register:register">
        <xsl:context-item as="element()" use="required"/>
        <xsl:variable name="heads" as="xs:string*">
            <xsl:apply-templates mode="register:heads" select="."/>
        </xsl:variable>
        <xsl:variable name="columns" as="xs:string*">
            <xsl:apply-templates mode="register:columns" select="."/>
        </xsl:variable>
        <xsl:assert test="count($heads) eq count($columns)">
            <xsl:text>202</xsl:text>
            <xsl:text>Count of heads and columns differ</xsl:text>
        </xsl:assert>
        <table>
            <xsl:attribute name="class">
                <xsl:value-of select="local-name(.)"/>
                <xsl:if test="$register:sortable">
                    <xsl:text>sortable</xsl:text>
                </xsl:if>
            </xsl:attribute>
            <thead>
                <tr>
                    <xsl:for-each select="$heads">
                        <th>
                            <xsl:value-of select="."/>
                        </th>
                    </xsl:for-each>
                </tr>
            </thead>
            <xsl:apply-templates mode="register:row">
                <xsl:with-param name="columns" as="xs:string*" select="$columns" tunnel="true"/>
            </xsl:apply-templates>
        </table>
    </xsl:template>

    <!-- modes register:heads and register:columns determine the header and the columns of the table -->
    <xsl:mode name="register:heads" on-no-match="fail" visibility="public"/>
    <xsl:mode name="register:columns" on-no-match="fail" visibility="public"/>

    <xsl:template mode="register:heads" match="*" as="xs:string*">
        <xsl:value-of>ID</xsl:value-of>
        <xsl:value-of>Name</xsl:value-of>
        <xsl:value-of>URI</xsl:value-of>
    </xsl:template>

    <xsl:template mode="register:columns" match="*" as="xs:string*">
        <xsl:value-of>@xml:id</xsl:value-of>
        <xsl:value-of>*[local-name(.) => lower-case() => ends-with('name')]</xsl:value-of>
        <xsl:value-of>@xml:id</xsl:value-of>
    </xsl:template>



    <xsl:mode name="register:row" on-no-match="shallow-skip" visibility="public"/>

    <xsl:template mode="register:row" match="person | place | org | event">
        <xsl:param name="columns" as="xs:string*" tunnel="true"/>
        <xsl:variable name="context" as="element()" select="."/>
        <tr>
            <xsl:for-each select="$columns">
                <td>
                    <xsl:variable name="cell" as="element()*">
                        <xsl:evaluate as="element()*" expand-text="true" xpath="."
                            context-item="$context"/>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="count($cell) le 1">
                            <xsl:apply-templates mode="register:cell" select="$cell"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <ul class="data-sequence">
                                <xsl:for-each select="$cell">
                                    <li>
                                        <xsl:apply-templates mode="register:cell" select="."/>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </xsl:for-each>
        </tr>
    </xsl:template>

    <xsl:mode name="register:cell" on-no-match="shallow-skip" visibility="public"/>

    <!-- default cell output -->
    <xsl:template mode="register:cell" match="node() | attribute()">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template mode="register:cell" match="idno[@xml:base]">
        <xsl:apply-templates mode="naf:label" select="."/>
        <xsl:text>:</xsl:text>
        <a>
            <xsl:attribute name="href" select="@xml:base || string(.)"/>
            <xsl:value-of select="."/>
        </a>
    </xsl:template>


</xsl:package>
