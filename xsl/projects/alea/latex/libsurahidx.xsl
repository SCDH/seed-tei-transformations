<!-- components for an index of the citations from Quran

-->
<!DOCTYPE package [
    <!ENTITY lb "&#xa;" >
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >]>
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/latex/libsurahidx.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:xd="https://www.oxygenxml.com/ns/doc/xsl" xmlns:surah="http://scdh.wwu.de/transform/surah#"
  xmlns:common="http://scdh.wwu.de/transform/common#"
  xmlns:index="http://scdh.wwu.de/transform/index#" xmlns:ref="http://scdh.wwu.de/transform/ref#"
  xmlns:i18n="http://scdh.wwu.de/transform/i18n#" exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

  <xsl:output method="text" indent="false"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libcommon.xsl"
    package-version="0.1.0"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libi18n.xsl"
    package-version="1.0.0">
    <xsl:accept component="function" names="i18n:babel-language#1" visibility="private"/>
  </xsl:use-package>

  <xsl:variable name="surah:bibl-scope-re" as="xs:string"
    select="'^(\d+)(:((\d+)((\s*-\s*\d+|\s*,\s*\d+)*)))?$'" visibility="final"/>


  <xsl:template name="surah:index" visibility="final">
    <xsl:context-item as="element()"/>
    <xsl:param name="cite-key" as="xs:string" select="'bibl:Quran'" required="false"/>
    <xsl:param name="quote-types" as="xs:string+" select="'verbatim-holy'" required="false"/>
    <xsl:variable name="bibl-scope" as="element(biblScope)*">
      <xsl:choose>
        <xsl:when
          test="self::quote[@type = $quote-types] and following::note[1]/bibl[@corresp eq $cite-key]/biblScope">
          <!-- as used by Andreas in Prosa/Sag -->
          <xsl:sequence select="following::note[1]/bibl[@corresp eq $cite-key]/biblScope"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>no biblScope found for citation from Quran in </xsl:text>
            <xsl:value-of select="path(.)"/>
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="$bibl-scope">
      <xsl:variable name="quote" as="xs:string?" select="surah:quote(.)"/>
      <!-- note: the surah titles are in the namespace 'quran' and have the 'surah-' prefix -->
      <xsl:text>\index[surah]{</xsl:text>
      <xsl:value-of select="surah:number(.) => common:left-fill('0', 3)"/>
      <xsl:text>@</xsl:text>
      <xsl:text>\GetTranslation{surah-</xsl:text>
      <xsl:value-of select="surah:number(.)"/>
      <xsl:text>}!</xsl:text>
      <xsl:value-of
        select="surah:verses(.)[1] => common:left-fill('0', 3) || $quote => tokenize() => count() => string() => common:left-fill('0', 2)"/>
      <xsl:text>@\surahind{\arabicornateoparen{}</xsl:text>
      <xsl:value-of select="$quote"/>
      <xsl:text>\arabicornatecparen{}}{</xsl:text>
      <xsl:value-of
        select="(. => normalize-space() => tokenize('\s+'))[position() gt 1] => string-join()"/>
      <xsl:text>}}</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:function name="surah:number" as="xs:string" visibility="final">
    <xsl:param name="bibl-scope" as="element(biblScope)"/>
    <xsl:sequence select="surah:scope-component($bibl-scope, 1)"/>
  </xsl:function>

  <xsl:function name="surah:verses" as="xs:string" visibility="final">
    <xsl:param name="bibl-scope" as="element(biblScope)"/>
    <xsl:sequence select="surah:scope-component($bibl-scope, 3)"/>
  </xsl:function>

  <xsl:function name="surah:scope-component" as="xs:string" visibility="final">
    <xsl:param name="bibl-scope" as="element(biblScope)"/>
    <xsl:param name="group" as="xs:integer"/>
    <xsl:choose>
      <xsl:when test="$bibl-scope/@from">
        <!-- taking the number from @from -->
        <xsl:analyze-string select="$bibl-scope/@from" regex="{$surah:bibl-scope-re}">
          <xsl:matching-substring>
            <xsl:sequence select="regex-group($group)"/>
          </xsl:matching-substring>
        </xsl:analyze-string>
      </xsl:when>
      <xsl:when test="matches($bibl-scope, $surah:bibl-scope-re)">
        <!-- looking in text nodes -->
        <xsl:analyze-string select="normalize-space($bibl-scope)" regex="{$surah:bibl-scope-re}">
          <xsl:matching-substring>
            <xsl:sequence select="regex-group($group)"/>
          </xsl:matching-substring>
        </xsl:analyze-string>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          <xsl:text>scope component </xsl:text>
          <xsl:value-of select="$group"/>
          <xsl:text> not found for </xsl:text>
          <xsl:value-of select="path($bibl-scope)"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="surah:quote" as="xs:string">
    <xsl:param name="bibl-scope" as="element(biblScope)"/>
    <xsl:variable name="from" as="element()"
      select="id(substring($bibl-scope/ancestor::note/@target, 2), root($bibl-scope))"/>
    <xsl:variable name="quote" as="element(quote)?"
      select="($bibl-scope/preceding::quote intersect $from/following::quote)[1]"/>
    <xsl:value-of
      select="$quote//text()[not(ancestor::app) and not(ancestor::note)] => string-join()"/>
  </xsl:function>


  <xsl:template name="surah:latex-header" visibility="public">
    <xsl:text>&lb;%% contributions to the latex header from .../libsurahidx.xsl</xsl:text>
    <xsl:text>&lb;\makeatletter%</xsl:text>
    <xsl:text>&lb;\@ifpackageloaded{tabto}{}{\usepackage{tabto}}%</xsl:text>
    <xsl:text>&lb;\@ifpackageloaded{filecontents}{}{\usepackage{filecontents}}%</xsl:text>
    <xsl:text>&lb;\makeatother%</xsl:text>
    <xsl:text>&lb;\begin{filecontents}{surah.ist}</xsl:text>
    <xsl:text>&lb;delim_0 ": "</xsl:text>
    <xsl:text>&lb;delim_1 ": "</xsl:text>
    <xsl:text>&lb;delim_2 "، "</xsl:text>
    <xsl:text>&lb;\end{filecontents}</xsl:text>
    <xsl:text>&lb;\newcommand{\surahind}[2]{#1\hspace{1em}#2}&lb;</xsl:text>
    <xsl:text>&lb;\makeindex[name=surah,options=-s surah.ist,title=\GetTranslation{index-title-surah},columns=1]</xsl:text>
    <xsl:call-template name="i18n:mk-package">
      <xsl:with-param name="namespace" select="'quran'"/>
      <xsl:with-param name="directory" select="resolve-uri('../html/locales/', static-base-uri())"/>
    </xsl:call-template>
    <xsl:text>&lb;\usepackage{i18n-quran}</xsl:text>
  </xsl:template>

  <xsl:template name="surah:print-index" visibility="public">
    <xsl:text>&lb;\indexprologue[\smallskip]{\hspace{1em}اسم السورة\tabto*{6cm}رقم الآية:\hspace{.5em}الصفحة}%</xsl:text>
    <xsl:text>&lb;\printindex[surah]</xsl:text>
    <xsl:text>&lb;\indexprologue{}% reset prologue for the next printed index&lb;</xsl:text>
  </xsl:template>

</xsl:package>
