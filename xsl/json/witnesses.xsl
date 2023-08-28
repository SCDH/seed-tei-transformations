<?xml version="1.0" encoding="UTF-8"?>
<!-- get the text witnesses from a TEI document, output in JSON format -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/2005/xpath-functions"
    xmlns:wit="http://scdh.wwu.de/transform/wit#"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" expand-text="yes"
    exclude-result-prefixes="#all" version="3.0">

    <xsl:output method="json" indent="false"/>

    <!-- whether to flatten or to keep the nested structure of <listWit> elements -->
    <xsl:param name="wit:flatten" as="xs:boolean" select="true()"/>

    <!-- optional: the URI of the projects central witness catalogue -->
    <xsl:param name="wit:catalog" as="xs:string" select="string()"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libwit.xsl"
        package-version="1.0.0">
        <xsl:override>
            <xsl:variable name="wit:witnesses" as="element()*">
                <xsl:choose>
                    <xsl:when test="$wit:catalog eq string()">
                        <xsl:sequence select="//sourceDesc//witness[@xml:id]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- a sequence from external and local witnesses -->
                        <xsl:sequence select="
                                (doc($wit:catalog)/descendant::witness[@xml:id],
                                //sourceDesc//witness[@xml:id])"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
        </xsl:override>
        <xsl:accept component="function" names="wit:*" visibility="public"/>
    </xsl:use-package>


    <xsl:template match="/" as="map(xs:string,map(*)*)">
        <xsl:map>
            <xsl:apply-templates
                select="descendant::sourceDesc/(descendant::listWit[not(ancestor::listWit)] | descendant::witness[not(ancestor::listWit)])"
            />
        </xsl:map>
    </xsl:template>

    <xsl:mode on-no-match="shallow-skip"/>

    <!-- if a listWit does not have an ID the structure is flattened -->
    <xsl:template match="listWit[not(@xml:id) or $wit:flatten]" as="map(*)*">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="listWit[@xml:id and not($wit:flatten)]" as="map(xs:string,map(*))*">
        <xsl:map-entry key="string(@xml:id)">
            <xsl:map>
                <xsl:map-entry key="'type'" select="'list'"/>
                <xsl:map-entry key="'descendants'">
                    <xsl:map>
                        <xsl:apply-templates/>
                    </xsl:map>
                </xsl:map-entry>
            </xsl:map>
        </xsl:map-entry>
    </xsl:template>

    <xsl:template match="witness[@xml:id]" as="map(xs:string,item()*)">
        <xsl:map-entry key="string(@xml:id)">
            <xsl:map>
                <xsl:map-entry key="'type'" select="'witness'"/>
                <xsl:map-entry key="'siglum'" select="string-join(wit:sigla-for-ids(@xml:id), ', ')"/>
                <xsl:map-entry key="'description'"
                    select="string-join(wit:descriptions-for-ids(@xml:id), ' | ')"/>
                <xsl:map-entry key="'list'" select="array {ancestor::listWit/@xml:id ! string()}"/>
            </xsl:map>
        </xsl:map-entry>
    </xsl:template>

</xsl:stylesheet>
