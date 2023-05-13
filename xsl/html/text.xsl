<?xml version="1.0" encoding="UTF-8"?>
<!-- a transformation that just outputs the text using libtext.xsl

This is mainly for testing libtext.xsl, but can be used to get a <div>
containing the text.
-->
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/test-libtext.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:text="http://scdh.wwu.de/transform/text#"
  exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0"
  default-mode="text:text">

  <xsl:param name="apparatus-entries" as="map(xs:string, map(*))" select="map {}" required="false"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libtext.xsl"
    package-version="1.0.0">
    <xsl:accept component="mode" names="*" visibility="public"/>
    <xsl:override>

      <xsl:variable name="text:apparatus-entries" as="map(xs:string, map(*))"
        select="$apparatus-entries"/>

      <xsl:template mode="text:hook-after" match="sic">
        <xsl:text> [sic!]</xsl:text>
      </xsl:template>

      <xsl:variable name="i18n:default-language" as="xs:string" select="(/*/@xml:lang, 'en')[1]"/>

    </xsl:override>
  </xsl:use-package>

</xsl:package>
