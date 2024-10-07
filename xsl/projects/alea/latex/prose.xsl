<!-- XSLT transformation from TEI to LaTeX

EXAMPLE USAGE:

target/bin/xslt.sh -config:saxon.he.xml -xsl:xsl/projects/alea/latex/prose.xsl -s:test/alea/Prosa/Sag_al_mutawwaq/Sag_al_mutawwaq.tei.xml wit-catalog=../../WitnessCatalogue.xml {http://scdh.wwu.de/transform/edmac#}pstart-opt="\noindent"

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
  xmlns:text="http://scdh.wwu.de/transform/text#" xmlns:verse="http://scdh.wwu.de/transform/verse#"
  xmlns:edmac="http://scdh.wwu.de/transform/edmac#"
  xmlns:common="http://scdh.wwu.de/transform/common#"
  xmlns:meta="http://scdh.wwu.de/transform/meta#" xmlns:wit="http://scdh.wwu.de/transform/wit#"
  xmlns:alea="http://scdh.wwu.de/transform/alea#"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0">

  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:param name="latex-header-csv" as="xs:string" select="''"/>

  <xsl:param name="latex-header" as="xs:anyURI*"
    select="tokenize($latex-header-csv, ',\s*') ! xs:anyURI(.)"/>

  <xsl:param name="language" as="xs:string" select="/TEI/@xml:lang"/>

  <!-- optional: the URI of the projects central witness catalogue -->
  <xsl:param name="wit-catalog" as="xs:string" select="string()"/>

  <!-- the font to use with TeX -->
  <xsl:param name="font" as="xs:string" select="'FreeSerif'" required="false"/>

  <!-- base font size -->
  <xsl:param name="fontsize" as="xs:string" select="'12pt'" required="false"/>

  <!-- scaling factor of the main font -->
  <xsl:param name="fontscale" as="xs:string" select="'1'" required="false"/>

  <!-- additional font features, must start with a comma, e.g. ,AutoFakeBold=3.5 -->
  <xsl:param name="fontfeatures" as="xs:string" select="''"/>

  <!-- width of the verses' caesura in times of the tatweel (tatwir) elongation character -->
  <xsl:param name="tatweel-times" as="xs:integer" select="8" required="false"/>

  <!-- whether to show LaTeX debugging features like frames etc. -->
  <xsl:param name="debug-latex" as="xs:boolean" select="false()" required="false"/>

  <!-- where kashida elongation is to be applied -->
  <xsl:param name="kashida" as="xs:string" select="'verse'" required="false"/>

  <!-- types of div in which verses are embedded and thus are printed without extra vertical space -->
  <xsl:param name="embedded-verse-contexts" as="xs:string*" select="('letter', 'bio', 'intro')"/>


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


      <!-- correct parens and brackets -->
      <xsl:template mode="app:reading-text" match="text()">
        <xsl:value-of select="alea:proc-text-node(.)"/>
      </xsl:template>

    </xsl:override>
  </xsl:use-package>

  <xsl:variable name="apparatus-entries" as="map(xs:string, map(*))"
    select="app:apparatus-entries($current) => seed:note-based-apparatus-nodes-map(true())"/>
  <xsl:variable name="editorial-notes" as="map(xs:string, map(*))"
    select="app:apparatus-entries($current, 'descendant-or-self::note[ancestor::text]', 2) => seed:note-based-apparatus-nodes-map(true())"/>


  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libcouplet.xsl"
    package-version="1.0.0">
    <xsl:override>
      <xsl:template name="verse:fill-caesura" as="text()*">
        <xsl:context-item as="element(l)" use="required"/>
        <xsl:call-template name="verse:fill-tatweel"/>
      </xsl:template>
    </xsl:override>

  </xsl:use-package>


  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libtext.xsl"
    package-version="1.0.0">
    <xsl:override>

      <xsl:param name="edmac:section-workaround" as="xs:boolean" select="true()"/>

      <!-- make apparatus footnotes -->
      <xsl:template name="text:inline-footnotes">
        <xsl:context-item as="element()" use="required"/>
        <xsl:message>apparatus footnote</xsl:message>
        <xsl:call-template name="app:footnote-marks">
          <xsl:with-param name="entries" select="$apparatus-entries"/>
        </xsl:call-template>
        <xsl:call-template name="app:footnote-marks">
          <xsl:with-param name="entries" select="$editorial-notes"/>
        </xsl:call-template>
      </xsl:template>

      <xsl:template name="text:verse">
        <xsl:call-template name="verse:verse"/>
      </xsl:template>

      <xsl:template mode="text:hook-ahead" match="*[@met]">
        <!-- set the verse meter (metrum) before the verse environment starts -->
        <xsl:message use-when="system-property('debug') eq 'true'">
          <xsl:text>setting verse meter to </xsl:text>
          <xsl:value-of select="@met"/>
          <xsl:text>: </xsl:text>
          <xsl:value-of select="alea:meter(@met)"/>
        </xsl:message>
        <xsl:text>&lb;\versemeter</xsl:text>
        <xsl:text>{</xsl:text>
        <xsl:value-of select="alea:meter(@met)"/>
        <xsl:text>}%&lb;</xsl:text>
      </xsl:template>

      <xsl:template mode="text:hook-behind" match="*[@met]">
        <xsl:variable name="is-embedded" as="xs:boolean"
          select="some $t in tokenize(ancestor::div[1]/@type) satisfies  $embedded-verse-contexts = $t"/>
        <xsl:if test="not($is-embedded)">
          <xsl:text>&lb;\poemafterskip&lb;</xsl:text>
        </xsl:if>
      </xsl:template>

      <xsl:template mode="text:hook-ahead" match="quote[@type eq 'verbatim-holy']">
        <xsl:message use-when="system-property('debug') eq 'true'">
          <xsl:text>opening parenthesis for verbatim citation of holy text</xsl:text>
        </xsl:message>
        <xsl:text>\arabicornateoparen{}</xsl:text>
      </xsl:template>

      <xsl:template mode="text:hook-after" match="quote[@type eq 'verbatim-holy']">
        <xsl:message use-when="system-property('debug') eq 'true'">
          <xsl:text>closing parenthesis for verbatim citation of holy text</xsl:text>
        </xsl:message>
        <xsl:text>\arabicornatecparen{}</xsl:text>
      </xsl:template>

      <xsl:template mode="text:hook-ahead" match="quote[@type eq 'verbatim']">
        <xsl:message use-when="system-property('debug') eq 'true'">
          <xsl:text>opening parenthesis for verbatim citation of holy text</xsl:text>
        </xsl:message>
        <xsl:text>\arabicoparen{}</xsl:text>
      </xsl:template>

      <xsl:template mode="text:hook-after" match="quote[@type eq 'verbatim']">
        <xsl:message use-when="system-property('debug') eq 'true'">
          <xsl:text>closing parenthesis for verbatim citation of holy text</xsl:text>
        </xsl:message>
        <xsl:text>\arabiccparen{}</xsl:text>
      </xsl:template>

      <xsl:template mode="text:hook-before" match="supplied">
        <xsl:text>\arabicobracket{}</xsl:text>
      </xsl:template>

      <xsl:template mode="text:hook-after" match="supplied">
        <xsl:text>\arabiccbracket{}</xsl:text>
      </xsl:template>

    </xsl:override>
  </xsl:use-package>


  <!-- todo: move to reasonable place -->
  <!-- a template for displaying the meter (metrum) of verse -->
  <xsl:function name="alea:meter" as="xs:string">
    <xsl:param name="met" as="attribute(met)"/>
    <xsl:variable name="meter" as="xs:string" select="string($met)"/>
    <xsl:choose>
      <xsl:when test="root($met)//teiHeader//metSym[@value eq $meter]//term[@xml:lang eq 'ar']">
        <!-- The meters name is pulled from the metDecl
            in the encodingDesc in the document header -->
        <xsl:value-of
          select="root($met)//teiHeader//metSym[@value eq $meter][1]//term[@xml:lang eq 'ar']"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$met"/>
        <xsl:message use-when="system-property('debug') eq 'true'">
          <xsl:text>no metSym found for </xsl:text>
          <xsl:value-of select="$met"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- we may need some corrections on text nodes -->
  <xsl:function name="alea:proc-text-node" as="xs:string">
    <xsl:param name="text" as="xs:string"/>
    <xsl:sequence
      select="$text => replace('\(', '\\arabicoparen{}') => replace('\)', '\\arabiccparen{}')"/>
  </xsl:function>


  <xsl:mode on-no-match="shallow-skip"/>

  <xsl:template match="/ | TEI">
    <xsl:choose>
      <xsl:when test="$latex-header">
        <xsl:for-each select="$latex-header">
          <xsl:value-of select="resolve-uri(., static-base-uri()) => unparsed-text()"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="latex-header"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&lb;&lb;\begin{document}&lb;</xsl:text>

    <!--xsl:text>&lb;\pagenumbering{arabicnum}</xsl:text-->

    <!-- Durchschuss -->
    <xsl:text>&lb;\setlength{\baselineskip}{28pt}</xsl:text>
    <!-- negative lineskiplimit fixes the baselineskip (no glue) -->
    <xsl:text>&lb;\setlength{\lineskiplimit}{-100pt}</xsl:text>

    <xsl:call-template name="latex-front"/>
    <xsl:text>&lb;&lb;\selectlanguage{arabic}</xsl:text>
    <xsl:text>&lb;&lb;%% main content</xsl:text>
    <xsl:apply-templates mode="text:text" select="/TEI/text/body"/>
    <xsl:text>&lb;</xsl:text>
    <xsl:call-template name="latex-back"/>
    <xsl:text>&lb;\end{document}&lb;</xsl:text>
    <xsl:call-template name="latex-footer"/>
  </xsl:template>

  <xsl:template name="latex-header" visibility="public">
    <!-- it does not work with koma-script classes
    <xsl:text>\documentclass{scrbook}</xsl:text>
    <xsl:text>&lb;\KOMAoption{fontsize}{14pt}</xsl:text>
    -->
    <xsl:text>\documentclass{book}</xsl:text>
    <xsl:text>&lb;\usepackage[fontsize=</xsl:text>
    <xsl:value-of select="$fontsize"/>
    <xsl:text>]{scrextend}</xsl:text>

    <!-- typearea of the books in the ALEA series -->
    <xsl:text>&lb;\usepackage[text={113mm,185mm}]{geometry}</xsl:text>


    <xsl:if test="$debug-latex">
      <xsl:text>&lb;\usepackage{showframe}</xsl:text>
    </xsl:if>

    <!-- input encoding -->
    <xsl:text>&lb;\usepackage{ifluatex}</xsl:text>
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
    <xsl:text>&lb;\babelprovide[import,main,justification=kashida,transforms=kashida.afterdiacritics.plain]{arabic}</xsl:text>
    <xsl:text>&lb;\directlua{Babel.arabic.kashida_after_diacritics = true}</xsl:text>
    <xsl:text>&lb;\directlua{Babel.arabic.kashida_after_ligature_allowed = false}</xsl:text>
    <xsl:for-each select="('rm', 'sf', 'tt')">
      <xsl:text>&lb;\babelfont{</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>}[Scale=</xsl:text>
      <xsl:value-of select="$fontscale"/>
      <xsl:value-of select="$fontfeatures"/>
      <xsl:text>]{</xsl:text>
      <xsl:value-of select="$font"/>
      <xsl:text>}</xsl:text>
    </xsl:for-each>
    <xsl:text>&lb;\setRTLmain</xsl:text>

    <xsl:text>&lb;\newcommand*{\arabicobracket}{]}</xsl:text>
    <xsl:text>&lb;\newcommand*{\arabiccbracket}{[}</xsl:text>
    <xsl:text>&lb;\newcommand*{\arabicoparen}{)}</xsl:text>
    <xsl:text>&lb;\newcommand*{\arabiccparen}{(}</xsl:text>
    <xsl:text>&lb;\newcommand*{\arabicornateoparen}{﴿}</xsl:text>
    <xsl:text>&lb;\newcommand*{\arabicornatecparen}{﴾}</xsl:text>

    <xsl:call-template name="text:latex-header"/>
    <xsl:call-template name="i18n:latex-header"/>
    <xsl:call-template name="app:latex-header"/>
    <xsl:call-template name="arabic-numbering"/>

    <!-- does not give footnotes in para
    <xsl:text>&lb;\let\Footnote\undefined</xsl:text>
    <xsl:text>&lb;\usepackage[perpage,para]{manyfoot}</xsl:text>
    -->
    <xsl:text>&lb;\usepackage{reledmac}</xsl:text>
    <xsl:choose>
      <xsl:when test="$debug-latex">
        <xsl:text>&lb;\firstlinenum{1}</xsl:text>
        <xsl:text>&lb;\linenumincrement{1}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>&lb;\firstlinenum{1}</xsl:text>
        <xsl:text>&lb;\linenumincrement{1}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&lb;\renewcommand{\footfudgefiddle}{100}</xsl:text>
    <xsl:text>&lb;\lineation{page}</xsl:text>
    <xsl:text>&lb;\linenummargin{outer}</xsl:text>
    <xsl:text>&lb;\fnpos{critical-familiar}</xsl:text>
    <xsl:text>&lb;\Xarrangement{paragraph}</xsl:text>
    <xsl:text>&lb;\Xnonbreakableafternumber</xsl:text>
    <xsl:text>&lb;\Xnumberonlyfirstinline</xsl:text>
    <xsl:text>&lb;\Xsymlinenum{ | }</xsl:text>
    <xsl:text>&lb;\Xlemmafont{\normalfont}</xsl:text>
    <!--xsl:text>&lb;\Xwraplemma{\RL}</xsl:text>
    <xsl:text>&lb;\Xwrapcontent{\RL}</xsl:text-->
    <xsl:text>&lb;\setlength{\parindent}{0pt}</xsl:text>
    <xsl:text>&lb;%% setting for rtl</xsl:text>
    <xsl:text>&lb;\Xbhookgroup{\textdir TRT}</xsl:text>

    <xsl:text>&lb;\pagestyle{plain}</xsl:text>
    <xsl:text>&lb;\setcounter{secnumdepth}{0}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\pb}[1]{ |\ledinnernote{#1} }</xsl:text>

    <xsl:text>&lb;&lb;%% overrides</xsl:text>
    <xsl:text>&lb;\renewcommand*{\milestone}[2]{\RL{\arabicobracket{}#1\arabiccbracket{}}}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\gap}{ \arabicobracket{}...\arabiccbracket{} }</xsl:text>

    <xsl:text>&lb;&lb;%% typesetting arabic poetry</xsl:text>
    <xsl:text>&lb;\usepackage{ifthen}</xsl:text>
    <xsl:text>&lb;\newcommand{\true}{true}</xsl:text>
    <xsl:text>&lb;\makeatletter</xsl:text>
    <xsl:text>&lb;\def\@verse@meter{?} %% always have verse meter!</xsl:text>
    <xsl:text>&lb;\newcommand*{\versemeter}[1]{\def\@verse@meter{#1}}</xsl:text>
    <xsl:text>&lb;\def\@verse@isembedded{false} %% always have embedding information</xsl:text>
    <xsl:text>&lb;\newcommand*{\embeddedverse}[1]{\def\@verse@isembedded{#1}}</xsl:text>
    <xsl:text>&lb;\makeatother</xsl:text>
    <xsl:text>&lb;\setlength{\stanzaindentbase}{10pt}</xsl:text>
    <xsl:text>&lb;\setstanzaindents{1,1}% for reledmac's stanzas</xsl:text>
    <xsl:text>&lb;\setcounter{stanzaindentsrepetition}{1}</xsl:text>
    <xsl:call-template name="verse:latex-header"/>
    <xsl:text>&lb;\AtEveryStanza{%</xsl:text>
    <xsl:text>&lb;  \let\oldpb\pb%</xsl:text>
    <xsl:text>&lb;  \let\pb\ledinnernote%</xsl:text>
    <xsl:text>&lb;  }</xsl:text>
    <xsl:text>&lb;\makeatletter</xsl:text>
    <xsl:text>&lb;\AtStartEveryStanza{\setRL\relax{}\arabicobracket\@verse@meter\arabiccbracket\newverse\relax}</xsl:text>
    <xsl:text>&lb;\AtEveryStopStanza{%</xsl:text>
    <xsl:text>&lb;  %\ifthenelse{\equal{true}{\@verse@isembedded}}{}{\smallskip}</xsl:text>
    <xsl:text>&lb;  %\smallskip% skip after stanza</xsl:text>
    <xsl:text>&lb;  \let\pb\oldpb%</xsl:text>
    <xsl:text>&lb;  }</xsl:text>
    <xsl:text>&lb;\makeatother</xsl:text>
    <xsl:text>&lb;\usepackage{calc}</xsl:text>
    <xsl:text>&lb;\makeatletter</xsl:text>
    <xsl:text>&lb;\settowidth{\hst@gutter@width}{</xsl:text>
    <xsl:for-each select="1 to $tatweel-times">
      <xsl:text>&#x640;</xsl:text>
    </xsl:for-each>
    <xsl:text>}</xsl:text>
    <xsl:text>&lb;%% for indent before verse say ...-0.5\stanzaindentbase</xsl:text>
    <xsl:text>&lb;%% for indent on both sides say ...-\stanzaindentbase</xsl:text>
    <xsl:text>&lb;\setlength{\hst@hemistich@width}{.5\textwidth-.5\hst@gutter@width-\stanzaindentbase}</xsl:text>
    <xsl:text>&lb;\makeatother</xsl:text>
    <xsl:text>&lb;\newcommand{\poemafterskip}{}</xsl:text>

    <!-- set kashida elongation rule -->
    <xsl:choose>
      <xsl:when test="$kashida eq 'global'">
        <xsl:text>&lb;\directlua{Babel.arabic.justify_enabled=true}</xsl:text>
      </xsl:when>
      <xsl:when test="$kashida eq 'verse'">
        <xsl:text>&lb;\directlua{Babel.arabic.justify_enabled=false}</xsl:text>
        <xsl:text>&lb;\renewcommand*{\hemistichEnd}{\directlua{Babel.arabic.justify_enabled=true}}</xsl:text>
        <xsl:text>&lb;\renewcommand*{\afterHemistich}{\directlua{Babel.arabic.justify_enabled=false}}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>&lb;\directlua{Babel.arabic.justify_enabled=false}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>

    <!-- workaround for broken sectioning commands in reledmac -->
    <xsl:call-template name="text:latex-header-workaround36"/>
    <xsl:text>&lb;\renewcommand*{\seedchapterfont}[1]{\bfseries #1}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\seedsectionfont}[1]{\bfseries #1}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\seedsubsectionfont}[1]{\bfseries #1}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\seedsubsubsectionfont}[1]{\bfseries #1}</xsl:text>


    <xsl:text>&lb;\setlength{\emergencystretch}{3em}</xsl:text>
  </xsl:template>

  <xsl:template name="latex-front" visibility="public">
    <xsl:text>&lb;%%\maketitle</xsl:text>
  </xsl:template>

  <xsl:template name="latex-back" visibility="public"/>

  <xsl:template name="arabic-numbering">
    <xsl:text>
\makeatletter
\newcommand*{\@arabicnum}[1]{%
  \ifcase#1%
    ٠%
  \or
    ١%
  \or
    ٢%
  \or
    ٣%
  \or
    ٤%
  \or
    ٥%
  \or
    ٦%
  \or
    ٧%
  \or
    ٨%
  \or
    ٩%
  \else
    \@ctrerr
  \fi
}
\newcommand*{\arabicnum}[1]{%
  \expandafter\@arabicnum\csname c@#1\endcsname
}
\makeatother
    </xsl:text>
  </xsl:template>

  <xsl:template name="latex-footer">
    <!-- local variables for AUCTeX -->
    <xsl:text>&lb;&lb;%%% Local Variables:</xsl:text>
    <xsl:text>&lb;%%% mode: latex</xsl:text>
    <xsl:text>&lb;%%% TeX-master: t</xsl:text>
    <xsl:text>&lb;%%% TeX-engine: luatex</xsl:text>
    <xsl:text>&lb;%%% TeX-PDF-mode: t</xsl:text>
    <xsl:text>&lb;%%% End:</xsl:text>
  </xsl:template>

</xsl:package>
