<?xml version="1.0" encoding="UTF-8"?>
<!-- XSL transfromation for extracting a single recension from a multiple-recension document.

Recensions and the witnesses belonging to them are expected to be encoded
as a sourceDesc//listWit with an @xml:id.

We define a default mode in order to make stylesheet composition simpler.
-->
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/tei/extract-recension.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:recension="http://scdh.wwu.de/transform/recension#" exclude-result-prefixes="#all"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.1"
    default-mode="recension:extract">

    <xsl:mode name="recension:extract" on-no-match="shallow-copy" visibility="public"/>
    <xsl:mode name="recension:single" on-no-match="shallow-copy" visibility="public"/>

    <xsl:param name="source" as="xs:string" required="true"/>

    <xsl:variable name="recension:work-id-xpath" as="xs:string" visibility="public">
        <xsl:text>(/*/@xml:id, //idno[@type eq 'canonical-id'], //idno[@type eq 'work-identifier'], tokenize(tokenize(base-uri(/), '/')[last()], '\.')[1])[1]</xsl:text>
    </xsl:variable>

    <xsl:param name="recension:source-work-id-delim" as="xs:string" select="'###'"/>

    <xsl:variable name="recension:new-work-id-xpath" as="xs:string" visibility="public">
        <xsl:text>let $ts:=tokenize(., '#') return concat(replace($ts[1], '[a-z]', ''), $ts[2])</xsl:text>
    </xsl:variable>

    <xsl:function name="recension:new-work-id" as="xs:string" visibility="final">
        <xsl:param name="context" as="node()"/>
        <xsl:variable name="current-id" as="xs:string">
            <xsl:evaluate as="xs:string" context-item="$context" xpath="$recension:work-id-xpath"
                expand-text="true"/>
        </xsl:variable>
        <xsl:variable name="new-id" as="xs:string">
            <xsl:evaluate as="xs:string" context-item="concat($source, '#', $current-id)"
                xpath="$recension:new-work-id-xpath" expand-text="true"/>
        </xsl:variable>
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>Changed work ID from </xsl:text>
            <xsl:value-of select="$current-id"/>
            <xsl:text> to </xsl:text>
            <xsl:value-of select="$new-id"/>
        </xsl:message>
        <xsl:value-of select="$new-id"/>
    </xsl:function>

    <!-- delete MRE app info -->
    <xsl:template match="application[@ident eq 'oxmre']"/>
    <xsl:template match="appInfo[not(exists(application[@ident ne 'oxmre']))]"/>

    <xsl:template name="warning">
        <xsl:text>&#xa;</xsl:text>
        <xsl:comment>
            <xsl:text>Extracted from </xsl:text>
            <xsl:value-of select="tokenize(base-uri(/), '/')[last()]"/>
            <xsl:text>. Do NOT change!</xsl:text>
        </xsl:comment>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>

    <xsl:template match="/">
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>extracting recension '</xsl:text>
            <xsl:value-of select="$source"/>
            <xsl:text>'</xsl:text>
        </xsl:message>
        <xsl:call-template name="warning"/>
        <xsl:choose>
            <xsl:when test="exists(//teiHeader//sourceDesc//listWit[@xml:id eq $source])">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="$source eq ''">
                <!-- No recension selected: Apply simple identity transformation -->
                <xsl:message use-when="system-property('debug') eq 'true'">No recension selected.
                    Performing identity transformation. </xsl:message>
                <xsl:apply-templates mode="recension:single"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">Recension not found</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="TEI">
        <xsl:copy>
            <xsl:apply-templates select="@* except @xml:id"/>
            <xsl:attribute name="xml:id" select="recension:new-work-id(.)"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- delete recension and its witnesses from the source description -->
    <xsl:template match="sourceDesc//listWit[@xml:id ne $source]"/>

    <!-- this rule applys for positive recension encoding, i.e. all
        recensions are explicitly given. -->
    <xsl:template match="choice[child::seg[@source]]">
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>selecting reading ...</xsl:text>
        </xsl:message>
        <xsl:apply-templates select="
                seg[some $s in tokenize(@source, '\s+')
                    satisfies $s eq concat('#', $source)]/node()"/>
    </xsl:template>

    <!-- this rule applies to positive recension encoding -->
    <xsl:template match="*[@source]">
        <xsl:choose>
            <xsl:when test="
                    some $s in tokenize(@source, '\s+')
                        satisfies $s eq concat('#', $source)">
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>selecting </xsl:text>
                    <xsl:value-of select="name(.)"/>
                    <xsl:text> of recension</xsl:text>
                </xsl:message>
                <xsl:copy>
                    <xsl:apply-templates select="@* except @source"/>
                    <xsl:apply-templates select="node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>unselecting </xsl:text>
                    <xsl:value-of select="name(.)"/>
                    <xsl:text> of recension</xsl:text>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- delete apparatus entries that only belong to other recensions -->
    <xsl:template match="
            app[every $wit in (string-join((child::rdg/@wit | child::witDetail/@wit), ' ') => tokenize()) ! substring(., 2)
                satisfies not(exists(//teiHeader//sourceDesc//listWit[@xml:id eq $source]//witness[@xml:id eq $wit]))]">
        <!-- handle the lemma according to variant encoding -->
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>delete whole app with readings from </xsl:text>
            <xsl:value-of select="string-join((child::rdg/@wit, child::witDetail/@wit), ' ')"/>
        </xsl:message>
        <xsl:apply-templates select="lem" mode="lemma"/>
    </xsl:template>


    <xsl:mode name="lemma"/>

    <!-- keep the lemma in parallel segmentation -->
    <xsl:template mode="lemma"
        match="lem[//descendant::variantEncoding[@method eq 'parallel-segmentation']]">
        <xsl:message use-when="system-property('debug') eq 'true'">keeping lemma</xsl:message>
        <xsl:apply-templates/>
    </xsl:template>

    <!-- delete the lemma in all other encoding variants -->
    <xsl:template mode="lemma" match="lem"/>

    <!-- remove variant readings not from the current recension -->
    <xsl:template match="
            (rdg | witDetail)[every $wit in (tokenize(@wit) ! substring(., 2))
                satisfies empty(//teiHeader//sourceDesc//listWit[@xml:id eq $source]//witness[@xml:id eq $wit])]">
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>deleting single reading</xsl:text>
        </xsl:message>
    </xsl:template>

    <!-- remove all sigla from other recensions -->
    <xsl:template match="@wit">
        <xsl:variable name="root" select="root()"/>
        <xsl:variable name="tokenized" select="tokenize(.)"/>
        <xsl:variable name="filtered" select="
                ($tokenized)[let $s := substring(., 2)
                return
                    exists($root//teiHeader//sourceDesc//listWit[@xml:id eq $source]//witness[@xml:id eq $s])]"/>
        <xsl:attribute name="wit" select="string-join($filtered, ' ')"/>
    </xsl:template>

</xsl:package>
