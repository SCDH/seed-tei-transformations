<?xml version="1.0" encoding="UTF-8"?>
<!-- a package based on common/librend-base

Replace this package with one with your project-specific and output-specific
rules for formatting the text.
-->
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/librend.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:text="http://scdh.wwu.de/transform/text#"
  xmlns:app="http://scdh.wwu.de/transform/app#" xmlns:note="http://scdh.wwu.de/transform/note#"
  xmlns:i18n="http://scdh.wwu.de/transform/i18n#" exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/librend-base.xsl"
    package-version="1.0.0">
    <xsl:accept component="mode" names="*" visibility="public"/>
    <xsl:accept component="template" names="text:*" visibility="public"/>
    <xsl:override>

      <!-- just a dumb implementation that produces no output -->
      <xsl:template name="text:class-attribute" visibility="public">
        <xsl:param name="context" as="element()" select="." required="false"/>
        <xsl:param name="additional" as="xs:string*" select="()" required="false"/>
      </xsl:template>

      <!-- just a dumb implementation that produces no output -->
      <xsl:template name="text:class-attribute-opt" visibility="public">
        <xsl:param name="context" as="element()" select="." required="false"/>
        <xsl:param name="additional" as="xs:string*" select="()" required="false"/>
      </xsl:template>

    </xsl:override>
  </xsl:use-package>

</xsl:package>
