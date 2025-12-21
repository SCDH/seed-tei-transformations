<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libcompat.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:compat="http://scdh.wwu.de/transform/compat#"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="3.0">

  <!-- compat:first-child = true changes the default behaviour of some encoding christals with alternative text -->
  <xsl:param name="compat:first-child" as="xs:boolean" select="false()" static="true"/>

</xsl:package>
