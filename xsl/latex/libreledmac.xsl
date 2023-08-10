<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT package with components for using reledmac for critical editions -->
<!DOCTYPE package [
    <!ENTITY lb "&#xa;" >
    <!ENTITY cr "&#xd;" >
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

    <xsl:expose component="mode" names="edmac:*" visibility="public"/>
    <xsl:expose component="template" names="edmac:*" visibility="public"/>

    <!-- how to normalize generated latex of block elements like verses and paragraphs. VALUES: empty string, 'space' -->
    <xsl:param name="edmac:normalization" as="xs:string" select="''" required="false"/>

    <!-- optional parameter passed to every \pstart. E.g. '[\setRL]' -->
    <xsl:param name="edmac:pstart-opt" as="xs:string" select="''"/>

    <!-- The templates named edmac:*-(start|end)-macro are used to make \pstart
        and \pend etc. homogenously in various places.
        Do not use them directly, but use edmac:(par|stanza)-(start|end) which
        add some evaluation of the context.
        But, OVERRIDE these macros to adapt how \pstart etc. is done in your
        project.
        A comment can be passed in as argument which will be inserted after %,
        which may be instructive for debugging.
    -->

    <xsl:template name="edmac:par-start-macro" visibility="public">
        <xsl:param name="comment" as="xs:string" select="''" required="false"/>
        <xsl:text>&lb;\pstart</xsl:text>
        <xsl:value-of select="$edmac:pstart-opt"/>
        <!-- to end macro, instead of {} -->
        <xsl:text>{}%</xsl:text>
        <xsl:value-of select="$comment"/>
        <xsl:text>&lb;</xsl:text>
    </xsl:template>

    <xsl:template name="edmac:par-end-macro">
        <xsl:param name="comment" as="xs:string" select="''" required="false"/>
        <xsl:text>&lb;\pend %</xsl:text>
        <xsl:value-of select="$comment"/>
        <xsl:text>&lb;&lb;&lb;</xsl:text>
    </xsl:template>

    <xsl:template name="edmac:stanza-start-macro">
        <xsl:param name="comment" as="xs:string" select="''" required="false"/>
        <xsl:text>&lb;\stanza\relax %</xsl:text>
        <xsl:value-of select="$comment"/>
        <xsl:text>&lb;</xsl:text>
    </xsl:template>

    <xsl:template name="edmac:stanza-end-macro">
        <xsl:param name="comment" as="xs:string" select="''" required="false"/>
        <!-- in reledmac, a stanza is ended by \& -->
        <xsl:text>\&amp;%</xsl:text>
        <xsl:value-of select="$comment"/>
        <xsl:text>&lb;&lb;&lb;</xsl:text>
    </xsl:template>



    <!-- The templates named edmac:par-(start|end) evaluate the context and make
        \pstart and \pend if they are not to be suppressed because of
        wrapping apparatus elements or the like. These templates are used a lot in
        libtext.xsl.
    -->

    <!-- used to add \pstart in context of a block element like p or l -->
    <xsl:template name="edmac:par-start" visibility="public">
        <xsl:context-item as="element()" use="required"/>
        <xsl:variable name="predicate" as="xs:boolean">
            <xsl:apply-templates mode="edmac:par-pstart" select="."/>
        </xsl:variable>
        <xsl:if test="$predicate">
            <xsl:call-template name="edmac:par-start-macro"/>
        </xsl:if>
    </xsl:template>

    <!-- used to add \pend in context of a block element like p or l -->
    <xsl:template name="edmac:par-end" visibility="public">
        <xsl:context-item as="element()" use="required"/>
        <xsl:variable name="predicate" as="xs:boolean">
            <xsl:apply-templates mode="edmac:par-pend" select="."/>
        </xsl:variable>
        <xsl:if test="$predicate">
            <xsl:call-template name="edmac:par-end-macro"/>
        </xsl:if>
    </xsl:template>

    <!-- The templates named edmac:stanza-(start|end) are as edmac:par-(start|end),
        but for verse. -->

    <!-- used to add \pstart in context of a block element like p or l -->
    <xsl:template name="edmac:stanza-start" visibility="public">
        <xsl:context-item as="element()" use="required"/>
        <xsl:variable name="predicate" as="xs:boolean">
            <xsl:apply-templates mode="edmac:par-pstart" select="."/>
        </xsl:variable>
        <xsl:if test="$predicate">
            <xsl:call-template name="edmac:stanza-start-macro"/>
        </xsl:if>
    </xsl:template>

    <!-- used to add \pend in context of a block element like p or l -->
    <xsl:template name="edmac:stanza-end" visibility="public">
        <xsl:context-item as="element()" use="required"/>
        <xsl:variable name="predicate" as="xs:boolean">
            <xsl:apply-templates mode="edmac:par-pend" select="."/>
        </xsl:variable>
        <xsl:if test="$predicate">
            <xsl:call-template name="edmac:stanza-end-macro"/>
        </xsl:if>
    </xsl:template>


    <!-- used to add \pstart in case, where the apparatus entry begins outside of a block element like p or l -->
    <xsl:template name="edmac:app-start" visibility="public">
        <xsl:context-item as="element()" use="required"/>
        <xsl:variable name="predicate" as="xs:boolean">
            <xsl:apply-templates mode="edmac:app-pstart" select="."/>
        </xsl:variable>
        <xsl:if test="$predicate">
            <!-- we have to treat prose different that lyrics, so we use a mode -->
            <xsl:apply-templates mode="edmac:app-pstart-macro" select="."/>
        </xsl:if>
    </xsl:template>

    <!-- used to add \pend in case, where the apparatus entry ends outside of a block element like p or l -->
    <xsl:template name="edmac:app-end" visibility="public">
        <xsl:context-item as="element()" use="required"/>
        <xsl:variable name="predicate" as="xs:boolean">
            <xsl:apply-templates mode="edmac:app-pend" select="."/>
        </xsl:variable>
        <xsl:if test="$predicate">
            <!-- we have to treat prose and lyrics differently, so we use a mode -->
            <xsl:apply-templates mode="edmac:app-pend-macro" select="."/>
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

    <!-- no \pstart if an anchor preceeds immediately that is referenced by a later app -->
    <xsl:template mode="edmac:par-pstart" priority="5"
        match="*[preceding-sibling::*[1][self::anchor and (let $idref:=concat('#', @xml:id) return following::app[@from eq $idref])]]">
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

    <!-- app from double-end-point before paragraph does not get a \pstart -->
    <xsl:template mode="edmac:app-pstart" priority="10"
        match="app[not(ancestor::p or ancestor::head or ancestor::l or ancestor::lg)
                   and //variantEncoding[@method eq 'double-end-point' and @location eq 'internal']
                   and @from]">
        <xsl:sequence select="false()"/>
    </xsl:template>

    <!-- app from double-end-point before paragraph does not get a \pend -->
    <xsl:template mode="edmac:app-pend" priority="10"
        match="app[not(ancestor::p or ancestor::head or ancestor::l or ancestor::lg)
                   and //variantEncoding[@method eq 'double-end-point' and @location eq 'internal']
                   and @to]">
        <xsl:sequence select="false()"/>
    </xsl:template>

    <!-- apparatus elements outside a paragraph or other text block get a \pstart and \pend,
        if no other more special rule matches -->
    <xsl:template mode="edmac:app-pstart edmac:app-pend" priority="2"
        match="*[not(ancestor::p or ancestor::head or ancestor::l or ancestor::lg)]">
        <xsl:sequence select="true()"/>
    </xsl:template>

    <!-- default rule: no \pstart and \pend -->
    <xsl:template mode="edmac:app-pstart edmac:app-pend" match="*">
        <xsl:sequence select="false()"/>
    </xsl:template>


    <!-- modes for choosing the right macro for pstart and pend
        when wrapping apparatus elements. Per default, it is
        \pstart and \pend, but for verse we need \stanza and \&.
    -->
    <xsl:mode name="edmac:app-pstart-macro" on-no-match="fail"/>
    <xsl:mode name="edmac:app-pend-macro" on-no-match="fail"/>

    <!-- defaults to \pstart -->
    <xsl:template mode="edmac:app-pstart-macro" match="*">
        <xsl:call-template name="edmac:par-start-macro">
            <xsl:with-param name="comment" select="concat('preferred from ', name())"/>
        </xsl:call-template>
    </xsl:template>

    <!-- defaults to \pend -->
    <xsl:template mode="edmac:app-pend-macro" match="*">
        <xsl:call-template name="edmac:par-end-macro">
            <xsl:with-param name="comment" select="concat('delayed from ', name())"/>
        </xsl:call-template>
    </xsl:template>

    <!-- verse or stanza, start of stanza,
        for internal double end-point, apparatus element before lemma -->
    <xsl:template mode="edmac:app-pstart-macro"
        match="app[(following-sibling::l|following-sibling::lg)
                   and not(ancestor::lg)
                   and //variantEncoding[@method eq 'double-end-point' and @location eq 'internal']
                   and @to]">
        <xsl:call-template name="edmac:stanza-start-macro">
            <xsl:with-param name="comment" select="concat('preferred from ', name())"/>
        </xsl:call-template>
    </xsl:template>

    <!-- verse or stanza, end of stanza,
        for internal double end-point, apparatus element after lemma -->
    <xsl:template mode="edmac:app-pend-macro"
        match="app[(preceding-sibling::*[1][self::l]|preceding-sibling::*[1][self::lg])
                   and not(ancestor::lg)
                   and //variantEncoding[@method eq 'double-end-point' and @location eq 'internal']
                   and @from]">
        <xsl:call-template name="edmac:stanza-end-macro">
            <xsl:with-param name="comment" select="concat('delayed from ', name())"/>
        </xsl:call-template>
    </xsl:template>

    <!-- anchor and app around l or lg: \stanza as opening for anchor-->
    <xsl:template mode="edmac:app-pstart-macro"
        match="anchor[(following-sibling::*[1][self::l]|following-sibling::*[1][self::lg])
                      and not(ancestor::lg)
                      and //variantEncoding[@method eq 'double-end-point' and @location eq 'internal']
                      and (let $idref:=concat('#', @xml:id) return following::app[@from eq $idref])]">
        <xsl:call-template name="edmac:stanza-start-macro">
            <xsl:with-param name="comment" select="concat('preferred from ', name())"/>
        </xsl:call-template>
    </xsl:template>

    <!-- no \pend output for anchor that preceedes block elements and belongs to a following app -->
    <xsl:template mode="edmac:app-pend-macro"
        match="anchor[(following-sibling::*[1][self::l] | following-sibling::*[1][self::lg] | following-sibling::*[1][self::p] | following-sibling::*[1][self::head])
                      and not(ancestor::lg)
                      and //variantEncoding[@method eq 'double-end-point' and @location eq 'internal']
                      and (let $idref:=concat('#', @xml:id) return following::app[@from eq $idref])]"/>



    <!-- make a edlabel macro -->
    <xsl:template name="edmac:edlabel" visibility="public">
        <xsl:param name="context" as="node()" select="." required="false"/>
        <xsl:param name="suffix" as="xs:string" select="''" required="false"/>
        <xsl:text>\edlabel{</xsl:text>
        <xsl:value-of
            select="concat(if ($context/@xml:id) then $context/@xml:id else generate-id($context), $suffix)"/>
        <xsl:text>}</xsl:text>
    </xsl:template>





    <!-- modes for generating IDs used as labels in reledmac -->

    <xsl:mode name="edmac:edlabel-start" on-no-match="shallow-skip" visibility="public"/>
    <xsl:mode name="edmac:edlabel-end" on-no-match="shallow-skip" visibility="public"/>

    <xsl:template mode="edmac:edlabel-start"
        match="app[//variantEncoding/@method eq 'parallel-segmentation']">
        <xsl:value-of select="concat(if (@xml:id) then @xml:id else generate-id(), '-start')"/>
    </xsl:template>

    <xsl:template mode="edmac:edlabel-end"
        match="app[//variantEncoding/@method eq 'parallel-segmentation']">
        <xsl:value-of select="concat(if (@xml:id) then @xml:id else generate-id(), '-end')"/>
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
        <xsl:value-of select="if (@xml:id) then @xml:id else generate-id()"/>
    </xsl:template>

    <xsl:template mode="edmac:edlabel-start" match="corr">
        <xsl:value-of select="concat(if (@xml:id) then @xml:id else generate-id(), '-start')"/>
    </xsl:template>

    <xsl:template mode="edmac:edlabel-end" match="corr">
        <xsl:value-of select="concat(if (@xml:id) then @xml:id else generate-id(), '-end')"/>
    </xsl:template>

    <xsl:template mode="edmac:edlabel-start" match="sic">
        <xsl:value-of select="concat(if (@xml:id) then @xml:id else generate-id(), '-start')"/>
    </xsl:template>

    <xsl:template mode="edmac:edlabel-end" match="sic">
        <xsl:value-of select="concat(if (@xml:id) then @xml:id else generate-id(), '-end')"/>
    </xsl:template>

    <xsl:template mode="edmac:edlabel-start" match="choice">
        <xsl:value-of select="concat(if (@xml:id) then @xml:id else generate-id(), '-start')"/>
    </xsl:template>

    <xsl:template mode="edmac:edlabel-end" match="choice">
        <xsl:value-of select="concat(if (@xml:id) then @xml:id else generate-id(), '-end')"/>
    </xsl:template>


    <xsl:template mode="edmac:edlabel-start" match="note">
        <xsl:value-of
            select="concat(if (parent::*/@xml:id) then parent::*/@xml:id else generate-id(parent::*), '-start')"
        />
    </xsl:template>

    <xsl:template mode="edmac:edlabel-end" match="note">
        <xsl:value-of
            select="concat(if (parent::*/@xml:id) then parent::*/@xml:id else generate-id(parent::*), '-end')"
        />
    </xsl:template>

    <xsl:template mode="edmac:edlabel-start" match="note[@fromTarget]">
        <xsl:value-of select="substring(@fromTarget, 2)"/>
    </xsl:template>

    <xsl:template mode="edmac:edlabel-end" match="note[@fromTarget]">
        <xsl:value-of select="concat(if (@xml:id) then @xml:id else generate-id(), '-end')"/>
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


    <!-- override this in order to make other verse endings -->
    <xsl:template name="edmac:verse-end">
        <!-- TODO: Are there more possibilities for nested following verses? -->
        <xsl:if test="following-sibling::l | following-sibling::app/lem//l">
            <!-- in reledmac, each verse but the last is ended by an ampersand -->
            <xsl:text>&amp;%&lb;</xsl:text>
        </xsl:if>
    </xsl:template>


    <!-- general tools -->

    <xsl:function name="edmac:normalize" as="xs:string" visibility="public">
        <xsl:param name="latex" as="xs:string*"/>
        <xsl:choose>
            <xsl:when test="$edmac:normalization eq 'space'">
                <!--
                    Leading space is stripped.
                    Trailing ASCII SP is stripped but trailing linebreaks are kept because they may end a comment.
                    Multiple spaces are shrinked to a single space, but linebreaks ending a comment are kept.
                -->
                <!-- note: using named entities in regex does not work -->
                <xsl:variable name="pass1" select="string-join($latex) =>
                        replace('(%[^&#xa;]*&#xa;&#xd;?)\s+', '$1 ', 'm') =>
                        replace('[ ]+', ' ') =>
                        replace('^\s+', '') =>
                        replace('[ ]+$', '')
                        "/>
                <!-- Since do not have (negative) lookahead,
                    we cannot use replace() to remove trailing newlines but them in case of keep comments.
                -->
                <xsl:choose>
                    <xsl:when
                        test="matches($pass1, '\s+$') and not(replace($pass1, '\s+$', '') => matches('%[^&#xa;]*$'))">
                        <xsl:message use-when="system-property('debug') eq 'true'">
                            <xsl:text>deleting left over trailing space: '</xsl:text>
                            <xsl:value-of select="$pass1"/>
                            <xsl:text>'</xsl:text>
                        </xsl:message>
                        <xsl:value-of select="replace($pass1, '\s+$', '')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$pass1"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="string-join($latex)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:package>
