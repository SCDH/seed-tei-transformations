<?xml version="1.0" encoding="UTF-8"?>
<!--
This generic XSLT module provides babel translations for translation namespaces defined in JSON (for i18n-javascript).
-->
<!DOCTYPE package [
    <!ENTITY lb "&#xa;" >
]>
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libi18n.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://scdh.wwu.de/transform/i18n#"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" exclude-result-prefixes="xs i18n"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.1">

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libi18n.xsl"
        package-version="1.0.0">

        <xsl:accept visibility="public" component="function" names="i18n:*"/>
        <xsl:accept visibility="public" component="template" names="i18n:*"/>
        <xsl:accept visibility="abstract" component="variable" names="i18n:default-language"/>

    </xsl:use-package>

    <!-- a mapping of i18n language codes to babel languages -->
    <xsl:function name="i18n:babel-language" as="xs:string" visibility="public">
        <xsl:param name="language" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$language eq 'en'">english</xsl:when>
            <xsl:when test="$language eq 'de'">ngerman</xsl:when>
            <xsl:when test="$language eq 'ar'">arabic</xsl:when>
            <xsl:otherwise>english</xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- make a package via filecontents from a translation namespace -->
    <xsl:template name="i18n:mk-package" visibility="public">
        <xsl:param name="namespace" as="xs:string"/>
        <xsl:param name="directory" as="xs:string"/>
        <xsl:text>&lb;\usepackage{filecontents}</xsl:text>
        <xsl:text>&lb;\begin{filecontents}{i18n-</xsl:text>
        <xsl:value-of select="$namespace"/>
        <xsl:text>.sty}&lb;</xsl:text>
        <xsl:call-template name="i18n:package">
            <xsl:with-param name="namespace" select="$namespace"/>
            <xsl:with-param name="directory" select="$directory"/>
        </xsl:call-template>
        <xsl:text>&lb;\end{filecontents}</xsl:text>
    </xsl:template>

    <!-- make a package from a translation namespace -->
    <xsl:template name="i18n:package" visibility="public">
        <xsl:param name="namespace" as="xs:string"/>
        <xsl:param name="directory" as="xs:string"/>
        <xsl:text>\ProvidesPackage{i18n-</xsl:text>
        <xsl:value-of select="$namespace"/>
        <xsl:text>}</xsl:text>
        <xsl:text>&lb;\RequirePackage{translations}</xsl:text>
        <xsl:for-each select="$i18n:locales">
            <xsl:variable name="language" select="."/>
            <xsl:variable name="translation-file"
                select="resolve-uri(concat($directory, '/', ., '/', $namespace, '.json'), static-base-uri())"/>
            <!-- FIXME: why doesn't doc-available() work as expected? -->
            <xsl:if test="true() or doc-available($translation-file)">
                <xsl:variable name="translations" as="map(xs:string, xs:string)"
                    select="unparsed-text($translation-file) => parse-json()"/>
                <xsl:for-each select="map:keys($translations)">
                    <xsl:text>&lb;\DeclareTranslation{</xsl:text>
                    <xsl:value-of select="i18n:babel-language($language)"/>
                    <xsl:text>}{</xsl:text>
                    <xsl:value-of select="."/>
                    <xsl:text>}{</xsl:text>
                    <xsl:value-of select="map:get($translations, .)"/>
                    <xsl:text>}</xsl:text>
                    <xsl:if test="$language eq $i18n:default-language">
                        <xsl:text>&lb;\DeclareTranslationFallback{</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>}{</xsl:text>
                        <xsl:value-of select="map:get($translations, .)"/>
                        <xsl:text>}</xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- contribution to the latex header -->
    <xsl:template name="i18n:latex-header" visibility="public">
        <xsl:text>&lb;&lb;%% header contributions from .../xsl/latex/libi18n.xsl</xsl:text>
        <xsl:call-template name="i18n:mk-package">
            <xsl:with-param name="namespace" select="'translation'"/>
            <xsl:with-param name="directory" select="concat('../html/', $i18n:locales-directory)"/>
        </xsl:call-template>
        <xsl:text>&lb;\usepackage{i18n-translation}</xsl:text>
    </xsl:template>

</xsl:package>
