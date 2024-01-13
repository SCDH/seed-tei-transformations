<?xml version="1.0" encoding="UTF-8"?>
<!-- a transformation that just outputs the text using libprose.xsl and outputting apparatus and notes as popups -->
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/prose-with-popups.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:text="http://scdh.wwu.de/transform/text#"
  xmlns:html="http://scdh.wwu.de/transform/html#" xmlns:app="http://scdh.wwu.de/transform/app#"
  xmlns:seed="http://scdh.wwu.de/transform/seed#" xmlns:prose="http://scdh.wwu.de/transform/prose#"
  exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0"
  default-mode="prose">

  <xsl:output method="html" encoding="UTF-8"/>

  <!-- whether to use the HTML template from libhtml and make a full HTML file -->
  <xsl:param name="use-libhtml" as="xs:boolean" select="false()"/>

  <xsl:param name="default-language" as="xs:string" select="'en'"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libi18n.xsl"
    package-version="0.1.0">
    <xsl:override>
      <xsl:variable name="i18n:default-language" as="xs:string" select="$default-language"/>
    </xsl:override>
  </xsl:use-package>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libentry2.xsl"
    package-version="1.0.0">
    <xsl:accept component="function" names="seed:note-based-apparatus-nodes-map#2"
      visibility="public"/>
    <xsl:accept component="function" names="seed:shorten-lemma#1" visibility="hidden"/>
    <xsl:accept component="mode" names="*" visibility="public"/>
    <xsl:accept component="mode" names="seed:lemma-text-nodes" visibility="hidden"/>
  </xsl:use-package>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libapp2.xsl"
    package-version="1.0.0">
    <xsl:accept component="*" names="*" visibility="public"/>
    <xsl:accept component="variable" names="app:popup-css" visibility="final"/>
    <xsl:accept component="mode" names="seed:lemma-text-nodes" visibility="public"/>
  </xsl:use-package>

  <xsl:variable name="prose:apparatus-entries" as="map(xs:string, map(*))" visibility="public"
    select="app:apparatus-entries(/) => seed:note-based-apparatus-nodes-map(true())"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libprose.xsl"
    package-version="1.0.0">
    <xsl:accept component="mode" names="*" visibility="public"/>

    <xsl:override>
      <xsl:template name="text:inline-marks">
        <xsl:call-template name="app:inline-alternatives">
          <xsl:with-param name="entries" select="map:merge($prose:apparatus-entries)"/>
        </xsl:call-template>
      </xsl:template>
    </xsl:override>
  </xsl:use-package>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libhtml.xsl"
    package-version="1.0.0">

    <xsl:accept component="mode" names="html:html" visibility="public"/>
    <xsl:accept component="template" names="html:*" visibility="public"/>

    <xsl:override>

      <xsl:template name="html:content">
        <xsl:apply-templates mode="text:text"/>
      </xsl:template>

      <xsl:variable name="html:extra-css" as="xs:anyURI*" select="$app:popup-css" visibility="public"/>

    </xsl:override>
  </xsl:use-package>

  <xsl:mode name="prose" on-no-match="shallow-skip" visibility="public"/>

  <!-- if parameter $use-libhtml is true, switch to html:html mode -->
  <xsl:template match="/" mode="prose">
    <xsl:choose>
      <xsl:when test="$use-libhtml">
        <xsl:apply-templates mode="html:html" select="root()"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- how is app:popup-css passed into? -->
        <xsl:apply-templates mode="text:text" select="//body"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:package>
