<?xml version="1.0" encoding="UTF-8"?>
<!-- a stylesheet defining keys which cannot be exported in a package

USAGE:
<xsl:import href="../common/likkeys.xsl"/>

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:keys="http://scdh.wwu.de/transform/keys#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs keys"
    version="3.0">

    <!-- alternants: alternative text -->

    <!-- a key from all <alt mode="excl" target="..."/> -->
    <xsl:key name="alt-excl" match="//alt[@mode eq 'excl']"
        use="tokenize(@target) ! substring(., 2)"/>

    <!-- a key for keeping track of all alternants in document order -->
    <xsl:key name="alternants" match="//*[@type eq 'alternative']" use="@type"/>

    <!--
        a key telling if an alternant is the first one of a set or not

        In the following example, <seg> has the true value
        and <add> has the false value

        <seg xml:id="op1" type="alternative">text</seg>
        <add xml:id="op2" type="alternative" place="above">text</add>
        <alt target="#op1 #op2" mode="excl"/>

    -->
    <xsl:key name="first-alternant" match="//*[@type eq 'alternative']"
        use="keys:is-first-alternative(.) => string()"/>

    <xsl:function name="keys:is-first-alternative" as="xs:boolean" visibility="private">
        <xsl:param name="context" as="element()"/>
        <xsl:variable name="id" as="xs:string" select="$context/@xml:id => string()"/>
        <xsl:variable name="alternants-at-context" as="xs:string*"
            select="$context/key('alt-excl', $id)/@target ! tokenize(.) ! substring(., 2)"/>
        <xsl:variable name="alternants-in-order"
            select="($context/key('alternants', $context/@type)[string(@xml:id) = $alternants-at-context])/@xml:id ! string()"/>
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>testing if is first alternative </xsl:text>
            <xsl:value-of select="$id"/>
            <xsl:text> amongst alternatives </xsl:text>
            <xsl:value-of select="$alternants-at-context"/>
            <xsl:text> in ordered set </xsl:text>
            <xsl:value-of select="$alternants-in-order"/>
        </xsl:message>
        <xsl:sequence select="$alternants-in-order[1] eq $id"/>
    </xsl:function>

</xsl:stylesheet>
