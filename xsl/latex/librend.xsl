<!-- components for latex output shared in modes text:text, app:reading-text and note:editorial -->
<!DOCTYPE package [
    <!ENTITY lb "&#xa;" >
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >]>
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/librend.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:text="http://scdh.wwu.de/transform/text#"
  xmlns:app="http://scdh.wwu.de/transform/app#" xmlns:note="http://scdh.wwu.de/transform/note#"
  xmlns:edmac="http://scdh.wwu.de/transform/edmac#" exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

  <!-- names of indices (used by imakeidx) -->
  <xsl:param name="text:indices" as="xs:string*" required="false"
    select="'person', 'place', 'org', 'event'"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libreledmac.xsl"
    package-version="1.0.0"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/librend.xsl"
    package-version="1.0.0">
    <xsl:accept component="mode" names="*" visibility="public"/>

    <xsl:override>

      <!-- write PIs from latex target to the output -->
      <xsl:template mode="text:text app:reading-text note:editorial"
        match="processing-instruction('latex')">
        <xsl:value-of select="."/>
      </xsl:template>

      <!-- you may want to override the rule content, e.g., by \txarb{.} -->
      <xsl:template mode="text:text app:reading-text note:editorial" match="text()">
        <!-- some characters need to be escaped -->
        <!--xsl:value-of select=". => replace('\[', '\\lbrack{}') => replace('\]', '\\rbrack{}')"/-->
        <!--xsl:value-of select=". => replace('([\[])', '{$1}')"/-->
        <xsl:value-of select="."/>
      </xsl:template>

      <!-- shrink multiple whitespace space characters to a single space  -->
      <xsl:template mode="text:text app:reading-text note:editorial"
        match="text()[ancestor::p or ancestor::l or ancestor::head]">
        <xsl:value-of select=". => replace('\s+', ' ')"/>
      </xsl:template>

      <!-- add hooks everywhere -->
      <xsl:template mode="text:text app:reading-text note:editorial" match="*">
        <xsl:call-template name="text:hooks"/>
      </xsl:template>


      <!-- named entities make up indices. Its up to downstream packages to use them or to let the go. -->

      <xsl:template mode="text:text app:reading-text note:editorial" match="rs">
        <xsl:call-template name="text:index-entity">
          <xsl:with-param name="index" select="@type"/>
        </xsl:call-template>
      </xsl:template>

      <xsl:template mode="text:text app:reading-text note:editorial" match="persName">
        <xsl:call-template name="text:index-entity">
          <xsl:with-param name="index">person</xsl:with-param>
        </xsl:call-template>
      </xsl:template>

      <xsl:template mode="text:text app:reading-text note:editorial" match="placeName">
        <xsl:call-template name="text:index-entity">
          <xsl:with-param name="index">place</xsl:with-param>
        </xsl:call-template>
      </xsl:template>

      <xsl:template mode="text:text app:reading-text note:editorial" match="orgName">
        <xsl:call-template name="text:index-entity">
          <xsl:with-param name="index">org</xsl:with-param>
        </xsl:call-template>
      </xsl:template>

      <xsl:template mode="text:text app:reading-text note:editorial" match="eventName">
        <xsl:call-template name="text:index-entity">
          <xsl:with-param name="index">event</xsl:with-param>
        </xsl:call-template>
      </xsl:template>

    </xsl:override>
  </xsl:use-package>

  <!-- hooks -->
  <xsl:mode name="text:hook-ahead" on-no-match="deep-skip" visibility="public"/>
  <xsl:mode name="text:hook-before" on-no-match="deep-skip" visibility="public"/>
  <xsl:mode name="text:hook-after" on-no-match="deep-skip" visibility="public"/>
  <xsl:mode name="text:hook-behind" on-no-match="deep-skip" visibility="public"/>

  <xsl:template name="text:hooks" visibility="public">
    <xsl:context-item as="element()" use="required"/>
    <xsl:apply-templates mode="text:hook-ahead" select="."/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-start'"/>
    </xsl:call-template>
    <xsl:apply-templates mode="text:hook-before" select="."/>
    <!-- #current mode on children.
      This works albeit we are in a named template!
      Its guaranteed by the specs.
      Quote From the XSLT 3.0 TR:
      "Definition: At any point in the processing of a stylesheet,
      there is a current mode." -->
    <xsl:apply-templates mode="#current"/>
    <xsl:apply-templates mode="text:hook-after" select="."/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-end'"/>
    </xsl:call-template>
    <xsl:apply-templates mode="text:hook-behind" select="."/>
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


  <!-- contributions to the latex prologue -->
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

</xsl:package>
