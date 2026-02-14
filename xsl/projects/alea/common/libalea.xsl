<?xml version="1.0" encoding="UTF-8"?>
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/common/libalea.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:alea="http://scdh.wwu.de/transform/alea#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs alea"
    version="3.0">

    <xsl:expose component="*" visibility="public" names="*"/>

    <!-- Whether to use line (block-element) counting, or verse (typed) counting. -->
    <xsl:param name="typed-line-numbering" as="xs:boolean" select="true()"/>


    <!-- returns the line or verse number, depending on the value of $typed-line-numbering -->
    <xsl:function name="alea:line-number" as="xs:string">
        <xsl:param name="el" as="node()"/>
        <xsl:choose>
            <xsl:when test="$typed-line-numbering">
                <xsl:value-of select="alea:typed-line-number($el)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="alea:plain-line-number($el)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- returns the verse or paragraph number  -->
    <xsl:function name="alea:typed-line-number" as="xs:string">
        <xsl:param name="el" as="node()"/>
        <!-- suffix is a marker for additional verses or paragraphs in readings.
            It is displayed in the apparatus. -->
        <xsl:variable name="suffix" select="
                if (exists(
                $el/ancestor-or-self::l/parent::rdg |
                $el/self::app/parent::lg
                )) then
                    '+'
                else
                    ''"/>
        <xsl:choose>
            <xsl:when test="$el/ancestor-or-self::head[l]">
                <xsl:value-of select="
                        concat('H', count($el/preceding::head[not(ancestor::rdg)]) + 1,
                        '/V', count($el/preceding::l[not(ancestor::rdg)]) + 1, $suffix)"
                />
            </xsl:when>
            <xsl:when test="$el/ancestor-or-self::head">
                <xsl:value-of
                    select="concat('H', count($el/preceding::head[not(ancestor::rdg)]) + 1, $suffix)"
                />
            </xsl:when>
            <xsl:when test="$el/ancestor-or-self::p[parent::div and preceding-sibling::head]">
                <xsl:value-of
                    select="concat('P', count($el/preceding::head[not(ancestor::rdg)]), '.', count($el/ancestor-or-self::p/preceding-sibling::p) + 1, $suffix)"
                />
            </xsl:when>
            <xsl:when test="$el/ancestor-or-self::l">
                <xsl:variable name="inc" select="
                        if ($el/ancestor-or-self::l/ancestor::rdg) then
                            0
                        else
                            1" as="xs:integer"/>
                <xsl:value-of
                    select="concat('V', count($el/preceding::l[not(ancestor::rdg)]) + $inc, $suffix)"
                />
            </xsl:when>
            <xsl:when test="$el/self::app/parent::lg">
                <xsl:value-of
                    select="concat('V', count($el/preceding::l[not(ancestor::rdg)]), $suffix)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('?', $suffix)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- returns the line number of a given element as string -->
    <xsl:function name="alea:plain-line-number" as="xs:string">
        <xsl:param name="el" as="element()"/>
        <xsl:variable name="suffix" select="
                if (exists($el/ancestor::rdg)) then
                    '+'
                else
                    ''"/>
        <xsl:value-of select="
                concat(count($el/preceding::l[not(parent::head) and not(ancestor::rdg)] union
                $el/preceding::head[not(ancestor::rdg)] union
                $el/preceding::p[not(ancestor::rdg)])
                + 1, $suffix)"/>
    </xsl:function>

</xsl:package>
