<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT package with components for using reledmac for critical editions -->
<!DOCTYPE package [
    <!ENTITY lb "&#xa;" >
]>
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libreledmac.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:edmac="http://scdh.wwu.de/transform/edmac#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    version="3.0">

    <!-- reledmac for line numbering -->

    <!-- optional parameter passed to every \pstart. E.g. '[\setRL]' -->
    <xsl:param name="edmac:pstart-opt" as="xs:string" select="''"/>

    <!-- used to add \pstart in context of a block element like p or l -->
    <xsl:template name="edmac:par-start" visibility="public">
        <xsl:variable name="predicate" as="xs:boolean">
            <xsl:apply-templates mode="edmac:par-pstart" select="."/>
        </xsl:variable>
        <xsl:if test="$predicate">
            <xsl:text>&lb;\pstart</xsl:text>
            <xsl:value-of select="$edmac:pstart-opt"/>
            <xsl:text>{} </xsl:text>
            <!-- to end macro, instead of {} -->
        </xsl:if>
    </xsl:template>

    <!-- used to add \pend in context of a block element like p or l -->
    <xsl:template name="edmac:par-end" visibility="public">
        <xsl:variable name="predicate" as="xs:boolean">
            <xsl:apply-templates mode="edmac:par-pend" select="."/>
        </xsl:variable>
        <xsl:if test="not(following-sibling::*[1][self::app[@from]])">
            <xsl:text>&lb;\pend</xsl:text>
        </xsl:if>
    </xsl:template>


    <!-- used to add \pstart in case, where the apparatus entry begins outside of a block element like p or l -->
    <xsl:template name="edmac:app-start" visibility="public">
        <xsl:variable name="predicate" as="xs:boolean">
            <xsl:apply-templates mode="edmac:app-pstart" select="."/>
        </xsl:variable>
        <xsl:if test="$predicate">
            <xsl:text>&lb;\pstart</xsl:text>
            <xsl:value-of select="$edmac:pstart-opt"/>
            <xsl:text>{} </xsl:text>
            <!-- to end macro, instead of {} -->
        </xsl:if>
    </xsl:template>

    <!-- used to add \pend in case, where the apparatus entry ends outside of a block element like p or l -->
    <xsl:template name="edmac:app-end" visibility="public">
        <xsl:variable name="predicate" as="xs:boolean">
            <xsl:apply-templates mode="edmac:app-pstart" select="."/>
        </xsl:variable>
        <xsl:if test="$predicate">
            <xsl:text>&lb;\pend</xsl:text>
        </xsl:if>
    </xsl:template>

    <!-- Rules for deciding if text blocks like p and l get a \pstart and \pend.
        Elements outside text blocks may need these macros.
        Templates in theses modes must return a boolean value. -->
    <xsl:mode name="edmac:par-pstart" on-no-match="fail"/>
    <xsl:mode name="edmac:par-pend" on-no-match="fail"/>

    <xsl:template mode="edmac:par-pstart edmac:par-pend" match="*[ancestor::app]">
        <xsl:sequence select="false()"/>
    </xsl:template>

    <!-- no \pend when an app emmidiatly follows that has its end point before -->
    <xsl:template mode="edmac:par-pend" match="*[following-sibling::*[1][self::app[@from]]]">
        <xsl:sequence select="false()"/>
    </xsl:template>

    <!-- default rule: output \pstart or \pend -->
    <xsl:template mode="edmac:par-pstart edmac:par-pend" match="*">
        <xsl:sequence select="true()"/>
    </xsl:template>


    <!-- Rules for deciding if apparatus elements get a \pstart and \pend.
        Elements outside text blocks may need these macros.
        Templates in theses modes must return a boolean value. -->
    <xsl:mode name="edmac:app-pstart" on-no-match="fail"/>
    <xsl:mode name="edmac:app-pend" on-no-match="fail"/>

    <!-- app from double-end-point behind paragraph does not get a \pstart -->
    <xsl:template mode="edmac:app-pstart" match="app[not(ancestor::p or ancestor::l)
                   and //variantEncoding[@method eq 'double-end-point' and @location eq 'inline']
                   and @from]">
        <xsl:sequence select="false()"/>
    </xsl:template>

    <!-- app from double-end-point before paragraph does not get a \pend -->
    <xsl:template mode="edmac:app-pend" match="app[not(ancestor::p or ancestor::l)
        and //variantEncoding[@method eq 'double-end-point' and @location eq 'inline']
        and @to]">
        <xsl:sequence select="false()"/>
    </xsl:template>

    <!-- apparatus elements outside a paragraph or other text block get a \pstart and \pend,
        if no other more special rule matches -->
    <xsl:template mode="edmac:app-pstart edmac:app-pend" match="*[not(ancestor::p or ancestor::l)]">
        <xsl:sequence select="true()"/>
    </xsl:template>

    <!-- default rule: no \pstart and \pend -->
    <xsl:template mode="edmac:app-pstart edmac:app-pend" match="*">
        <xsl:sequence select="false()"/>
    </xsl:template>



    <!-- make a edlabel macro -->
    <xsl:template name="edmac:edlabel" visibility="public">
        <xsl:param name="context" as="node()" select="." required="false"/>
        <xsl:param name="suffix" as="xs:string" select="''" required="false"/>
        <xsl:text>\edlabel{</xsl:text>
        <xsl:choose>
            <xsl:when test="$context/@xml:id">
                <xsl:value-of select="$context/@xml:id"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat(generate-id($context), $suffix)"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>}</xsl:text>
    </xsl:template>





    <!-- modes for generating IDs used as labels in reledmac -->

    <xsl:mode name="edmac:edlabel-start" on-no-match="shallow-skip" visibility="public"/>
    <xsl:mode name="edmac:edlabel-end" on-no-match="shallow-skip" visibility="public"/>

    <xsl:template mode="edmac:edlabel-start"
        match="app[//variantEncoding/@method eq 'parallel-segmentation']">
        <xsl:value-of select="concat(generate-id(), '-start')"/>
    </xsl:template>

    <xsl:template mode="edmac:edlabel-end"
        match="app[//variantEncoding/@method eq 'parallel-segmentation']">
        <xsl:value-of select="concat(generate-id(), '-end')"/>
    </xsl:template>

    <xsl:template mode="edmac:edlabel-start"
        match="app[//variantEncoding/@method ne 'parallel-segmentation' and @from]">
        <xsl:message>
            <xsl:text>start edlabel </xsl:text>
            <xsl:value-of select="@from"/>
        </xsl:message>
        <xsl:value-of select="substring(@from, 2)"/>
    </xsl:template>

    <xsl:template mode="edmac:edlabel-end"
        match="app[//variantEncoding/@method ne 'parallel-segmentation']">
        <xsl:value-of select="generate-id()"/>
    </xsl:template>

    <xsl:template mode="edmac:edlabel-start" match="corr">
        <xsl:value-of select="concat(generate-id(), '-start')"/>
    </xsl:template>

    <xsl:template mode="edmac:edlabel-end" match="corr">
        <xsl:value-of select="concat(generate-id(), '-end')"/>
    </xsl:template>


    <xsl:template mode="edmac:edlabel-start edmac:edlabel-end" match="note[not(@fromTarget)]">
        <xsl:value-of select="generate-id(parent::*)"/>
    </xsl:template>

    <xsl:template mode="edmac:edlabel-start" match="note[@fromTarget]">
        <xsl:choose>
            <xsl:when test="@xml:id">
                <xsl:value-of select="@xml:id"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="generate-id()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="edmac:edlabel-end" match="note[@fromTarget]">
        <xsl:value-of select="substring(@fromTarget, 2)"/>
    </xsl:template>

    <xsl:template mode="edmac:edlabel-start" match="*">
        <xsl:message terminate="yes">
            <xsl:text>ERROR: no rule for making start edlabel for </xsl:text>
            <xsl:value-of select="name(.)"/>
            <xsl:text> in </xsl:text>
            <xsl:value-of select="//variantEncoding/@method"/>
        </xsl:message>
    </xsl:template>

    <xsl:template mode="edmac:edlabel-end" match="*">
        <xsl:message terminate="yes">
            <xsl:text>ERROR: no rule for making end edlabel for </xsl:text>
            <xsl:value-of select="name(.)"/>
            <xsl:text> in </xsl:text>
            <xsl:value-of select="//variantEncoding/@method"/>
        </xsl:message>
    </xsl:template>


    <!-- count of reledmac series. Per default, reledmac makes 5 series. -->
    <xsl:variable name="edmac:count-of-series" select="5"/>

    <!-- make a reledmac macro name like 'Afootnote' or 'footnoteA' for an entry.
        This will make Xfootnote for an entry with 1 <= entry.type <= $edmac:count-of-series
        and footnoteX for $edmac:count-of-series < entry.type <= 2*edmac:count-of-series.
        entry.type must be between 1 through 2*edmac:count-of-series.
    -->
    <xsl:function name="edmac:footnote-macro" as="xs:string" visibility="public">
        <xsl:param name="entry" as="map(xs:string, item()*)"/>
        <xsl:variable name="series" as="xs:integer" select="map:get($entry,'type') - 1"/>
        <xsl:choose>
            <xsl:when test="$series lt 0 or $series gt 2*$edmac:count-of-series - 1">
                <xsl:message terminate="yes">
                    <xsl:text>ERROR: Invalid type/series of apparatus or notes entry: </xsl:text>
                    <xsl:value-of select="$series"/>
                </xsl:message>
            </xsl:when>
            <xsl:when test="$series lt $edmac:count-of-series">
                <xsl:value-of select="concat(codepoints-to-string(65 + $series), 'footnote')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="concat('footnote', codepoints-to-string(65 + $series mod $edmac:count-of-series))"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:package>
