<?xml version="1.0" encoding="UTF-8"?>
<!-- HTML preview for a poem from diwan, that contains multiple recensions.

This is simply a composition of extract-recension.xsl and diwan.xsl.
-->
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/html/diwan-recension.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:recension="http://scdh.wwu.de/transform/recension#"
    xmlns:app="http://scdh.wwu.de/transform/app#" exclude-result-prefixes="#all"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.1">

    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <xsl:global-context-item as="document-node()" use="required"/>

    <!-- store the single recension for performance reasons -->
    <xsl:variable name="single-recension" as="document-node()">
        <xsl:document validation="preserve">
            <xsl:apply-templates mode="recension:extract" select="/"/>
        </xsl:document>
    </xsl:variable>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/tei/extract-recension.xsl"
        package-version="1.0.0">
        <xsl:override>
            <!-- During composition, the base URI of nodes is the base URI of the xsl:variable element
                and the base URI of the source document becomes inaccessible.
                That's why we set @xml:base of the TEI element.
                Cf. https://www.w3.org/TR/xslt-30/#temporary-trees
                This even works in combination with Base fixup for xi:include (tested).
            -->
            <xsl:template name="recension:root-hook">
                <xsl:context-item as="element()" use="required"/>
                <xsl:attribute name="xml:base" select="document-uri(/)"/>
            </xsl:template>
        </xsl:override>
    </xsl:use-package>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/html/diwan.xsl"
        package-version="1.0.0">
        <xsl:override>
            <!-- we have to override some components since missing context item in virtual tree after composition -->
            <xsl:variable name="apparatus-entries" as="map(*)*" visibility="public"
                select="app:apparatus-entries($single-recension)"/>
            <xsl:variable name="editorial-notes" as="map(*)*" visibility="public"
                select="app:apparatus-entries($single-recension, 'descendant-or-self::note[ancestor::text]', 2)"/>
            <xsl:variable name="witnesses" as="element()*">
                <xsl:choose>
                    <xsl:when test="empty($wit-catalog) or not(doc-available($wit-catalog))">
                        <xsl:message use-when="system-property('debug') eq 'true'">
                            <xsl:text>no witness catalog</xsl:text>
                        </xsl:message>
                        <xsl:sequence>
                            <xsl:try select="$single-recension//sourceDesc//witness[@xml:id]">
                                <xsl:catch errors="*" select="()"/>
                            </xsl:try>
                        </xsl:sequence>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- a sequence from external and local witnesses -->
                        <xsl:sequence>
                            <xsl:try select="(doc($wit-catalog)/descendant::witness[@xml:id],
                                $single-recension//sourceDesc//witness[@xml:id])">
                                <xsl:catch errors="*"
                                    select="doc($wit-catalog)/descendant::witness[@xml:id]"/>
                            </xsl:try>
                        </xsl:sequence>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="language" as="xs:string">
                <xsl:try select="/*/@xml:lang">
                    <xsl:catch errors="*" select="'ar'"/>
                </xsl:try>
            </xsl:variable>
        </xsl:override>
    </xsl:use-package>


    <xsl:mode on-no-match="shallow-skip"/>

    <xsl:template match="/">
        <!-- We do a composition of extract-recension and preview: -->
        <xsl:apply-templates mode="preview" select="$single-recension"/>
    </xsl:template>

</xsl:package>
