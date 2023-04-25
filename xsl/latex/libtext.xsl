<!DOCTYPE package [
    <!ENTITY lb "&#xa;" >
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >]>
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libtext.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:text="http://scdh.wwu.de/transform/text#"
  exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0"
  default-mode="text:text">

  <xsl:mode name="text:text" on-no-match="shallow-skip" visibility="public"/>

  <!-- you may want to override the rule content, e.g., by \txarb{.} -->
  <xsl:template match="text()">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="teiHeader"/>

  <!-- TODO -->
  <xsl:template match="front | back"/>

  <xsl:template match="body">
    <xsl:text>&lb;&lb;%% begin of text body&lb;&lb;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&lb;&lb;%% end of text body&lb;&lb;</xsl:text>
  </xsl:template>


  <!-- document structure -->

  <xsl:template match="head">
    <!-- TODO -->
    <xsl:text>&lb;&lb;\noindent{}</xsl:text>
    <xsl:text>&lb;\minisec{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="p">
    <xsl:call-template name="text:par-start"/>
    <xsl:apply-templates/>
    <xsl:text>&lb;&lb;&lb;</xsl:text>
  </xsl:template>

  <!-- a hook for macros at the beginning of a paragraph -->
  <xsl:template name="text:par-start" visibility="public"/>

  <xsl:template match="pb">
    <xsl:text>\pb{</xsl:text>
    <xsl:value-of select="@n"/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="milestone">
    <xsl:text>\milestone{</xsl:text>
    <xsl:value-of select="@n"/>
    <xsl:text>}{</xsl:text>
    <xsl:value-of select="@unit"/>
    <!--
    <xsl:text>}{</xsl:text>
    <xsl:value-of select="ancestor-or-self::*[@xml:lang]/@xml:lang"/>
    -->
    <xsl:text>}</xsl:text>
  </xsl:template>


  <!-- related to critical apparatus and notes -->

  <xsl:template match="app">
    <xsl:apply-templates select="lem"/>
    <xsl:call-template name="text:apparatus-footnote"/>
  </xsl:template>

  <xsl:template match="rdg"/>

  <xsl:template match="lem[//variantEncoding/@medthod ne 'parallel-segmentation']"/>

  <xsl:template match="witDetail"/>

  <xsl:template match="note"/>

  <xsl:template match="gap">
    <xsl:text>[...]</xsl:text>
  </xsl:template>

  <xsl:template match="unclear">
    <!--xsl:text>[? </xsl:text-->
    <xsl:apply-templates/>
    <!--xsl:text> ?]</xsl:text-->
  </xsl:template>

  <xsl:template match="choice[child::sic and child::corr]">
    <xsl:apply-templates select="corr"/>
  </xsl:template>

  <xsl:template match="sic[not(parent::choice)]">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="corr[not(parent::choice)]">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- make a footnote with an apparatus entry if there is one for the context element.
    You probably want to override this, e.g., with app:apparatus-footnote. -->
  <xsl:template name="text:apparatus-footnote" visibility="public"/>




  <!-- contributions to the latex header -->
  <xsl:template name="text:latex-header" visibility="public">
    <xsl:text>&lb;&lb;%% macro definitions from .../xsl/latex/libtext.xsl</xsl:text>
    <xsl:text>&lb;\newcommand*{\pb}[1]{[#1]}</xsl:text>
    <xsl:text>&lb;\newcommand*{\milestone}[2]{[#1]}</xsl:text>
  </xsl:template>

</xsl:package>
