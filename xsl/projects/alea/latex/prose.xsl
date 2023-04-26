<!DOCTYPE package [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
    <!ENTITY nbsp "&#xa0;" >
    <!ENTITY emsp "&#x2003;" >
    <!ENTITY lb "&#xa;" >
]>
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/latex/prose.xsl"
  package-version="1.0" version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:app="http://scdh.wwu.de/transform/app#"
  xmlns:note="http://scdh.wwu.de/transform/note#" xmlns:seed="http://scdh.wwu.de/transform/seed#"
  xmlns:text="http://scdh.wwu.de/transform/text#"
  xmlns:common="http://scdh.wwu.de/transform/common#"
  xmlns:meta="http://scdh.wwu.de/transform/meta#" xmlns:wit="http://scdh.wwu.de/transform/wit#"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0">

  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:param name="language" as="xs:string" select="/TEI/@xml:lang"/>

  <xsl:variable name="current" as="node()*" select="root()"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libi18n.xsl"
    package-version="1.0.0">
    <xsl:override>
      <xsl:variable name="i18n:default-language" as="xs:string" select="$language"/>
    </xsl:override>
  </xsl:use-package>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libentry2.xsl"
    package-version="1.0.0">
    <xsl:accept component="function" names="seed:note-based-apparatus-nodes-map#2"
      visibility="public"/>
    <xsl:accept component="function" names="seed:shorten-lemma#1" visibility="hidden"/>
  </xsl:use-package>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libapp2.xsl"
    package-version="1.0.0">
    <xsl:override>

      <xsl:variable name="app:apparatus-entries" as="map(xs:string, map(*))"
        select="app:apparatus-entries($current) => seed:note-based-apparatus-nodes-map(true())"/>

      <xsl:variable name="app:entries-xpath-internal-parallel-segmentation" as="xs:string">
        <xsl:value-of>
          <!-- choice+corr+sic+app+rdg was an old encoding of conjectures in ALEA -->
          <xsl:text>descendant-or-self::app[not(parent::sic[parent::choice])]</xsl:text>
          <xsl:text>| descendant::witDetail[not(parent::app)]</xsl:text>
          <xsl:text>| descendant::corr[not(parent::choice)]</xsl:text>
          <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
          <xsl:text>| descendant::choice[sic and corr]</xsl:text>
          <xsl:text>| descendant::unclear[not(parent::choice)]</xsl:text>
          <xsl:text>| descendant::choice[unclear]</xsl:text>
          <xsl:text>| descendant::gap</xsl:text>
        </xsl:value-of>
      </xsl:variable>

      <xsl:variable name="app:entries-xpath-internal-double-end-point" as="xs:string">
        <xsl:value-of>
          <!-- choice+corr+sic+app+rdg was an old encoding of conjectures in ALEA -->
          <xsl:text>descendant-or-self::app[not(parent::sic[parent::choice])]</xsl:text>
          <xsl:text>| descendant::witDetail[not(parent::app)]</xsl:text>
          <xsl:text>| descendant::corr[not(parent::choice)]</xsl:text>
          <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
          <xsl:text>| descendant::choice[sic and corr]</xsl:text>
          <xsl:text>| descendant::unclear[not(parent::choice)]</xsl:text>
          <xsl:text>| descendant::choice[unclear]</xsl:text>
          <xsl:text>| descendant::gap</xsl:text>
        </xsl:value-of>
      </xsl:variable>

      <xsl:variable name="app:entries-xpath-external-double-end-point" as="xs:string">
        <xsl:value-of>
          <xsl:text>descendant-or-self::app</xsl:text>
          <xsl:text>| descendant::witDetail[not(parent::app)]</xsl:text>
          <xsl:text>| descendant::corr[not(parent::choice)]</xsl:text>
          <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
          <xsl:text>| descendant::choice[sic and corr]</xsl:text>
          <xsl:text>| descendant::unclear[not(parent::choice)]</xsl:text>
          <xsl:text>| descendant::choice[unclear]</xsl:text>
          <xsl:text>| descendant::gap</xsl:text>
        </xsl:value-of>
      </xsl:variable>

      <xsl:variable name="app:entries-xpath-no-textcrit" as="xs:string">
        <xsl:value-of>
          <xsl:text>descendant::corr[not(parent::choice)]</xsl:text>
          <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
          <xsl:text>| descendant::choice[sic and corr]</xsl:text>
          <xsl:text>| descendant::unclear[not(parent::choice)]</xsl:text>
          <xsl:text>| descendant::choice[unclear]</xsl:text>
          <xsl:text>| descendant::gap</xsl:text>
        </xsl:value-of>
      </xsl:variable>


    </xsl:override>
  </xsl:use-package>



  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libtext.xsl"
    package-version="1.0.0">
    <xsl:override>

      <xsl:template name="text:par-start">
        <xsl:text>&lb;\setRTL\pstart </xsl:text>
      </xsl:template>

      <xsl:template name="text:par-end">
        <xsl:text>&lb;\pend</xsl:text>
      </xsl:template>

      <!-- make apparatus footnotes -->
      <xsl:template name="text:apparatus-footnote">
        <xsl:message>apparatus footnote</xsl:message>
        <xsl:call-template name="app:apparatus-footnote"/>
      </xsl:template>

    </xsl:override>
  </xsl:use-package>



  <xsl:mode on-no-match="shallow-skip"/>

  <xsl:template match="/ | TEI">
    <xsl:call-template name="latex-header"/>
    <xsl:text>&lb;&lb;\begin{document}&lb;</xsl:text>
    <xsl:call-template name="latex-front"/>
    <xsl:text>&lb;&lb;%% main content</xsl:text>
    <xsl:apply-templates mode="text:text" select="/TEI/text/body"/>
    <xsl:text>&lb;</xsl:text>
    <xsl:call-template name="latex-back"/>
    <xsl:text>&lb;\end{document}&lb;</xsl:text>
  </xsl:template>

  <xsl:template name="latex-header">
    <xsl:text>\documentclass{book}</xsl:text>

    <!-- input encoding -->
    <xsl.text>&lb;\usepackage{ifluatex}</xsl.text>
    <xsl:text>&lb;\ifluatex</xsl:text>
    <xsl:text>&lb;%% für luatex</xsl:text>
    <xsl:text>&lb;\usepackage[utf8]{luainputenc}</xsl:text>
    <xsl:text>&lb;\else</xsl:text>
    <xsl:text>&lb;%% für pdftex</xsl:text>
    <xsl:text>&lb;\usepackage[utf8]{inputenc}%</xsl:text>
    <xsl:text>&lb;\usepackage[T1]{fontenc}%</xsl:text>
    <xsl:text>&lb;% \FAIL</xsl:text>
    <xsl:text>&lb;\fi</xsl:text>

    <!-- language and script -->
    <xsl:text>&lb;\ifluatex</xsl:text>
    <xsl:text>&lb;%% für luatex</xsl:text>
    <xsl:text>&lb;\usepackage{luabidi}</xsl:text>
    <xsl:text>&lb;\usepackage[english,bidi=basic]{babel}</xsl:text>
    <xsl:text>&lb;\babelprovide[import,main]{arabic}</xsl:text>
    <xsl:text>&lb;\babelfont{rm}{Amiri}</xsl:text>
    <xsl:text>&lb;\babelfont{sf}{Amiri}</xsl:text>
    <xsl:text>&lb;\babelfont{tt}{Amiri}</xsl:text>
    <!--
    <xsl:text>&lb;\usepackage{fontspec}</xsl:text>
    <xsl:text>&lb;\defaultfontfeatures{Ligatures=TeX}</xsl:text>
    <xsl:text>&lb;\usepackage{polyglossia}</xsl:text>
    <xsl:text>&lb;\setdefaultlanguage{arabic}</xsl:text>
    <xsl:text>&lb;\setmainfont[Ligatures=TeX,Script=Arabic]{Amiri}</xsl:text>
    <xsl:text>&lb;\newfontfamily\arabicfont[Ligatures=TeX,Script=Arabic]{Amiri}</xsl:text>
    <xsl:text>&lb;\newfontfamily\arabicfontsf[Ligatures=TeX,Script=Arabic]{Amiri}</xsl:text>
    <xsl:text>&lb;\newfontfamily\arabicfonttt[Ligatures=TeX,Script=Arabic]{Amiri}</xsl:text>
    -->
    <xsl:text>&lb;\setRTLmain</xsl:text>
    <xsl:text>&lb;\else</xsl:text>
    <xsl:text>&lb;%% für pdftex</xsl:text>
    <xsl:text>&lb;\usepackage{bidi}</xsl:text>
    <xsl:text>&lb;\usepackage[ngerman,english,bidi=basic]{babel}</xsl:text>
    <xsl:text>&lb;\babelprovide[import,main]{arabic}</xsl:text>
    <xsl:text>&lb;\babelfont{rm}{Amiri}</xsl:text>
    <xsl:text>&lb;\babelfont{sf}{Amiri}</xsl:text>
    <xsl:text>&lb;\babelfont{tt}{Amiri}</xsl:text>
    <xsl:text>&lb;\setRTLmain</xsl:text>
    <xsl:text>&lb;\fi</xsl:text>

    <xsl:call-template name="text:latex-header"/>
    <xsl:call-template name="i18n:latex-header"/>
    <xsl:call-template name="app:latex-header"/>

    <!-- does not give footnotes in para
    <xsl:text>&lb;\let\Footnote\undefined</xsl:text>
    <xsl:text>&lb;\usepackage[perpage,para]{manyfoot}</xsl:text>
    -->
    <xsl:text>&lb;\usepackage{reledmac}</xsl:text>

    <xsl:text>&lb;&lb;%% overrides</xsl:text>
    <xsl:text>&lb;\renewcommand*{\milestone}[2]{[#1]}</xsl:text>

    <!--
    <xsl:text>&lb;\usepackage[switch,modulo,pagewise]{lineno}</xsl:text>
    -->
  </xsl:template>

  <xsl:template name="latex-front">
    <xsl:text>&lb;%%\maketitle</xsl:text>
  </xsl:template>

  <xsl:template name="latex-back"/>

</xsl:package>
