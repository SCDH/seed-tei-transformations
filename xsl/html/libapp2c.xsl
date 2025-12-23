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
    xmlns:seed="http://scdh.wwu.de/transform/seed#" xmlns:wit="http://scdh.wwu.de/transform/wit#"
    xmlns:common="http://scdh.wwu.de/transform/common#"
    xmlns:compat="http://scdh.wwu.de/transform/compat#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    version="3.1">

    <!-- with false (default), there are some specific templates for alternative text in choice -->
    <xsl:param name="compat:first-child" as="xs:boolean" select="false()" static="true"/>

    <xsl:param name="app:popup-anchor" as="xs:string" select="'?'" required="false"/>

    <!-- whether or not to have the "lemma]" in apparatus entries -->
    <xsl:param name="app:lemma" as="xs:boolean" select="true()" required="false"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libi18n.xsl"
        package-version="0.1.0">
        <xsl:accept component="function"
            names="i18n:language#1 i18n:language-direction#1 i18n:language-align#1 i18n:direction-embedding#1"
            visibility="private"/>
    </xsl:use-package>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libwit.xsl"
        package-version="1.0.0">
        <xsl:accept component="variable" names="wit:witness" visibility="private"/>
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
        <xsl:accept component="variable" names="compat:*" visibility="hidden"/>

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

            <!-- generate a line-based apparatus (as CSS grid layout) for a sequence of prepared maps -->
            <xsl:template name="app:line-based-apparatus-block" visibility="public">
                <xsl:param name="entries" as="map(*)*"/>
                <div class="apparatus-container">
                    <!-- we first group the entries by line number -->
                    <xsl:for-each-group select="$entries" group-by="map:get(., 'line-number')">
                        <xsl:message use-when="system-property('debug') eq 'true'">
                            <xsl:text>Apparatus entries for line </xsl:text>
                            <xsl:value-of select="current-grouping-key()"/>
                            <xsl:text> : </xsl:text>
                            <xsl:value-of select="count(current-group())"/>
                        </xsl:message>

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
                                <xsl:if test="position() ne last()">
                                    <span class="apparatus-sep" data-i18n-key="app-entry-sep"
                                        >&nbsp;|&emsp;</span>
                                </xsl:if>
                            </xsl:for-each-group>
                        </span>

                    </xsl:for-each-group>
                </div>
            </xsl:template>

            <!-- generate a note-based apparatus for a sequence of prepared maps -->
            <xsl:template name="app:note-based-apparatus" visibility="public">
                <xsl:param name="entries" as="map(xs:string, map(*))"/>
                <xsl:variable name="merged-entries" select="map:merge($entries)"/>
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>printing note based apparatus for </xsl:text>
                    <xsl:value-of select="map:size($entries)"/>
                    <xsl:text> entries</xsl:text>
                </xsl:message>
                <div>
                    <xsl:for-each select="map:keys($entries)">
                        <xsl:sort select="map:get($entries, .) => map:get('number')"/>
                        <xsl:variable name="entry-id" select="."/>
                        <xsl:variable name="entry" select="map:get($entries, $entry-id)"/>
                        <xsl:variable name="number" select="map:get($entry, 'number')"/>
                        <div class="apparatus-line">
                            <span class="apparatus-note-number note-number">
                                <a name="app-{$entry-id}" href="#{$entry-id}">
                                    <xsl:value-of select="map:get($entry, 'number')"/>
                                </a>
                            </span>
                            <!-- call the template that outputs an apparatus entries -->
                            <xsl:call-template name="app:apparatus-entry">
                                <xsl:with-param name="entries" select="map:get($entry, 'entries')"/>
                            </xsl:call-template>
                        </div>
                    </xsl:for-each>
                </div>
            </xsl:template>

            <!-- make a link to an apparatus entry if there is one for the context item.
                See seed:note-based-apparatus-nodes-map#2 for making a required map. -->
            <xsl:template name="app:footnote-marks" visibility="public">
                <xsl:param name="entries" as="map(xs:string, map(*))"/>
                <xsl:variable name="element-id"
                    select="if (@xml:id) then @xml:id else generate-id()"/>
                <xsl:if test="map:contains($entries, $element-id)">
                    <xsl:variable name="entry" select="map:get($entries, $element-id)"/>
                    <sup class="apparatus-footnote-mark footnote-mark">
                        <a name="{$element-id}" href="#app-{$element-id}">
                            <xsl:value-of select="map:get($entry, 'number')"/>
                        </a>
                    </sup>
                </xsl:if>
            </xsl:template>

            <!-- make an inline alternative for an entry at the context it appears in.
                See seed:note-based-apparatus-nodes-map#2 for making a required map.
                popup.css should be loaded when used; see named template
                app:popup-css. -->
            <xsl:template name="app:inline-alternatives" visibility="public">
                <xsl:param name="entries" as="map(xs:string, map(*))"/>
                <xsl:variable name="element-id"
                    select="if (@xml:id) then @xml:id else generate-id()"/>
                <xsl:variable name="popup-id" select="concat($element-id, '-popup')"/>
                <xsl:if test="map:contains($entries, $element-id)">
                    <xsl:variable name="entry" as="map(*)" select="map:get($entries, $element-id)"/>
                    <!-- cf. https://www.w3schools.com/howto/howto_js_popup.asp -->
                    <span class="popup">
                        <xsl:attribute name="onclick">
                            <!-- call anonymous function onclick="'(()=>{...})()'" -->
                            <xsl:text>(()=>{</xsl:text>
                            <xsl:text use-when="system-property('debug') eq 'true'">console.log("clicked on apparatus entry ","</xsl:text>
                            <xsl:value-of select="$popup-id"
                                use-when="system-property('debug') eq 'true'"/>
                            <xsl:text use-when="system-property('debug') eq 'true'">"); </xsl:text>
                            <xsl:text>const popup = document.getElementById('</xsl:text>
                            <xsl:value-of select="$popup-id"/>
                            <xsl:text>'); popup.classList.toggle("show");</xsl:text>
                            <xsl:text>})()</xsl:text>
                        </xsl:attribute>
                        <span class="static-text clickable-text popup-anchor">
                            <xsl:if test="$app:popup-anchor eq ''">
                                <xsl:attribute name="data-i18n-key" select="'popup-anchor'"/>
                            </xsl:if>
                            <xsl:value-of select="$app:popup-anchor"/>
                        </span>
                        <span class="popuptext" id="{$popup-id}">
                            <xsl:call-template name="app:apparatus-entry">
                                <xsl:with-param name="entries" select="map:get($entry, 'entries')"/>
                            </xsl:call-template>
                        </span>
                    </span>
                </xsl:if>
            </xsl:template>


            <!-- the template for an entry -->
            <xsl:template name="app:apparatus-entry" visibility="public">
                <xsl:param name="entries" as="map(*)*"/>
                <span class="apparatus-entry">
                    <xsl:if test="$app:lemma">
                        <xsl:call-template name="app:apparatus-lemma">
                            <xsl:with-param name="entry" select="$entries[1]"/>
                        </xsl:call-template>
                        <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">]</span>
                        <xsl:text> </xsl:text>
                        <xsl:call-template name="app:lemma-annotation">
                            <xsl:with-param name="entry" select="$entries[1] => map:get('entry')"/>
                        </xsl:call-template>
                    </xsl:if>
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

            <xsl:template name="app:lemma-annotation" visibility="private">
                <xsl:param name="entry" as="element()"/>
                <xsl:variable name="annotations" as="element()*">
                    <xsl:apply-templates mode="app:lemma-annotation" select="$entry"/>
                </xsl:variable>
                <xsl:for-each select="$annotations">
                    <xsl:sequence select="."/>
                    <span class="lemma-annotation-separator" data-i18n-key="lemma-annotation-sep"
                        >,&#x20;</span>
                </xsl:for-each>
            </xsl:template>


            <xsl:template mode="app:reading-dspt" match="rdg[normalize-space(.) ne '']">
                <span class="reading">
                    <!-- we have to evaluate the entry: if the lemma is empty, we need to prepend or append the empty replacement -->
                    <xsl:call-template name="app:apparatus-xpend-if-lemma-empty">
                        <xsl:with-param name="reading" select="node()"/>
                    </xsl:call-template>
                    <!-- handle nested gap etc. -->
                    <xsl:call-template name="app:reading-annotation">
                        <xsl:with-param name="separator" select="true()"/>
                    </xsl:call-template>
                    <xsl:if test="app:prints-sigla(.)">
                        <span class="apparatus-sep" style="padding-left: 3px"
                            data-i18n-key="rdg-siglum-sep">:</span>
                        <xsl:call-template name="app:sigla">
                            <xsl:with-param name="context" select="."/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:if test="position() ne last()">
                        <span class="apparatus-sep" style="padding-left: 4px"
                            data-i18n-key="rdgs-sep">;</span>
                    </xsl:if>
                </span>
            </xsl:template>

            <!-- empty <rdg> -->
            <xsl:template mode="app:reading-dspt" match="rdg[not(node())]">
                <span class="reading">
                    <span class="static-text" data-i18n-key="omisit">&lre;om.&pdf;</span>
                    <xsl:if test="app:prints-sigla(.)">
                        <span class="apparatus-sep" style="padding-left: 3px"
                            data-i18n-key="rdg-siglum-sep">:</span>
                        <xsl:call-template name="app:sigla">
                            <xsl:with-param name="context" select="."/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:if test="position() ne last()">
                        <span class="apparatus-sep" style="padding-left: 4px"
                            data-i18n-key="rdgs-sep">;</span>
                    </xsl:if>
                </span>
            </xsl:template>

            <!-- <rdg> without text nodes, but other nodes, e.g. <rdg><gap reason="illegible"/></rdg> -->
            <xsl:template mode="app:reading-dspt" match="rdg[node() and normalize-space(.) eq '']"
                priority="5">
                <span class="reading">
                    <xsl:call-template name="app:reading-annotation"/>
                    <xsl:if test="app:prints-sigla(.)">
                        <span class="apparatus-sep" style="padding-left: 3px"
                            data-i18n-key="rdg-siglum-sep">:</span>
                        <xsl:call-template name="app:sigla">
                            <xsl:with-param name="context" select="."/>
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
                    <xsl:if test="app:prints-sigla(.)">
                        <span class="apparatus-sep" style="padding-left: 3px"
                            data-i18n-key="rdg-siglum-sep">:</span>
                        <xsl:call-template name="app:sigla">
                            <xsl:with-param name="context" select="."/>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:if test="position() ne last()">
                        <span class="apparatus-sep" style="padding-left: 4px"
                            data-i18n-key="rdgs-sep">;</span>
                    </xsl:if>
                </span>
            </xsl:template>


            <xsl:template mode="app:reading-dspt" match="corr">
                <span class="static-text" data-i18n-key="conieci">&lre;corr.&pdf;</span>
            </xsl:template>


            <xsl:template mode="app:reading-dspt" match="sic[not(parent::choice)]">
                <span class="static-text" data-i18n-key="sic">&lre;sic!&pdf;</span>
            </xsl:template>


            <xsl:template mode="app:reading-dspt" match="choice/sic"
                use-when="not($compat:first-child)">
                <span class="reading">
                    <xsl:apply-templates mode="app:reading-text"/>
                    <xsl:if test="app:prints-sigla(.)">
                        <span class="apparatus-sep" style="padding-left: 3px"
                            data-i18n-key="rdg-siglum-sep">:</span>
                        <span class="siglum">
                            <xsl:call-template name="app:sigla">
                                <xsl:with-param name="context" select="."/>
                            </xsl:call-template>
                        </span>
                    </xsl:if>
                </span>
                <xsl:if test="position() ne last()">
                    <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                        >;&sp;</span>
                </xsl:if>
            </xsl:template>

            <xsl:template mode="app:reading-dspt" match="choice[corr and sic]"
                use-when="not($compat:first-child)">
                <span class="reading">
                    <xsl:apply-templates select="sic" mode="app:reading-dspt"/>
                </span>
                <xsl:if test="position() ne last()">
                    <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                        >;&sp;</span>
                </xsl:if>
            </xsl:template>

            <xsl:template mode="app:reading-dspt" match="choice[orig and reg]"
                use-when="not($compat:first-child)">
                <span class="reading">
                    <xsl:apply-templates mode="app:reading-text" select="orig"/>
                </span>
                <xsl:if test="position() ne last()">
                    <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                        >;&sp;</span>
                </xsl:if>
            </xsl:template>

            <xsl:template mode="app:reading-dspt" match="choice[abbr and expan]"
                use-when="not($compat:first-child)">
                <span class="reading">
                    <xsl:apply-templates mode="app:reading-text" select="abbr"/>
                </span>
                <xsl:if test="position() ne last()">
                    <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                        >;&sp;</span>
                </xsl:if>
            </xsl:template>

            <!-- choice with nested seg as basic variant encoding -->
            <xsl:template mode="app:reading-dspt" match="choice[seg and exists($wit:witness)]">
                <xsl:for-each
                    select="seg[not((@source ! tokenize(.) ! replace(., '^#', '')) = $wit:witness)]">
                    <span class="reading">
                        <xsl:apply-templates mode="app:reading-text" select="."/>
                        <xsl:if test="app:prints-sigla(.)">
                            <span class="apparatus-sep" style="padding-left: 3px"
                                data-i18n-key="rdg-siglum-sep">:</span>
                            <span class="siglum">
                                <xsl:call-template name="app:sigla">
                                    <xsl:with-param name="context" select="."/>
                                </xsl:call-template>
                            </span>
                        </xsl:if>
                    </span>
                    <xsl:if test="position() ne last()">
                        <span class="apparatus-sep" style="padding-left: 4px"
                            data-i18n-key="rdgs-sep">;&sp;</span>
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="position() ne last()">
                    <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                        >;&sp;</span>
                </xsl:if>
            </xsl:template>

            <!-- general choice handling (unspecified default): every child but the first is a reading -->
            <xsl:template mode="app:reading-dspt" match="choice">
                <xsl:for-each select="*[position() gt 1]">
                    <span class="reading">
                        <xsl:apply-templates mode="app:reading-text" select="."/>
                        <xsl:if test="app:prints-sigla(.)">
                            <span class="apparatus-sep" style="padding-left: 3px"
                                data-i18n-key="rdg-siglum-sep">:</span>
                            <span class="siglum">
                                <xsl:call-template name="app:sigla">
                                    <xsl:with-param name="context" select="."/>
                                </xsl:call-template>
                            </span>
                        </xsl:if>
                    </span>
                    <xsl:if test="position() ne last()">
                        <span class="apparatus-sep" style="padding-left: 4px"
                            data-i18n-key="rdgs-sep">;&sp;</span>
                    </xsl:if>
                </xsl:for-each>
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


            <xsl:template mode="app:reading-dspt" match="subst[del and add]">
                <span class="reading">
                    <xsl:apply-templates select="del" mode="app:reading-dspt"/>
                </span>
                <xsl:call-template name="app:reading-annotation">
                    <xsl:with-param name="context" select="del"/>
                    <xsl:with-param name="separator" select="true()"/>
                </xsl:call-template>
                <xsl:if test="position() ne last()">
                    <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                        >;&sp;</span>
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

            <xsl:template mode="app:reading-dspt" match="space">
                <span class="reading space">
                    <!-- space as well as gap is a kind of lacuna -->
                    <span class="static-text" data-i18n-key="space">&lre;lac.&pdf;</span>
                    <!-- TODO: evaluate all dimension attributes -->
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


            <xsl:template mode="app:reading-dspt" match="supplied">
                <span class="reading supplied">
                    <span class="static-text" data-i18n-key="supplied">&lre;supplied&pdf;</span>
                </span>
                <xsl:if test="position() ne last()">
                    <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                        >;</span>
                </xsl:if>
            </xsl:template>

            <xsl:template mode="app:reading-dspt" match="note[not(parent::app)]">
                <span class="note-text" lang="{i18n:language(.)}"
                    style="direction:{i18n:language-direction(.)}; text-align:{i18n:language-align(.)};">
                    <!-- This must be paired with pdf character entity,
                                because directional embeddings are an embedded CFG! -->
                    <xsl:value-of select="i18n:direction-embedding(.)"/>
                    <xsl:apply-templates mode="app:pre-reading-text" select="."/>
                    <xsl:apply-templates mode="app:reading-text" select="node()"/>
                    <xsl:apply-templates mode="app:post-reading-text" select="."/>
                    <xsl:text>&pdf;</xsl:text>
                    <xsl:if
                        test="i18n:language-direction(.) eq 'ltr' and i18n:language-direction(parent::*) ne 'ltr' and $i18n:ltr-to-rtl-extra-space">
                        <xsl:text> </xsl:text>
                    </xsl:if>
                </span>
            </xsl:template>




            <xsl:template name="app:reading-annotation">
                <xsl:context-item as="element()" use="optional"/>
                <xsl:param name="context" as="element()" select="."/>
                <xsl:param name="separator" as="xs:boolean" select="false()"/>
                <xsl:variable name="annotations" as="element()*">
                    <span class="reading-annotation">
                        <!--
                            Applying on both, context and children may easy break things.
                            Maybe we need a flag to controle this.
                        -->
                        <xsl:apply-templates mode="app:reading-annotation"
                            select="$context, $context/node()"/>
                    </span>
                </xsl:variable>
                <!-- we have to filter out the spans with no content -->
                <xsl:for-each select="$annotations[node()]">
                    <xsl:if test="position() gt 1 or $separator">
                        <span class="apparatus-sep" data-i18n-key="rdg-annotation-sep">, </span>
                    </xsl:if>
                    <xsl:sequence select="."/>
                </xsl:for-each>
            </xsl:template>


            <!-- make reading annotation from nested <unclear>, <gap> etc. -->
            <xsl:template mode="app:reading-annotation" match="*[@reason]">
                <span class="static-text" data-i18n-key="{string(@reason)}">
                    <xsl:value-of select="@reason"/>
                </span>
            </xsl:template>

            <!-- make reading annotation for a nested <space> -->
            <xsl:template mode="app:reading-annotation" match="space">
                <span class="static-text" data-i18n-key="space">&lre;lac.&pdf;</span>
            </xsl:template>

            <!-- make reading annotation for a nested <del> -->
            <xsl:template mode="app:reading-annotation" match="del">
                <span class="static-text" data-i18n-key="space">&lre;a.c.&pdf;</span>
            </xsl:template>


            <!-- lemma annotations -->

            <xsl:template mode="app:lemma-annotation" match="app[lem/sic]">
                <span class="static-text lemma-annotation" data-i18n-key="sic-annotation"
                    >&lre;sic&pdf;</span>
            </xsl:template>

            <xsl:template mode="app:lemma-annotation" match="choice[corr and sic]">
                <span class="static-text lemma-annotation" data-i18n-key="corr-annotation"
                    >&lre;corr.&pdf;</span>
            </xsl:template>

            <!-- make reading annotation for a nested <add> -->
            <xsl:template mode="app:lemma-annotation" match="subst[add and del]">
                <span class="lemma-annotation">
                    <span class="static-text" data-i18n-key="space">&lre;add.&pdf;</span>
                    <xsl:if test="add/@place">
                        <xsl:text>&#x20;</xsl:text>
                        <span class="static-text" data-i18n-key="{add/@place}">
                            <xsl:text>&lre;</xsl:text>
                            <xsl:value-of select="add/@place"/>
                            <xsl:text>&pdf;</xsl:text>
                        </span>
                    </xsl:if>
                </span>
            </xsl:template>

        </xsl:override>
    </xsl:use-package>

    <xsl:variable name="app:popup-css" as="xs:anyURI"
        select="resolve-uri('popup.css', static-base-uri())" visibility="final"/>

    <!-- load css required for app:inline-alternatives -->
    <xsl:template name="app:popup-css" visibility="public">
        <style>
            <xsl:value-of select="$app:popup-css => unparsed-text()"/>
        </style>
    </xsl:template>

</xsl:package>
