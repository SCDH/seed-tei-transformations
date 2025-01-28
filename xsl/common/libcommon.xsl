<?xml version="1.0" encoding="UTF-8"?>
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libcommon.xsl"
    package-version="0.1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:common="http://scdh.wwu.de/transform/common#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs common"
    version="3.0">

    <xsl:expose component="*" visibility="public" names="*"/>

    <!-- Whether to use line (block-element) counting, or verse (typed) counting. -->
    <xsl:param name="typed-line-numbering" as="xs:boolean" select="true()"/>

    <!-- returns the line or verse number, depending on the value of $typed-line-numbering -->
    <xsl:function name="common:line-number" as="xs:string">
        <xsl:param name="el" as="node()"/>
        <xsl:choose>
            <xsl:when test="$typed-line-numbering">
                <xsl:value-of select="common:typed-line-number($el)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="common:plain-line-number($el)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- returns the verse or paragraph number  -->
    <xsl:function name="common:typed-line-number" as="xs:string">
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
    <xsl:function name="common:plain-line-number" as="xs:string">
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

    <!-- returns the number of the editorial note in context -->
    <xsl:function name="common:note-number" as="xs:string">
        <xsl:param name="context" as="element()"/>
        <xsl:value-of select="string(count($context/preceding-sibling::note) + 1)"/>
    </xsl:function>

    <!-- shorten a string of N words to w1 … wN, but returned it as is when N<=3
        USAGE: see preview.xsl -->
    <xsl:function name="common:shorten-string" as="xs:normalizedString">
        <xsl:param name="nodes" as="node()*"/>
        <xsl:variable name="lemma-text"
            select="tokenize(normalize-space(string-join($nodes, '')), '\s+')"/>
        <xsl:value-of select="
                if (count($lemma-text) gt 3)
                then
                    (concat($lemma-text[1], ' … ', $lemma-text[last()]))
                else
                    string-join($lemma-text, ' ')"/>
    </xsl:function>

    <xsl:function name="common:left-fill" as="xs:string" visibility="final">
        <xsl:param name="s" as="xs:string"/>
        <xsl:param name="filling-char" as="xs:string"/>
        <xsl:param name="size" as="xs:integer"/>
        <xsl:variable name="filled" as="xs:string*">
            <xsl:for-each select="0 to $size">
                <xsl:value-of select="$filling-char"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="composed" as="xs:string" select="concat(string-join(($filled)), $s)"/>
        <xsl:variable name="length" as="xs:integer" select="string-length($composed)"/>
        <xsl:sequence select="substring($composed, $length - $size, $length)"/>
    </xsl:function>

</xsl:package>
