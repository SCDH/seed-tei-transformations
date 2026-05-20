<?xml version="1.0" encoding="UTF-8"?>
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libregister.xsl"
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

    <xsl:template name="register:table" visibility="final">
        <xsl:context-item as="element()" use="required"/>
        <!-- make column vectors -->
        <xsl:variable name="heads" as="xs:string*">
            <xsl:apply-templates mode="register:heads" select="."/>
        </xsl:variable>
        <xsl:variable name="columns" as="xs:string*">
            <xsl:apply-templates mode="register:columns" select="."/>
        </xsl:variable>
        <xsl:variable name="column-is-num" as="xs:boolean*">
            <xsl:apply-templates mode="register:column-is-num" select="."/>
        </xsl:variable>

        <!-- assert that all column vectors are of equal length -->
        <xsl:assert
            test="count($heads) eq count($columns) and count($heads) eq count($column-is-num)">
            <xsl:text>202</xsl:text>
            <xsl:text>Count of heads and columns differ</xsl:text>
        </xsl:assert>

        <xsl:variable name="classes" as="xs:string*">
            <xsl:value-of select="local-name(.)"/>
            <xsl:if test="$register:sortable">
                <xsl:text>sortable</xsl:text>
            </xsl:if>
        </xsl:variable>
        <table>
            <xsl:attribute name="class" select="$classes"/>
            <thead>
                <tr>
                    <xsl:for-each select="$heads">
                        <xsl:variable name="col" as="xs:integer" select="position()"/>
                        <th>
                            <xsl:if test="$column-is-num[$col]">
                                <xsl:attribute name="class">num</xsl:attribute>
                            </xsl:if>
                            <button>
                                <xsl:value-of select="."/>
                                <span aria-hidden="true"/>
                            </button>
                        </th>
                    </xsl:for-each>
                </tr>
            </thead>
            <tbody>
                <xsl:apply-templates mode="register:row">
                    <xsl:with-param name="columns" as="xs:string*" select="$columns" tunnel="true"/>
                    <xsl:with-param name="column-is-num" as="xs:boolean*" select="$column-is-num"
                        tunnel="true"/>
                </xsl:apply-templates>
            </tbody>
        </table>
    </xsl:template>

    <!-- modes register:heads and register:columns determine the header and the columns of the table -->
    <xsl:mode name="register:heads" on-no-match="fail" visibility="public"/>
    <xsl:mode name="register:columns" on-no-match="fail" visibility="public"/>
    <xsl:mode name="register:column-is-num" on-no-match="fail" visibility="public"/>


    <xsl:template mode="register:heads" match="*" as="xs:string*">
        <xsl:value-of>No.</xsl:value-of>
        <xsl:value-of>ID</xsl:value-of>
        <xsl:value-of>Name</xsl:value-of>
        <xsl:value-of>URI</xsl:value-of>
    </xsl:template>

    <xsl:template mode="register:columns" match="*" as="xs:string*">
        <xsl:value-of>preceding-sibling::* => count() + 1</xsl:value-of>
        <xsl:value-of>@xml:id</xsl:value-of>
        <xsl:value-of>*[local-name(.) => lower-case() => ends-with('name')]</xsl:value-of>
        <xsl:value-of>idno</xsl:value-of>
    </xsl:template>

    <xsl:template mode="register:column-is-num" match="*" as="xs:boolean*">
        <xsl:sequence select="true(), false(), false(), false()"/>
    </xsl:template>




    <xsl:mode name="register:row" on-no-match="shallow-skip" visibility="public"/>

    <xsl:template mode="register:row" match="person | place | org | event">
        <xsl:param name="columns" as="xs:string*" tunnel="true"/>
        <xsl:param name="column-is-num" as="xs:boolean*" tunnel="true"/>
        <xsl:variable name="context" as="element()" select="."/>
        <tr>
            <xsl:if test="@xml:id">
                <xsl:attribute name="id" select="@xml:id"/>
            </xsl:if>
            <xsl:for-each select="$columns">
                <xsl:variable name="col" as="xs:integer" select="position()"/>
                <xsl:variable name="classes" as="xs:string*">
                    <xsl:if test="$column-is-num[$col]">
                        <xsl:text>num</xsl:text>
                    </xsl:if>
                </xsl:variable>
                <td>
                    <xsl:if test="not(empty($classes))">
                        <xsl:attribute name="class" select="$classes"/>
                    </xsl:if>
                    <xsl:variable name="cell" as="item()*">
                        <xsl:evaluate as="item()*" expand-text="true" xpath="."
                            context-item="$context"/>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="empty($cell)"/>
                        <xsl:when test="register:is-atomic($cell)">
                            <xsl:value-of select="$cell"/>
                        </xsl:when>
                        <xsl:when test="count($cell) eq 1">
                            <xsl:attribute name="lang"
                                select="($cell/ancestor-or-self::*/@xml:lang)[last()]"/>
                            <xsl:apply-templates mode="register:cell" select="$cell"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <ul class="data-sequence">
                                <xsl:for-each select="$cell">
                                    <li>
                                        <xsl:attribute name="lang"
                                            select="($cell/ancestor-or-self::*/@xml:lang)[last()]"/>
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

    <xsl:function name="register:is-atomic" as="xs:boolean">
        <xsl:param name="x" as="item()*"/>
        <xsl:try>
            <xsl:sequence select="if ($x[self::node()]) then false() else false()"/>
            <xsl:catch>
                <xsl:sequence select="true()"/>
            </xsl:catch>
        </xsl:try>
    </xsl:function>



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
