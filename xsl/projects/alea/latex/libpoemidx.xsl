<!-- components for an index of poems, rhymes and meters


-->
<!DOCTYPE package [
    <!ENTITY lb "&#xa;" >
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >]>
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/latex/libpoemidx.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:xd="https://www.oxygenxml.com/ns/doc/xsl" xmlns:poem="http://scdh.wwu.de/transform/poem#"
  xmlns:common="http://scdh.wwu.de/transform/common#"
  xmlns:index="http://scdh.wwu.de/transform/index#" xmlns:ref="http://scdh.wwu.de/transform/ref#"
  xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:seed="http://scdh.wwu.de/transform/seed#"
  exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0"
  default-mode="poem:translations">
  <xsl:output method="text" indent="false"/>


  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libi18n.xsl"
    package-version="1.0.0">
    <xsl:accept component="function" names="i18n:babel-language#1" visibility="private"/>
  </xsl:use-package>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libentry2.xsl"
    package-version="1.0.0">
    <xsl:accept component="mode" names="seed:lemma-text-nodes" visibility="private"/>
  </xsl:use-package>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libcommon.xsl"
    package-version="0.1.0"/>


  <xsl:template name="poem:index" visibility="final">
    <xsl:context-item as="element()"/>
    <xsl:variable name="poem" as="map(xs:string, item()*)">
      <xsl:choose>
        <xsl:when test="self::lg[@met]">
          <xsl:map>
            <xsl:map-entry key="'verse'" select="descendant::l[1]"/>
            <xsl:map-entry key="'met'" select="@met"/>
            <xsl:map-entry key="'count'" select="count(descendant-or-self::lg/l)"/>
          </xsl:map>
        </xsl:when>
        <xsl:when test="self::l">
          <xsl:map>
            <xsl:map-entry key="'verse'" select="self::l[1]"/>
            <xsl:map-entry key="'met'" select="@met"/>
            <xsl:map-entry key="'count'" select="1"/>
          </xsl:map>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>no information found about poem or verse in </xsl:text>
            <xsl:value-of select="path(.)"/>
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- note: the surah titles are in the namespace 'quran' and have the 'surah-' prefix -->
    <xsl:text>\index[poem]{</xsl:text>
    <xsl:if test="map:get($poem, 'verse') => poem:letter() eq ''">
      <xsl:message terminate="yes"> NO rhyme letter </xsl:message>
    </xsl:if>
    <xsl:value-of select="map:get($poem, 'verse') => poem:letter() => string-to-codepoints()"/>
    <xsl:text>@</xsl:text>
    <xsl:value-of select="map:get($poem, 'verse') => poem:letter()"/>
    <xsl:text>!</xsl:text>
    <xsl:value-of select="poem:sortkey(.)"/>
    <xsl:text>@\poemind{</xsl:text>
    <xsl:value-of select="map:get($poem, 'verse') => poem:rhyme()"/>
    <xsl:text>}{\GetTranslation{meter-</xsl:text>
    <xsl:value-of select="map:get($poem, 'met') => poem:met() => poem:normalize-meter-symbol()"/>
    <xsl:text>}}{</xsl:text>
    <xsl:value-of select="map:get($poem, 'count')"/>
    <xsl:text>}}</xsl:text>
  </xsl:template>

  <xsl:function name="poem:normalize-meter-symbol" as="xs:string">
    <xsl:param name="in" as="xs:string"/>
    <xsl:sequence select="replace($in, '\s+', '')"/>
  </xsl:function>

  <xsl:function name="poem:met" as="xs:string">
    <xsl:param name="met" as="attribute(met)"/>
    <xsl:value-of select="replace($met, '^#', '')"/>
  </xsl:function>

  <xsl:function name="poem:rhyme" as="xs:string">
    <xsl:param name="verse" as="element(l)"/>
    <xsl:variable name="text" as="text()*">
      <xsl:apply-templates mode="seed:lemma-text-nodes" select="$verse"/>
    </xsl:variable>
    <xsl:sequence select="(string-join(($text)) => tokenize())[last()]"/>
  </xsl:function>

  <xsl:function name="poem:letter" as="xs:string">
    <xsl:param name="verse" as="element(l)"/>
    <xsl:choose>
      <xsl:when test="$verse/@rhyme">
        <xsl:value-of select="$verse/@rhyme"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- spacing letter with optional diacritics -->
        <xsl:value-of
          select="poem:rhyme($verse) => normalize-space() => replace('.*(\P{M}\p{M}*)$', '$1')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="poem:sortkey" as="xs:string" visibility="public">
    <xsl:param name="context" as="element()"/>
    <xsl:sequence select="count($context/preceding::l) => string() => common:left-fill('0', 4)"/>
  </xsl:function>


  <!-- an entry point which writes the translations as a package into a tex file -->
  <xsl:template name="poem:translation-package-filecontents" visibility="final">
    <xsl:context-item as="node()" use="required"/>
    <xsl:param name="package-name" as="xs:string" select="'i18n-poem'" required="false"/>
    <xsl:param name="use" as="xs:boolean" select="true()" required="false"/>
    <xsl:text>&lb;%% this needs \usepackage{filecontents} to work!</xsl:text>
    <xsl:text>&lb;\begin{filecontents}{</xsl:text>
    <xsl:value-of select="$package-name"/>
    <xsl:text>.sty}</xsl:text>
    <xsl:call-template name="poem:translation-package"/>
    <xsl:text>&lb;\end{filecontents}</xsl:text>
    <xsl:if test="$use">
      <xsl:text>&lb;\usepackage{</xsl:text>
      <xsl:value-of select="$package-name"/>
      <xsl:text>}&lb;</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- an entry point that makes a translation package -->
  <xsl:template name="poem:translation-package" visibility="final">
    <xsl:context-item as="node()" use="required"/>
    <xsl:param name="package-name" as="xs:string" select="'i18n-poem'" required="false"/>
    <xsl:text>&lb;\ProvidesPackage{</xsl:text>
    <xsl:value-of select="$package-name"/>
    <xsl:text>}</xsl:text>
    <xsl:text>&lb;\RequirePackage{translations}</xsl:text>
    <xsl:call-template name="poem:translations"/>
  </xsl:template>

  <xsl:template name="poem:translations" visibility="final">
    <xsl:context-item as="node()" use="required"/>
    <xsl:apply-templates mode="poem:translations" select="."/>
  </xsl:template>


  <xsl:mode name="poem:translations" on-no-match="shallow-skip"/>

  <xsl:template mode="poem:translations" match="metSym">
    <xsl:variable name="meter" select="."/>
    <xsl:for-each select="note/term">
      <xsl:text>&lb;\DeclareTranslation{</xsl:text>
      <xsl:value-of select="i18n:babel-language((ancestor-or-self::*/@xml:lang)[last()])"/>
      <xsl:text>}{meter-</xsl:text>
      <xsl:value-of select="$meter/@value => poem:normalize-meter-symbol()"/>
      <xsl:text>}{</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>}</xsl:text>
    </xsl:for-each>
  </xsl:template>



  <xsl:template name="poem:latex-header" visibility="public">
    <xsl:text>&lb;%% contributions to the latex header from .../libpoemidx.xsl</xsl:text>
    <xsl:text>&lb;\makeatletter%</xsl:text>
    <xsl:text>&lb;\@ifpackageloaded{tabto}{}{\usepackage{tabto}}%</xsl:text>
    <xsl:text>&lb;\@ifpackageloaded{filecontents}{}{\usepackage{filecontents}}%</xsl:text>
    <xsl:text>&lb;\makeatother%</xsl:text>
    <xsl:text>&lb;\begin{filecontents}{poem.ist}</xsl:text>
    <xsl:text>&lb;delim_0 ": "</xsl:text>
    <xsl:text>&lb;delim_1 ": "</xsl:text>
    <xsl:text>&lb;delim_2 "، "</xsl:text>
    <xsl:text>&lb;\end{filecontents}</xsl:text>
    <xsl:text>&lb;\makeindex[name=poem,options=-s poem.ist,title=\GetTranslation{index-title-poem},columns=1]</xsl:text>
    <xsl:text>&lb;\newcommand{\poemind}[3]{#1\tabto*{3cm}#2\tabto*{6cm}#3}&lb;</xsl:text>
    <xsl:call-template name="poem:translation-package-filecontents"/>
  </xsl:template>

  <xsl:template name="poem:print-index" visibility="public">
    <xsl:text>&lb;\indexprologue[\smallskip]{\hspace{1em}القافية\tabto*{3cm}البحر\tabto*{6cm}عدد الأبيات:\hspace{.5em}الصفحة}%</xsl:text>
    <xsl:text>&lb;\printindex[poem]</xsl:text>
    <xsl:text>&lb;\indexprologue{}% reset prologue for the next printed index&lb;</xsl:text>
  </xsl:template>

</xsl:package>
