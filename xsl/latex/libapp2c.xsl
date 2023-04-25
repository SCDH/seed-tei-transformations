<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE package [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
    <!ENTITY sp "&#x20;" >
    <!ENTITY nbsp "&#xa0;" >
    <!ENTITY emsp "&#x2003;" >
    <!ENTITY lb "&#xa;" >
]>
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libapp2.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:app="http://scdh.wwu.de/transform/app#"
    xmlns:seed="http://scdh.wwu.de/transform/seed#"
    xmlns:common="http://scdh.wwu.de/transform/common#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    version="3.1">

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libi18n.xsl"
        package-version="1.0.0">
        <xsl:accept component="function"
            names="i18n:language#1 i18n:language-direction#1 i18n:language-align#1 i18n:direction-embedding#1"
            visibility="private"/>
        <xsl:accept component="variable" names="i18n:default-language" visibility="abstract"/>
    </xsl:use-package>

    <!-- override this with a map when you need footnote signs to apparatus entries. See seed:note-based-apparatus-nodes-map#2 -->
    <xsl:variable name="app:apparatus-entries" as="map(xs:string, map(*))" select="map {}"
        visibility="public"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libapp2.xsl"
        package-version="1.0.0">

        <xsl:accept component="mode" names="app:*" visibility="public"/>
        <xsl:accept component="template" names="app:*" visibility="public"/>
        <xsl:accept component="variable" names="app:*" visibility="public"/>
        <xsl:accept component="function" names="app:*" visibility="public"/>
        <xsl:accept component="function" names="seed:shorten-lemma#1" visibility="public"/>
        <xsl:accept component="mode" names="seed:lemma-text-nodes" visibility="public"/>

        <xsl:override>

            <!-- generate a line-based apparatus for a sequence of prepared maps -->
            <xsl:template name="app:line-based-apparatus" visibility="public">
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

            <!-- generate a note-based apparatus for a sequence of prepared maps -->
            <xsl:template name="app:note-based-apparatus" visibility="public">
                <xsl:param name="entries" as="map(*)*"/>
                <div>
                    <xsl:for-each-group select="$entries"
                        group-by="map:get(., 'lemma-grouping-ids')">
                        <xsl:message use-when="system-property('debug') eq 'true'">
                            <xsl:text>Joining </xsl:text>
                            <xsl:value-of select="count(current-group())"/>
                            <xsl:text> apparatus entries referencing text nodes </xsl:text>
                            <xsl:value-of select="current-grouping-key()"/>
                        </xsl:message>
                        <div class="apparatus-line">
                            <span class="apparatus-note-number note-number">

                                <xsl:variable name="entry" select="current-group()[1]"/>
                                <a name="{map:get($entry, 'entry-id')}"
                                    href="#text-{map:get($entry, 'entry-id')}">
                                    <xsl:value-of select="map:get($entry, 'number')"/>
                                </a>
                            </span>
                            <!-- call the template that outputs an apparatus entries -->
                            <xsl:call-template name="app:apparatus-entry">
                                <xsl:with-param name="entries" select="current-group()"/>
                            </xsl:call-template>
                        </div>
                    </xsl:for-each-group>
                </div>
            </xsl:template>


            <!-- the template for an entry -->
            <xsl:template name="app:apparatus-entry" visibility="public">
                <xsl:param name="entries" as="map(*)+"/>
                <xsl:call-template name="app:apparatus-lemma">
                    <xsl:with-param name="entry" select="$entries[1]"/>
                </xsl:call-template>
                <!--xsl:text>\appsep{lem-rdg-sep}</xsl:text-->
                <xsl:for-each select="$entries">
                    <xsl:apply-templates mode="app:reading-dspt" select="map:get(., 'entry')">
                        <xsl:with-param name="apparatus-entry-map" as="map(*)" select="."
                            tunnel="true"/>
                    </xsl:apply-templates>
                    <xsl:if test="position() ne last()">
                        <xsl:text>\appsep{rdgs-sep}</xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <!--
                <xsl:if test="position() ne last()">
                    <xsl:text>\appsep{app-entry-sep}</xsl:text>
                </xsl:if>
                -->
            </xsl:template>

            <!-- template for making the lemma text with some logic for handling empty lemmas -->
            <xsl:template name="app:apparatus-lemma" visibility="private">
                <xsl:param name="entry" as="map(*)"/>
                <xsl:text>\lemma{</xsl:text>
                <xsl:variable name="full-lemma" as="xs:string"
                    select="map:get($entry, 'lemma-text-nodes') => seed:shorten-lemma()"/>
                <xsl:choose>
                    <xsl:when test="map:get($entry, 'entry')/self::gap">
                        <xsl:text>\apptranslate{gap-rep}</xsl:text>
                    </xsl:when>
                    <xsl:when test="$full-lemma ne ''">
                        <xsl:value-of select="$full-lemma"/>
                    </xsl:when>
                    <xsl:when test="$full-lemma eq 'TODO OFF'">
                        <!-- empty lemma: we get the text from empty replacement -->
                        <xsl:variable name="empty-replacement"
                            select="map:get($entry, 'lemma-replacement')"/>
                        <xsl:value-of select="map:get($empty-replacement, 'text')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>???</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>}</xsl:text>
            </xsl:template>


            <xsl:template mode="app:reading-dspt" match="rdg[normalize-space(.) ne '']">
                <xsl:text>\footnoteA{</xsl:text>
                <!-- we have to evaluate the entry: if the lemma is empty, we need to prepend or append the empty replacement -->
                <xsl:call-template name="app:apparatus-xpend-if-lemma-empty">
                    <xsl:with-param name="reading" select="node()"/>
                </xsl:call-template>
                <xsl:if test="@wit">
                    <xsl:text>\appsep{rdg-siglum-sep}\wit{</xsl:text>
                    <xsl:call-template name="app:sigla">
                        <xsl:with-param name="wit" select="@wit"/>
                    </xsl:call-template>
                    <xsl:text>}</xsl:text>
                </xsl:if>
                <xsl:text>}</xsl:text>
                <xsl:if test="position() ne last()">
                    <xsl:text>\appsep{rdgs-sep}</xsl:text>
                </xsl:if>
            </xsl:template>


            <xsl:template mode="app:reading-dspt" match="rdg[normalize-space(.) eq '']">
                <xsl:text>\footnoteA{\apptranslate{omisit}</xsl:text>
                <xsl:if test="@wit">
                    <xsl:text>\appsep{rdg-siglum-sep}\wit{</xsl:text>
                    <xsl:call-template name="app:sigla">
                        <xsl:with-param name="wit" select="@wit"/>
                    </xsl:call-template>
                    <xsl:text>}</xsl:text>
                </xsl:if>
                <xsl:text>}</xsl:text>
                <xsl:if test="position() ne last()">
                    <xsl:text>\appsep{rdgs-sep}</xsl:text>
                </xsl:if>
            </xsl:template>

            <xsl:template mode="app:reading-dspt" match="app/note">
                <xsl:text>\appnote{</xsl:text>
                <xsl:apply-templates mode="app:reading-text" select="node()"/>
                <xsl:text>}</xsl:text>
                <xsl:if test="position() ne last()">
                    <xsl:text>\appsep{rdgs-sep}</xsl:text>
                </xsl:if>
            </xsl:template>


            <xsl:template mode="app:reading-dspt" match="witDetail">
                <xsl:text>\appnote{</xsl:text>
                <xsl:value-of select="i18n:direction-embedding(.)"/>
                <xsl:apply-templates select="node()" mode="app:reading-text"/>
                <xsl:if test="@wit">
                    <xsl:text>\appsep{rdg-siglum-sep}\wit{</xsl:text>
                    <xsl:call-template name="app:sigla">
                        <xsl:with-param name="wit" select="@wit"/>
                    </xsl:call-template>
                    <xsl:text>}</xsl:text>
                </xsl:if>
                <xsl:text>}</xsl:text>
                <xsl:if test="position() ne last()">
                    <xsl:text>\appsep{rdgs-sep}</xsl:text>
                </xsl:if>
            </xsl:template>


            <xsl:template mode="app:reading-dspt" match="corr">
                <xsl:text>\apptranslate{conieci}</xsl:text>
            </xsl:template>


            <xsl:template mode="app:reading-dspt" match="sic[not(parent::choice)]">
                <xsl:text>\apptranslate{sic}</xsl:text>
            </xsl:template>


            <xsl:template mode="app:reading-dspt" match="choice/sic">
                <xsl:text>\footnoteA{</xsl:text>
                <xsl:apply-templates mode="app:reading-text"/>
                <xsl:if test="@source">
                    <xsl:text>\appsep{rdg-siglum-sep}\wit{</xsl:text>
                    <xsl:call-template name="app:sigla">
                        <xsl:with-param name="wit" select="@source"/>
                    </xsl:call-template>
                    <xsl:text>}</xsl:text>
                </xsl:if>
                <xsl:text>}</xsl:text>
                <xsl:if test="position() ne last()">
                    <xsl:text>\appsep{rdgs-sep}</xsl:text>
                </xsl:if>
            </xsl:template>

            <xsl:template mode="app:reading-dspt" match="choice[corr and sic]">
                <xsl:text>\footnoteA{</xsl:text>
                <xsl:apply-templates select="corr" mode="app:reading-dspt"/>
                <xsl:text>\appsep{rdgs-sep}</xsl:text>
                <xsl:apply-templates select="sic" mode="app:reading-dspt"/>
                <xsl:text>}</xsl:text>
                <xsl:if test="position() ne last()">
                    <xsl:text>\appsep{rdgs-sep}</xsl:text>
                </xsl:if>
            </xsl:template>

            <!-- ALEA's old encoding of conjectures -->
            <xsl:template mode="app:reading-dspt" match="choice[corr and sic/app]" priority="2">
                <xsl:text>\footnoteA{</xsl:text>
                <xsl:apply-templates select="corr" mode="app:reading-dspt"/>
                <xsl:text>\appsep{rdgs-sep}</xsl:text>
                <xsl:apply-templates select="sic/app" mode="app:reading-dspt"/>
                <xsl:text>}</xsl:text>
                <xsl:if test="position() ne last()">
                    <xsl:text>\appsep{rdgs-sep}</xsl:text>
                </xsl:if>
            </xsl:template>


            <xsl:template mode="app:reading-dspt" match="unclear[not(parent::choice)]">
                <xsl:text>\footnoteA{</xsl:text>
                <xsl:choose>
                    <xsl:when test="@reason">
                        <xsl:text>\IfTranslation{</xsl:text>
                        <xsl:value-of select="$i18n:default-language"/>
                        <xsl:text>}{</xsl:text>
                        <xsl:value-of select="@reason"/>
                        <xsl:text>}{\apptranslate{</xsl:text>
                        <xsl:value-of select="@reason"/>
                        <xsl:text>}}{</xsl:text>
                        <xsl:value-of select="@reason"/>
                        <xsl:text>}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\apptranslate{unclear}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>}</xsl:text>
                <xsl:if test="position() ne last()">
                    <xsl:text>\appsep{rdgs-sep}</xsl:text>
                </xsl:if>
            </xsl:template>


            <xsl:template mode="app:reading-dspt" match="gap">
                <xsl:text>\footnoteA{</xsl:text>
                <xsl:choose>
                    <xsl:when test="@reason">
                        <xsl:text>\IfTranslation{</xsl:text>
                        <xsl:value-of select="$i18n:default-language"/>
                        <xsl:text>}{</xsl:text>
                        <xsl:value-of select="@reason"/>
                        <xsl:text>}{\apptranslate{</xsl:text>
                        <xsl:value-of select="@reason"/>
                        <xsl:text>}}{</xsl:text>
                        <xsl:value-of select="@reason"/>
                        <xsl:text>}</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>\apptranslate{lost}</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="@quantity and @unit">
                    <xsl:text>\appsep{reason-quantity-sep}\quantity{</xsl:text>
                    <span class="static-text">
                        <xsl:value-of select="@quantity"/>
                    </span>
                    <xsl:text>}&#160;</xsl:text>
                    <xsl:text>\IfTranslation{</xsl:text>
                    <xsl:value-of select="$i18n:default-language"/>
                    <xsl:text>}{</xsl:text>
                    <xsl:value-of select="@unit"/>
                    <xsl:text>}{\apptranslate{</xsl:text>
                    <xsl:value-of select="@unit"/>
                    <xsl:text>}}{</xsl:text>
                    <xsl:value-of select="@unit"/>
                    <xsl:text>}</xsl:text>
                </xsl:if>
                <xsl:text>}</xsl:text>
                <xsl:if test="position() ne last()">
                    <xsl:text>\appsep{rdgs-sep}</xsl:text>
                </xsl:if>
            </xsl:template>

        </xsl:override>
    </xsl:use-package>


    <!-- make a footnote with an apparatus entry if there is one for the context element -->
    <xsl:template name="app:apparatus-footnote" visibility="public">
        <xsl:variable name="element-id" select="generate-id()"/>
        <xsl:if test="map:contains($app:apparatus-entries, $element-id)">
            <xsl:variable name="entry" select="map:get($app:apparatus-entries, $element-id)"/>
            <xsl:variable name="app-entries" select="map:get($entry, 'entries')"/>
            <xsl:text>%&lb;\edtext{\edlabel{</xsl:text>
            <xsl:message use-when="system-property('debug') eq 'true'">
                <xsl:text>Making end edlabel for </xsl:text>
                <xsl:value-of select="map:get($app-entries[1], 'entry') => name()"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="map:get($app-entries[1], 'entry')/@xml:id"/>
            </xsl:message>
            <xsl:variable name="edlabel-end">
                <xsl:apply-templates mode="edlabel-end" select="map:get($app-entries[1], 'entry')"/>
            </xsl:variable>
            <xsl:value-of select="$edlabel-end"/>
            <xsl:text>}}{%&lb;</xsl:text>
            <!-- make the references by \xxref{startlabel}{endlabel} -->
            <xsl:text>\xxref{</xsl:text>
            <xsl:apply-templates mode="edlabel-start" select="map:get($app-entries[1], 'entry')"/>
            <xsl:text>}{</xsl:text>
            <xsl:value-of select="$edlabel-end"/>
            <xsl:text>}</xsl:text>
            <!-- make \lemma and \Afootnote -->
            <xsl:call-template name="app:apparatus-entry">
                <xsl:with-param name="entries" select="map:get($entry, 'entries')[1]"/>
            </xsl:call-template>
            <xsl:text>} %&lb;</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:mode name="edlabel-start" on-no-match="shallow-skip"/>
    <xsl:mode name="edlabel-end" on-no-match="shallow-skip"/>

    <xsl:template mode="edlabel-start"
        match="app[//variantEncoding/@method eq 'parallel-segmentation']">
        <xsl:value-of select="concat(generate-id(), '-start')"/>
    </xsl:template>

    <xsl:template mode="edlabel-end"
        match="app[//variantEncoding/@method eq 'parallel-segmentation']">
        <xsl:value-of select="concat(generate-id(), '-end')"/>
    </xsl:template>

    <xsl:template mode="edlabel-start"
        match="app[//variantEncoding/@method ne 'parallel-segmentation' and @from]">
        <xsl:message>
            <xsl:text>start edlabel </xsl:text>
            <xsl:value-of select="@from"/>
        </xsl:message>
        <xsl:value-of select="substring(@from, 2)"/>
    </xsl:template>

    <xsl:template mode="edlabel-end"
        match="app[//variantEncoding/@method ne 'parallel-segmentation']">
        <xsl:value-of select="generate-id()"/>
    </xsl:template>

    <xsl:template mode="edlabel-start" match="*">
        <xsl:message terminate="yes">
            <xsl:text>ERROR: no rule for making start edlabel for </xsl:text>
            <xsl:value-of select="name(.)"/>
            <xsl:text> in </xsl:text>
            <xsl:value-of select="//variantEncoding/@method"/>
        </xsl:message>
    </xsl:template>

    <xsl:template mode="edlabel-end" match="*">
        <xsl:message terminate="yes">
            <xsl:text>ERROR: no rule for making end edlabel for </xsl:text>
            <xsl:value-of select="name(.)"/>
            <xsl:text> in </xsl:text>
            <xsl:value-of select="//variantEncoding/@method"/>
        </xsl:message>
    </xsl:template>


    <!-- contributions to the latex header -->
    <xsl:template name="app:latex-header" visibility="public">
        <xsl:text>&lb;&lb;%% contributions to the header by .../xsl/latex/libapp.xsl</xsl:text>
        <xsl:text>&lb;\usepackage{translations}</xsl:text>
        <xsl:text>&lb;\usepackage{i18n-translation}</xsl:text>
        <xsl:text>&lb;\newcommand*{\lem}[1]{#1}</xsl:text>
        <xsl:text>&lb;\newcommand*{\rdg}[1]{#1}</xsl:text>
        <xsl:text>&lb;\newcommand*{\wit}[1]{#1}</xsl:text>
        <xsl:text>&lb;\newcommand*{\appsep}[1]{\GetTranslation{#1}}</xsl:text>
        <xsl:text>&lb;\newcommand*{\apptranslate}[1]{\GetTranslation{#1}}</xsl:text>
    </xsl:template>



</xsl:package>
