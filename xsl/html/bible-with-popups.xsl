<?xml version="1.0" encoding="UTF-8"?>
<!-- a transformation for a book of the bible outputting apparatus and notes as popups -->
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/bible-with-popups.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:text="http://scdh.wwu.de/transform/text#"
  xmlns:html="http://scdh.wwu.de/transform/html#" xmlns:app="http://scdh.wwu.de/transform/app#"
  xmlns:seed="http://scdh.wwu.de/transform/seed#" xmlns:prose="http://scdh.wwu.de/transform/prose#"
  xmlns:bible="http://scdh.wwu.de/transform/bible#" exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0" default-mode="prose">

  <xsl:output method="html" encoding="UTF-8"/>

  <xsl:param name="chapter-verse-sep" as="xs:string" select="','"/>

  <xsl:param name="bible:css" as="xs:anyURI*" select="resolve-uri('bible.css', static-base-uri())"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/prose-with-popups.xsl"
    package-version="1.0.0">
    <xsl:accept component="*" names="*" visibility="public"/>
    <xsl:override>

      <!-- redefinition required due to global context item -->
      <xsl:variable name="prose:apparatus-entries" as="map(xs:string, map(*))" visibility="public"
        select="app:apparatus-entries(/) => seed:note-based-apparatus-nodes-map(true())"/>

      <xsl:variable name="html:extra-css" as="xs:anyURI*" select="($app:popup-css, $bible:css)"/>

      <!-- chapter.verse numbers in front of each verse -->
      <xsl:template mode="text:text" match="l[ancestor::lg]/@n">
        <xsl:attribute name="data-tei-n" select="."/>
        <xsl:attribute name="data-chapter-verse"
          select="concat((ancestor::lg[@n])[1]/@n, $chapter-verse-sep, .)"/>
      </xsl:template>

      <xsl:template mode="text:text" match="milestone">
        <div class="milestone">
          <xsl:apply-templates mode="text:text" select="@*"/>
        </div>
      </xsl:template>

    </xsl:override>
  </xsl:use-package>

</xsl:package>
