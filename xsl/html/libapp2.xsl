<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE stylesheet [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
    <!ENTITY sp "&#x20;" >
    <!ENTITY nbsp "&#xa0;" >
    <!ENTITY emsp "&#x2003;" >
    <!ENTITY lb "&#xa;" >
]>
<xsl:package name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libapp2.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:app="http://scdh.wwu.de/transform/app#"
    xmlns:seed="http://scdh.wwu.de/transform/seed#"
    xmlns:common="http://scdh.wwu.de/transform/common#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    version="3.1">

    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libbetween.xsl"
        package-version="1.0.0"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libcommon.xsl"
        package-version="0.1.0"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libi18n.xsl"
        package-version="0.1.0">
        <xsl:accept component="function"
            names="i18n:language#1 i18n:language-direction#1 i18n:language-align#1 i18n:direction-embedding#1"
            visibility="private"/>
    </xsl:use-package>

    <xsl:expose component="mode" names="*" visibility="public"/>


    <!-- whether or not the first text node from a lemma determines the line number of the entry -->
    <xsl:param name="app:lemma-first-text-node-line-crit" as="xs:boolean" select="true()"
        required="false"/>

    <!-- parameters that determine, what shows up in the apparatus
        Please note that you can bypass them e.g. when you want multiple apparatus. -->

    <xsl:variable name="app:entries-xpath-internal-parallel-segmentation" as="xs:string"
        visibility="abstract">
        <!--
        <xsl:value-of>
            <!-/- choice+corr+sic+app+rdg was an old encoding of conjectures in ALEA -/->
            <xsl:text>descendant::app[not(parent::sic[parent::choice])]</xsl:text>
            <xsl:text>| descendant::witDetail[not(parent::app)]</xsl:text>
            <xsl:text>| descendant::corr[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::choice[sic and corr]</xsl:text>
            <xsl:text>| descendant::unclear[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::choice[unclear]</xsl:text>
            <xsl:text>| descendant::gap</xsl:text>
        </xsl:value-of>
        -->
    </xsl:variable>

    <xsl:variable name="app:entries-xpath-internal-double-end-point" as="xs:string"
        visibility="abstract">
        <!--
        <xsl:value-of>
            <!-/- choice+corr+sic+app+rdg was an old encoding of conjectures in ALEA -/->
            <xsl:text>descendant::app[not(parent::sic[parent::choice])]</xsl:text>
            <xsl:text>| descendant::witDetail[not(parent::app)]</xsl:text>
            <xsl:text>| descendant::corr[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::choice[sic and corr]</xsl:text>
            <xsl:text>| descendant::unclear[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::choice[unclear]</xsl:text>
            <xsl:text>| descendant::gap</xsl:text>
        </xsl:value-of>
        -->
    </xsl:variable>

    <xsl:variable name="app:entries-xpath-external-double-end-point" as="xs:string"
        visibility="abstract">
        <!--
        <xsl:value-of>
            <xsl:text>descendant::app</xsl:text>
            <xsl:text>| descendant::witDetail[not(parent::app)]</xsl:text>
            <xsl:text>| descendant::corr[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::choice[sic and corr]</xsl:text>
            <xsl:text>| descendant::unclear[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::choice[unclear]</xsl:text>
            <xsl:text>| descendant::gap</xsl:text>
        </xsl:value-of>
        -->
    </xsl:variable>

    <xsl:variable name="app:entries-xpath-no-textcrit" as="xs:string" visibility="abstract">
        <!--
        <xsl:value-of>
            <xsl:text>descendant::corr[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::choice[sic and corr]</xsl:text>
            <xsl:text>| descendant::unclear[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::choice[unclear]</xsl:text>
            <xsl:text>| descendant::gap</xsl:text>
        </xsl:value-of>
        -->
    </xsl:variable>

    <!-- XPath how to get a pLike container given an app entry.
        Note: this should not evaluate to an empty sequence. -->
    <xsl:variable name="app:entry-container-xpath" as="xs:string" visibility="abstract">
        <!--
        <xsl:value-of>
            <xsl:text>ancestor::p</xsl:text>
            <xsl:text>| ancestor::l</xsl:text>
            <xsl:text>| ancestor::head</xsl:text>
        </xsl:value-of>
        -->
    </xsl:variable>

    <xsl:variable name="app:text-nodes-mutet-ancestors" as="xs:string" visibility="abstract">
        <!--
        <xsl:value-of>
            <xsl:text>ancestor::rdg</xsl:text>
            <xsl:text>| ancestor::sic[parent::choice]</xsl:text>
        </xsl:value-of>
        -->
    </xsl:variable>

    <!-- for convenience this will be '@location-@method' -->
    <!-- TODO: the global context item will be missing! -->
    <xsl:variable name="variant-encoding" visibility="private">
        <xsl:variable name="ve"
            select="/TEI/teiHeader/encodingDesc/variantEncoding | /teiCorpus/teiHeader/encodingDesc/variantEncoding"/>
        <xsl:value-of select="concat($ve/@location, '-', $ve/@method)"/>
    </xsl:variable>

    <!-- select the right XPath for generating apparatus entries -->
    <xsl:variable name="app-entries-xpath" visibility="final">
        <xsl:choose>
            <xsl:when test="$variant-encoding eq 'internal-double-end-point'">
                <xsl:value-of select="$app:entries-xpath-internal-double-end-point"/>
            </xsl:when>
            <xsl:when test="$variant-encoding eq 'external-double-end-point'">
                <xsl:value-of select="$app:entries-xpath-internal-double-end-point"/>
            </xsl:when>
            <xsl:when test="$variant-encoding eq 'internal-parallel-segmentation'">
                <xsl:value-of select="$app:entries-xpath-internal-parallel-segmentation"/>
            </xsl:when>
            <xsl:when test="$variant-encoding eq '-'">
                <xsl:value-of select="$app:entries-xpath-no-textcrit"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">
                    <xsl:text>This variant encoding is not supported: </xsl:text>
                    <xsl:value-of select="$variant-encoding"/>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>



    <!-- convenience functions and templates for generating the apparatus with the XPaths from the parameters above. -->

    <!-- generate apparatus elements for a given context, e.g. / and prepare mappings for them.
        This implementation uses the XPaths defined above to generate the sequence of apparatus entries.
    -->
    <xsl:function name="app:apparatus-entries" as="map(*)*" visibility="public">
        <xsl:param name="context" as="node()*"/>
        <!-- we first generate a sequence of all elements that should show up in the apparatus -->
        <xsl:sequence as="map(*)*" select="app:apparatus-entries($context, $app-entries-xpath)"/>
    </xsl:function>

    <!-- generate the apparatus for a given context, e.g. / -->
    <xsl:template name="app:apparatus-for-context" visibility="public">
        <xsl:param name="app-context" as="node()*"/>
        <xsl:call-template name="app:apparatus">
            <xsl:with-param name="entries" select="app:apparatus-entries($app-context)"/>
        </xsl:call-template>
    </xsl:template>



    <!-- generic implementation of the apparatus
        The XPath expressions from above are not hard-wired anywhere below.
    -->

    <!-- generate apparatus elements for a given context, e.g. / and prepare mappings for them.
        The second argument is an XPath expression that tells what elements should go into the apparatus.
        It is evaluated in the context given by the parameter 'context'.
    -->
    <xsl:function name="app:apparatus-entries" as="map(*)*" visibility="public">
        <xsl:param name="context" as="node()*"/>
        <xsl:param name="app-entries-xpath" as="xs:string"/>
        <!-- we first generate a sequence of all elements that should show up in the apparatus -->
        <xsl:variable name="entry-elements" as="element()*">
            <xsl:evaluate as="element()*" context-item="$context" expand-text="true"
                xpath="$app-entries-xpath"/>
        </xsl:variable>
        <xsl:sequence as="map(*)*" select="$entry-elements ! seed:mk-entry-map(.)"/>
    </xsl:function>

    <!-- generate the apparatus for a sequence of prepared maps -->
    <xsl:template name="app:apparatus" visibility="public">
        <xsl:param name="entries" as="map(*)*"/>
        <div>
            <!-- we first group the entries by line number -->
            <xsl:for-each-group select="$entries" group-by="map:get(., 'line-number')">
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>Apparatus entries for line </xsl:text>
                    <xsl:value-of select="current-grouping-key()"/>
                    <xsl:text> : </xsl:text>
                    <xsl:value-of select="count(current-group())"/>
                </xsl:message>

                <div class="apparatus-line">
                    <span class="apparatus-line-number line-number">
                        <xsl:value-of select="current-grouping-key()"/>
                        <xsl:text>&sp;</xsl:text>
                    </span>
                    <span class="apparatus-line-entries">
                        <!-- we then group by such entries, that get their lemma (repetition of the base text)
                            from the same set of text nodes, because we want to join them into one entry -->
                        <xsl:for-each-group select="current-group()"
                            group-by="map:get(., 'lemma-grouping-ids')">
                            <xsl:message use-when="system-property('debug') eq 'true'">
                                <xsl:text>Joining </xsl:text>
                                <xsl:value-of select="count(current-group())"/>
                                <xsl:text> apparatus entries referencing text nodes </xsl:text>
                                <xsl:value-of select="current-grouping-key()"/>
                            </xsl:message>
                            <!-- call the template that outputs an apparatus entries -->
                            <xsl:call-template name="app:apparatus-entry">
                                <xsl:with-param name="entries" select="current-group()"/>
                            </xsl:call-template>
                        </xsl:for-each-group>
                    </span>
                </div>

            </xsl:for-each-group>
        </div>
    </xsl:template>

    <!-- the template for an entry -->
    <xsl:template name="app:apparatus-entry" visibility="private">
        <xsl:param name="entries" as="map(*)*"/>
        <span class="apparatus-entry">
            <xsl:call-template name="app:apparatus-lemma">
                <xsl:with-param name="entry" select="$entries[1]"/>
            </xsl:call-template>
            <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">]</span>
            <xsl:for-each select="$entries">
                <xsl:apply-templates mode="apparatus-reading-dspt" select="map:get(., 'entry')">
                    <xsl:with-param name="apparatus-entry-map" as="map(*)" select="." tunnel="true"
                    />
                </xsl:apply-templates>
                <xsl:if test="position() ne last()">
                    <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                        >;</span>
                </xsl:if>
            </xsl:for-each>
            <xsl:if test="position() ne last()">
                <span class="apparatus-sep" data-i18n-key="app-entry-sep">&nbsp;|&emsp;</span>
            </xsl:if>
        </span>
    </xsl:template>

    <!-- template for making the lemma text with some logic for handling empty lemmas -->
    <xsl:template name="app:apparatus-lemma" visibility="private">
        <xsl:param name="entry" as="map(*)"/>
        <span class="apparatus-lemma">
            <xsl:variable name="full-lemma" as="xs:string"
                select="map:get($entry, 'lemma-text-nodes') => app:shorten-lemma()"/>
            <xsl:choose>
                <xsl:when test="map:get($entry, 'entry')/self::gap">
                    <span class="lemma-gap" data-i18n-key="gap-rep">[…]</span>
                </xsl:when>
                <xsl:when test="$full-lemma ne ''">
                    <xsl:value-of select="$full-lemma"/>
                </xsl:when>
                <xsl:when test="$full-lemma eq ''">
                    <!-- empty lemma: we get the text from empty replacement -->
                    <xsl:variable name="empty-replacement"
                        select="map:get($entry, 'lemma-replacement')"/>
                    <xsl:value-of select="map:get($empty-replacement, 'text')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>???</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>

    <!-- you may want to override this: shortening of the lemma done here -->
    <xsl:function name="app:shorten-lemma" as="xs:string" visibility="public">
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

    <!-- this generates a map (object) for an apparatus entry
        with all there is needed for grouping and creating the entry -->
    <xsl:function name="seed:mk-entry-map" as="map(*)" visibility="public">
        <xsl:param name="entry" as="element()"/>
        <xsl:variable name="lemma-text-nodes" as="text()*">
            <xsl:apply-templates select="$entry" mode="lemma-text-nodes-dspt"/>
        </xsl:variable>
        <xsl:sequence select="seed:mk-entry-map($entry, $lemma-text-nodes)"/>
    </xsl:function>

    <xsl:function name="seed:mk-entry-map" as="map(*)" visibility="public">
        <xsl:param name="entry" as="element()"/>
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
                    <xsl:value-of select="generate-id($entry)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$lemma-text-node-ids => string-join('-')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- in case of an empty lemma, we make a replacement: the preceding or following word -->
        <xsl:variable name="full-lemma" as="xs:string"
            select="$lemma-text-nodes => app:shorten-lemma()"/>
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
                            xpath="$app:entry-container-xpath"/>
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
                <xsl:when test="$app:lemma-first-text-node-line-crit">
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
                    'entry-id': generate-id($entry),
                    'lemma-text-nodes': $lemma-text-nodes,
                    'lemma-grouping-ids': $lemma-grouping-ids,
                    'lemma-replacement': $lemma-replacement,
                    'line-number': $line-number
                }"/>
    </xsl:function>

    <xsl:function name="app:lemma-text-nodes" as="text()*" visibility="public">
        <xsl:param name="element" as="element()"/>
        <xsl:apply-templates select="$element" mode="lemma-text-nodes"/>
    </xsl:function>

    <!-- Returns true if the text() node is in the edited text (lemma) -->
    <xsl:function name="seed:text-node-in-text" as="xs:boolean" visibility="public">
        <xsl:param name="context" as="text()"/>
        <!-- An other implementation could use the libtext module. But this would be difficult. -->
        <xsl:variable name="mutet-ancestors" as="node()*">
            <xsl:evaluate as="node()*" context-item="$context" expand-text="true"
                xpath="$app:text-nodes-mutet-ancestors"/>
        </xsl:variable>
        <xsl:sequence select="empty($mutet-ancestors)"/>
    </xsl:function>


    <!-- the mode lemma-text-nodes is for grouping apparatus entries by the text repeated from the base text -->
    <xsl:mode name="lemma-text-nodes" on-no-match="shallow-skip" visibility="public"/>

    <xsl:template mode="lemma-text-nodes" match="text()" as="text()">
        <xsl:sequence select="."/>
    </xsl:template>

    <!-- caesura is replaced with a space. Override this if needed! -->
    <xsl:template mode="lemma-text-nodes" match="caesura" as="text()">
        <xsl:text>&#x20;</xsl:text>
    </xsl:template>

    <!-- things that do not go into the base text -->
    <xsl:template mode="lemma-text-nodes"
        match="rdg | choice[corr]/sic | choice[reg]/orig | span | index | note | witDetail"/>

    <xsl:template mode="lemma-text-nodes"
        match="lem[matches($variant-encoding, '^(in|ex)ternal-double-end-point')]"/>


    <!-- The mode apparatus-reading-text is for printing the text of a reading etc.
        Typically it is entred from a template in the mode apparatus-reading -->
    <xsl:mode name="apparatus-reading-text" on-no-match="shallow-skip" visibility="public"/>

    <xsl:template mode="apparatus-reading-text"
        match="app[$variant-encoding eq 'internal-parallel-segmentation']">
        <xsl:apply-templates mode="apparatus-reading-text" select="lem"/>
    </xsl:template>

    <xsl:template mode="apparatus-reading-text"
        match="app[matches($variant-encoding, '^(in|ex)ternal-double-end-point')]"/>

    <xsl:template mode="apparatus-reading-text" match="choice[sic and corr]">
        <xsl:apply-templates mode="apparatus-reading-text" select="corr"/>
    </xsl:template>

    <xsl:template mode="apparatus-reading-text" match="caesura">
        <xsl:text> || </xsl:text>
    </xsl:template>

    <xsl:template mode="apparatus-reading-text" match="l[preceding-sibling::l]">
        <xsl:text> / </xsl:text>
        <xsl:apply-templates mode="apparatus-reading-text"/>
    </xsl:template>

    <xsl:template mode="apparatus-reading-text" match="text()">
        <xsl:value-of select="."/>
    </xsl:template>



    <!-- Both of the two dispatcher modes should define transformation rules
	 for each type of encoding that appears in the apparatus. -->


    <!-- mode 'lemma-text-nodes-dspt' is a dispatcher for various element types.
        The templates have to select nodes that go into the lemma. Typically they
        apply the rules from 'lemma-text-nodes' on them. -->
    <xsl:mode name="lemma-text-nodes-dspt" on-no-match="shallow-skip" visibility="public"/>

    <!-- The mode apparatus-reading-dspt is for the entries after the lemma (readings, etc.).
        It serves as a dispatcher for different types of entries.
        All templates should leave it again to get the text of the reading etc. -->
    <xsl:mode name="apparatus-reading" on-no-match="shallow-skip" visibility="public"/>


    <!-- app -->

    <xsl:template mode="lemma-text-nodes-dspt"
        match="app[$variant-encoding eq 'internal-parallel-segmentation']">
        <xsl:apply-templates mode="lemma-text-nodes" select="lem"/>
    </xsl:template>

    <xsl:template mode="lemma-text-nodes-dspt"
        match="app[@from and $variant-encoding eq 'internal-double-end-point']">
        <xsl:variable name="limit-id" select="substring(@from, 2)"/>
        <xsl:variable name="limit" select="//*[@xml:id eq $limit-id]"/>
        <xsl:apply-templates mode="lemma-text-nodes"
            select="seed:subtrees-between-anchors($limit, .)"/>
    </xsl:template>

    <xsl:template mode="lemma-text-nodes-dspt"
        match="app[@to and $variant-encoding eq 'internal-double-end-point']">
        <xsl:variable name="limit-id" select="substring(@to, 2)"/>
        <xsl:variable name="limit" select="//*[@xml:id eq $limit-id]"/>
        <xsl:apply-templates mode="lemma-text-nodes"
            select="seed:subtrees-between-anchors(., $limit)"/>
    </xsl:template>

    <xsl:template mode="lemma-text-nodes-dspt"
        match="app[@from and @to and $variant-encoding eq 'external-double-end-point']">
        <xsl:variable name="from-id" select="substring(@from, 2)"/>
        <xsl:variable name="from" select="//*[@xml:id eq $from-id]"/>
        <xsl:variable name="to-id" select="substring(@to, 2)"/>
        <xsl:variable name="to" select="//*[@xml:id eq $to-id]"/>
        <xsl:apply-templates mode="lemma-text-nodes"
            select="seed:subtrees-between-anchors($from, $to)"/>
    </xsl:template>

    <xsl:template mode="lemma-text-nodes-dspt"
        match="app[$variant-encoding eq 'internal-location-referenced']">
        <xsl:apply-templates mode="lemma-text-nodes" select="lem"/>
    </xsl:template>

    <xsl:mode name="apparatus-reading-dspt" on-no-match="shallow-skip" visibility="public"/>

    <xsl:template mode="apparatus-reading-dspt" match="app">
        <xsl:apply-templates mode="apparatus-reading-dspt" select="rdg | witDetail | note"/>
    </xsl:template>

    <xsl:template mode="apparatus-reading-dspt" match="rdg[normalize-space(.) ne '']">
        <span class="reading">
            <!-- we have to evaluate the entry: if the lemma is empty, we need to prepend or append the empty replacement -->
            <xsl:call-template name="app:apparatus-xpend-if-lemma-empty">
                <xsl:with-param name="reading" select="node()"/>
            </xsl:call-template>
            <xsl:if test="@wit">
                <span class="apparatus-sep" style="padding-left: 3px" data-i18n-key="rdg-siglum-sep"
                    >:</span>
                <xsl:call-template name="app:sigla">
                    <xsl:with-param name="wit" select="@wit"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="position() ne last()">
                <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                    >;</span>
            </xsl:if>
        </span>
    </xsl:template>

    <!-- Format sigla from @wit. Potentianally you will override this with your own. -->
    <xsl:template name="app:sigla" visibility="public">
        <xsl:param name="wit" as="node()"/>
        <xsl:for-each select="tokenize($wit)">
            <xsl:if test="position() gt 1">
                <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:value-of select="replace(., '^#', '')"/>
        </xsl:for-each>
    </xsl:template>

    <!-- prepend or append a replacement for an empty lemma to a reading.
        The nodes of the reading must be passed in as parameter -->
    <xsl:template name="app:apparatus-xpend-if-lemma-empty" visibility="public">
        <xsl:param name="reading" as="node()*"/>
        <xsl:param name="apparatus-entry-map" as="map(*)" tunnel="true"/>
        <xsl:variable name="full-lemma" as="xs:string"
            select="map:get($apparatus-entry-map, 'lemma-text-nodes') => app:shorten-lemma()"/>
        <xsl:choose>
            <xsl:when test="$full-lemma ne ''">
                <xsl:apply-templates mode="apparatus-reading-text" select="$reading"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="lemma-replacement"
                    select="map:get($apparatus-entry-map, 'lemma-replacement')"/>
                <xsl:choose>
                    <xsl:when test="map:get($lemma-replacement, 'position') eq 'preceding'">
                        <xsl:value-of select="map:get($lemma-replacement, 'text')"/>
                        <xsl:text> </xsl:text>
                        <xsl:apply-templates mode="apparatus-reading-text" select="$reading"/>
                    </xsl:when>
                    <xsl:when test="map:get($lemma-replacement, 'position') eq 'following'">
                        <xsl:apply-templates mode="apparatus-reading-text" select="$reading"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="map:get($lemma-replacement, 'text')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- in this case we still printed 'empty' in the lemma -->
                        <xsl:apply-templates mode="apparatus-reading-text" select="$reading"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="apparatus-reading-dspt" match="rdg[normalize-space(.) eq '']">
        <span class="reading">
            <span class="static-text" data-i18n-key="omisit">&lre;om.&pdf;</span>
            <xsl:if test="@wit">
                <span class="apparatus-sep" style="padding-left: 3px" data-i18n-key="rdg-siglum-sep"
                    >:</span>
                <xsl:call-template name="app:sigla">
                    <xsl:with-param name="wit" select="@wit"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="position() ne last()">
                <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                    >;</span>
            </xsl:if>
        </span>
    </xsl:template>

    <xsl:template mode="apparatus-reading-dspt" match="app/note">
        <span class="reading reading-note">
            <xsl:apply-templates mode="apparatus-reading-text" select="node()"/>
            <xsl:if test="position() ne last()">
                <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                    >;</span>
            </xsl:if>
        </span>
    </xsl:template>


    <!-- witDetail -->

    <xsl:template mode="lemma-text-nodes-dspt" match="witDetail[not(parent::app)]">
        <xsl:apply-templates mode="lemma-text-nodes" select="parent::*"/>
    </xsl:template>

    <xsl:template mode="apparatus-reading-dspt" match="witDetail">
        <span class="reading note-text witDetail" lang="{i18n:language(.)}"
            style="direction:{i18n:language-direction(.)}; text-align:{i18n:language-align(.)};">
            <xsl:value-of select="i18n:direction-embedding(.)"/>
            <xsl:apply-templates select="node()" mode="apparatus-reading-text"/>
            <xsl:text>&pdf;</xsl:text>
            <xsl:if test="@wit">
                <span class="apparatus-sep" style="padding-left: 3px" data-i18n-key="rdg-siglum-sep"
                    >:</span>
                <xsl:call-template name="app:sigla">
                    <xsl:with-param name="wit" select="@wit"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="position() ne last()">
                <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                    >;</span>
            </xsl:if>
        </span>
    </xsl:template>


    <!-- corr -->

    <xsl:template mode="lemma-text-nodes-dspt" match="corr">
        <xsl:apply-templates mode="lemma-text-nodes"/>
    </xsl:template>

    <xsl:template mode="apparatus-reading-dspt" match="corr">
        <span class="static-text" data-i18n-key="conieci">&lre;coniec.&pdf;</span>
    </xsl:template>


    <!-- sic -->

    <xsl:template mode="lemma-text-nodes-dspt" match="sic[not(parent::choice)]">
        <xsl:apply-templates mode="lemma-text-nodes"/>
    </xsl:template>

    <xsl:template mode="apparatus-reading-dspt" match="sic[not(parent::choice)]">
        <span class="static-text" data-i18n-key="sic">&lre;sic!&pdf;</span>
    </xsl:template>


    <!-- choice -->

    <xsl:template mode="lemma-text-nodes-dspt" match="choice[corr and sic]">
        <xsl:apply-templates mode="lemma-text-nodes" select="corr"/>
    </xsl:template>

    <xsl:template mode="lemma-text-nodes-dspt" match="choice[unclear]">
        <xsl:apply-templates mode="lemma-text-nodes" select="unclear[1]"/>
    </xsl:template>

    <xsl:template mode="lemma-text-nodes-dspt" match="choice[orig and reg]">
        <xsl:apply-templates mode="lemma-text-nodes" select="reg"/>
    </xsl:template>

    <xsl:template mode="apparatus-reading-dspt" match="choice/sic">
        <span class="reading">
            <xsl:apply-templates mode="apparatus-reading-text"/>
            <xsl:if test="@source">
                <span class="apparatus-sep" style="padding-left: 3px" data-i18n-key="rdg-siglum-sep"
                    >:</span>
                <xsl:call-template name="app:sigla">
                    <xsl:with-param name="wit" select="@source"/>
                </xsl:call-template>
            </xsl:if>
        </span>
        <xsl:if test="position() ne last()">
            <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                >;&sp;</span>
        </xsl:if>
    </xsl:template>

    <xsl:template mode="apparatus-reading-dspt" match="choice[corr and sic]">
        <span class="reading">
            <xsl:apply-templates select="corr" mode="apparatus-reading-dspt"/>
            <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep">;</span>
            <xsl:apply-templates select="sic" mode="apparatus-reading-dspt"/>
        </span>
        <xsl:if test="position() ne last()">
            <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                >;&sp;</span>
        </xsl:if>
    </xsl:template>

    <!-- ALEA's old encoding of conjectures -->
    <xsl:template mode="apparatus-reading-dspt" match="choice[corr and sic/app]" priority="2">
        <span class="reading">
            <xsl:apply-templates select="corr" mode="apparatus-reading-dspt"/>
            <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep">;</span>
            <xsl:apply-templates select="sic/app" mode="apparatus-reading-dspt"/>
        </span>
        <xsl:if test="position() ne last()">
            <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep">;</span>
        </xsl:if>
    </xsl:template>


    <!-- unclear -->

    <xsl:template mode="lemma-text-nodes-dspt" match="unclear[not(parent::choice)]">
        <xsl:apply-templates mode="lemma-text-nodes"/>
    </xsl:template>

    <xsl:template mode="apparatus-reading-dspt" match="unclear[not(parent::choice)]">
        <span class="reading unclear">
            <xsl:choose>
                <xsl:when test="@reason">
                    <span class="static-text" data-i18n-key="{@reason}">&lre;<xsl:value-of
                            select="@reason"/>&pdf;</span>
                </xsl:when>
                <xsl:otherwise>
                    <!-- TODO: latin -->
                    <span class="static-text" data-i18n-key="unclear">&lre;unclear&pdf;</span>
                </xsl:otherwise>
            </xsl:choose>
        </span>
        <xsl:if test="position() ne last()">
            <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep">;</span>
        </xsl:if>
    </xsl:template>


    <!-- gap -->

    <!-- handle <gap> as empty, what ever occurs -->
    <xsl:template mode="lemma-text-nodes-dspt" match="gap"/>

    <xsl:template mode="apparatus-reading-dspt" match="gap">
        <span class="reading gap">
            <xsl:choose>
                <xsl:when test="@reason">
                    <span class="static-text" data-i18n-key="{@reason}">&lre;<xsl:value-of
                            select="@reason"/>&pdf;</span>
                </xsl:when>
                <xsl:otherwise>
                    <!-- TODO: latin -->
                    <span class="static-text" data-i18n-key="lost">&lre;lost&pdf;</span>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="@quantity and @unit">
                <span class="apparatus-sep" data-i18n-key="reason-quantity-sep">, </span>
                <span class="static-text">
                    <xsl:value-of select="@quantity"/>
                </span>
                <xsl:text>&#160;</xsl:text>
                <span class="static-text" data-i18n-key="{@unit}">&lre;<xsl:value-of select="@unit"
                    />&pdf;</span>
            </xsl:if>
        </span>
        <xsl:if test="position() ne last()">
            <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep">;</span>
        </xsl:if>
    </xsl:template>



    <!-- default rules -->

    <xsl:template mode="lemma-text-nodes-dspt" match="*">
        <xsl:message>
            <xsl:text>WARNING: </xsl:text>
            <xsl:text>No rule in mode 'lemma-text-nodes-dspt' for apparatus element: </xsl:text>
            <xsl:value-of select="name(.)"/>
        </xsl:message>
        <xsl:apply-templates mode="lemma-text-nodes"/>
    </xsl:template>

    <xsl:template mode="apparatus-reading-dspt" match="*">
        <xsl:message>
            <xsl:text>WARNING: </xsl:text>
            <xsl:text>No rule for in mode 'apparatus-reading-dspt' for apparatur element: </xsl:text>
            <xsl:value-of select="name(.)"/>
        </xsl:message>
        <xsl:apply-templates mode="apparatus-reading-text"/>
    </xsl:template>


</xsl:package>
