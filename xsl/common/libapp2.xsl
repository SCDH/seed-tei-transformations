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
- the function app:apparatus-entries#3 to generate a map of apparatus entries and pass this map to
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
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libapp2.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:app="http://scdh.wwu.de/transform/app#" xmlns:seed="http://scdh.wwu.de/transform/seed#"
    xmlns:common="http://scdh.wwu.de/transform/common#"
    xmlns:wit="http://scdh.wwu.de/transform/wit#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    version="3.1">

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libbetween.xsl"
        package-version="1.0.0"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libcommon.xsl"
        package-version="0.1.0"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libentry2.xsl"
        package-version="1.0.0">
        <xsl:accept component="function" names="seed:mk-entry-map#4" visibility="final"/>
        <xsl:accept component="mode" names="seed:lemma-text-nodes" visibility="public"/>
        <xsl:accept component="function" names="seed:shorten-lemma#1" visibility="public"/>
    </xsl:use-package>

    <xsl:expose component="mode" names="*" visibility="public"/>
    <xsl:expose component="template" names="app:*" visibility="public"/>
    <xsl:expose component="variable" names="app:*" visibility="public"/>
    <xsl:expose component="function" names="app:*" visibility="public"/>


    <!--
        Variables that determine, what shows up in the apparatus, by describing
        apparatus entries with XPath expressions.

        You may want to override them in order to put more or less on the apparatus.

        Please note that you can bypass them e.g. when you want multiple apparatus.
    -->

    <!-- apparatus entries made for parallel segementation -->
    <xsl:variable name="app:entries-xpath-internal-parallel-segmentation" as="xs:string"
        visibility="public">
        <xsl:value-of>
            <xsl:text>descendant::app[not(parent::sic[parent::choice])]</xsl:text>
            <xsl:text>| descendant::witDetail[not(parent::app)]</xsl:text>
            <xsl:text>| descendant::corr[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::choice[sic and corr]</xsl:text>
            <xsl:text>| descendant::unclear[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::choice[unclear]</xsl:text>
            <xsl:text>| descendant::gap[not(parent::rdg)]</xsl:text>
            <xsl:text>| descendant::space[not(parent::rdg)]</xsl:text>
            <xsl:text>| descendant::supplied</xsl:text>
        </xsl:value-of>
    </xsl:variable>

    <!-- XPath describing apparatus entries made for internal double end-point variant encoding -->
    <xsl:variable name="app:entries-xpath-internal-double-end-point" as="xs:string"
        visibility="public">
        <xsl:value-of>
            <xsl:text>descendant::app[not(parent::sic[parent::choice]) and not(@from eq '#' or @to eq '#')]</xsl:text>
            <xsl:text>| descendant::witDetail[not(parent::app)]</xsl:text>
            <xsl:text>| descendant::corr[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::choice[sic and corr]</xsl:text>
            <xsl:text>| descendant::unclear[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::choice[unclear]</xsl:text>
            <xsl:text>| descendant::gap[not(parent::rdg)]</xsl:text>
            <xsl:text>| descendant::space[not(parent::rdg)]</xsl:text>
            <xsl:text>| descendant::supplied</xsl:text>
        </xsl:value-of>
    </xsl:variable>

    <!-- XPath describing apparatus entries made for external double end-point variant encoding -->
    <xsl:variable name="app:entries-xpath-external-double-end-point" as="xs:string"
        visibility="public">
        <xsl:value-of>
            <xsl:text>descendant::app</xsl:text>
            <xsl:text>| descendant::witDetail[not(parent::app)]</xsl:text>
            <xsl:text>| descendant::corr[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::choice[sic and corr]</xsl:text>
            <xsl:text>| descendant::unclear[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::choice[unclear]</xsl:text>
            <xsl:text>| descendant::gap[not(parent::rdg)]</xsl:text>
            <xsl:text>| descendant::space[not(parent::rdg)]</xsl:text>
            <xsl:text>| descendant::supplied</xsl:text>
        </xsl:value-of>
    </xsl:variable>

    <!-- apparatus entries made for location referenced -->
    <xsl:variable name="app:entries-xpath-internal-location-referenced" as="xs:string"
        visibility="public">
        <xsl:value-of>
            <xsl:text>descendant::app[not(parent::sic[parent::choice])]</xsl:text>
            <xsl:text>| descendant::witDetail[not(parent::app)]</xsl:text>
            <xsl:text>| descendant::corr[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::choice[sic and corr]</xsl:text>
            <xsl:text>| descendant::unclear[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::choice[unclear]</xsl:text>
            <xsl:text>| descendant::gap[not(parent::rdg)]</xsl:text>
            <xsl:text>| descendant::space[not(parent::rdg)]</xsl:text>
            <xsl:text>| descendant::supplied</xsl:text>
        </xsl:value-of>
    </xsl:variable>


    <!-- when no variant encoding is present -->
    <xsl:variable name="app:entries-xpath-no-textcrit" as="xs:string" visibility="public">
        <xsl:value-of>
            <xsl:text>descendant::corr[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::choice[sic and corr]</xsl:text>
            <xsl:text>| descendant::unclear[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::choice[unclear]</xsl:text>
            <xsl:text>| descendant::gap</xsl:text>
            <xsl:text>| descendant::space</xsl:text>
            <xsl:text>| descendant::supplied</xsl:text>
        </xsl:value-of>
    </xsl:variable>


    <!-- for convenience this will be '@location-@method' -->
    <xsl:function name="app:variant-encoding" visibility="public">
        <xsl:param name="context" as="node()"/>
        <xsl:variable name="ve" select="root($context)//teiHeader/encodingDesc/variantEncoding"/>
        <xsl:value-of select="concat($ve/@location, '-', $ve/@method)"/>
    </xsl:function>




    <!-- convenience functions and templates for generating the apparatus with the XPaths from the parameters above. -->

    <!-- generate apparatus elements for a given context, e.g. / and prepare mappings for them.
        This implementation uses the XPaths defined above to generate the sequence of apparatus entries.
    -->
    <xsl:function name="app:apparatus-entries" as="map(*)*" visibility="public">
        <xsl:param name="context" as="node()*"/>
        <!-- select the right XPath for generating apparatus entries -->
        <!-- since $context may be a sequence, we only take the first item to get the variant encoding -->
        <xsl:variable name="variant-encoding" select="app:variant-encoding($context[1])"/>
        <xsl:variable name="app-entries-xpath">
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
                <xsl:when test="$variant-encoding eq 'internal-location-referenced'">
                    <xsl:value-of select="$app:entries-xpath-internal-location-referenced"/>
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
        <!-- we first generate a sequence of all elements that should show up in the apparatus -->
        <xsl:sequence as="map(*)*" select="app:apparatus-entries($context, $app-entries-xpath, 1)"/>
    </xsl:function>

    <!-- generate a line-based apparatus for a given context, e.g. / -->
    <xsl:template name="app:line-based-apparatus-for-context" visibility="public">
        <xsl:param name="app-context" as="node()*"/>
        <xsl:call-template name="app:line-based-apparatus">
            <xsl:with-param name="entries" select="app:apparatus-entries($app-context)"/>
        </xsl:call-template>
    </xsl:template>

    <!-- generate a note-based apparatus for a given context, e.g. / -->
    <xsl:template name="app:note-based-apparatus-for-context" visibility="public">
        <xsl:param name="app-context" as="node()*"/>
        <xsl:call-template name="app:note-based-apparatus">
            <xsl:with-param name="entries" select="app:apparatus-entries($app-context)"/>
        </xsl:call-template>
    </xsl:template>



    <!--
        Generic implementation of the apparatus.
        The XPath expressions from above are not hard-wired anywhere below.
    -->


    <!-- Generate apparatus elements for a given context, e.g. / and prepare mappings for them.
        The second argument is an XPath expression that tells what elements should go into the apparatus.
        It is evaluated in the context given by the parameter 'context'.
        The third parameter is a grouping key for multiple apparatuses. Pass a constant of 1 if you want
        yust one critical apparatus.
    -->
    <xsl:function name="app:apparatus-entries" as="map(*)*" visibility="public">
        <xsl:param name="context" as="node()*"/>
        <xsl:param name="app-entries-xpath" as="xs:string"/>
        <xsl:param name="type" as="xs:integer"/>
        <!-- we first generate a sequence of all elements that should show up in the apparatus -->
        <xsl:variable name="entry-elements" as="element()*">
            <xsl:choose>
                <xsl:when test="count($context) eq 1">
                    <xsl:evaluate as="element()*" context-item="$context" expand-text="true"
                        xpath="$app-entries-xpath"/>
                </xsl:when>
                <xsl:when test="empty($context)">
                    <xsl:sequence select="()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="$context">
                        <xsl:evaluate as="element()*" context-item="." expand-text="true"
                            xpath="$app-entries-xpath"/>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>Elements for apparatus: </xsl:text>
            <xsl:value-of select="$entry-elements ! name()"/>
        </xsl:message>
        <xsl:sequence as="map(*)*"
            select="$entry-elements ! seed:mk-entry-map(., position(), $type)"/>
    </xsl:function>

    <!-- generate a line-based apparatus for a sequence of prepared maps -->
    <xsl:template name="app:line-based-apparatus" visibility="abstract">
        <xsl:param name="entries" as="map(*)*"/>
    </xsl:template>

    <!-- generate a line-based apparatus as grid layout for a sequence of prepared maps -->
    <xsl:template name="app:line-based-apparatus-block" visibility="abstract">
        <xsl:param name="entries" as="map(*)*"/>
    </xsl:template>

    <!-- generate a note-based apparatus for a sequence of prepared maps -->
    <xsl:template name="app:note-based-apparatus" visibility="abstract">
        <xsl:param name="entries" as="map(xs:string, map(*))"/>
    </xsl:template>

    <!-- generate inline footnote marks. Hook this to text:inline-marks -->
    <xsl:template name="app:footnote-marks" visibility="abstract">
        <xsl:param name="entries" as="map(xs:string, map(*))"/>
    </xsl:template>

    <!-- generate inline alternatives. Hook this to text:inline-marks -->
    <xsl:template name="app:inline-alternatives" visibility="abstract">
        <xsl:param name="entries" as="map(xs:string, map(*))"/>
    </xsl:template>


    <!-- the template for an entry -->
    <xsl:template name="app:apparatus-entry" visibility="abstract"/>

    <!-- template for making the lemma text with some logic for handling empty lemmas -->
    <xsl:template name="app:apparatus-lemma" visibility="abstract"/>

    <!--
        This generates a map (object) for an apparatus entry
        with all there is needed for grouping and creating the entry.

        This funtion will call templates to get all non-whitespace
        text nodes from the main (edited) text, on which the entry
        is about. It than passes over to seed:mk-entry-map#4.

        parameters:
        @entry: the apparatus element
        @number: the footnote number of the apparatus element
        @type: the type of the apparatus, e.g. 1 for critical apparatus, 2 for editorial comments
    -->
    <xsl:function name="seed:mk-entry-map" as="map(*)" visibility="public">
        <xsl:param name="entry" as="element()"/>
        <xsl:param name="number" as="xs:integer"/>
        <xsl:param name="type" as="xs:integer"/>
        <xsl:variable name="lemma-text-nodes" as="text()*">
            <xsl:apply-templates select="$entry" mode="app:lemma-text-nodes-dspt"/>
        </xsl:variable>
        <xsl:sequence select="seed:mk-entry-map($entry, $number, $type, $lemma-text-nodes)"/>
    </xsl:function>


    <!-- The mode apparatus-reading-text is for printing the text of a reading etc.
        Typically it is entred from a template in the mode apparatus-reading -->
    <!--xsl:mode name="app:reading-text" on-no-match="shallow-skip" visibility="public"/-->

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/librend.xsl"
        package-version="1.0.0">
        <xsl:accept component="mode" names="app:reading-text" visibility="public"/>
        <xsl:override>
            <xsl:template mode="app:reading-text"
                match="app[app:variant-encoding(.) eq 'internal-parallel-segmentation']">
                <xsl:apply-templates mode="app:reading-text" select="lem"/>
            </xsl:template>

            <xsl:template mode="app:reading-text"
                match="app[matches(app:variant-encoding(.), '^(in|ex)ternal-double-end-point')]"/>

            <xsl:template mode="app:reading-text" match="choice[sic and corr]">
                <xsl:apply-templates mode="app:reading-text" select="corr"/>
            </xsl:template>

            <xsl:template mode="app:reading-text" match="gap[parent::rdg]">
                <xsl:text>[...]</xsl:text>
            </xsl:template>

            <xsl:template mode="app:reading-text" match="caesura">
                <xsl:text> || </xsl:text>
            </xsl:template>

            <xsl:template mode="app:reading-text" match="l[preceding-sibling::l]">
                <xsl:text> / </xsl:text>
                <xsl:apply-templates mode="app:reading-text"/>
            </xsl:template>

            <xsl:template mode="app:reading-text" match="text()">
                <xsl:value-of select="."/>
            </xsl:template>
        </xsl:override>
    </xsl:use-package>


    <!-- Both of the two dispatcher modes should define transformation rules
	 for each type of encoding that appears in the apparatus. -->


    <!-- mode 'lemma-text-nodes-dspt' is a dispatcher for various element types.
        The templates have to select nodes that go into the lemma. Typically they
        apply the rules from 'lemma-text-nodes' on them. -->
    <xsl:mode name="app:lemma-text-nodes-dspt" on-no-match="shallow-skip" visibility="public"/>

    <!-- The mode apparatus-reading-dspt is for the entries after the lemma (readings, etc.).
        It serves as a dispatcher for different types of entries.
        All templates should leave it again to get the text of the reading etc. -->
    <xsl:mode name="app:reading" on-no-match="shallow-skip" visibility="public"/>


    <!-- app -->

    <xsl:template mode="app:lemma-text-nodes-dspt"
        match="app[app:variant-encoding(.) eq 'internal-parallel-segmentation']">
        <xsl:apply-templates mode="seed:lemma-text-nodes" select="lem"/>
    </xsl:template>

    <xsl:template mode="app:lemma-text-nodes-dspt"
        match="app[@from and app:variant-encoding(.) eq 'internal-double-end-point']">
        <xsl:variable name="limit-id" select="substring(@from, 2)"/>
        <xsl:variable name="limit" select="//*[@xml:id eq $limit-id]"/>
        <xsl:apply-templates mode="seed:lemma-text-nodes"
            select="seed:subtrees-between-anchors($limit, .)"/>
    </xsl:template>

    <xsl:template mode="app:lemma-text-nodes-dspt"
        match="app[@to and app:variant-encoding(.) eq 'internal-double-end-point']">
        <xsl:variable name="limit-id" select="substring(@to, 2)"/>
        <xsl:variable name="limit" select="//*[@xml:id eq $limit-id]"/>
        <xsl:apply-templates mode="seed:lemma-text-nodes"
            select="seed:subtrees-between-anchors(., $limit)"/>
    </xsl:template>

    <xsl:template mode="app:lemma-text-nodes-dspt"
        match="app[@from and @to and app:variant-encoding(.) eq 'external-double-end-point']">
        <xsl:variable name="from-id" select="substring(@from, 2)"/>
        <xsl:variable name="from" select="//*[@xml:id eq $from-id]"/>
        <xsl:variable name="to-id" select="substring(@to, 2)"/>
        <xsl:variable name="to" select="//*[@xml:id eq $to-id]"/>
        <xsl:apply-templates mode="seed:lemma-text-nodes"
            select="seed:subtrees-between-anchors($from, $to)"/>
    </xsl:template>

    <xsl:template mode="app:lemma-text-nodes-dspt"
        match="app[app:variant-encoding(.) eq 'internal-location-referenced']">
        <xsl:apply-templates mode="seed:lemma-text-nodes" select="lem"/>
    </xsl:template>


    <!-- entry nested in span with @from -->
    <xsl:template mode="app:lemma-text-nodes-dspt" match="span[@from and not(@to)]/*" priority="2">
        <xsl:variable name="from-id" select="substring(parent::span/@from, 2)"/>
        <xsl:variable name="from" select="//*[@xml:id eq $from-id]"/>
        <xsl:variable name="to" select="parent::span"/>
        <xsl:apply-templates mode="seed:lemma-text-nodes"
            select="seed:subtrees-between-anchors($from, $to)"/>
    </xsl:template>

    <!-- entry nested in span with @to -->
    <xsl:template mode="app:lemma-text-nodes-dspt" match="span[not(@from) and @to]/*" priority="2">
        <xsl:variable name="from" select="parent::span"/>
        <xsl:variable name="to-id" select="substring(parent::span/@to, 2)"/>
        <xsl:variable name="to" select="//*[@xml:id eq $to-id]"/>
        <xsl:apply-templates mode="seed:lemma-text-nodes"
            select="seed:subtrees-between-anchors($from, $to)"/>
    </xsl:template>

    <!-- entry nested in span with @from and @to -->
    <xsl:template mode="app:lemma-text-nodes-dspt" match="span[@from and @to]/*" priority="2">
        <xsl:variable name="from-id" select="substring(parent::span/@from, 2)"/>
        <xsl:variable name="from" select="//*[@xml:id eq $from-id]"/>
        <xsl:variable name="to-id" select="substring(parent::span/@to, 2)"/>
        <xsl:variable name="to" select="//*[@xml:id eq $to-id]"/>
        <xsl:apply-templates mode="seed:lemma-text-nodes"
            select="seed:subtrees-between-anchors($from, $to)"/>
    </xsl:template>


    <!-- for <note>: if there is no @targetEnd, the referring passage is the whole parent element -->
    <xsl:template mode="app:lemma-text-nodes-dspt"
        match="note[not(@targetEnd)] | noteGrp[not(@targetEnd)]">
        <xsl:apply-templates mode="seed:lemma-text-nodes" select="parent::*"/>
    </xsl:template>

    <!-- note with @targetEnd -->
    <xsl:template mode="app:lemma-text-nodes-dspt" match="note[@targetEnd] | noteGrp[@targetEnd]">
        <xsl:variable name="targetEnd" as="xs:string" select="substring(@targetEnd, 2)"/>
        <xsl:variable name="target-end-node" as="node()" select="//*[@xml:id eq $targetEnd]"/>
        <xsl:choose>
            <xsl:when test="empty($target-end-node)">
                <xsl:message>
                    <xsl:text>No anchor for message with @targetEnd: </xsl:text>
                    <xsl:value-of select="$targetEnd"/>
                </xsl:message>
            </xsl:when>
            <xsl:when test="following-sibling::*[@xml:id eq $targetEnd]">
                <xsl:apply-templates mode="seed:lemma-text-nodes"
                    select="seed:subtrees-between-anchors(., $target-end-node)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="seed:lemma-text-nodes"
                    select="seed:subtrees-between-anchors($target-end-node, .)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:mode name="app:reading-dspt" on-no-match="shallow-skip" visibility="public"/>

    <xsl:template mode="app:reading-dspt" match="app">
        <xsl:apply-templates mode="app:reading-dspt" select="rdg | witDetail | note">
            <xsl:sort>
                <xsl:choose>
                    <xsl:when test="@wit">
                        <xsl:sequence select="app:entry-sortkey-from-wit(@wit)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="app:entry-sortkey(.)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:sort>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:function name="app:entry-sortkey-from-wit" as="item()" visibility="public">
        <xsl:param name="wit" as="attribute(wit)"/>
        <xsl:sequence select="100"/>
    </xsl:function>

    <xsl:function name="app:entry-sortkey" as="item()" visibility="public">
        <xsl:param name="wit" as="element()"/>
        <xsl:sequence select="100"/>
    </xsl:function>

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
            select="map:get($apparatus-entry-map, 'lemma-text-nodes') => seed:shorten-lemma()"/>
        <xsl:choose>
            <xsl:when test="$full-lemma ne ''">
                <xsl:apply-templates mode="app:reading-text" select="$reading"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="lemma-replacement"
                    select="map:get($apparatus-entry-map, 'lemma-replacement')"/>
                <xsl:choose>
                    <xsl:when test="map:get($lemma-replacement, 'position') eq 'preceding'">
                        <xsl:value-of select="map:get($lemma-replacement, 'text')"/>
                        <xsl:text> </xsl:text>
                        <xsl:apply-templates mode="app:reading-text" select="$reading"/>
                    </xsl:when>
                    <xsl:when test="map:get($lemma-replacement, 'position') eq 'following'">
                        <xsl:apply-templates mode="app:reading-text" select="$reading"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="map:get($lemma-replacement, 'text')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- in this case we still printed 'empty' in the lemma -->
                        <xsl:apply-templates mode="app:reading-text" select="$reading"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- witDetail -->

    <xsl:template mode="app:lemma-text-nodes-dspt" match="witDetail[not(parent::app)]">
        <xsl:apply-templates mode="seed:lemma-text-nodes" select="parent::*"/>
    </xsl:template>


    <!-- corr -->

    <xsl:template mode="app:lemma-text-nodes-dspt" match="corr">
        <xsl:apply-templates mode="seed:lemma-text-nodes"/>
    </xsl:template>


    <!-- sic -->

    <xsl:template mode="app:lemma-text-nodes-dspt" match="sic[not(parent::choice)]">
        <xsl:apply-templates mode="seed:lemma-text-nodes"/>
    </xsl:template>


    <!-- choice -->

    <xsl:template mode="app:lemma-text-nodes-dspt" match="choice[corr and sic]">
        <xsl:apply-templates mode="seed:lemma-text-nodes" select="corr"/>
    </xsl:template>

    <xsl:template mode="app:lemma-text-nodes-dspt" match="choice[unclear]">
        <xsl:apply-templates mode="seed:lemma-text-nodes" select="unclear[1]"/>
    </xsl:template>

    <xsl:template mode="app:lemma-text-nodes-dspt" match="choice[orig and reg]">
        <xsl:apply-templates mode="seed:lemma-text-nodes" select="reg"/>
    </xsl:template>


    <!-- unclear -->

    <xsl:template mode="app:lemma-text-nodes-dspt" match="unclear[not(parent::choice)]">
        <xsl:apply-templates mode="seed:lemma-text-nodes"/>
    </xsl:template>


    <!-- gap -->

    <!-- handle <gap> as empty, what ever occurs -->
    <xsl:template mode="app:lemma-text-nodes-dspt" match="gap"/>

    <!-- space -->

    <xsl:template mode="app:lemma-text-nodes-dspt" match="space">
        <!--xsl:apply-templates mode="app:lemma-text-nodes-dspt"/-->
        <xsl:text>—</xsl:text>
    </xsl:template>


    <!-- supplied -->

    <xsl:template mode="app:lemma-text-nodes-dspt" match="supplied[not(parent::choice)]">
        <xsl:apply-templates mode="seed:lemma-text-nodes"/>
    </xsl:template>


    <!-- default rules -->

    <xsl:template mode="app:lemma-text-nodes-dspt" match="*">
        <xsl:message>
            <xsl:text>WARNING: </xsl:text>
            <xsl:text>No rule in mode 'lemma-text-nodes-dspt' for apparatus element: </xsl:text>
            <xsl:value-of select="name(.)"/>
        </xsl:message>
        <xsl:apply-templates mode="seed:lemma-text-nodes"/>
    </xsl:template>

    <xsl:template mode="app:reading-dspt" match="*">
        <xsl:message>
            <xsl:text>WARNING: </xsl:text>
            <xsl:text>No rule for in mode 'apparatus-reading-dspt' for apparatur element: </xsl:text>
            <xsl:value-of select="name(.)"/>
        </xsl:message>
        <xsl:apply-templates mode="app:reading-text"/>
    </xsl:template>


    <!-- hooks before and after the reading text -->
    <xsl:mode name="app:pre-reading-text" on-no-match="deep-skip" visibility="public"/>
    <xsl:mode name="app:post-reading-text" on-no-match="deep-skip" visibility="public"/>


    <!-- The mode app:reading-annotation is for adding (automatically generated) notes to an apparatus entry,
        e.g. when <unclear> or <gap> is nested in an apparatus entry, we may want to add information from the
        @reason attribute to the entry. -->
    <xsl:mode name="app:reading-annotation" on-no-match="deep-skip" visibility="public"/>


    <!-- A named template that serves as encapsulation for generating reading annotations.
        It interleaves several annotations generated by calling the templates from mode app:reading-annotation
        with a separator. If the parameter $separator is true(), then the result will have a leading separator.
    -->
    <xsl:template name="app:reading-annotation" visibility="abstract">
        <xsl:context-item as="element()" use="required"/>
        <xsl:param name="separator" as="xs:boolean" select="false()"/>
    </xsl:template>


</xsl:package>
