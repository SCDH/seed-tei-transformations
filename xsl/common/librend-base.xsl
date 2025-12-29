<?xml version="1.0" encoding="UTF-8"?>
<!-- a base package that defines modes for text reproduction where formatting is needed

This package base package provides modes for all text reproductive modes.
These modes are empty.

TODO: Consider and decide! Should we declare only one mode, instead of multiple modes. The XSLT
package system would allow this and even its adaption in a branch of the package hierarchy.
-->
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/librend-base.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:text="http://scdh.wwu.de/transform/text#"
  xmlns:app="http://scdh.wwu.de/transform/app#" xmlns:note="http://scdh.wwu.de/transform/note#"
  xmlns:i18n="http://scdh.wwu.de/transform/i18n#" exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

  <xsl:mode name="text:text" on-no-match="text-only-copy" visibility="public"/>
  <xsl:mode name="app:reading-text" on-no-match="text-only-copy" visibility="public"/>
  <xsl:mode name="note:editorial" on-no-match="text-only-copy" visibility="public"/>

  <!-- drop attributes for which there is not special rule -->
  <xsl:template mode="text:text app:reading-text note:editorial" match="@*"/>

  <xsl:template name="text:class-attribute" visibility="abstract">
    <xsl:param name="context" as="element()" select="." required="false"/>
    <xsl:param name="additional" as="xs:string*" select="()" required="false"/>
  </xsl:template>

  <xsl:template name="text:class-attribute-opt" visibility="abstract">
    <xsl:param name="context" as="element()" select="." required="false"/>
    <xsl:param name="additional" as="xs:string*" select="()" required="false"/>
  </xsl:template>

</xsl:package>
