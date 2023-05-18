<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT package with components for a HTML output file

Note, that the default mode is html:html!
-->
<!DOCTYPE package [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
    <!ENTITY nbsp "&#xa0;" >
    <!ENTITY emsp "&#x2003;" >
    <!ENTITY lb "&#xa;" >
]>
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libhtml.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:app="http://scdh.wwu.de/transform/app#"
  xmlns:seed="http://scdh.wwu.de/transform/seed#"
  xmlns:common="http://scdh.wwu.de/transform/common#"
  xmlns:html="http://scdh.wwu.de/transform/html#"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="3.1"
  default-mode="html:html">

  <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

  <xsl:param name="html:css" as="xs:string*" select="()"/>

  <xsl:param name="html:css-internal" as="xs:boolean" select="true()"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libi18n.xsl"
    package-version="0.1.0">
    <xsl:accept component="function" names="i18n:language#1" visibility="private"/>
  </xsl:use-package>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libprose.xsl"
    package-version="1.0.0"/>

  <xsl:mode name="html:html" on-no-match="shallow-skip" visibility="public"/>

  <xsl:template match="/*">
    <xsl:text disable-output-escaping="yes" use-when="false()">&lt;!DOCTYPE html&gt;&lb;</xsl:text>
    <xsl:for-each select="//xi:include">
      <xsl:message>
        <xsl:call-template name="html:xi-warning">
          <xsl:with-param name="include-element" select="."/>
        </xsl:call-template>
      </xsl:message>
      <xsl:comment>
        <xsl:call-template name="html:xi-warning">
          <xsl:with-param name="include-element" select="."/>
        </xsl:call-template>
      </xsl:comment>
    </xsl:for-each>
    <html lang="{i18n:language(.)}">
      <xsl:if test="@xml:id">
        <xsl:attribute name="id" select="@xml:id"/>
      </xsl:if>
      <head>
        <meta charset="utf-8"/>
        <xsl:call-template name="html:meta-hook"/>
        <title>
          <xsl:call-template name="html:title"/>
        </title>
        <xsl:call-template name="html:css"/>
        <xsl:call-template name="html:last-in-head-hook"/>
      </head>
      <body>
        <xsl:call-template name="html:first-in-body-hook"/>
        <div class="content">
          <xsl:call-template name="html:content"/>
        </div>
        <xsl:call-template name="html:last-in-body-hook"/>
      </body>
      <xsl:call-template name="html:after-body-hook"/>
    </html>
  </xsl:template>

  <xsl:template name="html:meta-hook" visibility="public">
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  </xsl:template>

  <xsl:template name="html:title" visibility="public">
    <xsl:value-of select="(//title ! normalize-space()) => string-join(' :: ')"/>
    <xsl:text> :: SEED transformations</xsl:text>
  </xsl:template>

  <xsl:template name="html:css" visibility="public">
    <xsl:choose>
      <xsl:when test="$html:css-internal">
        <xsl:for-each select="$html:css">
          <link rel="stylesheet" type="text/css" href="resolve-uri(., base-uri())"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="root" select="root()"/>
        <xsl:for-each select="$html:css">
          <xsl:variable name="href" select="resolve-uri(., base-uri($root))"/>
          <xsl:choose>
            <xsl:when test="doc-available($href)">
              <xsl:comment>
                <xsl:text>CSS from </xsl:text>
                <xsl:value-of select="$href"/>
              </xsl:comment>
              <style>
                <xsl:value-of select="unparsed-text($href)"/>
              </style>
            </xsl:when>
            <xsl:otherwise>
              <xsl:comment>
              <xsl:text>CSS not available </xsl:text>
              <xsl:value-of select="$href"/>
            </xsl:comment>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="html:additional-css"/>
  </xsl:template>

  <xsl:template name="html:additional-css" visibility="public"/>

  <xsl:template name="html:last-in-head-hook" visibility="public"/>

  <xsl:template name="html:content" visibility="public"/>

  <xsl:template name="html:first-in-body-hook" visibility="public"/>
  <xsl:template name="html:last-in-body-hook" visibility="public"/>

  <xsl:template name="html:after-body-hook" visibility="public"/>

  <xsl:template name="html:xi-warning" visibility="final">
    <xsl:param name="include-element" as="element()"/>
    <xsl:text>WARNING: </xsl:text>
    <xsl:text>XInclude element not expanded! @href="</xsl:text>
    <xsl:value-of select="$include-element/@href"/>
    <xsl:text>" @xpointer="</xsl:text>
    <xsl:value-of select="$include-element/@xpointer"/>
    <xsl:text>"</xsl:text>
  </xsl:template>

</xsl:package>
