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
  xmlns:edmac="http://scdh.wwu.de/transform/edmac#" exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0" default-mode="text:text">

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libreledmac.xsl"
    package-version="1.0.0"/>

  <xsl:mode name="text:text" on-no-match="shallow-skip" visibility="public"/>

  <!-- you may want to override the rule content, e.g., by \txarb{.} -->
  <xsl:template match="text()">
    <!-- some characters need to be escaped -->
    <!--xsl:value-of select=". => replace('\[', '\\lbrack{}') => replace('\]', '\\rbrack{}')"/-->
    <!--xsl:value-of select=". => replace('([\[])', '{$1}')"/-->
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- shrink multiple whitespace space characters to a singel space  -->
  <xsl:template match="text()[ancestor::p or ancestor::l or ancestor::head]">
    <xsl:value-of select=". => replace('\s+', ' ')"/>
  </xsl:template>

  <xsl:template match="teiHeader"/>

  <!-- TODO -->
  <xsl:template match="front | back"/>

  <xsl:template match="body">
    <xsl:text>&lb;&lb;%% begin of text body&lb;\beginnumbering&lb;&lb;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&lb;&lb;%% end of text body&lb;\endnumbering&lb;&lb;</xsl:text>
  </xsl:template>


  <!-- document structure -->

  <xsl:template match="head">
    <!-- TODO -->
    <!--xsl:text>&lb;&lb;\noindent{}</xsl:text-->
    <xsl:call-template name="edmac:par-start"/>
    <xsl:text>&lb;&lb;\eledsection[</xsl:text>
    <xsl:apply-templates mode="text:text-only"/>
    <xsl:text>]{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
    <xsl:call-template name="edmac:par-end"/>
  </xsl:template>

  <xsl:template match="p">
    <xsl:call-template name="edmac:par-start"/>
    <xsl:apply-templates/>
    <xsl:call-template name="edmac:par-end"/>
    <xsl:text>&lb;&lb;&lb;</xsl:text>
  </xsl:template>

  <!-- simple support for verse -->
  <xsl:template match="l">
    <xsl:call-template name="edmac:par-start"/>
    <xsl:apply-templates/>
    <xsl:call-template name="edmac:par-end"/>
    <xsl:text>&lb;&lb;&lb;</xsl:text>
  </xsl:template>

  <xsl:template match="caesura">
    <xsl:text>\hfill{}</xsl:text>
  </xsl:template>

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
    <xsl:call-template name="edmac:app-start"/>
    <xsl:apply-templates select="lem"/>
    <xsl:call-template name="text:inline-footnotes"/>
    <xsl:call-template name="edmac:app-end"/>
  </xsl:template>

  <xsl:template match="anchor">
    <xsl:call-template name="edmac:app-start"/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="context" select="."/>
      <xsl:with-param name="suffix" select="''"/>
    </xsl:call-template>
    <xsl:call-template name="edmac:app-end"/>
  </xsl:template>

  <xsl:template match="rdg"/>

  <xsl:template match="lem[//variantEncoding/@medthod eq 'parallel-segmentation']">
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="context" select="parent::app"/>
      <xsl:with-param name="suffix" select="'-start'"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="lem[//variantEncoding/@medthod ne 'parallel-segmentation']"/>

  <xsl:template match="witDetail"/>

  <xsl:template match="note">
    <xsl:call-template name="edmac:app-start"/>
    <xsl:call-template name="text:inline-footnotes"/>
    <xsl:call-template name="edmac:app-end"/>
  </xsl:template>

  <xsl:template match="gap">
    <xsl:call-template name="edmac:app-start"/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-start'"/>
    </xsl:call-template>
    <xsl:text>[...]</xsl:text>
    <xsl:call-template name="text:inline-footnotes"/>
    <xsl:call-template name="edmac:app-end"/>
  </xsl:template>

  <xsl:template match="unclear">
    <xsl:call-template name="edmac:app-start"/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-start'"/>
    </xsl:call-template>
    <!--xsl:text>[? </xsl:text-->
    <xsl:apply-templates/>
    <!--xsl:text> ?]</xsl:text-->
    <xsl:call-template name="text:inline-footnotes"/>
    <xsl:call-template name="edmac:app-end"/>
  </xsl:template>

  <xsl:template match="choice[child::sic and child::corr]">
    <xsl:call-template name="edmac:app-start"/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-start'"/>
    </xsl:call-template>
    <xsl:apply-templates select="corr"/>
    <xsl:call-template name="text:inline-footnotes"/>
    <xsl:call-template name="edmac:app-end"/>
  </xsl:template>

  <xsl:template match="sic[not(parent::choice)]">
    <xsl:call-template name="edmac:app-start"/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-start'"/>
    </xsl:call-template>
    <xsl:apply-templates/>
    <xsl:call-template name="text:inline-footnotes"/>
    <xsl:call-template name="edmac:app-end"/>
  </xsl:template>

  <xsl:template match="corr[not(parent::choice)]">
    <xsl:call-template name="edmac:app-start"/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-start'"/>
    </xsl:call-template>
    <xsl:apply-templates/>
    <xsl:call-template name="text:inline-footnotes"/>
    <xsl:call-template name="edmac:app-end"/>
  </xsl:template>

  <xsl:template name="text:edlabel">
    <xsl:param name="context" as="node()" select="." required="false"/>
    <xsl:param name="suffix" as="xs:string" select="''" required="false"/>
    <xsl:text>\edlabel{</xsl:text>
    <xsl:choose>
      <xsl:when test="$context/@xml:id">
        <xsl:value-of select="$context/@xml:id"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat(generate-id($context), $suffix)"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>}</xsl:text>
  </xsl:template>


  <!-- a mode if text text only (without macros that can cause run away arguments) is needed,
    e.g. in the optional argument of \section -->
  <xsl:mode name="text:text-only" on-no-match="shallow-skip" visibility="public"/>

  <xsl:template mode="text:text-only" match="text()">
    <!-- we have to drop square brackets for syntactical reasons! -->
    <xsl:value-of select=". => replace('[\[\]]', '') => replace('\s+', ' ')"/>
  </xsl:template>

  <xsl:template mode="text:text-only" match="app">
    <xsl:apply-templates mode="text:text-only" select="lem"/>
  </xsl:template>

  <xsl:template mode="text:text-only" match="choice[sic and corr]">
    <xsl:apply-templates mode="text:text-only" select="corr"/>
  </xsl:template>

  <xsl:template mode="text:text-only" match="choice[abbr and expan]">
    <xsl:apply-templates mode="text:text-only" select="expan"/>
  </xsl:template>

  <xsl:template mode="text:text-only" match="choice[seg]">
    <xsl:apply-templates mode="text:text-only" select="seg[1]"/>
  </xsl:template>

  <xsl:template mode="text:text-only" match="note"/>



  <!-- make a footnote with an apparatus entry if there is one for the context element.
    You probably want to override this, e.g., with app:apparatus-footnote and note:editorial-note. -->
  <xsl:template name="text:inline-footnotes" visibility="public"/>




  <!-- contributions to the latex header -->
  <xsl:template name="text:latex-header" visibility="public">
    <xsl:text>&lb;&lb;%% macro definitions from .../xsl/latex/libtext.xsl</xsl:text>
    <xsl:text>&lb;\newcommand*{\pb}[1]{[#1]}</xsl:text>
    <xsl:text>&lb;\newcommand*{\milestone}[2]{[#1]}</xsl:text>
  </xsl:template>

</xsl:package>
