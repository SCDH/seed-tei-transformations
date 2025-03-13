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
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:app="http://scdh.wwu.de/transform/app#"
  xmlns:note="http://scdh.wwu.de/transform/note#" xmlns:seed="http://scdh.wwu.de/transform/seed#"
  xmlns:text="http://scdh.wwu.de/transform/text#" xmlns:verse="http://scdh.wwu.de/transform/verse#"
  xmlns:edmac="http://scdh.wwu.de/transform/edmac#" xmlns:rend="http://scdh.wwu.de/transform/rend#"
  xmlns:common="http://scdh.wwu.de/transform/common#"
  xmlns:preamble="http://scdh.wwu.de/transform/preamble#"
  xmlns:meta="http://scdh.wwu.de/transform/meta#" xmlns:wit="http://scdh.wwu.de/transform/wit#"
  xmlns:alea="http://scdh.wwu.de/transform/alea#" xmlns:index="http://scdh.wwu.de/transform/index#"
  xmlns:surah="http://scdh.wwu.de/transform/surah#" xmlns:poem="http://scdh.wwu.de/transform/poem#"
  xmlns:ref="http://scdh.wwu.de/transform/ref#"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0">

  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:param name="language" as="xs:string" select="/TEI/@xml:lang"/>

  <!-- optional: the URI of the projects central witness catalogue -->
  <xsl:param name="wit-catalog" as="xs:string" select="string()"/>

  <!-- types of div in which verses are embedded and thus are printed without extra vertical space -->
  <xsl:param name="embedded-verse-contexts" as="xs:string*" select="('letter', 'bio', 'intro')"/>

  <!-- whether or not to print out the indexes -->
  <xsl:param name="print-indexes" as="xs:boolean" select="true()"/>

  <!-- pagestyle of first content page (after \maketitle if used) -->
  <xsl:param name="first-page-style" as="xs:string" select="'empty'"/>

  <xsl:variable name="current" as="node()*" select="root()"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/latex/preamble.xsl"
    package-version="1.0.0">
    <xsl:accept component="template" names="preamble:header" visibility="final"/>
  </xsl:use-package>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libbetween.xsl"
    package-version="1.0.0"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libref.xsl"
    package-version="1.0.0"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libcommon.xsl"
    package-version="0.1.0">
    <xsl:accept component="function" names="common:left-fill#3" visibility="final"/>
  </xsl:use-package>

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
        <xsl:param name="context" as="node()"/>
        <xsl:call-template name="wit:sigla">
          <xsl:with-param name="wit" select="$context/@wit"/>
        </xsl:call-template>
      </xsl:template>

      <!-- only print sigla, if there are at least two witnesses -->
      <xsl:function name="app:prints-sigla" as="xs:boolean">
        <xsl:param name="context" as="node()"/>
        <xsl:sequence
          select="root($context)/TEI/teiHeader/fileDesc/sourceDesc//listWit/witness => count() gt 1"
        />
      </xsl:function>

      <!-- correct parens and brackets -->
      <xsl:template mode="app:reading-text" match="text()">
        <xsl:call-template name="alea:fix-text"/>
      </xsl:template>

      <!-- quick and dirty hack to get references to manuscripts, TODO: real multilanguage support -->
      <xsl:template mode="app:reading-text" match="seg[@xml:lang]">
        <xsl:text>\foreignlanguage{</xsl:text>
        <xsl:value-of select="i18n:babel-language(@xml:lang)"/>
        <xsl:text>}{</xsl:text>
        <xsl:apply-templates mode="#current"/>
        <xsl:text>}</xsl:text>
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
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/latex/libsurahidx.xsl"
    package-version="1.0.0">
    <xsl:accept component="template" names="surah:*" visibility="final"/>
  </xsl:use-package>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/latex/libpoemidx.xsl"
    package-version="1.0.0">
    <xsl:accept component="template" names="poem:*" visibility="final"/>
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

      <xsl:template mode="rend:hook-behind" match="p[@ana eq 'tag:inquit']">
        <xsl:text>\penalty 6000</xsl:text>
      </xsl:template>

      <xsl:template mode="rend:hook-ahead" match="*[@met]">
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

      <xsl:template mode="rend:hook-before" match="*[@met]">
        <xsl:text>%&lb;</xsl:text>
        <xsl:call-template name="poem:index"/>
        <xsl:text>%&lb;</xsl:text>
      </xsl:template>

      <xsl:template mode="rend:hook-behind" match="*[@met]">
        <xsl:variable name="is-embedded" as="xs:boolean"
          select="some $t in tokenize(ancestor::div[1]/@type) satisfies  $embedded-verse-contexts = $t"/>
        <xsl:if test="not($is-embedded)">
          <xsl:text>&lb;\poemafterskip&lb;</xsl:text>
        </xsl:if>
      </xsl:template>

      <xsl:template mode="rend:hook-before" match="quote[@type eq 'verbatim-holy']">
        <xsl:message use-when="system-property('debug') eq 'true'">
          <xsl:text>opening parenthesis for verbatim citation of holy text</xsl:text>
        </xsl:message>
        <xsl:call-template name="surah:index"/>
        <xsl:text>\arabicornateoparen{}</xsl:text>
      </xsl:template>

      <xsl:template mode="rend:hook-after" match="quote[@type eq 'verbatim-holy']">
        <xsl:message use-when="system-property('debug') eq 'true'">
          <xsl:text>closing parenthesis for verbatim citation of holy text</xsl:text>
        </xsl:message>
        <xsl:text>\arabicornatecparen{}</xsl:text>
      </xsl:template>

      <xsl:template mode="rend:hook-before" match="quote[@type eq 'verbatim']">
        <xsl:message use-when="system-property('debug') eq 'true'">
          <xsl:text>opening parenthesis for verbatim citation of holy text</xsl:text>
        </xsl:message>
        <xsl:text>\arabicoparen{}</xsl:text>
      </xsl:template>

      <xsl:template mode="rend:hook-after" match="quote[@type eq 'verbatim']">
        <xsl:message use-when="system-property('debug') eq 'true'">
          <xsl:text>closing parenthesis for verbatim citation of holy text</xsl:text>
        </xsl:message>
        <xsl:text>\arabiccparen{}</xsl:text>
      </xsl:template>

      <xsl:template mode="rend:hook-before" match="supplied">
        <xsl:text>{\normalfont\arabicobracket{}}</xsl:text>
      </xsl:template>

      <xsl:template mode="rend:hook-after" match="supplied">
        <xsl:text>{\normalfont\arabiccbracket{}}</xsl:text>
      </xsl:template>

      <xsl:function name="rend:index-entries-from-ref-attribute" as="xs:string*">
        <xsl:param name="ref" as="attribute(ref)"/>
        <xsl:param name="index" as="xs:string"/>
        <xsl:for-each select="ref:references-from-attribute($ref) ! ref:dereference(., $ref)">
          <xsl:variable name="entry" as="element()" select="."/>
          <!-- sort order from register file -->
          <xsl:variable name="sortkey" as="xs:integer"
            select="$entry/preceding::*[@xml:id] => count()"/>
          <xsl:variable name="entry-language-maps" as="map(xs:string, xs:string*)*">
            <xsl:apply-templates select="$entry" mode="index:languages"/>
          </xsl:variable>
          <xsl:variable name="arabic-entry" as="xs:string*"
            select="map:merge($entry-language-maps) => map:get('ar')"/>
          <!-- we have to return a single string per entry -->
          <xsl:value-of
            select="string-join((common:left-fill($sortkey => string(), '0', 4), '@', string-join($arabic-entry)))"
          />
        </xsl:for-each>
      </xsl:function>

    </xsl:override>
  </xsl:use-package>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libindex.xsl"
    package-version="1.0.0">
    <xsl:accept component="template" names="index:translation-package-filecontents"
      visibility="final"/>
    <xsl:accept component="mode" names="index:languages" visibility="public"/>
  </xsl:use-package>

  <!-- we fix  -->
  <xsl:template name="alea:fix-text">
    <xsl:context-item as="text()" use="required"/>
    <xsl:choose>
      <xsl:when test="i18n:language(.) eq 'ar'">
        <!-- fix inverted parenthesis -->
        <xsl:analyze-string select="." regex="[\[\]\(\)]">
          <xsl:matching-substring>
            <xsl:choose>
              <xsl:when test=". eq '('">
                <xsl:text>\arabicoparen{}</xsl:text>
              </xsl:when>
              <xsl:when test=". eq ')'">
                <xsl:text>\arabiccparen{}</xsl:text>
              </xsl:when>
              <xsl:when test=". eq '['">
                <xsl:text>\arabicobracket{}</xsl:text>
              </xsl:when>
              <xsl:when test=". eq ']'">
                <xsl:text>\arabiccbracket{}</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:message terminate="yes"> Bad parenthesis match </xsl:message>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:matching-substring>
          <xsl:non-matching-substring>
            <xsl:value-of select="."/>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


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
      select="$text => replace('\(', '\\arabicoparen{}') => replace('\)', '\\arabiccparen{}') => replace('\[', '\\arabicobracket{}') => replace('\]', '\\arabiccbracket{}') "
    />
  </xsl:function>


  <xsl:mode on-no-match="shallow-skip"/>

  <xsl:template match="/ | TEI">
    <xsl:call-template name="preamble:header"/>

    <xsl:text>&lb;&lb;\begin{document}&lb;</xsl:text>

    <!--xsl:text>&lb;\pagenumbering{arabicnum}</xsl:text-->

    <xsl:call-template name="latex-front"/>
    <xsl:text>&lb;&lb;\selectlanguage{</xsl:text>
    <xsl:value-of select="i18n:language(/TEI/@xml:lang) => i18n:babel-language()"/>
    <xsl:text>}</xsl:text>

    <xsl:text>&lb;&lb;\thispagestyle{</xsl:text>
    <xsl:value-of select="$first-page-style"/>
    <xsl:text>}</xsl:text>

    <xsl:text>&lb;&lb;%% main content</xsl:text>
    <xsl:apply-templates mode="text:text" select="/TEI/text/body"/>
    <xsl:text>&lb;</xsl:text>
    <xsl:call-template name="latex-back"/>
    <xsl:text>&lb;</xsl:text>

    <xsl:if test="$print-indexes">
      <xsl:text>&lb;\cleardoublepage</xsl:text>
      <xsl:text>&lb;\addtocontents{toc}{\protect\setcounter{tocdepth}{1}}</xsl:text>
      <xsl:text>&lb;\addcontentsline{toc}{chapter}{الفهارس}</xsl:text>
      <xsl:call-template name="surah:print-index"/>
      <xsl:call-template name="poem:print-index"/>
      <xsl:call-template name="rend:print-indices"/>
    </xsl:if>

    <xsl:text>&lb;</xsl:text>
    <xsl:text>&lb;\end{document}&lb;</xsl:text>
    <xsl:call-template name="preamble:footer"/>
  </xsl:template>


  <xsl:template name="latex-front" visibility="public">
    <xsl:text>&lb;%%\maketitle</xsl:text>
  </xsl:template>

  <xsl:template name="latex-back" visibility="public"/>

</xsl:package>
