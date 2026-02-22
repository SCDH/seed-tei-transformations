<?xml version="1.0" encoding="UTF-8"?>
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libcommon.xsl"
    package-version="0.1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:common="http://scdh.wwu.de/transform/common#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs common"
    version="3.0">

    <xsl:expose component="*" visibility="public" names="*"/>

    <!-- local names of block elements, separated by comma -->
    <xsl:param name="common:block-elements-csv" as="xs:string"
        select="'p,ab,l,lg,div,div1,div2,div3,div4,div5,div6,div7'"/>

    <!-- sequence of local names of block elements -->
    <xsl:param name="common:block-elements" as="xs:string*"
        select="tokenize($common:block-elements-csv, ',') ! normalize-space(.)"/>

    <!-- returns the line or verse number -->
    <xsl:function name="common:line-number" as="xs:string">
        <xsl:param name="el" as="node()"/>
        <xsl:choose>
            <xsl:when test="$el[ancestor-or-self::l[@n]]">
                <xsl:value-of select="$el/ancestor-or-self::l/@n"/>
            </xsl:when>
            <xsl:when test="$el/self::lb[not(@n)]">
                <xsl:text>?</xsl:text>
            </xsl:when>
            <xsl:when test="$el/self::lb[@n]">
                <xsl:value-of select="$el/@n"/>
            </xsl:when>
            <xsl:when test="$el/preceding::lb[1][@n]">
                <xsl:value-of select="$el/preceding::lb[1]/@n"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>?</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
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

    <!-- predicate for testing if the context node has siblings that contribute text -->
    <xsl:function name="common:has-text-siblings" as="xs:boolean" visibility="final">
        <xsl:param name="context" as="element()"/>
        <xsl:sequence
            select="($context/parent::*/node() except $context) ! normalize-space(.) => string-join() ne ''"
        />
    </xsl:function>

    <!-- predivate for testing if the context node is a block element -->
    <xsl:function name="common:is-block" as="xs:boolean" visibility="final">
        <xsl:param name="context" as="element()"/>
        <xsl:sequence select="local-name($context) = $common:block-elements"/>
    </xsl:function>

</xsl:package>
