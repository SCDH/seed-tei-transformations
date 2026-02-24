<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT package for edited text (main text)

This package is not intended to be used directly. Use a derived package for the
main text instead, e.g. libprose.xsl for prose or libcouplet.xsl for verses with
caesura. Or derive your own.

This package provides basic components for the main text (edited text), such as
inserting footnote marks that link to the apparatus and comment sections.

To get such footnote marks, you will have to override the variable the template
text:inline-marks.

Note, that there is a default mode in this package.

-->
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libtext.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:text="http://scdh.wwu.de/transform/text#"
    xmlns:common="http://scdh.wwu.de/transform/common#"
    xmlns:source="http://scdh.wwu.de/transform/source#"
    xmlns:wit="http://scdh.wwu.de/transform/wit#" xmlns:app="http://scdh.wwu.de/transform/app#"
    xmlns:compat="http://scdh.wwu.de/transform/compat#" exclude-result-prefixes="#all"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0" default-mode="text:text">

    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <!-- with false (default), there are some specific templates for alternative text in choice -->
    <xsl:param name="compat:first-child" as="xs:boolean" select="false()" static="true"/>

    <!-- whether or not lb elements are evaluated in the HTML -->
    <xsl:param name="text:diplomatic" as="xs:boolean" select="false()" required="false"/>

    <!-- the hyphenation mark to be inserted in <lb> inside a word -->
    <xsl:param name="text:diplomatic-hyphen" as="xs:string" select="'-'" required="false"/>


    <!-- keys cannot be importet via use-package -->
    <xsl:import href="../common/libkeys.xsl"/>

    <!--
        A key for distinguishing text nodes in 'before', 'after' and 'both-ends' delimitation
        by in-word <lb>.
    -->
    <xsl:key name="text-delimited-by-in-word-lb" match="//text()">
        <xsl:variable name="this" as="text()" select="."/>
        <xsl:variable name="lb-before" as="element()?" select="preceding::lb[1][@break eq 'no']"/>
        <xsl:variable name="lb-after" as="element()?" select="following::lb[1][@break eq 'no']"/>
        <!-- make a sequence of values! -->
        <xsl:sequence>
            <xsl:if test="$lb-before">
                <xsl:variable name="text-before" as="node()*"
                    select="$lb-before/following::text() intersect $this/preceding::text()"/>
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>before: </xsl:text>
                    <xsl:value-of select="generate-id(.)"/>
                    <xsl:text> lb: </xsl:text>
                    <xsl:value-of select="generate-id($lb-before)"/>
                    <xsl:text> count of inter text nodes: </xsl:text>
                    <xsl:value-of select="count($text-before)"/>
                    <xsl:text> key value: </xsl:text>
                    <xsl:value-of select="normalize-space(string-join($text-before)) eq ''"/>
                    <xsl:text> content: "</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text>"</xsl:text>
                </xsl:message>
                <xsl:if test="normalize-space(string-join($text-before)) eq ''">before</xsl:if>
            </xsl:if>
            <xsl:if test="$lb-after">
                <xsl:variable name="text-after" as="node()*"
                    select="$this/following::text() intersect $lb-after/preceding::text()"/>
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>after: </xsl:text>
                    <xsl:value-of select="generate-id(.)"/>
                    <xsl:text> lb: </xsl:text>
                    <xsl:value-of select="generate-id($lb-after)"/>
                    <xsl:text> count of inter text nodes: </xsl:text>
                    <xsl:value-of select="count($text-after)"/>
                    <xsl:text> key value: </xsl:text>
                    <xsl:value-of select="normalize-space(string-join($text-after)) eq ''"/>
                    <xsl:text> content: "</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text>"</xsl:text>
                </xsl:message>
                <xsl:if test="normalize-space(string-join($text-after)) eq ''">after</xsl:if>
            </xsl:if>
            <xsl:if test="$lb-after and $lb-before">
                <xsl:variable name="text-before" as="node()*"
                    select="$lb-before/following::text() intersect $this/preceding::text()"/>
                <xsl:variable name="text-after" as="node()*"
                    select="$this/following::text() intersect $lb-after/preceding::text()"/>
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>both-ends: </xsl:text>
                    <xsl:value-of select="generate-id(.)"/>
                    <xsl:text> lb: </xsl:text>
                    <xsl:value-of select="generate-id($lb-before)"/>
                    <xsl:text> count of text nodes before: </xsl:text>
                    <xsl:value-of select="count($text-before)"/>
                    <xsl:text> count of text nodes after: </xsl:text>
                    <xsl:value-of select="count($text-after)"/>
                    <xsl:text> key value set: </xsl:text>
                    <xsl:value-of
                        select="normalize-space(string-join($text-before)) eq '' and normalize-space(string-join($text-after)) eq ''"/>
                    <xsl:text> content: "</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text>"</xsl:text>
                </xsl:message>
                <xsl:if
                    test="normalize-space(string-join($text-before)) eq '' and normalize-space(string-join($text-after)) eq ''"
                    >both-ends</xsl:if>
            </xsl:if>
        </xsl:sequence>
    </xsl:key>


    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libi18n.xsl"
        package-version="0.1.0">
        <xsl:accept component="function" names="i18n:language#1" visibility="private"/>
        <xsl:accept component="function" names="i18n:language-direction#1" visibility="private"/>
        <xsl:accept component="function" names="i18n:language-code-to-direction#1"
            visibility="private"/>
    </xsl:use-package>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libsource.xsl"
        package-version="1.0.0"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libwit.xsl"
        package-version="1.0.0">
        <xsl:accept component="variable" names="wit:witness" visibility="private"/>
    </xsl:use-package>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libcommon.xsl"
        package-version="0.1.0">
        <xsl:accept component="function" names="common:is-block#1" visibility="private"/>
    </xsl:use-package>

    <xsl:mode name="text:hook-before" on-no-match="deep-skip" visibility="public"/>
    <xsl:mode name="text:hook-after" on-no-match="deep-skip" visibility="public"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/librend.xsl"
        package-version="1.0.0">
        <xsl:accept component="mode" names="text:text" visibility="public"/>
        <xsl:accept component="template" names="text:*" visibility="public"/>
        <xsl:accept component="mode" names="app:reading-text" visibility="hidden"/>
        <xsl:override default-mode="text:text">
            <!-- text:hook-before and text:hook-after are modes that offer hooks for
                inserting project-specific things before and after an element -->

            <xsl:template mode="text:text" match="text()">
                <xsl:call-template name="source:text-node"/>
            </xsl:template>

            <!-- diplomatic presentation with linebreaks -->

            <!-- @break='no' means that lb is inside a token and therefore a hyphen must be inserted -->
            <xsl:template match="lb[$text:diplomatic]">
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>text nodes from before key: </xsl:text>
                    <xsl:value-of select="key('text-delimited-by-in-word-lb', 'before') => count()"/>
                    <xsl:text> text nodes from after key: </xsl:text>
                    <xsl:value-of select="key('text-delimited-by-in-word-lb', 'after') => count()"/>
                    <xsl:text> text nodes from double key: </xsl:text>
                    <xsl:value-of
                        select="key('text-delimited-by-in-word-lb', 'both-ends') => count()"/>
                </xsl:message>
                <xsl:if test="@break eq 'no'">
                    <span class="hyphen">
                        <xsl:value-of select="$text:diplomatic-hyphen"/>
                    </span>
                </xsl:if>
                <br/>
                <xsl:text>&#xa;</xsl:text>
                <span class="line-number">
                    <xsl:value-of select="common:line-number(.)"/>
                </span>
            </xsl:template>

            <!-- remove whitespace next to lb -->
            <xsl:template match="key('text-delimited-by-in-word-lb', 'both-ends')" priority="20">
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>cutting whitespace at both ends</xsl:text>
                </xsl:message>
                <xsl:call-template name="source:text-node">
                    <xsl:with-param name="content"
                        select="replace(., '^\s+', '') => replace('\s+$', '')"/>
                </xsl:call-template>
            </xsl:template>

            <xsl:template match="key('text-delimited-by-in-word-lb', 'after')" priority="10">
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>cutting whitespace at end</xsl:text>
                </xsl:message>
                <xsl:call-template name="source:text-node">
                    <xsl:with-param name="content" select="replace(., '\s+$', '')"/>
                </xsl:call-template>
            </xsl:template>

            <xsl:template match="key('text-delimited-by-in-word-lb', 'before')">
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>cutting whitespace a beginning</xsl:text>
                </xsl:message>
                <xsl:call-template name="source:text-node">
                    <xsl:with-param name="content" select="replace(., '^\s+', '')"/>
                </xsl:call-template>
            </xsl:template>



            <!-- parts of the document -->

            <!-- parts that should not be generate output in mode text:text -->
            <xsl:template match="teiHeader"/>

            <xsl:template match="text">
                <div class="text">
                    <xsl:if test="not(@xml:lang)">
                        <!-- assert that the language is set -->
                        <xsl:variable name="lang" select="i18n:language(.)"/>
                        <xsl:attribute name="xml:lang" select="$lang"/>
                        <xsl:attribute name="lang" select="$lang"/>
                        <xsl:attribute name="dir" select="i18n:language-code-to-direction($lang)"/>
                    </xsl:if>
                    <xsl:call-template name="text:class-attribute"/>
                    <xsl:apply-templates select="@* | node()"/>
                </div>
            </xsl:template>

            <xsl:template match="body | front | back">
                <div>
                    <xsl:call-template name="text:class-attribute"/>
                    <xsl:apply-templates select="@* | node()"/>
                </div>
            </xsl:template>


            <!-- markup that has to be invisible in the edited text -->

            <xsl:template match="span/text() | interp/text()"/>

            <xsl:template match="note">
                <xsl:apply-templates mode="text:hook-before" select="."/>
                <xsl:call-template name="text:inline-marks"/>
                <xsl:apply-templates mode="text:hook-after" select="."/>
            </xsl:template>

            <!-- rdg: Do not output reading (variant) in all modes generating edited text. -->
            <xsl:template match="rdg"/>

            <xsl:template match="witDetail"/>

            <xsl:template match="app[//variantEncoding/@location eq 'internal']">
                <xsl:apply-templates mode="text:hook-before" select="."/>
                <xsl:apply-templates select="lem"/>
                <xsl:call-template name="text:inline-marks"/>
                <xsl:apply-templates mode="text:hook-after" select="."/>
            </xsl:template>

            <!--
                insert inline marks for external apparatus
                TODO: other app-targets than anchor elements
            -->
            <xsl:template match="key('external-app-target', 'true')/self::anchor">
                <xsl:variable name="app" as="element(app)"
                    select="key('external-app-entry', @xml:id)"/>
                <xsl:apply-templates mode="text:hook-before" select="$app"/>
                <xsl:call-template name="text:inline-marks">
                    <xsl:with-param name="context" select="$app"/>
                </xsl:call-template>
                <xsl:apply-templates mode="text:hook-after" select="$app"/>
            </xsl:template>

            <xsl:template match="lem[//variantEncoding/@method ne 'parallel-segmentation']"/>

            <xsl:template
                match="lem[//variantEncoding/@method eq 'parallel-segmentation' and empty(node())]">
                <!-- FIXME: some error here eg. on BBgim8.tei -->
                <!--xsl:text>[!!!]</xsl:text-->
            </xsl:template>

            <!-- The first element is presented in the text. So order matters! -->
            <xsl:template match="choice">
                <xsl:apply-templates mode="text:hook-before" select="."/>
                <span class="choice">
                    <xsl:call-template name="text:standard-attributes"/>
                    <xsl:call-template name="text:class-attribute"/>
                    <xsl:apply-templates select="@*"/>
                    <xsl:apply-templates select="*[1]"/>
                </span>
                <xsl:apply-templates mode="text:hook-after" select="."/>
                <xsl:call-template name="text:inline-marks"/>
            </xsl:template>

            <!-- Simple encoding of variation using seg nested in choice -->
            <xsl:template
                match="choice[seg and exists($wit:witness) and (seg/@source ! tokenize(.) ! replace(., '^#', '')) = $wit:witness]">
                <xsl:apply-templates mode="text:hook-before" select="."/>
                <span class="choice">
                    <xsl:call-template name="text:class-attribute"/>
                    <xsl:apply-templates select="@*"/>
                    <xsl:apply-templates
                        select="*[(tokenize(@source) ! replace(., '^#', '')) = $wit:witness]"/>
                </span>
                <xsl:apply-templates mode="text:hook-after" select="."/>
                <xsl:call-template name="text:inline-marks"/>
            </xsl:template>

            <!-- more specific templates for choice if $compat:first-child is false -->
            <!-- the text contains the corrected passage (emendatio) -->
            <xsl:template match="choice[sic and corr]" use-when="not($compat:first-child)">
                <xsl:apply-templates mode="text:hook-before" select="corr"/>
                <span class="corr">
                    <xsl:call-template name="text:class-attribute">
                        <xsl:with-param name="context" select="corr"/>
                    </xsl:call-template>
                    <xsl:apply-templates select="@*, corr/@*"/>
                    <xsl:apply-templates select="corr/node()"/>
                </span>
                <xsl:apply-templates mode="text:hook-after" select="corr"/>
                <xsl:call-template name="text:inline-marks"/>
            </xsl:template>

            <!-- the text contains the regularized passage -->
            <xsl:template match="choice[orig and reg]" use-when="not($compat:first-child)">
                <xsl:apply-templates mode="text:hook-before" select="reg"/>
                <span class="reg">
                    <xsl:call-template name="text:class-attribute">
                        <xsl:with-param name="context" select="reg"/>
                    </xsl:call-template>
                    <xsl:apply-templates select="@*, reg/@*"/>
                    <xsl:apply-templates select="reg/node()"/>
                </span>
                <xsl:apply-templates mode="text:hook-after" select="reg"/>
                <xsl:call-template name="text:inline-marks"/>
            </xsl:template>

            <!-- the text contains the expanded word -->
            <xsl:template match="choice[abbr and expan]" use-when="not($compat:first-child)">
                <xsl:apply-templates mode="text:hook-before" select="expan"/>
                <span class="expan">
                    <xsl:call-template name="text:class-attribute">
                        <xsl:with-param name="context" select="expan"/>
                    </xsl:call-template>
                    <xsl:apply-templates select="@*, expan/@*"/>
                    <xsl:apply-templates select="expan/node()"/>
                </span>
                <xsl:apply-templates mode="text:hook-after" select="expan"/>
                <xsl:call-template name="text:inline-marks"/>
            </xsl:template>

            <!-- a scribal correction with deletion and addition -->
            <xsl:template match="subst[del and add]">
                <xsl:apply-templates mode="text:hook-before" select="add"/>
                <span class="add subst">
                    <xsl:call-template name="text:class-attribute">
                        <xsl:with-param name="context" select="add"/>
                    </xsl:call-template>
                    <xsl:apply-templates select="@*, add/@*"/>
                    <xsl:apply-templates select="add/node()"/>
                </span>
                <xsl:apply-templates mode="text:hook-after" select="add"/>
                <xsl:call-template name="text:inline-marks"/>
            </xsl:template>


            <xsl:template match="gap">
                <xsl:apply-templates mode="text:hook-before" select="."/>
                <!-- use hook instead? -->
                <xsl:text>[...]</xsl:text>
                <xsl:call-template name="text:inline-marks"/>
                <xsl:apply-templates mode="text:hook-after" select="."/>
            </xsl:template>

            <xsl:template match="space">
                <xsl:apply-templates mode="text:hook-before" select="."/>
                <!-- use hook instead? -->
                <xsl:text>[ — ]</xsl:text>
                <xsl:call-template name="text:inline-marks"/>
                <xsl:apply-templates mode="text:hook-after" select="."/>
            </xsl:template>

            <xsl:template match="unclear">
                <xsl:apply-templates mode="text:hook-before" select="."/>
                <span class="unclear">
                    <xsl:call-template name="text:class-attribute"/>
                    <xsl:apply-templates select="@* | node()"/>
                </span>
                <xsl:apply-templates mode="text:hook-after" select="."/>
                <xsl:call-template name="text:inline-marks"/>
            </xsl:template>

            <!-- various (inline) elements that may need an inline mark -->
            <xsl:template
                match="sic | corr | orig | reg | abbr | expan | seg | quote | q | del | add">
                <xsl:apply-templates mode="text:hook-before" select="."/>
                <span class="{name(.)}">
                    <xsl:call-template name="text:class-attribute"/>
                    <xsl:apply-templates select="@* | node()"/>
                </span>
                <xsl:apply-templates mode="text:hook-after" select="."/>
                <xsl:call-template name="text:inline-marks"/>
            </xsl:template>



            <xsl:template match="supplied[not(parent::choice)]">
                <xsl:apply-templates mode="text:hook-before" select="."/>
                <span class="supplied">
                    <xsl:call-template name="text:class-attribute"/>
                    <xsl:apply-templates select="@* | node()"/>
                </span>
                <xsl:apply-templates mode="text:hook-after" select="."/>
                <xsl:call-template name="text:inline-marks"/>
            </xsl:template>

            <!-- keep first alternant in document order -->
            <xsl:template match="key('first-alternant', 'true')">
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>first alternative text in </xsl:text>
                    <xsl:value-of select="name(.)"/>
                    <xsl:text> with ID </xsl:text>
                    <xsl:value-of select="@xml:id"/>
                    <xsl:text> alternants: </xsl:text>
                    <xsl:value-of select="key('alt-excl', @xml:id)/@target"/>
                </xsl:message>
                <xsl:choose>
                    <xsl:when test="local-name(.) = ('p', 'ab')">
                        <p>
                            <xsl:call-template name="text:class-attribute"/>
                            <xsl:apply-templates select="@*"/>
                            <xsl:apply-templates mode="text:hook-before" select="."/>
                            <xsl:apply-templates select="node()"/>
                            <xsl:apply-templates mode="text:hook-after" select="."/>
                            <xsl:call-template name="text:inline-marks">
                                <xsl:with-param name="context" as="element()"
                                    select="key('alt-excl', @xml:id)"/>
                            </xsl:call-template>
                        </p>
                    </xsl:when>
                    <xsl:when test="common:is-block(.)">
                        <div>
                            <xsl:call-template name="text:class-attribute"/>
                            <xsl:apply-templates select="@*"/>
                            <xsl:apply-templates mode="text:hook-before" select="."/>
                            <xsl:apply-templates select="node()"/>
                            <xsl:apply-templates mode="text:hook-after" select="."/>
                            <xsl:call-template name="text:inline-marks">
                                <xsl:with-param name="context" as="element()"
                                    select="key('alt-excl', @xml:id)"/>
                            </xsl:call-template>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="text:hook-before" select="."/>
                        <span>
                            <xsl:call-template name="text:class-attribute"/>
                            <xsl:apply-templates select="@* | node()"/>
                        </span>
                        <xsl:apply-templates mode="text:hook-after" select="."/>
                        <xsl:call-template name="text:inline-marks">
                            <xsl:with-param name="context" as="element()"
                                select="key('alt-excl', @xml:id)"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:template>

            <!-- drop subsequent alternants in document order -->
            <xsl:template match="key('first-alternant', 'false')">
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>dropping subsequent alternative text in </xsl:text>
                    <xsl:value-of select="name(.)"/>
                    <xsl:text> with ID </xsl:text>
                    <xsl:value-of select="@xml:id"/>
                    <xsl:text> alternants: </xsl:text>
                    <xsl:value-of select="key('alt-excl', @xml:id)/@target"/>
                </xsl:message>
            </xsl:template>


            <xsl:template match="@xml:id">
                <xsl:attribute name="id" select="."/>
            </xsl:template>

            <xsl:template match="@xml:lang">
                <xsl:attribute name="xml:lang" select="."/>
                <xsl:attribute name="lang" select="."/>
                <xsl:attribute name="dir" select="i18n:language-direction(.)"/>
            </xsl:template>

            <xsl:template match="@n">
                <xsl:attribute name="data-tei-n" select="."/>
            </xsl:template>

            <xsl:template match="@type">
                <xsl:attribute name="data-tei-type" select="."/>
            </xsl:template>

            <xsl:template match="@source">
                <xsl:attribute name="data-tei-source" select="."/>
            </xsl:template>

        </xsl:override>
    </xsl:use-package>


    <xsl:function name="text:non-lemma-nodes" as="node()*">
        <xsl:param name="element" as="node()"/>
        <xsl:sequence select="$element/descendant-or-self::rdg/descendant-or-self::node()"/>
    </xsl:function>

    <xsl:template name="text:tag-start" visibility="public"/>

    <xsl:template name="text:tag-end" visibility="public"/>

    <xsl:template name="text:standard-attributes" visibility="private">
        <xsl:if test="@xml:id">
            <xsl:attribute name="id" select="@xml:id"/>
        </xsl:if>
        <xsl:if test="@xml:lang">
            <xsl:attribute name="lang" select="@xml:lang"/>
            <xsl:attribute name="xml:lang" select="@xml:lang"/>
        </xsl:if>
    </xsl:template>

    <!-- you probably want to override this for adding footnote marks etc. to the text -->
    <xsl:template name="text:inline-marks" visibility="public">
        <xsl:param name="context" as="element()" required="false" select="."/>
    </xsl:template>


</xsl:package>
