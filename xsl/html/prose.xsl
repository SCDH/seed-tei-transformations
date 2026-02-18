<?xml version="1.0" encoding="UTF-8"?>
<!-- a transformation that just outputs the text using libprose.xsl -->
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/prose.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:text="http://scdh.wwu.de/transform/text#"
  xmlns:html="http://scdh.wwu.de/transform/html#" exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0" default-mode="prose">

  <xsl:output method="html" encoding="UTF-8"/>

  <!-- whether to use the HTML template from libhtml and make a full HTML file -->
  <xsl:param name="use-libhtml" as="xs:boolean" select="true()"/>


  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libprose.xsl"
    package-version="1.0.0">
    <xsl:accept component="mode" names="*" visibility="public"/>
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
        <xsl:apply-templates mode="text:text" select="//body"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:package>
