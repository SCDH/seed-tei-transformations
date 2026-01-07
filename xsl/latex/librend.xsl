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
  xmlns:rend="http://scdh.wwu.de/transform/rend#" xmlns:text="http://scdh.wwu.de/transform/text#"
  xmlns:app="http://scdh.wwu.de/transform/app#" xmlns:note="http://scdh.wwu.de/transform/note#"
  xmlns:edmac="http://scdh.wwu.de/transform/edmac#" exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

  <!-- names of indices (used by imakeidx), separated by comma -->
  <xsl:param name="rend:indices-csv" as="xs:string" required="false"
    select="'person,place,org,event'"/>

  <!-- names of indices (used by imakeidx) -->
  <xsl:param name="rend:indices" as="xs:string*" required="false"
    select="tokenize($rend:indices-csv, ',')"/>

  <!-- style file for indexes, passed in as ',options=-s myindex.ist' -->
  <xsl:param name="rend:index-styles" as="xs:string?" select="()" required="false"/>

  <!-- options to \makeindex -->
  <xsl:param name="rend:index-options" as="xs:string*" select="tokenize($rend:index-options-csv)"/>

  <!-- options to \makeindex, comma separated values -->
  <xsl:param name="rend:index-options-csv" as="xs:string" select="''"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libreledmac.xsl"
    package-version="1.0.0"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/librend-base.xsl"
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
        <xsl:call-template name="rend:hooks"/>
      </xsl:template>


      <!-- named entities make up indices. Its up to downstream packages to use them or to let the go. -->

      <xsl:template mode="text:text app:reading-text note:editorial" match="rs">
        <xsl:call-template name="rend:index-entity">
          <xsl:with-param name="index" select="@type"/>
        </xsl:call-template>
      </xsl:template>

      <xsl:template mode="text:text app:reading-text note:editorial" match="persName">
        <xsl:call-template name="rend:index-entity">
          <xsl:with-param name="index">person</xsl:with-param>
        </xsl:call-template>
      </xsl:template>

      <xsl:template mode="text:text app:reading-text note:editorial" match="placeName">
        <xsl:call-template name="rend:index-entity">
          <xsl:with-param name="index">place</xsl:with-param>
        </xsl:call-template>
      </xsl:template>

      <xsl:template mode="text:text app:reading-text note:editorial" match="orgName">
        <xsl:call-template name="rend:index-entity">
          <xsl:with-param name="index">org</xsl:with-param>
        </xsl:call-template>
      </xsl:template>

      <xsl:template mode="text:text app:reading-text note:editorial" match="eventName">
        <xsl:call-template name="rend:index-entity">
          <xsl:with-param name="index">event</xsl:with-param>
        </xsl:call-template>
      </xsl:template>

      <!-- just a dumb implementation that produces no output -->
      <xsl:template name="text:class-attribute" visibility="public">
        <xsl:param name="context" as="element()" select="." required="false"/>
        <xsl:param name="additional" as="xs:string*" select="()" required="false"/>
      </xsl:template>

      <!-- just a dumb implementation that produces no output -->
      <xsl:template name="text:class-attribute-opt" visibility="public">
        <xsl:param name="context" as="element()" select="." required="false"/>
        <xsl:param name="additional" as="xs:string*" select="()" required="false"/>
      </xsl:template>

    </xsl:override>
  </xsl:use-package>

  <!-- hooks -->
  <xsl:mode name="rend:hook-ahead" on-no-match="deep-skip" visibility="public"/>
  <xsl:mode name="rend:hook-before" on-no-match="deep-skip" visibility="public"/>
  <xsl:mode name="rend:hook-after" on-no-match="deep-skip" visibility="public"/>
  <xsl:mode name="rend:hook-behind" on-no-match="deep-skip" visibility="public"/>

  <xsl:template name="rend:hooks" visibility="public">
    <xsl:context-item as="element()" use="required"/>
    <xsl:apply-templates mode="rend:hook-ahead" select="."/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-start'"/>
    </xsl:call-template>
    <xsl:apply-templates mode="rend:hook-before" select="."/>
    <!-- #current mode on children.
      This works albeit we are in a named template!
      Its guaranteed by the specs. Quote From the XSLT 3.0 TR:
      "Definition: At any point in the processing of a stylesheet,
      there is a current mode." -->
    <xsl:apply-templates mode="#current"/>
    <xsl:apply-templates mode="rend:hook-after" select="."/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-end'"/>
    </xsl:call-template>
    <xsl:apply-templates mode="rend:hook-behind" select="."/>
  </xsl:template>


  <!-- named template that generates entries to the indices.
    This also calls the hooks.
    The index parameter should be of the values of rs/@type, i.e., 'person', 'place', 'org', 'event', etc. -->
  <xsl:template name="rend:index-entity" visibility="public">
    <xsl:context-item as="element()" use="required"/>
    <xsl:param name="index" as="xs:string" required="true"/>
    <!-- early hooks and start label -->
    <xsl:apply-templates mode="rend:hook-ahead" select="."/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-start'"/>
    </xsl:call-template>
    <xsl:apply-templates mode="rend:hook-before" select="."/>
    <!-- output index macro -->
    <xsl:for-each select="rend:index-keys(., $index)">
      <xsl:text>\index[</xsl:text>
      <xsl:value-of select="$index"/>
      <xsl:text>]{</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>}</xsl:text>
    </xsl:for-each>
    <!-- current mode on children -->
    <xsl:apply-templates mode="#current"/>
    <!-- late hooks and ending label -->
    <xsl:apply-templates mode="rend:hook-after" select="."/>
    <xsl:call-template name="edmac:edlabel">
      <xsl:with-param name="suffix" select="'-end'"/>
    </xsl:call-template>
    <xsl:apply-templates mode="rend:hook-behind" select="."/>
  </xsl:template>

  <!-- likely to be replaced with a more sophisticated function that gets names for keys -->
  <xsl:function name="rend:index-keys" as="xs:string*" visibility="final">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="index" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$context/@key">
        <xsl:value-of select="rend:index-keys-from-key-attribute($context/@key, $index)"/>
      </xsl:when>
      <xsl:when test="$context/@ref">
        <!-- we remove # because it is reserved in tex -->
        <xsl:value-of select="rend:index-entries-from-ref-attribute($context/@ref, $index)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          <xsl:text>entity without canonical attribute @ref or @key: </xsl:text>
          <xsl:value-of select="path($context)"/>
        </xsl:message>
        <xsl:text>UNKNOWN</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- you may want to override this if you do not like the \GetTranslation{...} mechanism -->
  <xsl:function name="rend:index-entries-from-ref-attribute" as="xs:string*" visibility="public">
    <xsl:param name="ref" as="attribute(ref)"/>
    <xsl:param name="index" as="xs:string"/>
    <xsl:for-each select="($ref => tokenize()) ! replace(., '^#', '')">
      <!-- we have to return a single string per reference! -->
      <xsl:value-of select="'\GetTranslation{' || normalize-space(.) || '}'"/>
    </xsl:for-each>
  </xsl:function>

  <!-- You will probably need to override this in downstream packages.
    Since @key's "form will depend entirely on practice within a given project",
    there is no generic implementation of this function.
    See https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-att.canonical.html
  -->
  <xsl:function name="rend:index-keys-from-key-attribute" as="xs:string*" visibility="public">
    <xsl:param name="key" as="attribute(key)"/>
    <xsl:param name="index" as="xs:string"/>
    <xsl:for-each select="tokenize($key)">
      <xsl:value-of select="'\GetTranslation{' || . || '}'"/>
    </xsl:for-each>
  </xsl:function>

  <!-- generate options for \makeindex based on $rend:index-options -->
  <xsl:template name="rend:index-options" visibility="final">
    <xsl:for-each select="$rend:index-options">
      <xsl:if test="position() gt 1 or $rend:index-styles">
        <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:value-of select="."/>
    </xsl:for-each>
  </xsl:template>

  <!-- contributions to the latex prologue -->
  <xsl:template name="rend:latex-header-index" visibility="public">
    <xsl:context-item as="item()" use="required"/>
    <xsl:text>&lb;\makeatletter%</xsl:text>
    <xsl:text>&lb;\@ifpackageloaded{imakeidx}{}{\usepackage{imakeidx}}%</xsl:text>
    <xsl:text>&lb;\makeatother%</xsl:text>
    <xsl:for-each select="(root(.)//rs/@type ! string(), $rend:indices) => distinct-values()">
      <xsl:text>&lb;\makeindex[name=</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>,title={\GetTranslation{index-title-</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>}}</xsl:text>
      <xsl:if test="$rend:index-styles">
        <xsl:text>,options=-s </xsl:text>
        <xsl:value-of select="$rend:index-styles"/>
      </xsl:if>
      <xsl:call-template name="rend:index-options"/>
      <xsl:text>]</xsl:text>
    </xsl:for-each>
    <xsl:text>&lb;&lb;</xsl:text>
  </xsl:template>

  <!-- template for printing all indices -->
  <xsl:template name="rend:print-indices" visibility="public">
    <xsl:text>&lb;&lb;%% from librend</xsl:text>
    <xsl:for-each select="(root(.)//rs/@type ! string(), $rend:indices) => distinct-values()">
      <xsl:text>&lb;\printindex[</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>]</xsl:text>
    </xsl:for-each>
  </xsl:template>

</xsl:package>
