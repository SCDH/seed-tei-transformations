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


  <!-- corrects how the section level is set from the level of divs a head coccurs in -->
  <xsl:param name="text:section-level-delta" as="xs:integer" select="0" required="false"/>

  <!-- whether to use a workaround for issues related to sectioning in reledmac, e.g., #976 and #976 -->
  <xsl:param name="edmac:section-workaround" as="xs:boolean" select="false()" required="false"/>

  <!-- names of indices (used by imakeidx) -->
  <xsl:param name="text:indices" as="xs:string*" required="false"
    select="'person', 'place', 'org', 'event'"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libreledmac.xsl"
    package-version="1.0.0"/>

  <xsl:mode name="text:text" on-no-match="shallow-skip" visibility="public"/>

  <xsl:mode name="text:hook-ahead" on-no-match="deep-skip" visibility="public"/>
  <xsl:mode name="text:hook-before" on-no-match="deep-skip" visibility="public"/>
  <xsl:mode name="text:hook-after" on-no-match="deep-skip" visibility="public"/>
  <xsl:mode name="text:hook-behind" on-no-match="deep-skip" visibility="public"/>


  <!-- write PIs from latex target to the output -->
  <xsl:template match="processing-instruction('latex')">
    <xsl:value-of select="."/>
  </xsl:template>

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

  <!-- drop whitespace nodes that from outside pLike -->
  <!--xsl:template match="text()[normalize-space() eq '' and not(ancestor::p | ancestor::l | ancestor::head)]"/-->

  <xsl:template match="teiHeader"/>

  <!-- TODO -->
  <xsl:template match="front | back"/>

  <xsl:template match="body">
    <xsl:text>&lb;&lb;%% begin of text body&lb;\beginnumbering&lb;&lb;</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>&lb;&lb;%% end of text body&lb;\endnumbering&lb;&lb;</xsl:text>
  </xsl:template>

  <xsl:template match="element()">
    <xsl:apply-templates mode="text:hook-ahead" select="."/>
    <xsl:apply-templates mode="text:hook-before" select="."/>
    <xsl:apply-templates/>
    <xsl:apply-templates mode="text:hook-after" select="."/>
    <xsl:apply-templates mode="text:hook-behind" select="."/>
  </xsl:template>


  <!-- document structure -->

  <xsl:variable name="text:section-levels" as="xs:string*"
    select="'chapter', 'section', 'subsection', 'subsubsection'" visibility="public"/>

  <xsl:template match="head">
    <xsl:variable name="level" as="xs:integer" select="text:section-level(.)"/>
    <xsl:apply-templates mode="text:hook-ahead" select=".">
      <xsl:with-param name="level" as="xs:integer" select="$level" tunnel="true"/>
    </xsl:apply-templates>
    <xsl:text>&lb;</xsl:text>
    <xsl:call-template name="edmac:par-start"/>
    <xsl:apply-templates mode="text:hook-before" select=".">
      <xsl:with-param name="level" as="xs:integer" select="$level" tunnel="true"/>
    </xsl:apply-templates>
    <xsl:text>&lb;\eled</xsl:text>
    <xsl:value-of select="$text:section-levels[$level]"/>
    <xsl:text>[</xsl:text>
    <xsl:apply-templates mode="text:text-only"/>
    <xsl:text>]{</xsl:text>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-start'"/>
    </xsl:call-template>
    <xsl:apply-templates/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-end'"/>
    </xsl:call-template>
    <xsl:text>}</xsl:text>
    <xsl:apply-templates mode="text:hook-after" select=".">
      <xsl:with-param name="level" as="xs:integer" select="$level" tunnel="true"/>
    </xsl:apply-templates>
    <xsl:call-template name="edmac:par-end"/>
    <xsl:text>&lb;&lb;</xsl:text>
    <xsl:apply-templates mode="text:hook-behind" select=".">
      <xsl:with-param name="level" as="xs:integer" select="$level" tunnel="true"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template mode="text:hook-ahead" match="head">
    <xsl:param name="level" as="xs:integer" select="0" tunnel="true"/>
    <xsl:choose>
      <xsl:when test="not($edmac:section-workaround)"/>
      <xsl:when test="parent::*/preceding-sibling::*">
        <xsl:text>&lb;&lb;\seed</xsl:text>
        <xsl:value-of select="$text:section-levels[$level]"/>
        <xsl:text>beforeskip&lb;&lb;</xsl:text>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="text:hook-after" match="head">
    <xsl:param name="level" as="xs:integer" select="0" tunnel="true"/>
    <xsl:choose>
      <xsl:when test="not($edmac:section-workaround)"/>
      <xsl:when test="following-sibling::*[1][self::*[child::*[1][self::head]]]">
        <xsl:text>&lb;&lb;\seed</xsl:text>
        <xsl:value-of select="$text:section-levels[$level]"/>
        <xsl:text>afterskip&lb;&lb;</xsl:text>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <xsl:function name="text:section-level" as="xs:integer" visibility="public">
    <xsl:param name="context" as="element(head)"/>
    <xsl:variable name="level" as="xs:integer">
      <xsl:choose>
        <xsl:when test="$context/parent::div">
          <xsl:sequence select="$context/ancestor::div => count()"/>
        </xsl:when>
        <xsl:when test="matches(name($context/parent::*), '^div')">
          <xsl:sequence
            select="name($context/parent::*) => replace('^div(\d+)', '$1') => xs:integer()"/>
        </xsl:when>
        <xsl:when test="$context/parent::lg">
          <xsl:sequence select="($context/ancestor::lg | $context/ancestor::div) => count()"/>
        </xsl:when>
        <xsl:when test="matches(name($context/parent::*), '^list')">
          <xsl:sequence
            select="($context/ancestor::*[matches(name(.), '^list')] | $context/ancestor::div) => count()"
          />
        </xsl:when>
        <xsl:otherwise>
          <!-- we are in <body> or so! TODO -->
          <xsl:sequence select="1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:sequence select="$level + $text:section-level-delta"/>
  </xsl:function>

  <xsl:template match="div | div1 | div2 | div3 | div4 | div5 | div6 | div7">
    <xsl:apply-templates mode="text:hook-ahead" select="."/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-start'"/>
    </xsl:call-template>
    <xsl:apply-templates/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-end'"/>
    </xsl:call-template>
    <xsl:apply-templates mode="text:hook-behind" select="."/>
  </xsl:template>

  <xsl:template match="p">
    <xsl:call-template name="edmac:par-start"/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-start'"/>
    </xsl:call-template>
    <xsl:apply-templates/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-end'"/>
    </xsl:call-template>
    <xsl:call-template name="edmac:par-end"/>
    <xsl:text>&lb;&lb;&lb;</xsl:text>
  </xsl:template>

  <xsl:template match="lg[not(lg)]">
    <xsl:apply-templates mode="text:hook-ahead" select="."/>
    <xsl:call-template name="edmac:stanza-start"/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-start'"/>
    </xsl:call-template>
    <xsl:apply-templates mode="text:hook-before" select="."/>
    <xsl:apply-templates/>
    <xsl:apply-templates mode="text:hook-after" select="."/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-end'"/>
    </xsl:call-template>
    <xsl:call-template name="edmac:stanza-end"/>
    <xsl:apply-templates mode="text:hook-behind" select="."/>
  </xsl:template>

  <!-- a single verse not in lg is output as a stanza -->
  <xsl:template match="l[not(ancestor::lg)]">
    <xsl:apply-templates mode="text:hook-ahead" select="."/>
    <xsl:call-template name="edmac:stanza-start"/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-start'"/>
    </xsl:call-template>
    <xsl:apply-templates mode="text:hook-before" select="."/>
    <xsl:variable name="latex" as="text()*">
      <xsl:call-template name="text:verse"/>
    </xsl:variable>
    <xsl:value-of select="edmac:normalize($latex)"/>
    <xsl:apply-templates mode="text:hook-after" select="."/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-end'"/>
    </xsl:call-template>
    <xsl:call-template name="edmac:stanza-end"/>
    <xsl:apply-templates mode="text:hook-behind" select="."/>
  </xsl:template>

  <xsl:template match="l[ancestor::lg]">
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-start'"/>
    </xsl:call-template>
    <xsl:call-template name="text:verse"/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-end'"/>
    </xsl:call-template>
    <xsl:call-template name="edmac:verse-end"/>
  </xsl:template>

  <!-- a hook for handling verse. The default just applies the templates in mode text:text -->
  <xsl:template name="text:verse" visibility="public">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- delete whitespace nodes between verses -->
  <xsl:template match="text()[normalize-space(.) eq '' and ancestor::lg and not(ancestor::l)]"/>

  <xsl:template match="caesura">
    <xsl:text>\caesura{}</xsl:text>
  </xsl:template>

  <xsl:template match="pb">
    <xsl:call-template name="edmac:edlabel"/>
    <xsl:text>\pb{</xsl:text>
    <xsl:value-of select="@n"/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="milestone">
    <xsl:call-template name="edmac:edlabel"/>
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

  <xsl:template match="lem[//variantEncoding/@method eq 'parallel-segmentation']">
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="context" select="parent::app"/>
      <xsl:with-param name="suffix" select="'-start'"/>
    </xsl:call-template>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="lem[//variantEncoding/@method ne 'parallel-segmentation']"/>

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
    <xsl:apply-templates mode="text:hook-before" select="."/>
    <xsl:text>[...]</xsl:text>
    <xsl:apply-templates mode="text:hook-after" select="."/>
    <xsl:call-template name="text:inline-footnotes"/>
    <xsl:call-template name="edmac:app-end"/>
  </xsl:template>

  <xsl:template match="supplied">
    <xsl:call-template name="edmac:app-start"/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-start'"/>
    </xsl:call-template>
    <xsl:apply-templates mode="text:hook-before" select="."/>
    <!--xsl:text>[</xsl:text-->
    <xsl:apply-templates/>
    <!--xsl:text>]</xsl:text-->
    <xsl:apply-templates mode="text:hook-after" select="."/>
    <xsl:call-template name="text:inline-footnotes"/>
    <xsl:call-template name="edmac:app-end"/>
  </xsl:template>

  <xsl:template match="unclear">
    <xsl:call-template name="edmac:app-start"/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-start'"/>
    </xsl:call-template>
    <xsl:apply-templates mode="text:hook-before" select="."/>
    <!--xsl:text>[? </xsl:text-->
    <xsl:apply-templates/>
    <!--xsl:text> ?]</xsl:text-->
    <xsl:apply-templates mode="text:hook-after" select="."/>
    <xsl:call-template name="text:inline-footnotes"/>
    <xsl:call-template name="edmac:app-end"/>
  </xsl:template>

  <xsl:template match="choice[child::sic and child::corr]">
    <xsl:call-template name="edmac:app-start"/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-start'"/>
    </xsl:call-template>
    <xsl:apply-templates mode="text:hook-before" select="."/>
    <xsl:apply-templates select="corr"/>
    <xsl:apply-templates mode="text:hook-after" select="."/>
    <xsl:call-template name="text:inline-footnotes"/>
    <xsl:call-template name="edmac:app-end"/>
  </xsl:template>

  <xsl:template match="sic[not(parent::choice)]">
    <xsl:call-template name="edmac:app-start"/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-start'"/>
    </xsl:call-template>
    <xsl:apply-templates mode="text:hook-before" select="."/>
    <xsl:apply-templates/>
    <xsl:apply-templates mode="text:hook-after" select="."/>
    <xsl:call-template name="text:inline-footnotes"/>
    <xsl:call-template name="edmac:app-end"/>
  </xsl:template>

  <xsl:template match="corr[not(parent::choice)]">
    <xsl:call-template name="edmac:app-start"/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-start'"/>
    </xsl:call-template>
    <xsl:apply-templates mode="text:hook-before" select="."/>
    <xsl:apply-templates/>
    <xsl:apply-templates mode="text:hook-after" select="."/>
    <xsl:call-template name="text:inline-footnotes"/>
    <xsl:call-template name="edmac:app-end"/>
  </xsl:template>

  <xsl:template match="span/text() | interp/text()"/>


  <!-- named entities make up indices. Its up to downstream packages to use them or to let the go. -->

  <xsl:template match="rs">
    <xsl:call-template name="text:index-entity">
      <xsl:with-param name="index" select="@type"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="persName">
    <xsl:call-template name="text:index-entity">
      <xsl:with-param name="index">person</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="placeName">
    <xsl:call-template name="text:index-entity">
      <xsl:with-param name="index">place</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="orgName">
    <xsl:call-template name="text:index-entity">
      <xsl:with-param name="index">org</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="eventName">
    <xsl:call-template name="text:index-entity">
      <xsl:with-param name="index">event</xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <!-- named template that generates entries to the indices.
    This also calls the hooks.
    The index parameter should be of the values of rs/@type, i.e., 'person', 'place', 'org', 'event', etc. -->
  <xsl:template name="text:index-entity" visibility="public">
    <xsl:context-item as="element()" use="required"/>
    <xsl:param name="index" as="xs:string" required="true"/>
    <!-- early hooks and start label -->
    <xsl:apply-templates mode="text:hook-ahead" select="."/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-start'"/>
    </xsl:call-template>
    <xsl:apply-templates mode="text:hook-before" select="."/>
    <!-- output index macro -->
    <xsl:for-each select="text:index-keys(., $index)">
      <xsl:text>\index[</xsl:text>
      <xsl:value-of select="$index"/>
      <xsl:text>]{</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>}</xsl:text>
    </xsl:for-each>
    <!-- current mode on children -->
    <xsl:apply-templates mode="#current"/>
    <!-- late hooks and ending label -->
    <xsl:apply-templates mode="text:hook-after" select="."/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-end'"/>
    </xsl:call-template>
    <xsl:apply-templates mode="text:hook-behind" select="."/>
  </xsl:template>

  <!-- likely to be replaced with a more sophisticated function that gets names for keys -->
  <xsl:function name="text:index-keys" as="xs:string*" visibility="public">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="index" as="xs:string"/>
    <xsl:variable name="keys" as="xs:string*">
      <xsl:choose>
        <xsl:when test="$context/@key">
          <xsl:value-of select="$context/@key"/>
        </xsl:when>
        <xsl:when test="$context/@ref">
          <xsl:value-of select="$context/@ref => replace('#', '')"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:sequence select="tokenize($keys)"/>
  </xsl:function>


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
  <xsl:template name="text:inline-footnotes" visibility="public">
    <xsl:context-item as="element()" use="required"/>
  </xsl:template>




  <!-- contributions to the latex header -->
  <xsl:template name="text:latex-header" visibility="public">
    <xsl:text>&lb;&lb;%% macro definitions from .../xsl/latex/libtext.xsl</xsl:text>
    <xsl:text>&lb;\newcommand*{\pb}[1]{[#1]}</xsl:text>
    <xsl:text>&lb;\newcommand*{\milestone}[2]{[#1]}</xsl:text>
    <xsl:text>&lb;\newcommand*{\caesura}{||}</xsl:text>
  </xsl:template>

  <xsl:template name="text:latex-header-index" visibility="public">
    <xsl:context-item as="item()" use="required"/>
    <xsl:text>&lb;\makeatletter%</xsl:text>
    <xsl:text>&lb;\@ifpackageloaded{imakeidx}{}{\usepackage{imakeidx}}%</xsl:text>
    <xsl:text>&lb;\makeatother%</xsl:text>
    <xsl:for-each select="(root(.)//rs/@type ! string(), $text:indices) => distinct-values()">
      <xsl:text>&lb;\makeindex[name=</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>,title={</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>}]</xsl:text>
    </xsl:for-each>
    <xsl:text>&lb;&lb;</xsl:text>
  </xsl:template>

  <!-- contribution to the header for workaround towards issue #36 -->
  <xsl:template name="text:latex-header-workaround36" visibility="public">
    <xsl:text>&lb;\makeatletter%</xsl:text>
    <xsl:text>&lb;\@ifpackageloaded{ifthen}{}{\usepackage{ifthen}}%</xsl:text>
    <xsl:text>&lb;\@ifpackageloaded{nowidow}{}{\usepackage{nowidow}}%</xsl:text>
    <xsl:text>&lb;% Note: skips around section commands must be outside \pstart...\pend!</xsl:text>
    <xsl:text>&lb;\newcommand*{\seedchapterbeforeskip}{\vspace{-3.5ex \@plus -1ex \@minus -.2ex}}</xsl:text>
    <xsl:text>&lb;\newcommand*{\seedchapterafterskip}{\vspace{2.3ex \@plus.2ex}}</xsl:text>
    <xsl:text>&lb;\newcommand*{\seedsectionbeforeskip}{\vspace{-3.25ex\@plus -1ex \@minus -.2ex}}</xsl:text>
    <xsl:text>&lb;\newcommand*{\seedsectionafterskip}{\vspace{1.5ex \@plus .2ex}}</xsl:text>
    <xsl:text>&lb;\newcommand*{\seedsubsectionbeforeskip}{\vspace{-3.25ex\@plus -1ex \@minus -.2ex}}</xsl:text>
    <xsl:text>&lb;\newcommand*{\seedsubsectionafterskip}{\vspace{1.5ex \@plus .2ex}}</xsl:text>
    <xsl:text>&lb;\newcommand*{\seedsubsubsectionbeforeskip}{\vspace{-3.25ex\@plus -1ex \@minus -.2ex}}</xsl:text>
    <xsl:text>&lb;\newcommand*{\seedsubsubsectionafterskip}{\vspace{1.5ex \@plus .2ex}}</xsl:text>
    <xsl:text>&lb;\newcommand*{\seedchapterfont}[1]{\LARGE #1}</xsl:text>
    <xsl:text>&lb;\newcommand*{\seedsectionfont}[1]{\Large #1}</xsl:text>
    <xsl:text>&lb;\newcommand*{\seedsubsectionfont}[1]{\large #1}</xsl:text>
    <xsl:text>&lb;\newcommand*{\seedsubsubsectionfont}[1]{\bfseries #1}</xsl:text>
    <xsl:text>&lb;%% redefining reledmac's sectioning commands to workaround issue #36</xsl:text>
    <xsl:text>&lb;\renewcommand{\eledchapter}[2][]{%</xsl:text>
    <xsl:text>&lb;  \seedchapterfont{#2}%</xsl:text>
    <xsl:text>&lb;  \ifthenelse{\equal{#1}{}}{%</xsl:text>
    <xsl:text>&lb;    \addcontentsline{toc}{chapter}{#2}}{%</xsl:text>
    <xsl:text>&lb;    \addcontentsline{toc}{chapter}{#1}}%</xsl:text>
    <xsl:text>&lb;}</xsl:text>
    <xsl:text>&lb;\renewcommand{\eledsection}[2][]{%</xsl:text>
    <xsl:text>&lb;  \seedsectionfont{#2}%</xsl:text>
    <xsl:text>&lb;  \ifthenelse{\equal{#1}{}}{%</xsl:text>
    <xsl:text>&lb;    \addcontentsline{toc}{section}{#2}}{%</xsl:text>
    <xsl:text>&lb;    \addcontentsline{toc}{section}{#1}}%</xsl:text>
    <xsl:text>&lb;}</xsl:text>
    <xsl:text>&lb;\renewcommand{\eledsubsection}[2][]{%</xsl:text>
    <xsl:text>&lb;  \seedsubsectionfont{#2}%</xsl:text>
    <xsl:text>&lb;  \ifthenelse{\equal{#1}{}}{%</xsl:text>
    <xsl:text>&lb;    \addcontentsline{toc}{subsection}{#2}}{%</xsl:text>
    <xsl:text>&lb;    \addcontentsline{toc}{subsection}{#1}}%</xsl:text>
    <xsl:text>&lb;}</xsl:text>
    <xsl:text>&lb;\renewcommand{\eledsubsubsection}[2][]{%</xsl:text>
    <xsl:text>&lb;  \seedsubsubsectionfont{#2}%</xsl:text>
    <xsl:text>&lb;  \ifthenelse{\equal{#1}{}}{%</xsl:text>
    <xsl:text>&lb;    \addcontentsline{toc}{subsubsection}{#2}}{%</xsl:text>
    <xsl:text>&lb;    \addcontentsline{toc}{subsubsection}{#1}}%</xsl:text>
    <xsl:text>&lb;}</xsl:text>
    <xsl:text>&lb;\makeatother</xsl:text>
  </xsl:template>

  <xsl:template name="text:latex-header-full-seedskips" visibility="public">
    <xsl:text>&lb;\renewcommand*{\seedchapterbeforeskip}{\bigskip}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\seedchapterafterskip}{}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\seedsectionbeforeskip}{\bigskip}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\seedsectionafterskip}{}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\seedsubsectionbeforeskip}{\bigskip}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\seedsubsectionafterskip}{}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\seedsubsubsectionbeforeskip}{\bigskip}</xsl:text>
    <xsl:text>&lb;\renewcommand*{\seedsubsubsectionafterskip}{}</xsl:text>
  </xsl:template>

</xsl:package>
