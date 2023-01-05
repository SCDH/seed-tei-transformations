<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT package of the ALEA preview: metadata -->
<!DOCTYPE stylesheet [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
]>
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/libmeta.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:wit="http://scdh.wwu.de/transform/wit#"
    xmlns:meta="http://scdh.wwu.de/transform/meta#" exclude-result-prefixes="#all"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0" default-mode="meta:data">

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libwit.xsl"
        package-version="1.0.0">
        <xsl:accept component="function" names="wit:sigla-for-ids#1" visibility="private"/>
        <xsl:accept component="variable" names="wit:witnesses" visibility="abstract"/>
    </xsl:use-package>


    <xsl:variable name="work-id-xpath" as="xs:string" visibility="public">
        <xsl:text>(/*/@xml:id, //idno[@type eq 'canonical-id'], //idno[@type eq 'work-identifier'], tokenize(tokenize(base-uri(/), '/')[last()], '\.')[1])[1]</xsl:text>
    </xsl:variable>

    <xsl:mode name="meta:data" on-no-match="shallow-skip" visibility="public"/>

    <xsl:template match="/ | TEI | teiHeader" mode="meta:data">
        <xsl:variable name="work-id" as="xs:string">
            <!-- we evaluate the XPath again in the context of the current item.
                This is required for composition in preview-recension.xsl -->
            <xsl:evaluate as="xs:string" context-item="." xpath="$work-id-xpath" expand-text="true"
            />
        </xsl:variable>
        <p>
            <xsl:value-of select="$work-id"/>
            <xsl:text>: </xsl:text>
            <xsl:apply-templates select="descendant-or-self::teiHeader/descendant::witness"
                mode="meta:data"/>
        </p>
    </xsl:template>

    <xsl:template match="witness" mode="meta:data">
        <span>
            <!--xsl:value-of select="@xml:id"/-->
            <xsl:text>&lre;</xsl:text>
            <span class="siglum">
                <xsl:value-of select="wit:sigla-for-ids(@xml:id)"/>
            </span>
            <xsl:text>&pdf;: </xsl:text>
            <xsl:value-of select="replace(@n, '^[a-zA-Z]+', '')"/>
        </span>
        <xsl:if test="position() ne last()">
            <span>; </span>
        </xsl:if>
    </xsl:template>

    <xsl:template match="text()" mode="meta:data">
        <xsl:value-of select="."/>
    </xsl:template>

</xsl:package>
