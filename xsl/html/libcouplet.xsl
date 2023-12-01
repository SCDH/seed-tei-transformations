<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT pacakge for couplets (verse, hemistichion) edited text (main text) -->
<!DOCTYPE stylesheet [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
    <!ENTITY nbsp "&#xa0;" >
    <!ENTITY emsp "&#x2003;" >
    <!ENTITY lb "&#xa;" >
]>
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libcouplet.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:common="http://scdh.wwu.de/transform/common#"
    xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:text="http://scdh.wwu.de/transform/text#"
    exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0" default-mode="text:text">

    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libcommon.xsl"
        package-version="0.1.0">
        <xsl:accept component="function" names="common:line-number#1" visibility="public"/>
    </xsl:use-package>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libi18n.xsl"
        package-version="0.1.0">
        <xsl:accept component="function" names="i18n:language#1" visibility="private"/>
    </xsl:use-package>

    <xsl:mode name="text:text" visibility="public"/>
    <xsl:mode name="after-caesura" visibility="private"/>
    <xsl:mode name="before-caesura" visibility="private"/>

    <!-- minimal prose features are available through mode text:prose-->
    <xsl:mode name="text:prose" visibility="public"/>


    <!-- Prose -->

    <xsl:template match="div[descendant-or-self::div/p]" mode="#default text:prose">
        <section>
            <xsl:apply-templates mode="text:prose"/>
        </section>
    </xsl:template>

    <xsl:template match="head" mode="text:prose">
        <header>
            <h3>
                <span class="line-number paragraph-number">
                    <xsl:value-of select="common:line-number(.)"/>
                </span>
                <xsl:text> </xsl:text>
                <!-- return to default mode -->
                <xsl:apply-templates/>
            </h3>
        </header>
    </xsl:template>

    <!-- verse embedded in text:prose -->
    <xsl:template match="l" mode="text:prose">
        <p>
            <span class="line-number paragraph-number">
                <xsl:value-of select="common:line-number(.)"/>
            </span>
            <xsl:text> </xsl:text>
            <!-- return to default mode -->
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- this should only be reached from text:prose -->
    <xsl:template match="caesura">
        <xsl:text> || </xsl:text>
    </xsl:template>

    <xsl:template match="p[not(ancestor::note)]" mode="#default text:prose">
        <p>
            <span class="line-number paragraph-number">
                <xsl:value-of select="common:line-number(.)"/>
            </span>
            <xsl:text> </xsl:text>
            <!-- return to default mode -->
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- Verse: This matches a group of verses, i.e. a poem.
        In the output, a table is created. The verse number goes
        into the first column, verses go into the other column(s).
        If there is a caesura (if the verse is a hemistichion)
        there must be left and right text columns. -->
    <xsl:template match="lg">
        <!-- This kind of poem goes into a table of columns -->
        <table>
            <!-- this table has 3 columns: 1: line number,
                2 and 3: hemispheres of a verse or something else with @colspan="2" -->
            <xsl:apply-templates select="*"/>
        </table>
    </xsl:template>

    <!-- nested group of verses, i.e. a stanza -->
    <xsl:template match="lg[parent::lg]">
        <xsl:apply-templates select="*"/>
    </xsl:template>

    <!-- header of a poem -->
    <xsl:template match="head[ancestor::lg]">
        <tr>
            <td class="line-number">
                <xsl:value-of select="common:line-number(.)"/>
            </td>
            <td colspan="2" class="title text-col1">
                <!-- Note: The head should not contain a verse, because that would result in
                    a table row nested in a tabel row. -->
                <xsl:apply-templates/>
                <!-- verse meter (metrum) is printed along with the poems header -->
                <xsl:if test="ancestor::*/@met">
                    <xsl:variable name="met" select="ancestor::*/@met[1]"/>
                    <span class="static-text">
                        <xsl:text> [</xsl:text>
                        <!-- The meters name is pulled from the metDecl
                            in the encodingDesc in the document header -->
                        <xsl:value-of select="/TEI/teiHeader//metSym[@value eq $met]//term[1]"/>
                        <xsl:text>] </xsl:text>
                    </span>
                </xsl:if>
            </td>
        </tr>
    </xsl:template>

    <!-- single verse with caesura: The hemistichion must be split by caesura and distributed
        into text columns.
        Since the caesura may be deeply nested in other elements, we enter a recursive distribution
        of the two hemispheres.
        Implementation note: xsl:for-each-group may seem as an alternative, but isn't well-suited
        for handling nested structures and we only have 2 target groups. -->
    <xsl:template match="l[not(ancestor::head) and descendant::caesura]">
        <tr>
            <td class="line-number">
                <xsl:value-of select="common:line-number(.)"/>
            </td>
            <td class="text-col1">
                <!-- output of nodes that preceed caesura -->
                <xsl:apply-templates
                    select="node() intersect descendant::caesura[not(ancestor::rdg)]/preceding::node() except text:non-lemma-nodes(.)"/>
                <!-- recursively handle nodes, that contain caesura -->
                <xsl:apply-templates select="*[descendant::caesura]" mode="before-caesura"/>
            </td>
            <td>
                <!-- recursively handle nodes, that contain caesura -->
                <xsl:apply-templates select="*[descendant::caesura]" mode="after-caesura"/>
                <!-- output nodes that follow caesura -->
                <xsl:apply-templates
                    select="node() intersect descendant::caesura[not(ancestor::rdg)]/following::node() except text:non-lemma-nodes(.)"
                />
            </td>
        </tr>
    </xsl:template>

    <!-- nodes that contain caesura: recursively output everything preceding caesura -->
    <xsl:template match="*[descendant::caesura]" mode="before-caesura">
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>Entered before-caesura mode: </xsl:text>
            <xsl:value-of select="local-name()"/>
        </xsl:message>
        <!-- output of nodes that preced caesura -->
        <xsl:apply-templates
            select="node() intersect descendant::caesura[not(ancestor::rdg)]/preceding::node() except text:non-lemma-nodes(.)"/>
        <!-- recursively handle nodes, that contain caesura -->
        <xsl:apply-templates select="*[descendant::caesura]" mode="before-caesura"/>
    </xsl:template>

    <!-- nodes that contain caesura: recursively output everything following caesura -->
    <xsl:template match="*[descendant::caesura]" mode="after-caesura">
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>Entered after-caesura mode: </xsl:text>
            <xsl:value-of select="local-name()"/>
        </xsl:message>
        <!-- recursively handle nodes, that contain caesura -->
        <xsl:apply-templates select="*[descendant::caesura]" mode="after-caesura"/>
        <!-- output nodes that follow caesura -->
        <xsl:apply-templates
            select="node() intersect descendant::caesura[not(ancestor::rdg)]/following::node() except text:non-lemma-nodes(.)"
        />
    </xsl:template>

    <!-- When the caesura is not present in the nested node, then output the node only once and warn the user.  -->
    <xsl:template match="*" mode="before-caesura">
        <xsl:message>WARNING: broken document? caesura missing</xsl:message>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="*" mode="after-caesura"/>

    <!-- verse without caesura in lemma: the verse goes into the first text column
        NOTE: This must override the one for simple verses with caesura by setting its priority! -->
    <xsl:template
        match="l[not(ancestor::head) and descendant::caesura[ancestor::rdg] and not(descendant::caesura[ancestor::lem])]"
        priority="1">
        <tr>
            <td class="line-number">
                <xsl:value-of select="common:line-number(.)"/>
            </td>
            <td class="text-col1">
                <!--xsl:apply-templates select="descendant::caesura/preceding-sibling::node()"/-->
                <xsl:apply-templates select="node() except text:non-lemma-nodes(.)"/>
            </td>
            <td/>
        </tr>
    </xsl:template>

    <!-- verse without caesura, but within group of verses: the whole verse spans the two text columns -->
    <xsl:template match="l[not(ancestor::head) and not(descendant::caesura) and ancestor::lg]">
        <tr>
            <td class="apparatus-line-number">
                <xsl:value-of select="common:line-number(.)"/>
            </td>
            <td colspan="2" class="text-col1">
                <xsl:apply-templates select="node() except text:non-lemma-nodes(.)"/>
            </td>
        </tr>
    </xsl:template>

    <!-- verses nested in head -->
    <xsl:template match="l[ancestor::head]">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- all other verses, i.e. verses outside of lg (and not in head) -->
    <xsl:template match="l">
        <p>
            <span class="line-number verse-number">
                <xsl:value-of select="common:line-number(.)"/>
            </span>
            <xsl:text> </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="name[@type]">
        <xsl:variable name="cat" select="@type"/>
        <abbr title="{/TEI/teiHeader/encodingDesc//category[@xml:id eq $cat]/catDesc[1]}">
            <xsl:apply-templates/>
        </abbr>
    </xsl:template>

    <!-- rdg: Do not output reading (variant) in all modes generating edited text. -->
    <xsl:template match="rdg"/>
    <xsl:template match="rdg" mode="before-caesura" priority="2"/>
    <xsl:template match="rdg" mode="after-caesura" priority="2"/>

    <xsl:function name="text:non-lemma-nodes" as="node()*">
        <xsl:param name="element" as="node()"/>
        <xsl:sequence select="$element/descendant-or-self::rdg/descendant-or-self::node()"/>
    </xsl:function>


    <!-- ## inline elements ## -->

    <!--
    <xsl:template match="note">
        <sup><xsl:value-of select="scdh:note-number(.)"/></sup>
    </xsl:template>
    -->

    <xsl:template match="note"/>

    <xsl:template match="witDetail"/>

    <xsl:template match="app">
        <xsl:apply-templates select="lem"/>
    </xsl:template>

    <xsl:template match="lem[//variantEncoding/@medthod ne 'parallel-segmentation']"/>

    <xsl:template
        match="lem[//variantEncoding/@method eq 'parallel-segmentation' and empty(node())]">
        <!-- FIXME: some error here eg. on BBgim8.tei -->
        <!--xsl:text>[!!!]</xsl:text-->
    </xsl:template>

    <xsl:template match="gap">
        <xsl:text>[...]</xsl:text>
    </xsl:template>

    <xsl:template match="space">
        <!--xsl:apply-templates mode="text:hook-before" select="."/-->
        <!-- use hook instead? -->
        <xsl:text>[ — ]</xsl:text>
        <!--xsl:call-template name="text:inline-marks"/-->
        <!--xsl:apply-templates mode="text:hook-after" select="."/-->
    </xsl:template>

    <xsl:template match="unclear">
        <!--xsl:text>[? </xsl:text-->
        <xsl:apply-templates/>
        <!--xsl:text> ?]</xsl:text-->
    </xsl:template>

    <xsl:template match="choice[child::sic and child::corr]">
        <xsl:apply-templates select="corr"/>
    </xsl:template>

    <xsl:template match="choice[child::sic and child::corr]" mode="before-caesura" priority="1">
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>entered choice in before-caesura mode</xsl:text>
        </xsl:message>
        <xsl:apply-templates select="corr" mode="before-caesura"/>
    </xsl:template>

    <xsl:template match="choice[child::sic and child::corr]" mode="after-caesura" priority="1">
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>entered choice in after-caesura mode</xsl:text>
        </xsl:message>
        <xsl:apply-templates select="corr" mode="after-caesura"/>
    </xsl:template>

    <xsl:template match="sic[not(parent::choice)]">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="corr[not(parent::choice)]">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- for segmentation, a prefix or suffix may be needed -->
    <xsl:template match="seg">
        <xsl:call-template name="tag-start-end">
            <xsl:with-param name="node" as="node()" select="."/>
            <xsl:with-param name="type" select="'start'"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="tag-start-end">
            <xsl:with-param name="node" as="node()" select="."/>
            <xsl:with-param name="type" select="'end'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="seg" mode="before-caesura" priority="1">
        <xsl:call-template name="tag-start-end">
            <xsl:with-param name="node" select="."/>
            <xsl:with-param name="type" select="'start'"/>
        </xsl:call-template>
        <!-- output of nodes that preced caesura -->
        <xsl:apply-templates
            select="node() intersect descendant::caesura[not(ancestor::rdg)]/preceding::node() except text:non-lemma-nodes(.)"/>
        <!-- recursively handle nodes, that contain caesura -->
        <xsl:apply-templates select="*[descendant::caesura]" mode="before-caesura"/>
    </xsl:template>

    <xsl:template match="seg" mode="after-caesura" priority="1">
        <!-- recursively handle nodes, that contain caesura -->
        <xsl:apply-templates select="*[descendant::caesura]" mode="after-caesura"/>
        <!-- output nodes that follow caesura -->
        <xsl:apply-templates
            select="node() intersect descendant::caesura/following::node() except text:non-lemma-nodes(.)"/>
        <xsl:call-template name="tag-start-end">
            <xsl:with-param name="node" select="."/>
            <xsl:with-param name="type" select="'end'"/>
        </xsl:call-template>
    </xsl:template>

    <!-- named template for inserting prefixes and suffixes of tagged content -->
    <xsl:template name="tag-start-end">
        <xsl:param name="node" as="node()"/>
        <xsl:param name="type" as="xs:string"/>
        <xsl:choose>
            <!-- ornamented parenthesis around verbatim citation from holy text:
                not in verses (poems) -->
            <xsl:when
                test="not($node/ancestor::l) and name($node) eq 'seg' and $node/@type eq 'verbatim-holy' and matches(i18n:language($node), '^ar') and $type eq 'start'">
                <xsl:text>&#xfd3f;</xsl:text>
            </xsl:when>
            <!-- closing ornamented parenthesis -->
            <xsl:when
                test="not($node/ancestor::l) and name($node) eq 'seg' and $node/@type eq 'verbatim-holy' and matches(i18n:language($node), '^ar') and $type eq 'end'">
                <xsl:text>&#xfd3e;</xsl:text>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

</xsl:package>
