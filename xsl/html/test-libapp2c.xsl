<!-- utilities for testing the apparatus library -->
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libapp2.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:app="http://scdh.wwu.de/transform/app#"
  xmlns:test="http://scdh.wwu.de/transform/testapp#" xmlns:seed="http://scdh.wwu.de/transform/seed#"
  xmlns:common="http://scdh.wwu.de/transform/common#"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="3.1">

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libapp2.xsl"
    package-version="1.0.0"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libentry2.xsl"
    package-version="1.0.0">
    <xsl:accept component="function" names="seed:shorten-lemma#1" visibility="hidden"/>
    <xsl:accept component="function" names="seed:note-based-apparatus-nodes-map#2"
      visibility="public"/>
  </xsl:use-package>

  <xsl:template name="test:single-app-entry" visibility="public">
    <xsl:variable name="entries"
      select="app:apparatus-entries(.) => seed:note-based-apparatus-nodes-map(true())"/>
    <xsl:call-template name="app:note-based-apparatus">
      <xsl:with-param name="entries" select="$entries"/>
    </xsl:call-template>
  </xsl:template>


</xsl:package>
