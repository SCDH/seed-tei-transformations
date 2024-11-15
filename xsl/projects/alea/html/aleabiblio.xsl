<?xml version="1.0" encoding="UTF-8"?>
<!-- An extension of libbiblio for printing special references for ALEA

Special references:

- Quran

-->
<!DOCTYPE stylesheet [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
    <!ENTITY nbsp "&#xa0;" >
    <!ENTITY emsp "&#x2003;" >
    <!ENTITY lb  "&#xa;" >
    <!ENTITY sp  "&#x20;" >
]>
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/html/aleabiblio.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ref="http://scdh.wwu.de/transform/ref#"
    xmlns:i18n="http://scdh.wwu.de/transform/i18n#"
    xmlns:biblio="http://scdh.wwu.de/transform/biblio#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    version="3.1">

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libi18n.xsl"
        package-version="0.1.0">
        <xsl:accept component="variable" names="i18n:default-language" visibility="abstract"/>
    </xsl:use-package>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libref.xsl"
        package-version="1.0.0"/>

    <xsl:template name="surah-translations" visibility="public">
        <script type="module">
            <xsl:call-template name="i18n:language-resources-inline">
                <xsl:with-param name="directory" select="'locales'"/>
                <xsl:with-param name="namespace" select="'quran'"/>
                <xsl:with-param name="base-uri" select="static-base-uri()"/>
            </xsl:call-template>
        </script>
    </xsl:template>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libbiblio.xsl"
        package-version="1.0.0">

        <xsl:accept component="*" names="*" visibility="public"/>
        <xsl:accept component="template" names="biblio:reference" visibility="final"/>

        <xsl:override>

            <!-- special reference to Quran
                <biblScope> encodes the number (title) of the Surah and the verse from it,
                e.g. 28:32 for Surah 28, Verse 32.
                The verse is optional.
                Mutlitpe verses may be separated by comma, like in 28:30,32.
                Range of verses may be given like so: 28:30-32.
                There may be multiple biblScope elements. Delimiters between them are
                dropped and replaced with new ones.
                Sarah titles and verses are internationalized by i18n.
                -->
            <xsl:template priority="10" mode="biblio:reference"
                match="bibl[matches(@corresp, ':Quran$')]">
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>Reference to Quran with </xsl:text>
                    <xsl:value-of select="count(biblScope)"/>
                    <xsl:text> biblScopes.</xsl:text>
                </xsl:message>
                <xsl:variable name="biblnode" select="."/>
                <xsl:variable name="autotext" as="xs:boolean"
                    select="exists(parent::note[normalize-space(string-join((text() | *) except bibl, '')) eq ''])"/>
                <xsl:variable name="analogous" as="xs:boolean"
                    select="exists(parent::note/parent::seg[matches(@type, '^analogous')])"/>
                <xsl:variable name="ref" as="element()*"
                    select="(ref:references-from-attribute(@corresp)[1] => ref:dereference(.)) treat as element()*"/>
                <xsl:variable name="ref-lang" select="i18n:language(($ref, .)[1])"/>
                <span class="bibliographic-reference" lang="{i18n:language(($ref, .)[1])}"
                    style="direction:{i18n:language-direction(($ref, .)[1])};">
                    <!-- This must be paired with pdf character entity,
                        because directional embeddings are an embedded CFG! -->
                    <xsl:value-of select="i18n:direction-embedding(($ref, .)[1])"/>
                    <xsl:if test="$autotext and $analogous">
                        <span class="static-text" data-i18n-key="Cf." data-i18n-lang="en"
                            >&lre;Cf.&pdf;</span>
                        <xsl:text> </xsl:text>
                    </xsl:if>
                    <span data-i18n-key="Quran" data-i18n-ns="quran" data-i18n-lang="en">
                        <xsl:apply-templates mode="biblio:entry-from-biblio" select="$ref//title"/>
                    </span>
                    <span data-i18n-key="quran-title-surah-delim" data-i18n-ns="quran"
                        data-i18n-lang="en">: </span>
                    <xsl:for-each select="biblScope">
                        <xsl:variable name="biblScope" as="element()" select="."/>
                        <xsl:variable name="surah">
                            <xsl:analyze-string select="$biblScope => normalize-space()"
                                regex="^(\d+)(:((\d+)((\s*-\s*\d+|\s*,\s*\d+)*)))?$">
                                <xsl:matching-substring>
                                    <xsl:value-of select="regex-group(1)"/>
                                </xsl:matching-substring>
                            </xsl:analyze-string>
                        </xsl:variable>
                        <xsl:variable name="verse">
                            <xsl:analyze-string select="$biblScope => normalize-space()"
                                regex="^(\d+)(:((\d+)((\s*-\s*\d+|\s*,\s*\d+)*)))?$">
                                <xsl:matching-substring>
                                    <xsl:value-of select="regex-group(3)"/>
                                </xsl:matching-substring>
                            </xsl:analyze-string>
                        </xsl:variable>
                        <!-- delimiter for multiple Surahs. -->
                        <xsl:if test="position() > 1">
                            <span data-i18n-key="quran-surahs-delim" data-i18n-ns="quran"
                                data-i18n-lang="en">, </span>
                        </xsl:if>
                        <!-- the surah (title) is output as a i18n key where the the number is the default -->
                        <span data-i18n-key="surah-{$surah}" data-i18n-ns="quran"
                            data-i18n-lang="en">
                            <xsl:value-of select="$surah"/>
                        </span>
                        <!-- output the verse(s) -->
                        <xsl:if test="$verse ne ''">
                            <span data-i18n-key="quran-surah-verse-delim" data-i18n-ns="quran"
                                data-i18n-lang="en">, </span>
                            <xsl:analyze-string select="$verse" regex="\d+">
                                <xsl:matching-substring>
                                    <span data-i18n-key="{regex-group(0)}" data-i18n-ns="decimal"
                                        data-i18n-lang="en">
                                        <xsl:value-of select="regex-group(0)"/>
                                    </span>
                                </xsl:matching-substring>
                                <xsl:non-matching-substring>
                                    <span data-i18n-key="{normalize-space(.)}" data-i18n-ns="quran"
                                        data-i18n-lang="en">
                                        <xsl:value-of select="."/>
                                    </span>
                                </xsl:non-matching-substring>
                            </xsl:analyze-string>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="$autotext">
                        <xsl:text>.</xsl:text>
                    </xsl:if>
                </span>
            </xsl:template>


            <!-- overriding templates from mode biblio:entry

                new style entries have author, title and date directly
                in bibl, plus other nodes for the long entry.

                old style entries have a choice and a short and a long
                version in it.
            -->

            <xsl:template match="choice[child::abbr and child::expan]"
                mode="biblio:entry-from-biblio">
                <xsl:apply-templates select="abbr" mode="#current"/>
            </xsl:template>

            <xsl:template match="am[parent::abbr/parent::choice[child::expan]]"
                mode="biblio:entry-from-biblio"/>


            <xsl:template mode="biblio:entry-from-biblio" match="bibl/text()"/>

            <xsl:template match="bibl/title" mode="biblio:entry-from-biblio">
                <span class="biblio title">
                    <xsl:apply-templates mode="#current"/>
                </span>
            </xsl:template>

            <xsl:template match="bibl/author" mode="biblio:entry-from-biblio">
                <span class="biblio author">
                    <xsl:apply-templates mode="#current"/>
                </span>
                <span data-i18n-key="author-title-sep" data-i18n-lang="en">, </span>
            </xsl:template>

            <xsl:template match="bibl/editor[following-sibling::title]"
                mode="biblio:entry-from-biblio">
                <span class="biblio editor">
                    <xsl:apply-templates mode="#current"/>
                </span>
                <span data-i18n-key="editor-abbrev-front" data-i18n-lang="en"
                    >&lre;&sp;(ed.)&pdf;</span>
                <span data-i18n-key="author-title-sep" data-i18n-lang="en">, </span>
            </xsl:template>

            <xsl:template match="bibl/editor[preceding-sibling::title]"
                mode="biblio:entry-from-biblio">
                <span data-i18n-key="title-editor-sep" data-i18n-lang="en">, </span>
                <span data-i18n-key="edited-by-abbrev" data-i18n-lang="en"
                    >&lre;ed.&sp;by&sp;&pdf;</span>
                <span class="biblio editor">
                    <xsl:apply-templates mode="#current"/>
                </span>
            </xsl:template>

            <xsl:template match="bibl/date" mode="biblio:entry-from-biblio"/>

        </xsl:override>
    </xsl:use-package>

</xsl:package>
