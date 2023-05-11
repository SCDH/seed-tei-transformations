<!-- XSLT transformation from TEI to LaTeX

EXAMPLE USAGE:

target/bin/xslt.sh -config:saxon.he.xml -xsl:xsl/projects/alea/latex/prose.xsl -s:test/alea/Prosa/Sag_al_mutawwaq/Sag_al_mutawwaq.tei.xml wit-catalog=../../WitnessCatalogue.xml {http://scdh.wwu.de/transform/edmac#}pstart-opt="[\noindent\setRL]"

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

  <!-- optional: the URI of the projects central witness catalogue -->
  <xsl:param name="wit-catalog" as="xs:string" select="string()"/>


  <xsl:variable name="current" as="node()*" select="root()"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libbetween.xsl"
    package-version="1.0.0"/>

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

  <xsl:variable name="witnesses" as="element()*">
    <xsl:choose>
      <xsl:when test="$wit-catalog eq string()">
        <xsl:sequence select="//sourceDesc//witness[@xml:id]"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- a sequence from external and local witnesses.
          We only use the ones with a siglum. -->
        <xsl:sequence select="
          (//sourceDesc//witness[@xml:id],
          doc(resolve-uri($wit-catalog, base-uri()))/descendant::witness[@xml:id])
          [descendant::abbr[@type eq 'siglum']]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libwit.xsl"
    package-version="1.0.0">
    <xsl:override>
      <xsl:variable name="wit:witnesses" as="element()*" select="$witnesses"/>
    </xsl:override>
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
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libnote2.xsl"
    package-version="1.0.0">
    <xsl:accept component="function" names="note:editorial-notes#3" visibility="public"/>
    <xsl:accept component="template" names="note:inline-editorial-notes" visibility="public"/>
    <xsl:accept component="mode" names="note:editorial-note" visibility="public"/>
    <xsl:accept component="function" names="seed:shorten-lemma#1" visibility="hidden"/>
    <xsl:accept component="function" names="seed:mk-entry-map#4" visibility="hidden"/>

    <xsl:override>

      <xsl:variable name="note:editorial-notes" as="map(xs:string, map(*))"
        select="note:editorial-notes($current, 'descendant-or-self::note[ancestor::text]', 2) => seed:note-based-apparatus-nodes-map(true())"/>

      <!-- note with @target, but should be @targetEnd. TODO: remove after TEI has been fixed -->
      <xsl:template mode="note:text-nodes-dspt" match="note[@target] | noteGrp[@target]">
        <xsl:variable name="targetEnd" as="xs:string" select="substring(@target, 2)"/>
        <xsl:variable name="target-end-node" as="node()*" select="//*[@xml:id eq $targetEnd]"/>
        <xsl:choose>
          <xsl:when test="empty($target-end-node)">
            <xsl:message>
              <xsl:text>No anchor for message with @target: </xsl:text>
              <xsl:value-of select="$targetEnd"/>
            </xsl:message>
          </xsl:when>
          <xsl:when test="following-sibling::*[@xml:id eq $targetEnd]">
            <xsl:apply-templates mode="seed:lemma-text-nodes"
              select="seed:subtrees-between-anchors(., $target-end-node)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="seed:lemma-text-nodes"
              select="seed:subtrees-between-anchors($target-end-node, .)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:template>

      <!-- drop mentioned -->
      <xsl:template mode="note:editorial-note" match="mentioned"/>
    </xsl:override>

  </xsl:use-package>



  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libtext.xsl"
    package-version="1.0.0">
    <xsl:override>

      <!-- make apparatus footnotes -->
      <xsl:template name="text:inline-footnotes">
        <xsl:message>apparatus footnote</xsl:message>
        <xsl:call-template name="app:apparatus-footnote"/>
        <xsl:call-template name="note:inline-editorial-notes"/>
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
    <xsl:text>&lb;\usepackage{arabluatex}% necessary</xsl:text>
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
    <xsl:text>&lb;\else</xsl:text>
    <xsl:text>&lb;%% für pdftex</xsl:text>
    <xsl:text>&lb;\usepackage{bidi}</xsl:text>
    <xsl:text>&lb;\fi</xsl:text>

    <xsl:text>&lb;\usepackage[ngerman,english,bidi=basic]{babel}</xsl:text>
    <xsl:text>&lb;\babelprovide[import,main]{arabic}</xsl:text>
    <xsl:text>&lb;\babelfont{rm}{Amiri}</xsl:text>
    <xsl:text>&lb;\babelfont{sf}{Amiri}</xsl:text>
    <xsl:text>&lb;\babelfont{tt}{Amiri}</xsl:text>
    <xsl:text>&lb;\setRTLmain</xsl:text>

    <xsl:call-template name="text:latex-header"/>
    <xsl:call-template name="i18n:latex-header"/>
    <xsl:call-template name="app:latex-header"/>

    <!-- does not give footnotes in para
    <xsl:text>&lb;\let\Footnote\undefined</xsl:text>
    <xsl:text>&lb;\usepackage[perpage,para]{manyfoot}</xsl:text>
    -->
    <xsl:text>&lb;\usepackage{reledmac}</xsl:text>
    <xsl:text>&lb;\Xarrangement{paragraph}</xsl:text>
    <xsl:text>&lb;\Xnonbreakableafternumber</xsl:text>
    <xsl:text>&lb;\Xnumberonlyfirstinline</xsl:text>
    <xsl:text>&lb;\Xsymlinenum{ | }</xsl:text>
    <xsl:text>&lb;\Xwraplemma{\RL}</xsl:text>
    <xsl:text>&lb;\Xwrapcontent{\RL}</xsl:text>

    <xsl:text>&lb;&lb;%% overrides</xsl:text>
    <xsl:text>&lb;\renewcommand*{\milestone}[2]{\LR{[#1]}}</xsl:text>

    <!--
    <xsl:text>&lb;\usepackage[switch,modulo,pagewise]{lineno}</xsl:text>
    -->
  </xsl:template>

  <xsl:template name="latex-front">
    <xsl:text>&lb;%%\maketitle</xsl:text>
  </xsl:template>

  <xsl:template name="latex-back"/>

</xsl:package>
