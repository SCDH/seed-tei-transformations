<!-- An XSLT package with a preamble for ALEA's publication at Ergon Verlag

This derives xsl/latex/libpreamble.xsl and is used similar.

USAGE: create a mainfile

target/bin/xslt.sh \
  -config:saxon.he.xml \
  -xsl:xsl/projects/alea/latex/preamble.xsl \
  -it:{http://scdh.wwu.de/transform/preamble#}mainfile \
  - xi \
  -s:/home/clueck/Projekte/edition-ibn-nubatah/Test/Sag1.tei.xml \
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
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/latex/preamble.xsl"
  package-version="1.0" version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:preamble="http://scdh.wwu.de/transform/preamble#"
  xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:app="http://scdh.wwu.de/transform/app#"
  xmlns:note="http://scdh.wwu.de/transform/note#" xmlns:seed="http://scdh.wwu.de/transform/seed#"
  xmlns:text="http://scdh.wwu.de/transform/text#" xmlns:verse="http://scdh.wwu.de/transform/verse#"
  xmlns:edmac="http://scdh.wwu.de/transform/edmac#" xmlns:rend="http://scdh.wwu.de/transform/rend#"
  xmlns:common="http://scdh.wwu.de/transform/common#"
  xmlns:meta="http://scdh.wwu.de/transform/meta#" xmlns:wit="http://scdh.wwu.de/transform/wit#"
  xmlns:alea="http://scdh.wwu.de/transform/alea#" xmlns:index="http://scdh.wwu.de/transform/index#"
  xmlns:surah="http://scdh.wwu.de/transform/surah#" xmlns:poem="http://scdh.wwu.de/transform/poem#"
  xmlns:ref="http://scdh.wwu.de/transform/ref#"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0">

  <xsl:output method="text" encoding="UTF-8"/>

  <!-- the font to use with TeX -->
  <xsl:param name="font" as="xs:string" select="'FreeSerif'" required="false"/>

  <!-- base font size -->
  <xsl:param name="fontsize" as="xs:string" select="'12pt'" required="false"/>

  <!-- additional font features, e.g. AutoFakeBold=3.5 -->
  <xsl:param name="fontfeatures" as="xs:string" select="''"/>

  <!-- the baselineskip -->
  <xsl:param name="baselineskip" as="xs:string" select="'28pt'"/>

  <!-- the count of lines on a page minus one -->
  <xsl:param name="lines" as="xs:integer" select="21"/>

  <!-- correction of textheight after evaluating  \topskip+$lines*\baselineskip -->
  <xsl:param name="textheight-correction" as="xs:string" select="'-5mm'"/>

  <!-- width of the verses' caesura in times of the tatweel (tatwir) elongation character -->
  <xsl:param name="tatweel-times" as="xs:integer" select="8" required="false"/>

  <!-- whether to show LaTeX debugging features like frames etc. -->
  <xsl:param name="debug-latex" as="xs:boolean" select="false()" required="false"/>

  <!-- value of reledmac's footfudgefiddle -->
  <xsl:param name="footfudgefiddle" as="xs:integer" select="90"/>

  <!-- where kashida elongation is to be applied -->
  <xsl:param name="kashida" as="xs:string" select="'verse'" required="false"/>


  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/latex/libsurahidx.xsl"
    package-version="1.0.0"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/latex/libpoemidx.xsl"
    package-version="1.0.0"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libindex.xsl"
    package-version="1.0.0"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libapp2.xsl"
    package-version="1.0.0"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libtext.xsl"
    package-version="1.0.0"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libi18n.xsl"
    package-version="1.0.0">
    <xsl:override>
      <xsl:variable name="i18n:default-language" as="xs:string">
        <xsl:try>
          <xsl:value-of select="/TEI/@xml:lang"/>
          <xsl:catch>
            <xsl:value-of select="'ar'"/>
          </xsl:catch>
        </xsl:try>
      </xsl:variable>
    </xsl:override>
  </xsl:use-package>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libcouplet.xsl"
    package-version="1.0.0"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libpreamble.xsl"
    package-version="1.0.0">
    <xsl:accept component="template" names="preamble:header" visibility="final"/>
    <xsl:accept component="template" names="preamble:footer" visibility="final"/>
    <xsl:accept component="template" names="preamble:mainfile" visibility="final"/>
    <xsl:override>

      <xsl:template name="preamble:preamble">
        <xsl:call-template name="alea:preamble"/>
      </xsl:template>

      <xsl:template name="preamble:maketitle"/>

    </xsl:override>
  </xsl:use-package>



  <xsl:template name="alea:preamble" visibility="public">
    <xsl:text>&lb;\usepackage[fontsize=</xsl:text>
    <xsl:value-of select="$fontsize"/>
    <xsl:text>]{fontsize}</xsl:text>

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
    <xsl:text>&lb;%% Note: mapdigits causes the engine to replace western arabic digits by arabic script digits.</xsl:text>
    <xsl:text>&lb;%% To keep western digits in some places, the language must be set to ngerman or english.</xsl:text>
    <xsl:text>&lb;\babelprovide[import,main,justification=kashida,transforms=kashida.afterdiacritics.plain,mapdigits,mapfont=direction]{arabic}</xsl:text>
    <xsl:text>&lb;\directlua{Babel.arabic.kashida_after_diacritics = true}</xsl:text>
    <xsl:text>&lb;\directlua{Babel.arabic.kashida_after_ligature_allowed = false}</xsl:text>
    <xsl:for-each select="('rm', 'sf', 'tt')">
      <xsl:text>&lb;\babelfont{</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>}[</xsl:text>
      <xsl:value-of select="$fontfeatures"/>
      <xsl:text>]{</xsl:text>
      <xsl:value-of select="$font"/>
      <xsl:text>}</xsl:text>
    </xsl:for-each>
    <xsl:text>&lb;\setRTLmain</xsl:text>

    <xsl:text>&lb;\newlength{\aleabaselineskip}</xsl:text>
    <xsl:text>&lb;\setlength{\aleabaselineskip}{</xsl:text>
    <xsl:value-of select="$baselineskip"/>
    <xsl:text>}</xsl:text>

    <xsl:text>&lb;%% baselineskip must be set in the document environment, not in preamble</xsl:text>
    <xsl:text>&lb;\AtBeginDocument{%</xsl:text>
    <xsl:text>&lb;  \setlength{\baselineskip}{\aleabaselineskip}%</xsl:text>
    <xsl:text>&lb;  \setlength{\lineskiplimit}{-100pt}%</xsl:text>
    <xsl:text>&lb;}</xsl:text>
    <xsl:text>&lb;\setlength{\baselineskip}{\aleabaselineskip}</xsl:text>

    <xsl:text>&lb;%% calculate the height and depth of a arabic letters from extreme examples</xsl:text>
    <xsl:text>&lb;\newlength{\ArabicCharHeight}%</xsl:text>
    <xsl:text>&lb;\settoheight{\ArabicCharHeight}{\hbox{تَحلَّتْ يُخْلِ أُصول المُتمكِّن}}% height from lam + wasla + shadda etc.</xsl:text>
    <xsl:text>&lb;\setlength{\topskip}{\ArabicCharHeight}%</xsl:text>
    <xsl:text>&lb;\newlength{\ArabicCharDepth}</xsl:text>
    <xsl:text>&lb;\settodepth{\ArabicCharDepth}{\hbox{والإطْلاعِ فليطّلِعْ بالتصفُّح }}% depth from </xsl:text>
    <xsl:text>&lb;\setlength{\maxdepth}{\ArabicCharDepth}% 9pt would also work, but 8pt isn't enough</xsl:text>
    <!-- TODO: should we set up \strut or \strutbox from that? -->

    <xsl:text>&lb;%% calculate textheight so that it is an integral multiple of line heights</xsl:text>
    <xsl:text>&lb;%\usepackage{calc}</xsl:text>
    <xsl:text>&lb;\newlength{\LinesN}% height of 25 lines</xsl:text>
    <xsl:text>&lb;\setlength{\LinesN}{\topskip}%</xsl:text>
    <xsl:text>&lb;\addtolength{\LinesN}{</xsl:text>
    <xsl:value-of select="$lines"/>
    <xsl:text>\aleabaselineskip}% N-1 lines</xsl:text>

    <!-- typearea of the books in the ALEA series -->
    <!-- top margin: 22.5mm, but reduced by 3mm which are added to headsep -->
    <xsl:text>&lb;\usepackage[papersize={170mm,240mm},inner=23mm,textwidth=113mm,top=\dimexpr(29mm-\ArabicCharHeight),headheight=8mm,headsep=2mm,textheight=\LinesN]{geometry}% % bottom=21mm</xsl:text>
    <xsl:text>&lb;%\addtolength{\headsep}{1mm}% this would have to be substracted from top</xsl:text>

    <xsl:text>&lb;%% geometry for non-editorial parts of the book, e.g., preface, registers, etc.</xsl:text>
    <xsl:text>&lb;\newcommand{\nonmarginlayout}{%</xsl:text>
    <xsl:text>&lb;  \newgeometry{inner=23mm,outer=23mm,top=\dimexpr(29mm-\ArabicCharHeight),headheight=8mm,headsep=2mm,textheight=\LinesN}% bottom=21mm</xsl:text>
    <xsl:text>&lb;  \fancyfootoffset{0pt}% recalculate \headwidth</xsl:text>
    <xsl:text>&lb;  \setlength{\baselineskip}{\aleabaselineskip}%</xsl:text>
    <xsl:text>&lb;  \setlength{\lineskiplimit}{-100pt}%</xsl:text>
    <xsl:text>&lb;}</xsl:text>

    <xsl:if test="$debug-latex and false()">
      <!-- draw the baseline for the first line -->
      <xsl:text>&lb;\usepackage[placement=top]{background}</xsl:text>
      <xsl:text>&lb;\SetBgScale{1}</xsl:text>
      <xsl:text>&lb;\SetBgAngle{0}</xsl:text>
      <xsl:text>&lb;\SetBgColor{red}</xsl:text>
      <xsl:text>&lb;\SetBgContents{\rule{\paperwidth}{.4pt}}</xsl:text>
      <xsl:text>&lb;\SetBgHshift{\textwidth}</xsl:text>
      <xsl:text>&lb;\SetBgVshift{-19.5mm+.4pt-\topskip}% top parameter from geometry, line thickness, topskip to get baseline of first line</xsl:text>
    </xsl:if>

    <xsl:if test="$debug-latex">
      <xsl:text>&lb;%% draw a red line at every baseline</xsl:text>
      <xsl:text>&lb;\usepackage{atbegshi,picture,xcolor}</xsl:text>
      <xsl:text>&lb;\AtBeginShipout{%</xsl:text>
      <xsl:text>&lb;  \AtBeginShipoutUpperLeft{%</xsl:text>
      <xsl:text>&lb;    {\color{red}%</xsl:text>
      <xsl:text>&lb;      \put(\dimexpr -1in-\oddsidemargin,%</xsl:text>
      <xsl:text>&lb;      -\dimexpr 1in+\topmargin+\headheight+\headsep+\topskip)%</xsl:text>
      <xsl:text>&lb;      {%</xsl:text>
      <xsl:text>&lb;        \vtop to\dimexpr\vsize+\aleabaselineskip{%</xsl:text>
      <xsl:text>&lb;          \hrule%</xsl:text>
      <xsl:text>&lb;          \leaders\vbox to\aleabaselineskip{\hrule width2\paperwidth\vfill}\vfill%</xsl:text>
      <xsl:text>&lb;        }%</xsl:text>
      <xsl:text>&lb;      }%</xsl:text>
      <xsl:text>&lb;    }}%</xsl:text>
      <xsl:text>&lb;}</xsl:text>
    </xsl:if>

    <xsl:if test="$debug-latex">
      <xsl:text>&lb;\usepackage{fgruler}</xsl:text>
      <xsl:text>&lb;\usepackage{showframe}</xsl:text>
    </xsl:if>

    <xsl:text>&lb;\newcommand*{\arabicobracket}{]}</xsl:text>
    <xsl:text>&lb;\newcommand*{\arabiccbracket}{[}</xsl:text>
    <xsl:text>&lb;\newcommand*{\arabicoparen}{)}</xsl:text>
    <xsl:text>&lb;\newcommand*{\arabiccparen}{(}</xsl:text>
    <xsl:text>&lb;\newcommand*{\arabicornateoparen}{﴿}</xsl:text>
    <xsl:text>&lb;\newcommand*{\arabicornatecparen}{﴾}</xsl:text>

    <xsl:call-template name="text:latex-header"/>
    <xsl:call-template name="i18n:latex-header"/>
    <xsl:call-template name="app:latex-header"/>

    <xsl:text>&lb;\begin{filecontents}{alea.ist}</xsl:text>
    <xsl:text>&lb;delim_0 ": "</xsl:text>
    <xsl:text>&lb;delim_1 ": "</xsl:text>
    <xsl:text>&lb;delim_2 "، "</xsl:text>
    <xsl:text>&lb;\end{filecontents}</xsl:text>
    <xsl:call-template name="index:translation-package-filecontents"/>
    <xsl:call-template name="rend:latex-header-index"/>
    <xsl:call-template name="surah:latex-header"/>
    <xsl:call-template name="poem:latex-header"/>
    <xsl:text>&lb;\newcommand{\seedidxlevel}[1]{\large #1}</xsl:text>
    <xsl:text>&lb;\indexsetup{othercode=\footnotesize,level=\section*,toclevel=section,firstpagestyle=empty}</xsl:text>


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
        <xsl:text>&lb;%\firstlinenum{1}</xsl:text>
        <xsl:text>&lb;%\linenumincrement{1}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>&lb;\renewcommand{\footfudgefiddle}{</xsl:text>
    <xsl:value-of select="$footfudgefiddle"/>
    <xsl:text>}</xsl:text>
    <xsl:text>&lb;\lineation{page}</xsl:text>
    <xsl:text>&lb;\linenummargin{outer}</xsl:text>
    <xsl:text>&lb;\fnpos{critical-familiar}</xsl:text>
    <xsl:text>&lb;\Xarrangement{paragraph}</xsl:text>
    <xsl:text>&lb;\Xnonbreakableafternumber</xsl:text>
    <xsl:text>&lb;\Xnumberonlyfirstinline</xsl:text>
    <xsl:text>&lb;\Xafternumber{.5em plus.4em minus.4em}% default value 0.5em</xsl:text>
    <xsl:text>&lb;\Xafternote{1em plus.4em minus.9em} % important</xsl:text>
    <xsl:text>&lb;\Xbhooknote{\linebreak[1]}% important for getting spacing right</xsl:text>
    <xsl:text>&lb;\Xsymlinenum{|}% not working: {\penalty10000|\linebreak[1]}</xsl:text>
    <xsl:text>&lb;\Xlemmaseparator{\arabiccbracket}</xsl:text>
    <xsl:text>&lb;\Xlemmafont{\normalfont}</xsl:text>
    <!--xsl:text>&lb;\Xwraplemma{\RL}</xsl:text>
    <xsl:text>&lb;\Xwrapcontent{\RL}</xsl:text-->
    <xsl:text>&lb;\setlength{\parindent}{0pt}</xsl:text>
    <xsl:text>&lb;%% setting for rtl</xsl:text>
    <xsl:text>&lb;\Xbhookgroup{\textdir TRT}</xsl:text>

    <xsl:text>&lb;\pagestyle{plain}</xsl:text>

    <!-- to which level section titles go into the table of contents -->
    <xsl:text>&lb;&lb;\setcounter{secnumdepth}{-1}% chapters only</xsl:text>
    <xsl:text>&lb;\setcounter{tocdepth}{0}% toc entries only to chapter level</xsl:text>

    <xsl:text>&lb;%% Note: \foreignlanguage{english}{...} is used to get western digits for folio numbers.</xsl:text>
    <xsl:text>&lb;\newcommand*{\innernoteenglish}[1]{\ledinnernote{\foreignlanguage{english}{#1}}}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\pb}[1]{{\normalfont|}\ledinnernote{\foreignlanguage{english}{#1}} }</xsl:text>
    <xsl:text>&lb;\newcommand*{\pbnomark}[1]{\ledinnernote{\foreignlanguage{english}{#1}}\ignorespaces}</xsl:text>

    <xsl:text>&lb;&lb;%% overrides</xsl:text>
    <xsl:text>&lb;\renewcommand*{\milestone}[2]{\RL{{\normalfont\arabicobracket{}}#1{\normalfont\arabiccbracket{}}}}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\gap}{ {\normalfont\arabicobracket{}...\arabiccbracket{}} }</xsl:text>

    <xsl:text>&lb;&lb;%% typesetting arabic poetry</xsl:text>
    <xsl:text>&lb;\usepackage{ifthen}</xsl:text>
    <xsl:text>&lb;\newcommand{\true}{true}</xsl:text>
    <xsl:text>&lb;\makeatletter</xsl:text>
    <xsl:text>&lb;\def\@verse@meter{?} %% always have verse meter!</xsl:text>
    <xsl:text>&lb;\newcommand*{\versemeter}[1]{\def\@verse@meter{#1}}</xsl:text>
    <xsl:text>&lb;\def\@verse@isembedded{false} %% always have embedding information</xsl:text>
    <xsl:text>&lb;\newcommand*{\embeddedverse}[1]{\def\@verse@isembedded{#1}}</xsl:text>
    <xsl:text>&lb;\makeatother</xsl:text>
    <xsl:text>&lb;\setlength{\stanzaindentbase}{0pt}</xsl:text>
    <xsl:text>&lb;\setstanzaindents{1,1}% for reledmac's stanzas</xsl:text>
    <xsl:text>&lb;\setcounter{stanzaindentsrepetition}{1}</xsl:text>
    <xsl:call-template name="verse:latex-header"/>
    <xsl:text>&lb;\AtEveryStanza{%</xsl:text>
    <xsl:text>&lb;  \let\oldpb\pb%</xsl:text>
    <xsl:text>&lb;  \let\pb\pbnomark}</xsl:text>
    <xsl:text>&lb;\makeatletter</xsl:text>
    <xsl:text>&lb;\AtStartEveryStanza{\setRL\relax{}\arabicobracket\@verse@meter\arabiccbracket\newverse\relax\lednopb}</xsl:text>
    <xsl:text>&lb;\AtEveryStopStanza{%</xsl:text>
    <xsl:text>&lb;  %\ifthenelse{\equal{true}{\@verse@isembedded}}{}{}</xsl:text>
    <xsl:text>&lb;  %\smallskip% skip after stanza, set to third argument if wanted</xsl:text>
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
    <!--xsl:call-template name="text:latex-header-full-seedskips"/-->
    <xsl:text>&lb;\makeatletter</xsl:text>
    <xsl:text>&lb;\renewcommand*{\seedchapterfont}[1]{\bfseries #1}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\seedsectionfont}[1]{\bfseries #1}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\seedsubsectionfont}[1]{\bfseries #1}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\seedsubsubsectionfont}[1]{\bfseries #1}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\seedchapterbeforeskip}{\penalty-1001}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\seedchapterafterskip}{}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\seedsectionbeforeskip}{\penalty-1001}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\seedsectionafterskip}{}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\seedsubsectionbeforeskip}{\penalty-1001}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\seedsubsectionafterskip}{}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\seedsubsubsectionbeforeskip}{\penalty-1001}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\seedsubsubsectionafterskip}{}</xsl:text>
    <xsl:text>&lb;\makeatother</xsl:text>

    <!-- set style section titles, non-reledmac -->
    <xsl:text>&lb;\usepackage{titlesec}</xsl:text>
    <xsl:text>&lb;\titleformat{\chapter}{\Large\normalfont}{}{0pt}{}{}</xsl:text>
    <xsl:text>&lb;\titleformat{\section}{\normalsize\bfseries}{}{0pt}{}{}</xsl:text>
    <xsl:text>&lb;\titlespacing*{\section}{0pt}{*2}{*0}</xsl:text>
    <xsl:text>&lb;\titleformat{\subsection}{\normalsize\bfseries}{}{0pt}{}{}</xsl:text>
    <xsl:text>&lb;\titlespacing*{\subsection}{0pt}{*2}{*0}</xsl:text>

    <!-- using titlesec means, that titletoc is to be used instead of tocloft -->
    <xsl:text>&lb;\usepackage{titletoc}</xsl:text>
    <xsl:text>&lb;\titlecontents{chapter}[0pt]{}{}{}{\titlerule*[1pc]{.}\contentspage}</xsl:text>
    <xsl:text>&lb;\titlecontents{section}[15pt]{}{}{}{\titlerule*[1pc]{.}\contentspage}</xsl:text>

    <!-- page headers -->
    <xsl:text>&lb;\usepackage{fancyhdr}</xsl:text>
    <xsl:text>&lb;\pagestyle{fancy}</xsl:text>
    <xsl:text>&lb;\fancyhf{}</xsl:text>
    <xsl:text>&lb;\fancyhead[CE]{\normalfont\small\rightmark}</xsl:text>
    <xsl:text>&lb;\fancyhead[CO]{\normalfont\small\leftmark}</xsl:text>
    <xsl:text>&lb;\fancyhead[LE,RO]{\normalfont\small\foreignlanguage{arabic}{\thepage}}</xsl:text>
    <xsl:text>&lb;\renewcommand\headrulewidth{0pt}</xsl:text>
    <xsl:text>&lb;\renewcommand{\chaptermark}[1]{\markboth{#1}{#1}}</xsl:text>
    <xsl:text>&lb;\renewcommand{\sectionmark}[1]{}</xsl:text>
    <xsl:text>&lb;\fancypagestyle{plain}{\fancyhf{}}% reset page style plain which is issued by \chapter etc.</xsl:text>

    <xsl:if test="$debug-latex">
      <xsl:text>&lb;\fancyfoot[CO,CE]{%</xsl:text>
      <xsl:text>&lb;  \foreignlanguage{english}{%</xsl:text>
      <xsl:text>&lb;    baselineskip: \the\aleabaselineskip\ %</xsl:text>
      <xsl:text>&lb;    topskip: \the\topskip\ %</xsl:text>
      <xsl:text>&lb;    maxdepth: \the\maxdepth\ %</xsl:text>
      <xsl:text>&lb;}}</xsl:text>
    </xsl:if>


    <xsl:text>&lb;% let \cleardoublepage amke empty pages</xsl:text>
    <xsl:text>&lb;\let\origcleardoublepage\cleardoublepage</xsl:text>
    <xsl:text>&lb;\renewcommand*{\cleardoublepage}{\clearpage</xsl:text>
    <xsl:text>&lb;  {\thispagestyle{empty}\origcleardoublepage}}</xsl:text>

    <xsl:text>&lb;\setlength{\emergencystretch}{3em}</xsl:text>
  </xsl:template>

</xsl:package>
