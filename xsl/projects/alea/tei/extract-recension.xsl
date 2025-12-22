<?xml version="1.0" encoding="UTF-8"?>
<!-- XSL transformation for extracting a single recension from a multiple-recension document.

Recensions and the witnesses belonging to them are expected to be encoded
as a sourceDesc//listWit with an @xml:id.

There are different entry points:

1. match document-node() -> extract a single recension
2. initial template recension:separate-docs -> extract all recensions to several documents
3. initial template recension:tei-corpus -> extract all recensions to <teiCorpus>

All entry points hand over to mode recension:single on the document node and
pass in the recension as a tunnel parameter.

The initial templates require a (global) context item.


We define a default mode in order to make stylesheet composition simpler.

-->
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/tei/extract-recension.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:diwan="http://scdh.wwu.de/transform/diwan#"
    xmlns:recension="http://scdh.wwu.de/transform/recension#" exclude-result-prefixes="#all"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.1"
    default-mode="recension:extract">

    <xsl:mode name="recension:extract" on-no-match="fail" visibility="final"/>

    <xsl:param name="source" as="xs:string" required="true"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/common/diwan.xsl"
        package-version="1.0.0"/>

    <!-- A function to make the filename of an extracted recension -->
    <xsl:param name="recension:filename-function" as="xs:string"
        select="'recension:recension-suffix'"/>

    <!-- The output base folder for xsl:result-document etc. -->
    <xsl:param name="recension:dist" as="xs:string" select="'/'"/>


    <xsl:variable name="recension:work-id-xpath" as="xs:string" visibility="public">
        <xsl:text>(/*/@xml:id, //idno[@type eq 'canonical-id'], //idno[@type eq 'work-identifier'], tokenize(tokenize(base-uri(/), '/')[last()], '\.')[1])[1]</xsl:text>
    </xsl:variable>

    <xsl:param name="recension:source-work-id-delim" as="xs:string" select="'###'"/>

    <xsl:variable name="recension:new-work-id-xpath" as="xs:string" visibility="public">
        <xsl:text>let $ts:=tokenize(., '#') return concat(replace($ts[1], '[a-z]', ''), $ts[2])</xsl:text>
    </xsl:variable>

    <xsl:function name="recension:new-work-id" as="xs:string" visibility="final">
        <xsl:param name="context" as="node()"/>
        <xsl:param name="recension" as="xs:string"/>
        <xsl:variable name="current-id" as="xs:string">
            <xsl:evaluate as="xs:string" context-item="$context" xpath="$recension:work-id-xpath"
                expand-text="true"/>
        </xsl:variable>
        <xsl:variable name="new-id" as="xs:string">
            <xsl:evaluate as="xs:string" context-item="concat($recension, '#', $current-id)"
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

    <!-- entry points -->

    <xsl:template match="document-node()">
        <xsl:apply-templates mode="recension:single" select=".">
            <xsl:with-param name="recension" select="$source" tunnel="true"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template name="recension:separate-docs" visibility="final">
        <xsl:context-item as="document-node()" use="required"/>
        <xsl:variable name="source-document" select="."/>
        <!-- only extract recensions, if the source does not encode a single recension -->
        <xsl:if test="not(matches(/TEI/@xml:id, '^[A-Z]'))">
            <xsl:for-each select="$source-document//teiHeader//sourceDesc//listWit/@xml:id">
                <xsl:variable name="recension" select="."/>
                <xsl:variable name="fun" as="function (document-node(), xs:string) as xs:anyURI"
                    select="function-lookup(xs:QName($recension:filename-function), 2)"/>
                <xsl:variable name="recension-output" select="$fun($source-document, $recension)"/>
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>Extracting recension </xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text> to </xsl:text>
                    <xsl:value-of select="$recension-output"/>
                    <xsl:text> determined by '</xsl:text>
                    <xsl:value-of select="$recension:filename-function"/>
                    <xsl:text>#2'</xsl:text>
                </xsl:message>
                <xsl:result-document href="{$recension-output}">
                    <xsl:apply-templates mode="recension:single" select="$source-document">
                        <xsl:with-param name="recension" select="$recension" tunnel="true"/>
                    </xsl:apply-templates>
                </xsl:result-document>
            </xsl:for-each>
        </xsl:if>
        <!-- copy the source to the default output -->
        <xsl:copy-of select="."/>
    </xsl:template>

    <xsl:function name="recension:recension-suffix" as="xs:anyURI">
        <xsl:param name="source-document" as="document-node()"/>
        <xsl:param name="recension" as="xs:string"/>
        <xsl:sequence
            select="concat(base-uri($source-document), '.', $recension, '.xml') => xs:anyURI()"/>
    </xsl:function>

    <xsl:function name="recension:systematic-name" as="xs:anyURI">
        <xsl:param name="source-document" as="document-node()"/>
        <xsl:param name="recension" as="xs:string"/>
        <xsl:variable name="code" as="map(xs:string, xs:string)"
            select="diwan:parse-code($source-document/TEI/@xml:id)"/>
        <xsl:variable name="systematic-path" as="xs:string" select="'Diwan/'
            || map:get($code, 'rhyme') || '/' 
            || map:get($code, 'rhyme') || map:get($code, 'number') || '/' 
            || replace($recension, '[a-z]', '') || map:get($code, 'rhyme') || map:get($code, 'number') || '.tei.xml'"/>
        <xsl:sequence select="resolve-uri($systematic-path, $recension:dist)"/>
    </xsl:function>

    <xsl:template name="recension:tei-corpus" visibility="final">
        <xsl:context-item as="document-node(element(TEI))" use="required"/>
        <xsl:variable name="source-document" select="."/>
        <xsl:call-template name="warning"/>
        <teiCorpus>
            <teiHeader>
                <!-- TODO: common header -->
            </teiHeader>
            <xsl:for-each select="$source-document//teiHeader//sourceDesc//listWit/@xml:id">
                <xsl:apply-templates mode="recension:single" select="$source-document">
                    <xsl:with-param name="recension" select="." tunnel="true"/>
                </xsl:apply-templates>
            </xsl:for-each>
        </teiCorpus>
    </xsl:template>


    <!-- mode recension:single does the extraction -->

    <xsl:mode name="recension:single" on-no-match="shallow-copy" visibility="final"/>

    <xsl:template mode="recension:single" match="document-node()">
        <xsl:param name="recension" as="xs:string" tunnel="true"/>
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>extracting recension '</xsl:text>
            <xsl:value-of select="$recension"/>
            <xsl:text>'</xsl:text>
        </xsl:message>
        <xsl:call-template name="warning"/>
        <xsl:choose>
            <xsl:when test="exists(//teiHeader//sourceDesc//listWit[@xml:id eq $recension])">
                <xsl:apply-templates mode="recension:single"/>
            </xsl:when>
            <xsl:when test="$recension eq ''">
                <!-- No recension selected: Apply simple identity transformation -->
                <xsl:message use-when="system-property('debug') eq 'true'">No recension selected.
                    Performing identity transformation. </xsl:message>
                <xsl:copy-of select="node() | comment() | processing-instruction()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">Recension not found</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="recension:single" match="TEI">
        <xsl:param name="recension" as="xs:string" tunnel="true"/>
        <xsl:copy>
            <xsl:apply-templates mode="#current" select="@* except @xml:id"/>
            <xsl:attribute name="xml:id" select="recension:new-work-id(., $recension)"/>
            <!-- Enable downstream packages to do something on the root node.
                This may be important on composition. -->
            <xsl:if test="parent::document-node()">
                <xsl:call-template name="recension:root-hook"/>
            </xsl:if>
            <xsl:apply-templates mode="#current" select="node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- this named template is a hook to do something on the root node if required -->
    <xsl:template name="recension:root-hook" visibility="public">
        <xsl:context-item as="element()" use="required"/>
    </xsl:template>

    <!-- delete recension and its witnesses from the source description -->
    <xsl:template mode="recension:single" match="sourceDesc//listWit[@xml:id]">
        <xsl:param name="recension" tunnel="true"/>
        <xsl:if test="string(@xml:id) eq $recension">
            <xsl:copy>
                <xsl:apply-templates mode="#current" select="node() | attribute()"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>

    <!-- this rule applys for positive recension encoding, i.e. all
        recensions are explicitly given. -->
    <xsl:template mode="recension:single" match="choice[child::seg[@source]]">
        <xsl:param name="recension" as="xs:string" tunnel="true"/>
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>selecting reading ...</xsl:text>
        </xsl:message>
        <xsl:apply-templates mode="#current" select="
                seg[some $s in tokenize(@source, '\s+')
                    satisfies $s eq concat('#', $recension)]/node()"/>
    </xsl:template>

    <!-- this rule applies to positive recension encoding -->
    <xsl:template mode="recension:single" match="*[@source]">
        <xsl:param name="recension" as="xs:string" tunnel="true"/>
        <xsl:choose>
            <xsl:when test="
                    some $s in tokenize(@source, '\s+')
                        satisfies $s eq concat('#', $recension)">
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>selecting </xsl:text>
                    <xsl:value-of select="name(.)"/>
                    <xsl:text> of recension</xsl:text>
                </xsl:message>
                <xsl:copy>
                    <xsl:apply-templates mode="#current" select="@* except @source"/>
                    <xsl:apply-templates mode="#current" select="node()"/>
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
    <xsl:template mode="recension:single" match="app">
        <xsl:param name="recension" as="xs:string" tunnel="true"/>
        <xsl:choose>
            <xsl:when
                test="every $wit in (string-join((child::rdg/@wit | child::witDetail/@wit), ' ') => tokenize()) ! substring(., 2)
                satisfies not(exists(//teiHeader//sourceDesc//listWit[@xml:id eq $recension]//witness[@xml:id eq $wit]))">
                <!-- handle the lemma according to variant encoding -->
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>delete whole app with readings from </xsl:text>
                    <xsl:value-of
                        select="string-join((child::rdg/@wit, child::witDetail/@wit), ' ')"/>
                </xsl:message>
                <xsl:apply-templates select="lem" mode="lemma"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates mode="#current"
                        select="node() | attribute() | comment() | processing-instruction()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:mode name="lemma"/>

    <!-- keep the lemma in parallel segmentation -->
    <xsl:template mode="lemma"
        match="lem[//descendant::variantEncoding[@method eq 'parallel-segmentation']]">
        <xsl:message use-when="system-property('debug') eq 'true'">keeping lemma</xsl:message>
        <xsl:apply-templates mode="recension:single"/>
    </xsl:template>

    <!-- delete the lemma in all other encoding variants -->
    <xsl:template mode="lemma" match="lem"/>

    <!-- remove variant readings not from the current recension -->
    <xsl:template mode="recension:single" match="rdg[@wit] | witDetail[@wit]">
        <xsl:param name="recension" as="xs:string" tunnel="true"/>
        <xsl:choose>
            <xsl:when test="every $wit in (tokenize(@wit) ! substring(., 2))
                satisfies empty(//teiHeader//sourceDesc//listWit[@xml:id eq $recension]//witness[@xml:id eq $wit])">
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>deleting single reading</xsl:text>
                </xsl:message>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates mode="#current"
                        select="node() | attribute() | comment() | processing-instruction()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- remove all sigla from other recensions -->
    <xsl:template mode="recension:single" match="@wit">
        <xsl:param name="recension" as="xs:string" tunnel="true"/>
        <xsl:variable name="root" select="root()"/>
        <xsl:variable name="tokenized" select="tokenize(.)"/>
        <xsl:variable name="filtered" select="
                ($tokenized)[let $s := substring(., 2)
                return
                    exists($root//teiHeader//sourceDesc//listWit[@xml:id eq $recension]//witness[@xml:id eq $s])]"/>
        <xsl:attribute name="wit" select="string-join($filtered, ' ')"/>
    </xsl:template>

</xsl:package>
