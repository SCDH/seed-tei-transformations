<!-- this is for testing the generation of the apparatus with libapp2 -->
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libapp2-testwrapper.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:app="http://scdh.wwu.de/transform/app#"
  xmlns:seed="http://scdh.wwu.de/transform/seed#"
  xmlns:common="http://scdh.wwu.de/transform/common#"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="3.1">

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libapp2.xsl"
    package-version="1.0.0">
    <xsl:accept component="function" names="app:*" visibility="public"/>
    <xsl:accept component="template" names="app:*" visibility="public"/>
  </xsl:use-package>

</xsl:package>
