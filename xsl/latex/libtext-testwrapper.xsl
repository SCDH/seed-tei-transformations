<!-- this is for testing -->
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libtext-testwrapper.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:i18n="http://scdh.wwu.de/transform/i18n#"
  xmlns:text="http://scdh.wwu.de/transform/text#"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="3.1"
  default-mode="text:text">

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libi18n.xsl"
    package-version="1.0.0">
    <xsl:override>
      <xsl:variable name="i18n:default-language" as="xs:string" select="'en'"/>
    </xsl:override>
  </xsl:use-package>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libtext.xsl"
    package-version="1.0.0">
    <xsl:accept component="*" names="text:*" visibility="public"/>
  </xsl:use-package>

</xsl:package>
