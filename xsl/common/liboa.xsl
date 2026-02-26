<?xml version="1.0" encoding="UTF-8"?>
<!-- components for web annotations and annotation containers

See specs:
https://www.w3.org/TR/annotation-model/
https://www.w3.org/TR/annotation-protocol/#annotation-containers

Templates or functions? Just as required for building JSON-LD data structures.
-->
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/liboa.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://scdh.wwu.de/transform/i18n#"
    xmlns:oa="http://scdh.wwu.de/transform/oa#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    version="3.0">

    <xsl:output method="html" indent="false"/>

    <xsl:variable name="oa:context" as="xs:string" select="'http://www.w3.org/ns/anno.jsonld'"
        visibility="final"/>

    <xsl:variable name="oa:ldp-context" as="xs:string" select="'http://www.w3.org/ns/ldp.jsonld'"
        visibility="final"/>

    <xsl:template name="oa:annotation" as="map(xs:string, item()*)" visibility="final">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="body" as="item()"/>
        <xsl:param name="target" as="item()"/>
        <xsl:param name="context" as="xs:string?" select="$oa:context" required="false"/>
        <xsl:param name="type" as="xs:string" select="'Annotation'" required="false"/>
        <xsl:map>
            <xsl:if test="exists($context)">
                <xsl:map-entry key="'@context'" select="$context"/>
            </xsl:if>
            <xsl:map-entry key="'id'" select="$id"/>
            <xsl:map-entry key="'type'" select="$type"/>
            <xsl:map-entry key="'body'" select="$body"/>
            <xsl:map-entry key="'target'" select="$target"/>
        </xsl:map>
    </xsl:template>

    <xsl:template name="oa:textual-body" as="map(xs:string, item()*)" visibility="final">
        <xsl:param name="value" as="xs:string"/>
        <xsl:param name="format" as="xs:string"/>
        <xsl:param name="language" as="xs:string"/>
        <xsl:map>
            <xsl:map-entry key="'type'">TextualBody</xsl:map-entry>
            <xsl:map-entry key="'value'" select="$value"/>
            <xsl:map-entry key="'format'" select="$format"/>
            <xsl:map-entry key="'language'" select="$language"/>
        </xsl:map>
    </xsl:template>

    <xsl:function name="oa:target-samedoc-css" as="map(xs:string, item())" visibility="final">
        <xsl:param name="class"/>
        <xsl:map>
            <xsl:map-entry key="'type'">SpecificResource</xsl:map-entry>
            <xsl:map-entry key="'source'">.</xsl:map-entry>
            <xsl:map-entry key="'selector'">
                <xsl:map>
                    <xsl:map-entry key="'type'">CssSelector</xsl:map-entry>
                    <xsl:map-entry key="'selector'" select="'.' || $class"/>
                </xsl:map>
            </xsl:map-entry>
        </xsl:map>
    </xsl:function>

    <xsl:template name="oa:container" as="map(xs:string, item())" visibility="final">
        <xsl:param name="annotations" as="map(xs:string, item()*)*"/>
        <xsl:param name="container-id" as="xs:string"/>
        <xsl:param name="page-id" as="xs:string"
            select="$container-id => replace('container', 'page0')" required="false"/>
        <xsl:param name="container-type" as="xs:string*" select="()" required="false"/>
        <xsl:param name="label" as="xs:string" select="'A container for web annotations'"/>
        <xsl:param name="additional-contexts" as="xs:string*" select="()" required="false"/>
        <xsl:map>
            <xsl:map-entry key="'@context'"
                select="array { $oa:context, $oa:ldp-context, $additional-contexts }"/>
            <xsl:map-entry key="'id'" select="$container-id"/>
            <xsl:map-entry key="'type'"
                select="array { 'BasicContainer', 'AnnotationCollection', $container-type }"/>
            <xsl:map-entry key="'total'" select="count($annotations)"/>
            <xsl:map-entry key="'modified'" select="current-dateTime()"/>
            <xsl:map-entry key="'label'" select="$label"/>
            <xsl:map-entry key="'first'">
                <xsl:map>
                    <xsl:map-entry key="'id'" select="$page-id"/>
                    <xsl:map-entry key="'type'">AnnotationPage</xsl:map-entry>
                    <xsl:map-entry key="'next'" select="()"/>
                    <xsl:map-entry key="'items'" select="array { $annotations}"/>
                </xsl:map>
            </xsl:map-entry>
            <xsl:map-entry key="'last'" select="$page-id"/>
        </xsl:map>
    </xsl:template>

</xsl:package>
