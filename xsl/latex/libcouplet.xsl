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
  xmlns:rend="http://scdh.wwu.de/transform/rend#" xmlns:verse="http://scdh.wwu.de/transform/verse#"
  xmlns:edmac="http://scdh.wwu.de/transform/edmac#" exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

  <xsl:expose component="template" names="verse:fill-caesura" visibility="public"/>
  <xsl:expose component="template" names="verse:*" visibility="final"/>
  <xsl:expose component="function" names="verse:*" visibility="public"/>

  <xsl:mode name="after-caesura" visibility="private"/>
  <xsl:mode name="before-caesura" visibility="private"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libreledmac.xsl"
    package-version="1.0.0"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libtext.xsl"
    package-version="1.0.0"/>

  <!-- a replacement for text:verse -->
  <xsl:template name="verse:verse">
    <xsl:context-item as="element(l)" use="required"/>
    <xsl:choose>
      <xsl:when test="descendant::caesura[not(ancestor::note)]">
        <xsl:text>\hemistichs</xsl:text>
        <xsl:call-template name="verse:fill-caesura"/>
        <xsl:text>{</xsl:text>
        <!-- start label and hook on l -->
        <xsl:call-template name="edmac:edlabel">
          <xsl:with-param name="suffix" select="'-start'"/>
        </xsl:call-template>
        <xsl:variable name="first" as="xs:string*">
          <!-- text of first hemistich -->
          <!-- output of nodes that preceed caesura -->
          <xsl:apply-templates mode="text:text"
            select="node() intersect descendant::caesura[not(ancestor::rdg | ancestor::note)]/preceding::node() except verse:non-lemma-nodes(.)"/>
          <!-- recursively handle nodes, that contain caesura -->
          <xsl:apply-templates select="*[descendant::caesura[not(ancestor::rdg | ancestor::note)]]"
            mode="before-caesura"/>
        </xsl:variable>
        <xsl:value-of select="edmac:normalize($first, 'space')"/>
        <xsl:text>}{</xsl:text>
        <xsl:variable name="second" as="xs:string*">
          <!-- second hemistich -->
          <!-- recursively handle nodes, that contain caesura -->
          <xsl:apply-templates select="*[descendant::caesura[not(ancestor::rdg | ancestor::note)]]"
            mode="after-caesura"/>
          <!-- output nodes that follow caesura -->
          <xsl:apply-templates mode="text:text"
            select="node() intersect descendant::caesura[not(ancestor::rdg | ancestor::note)]/following::node() except verse:non-lemma-nodes(.)"
          />
        </xsl:variable>
        <xsl:value-of select="edmac:normalize($second, 'space')"/>
        <!-- end label and hook on l -->
        <xsl:call-template name="edmac:edlabel">
          <xsl:with-param name="suffix" select="'-end'"/>
        </xsl:call-template>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="text:text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- a hook to be replaced with your implementation if you need to fill the space
    of caesura with something else than \hfill -->
  <xsl:template name="verse:fill-caesura" as="text()*">
    <xsl:context-item as="element(l)" use="required"/>
    <xsl:text>[\hfill]</xsl:text>
  </xsl:template>


  <!-- This is a replacement for verse:fill-caesura for arabic poetry.
    If the characters around the caesura element are tatweel (elongation),
    then the caesura is filled with tatweel, resulting in in-word caesura.
  -->
  <xsl:template name="verse:fill-tatweel" as="text()*">
    <xsl:context-item as="element(l)" use="required"/>
    <xsl:variable name="caesura" as="element(caesura)"
      select="descendant::caesura[not(ancestor::rdg | ancestor::note) and not (ancestor::note)]"/>
    <xsl:variable name="before-text">
      <xsl:apply-templates mode="text:text" select="$caesura/preceding-sibling::node()"/>
    </xsl:variable>
    <xsl:variable name="before" select="normalize-space($before-text)"/>
    <xsl:variable name="after-text">
      <xsl:apply-templates mode="text:text" select="$caesura/following-sibling::node()"/>
    </xsl:variable>
    <xsl:variable name="after" select="normalize-space($after-text)"/>
    <xsl:choose>
      <xsl:when test="matches($before, '&#x0640;$') and matches($after, '^&#x0640;')">
        <xsl:text>[\filltatweel]</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <!-- empty -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- nodes that contain caesura: recursively output everything preceding caesura -->
  <xsl:template match="*[descendant::caesura[not(ancestor::note)]]" mode="before-caesura">
    <xsl:message use-when="system-property('debug') eq 'true'">
      <xsl:text>Entered before-caesura mode: </xsl:text>
      <xsl:value-of select="local-name()"/>
    </xsl:message>
    <!-- before element hooks -->
    <xsl:apply-templates mode="rend:hook-ahead" select="."/>
    <xsl:call-template name="edmac:app-start"/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-start'"/>
    </xsl:call-template>
    <xsl:apply-templates mode="rend:hook-before" select="."/>
    <!-- output of nodes that precede caesura -->
    <xsl:apply-templates mode="text:text"
      select="node() intersect descendant::caesura[not(ancestor::rdg | ancestor::note)]/preceding::node() except verse:non-lemma-nodes(.)"/>
    <!-- recursively handle nodes, that contain caesura -->
    <xsl:apply-templates select="*[descendant::caesura[not(ancestor::rdf | ancestor::note)]]"
      mode="before-caesura"/>
  </xsl:template>

  <!-- nodes that contain caesura: recursively output everything following caesura -->
  <xsl:template match="*[descendant::caesura[not(ancestor::rdf | ancestor::note)]]"
    mode="after-caesura">
    <xsl:message use-when="system-property('debug') eq 'true'">
      <xsl:text>Entered after-caesura mode: </xsl:text>
      <xsl:value-of select="local-name()"/>
    </xsl:message>
    <!-- recursively handle nodes, that contain caesura -->
    <xsl:apply-templates select="*[descendant::caesura[not(ancestor::rdg | ancestor::note)]]"
      mode="after-caesura"/>
    <!-- output nodes that follow caesura -->
    <xsl:apply-templates mode="text:text"
      select="node() intersect descendant::caesura[not(ancestor::rdg | ancestor::note)]/following::node() except verse:non-lemma-nodes(.)"/>
    <!-- after element hooks -->
    <xsl:apply-templates mode="rend:hook-after" select="."/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-end'"/>
    </xsl:call-template>
    <xsl:call-template name="edmac:app-end"/>
    <xsl:call-template name="text:inline-footnotes"/>
    <xsl:apply-templates mode="rend:hook-behind" select="."/>
  </xsl:template>

  <!-- When the caesura is not present in the nested node, then output the node only once and warn the user.  -->
  <xsl:template match="*" mode="before-caesura">
    <xsl:message>WARNING: broken document? caesura missing</xsl:message>
    <xsl:apply-templates mode="text:text"/>
  </xsl:template>
  <xsl:template match="*" mode="after-caesura"/>


  <!-- TODO: this needs a better implementation -->
  <xsl:function name="verse:non-lemma-nodes" as="node()*">
    <xsl:param name="element" as="node()"/>
    <xsl:sequence select="$element/descendant-or-self::rdg/descendant-or-self::node()"/>
  </xsl:function>


  <!-- contributions to the latex header -->
  <xsl:template name="verse:latex-header">
    <xsl:text>&lb;&lb;%% macro definitions from .../xsl/latex/libverse.xsl</xsl:text>
    <xsl:text>&lb;\usepackage{filecontents}</xsl:text>
    <xsl:text>&lb;\begin{filecontents}{hemistich.sty}</xsl:text>
    <xsl:text>&lb;</xsl:text>
    <xsl:value-of select="unparsed-text('hemistich.sty')"/>
    <xsl:text>&lb;\end{filecontents}</xsl:text>
    <xsl:text>&lb;\usepackage{hemistich}</xsl:text>
  </xsl:template>

</xsl:package>
