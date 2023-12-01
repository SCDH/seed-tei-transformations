<?xml version="1.0" encoding="UTF-8"?>
<!-- An extension of libbiblio for printing special references for ALEA

Special references:

- Quran

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">

    <xsl:import href="libi18n.xsl"/>

    <xsl:template priority="10" mode="biblio" match="bibl[@xml:id eq 'Quran']">
        <xsl:param name="tpBiblScope" as="element()*" tunnel="yes"/>
        <xsl:variable name="surah">
            <xsl:analyze-string select="$tpBiblScope => normalize-space()" regex="^(\d+)(:\d+)?$">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(1)"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <xsl:variable name="verse">
            <xsl:analyze-string select="$tpBiblScope => normalize-space()" regex="^(\d+):(\d+)?$">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(2)"/>
                </xsl:matching-substring>
            </xsl:analyze-string>
        </xsl:variable>
        <span data-i18n-key="Quran" data-i18n-ns="quran">
            <xsl:apply-templates mode="biblio"/>
        </span>
        <span data-i18n-key="quran-title-surah-delim" data-i18n-ns="quran">: </span>
        <span data-i18n-key="surah-{$surah}" data-i18n-ns="quran">
            <xsl:apply-templates mode="biblio" select="$tpBiblScope"/>
        </span>
        <xsl:if test="$verse ne ''">
            <span data-i18n-key="quran-surah-verse-delim" data-i18n-ns="quran">, </span>
            <span data-i18n-key="{$verse}" data-i18n-ns="decimal">
                <xsl:value-of select="$verse"/>
            </span>
        </xsl:if>
    </xsl:template>

    <!-- do not print biblScope for quran -->
    <xsl:template mode="biblio" match="biblScope[parent::bibl[@corresp eq 'bibl:Quran']]"/>


    <xsl:template name="surah-translations">
        <script type="module">
            <xsl:call-template name="i18n-language-resources-inline">
                <xsl:with-param name="directory" select="$locales-directory"/>
                <xsl:with-param name="namespace" select="'quran'"/>
            </xsl:call-template>
        </script>
    </xsl:template>

</xsl:stylesheet>
