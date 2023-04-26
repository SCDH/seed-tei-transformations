<?xml version="1.0" encoding="UTF-8"?>
<!-- This generic XSLT module provides UI translation for TEI to HTML transsforamtions using i18next.

The translations must be in i18next JSON files . Their path is given by parameters:

- $locales-directory:  absulute URI or relative  path relative to this stylesheet

- $locales: a sequence of locales

- $translations: the name of the file containing the translationns for a locale

The  path is concatenated from $locales-directory/LOCALE/$translations where LOCALE is one of the locales.

The default language is determined by the $default-language-xpath parameter.

Put the language chooser and the tmeplate  i18n-load-javascript in the back of your HTML file.

Then put <span data-i18n-key="MY-KEY">my default</span> into your templates for using translations.

See i18next documentation for more info: https://www.i18next.com

-->
<!DOCTYPE package [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
    <!ENTITY lb "&#xa;" >
]>
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libi18n.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://scdh.wwu.de/transform/i18n#"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" exclude-result-prefixes="xs i18n"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

    <xsl:expose visibility="public" component="function" names="i18n:*"/>
    <xsl:expose visibility="public" component="template" names="i18n:*"/>
    <xsl:expose visibility="abstract" component="variable" names="i18n:default-language"/>

    <!-- If true, this an extra space is added on the end of an ltr-to-rtl changeover. -->
    <xsl:param name="i18n:ltr-to-rtl-extra-space" as="xs:boolean" select="true()" required="no"/>

    <!-- path to i18next.js -->
    <xsl:param name="i18n:i18next" select="'https://unpkg.com/i18next/i18next.min.js'"
        as="xs:string"/>

    <!-- path to your i18n.js with setup for i18next-->
    <xsl:param name="i18n:js" select="'i18n.js'" as="xs:string"/>

    <!-- path to the translation files, relative to this stylesheet or absolute -->
    <xsl:param name="i18n:locales-directory" select="'locales'" as="xs:string"/>

    <!-- languages offered in the UI. The translation files must be available in the $locales-directory -->
    <xsl:param name="i18n:locales" as="xs:string*" select="('ar', 'de', 'en')"/>

    <!-- name of i18next JSON translations file in $locales-directory/LOCALE/ -->
    <xsl:param name="i18n:default-namespace" select="'translation'"/>



    <!-- a sensible value is e.g. /TEI/@xml:lang -->
    <xsl:variable name="i18n:default-language" as="xs:string" visibility="abstract"/>




    <!-- functions and templates to get language and script specific things done -->

    <!-- better use standard XPath function instead -->
    <xsl:function name="i18n:language" as="xs:string">
        <xsl:param name="context" as="node()"/>
        <xsl:param name="default" as="xs:string"/>
        <xsl:variable name="lang" select="$context/ancestor-or-self::*/@xml:lang"/>
        <xsl:value-of select="
                if (exists($lang)) then
                    $lang[last()]
                else
                    $default"/>
    </xsl:function>

    <!-- better use standard XPath function instead -->
    <xsl:function name="i18n:language" as="xs:string" visibility="public">
        <xsl:param name="context" as="node()"/>
        <xsl:value-of select="i18n:language($context, $i18n:default-language)"/>
    </xsl:function>

    <!-- get the direction CSS code for the context's language -->
    <xsl:function name="i18n:language-direction" visibility="public" as="xs:string">
        <xsl:param name="context" as="node()"/>
        <xsl:param name="default" as="xs:string"/>
        <xsl:variable name="lang" as="xs:string" select="i18n:language($context, $default)"/>
        <xsl:choose>
            <xsl:when test="$lang eq 'ar'">
                <xsl:value-of select="'rtl'"/>
            </xsl:when>
            <xsl:when test="$lang eq 'he'">
                <xsl:value-of select="'rtl'"/>
            </xsl:when>
            <!-- TODO: add other languages as needed -->
            <xsl:otherwise>
                <xsl:value-of select="'ltr'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="i18n:language-direction" as="xs:string" visibility="public">
        <xsl:param name="context" as="node()"/>
        <xsl:value-of select="i18n:language-direction($context, $i18n:default-language)"/>
    </xsl:function>

    <!-- get a Unicode bidi embedding for the language at context. You should pop directional formatting (pdf) afterwards! -->
    <xsl:function name="i18n:direction-embedding" as="xs:string">
        <xsl:param name="context" as="node()"/>
        <xsl:choose>
            <xsl:when test="i18n:language-direction($context) eq 'rtl'">
                <xsl:value-of select="'&rle;'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'&lre;'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- deprecated -->
    <xsl:function name="i18n:language-align" as="xs:string">
        <xsl:param name="context" as="node()"/>
        <xsl:param name="default" as="xs:string"/>
        <xsl:variable name="lang" as="xs:string" select="i18n:language($context, $default)"/>
        <xsl:choose>
            <xsl:when test="$lang eq 'ar'">
                <xsl:value-of select="'right'"/>
            </xsl:when>
            <xsl:when test="$lang eq 'he'">
                <xsl:value-of select="'right'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'left'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- deprecated -->
    <xsl:function name="i18n:language-align" as="xs:string">
        <xsl:param name="context" as="node()"/>
        <xsl:value-of select="i18n:language-align($context, $i18n:default-language)"/>
    </xsl:function>

    <!-- make an extra space text node when changing from ltr to rtl script -->
    <xsl:template name="i18n:ltr-to-rtl-extra-space" as="xs:string">
        <xsl:param name="first-direction" as="xs:string"/>
        <xsl:param name="then-direction" as="xs:string"/>
        <xsl:if
            test="$first-direction eq 'ltr' and $then-direction ne 'ltr' and $i18n:ltr-to-rtl-extra-space">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>

</xsl:package>
