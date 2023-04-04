<?xml version="1.0" encoding="UTF-8"?>
<!--  -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:app="http://scdh.wwu.de/transform/app#"
    xmlns:seed="http://scdh.wwu.de/transform/seed#" xmlns:text="http://scdh.wwu.de/transform/text#"
    xmlns:common="http://scdh.wwu.de/transform/common#"
    xmlns:meta="http://scdh.wwu.de/transform/meta#" xmlns:wit="http://scdh.wwu.de/transform/wit#"
    xmlns:obt="http://scdh.wwu.de/oxbytei" exclude-result-prefixes="#all"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0" default-mode="preview">

    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <!-- A sequence of IDs of annotations to be transformed.
        If this is the empty sequence, all annotations are transformed. -->
    <xsl:param name="pages" as="xs:string*">
        <xsl:message>
            <xsl:text>obt:current-node() available? </xsl:text>
            <xsl:value-of select="function-available('obt:current-node')"/>
        </xsl:message>
        <xsl:message use-when="function-available('obt:current-node')">
            <xsl:variable name="current-node" select="obt:current-node(base-uri())"/>
            <xsl:choose>
                <xsl:when test="$current-node[text()]">
                    <xsl:text>current text node: </xsl:text>
                    <xsl:value-of select="$current-node"/>
                </xsl:when>
                <xsl:when test="$current-node[element()]">
                    <xsl:text>current element: </xsl:text>
                    <xsl:value-of select="name($current-node)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>other node</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:message>
        <xsl:sequence use-when="function-available('obt:current-node')"
            select="obt:current-node(base-uri())/preceding::pb[1]/@n"> </xsl:sequence>
        <xsl:sequence use-when="not(function-available('obt:current-node'))" select="()"/>
    </xsl:param>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/abstract-preview.xsl"
        package-version="1.0.0">

        <xsl:accept component="function" names="seed:subtrees-between-anchors#2" visibility="public"/>
        <xsl:accept component="function" names="app:note-based-apparatus-nodes-map#2"
            visibility="public"/>
        <xsl:accept component="variable" names="apparatus-entries" visibility="public"/>
        <xsl:accept component="mode" names="preview" visibility="public"/>
        <xsl:accept component="mode" names="text:text" visibility="public"/>

        <xsl:override>
            <xsl:variable name="current" as="node()*">
                <xsl:variable name="root" select="/"/>
                <xsl:choose>
                    <!-- When there's a page number or several page numbers,
                            then this take the nodes between the pb with the page number and the next pb. -->
                    <xsl:when test="not(empty($pages))">
                        <xsl:for-each select="$pages">
                            <xsl:variable name="page-number" as="xs:string" select="."/>
                            <xsl:variable name="pb" as="node()"
                                select="$root//pb[@n eq $page-number]"/>
                            <xsl:variable name="next-pb" as="node()*" select="$pb/following::pb[1]"/>
                            <xsl:sequence select="$pb, seed:subtrees-between-anchors($pb, $next-pb)"
                            />
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- otherwise transform the whole document -->
                        <xsl:sequence select="root()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
        </xsl:override>

    </xsl:use-package>


    <!-- this transformation formats the main text with the libprose package -->
    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libprose.xsl"
        package-version="1.0.0">

        <xsl:accept component="mode" names="*" visibility="public"/>

        <xsl:override>
            <xsl:variable name="text:apparatus-entries" as="map(xs:string, map(*))"
                select="app:note-based-apparatus-nodes-map($apparatus-entries, true())"/>
        </xsl:override>

    </xsl:use-package>


</xsl:stylesheet>
