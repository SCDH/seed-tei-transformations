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
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libapp2.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:app="http://scdh.wwu.de/transform/app#"
    xmlns:seed="http://scdh.wwu.de/transform/seed#"
    xmlns:common="http://scdh.wwu.de/transform/common#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    version="3.1">

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libi18n.xsl"
        package-version="0.1.0">
        <xsl:accept component="function"
            names="i18n:language#1 i18n:language-direction#1 i18n:language-align#1 i18n:direction-embedding#1"
            visibility="private"/>
    </xsl:use-package>

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
                                <a name="app-{map:get($entry, 'entry-id')}"
                                    href="#{map:get($entry, 'entry-id')}">
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

            <!-- make a link to an apparatus entry if there is one for the context item.
                The global variable $app:apparatus-entries must be set for this. -->
            <xsl:template name="app:footnote-marks" visibility="public">
                <xsl:variable name="element-id"
                    select="if (@xml:id) then @xml:id else generate-id()"/>
                <xsl:if test="map:contains($app:apparatus-entries, $element-id)">
                    <xsl:variable name="entry" select="map:get($app:apparatus-entries, $element-id)"/>
                    <sup class="apparatus-footnote-mark footnote-mark">
                        <a name="{$element-id}" href="#app-{$element-id}">
                            <xsl:value-of select="map:get($entry, 'number')"/>
                        </a>
                    </sup>
                </xsl:if>
            </xsl:template>

            <!-- make an inline alternative for an entry at the context it.
                The global variable $app:apparatus-entries must be set for this. -->
            <xsl:template name="app:inline-alternatives">
                <!-- TODO -->
            </xsl:template>



            <!-- the template for an entry -->
            <xsl:template name="app:apparatus-entry" visibility="public">
                <xsl:param name="entries" as="map(*)*"/>
                <span class="apparatus-entry">
                    <xsl:call-template name="app:apparatus-lemma">
                        <xsl:with-param name="entry" select="$entries[1]"/>
                    </xsl:call-template>
                    <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">]</span>
                    <xsl:for-each select="$entries">
                        <xsl:apply-templates mode="app:reading-dspt" select="map:get(., 'entry')">
                            <xsl:with-param name="apparatus-entry-map" as="map(*)" select="."
                                tunnel="true"/>
                        </xsl:apply-templates>
                        <xsl:if test="position() ne last()">
                            <span class="apparatus-sep" style="padding-left: 4px"
                                data-i18n-key="rdgs-sep">;</span>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="position() ne last()">
                        <span class="apparatus-sep" data-i18n-key="app-entry-sep"
                            >&nbsp;|&emsp;</span>
                    </xsl:if>
                </span>
            </xsl:template>

            <!-- template for making the lemma text with some logic for handling empty lemmas -->
            <xsl:template name="app:apparatus-lemma" visibility="private">
                <xsl:param name="entry" as="map(*)"/>
                <span class="apparatus-lemma">
                    <xsl:variable name="full-lemma" as="xs:string"
                        select="map:get($entry, 'lemma-text-nodes') => seed:shorten-lemma()"/>
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



            <xsl:template mode="app:reading-dspt" match="rdg[normalize-space(.) ne '']">
                <span class="reading">
                    <!-- we have to evaluate the entry: if the lemma is empty, we need to prepend or append the empty replacement -->
                    <xsl:call-template name="app:apparatus-xpend-if-lemma-empty">
                        <xsl:with-param name="reading" select="node()"/>
                    </xsl:call-template>
                    <xsl:if test="@wit">
                        <span class="apparatus-sep" style="padding-left: 3px"
                            data-i18n-key="rdg-siglum-sep">:</span>
                        <xsl:call-template name="app:sigla">
                            <xsl:with-param name="wit" select="@wit"/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:if test="position() ne last()">
                        <span class="apparatus-sep" style="padding-left: 4px"
                            data-i18n-key="rdgs-sep">;</span>
                    </xsl:if>
                </span>
            </xsl:template>


            <xsl:template mode="app:reading-dspt" match="rdg[normalize-space(.) eq '']">
                <span class="reading">
                    <span class="static-text" data-i18n-key="omisit">&lre;om.&pdf;</span>
                    <xsl:if test="@wit">
                        <span class="apparatus-sep" style="padding-left: 3px"
                            data-i18n-key="rdg-siglum-sep">:</span>
                        <xsl:call-template name="app:sigla">
                            <xsl:with-param name="wit" select="@wit"/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:if test="position() ne last()">
                        <span class="apparatus-sep" style="padding-left: 4px"
                            data-i18n-key="rdgs-sep">;</span>
                    </xsl:if>
                </span>
            </xsl:template>

            <xsl:template mode="app:reading-dspt" match="app/note">
                <span class="reading reading-note">
                    <xsl:apply-templates mode="app:reading-text" select="node()"/>
                    <xsl:if test="position() ne last()">
                        <span class="apparatus-sep" style="padding-left: 4px"
                            data-i18n-key="rdgs-sep">;</span>
                    </xsl:if>
                </span>
            </xsl:template>


            <xsl:template mode="app:reading-dspt" match="witDetail">
                <span class="reading note-text witDetail" lang="{i18n:language(.)}"
                    style="direction:{i18n:language-direction(.)}; text-align:{i18n:language-align(.)};">
                    <xsl:value-of select="i18n:direction-embedding(.)"/>
                    <xsl:apply-templates select="node()" mode="app:reading-text"/>
                    <xsl:text>&pdf;</xsl:text>
                    <xsl:if test="@wit">
                        <span class="apparatus-sep" style="padding-left: 3px"
                            data-i18n-key="rdg-siglum-sep">:</span>
                        <xsl:call-template name="app:sigla">
                            <xsl:with-param name="wit" select="@wit"/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:if test="position() ne last()">
                        <span class="apparatus-sep" style="padding-left: 4px"
                            data-i18n-key="rdgs-sep">;</span>
                    </xsl:if>
                </span>
            </xsl:template>


            <xsl:template mode="app:reading-dspt" match="corr">
                <span class="static-text" data-i18n-key="conieci">&lre;coniec.&pdf;</span>
            </xsl:template>


            <xsl:template mode="app:reading-dspt" match="sic[not(parent::choice)]">
                <span class="static-text" data-i18n-key="sic">&lre;sic!&pdf;</span>
            </xsl:template>


            <xsl:template mode="app:reading-dspt" match="choice/sic">
                <span class="reading">
                    <xsl:apply-templates mode="app:reading-text"/>
                    <xsl:if test="@source">
                        <span class="apparatus-sep" style="padding-left: 3px"
                            data-i18n-key="rdg-siglum-sep">:</span>
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

            <xsl:template mode="app:reading-dspt" match="choice[corr and sic]">
                <span class="reading">
                    <xsl:apply-templates select="corr" mode="app:reading-dspt"/>
                    <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                        >;</span>
                    <xsl:apply-templates select="sic" mode="app:reading-dspt"/>
                </span>
                <xsl:if test="position() ne last()">
                    <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                        >;&sp;</span>
                </xsl:if>
            </xsl:template>

            <!-- ALEA's old encoding of conjectures -->
            <xsl:template mode="app:reading-dspt" match="choice[corr and sic/app]" priority="2">
                <span class="reading">
                    <xsl:apply-templates select="corr" mode="app:reading-dspt"/>
                    <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                        >;</span>
                    <xsl:apply-templates select="sic/app" mode="app:reading-dspt"/>
                </span>
                <xsl:if test="position() ne last()">
                    <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                        >;</span>
                </xsl:if>
            </xsl:template>


            <xsl:template mode="app:reading-dspt" match="unclear[not(parent::choice)]">
                <span class="reading unclear">
                    <xsl:choose>
                        <xsl:when test="@reason">
                            <span class="static-text" data-i18n-key="{@reason}">&lre;<xsl:value-of
                                    select="@reason"/>&pdf;</span>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- TODO: latin -->
                            <span class="static-text" data-i18n-key="unclear"
                                >&lre;unclear&pdf;</span>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
                <xsl:if test="position() ne last()">
                    <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                        >;</span>
                </xsl:if>
            </xsl:template>


            <xsl:template mode="app:reading-dspt" match="gap">
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
                        <span class="static-text" data-i18n-key="{@unit}">&lre;<xsl:value-of
                                select="@unit"/>&pdf;</span>
                    </xsl:if>
                </span>
                <xsl:if test="position() ne last()">
                    <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                        >;</span>
                </xsl:if>
            </xsl:template>

        </xsl:override>
    </xsl:use-package>

</xsl:package>
