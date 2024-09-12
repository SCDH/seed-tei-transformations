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

  <!-- a sequence of CSS files -->
  <xsl:param name="html:css" as="xs:string*" select="tokenize($html:css-csv, ',')"/>

  <!-- URLs to CSS, separated by comma -->
  <xsl:param name="html:css-csv" as="xs:string" select="''"/>

  <!-- should be one of 'internal', 'absolute', 'relative' -->
  <xsl:param name="html:css-method" as="xs:string" select="'internal'"/>

  <!-- a sequence of Javascript modules to be linked -->
  <xsl:param name="html:js-modules" as="xs:string*" select="tokenize($html:js-modules-csv, ',')"/>

  <!-- Javascript modules to be linked, multiple URLs separated by commas -->
  <xsl:param name="html:js-modules-csv" as="xs:string" select="''"/>

  <!-- a sequence of Javascript files to be included on the header -->
  <xsl:param name="html:js" as="xs:string*" select="tokenize($html:js-csv, ',')"/>

  <!-- URLs to Javascript files to be included in the header, separated by comma -->
  <xsl:param name="html:js-csv" as="xs:string" select="''"/>

  <!-- should be one of 'internal', 'absolute', 'relative' -->
  <xsl:param name="html:js-method" as="xs:string" select="'internal'"/>

  <!-- a sequence of javascript files to be included after the document body -->
  <xsl:param name="html:after-body-js" as="xs:string*"
    select="tokenize($html:after-body-js-csv, ',')"/>

  <!-- URLs to Javascript files to be included after the document body, separated by comma -->
  <xsl:param name="html:after-body-js-csv" as="xs:string" select="''"/>

  <!-- the canonical URL, if not set, a default value will be used -->
  <xsl:param name="html:canonical" as="xs:string" select="''"/>

  <xsl:variable name="html:canonical-uri" as="xs:string" select="''" visibility="public"/>


  <!-- a second way additional to $html:css to pass in CSS files -->
  <xsl:variable name="html:extra-css" as="xs:anyURI*" select="()" visibility="public"/>


  <xsl:param name="html:title-sep" as="xs:string" select="' :: '"/>

  <xsl:param name="html:title-suffix" as="xs:string?" select="'SEED TEI Transformations'"/>


  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libi18n.xsl"
    package-version="0.1.0">
    <xsl:accept component="function" names="i18n:language#1" visibility="private"/>
  </xsl:use-package>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libprose.xsl"
    package-version="1.0.0"/>

  <xsl:mode name="html:html" on-no-match="shallow-skip" visibility="public"/>

  <!-- Downstream packages may call the default mode on the document node or on the root element. -->
  <xsl:template match="document-node() | /* | *">
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
        <xsl:variable name="canonical" as="xs:string">
          <xsl:choose>
            <xsl:when test="$html:canonical ne ''">
              <xsl:value-of select="$html:canonical"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="base-uri()"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <link rel="canonical" href="{$canonical}"/>
        <xsl:call-template name="html:rendition-css"/>
        <xsl:call-template name="html:css"/>
        <xsl:call-template name="html:js-modules"/>
        <xsl:call-template name="html:js"/>
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
      <xsl:call-template name="html:after-body-js"/>
    </html>
  </xsl:template>

  <xsl:template name="html:meta-hook" visibility="public">
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  </xsl:template>

  <xsl:template name="html:title" visibility="public">
    <xsl:value-of
      select="((//title ! normalize-space()), $html:title-suffix) => string-join($html:title-sep)"/>
  </xsl:template>

  <xsl:template name="html:css" visibility="public">
    <xsl:variable name="base-uri" select="base-uri()"/>
    <xsl:choose>
      <xsl:when test="$html:css-method eq 'internal'">
        <xsl:for-each select="$html:extra-css, $html:css">
          <xsl:variable name="href" select="resolve-uri(., $base-uri)"/>
          <xsl:choose>
            <xsl:when test="unparsed-text-available($href)">
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
      </xsl:when>
      <xsl:when test="$html:css-method eq 'absolute'">
        <xsl:for-each select="$html:css">
          <link rel="stylesheet" type="text/css" href="{resolve-uri(., $base-uri)}"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$html:css-method eq 'relative'">
        <xsl:for-each select="$html:css">
          <link rel="stylesheet" type="text/css" href="{.}"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          <xsl:text>ERROR: invalid value for parameter html:css-method: </xsl:text>
          <xsl:value-of select="$html:css-method"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="html:additional-css"/>
  </xsl:template>

  <xsl:template name="html:additional-css" visibility="public"/>

  <xsl:template name="html:js-modules">
    <xsl:variable name="base-uri" select="base-uri()"/>
    <xsl:for-each select="$html:js-modules">
      <script type="module" src="{resolve-uri(., $base-uri)}"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="html:js">
    <xsl:variable name="base-uri" select="base-uri()"/>
    <xsl:choose>
      <xsl:when test="$html:js-method eq 'internal'">
        <xsl:for-each select="$html:js">
          <xsl:variable name="href" select="resolve-uri(., $base-uri)"/>
          <xsl:choose>
            <xsl:when test="unparsed-text-available($href)">
              <xsl:comment>
                <xsl:text>JS from </xsl:text>
                <xsl:value-of select="$href"/>
              </xsl:comment>
              <script type="text/javascript">
                <xsl:value-of select="unparsed-text($href)"/>
              </script>
            </xsl:when>
            <xsl:otherwise>
              <xsl:comment>
              <xsl:text>JS not available </xsl:text>
              <xsl:value-of select="$href"/>
            </xsl:comment>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$html:js-method eq 'absolute'">
        <xsl:for-each select="$html:js">
          <script type="text/javascript" src="{resolve-uri(., $base-uri)}"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$html:js-method eq 'relative'">
        <xsl:for-each select="$html:js">
          <script type="text/javascript" src="{.}"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          <xsl:text>ERROR: invalid value for parameter html:js-method: </xsl:text>
          <xsl:value-of select="$html:js-method"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="html:additional-js"/>
  </xsl:template>

  <xsl:template name="html:additional-js" visibility="public"/>

  <xsl:template name="html:after-body-js" visibility="public">
    <!-- javascript after the body is always internalized -->
    <xsl:variable name="base-uri" select="base-uri()"/>
    <xsl:variable name="base-uri" select="base-uri()"/>
    <xsl:choose>
      <xsl:when test="$html:js-method eq 'internal'">
        <xsl:for-each select="$html:after-body-js">
          <xsl:variable name="href" select="resolve-uri(., $base-uri)"/>
          <xsl:choose>
            <xsl:when test="unparsed-text-available($href)">
              <xsl:comment>
                <xsl:text>JS from </xsl:text>
                <xsl:value-of select="$href"/>
              </xsl:comment>
              <script type="text/javascript">
                <xsl:value-of select="unparsed-text($href)"/>
              </script>
            </xsl:when>
            <xsl:otherwise>
              <xsl:comment>
              <xsl:text>JS not available </xsl:text>
              <xsl:value-of select="$href"/>
            </xsl:comment>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$html:js-method eq 'absolute'">
        <xsl:for-each select="$html:after-body-js">
          <script type="text/javascript" src="{resolve-uri(., $base-uri)}"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$html:js-method eq 'relative'">
        <xsl:for-each select="$html:after-body-js">
          <script type="text/javascript" src="{.}"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          <xsl:text>ERROR: invalid value for parameter html:js-method: </xsl:text>
          <xsl:value-of select="$html:js-method"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="html:after-body-additional-js"/>
  </xsl:template>

  <xsl:template name="html:after-body-additional-js" visibility="public"/>

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


  <xsl:template name="html:rendition-css" as="item()*" visibility="public">
    <xsl:context-item as="node()" use="required"/>
    <xsl:variable name="root" select="root(.)"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:comment>CSS from tagsDecl/rendition</xsl:comment>
    <xsl:text>&#xa;</xsl:text>
    <style>
      <xsl:apply-templates mode="html:css"
        select="$root//teiHeader/encodingDesc/tagsDecl/rendition[@scheme eq 'css']"/>
    </style>
    <xsl:text>&#xa;</xsl:text>
  </xsl:template>

  <xsl:mode name="html:css" on-no-match="shallow-skip" visibility="public"/>

  <xsl:template mode="html:css" match="rendition[@selector]">
    <xsl:text>&#xa;</xsl:text>
    <xsl:value-of select="@selector"/>
    <xsl:text> { </xsl:text>
    <xsl:value-of select="text()"/>
    <xsl:text> } </xsl:text>
  </xsl:template>

  <xsl:template mode="html:css" match="rendition[@xml:id and not(@selector)]">
    <xsl:text>&#xa;.</xsl:text>
    <xsl:value-of select="@xml:id"/>
    <xsl:text> { </xsl:text>
    <xsl:value-of select="text()"/>
    <xsl:text> } </xsl:text>
  </xsl:template>

  <xsl:template mode="html:css" match="rendition[empty(node())]" priority="10"/>


</xsl:package>
