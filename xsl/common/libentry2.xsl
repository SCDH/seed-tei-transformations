<?xml version="1.0" encoding="UTF-8"?>
<!--
A generic implementation of a critical apparatus that works for
all of the following three variant encodings:

- parallel segmentation
- internal double end-point
- external double end-point

To deal with double end-point variant encodings the apparatus does the following:

1) Get a collection of all apparatus entries.
2) For each entry, get the text nodes that make up the lemma. White space text nodes are ignored.
3) Group the apparatus entries by the sequence of text nodes, that they are made of. This way,
   entries that originate from the same text nodes are grouped together.
4) Output the lemma once per group.
5) Output the readings and other annotations that make up the group.

The apparatus can be used on a document-wide basis, as used e.g. for short poems. And it can be used
on a part-of-document basis, as used e.g. for pages of a long prose work.

There are several modes that controle
- the selection of lemma text nodes
- the presentation of the lemma
- the presentation of the readings etc.

These modes are public and can be extended to your needs.

The static strings––e.g. separators, scholaraly phrases like "omisit"––can be overridden and translated
using the libi18n.xsl package.


The apparatus is configurable through variables with XPath expression that determine
which encoding cristalls go into the apparatus.

Usage:

Most generic usage needs 2 components
- the function app:apparatus-entries#2 to generate a map of apparatus entries and pass this map to
- the template app:apparatus
The funtion takes a context to determine the extension of the apparatus (doc or part) and an XPath
expression to determine its features.

For convenience there are also predefined XPath expressions and the template
- app:appararus-for-context
that does the two more generic steps.

Example:
see xsl/projects/alea/preview.xsl

-->
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libentry2.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:seed="http://scdh.wwu.de/transform/seed#"
    xmlns:common="http://scdh.wwu.de/transform/common#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    version="3.1">

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libbetween.xsl"
        package-version="1.0.0"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libcommon.xsl"
        package-version="0.1.0"/>


    <xsl:expose component="mode" names="*" visibility="public"/>
    <xsl:expose component="template" names="seed:*" visibility="public"/>
    <xsl:expose component="variable" names="seed:*" visibility="public"/>
    <xsl:expose component="function" names="seed:*" visibility="public"/>

    <!-- whether or not the first text node from a lemma determines the line number of the entry -->
    <xsl:param name="seed:lemma-first-text-node-line-crit" as="xs:boolean" select="true()"
        required="false"/>

    <!-- XPath how to get a pLike container given an (app) entry.
        Note: this should not evaluate to an empty sequence. -->
    <xsl:variable name="seed:entry-container-xpath" as="xs:string" visibility="public">
        <xsl:value-of>
            <xsl:text>ancestor::p</xsl:text>
            <xsl:text>| ancestor::l</xsl:text>
            <xsl:text>| ancestor::head</xsl:text>
        </xsl:value-of>
    </xsl:variable>

    <xsl:variable name="seed:text-nodes-mutet-ancestors" as="xs:string" visibility="public">
        <xsl:value-of>
            <xsl:text>ancestor::rdg</xsl:text>
            <xsl:text>| ancestor::sic[parent::choice]</xsl:text>
        </xsl:value-of>
    </xsl:variable>

    <!-- for convenience this will be '@location-@method' -->
    <xsl:function name="seed:variant-encoding" visibility="public">
        <xsl:param name="context" as="node()"/>
        <xsl:variable name="ve" select="root($context)//teiHeader/encodingDesc/variantEncoding"/>
        <xsl:value-of select="concat($ve/@location, '-', $ve/@method)"/>
    </xsl:function>


    <!-- you may want to override this: shortening of the lemma done here -->
    <xsl:function name="seed:shorten-lemma" as="xs:string" visibility="public">
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

    <!--
        This generates a map for an apparatus entry with all there is needed
        for grouping and creating the entry.

        We choose the type xs:integer for the type parameter because it
        will be used for filtering and comparing integers is much faster
        than comparing strings.

        parameters:
        @entry: the apparatus element
        @number: the footnote number of the apparatus element
        @type: the type of the apparatus, e.g. 1 for critical apparatus, 2 for editorial comments
        @lemma-text-nodes: a sequence of text nodes from the edited (main) text, that the entry is about
    -->
    <xsl:function name="seed:mk-entry-map" as="map(*)" visibility="final">
        <xsl:param name="entry" as="element()"/>
        <xsl:param name="number" as="xs:integer"/>
        <xsl:param name="type" as="xs:integer"/>
        <xsl:param name="lemma-text-nodes" as="text()*"/>
        <xsl:variable name="non-whitespace-text-nodes" as="text()*"
            select="$lemma-text-nodes[normalize-space(.) ne '']"/>
        <xsl:variable name="lemma-text-node-ids" as="xs:string*"
            select="$non-whitespace-text-nodes ! generate-id(.)"/>
        <xsl:variable name="lemma-grouping-ids" as="xs:string">
            <!-- if the element passed in is empty, the ID of the element is used. This asserts, that we have a grouping key.
                Whitespace text nodes are dropped because they generally interfere with testing where the lemma originates from.
                -->
            <xsl:choose>
                <xsl:when test="empty($lemma-text-node-ids)">
                    <xsl:value-of
                        select="if ($entry/@xml:id) then $entry/@xml:id else generate-id($entry)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$lemma-text-node-ids => string-join('-')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- in case of an empty lemma, we make a replacement: the preceding or following word -->
        <xsl:variable name="full-lemma" as="xs:string"
            select="$lemma-text-nodes => seed:shorten-lemma()"/>
        <xsl:variable name="lemma-replacement" as="map(xs:string, xs:string)">
            <xsl:choose>
                <xsl:when test="$full-lemma ne ''">
                    <!-- we do not need a replacement -->
                    <xsl:sequence select="map {}"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- TODO: for a non-internal apparatus we have to make $lemma-node
                        something different from $entry, e.g. start or end anchors -->
                    <xsl:variable name="lemma-node" select="$entry"/>
                    <xsl:variable name="pLike-container" as="element()*">
                        <xsl:evaluate context-item="$lemma-node" as="element()*" expand-text="true"
                            xpath="$seed:entry-container-xpath"/>
                    </xsl:variable>
                    <xsl:message use-when="system-property('debug') eq 'true'">
                        <xsl:text>libapp2: pLike-container for </xsl:text>
                        <xsl:value-of select="name($entry)"/>
                        <xsl:text>: </xsl:text>
                        <xsl:value-of select="name($pLike-container)"/>
                    </xsl:message>
                    <xsl:variable name="pLike-container-id" select="generate-id($pLike-container)"
                        as="xs:string"/>
                    <!-- the last string-join('') make this robust against empty sequences in $pLike-container -->
                    <xsl:variable name="preceding-word" as="xs:string" select="
                            (($lemma-node/preceding::text()[ancestor::*[generate-id(.) eq $pLike-container-id] and seed:text-node-in-text(.)])
                            => string-join('')
                            => normalize-space()
                            => tokenize())[last()]
                            => string-join('')"/>
                    <xsl:variable name="following-word" as="xs:string" select="
                            (($lemma-node/following::text()[ancestor::*[generate-id(.) eq $pLike-container-id] and seed:text-node-in-text(.)])
                            => string-join('')
                            => normalize-space()
                            => tokenize())[1]
                            => string-join('')"/>
                    <xsl:choose>
                        <!-- TODO: if directly after <caesura> then use following word. -->
                        <xsl:when test="$preceding-word ne ''">
                            <xsl:sequence select="
                                    map {
                                        'position': 'preceding',
                                        'text': $preceding-word
                                    }"/>
                        </xsl:when>
                        <xsl:when test="$following-word ne ''">
                            <xsl:sequence select="
                                    map {
                                        'position': 'following',
                                        'text': $following-word
                                    }"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- If we have an empty sequence in $pLike-container, this branch is evaluated. -->
                            <xsl:sequence select="
                                    map {
                                        'position': 'replacement',
                                        'text': 'empty'
                                    }"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="lemma-node-for-line" as="node()">
            <!-- this variable's type is node() and not text(),
                since we may have had an empty element. -->
            <!-- TODO: for external apparatus, we will have to extend
                the logic in case a entry is nested in an external element,
                e.g. a <rdg>. This can be done by introducing another mode analog
                to lemma-text-nodes, that switches to the lemma of the including
                elment. -->
            <xsl:choose>
                <xsl:when test="$seed:lemma-first-text-node-line-crit">
                    <xsl:sequence select="($non-whitespace-text-nodes, $entry)[1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="($entry, $non-whitespace-text-nodes)[last()]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="line-number" select="common:line-number($lemma-node-for-line)"/>
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>Line number for </xsl:text>
            <xsl:value-of select="
                        if ($lemma-node-for-line[element()]) then
                            name($lemma-node-for-line)
                        else
                            'text()'"/>
            <xsl:text> node </xsl:text>
            <xsl:value-of select="generate-id($lemma-node-for-line)"/>
            <xsl:text>: </xsl:text>
            <xsl:value-of select="$line-number"/>
            <xsl:if test="matches($line-number, '\?')">
                <xsl:value-of select="$lemma-node-for-line"/>
            </xsl:if>
        </xsl:message>
        <xsl:sequence select="
                map {
                    'entry': $entry,
                    'entry-id': seed:get-id($entry),
                    'type': $type,
                    'lemma-text-nodes': $lemma-text-nodes,
                    'lemma-grouping-ids': $lemma-grouping-ids,
                    'lemma-replacement': $lemma-replacement,
                    'line-number': $line-number,
                    'number': $number
                }"/>
    </xsl:function>

    <xsl:function name="seed:get-id" as="xs:string">
        <xsl:param name="context" as="node()"/>
        <xsl:choose>
            <xsl:when test="$context/@xml:id">
                <xsl:value-of select="$context/@xml:id"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="generate-id($context)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- make a map that can be used to add apparatus footnote signs into the main (edited) text -->
    <xsl:function name="seed:note-based-apparatus-nodes-map" as="map(xs:string, map(*))"
        visibilty="final">
        <xsl:param name="entries" as="map(*)*"/>
        <xsl:param name="after" as="xs:boolean"/>
        <xsl:map>
            <xsl:for-each-group select="$entries" group-by="map:get(., 'lemma-grouping-ids')">
                <xsl:variable name="entry" select="current-group()[1]"/>
                <xsl:variable name="text-node-id" as="xs:string">
                    <xsl:choose>
                        <xsl:when test="$after">
                            <xsl:value-of
                                select="(map:get($entry, 'lemma-grouping-ids') => tokenize('-'))[last()]"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="(map:get($entry, 'lemma-grouping-ids') => tokenize('-'))[1]"
                            />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="element-node-id" select="map:get($entry, 'entry-id')"/>
                <xsl:map-entry key="$element-node-id">
                    <xsl:map>
                        <xsl:map-entry key="'entry-id'" select="map:get($entry, 'entry-id')"/>
                        <xsl:map-entry key="'number'" select="map:get($entry, 'number')"/>
                        <xsl:map-entry key="'after'" select="$after"/>
                    </xsl:map>
                </xsl:map-entry>
            </xsl:for-each-group>
        </xsl:map>
    </xsl:function>


    <!-- Returns true if the text() node is in the edited text (lemma) -->
    <xsl:function name="seed:text-node-in-text" as="xs:boolean" visibility="final">
        <xsl:param name="context" as="text()"/>
        <!-- An other implementation could use the libtext module. But this would be difficult. -->
        <xsl:variable name="mutet-ancestors" as="node()*">
            <xsl:evaluate as="node()*" context-item="$context" expand-text="true"
                xpath="$seed:text-nodes-mutet-ancestors"/>
        </xsl:variable>
        <xsl:sequence select="empty($mutet-ancestors)"/>
    </xsl:function>


    <xsl:function name="seed:lemma-text-nodes" as="text()*" visibility="final">
        <xsl:param name="element" as="element()"/>
        <xsl:apply-templates select="$element" mode="seed:lemma-text-nodes"/>
    </xsl:function>


    <!-- the mode lemma-text-nodes is for grouping apparatus entries by the text repeated from the base text -->
    <xsl:mode name="seed:lemma-text-nodes" on-no-match="shallow-skip" visibility="public"/>

    <xsl:template mode="seed:lemma-text-nodes" match="text()" as="text()">
        <xsl:sequence select="."/>
    </xsl:template>

    <!-- caesura is replaced with a space. Override this if needed! -->
    <xsl:template mode="seed:lemma-text-nodes" match="caesura" as="text()">
        <xsl:text>&#x20;</xsl:text>
    </xsl:template>

    <!-- things that do not go into the base text -->
    <xsl:template mode="seed:lemma-text-nodes"
        match="rdg | choice[corr]/sic | choice[reg]/orig | span | index | note | witDetail"/>

    <xsl:template mode="seed:lemma-text-nodes"
        match="lem[matches(seed:variant-encoding(.), '^(in|ex)ternal-double-end-point')]"/>


</xsl:package>
