<?xml version="1.0" encoding="UTF-8"?>
<!-- An extension of libbiblio for printing special references for ALEA

Special references:

- Quran

-->
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

            <xsl:template priority="10" mode="biblio:entry" match="bibl[@xml:id eq 'Quran']">
                <xsl:param name="tpBiblScope" as="element()*" tunnel="yes"/>
                <xsl:message use-when="system-property('debug') ne 'true'">
                    <xsl:text>Reference to Quran with </xsl:text>
                    <xsl:value-of select="count($tpBiblScope)"/>
                    <xsl:text> biblScopes.</xsl:text>
                </xsl:message>
                <span data-i18n-key="Quran" data-i18n-ns="quran">
                    <xsl:apply-templates mode="#current"/>
                </span>
                <span data-i18n-key="quran-title-surah-delim" data-i18n-ns="quran">: </span>
                <xsl:for-each select="$tpBiblScope">
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
                    <span data-i18n-key="surah-{$surah}" data-i18n-ns="quran">
                        <xsl:apply-templates mode="#current" select="$biblScope"/>
                    </span>
                    <xsl:if test="$verse ne ''">
                        <span data-i18n-key="quran-surah-verse-delim" data-i18n-ns="quran">, </span>
                        <xsl:analyze-string select="$verse" regex="\d+">
                            <xsl:matching-substring>
                                <span data-i18n-key="{regex-group(0)}" data-i18n-ns="decimal">
                                    <xsl:value-of select="regex-group(0)"/>
                                </span>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <span data-i18n-key="{normalize-space(.)}" data-i18n-ns="quran">
                                    <xsl:value-of select="."/>
                                </span>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:if>
                </xsl:for-each>
            </xsl:template>

            <!-- do not print biblScope for quran -->
            <xsl:template mode="biblio:entry"
                match="biblScope[parent::bibl[@corresp eq 'bibl:Quran']]"/>

        </xsl:override>
    </xsl:use-package>

</xsl:package>
