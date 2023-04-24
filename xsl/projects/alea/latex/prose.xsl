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

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libtext.xsl"
    package-version="1.0.0">
    <xsl:override>
      <xsl:template name="text:par-start">
        <xsl:text>&lb;\setRTL{}</xsl:text>
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
    <xsl:text>\documentclass{scrbook}</xsl:text>

    <xsl:text>&lb;\KOMAoption{fontsize}{16}</xsl:text>

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
    <xsl:text>&lb;\usepackage{fontspec}</xsl:text>
    <xsl:text>&lb;\defaultfontfeatures{Ligatures=TeX}</xsl:text>
    <xsl:text>&lb;\usepackage{polyglossia}</xsl:text>
    <xsl:text>&lb;\setdefaultlanguage{arabic}</xsl:text>
    <xsl:text>&lb;\setmainfont[Ligatures=TeX,Script=Arabic]{Amiri}</xsl:text>
    <xsl:text>&lb;\newfontfamily\arabicfont[Ligatures=TeX,Script=Arabic]{Amiri}</xsl:text>
    <xsl:text>&lb;\newfontfamily\arabicfontsf[Ligatures=TeX,Script=Arabic]{Amiri}</xsl:text>
    <xsl:text>&lb;\newfontfamily\arabicfonttt[Ligatures=TeX,Script=Arabic]{Amiri}</xsl:text>
    <xsl:text>&lb;\setRTLmain</xsl:text>
    <xsl:text>&lb;\else</xsl:text>
    <xsl:text>&lb;%% für pdftex</xsl:text>
    <xsl:text>&lb;\fi</xsl:text>

    <xsl:call-template name="text:latex-header"/>

    <xsl:text>&lb;&lb;%% overrides</xsl:text>
    <!--xsl:text>&lb;\renewcommand*{\milestone}[2]{\LRE{[#1]}}</xsl:text-->
    <xsl:text>&lb;\renewcommand*{\milestone}[2]{]&rle;#1&pdf;[}</xsl:text>

    <xsl:text>&lb;\usepackage[switch,modulo,pagewise]{lineno}</xsl:text>

    <xsl:text>&lb;%\setkomafont{disposition}{\normalsize}</xsl:text>

  </xsl:template>

  <xsl:template name="latex-front">
    <xsl:text>&lb;%%\maketitle</xsl:text>
    <xsl:text>&lb;\linenumbers{}</xsl:text>
  </xsl:template>

  <xsl:template name="latex-back"/>

</xsl:package>
