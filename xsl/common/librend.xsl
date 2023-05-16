<?xml version="1.0" encoding="UTF-8"?>
<!-- a package that defines modes for text reproduction where formatting is needed

This package base package provides modes for all text reproductive modes.
These modes are empty. Replace this package with one with your project-specific and output-specific
rules for formatting the text.

TODO: Consider and decide! Should we declare only one mode, instead of multiple modes. The XSLT
package system would allow this and even its adaption in a branch of the package hierarchy.
-->
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/librend.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:text="http://scdh.wwu.de/transform/text#"
  xmlns:app="http://scdh.wwu.de/transform/app#" xmlns:note="http://scdh.wwu.de/transform/note#"
  xmlns:i18n="http://scdh.wwu.de/transform/i18n#" exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

  <xsl:mode name="text:text" on-no-match="text-only-copy" visibility="public"/>
  <xsl:mode name="app:reading-text" on-no-match="text-only-copy" visibility="public"/>
  <xsl:mode name="note:editorial" on-no-match="text-only-copy" visibility="public"/>

</xsl:package>
