<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/common/diwan.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:diwan="http://scdh.wwu.de/transform/diwan#"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="3.0">

  <xsl:variable name="diwan:code-re" as="xs:string" select="'^([A-Z]*)([a-z]+)([0-9]+)([a-z]*)$'"/>

  <!-- Maps the short recension code used in a poem's code to the longer recension ID used in the witness catalogue. -->
  <xsl:variable name="diwan:recension-short-to-long" as="map(xs:string, xs:string)"
    visibility="final">
    <xsl:map>
      <xsl:map-entry key="'A'" select="'Asl'"/>
      <xsl:map-entry key="'P'" select="'Pr'"/>
      <xsl:map-entry key="'BA'" select="'BA'"/>
      <xsl:map-entry key="'BB'" select="'BB'"/>
      <xsl:map-entry key="'IH'" select="'IH'"/>
      <xsl:map-entry key="'IHZ'" select="'IHZ'"/>
      <xsl:map-entry key="''" select="''"/>
    </xsl:map>
  </xsl:variable>

  <xsl:function name="diwan:parse-code" as="map(xs:string, xs:string)?" visibility="final">
    <xsl:param name="code" as="xs:string"/>
    <xsl:analyze-string select="$code" regex="{$diwan:code-re}">
      <xsl:matching-substring>
        <xsl:map>
          <xsl:map-entry key="'rhyme'" select="regex-group(2)"/>
          <xsl:map-entry key="'number'" select="regex-group(3)"/>
          <xsl:map-entry key="'secondary'" select="regex-group(4)"/>
          <xsl:if test="regex-group(1) ne ''">
            <xsl:map-entry key="'recension'"
              select="map:get($diwan:recension-short-to-long, regex-group(1))"/>
          </xsl:if>
        </xsl:map>
      </xsl:matching-substring>
    </xsl:analyze-string>
  </xsl:function>

  <xsl:function name="diwan:recensions" as="xs:string+" visibility="final">
    <xsl:param name="tei" as="document-node(element(TEI))"/>
    <xsl:choose>
      <xsl:when test="$tei/TEI/teiHeader//sourceDesc/listWit/listWit/@xml:id">
        <xsl:sequence select="$tei/TEI/teiHeader//sourceDesc/listWit/listWit/@xml:id"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$tei/TEI/@xml:id => diwan:parse-code() => map:get('recension')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="diwan:work-id-from-code" as="xs:string" visibility="final">
    <xsl:param name="c" as="map(xs:string, xs:string)"/>
    <xsl:value-of
      select="map:get($c, 'recension') => replace('[a-z]+', '') || map:get($c, 'rhyme') || map:get($c, 'number') || map:get($c, 'secondary')"
    />
  </xsl:function>

</xsl:package>
