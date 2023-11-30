<?xml version="1.0" encoding="UTF-8"?>
<!-- apparatus criticus for ALEA projects -->
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libapp2.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:app="http://scdh.wwu.de/transform/app#"
  xmlns:test="http://scdh.wwu.de/transform/test#" xmlns:seed="http://scdh.wwu.de/transform/seed#"
  xmlns:common="http://scdh.wwu.de/transform/common#"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="3.1">

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libwit.xsl"
    package-version="1.0.0"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libapp2.xsl"
    package-version="1.0.0">

    <xsl:override>

      <!-- apparatus entries made for parallel segementation -->
      <xsl:variable name="app:entries-xpath-internal-parallel-segmentation" as="xs:string"
        visibility="public">
        <xsl:value-of>
          <xsl:text>descendant::app[not(parent::sic[parent::choice])]</xsl:text>
          <xsl:text>| descendant::witDetail[not(parent::app)]</xsl:text>
          <xsl:text>| descendant::corr[not(parent::choice)]</xsl:text>
          <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
          <xsl:text>| descendant::choice[sic and corr]</xsl:text>
          <xsl:text>| descendant::unclear[not(parent::choice | ancestor::rdg)]</xsl:text>
          <xsl:text>| descendant::choice[unclear]</xsl:text>
          <xsl:text>| descendant::gap[not(ancestor::rdg)]</xsl:text>
          <xsl:text>| descendant::space[not(ancestor::rdg)]</xsl:text>
          <xsl:text>| descendant::supplied</xsl:text>
        </xsl:value-of>
      </xsl:variable>

      <!-- XPath describing apparatus entries made for internal double end-point variant encoding -->
      <xsl:variable name="app:entries-xpath-internal-double-end-point" as="xs:string"
        visibility="public">
        <xsl:value-of>
          <xsl:text>descendant::app[not(parent::sic[parent::choice])]</xsl:text>
          <xsl:text>| descendant::witDetail[not(parent::app)]</xsl:text>
          <xsl:text>| descendant::corr[not(parent::choice)]</xsl:text>
          <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
          <xsl:text>| descendant::choice[sic and corr]</xsl:text>
          <xsl:text>| descendant::unclear[not(parent::choice | ancestor::rdg)]</xsl:text>
          <xsl:text>| descendant::choice[unclear]</xsl:text>
          <xsl:text>| descendant::gap[not(ancestor::rdg)]</xsl:text>
          <xsl:text>| descendant::space[not(ancestor::rdg)]</xsl:text>
          <xsl:text>| descendant::supplied</xsl:text>
        </xsl:value-of>
      </xsl:variable>

      <!-- XPath describing apparatus entries made for external double end-point variant encoding -->
      <xsl:variable name="app:entries-xpath-external-double-end-point" as="xs:string"
        visibility="public">
        <xsl:value-of>
          <xsl:text>descendant::app</xsl:text>
          <xsl:text>| descendant::witDetail[not(parent::app)]</xsl:text>
          <xsl:text>| descendant::corr[not(parent::choice)]</xsl:text>
          <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
          <xsl:text>| descendant::choice[sic and corr]</xsl:text>
          <xsl:text>| descendant::unclear[not(parent::choice | ancestor::rdg)]</xsl:text>
          <xsl:text>| descendant::choice[unclear]</xsl:text>
          <xsl:text>| descendant::gap[not(ancestor::rdg)]</xsl:text>
          <xsl:text>| descendant::space[not(ancestor::rdg)]</xsl:text>
          <xsl:text>| descendant::supplied</xsl:text>
        </xsl:value-of>
      </xsl:variable>

      <!-- when no variant encoding is present -->
      <xsl:variable name="app:entries-xpath-no-textcrit" as="xs:string" visibility="public">
        <xsl:value-of>
          <xsl:text>descendant::corr[not(parent::choice)]</xsl:text>
          <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
          <xsl:text>| descendant::choice[sic and corr]</xsl:text>
          <xsl:text>| descendant::unclear[not(parent::choice)]</xsl:text>
          <xsl:text>| descendant::choice[unclear]</xsl:text>
          <xsl:text>| descendant::gap</xsl:text>
          <xsl:text>| descendant::space</xsl:text>
          <xsl:text>| descendant::supplied</xsl:text>
        </xsl:value-of>
      </xsl:variable>

      <!-- use libwit in apparatus -->
      <xsl:template name="app:sigla">
        <xsl:param name="wit" as="node()"/>
        <xsl:call-template name="wit:sigla">
          <xsl:with-param name="wit" select="$wit"/>
        </xsl:call-template>
      </xsl:template>

    </xsl:override>

  </xsl:use-package>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libentry2.xsl"
    package-version="1.0.0">
    <xsl:accept component="function" names="seed:shorten-lemma#1" visibility="hidden"/>
    <xsl:accept component="function" names="seed:note-based-apparatus-nodes-map#2"
      visibility="public"/>
  </xsl:use-package>

  <!-- a utility just for unit testing the apparatus -->
  <xsl:template name="test:single-app-entry" visibility="final">
    <xsl:variable name="entries"
      select="app:apparatus-entries(.) => seed:note-based-apparatus-nodes-map(true())"/>
    <xsl:call-template name="app:note-based-apparatus">
      <xsl:with-param name="entries" select="$entries"/>
    </xsl:call-template>
  </xsl:template>


</xsl:package>
