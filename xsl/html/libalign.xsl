<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libalign.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:align="http://scdh.wwu.de/transform/align#" exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

  <!-- adds attributes containing available alignment information on different levels:
    current page, region, line and node -->
  <xsl:template name="align:annotation" as="attribute()*" visibility="final">
    <xsl:context-item as="node()" use="required"/>
    <xsl:variable name="current-page" as="element(pb)?" select="preceding::pb[1]"/>
    <xsl:if test="$current-page/@xml:id">
      <xsl:attribute name="data-align-page" select="$current-page/@xml:id"/>
    </xsl:if>
    <xsl:variable name="current-region" as="element()?" select="ancestor-or-self::p[1]"/>
    <xsl:if test="$current-region/@xml:id">
      <xsl:attribute name="data-align-region" select="$current-region/@xml:id"/>
    </xsl:if>
    <xsl:variable name="current-line" as="element()?"
      select="(preceding::lb[1], ancestor-or-self::l[1])[1]"/>
    <xsl:if test="$current-line/@xml:id">
      <xsl:attribute name="data-align-line" select="$current-line/@xml:id"/>
    </xsl:if>
    <xsl:variable name="current-word" as="element()?" select="ancestor-or-self::w[1]"/>
    <xsl:if test="$current-word/@xml:id">
      <xsl:attribute name="data-align-word" select="$current-word/@xml:id"/>
    </xsl:if>
  </xsl:template>

  <!-- wraps a text node into span element and adds alignment information to it -->
  <xsl:template name="align:text-node-wrapper" visibility="final">
    <xsl:context-item as="text()" use="required"/>
    <span class="aligned-leaf">
      <xsl:attribute name="xml:id" select="generate-id()"/>
      <xsl:call-template name="align:annotation"/>
      <xsl:copy/>
    </span>
  </xsl:template>

</xsl:package>
