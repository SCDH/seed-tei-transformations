<!-- Generate mappings for selectors into an XML source and an HTML projection

The HTML projection, serialized to XHTML, is expected as context item.
It is also expected to contain source annotations by xsl/common/libsource.xsl

-->
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/json/srcmap.xsl"
  package-version="1.0.0" version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:array="http://www.w3.org/2005/xpath-functions/array"
  xmlns:source="http://scdh.wwu.de/transform/source#" exclude-result-prefixes="#all"
  default-mode="source:reverse-map">

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libsource.xsl"
    package-version="1.0.0">
    <xsl:accept component="mode" names="source:reverse-map" visibility="public"/>
  </xsl:use-package>

  <xsl:output method="json" indent="true" encoding="UTF-8"/>

</xsl:package>
