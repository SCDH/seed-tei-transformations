<!-- XSLT package with logic for making a LaTeX preamble

target/bin/xslt.sh \
  -config:saxon.he.xml \
  -xsl:xsl/projects/alea/latex/preamble.xsl \
  -it:{http://scdh.wwu.de/transform/preamble#}mainfile \
  {http://scdh.wwu.de/transform/preamble#}subfiles-csv=Sag1.tex,Sag2.tex

-->
<!DOCTYPE package [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
    <!ENTITY nbsp "&#xa0;" >
    <!ENTITY emsp "&#x2003;" >
    <!ENTITY lb "&#xa;" >
]>
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libpreamble.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:preamble="http://scdh.wwu.de/transform/preamble#" exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

  <!-- comma separated list of subfiles, used in alea:mainfile initial template -->
  <xsl:param name="preamble:subfiles-csv" as="xs:string" select="''"/>

  <!-- like subfiles-csv, but as a sequence of strings -->
  <xsl:param name="preamble:subfiles" as="xs:string*" select="tokenize($preamble:subfiles-csv, ',')"/>

  <!-- if this is not empty: documentclass[$mainfile]{subfiles} -->
  <xsl:param name="preamble:mainfile" as="xs:string?" select="()"/>

  <!-- external latex header files, separated by commas -->
  <xsl:param name="preamble:header-csv" as="xs:string" select="''"/>

  <!-- same as latex-header-csv, but as a sequence of URIs -->
  <xsl:param name="preamble:header" as="xs:anyURI*"
    select="tokenize($preamble:header-csv, ',\s*') ! xs:anyURI(.)"/>

  <!-- the LaTeX documentclass -->
  <xsl:param name="preamble:class" as="xs:string" select="'book'"/>

  <!-- the options to the documentclass -->
  <xsl:param name="preamble:class-options" as="xs:string?" select="()"/>


  <!-- make preamble based on whether external header files or a mainfile is provided -->
  <xsl:template name="preamble:header" visibility="final">
    <xsl:choose>
      <!-- when external header files are provided, use them as preamble -->
      <xsl:when test="$preamble:header">
        <xsl:for-each select="$preamble:header">
          <xsl:value-of select="resolve-uri(., static-base-uri()) => unparsed-text()"/>
        </xsl:for-each>
      </xsl:when>
      <!-- when an mainfile is provided, use the subfiles documentclass -->
      <xsl:when test="$preamble:header">
        <xsl:text>\documentclass[</xsl:text>
        <xsl:value-of select="$preamble:mainfile => replace('\.tex$', '')"/>
        <xsl:text>]{subfiles}</xsl:text>
      </xsl:when>
      <!-- otherwise use default preamble -->
      <xsl:otherwise>
        <xsl:text>\documentclass</xsl:text>
        <xsl:if test="$preamble:class-options">
          <xsl:text>[</xsl:text>
          <xsl:value-of select="$preamble:class-options"/>
          <xsl:text>]</xsl:text>
        </xsl:if>
        <xsl:text>{</xsl:text>
        <xsl:value-of select="$preamble:class"/>
        <xsl:text>}</xsl:text>
        <xsl:call-template name="preamble:preamble"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- make a mainfile including a list of subfiles, this should be used as an initial template -->
  <xsl:template name="preamble:mainfile" visibility="final">
    <!-- it does not work with koma-script classes
    <xsl:text>\documentclass{scrbook}</xsl:text>
    -->
    <xsl:text>\documentclass{book}</xsl:text>

    <xsl:call-template name="preamble:preamble"/>

    <xsl:text>&lb;\usepackage{subfiles}</xsl:text>

    <xsl:text>&lb;\begin{document}</xsl:text>
    <xsl:call-template name="preamble:maketitle"/>
    <xsl:for-each select="$preamble:subfiles">
      <xsl:text>&lb;\subfile{</xsl:text>
      <xsl:value-of select=". => replace('\.tex$', '')"/>
      <xsl:text>}</xsl:text>
    </xsl:for-each>
    <xsl:text>&lb;\end{document}</xsl:text>
    <xsl:call-template name="preamble:footer"/>
  </xsl:template>

  <!-- output the LaTeX preamble, but not the documentclass -->
  <xsl:template name="preamble:preamble" visibility="abstract"/>

  <!-- printout \maketitle -->
  <xsl:template name="preamble:maketitle" visibility="public">
    <xsl:text>&lb;\maketitle</xsl:text>
  </xsl:template>

  <xsl:template name="preamble:footer" visibility="final">
    <!-- local variables for AUCTeX -->
    <xsl:text>&lb;&lb;%%% Local Variables:</xsl:text>
    <xsl:text>&lb;%%% mode: latex</xsl:text>
    <xsl:text>&lb;%%% TeX-master: t</xsl:text>
    <xsl:text>&lb;%%% TeX-engine: luatex</xsl:text>
    <xsl:text>&lb;%%% TeX-PDF-mode: t</xsl:text>
    <xsl:text>&lb;%%% End:</xsl:text>
  </xsl:template>

</xsl:package>
