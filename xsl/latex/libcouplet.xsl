<!DOCTYPE package [
    <!ENTITY lb "&#xa;" >
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >]>
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libcouplet.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:text="http://scdh.wwu.de/transform/text#"
  xmlns:edmac="http://scdh.wwu.de/transform/edmac#" exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0" default-mode="text:text">

  <xsl:mode name="after-caesura" visibility="private"/>
  <xsl:mode name="before-caesura" visibility="private"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libreledmac.xsl"
    package-version="1.0.0"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libtext.xsl"
    package-version="1.0.0">
    <xsl:accept component="mode" names="text:*" visibility="public"/>
    <xsl:accept component="template" names="text:*" visibility="public"/>
    <xsl:accept component="template" names="edmac:*" visibility="public"/>

    <xsl:override>

      <xsl:template name="text:verse">
        <xsl:text>\couplet{</xsl:text>
        <!-- start label and hook on l -->
        <xsl:call-template name="edmac:edlabel">
          <xsl:with-param name="suffix" select="'-start'"/>
        </xsl:call-template>
        <!-- text of first hemistiche -->
        <!-- output of nodes that preceed caesura -->
        <xsl:apply-templates
          select="node() intersect descendant::caesura[not(ancestor::rdg)]/preceding::node() except text:non-lemma-nodes(.)"/>
        <!-- recursively handle nodes, that contain caesura -->
        <xsl:apply-templates select="*[descendant::caesura]" mode="before-caesura"/>
        <xsl:text>}{</xsl:text>
        <!-- second hemistiche -->
        <!-- recursively handle nodes, that contain caesura -->
        <xsl:apply-templates select="*[descendant::caesura]" mode="after-caesura"/>
        <!-- output nodes that follow caesura -->
        <xsl:apply-templates
          select="node() intersect descendant::caesura[not(ancestor::rdg)]/following::node() except text:non-lemma-nodes(.)"/>
        <!-- end label and hook on l -->
        <xsl:call-template name="edmac:edlabel">
          <xsl:with-param name="suffix" select="'-end'"/>
        </xsl:call-template>
        <xsl:text>}</xsl:text>
      </xsl:template>

    </xsl:override>

  </xsl:use-package>

  <!-- nodes that contain caesura: recursively output everything preceding caesura -->
  <xsl:template match="*[descendant::caesura]" mode="before-caesura">
    <xsl:message use-when="system-property('debug') eq 'true'">
      <xsl:text>Entered before-caesura mode: </xsl:text>
      <xsl:value-of select="local-name()"/>
    </xsl:message>
    <!-- before element hooks -->
    <xsl:call-template name="edmac:app-start"/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-start'"/>
    </xsl:call-template>
    <!-- output of nodes that preced caesura -->
    <xsl:apply-templates
      select="node() intersect descendant::caesura[not(ancestor::rdg)]/preceding::node() except text:non-lemma-nodes(.)"/>
    <!-- recursively handle nodes, that contain caesura -->
    <xsl:apply-templates select="*[descendant::caesura]" mode="before-caesura"/>
  </xsl:template>

  <!-- nodes that contain caesura: recursively output everything following caesura -->
  <xsl:template match="*[descendant::caesura]" mode="after-caesura">
    <xsl:message use-when="system-property('debug') eq 'true'">
      <xsl:text>Entered after-caesura mode: </xsl:text>
      <xsl:value-of select="local-name()"/>
    </xsl:message>
    <!-- recursively handle nodes, that contain caesura -->
    <xsl:apply-templates select="*[descendant::caesura]" mode="after-caesura"/>
    <!-- output nodes that follow caesura -->
    <xsl:apply-templates
      select="node() intersect descendant::caesura[not(ancestor::rdg)]/following::node() except text:non-lemma-nodes(.)"/>
    <!-- after element hooks -->
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-end'"/>
    </xsl:call-template>
    <xsl:call-template name="edmac:app-end"/>
    <xsl:call-template name="text:inline-footnotes"/>
  </xsl:template>

  <!-- When the caesura is not present in the nested node, then output the node only once and warn the user.  -->
  <xsl:template match="*" mode="before-caesura">
    <xsl:message>WARNING: broken document? caesura missing</xsl:message>
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="*" mode="after-caesura"/>


  <!-- TODO: this needs a better implementation -->
  <xsl:function name="text:non-lemma-nodes" as="node()*">
    <xsl:param name="element" as="node()"/>
    <xsl:sequence select="$element/descendant-or-self::rdg/descendant-or-self::node()"/>
  </xsl:function>


  <!-- contributions to the latex header -->
  <xsl:template name="text:latex-header-caesura" visibility="public">
    <xsl:text>&lb;&lb;%% macro definitions from .../xsl/latex/libverse.xsl</xsl:text>
    <xsl:text>&lb;\newcommand*{\couplet}[2]{#1#2}</xsl:text>
    <xsl:text>&lb;\usepackage{filecontents}</xsl:text>
    <xsl:text>&lb;\begin{filecontents}{hemistich.sty}</xsl:text>
    <xsl:value-of select="unparsed-text('hemistich.sty')"/>
    <xsl:text>&lb;\end{filecontents}</xsl:text>
  </xsl:template>

</xsl:package>
