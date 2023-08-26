<!-- A XSLT package that provides components for making a (HTML) projection or view transparent on its XML source.

USAGE:

<xsl:template
  ...
  xmlns:source="http://scdh.wwu.de/transform/source#">

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libsource.xsl"
    package-version="1.0.0"/>

  ...

  <xsl:template match="text()" mode="your-mode">
    <xsl:call-templage name="source:text-node"/>
  </xsl:template>

  ...

</xsl:template>

Run XSLT with source mode:

target/bin/xslt.sh -config:saxon.he.xml -xsl:your.xsl -s:your.xml {http://scdh.wwu.de/transform/source#}mode=1

The parameter source:mode determines how source information is included in the projection of the XML source.
The mode is integer-encoded because it's much faster to compare two integers than two strings.

0: no source information

1: xpath and offset, not namespace-aware

2: xpath from xml:id and offset, not namespace-aware

3: namespace-aware xpath in Clark notation of QNames, i.e. Q{uri}local

4: namespace-aware xpath from id in Clark notation of QNames, i.e. Q{uri}local

5: namespace-aware xpath, notation {uri}local

6: namespace-aware xpath from id, notation {uri}local

-->
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libsource.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:source="http://scdh.wwu.de/transform/source#"
  exclude-result-prefixes="#all" version="3.0">

  <!-- the mode determines how source data is included in the projection: 0=none, 1=span/@data -->
  <xsl:param name="source:mode" as="xs:integer" select="0" required="false"/>

  <xsl:template name="source:text-node" visibility="public">
    <xsl:context-item as="text()" use="required"/>
    <xsl:choose>
      <!-- the order should depend on probablity of the value of $source:mode -->
      <xsl:when test="$source:mode eq 6 or $source:mode eq 4 or $source:mode eq 2">
        <span class="source-text">
          <xsl:attribute name="data-source-xpath" select="source:xpath-from-id(., $source:mode)"/>
          <xsl:attribute name="data-source-offset" select="source:offset(.)"/>
          <xsl:attribute name="data-source-length" select="string-length(.)"/>
          <xsl:value-of select="."/>
        </span>
      </xsl:when>
      <xsl:when test="$source:mode eq 0">
        <!-- no source information -->
        <xsl:value-of select="."/>
      </xsl:when>
      <xsl:when test="$source:mode eq 5">
        <span class="source-text">
          <xsl:attribute name="data-source-xpath" select="source:xpath(., $source:mode)"/>
          <xsl:attribute name="data-source-offset" select="source:offset(.)"/>
          <xsl:attribute name="data-source-length" select="string-length(.)"/>
          <xsl:value-of select="."/>
        </span>
      </xsl:when>
      <xsl:when test="$source:mode eq 3">
        <span class="source-text">
          <xsl:attribute name="data-source-xpath" select="path(./parent::*)"/>
          <xsl:attribute name="data-source-offset" select="source:offset(.)"/>
          <xsl:attribute name="data-source-length" select="string-length(.)"/>
          <xsl:value-of select="."/>
        </span>
      </xsl:when>
      <xsl:when test="$source:mode eq 1">
        <span class="source-text">
          <xsl:attribute name="data-source-xpath" select="source:xpath-nons(.)"/>
          <xsl:attribute name="data-source-offset" select="source:offset(.)"/>
          <xsl:attribute name="data-source-length" select="string-length(.)"/>
          <xsl:value-of select="."/>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <!-- no source information -->
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:function name="source:xpath-nons" as="xs:string" visibility="final" new-each-time="no">
    <xsl:param name="node" as="text()"/>
    <xsl:variable name="path-elements" as="xs:string*">
      <xsl:for-each select="$node/ancestor::*">
        <xsl:variable name="name" as="xs:string" select="local-name(.)"/>
        <xsl:variable name="nth" as="xs:integer"
          select="count(preceding-sibling::*[local-name(.) eq $name])"/>
        <xsl:sequence select="concat('/', $name, '[', $nth + 1, ']')"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:sequence select="string-join($path-elements)"/>
  </xsl:function>

  <xsl:function name="source:xpath" as="xs:string" visibility="final" new-each-time="no">
    <xsl:param name="node" as="text()"/>
    <xsl:param name="mode" as="xs:integer"/>
    <xsl:variable name="path-elements" as="xs:string*">
      <xsl:for-each select="$node/ancestor::*">
        <xsl:variable name="name" as="xs:QName" select="node-name(.)"/>
        <xsl:variable name="nth" as="xs:integer"
          select="count(preceding-sibling::*[node-name(.) eq $name])"/>
        <xsl:sequence select="concat('/', source:name(., $mode), '[', $nth + 1, ']')"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:sequence select="string-join($path-elements)"/>
  </xsl:function>


  <xsl:function name="source:xpath-from-id" as="xs:string" visibility="final" new-each-time="no">
    <xsl:param name="node" as="text()"/>
    <xsl:param name="mode" as="xs:integer"/>
    <xsl:value-of select="source:recurse-to-id($node/parent::*, '', $mode)"/>
  </xsl:function>

  <xsl:function name="source:recurse-to-id" as="xs:string" visibility="private">
    <xsl:param name="node" as="element()"/>
    <xsl:param name="path" as="xs:string"/>
    <xsl:param name="mode" as="xs:integer"/>
    <xsl:choose>
      <xsl:when test="$node/@xml:id">
        <!-- node with @xml:id reached -->
        <xsl:value-of
          select="concat('id(', codepoints-to-string(39), $node/@xml:id, codepoints-to-string(39), ')', $path)"
        />
      </xsl:when>
      <xsl:when test="$node/parent::element()">
        <!-- recursion step to parent -->
        <xsl:variable name="name" as="xs:QName" select="node-name($node)"/>
        <xsl:variable name="nth" as="xs:integer"
          select="count($node/preceding-sibling::*[node-name(.) eq $name])"/>
        <xsl:value-of
          select="source:recurse-to-id($node/parent::*, concat('/', source:name($node, $mode), '[', $nth + 1, ']', $path), $mode)"
        />
      </xsl:when>
      <xsl:otherwise>
        <!-- root node reached -->
        <xsl:value-of select="concat('/', source:name($node, $mode), '[1]', $path)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="source:name" as="xs:string" visibility="private" new-each-time="no">
    <xsl:param name="node" as="element()"/>
    <!-- passing the $source:mode in as an argument makes this function side-effect free -->
    <xsl:param name="mode" as="xs:integer"/>
    <xsl:choose>
      <!-- first we have to handle unqualified names -->
      <xsl:when test="namespace-uri($node) eq ''">
        <xsl:sequence select="local-name($node)"/>
      </xsl:when>
      <!-- the further order should be determined by probable values of $source:mode -->
      <xsl:when test="$mode eq 6 or $mode eq 5">
        <xsl:sequence select="concat('{', namespace-uri($node), '}', local-name($node))"/>
      </xsl:when>
      <xsl:when test="$mode eq 4 or $mode eq 3">
        <xsl:sequence select="concat('Q{', namespace-uri($node), '}', local-name($node))"/>
      </xsl:when>
      <xsl:when test="$mode eq 2 or $mode eq 1">
        <xsl:sequence select="local-name($node)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="node-name($node)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="source:offset" as="xs:integer" visibility="final" new-each-time="no">
    <xsl:param name="node" as="text()"/>
    <xsl:variable name="parent" as="element()" select="$node/parent::*"/>
    <!-- expensive! -->
    <xsl:variable name="preceding-text" as="text()*"
      select="$node/preceding::text() intersect $parent/descendant::text()"/>
    <xsl:sequence select="sum($preceding-text ! string-length())"/>
  </xsl:function>

</xsl:package>
