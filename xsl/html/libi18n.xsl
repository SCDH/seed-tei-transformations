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
    <!ENTITY newline "&#xa;" >
]>
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libi18n.xsl"
    package-version="0.1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://scdh.wwu.de/transform/i18n#"
    exclude-result-prefixes="xs i18n" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0">

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
    <xsl:param name="i18n:default-namespace" as="xs:string" select="'translation'"/>

    <!-- a sequence of language codes for which the direction is right to left -->
    <xsl:param name="i18n:rtl-languages" as="xs:string*" select="('ar', 'he')"/>

    <!-- a sensible value is e.g. /TEI/@xml:lang -->
    <xsl:variable name="i18n:default-language" as="xs:string" visibility="abstract"/>



    <!-- tempates for generating java script needed for i18next -->

    <!-- this template makes java script code for inlining the translation files into a <script> block (strict loading) -->
    <xsl:template name="i18n:language-resources-inline">
        <xsl:param name="directory" as="xs:string"/>
        <xsl:param name="namespace" as="xs:string"/>
        <xsl:param name="base-uri" as="xs:string" select="static-base-uri()" required="false"/>
        <xsl:text>&newline;</xsl:text>
        <xsl:text>//import i18next from 'i18next';&newline;</xsl:text>
        <xsl:for-each select="$i18n:locales">
            <xsl:variable name="translation-file"
                select="resolve-uri(concat($directory, '/', ., '/', $namespace, '.json'), $base-uri)"/>
            <!-- FIXME: why doesn't doc-available() work as expected? -->
            <xsl:if test="true() or doc-available($translation-file)">
                <xsl:text>&newline;</xsl:text>
                <xsl:text>i18next.addResourceBundle('</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>', '</xsl:text>
                <xsl:value-of select="$namespace"/>
                <xsl:text>', </xsl:text>
                <xsl:value-of select="unparsed-text($translation-file)"/>
                <xsl:text>);&newline;</xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>i18next.addResourceBundle('dev', '</xsl:text>
        <xsl:value-of select="$namespace"/>
        <xsl:text>', {});&newline;</xsl:text>
    </xsl:template>

    <xsl:template name="i18n:initialisation">
        <xsl:text>&newline;</xsl:text>
        <xsl:text>const defaultNamespace = '</xsl:text>
        <xsl:value-of select="$i18n:default-namespace"/>
        <xsl:text>';&newline;</xsl:text>
        <xsl:text>const defaultLanguage = 'dev';&newline;</xsl:text>
        <xsl:text>const initialLanguage = '</xsl:text>
        <xsl:value-of select="$i18n:default-language"/>
        <xsl:text>';&newline;</xsl:text>
    </xsl:template>

    <!-- do everything needed for i18next -->
    <xsl:template name="i18n:load-javascript">
        <script src="{$i18n:i18next}"/>
        <script>
            <xsl:call-template name="i18n:initialisation"/>
        </script>
        <script src="{resolve-uri($i18n:js, static-base-uri())}">
            <!--xsl:value-of select="unparsed-text(resolve-uri($i18n, static-base-uri()))"/-->
        </script>
        <script type="module">
            <xsl:call-template name="i18n:language-resources-inline">
                <xsl:with-param name="directory" select="$i18n:locales-directory"/>
                <xsl:with-param name="namespace" select="$i18n:default-namespace"/>
            </xsl:call-template>
        </script>
    </xsl:template>

    <!-- language chooser  -->
    <xsl:template name="i18n:language-chooser">
        <section class="i18n-language-chooser">
            <xsl:for-each select="$i18n:locales">
                <button onclick="i18next.changeLanguage('{.}')">
                    <xsl:value-of select="."/>
                </button>
                <xsl:text> </xsl:text>
            </xsl:for-each>
            <button onclick="i18next.changeLanguage('dev')"
                xsl:use-when="system-property('debug') eq 'true'"> Dev </button>
        </section>
    </xsl:template>

    <xsl:template name="i18n:direction-indicator">
        <span id="i18n-direction-indicator">initial</span>
    </xsl:template>



    <!-- functions and templates to get language and script specific things done -->

    <!-- better use standard XPath function instead -->
    <xsl:function name="i18n:language">
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
    <xsl:function name="i18n:language" visibility="public">
        <xsl:param name="context" as="node()"/>
        <xsl:value-of select="i18n:language($context, $i18n:default-language)"/>
    </xsl:function>

    <!-- get the direction CSS code for the context's language -->
    <xsl:function name="i18n:language-direction" visibility="public">
        <xsl:param name="context" as="node()"/>
        <xsl:param name="default" as="xs:string"/>
        <xsl:variable name="lang" as="xs:string" select="i18n:language($context, $default)"/>
        <xsl:value-of select="i18n:language-code-to-direction($lang)"/>
    </xsl:function>

    <!-- get the direction for a language code -->
    <xsl:function name="i18n:language-code-to-direction" as="xs:string" visibility="public">
        <xsl:param name="lang" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="some $l in $i18n:rtl-languages satisfies $l eq $lang">
                <xsl:value-of select="'rtl'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'ltr'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="i18n:language-direction" visibility="public">
        <xsl:param name="context" as="node()"/>
        <xsl:value-of select="i18n:language-direction($context, $i18n:default-language)"/>
    </xsl:function>

    <!-- get a Unicode bidi embedding for the language at context. You should pop directional formatting (pdf) afterwards! -->
    <xsl:function name="i18n:direction-embedding">
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
    <xsl:function name="i18n:language-align">
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
    <xsl:function name="i18n:language-align">
        <xsl:param name="context" as="node()"/>
        <xsl:value-of select="i18n:language-align($context, $i18n:default-language)"/>
    </xsl:function>

    <!-- make HTML5 and XHTML language attributes reflecting the language at $context -->
    <xsl:template name="i18n:lang-attributes">
        <xsl:param name="context" as="node()"/>
        <xsl:variable name="lang" select="i18n:language($context)"/>
        <xsl:attribute name="lang" select="$lang"/>
        <xsl:attribute name="xml:lang" select="$lang"/>
    </xsl:template>

    <!-- make HTML5 and XHTML language attributes reflecting the language at current dynamic context -->
    <xsl:template name="i18n:lang-attributes-here">
        <xsl:variable name="lang" select="i18n:language(.)"/>
        <xsl:attribute name="lang" select="$lang"/>
        <xsl:attribute name="xml:lang" select="$lang"/>
    </xsl:template>

    <!-- make an extra space text node when changing from ltr to rtl script -->
    <xsl:template name="i18n:ltr-to-rtl-extra-space">
        <xsl:param name="first-direction" as="xs:string"/>
        <xsl:param name="then-direction" as="xs:string"/>
        <xsl:if
            test="$first-direction eq 'ltr' and $then-direction ne 'ltr' and $i18n:ltr-to-rtl-extra-space">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>


    <!-- CSS templates (deprecated) -->

    <xsl:template name="i18n:direction-style">
        <style>
            <xsl:text>&newline;body { direction: </xsl:text>
            <xsl:value-of select="i18n:language-direction(TEI/text)"/>
            <xsl:text>; }</xsl:text>
            <xsl:text>&newline;.variants { direction: </xsl:text>
            <xsl:value-of select="i18n:language-direction(TEI/text)"/>
            <xsl:text>; }</xsl:text>
            <xsl:text>&newline;.comments { direction: </xsl:text>
            <xsl:value-of select="i18n:language-direction(TEI/text)"/>
            <xsl:text>; }</xsl:text>
            <xsl:text>&newline;td { text-align: </xsl:text>
            <xsl:value-of select="i18n:language-align(TEI/text)"/>
            <xsl:text>; justify-content: space-between; justify-self: stretch; } </xsl:text>
        </style>
    </xsl:template>

</xsl:package>
