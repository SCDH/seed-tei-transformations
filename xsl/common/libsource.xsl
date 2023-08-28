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

target/bin/xslt.sh -config:saxon.he.xml -xsl:your.xsl -s:your.xml {http://scdh.wwu.de/transform/source#}mode=12

to get something like

<span class="source-text" data-source-xpath="id('v1')/text()[2]" data-source-offset="0" data-source-length="17"> zur ersten wacht</span>


The parameter source:mode determines how source information is included in the projection of the XML source.
The mode is integer-encoded because it's much faster to compare two integers than two strings.

0: no source information


1: xpath and offset, not namespace-aware

2: xpath from xml:id and offset, not namespace-aware

3: namespace-aware xpath and offset, Clark notation of QNames, i.e. Q{uri}local

4: namespace-aware xpath from id and offset, Clark notation of QNames, i.e. Q{uri}local

5: namespace-aware xpath and offset, notation {uri}local

6: namespace-aware xpath from id and offset, notation {uri}local


7: xpath to text node, not namespace-aware

8: xpath from xml:id to text node, not namespace-aware

9: namespace-aware xpath to text node in Clark notation of QNames, i.e. Q{uri}local

10: namespace-aware xpath from id to text node in Clark notation of QNames, i.e. Q{uri}local

11: namespace-aware xpath to text node, notation {uri}local

12: namespace-aware xpath from id to text node, notation {uri}local


modes 1-6 provide an xpath with name segments from element nodes and an offset of the text node in the parent's whole text (text nodes in parent's descendants)

modes 7-12 provide the same xpath with name segements from element nodes and the text node, offset is always 0

-->
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libsource.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:source="http://scdh.wwu.de/transform/source#"
  exclude-result-prefixes="#all" version="3.0">

  <!-- the mode determines how source data is included in the projection -->
  <xsl:param name="source:mode" as="xs:integer" select="0" required="false"/>


  <xsl:variable name="source:name-mode" as="xs:integer"
    select="($source:mode mod 6 + $source:mode mod 2) mod 3" visibility="final"/>

  <xsl:variable name="source:is-mode-to-text-node" as="xs:boolean" select="$source:mode gt 6"
    visibility="final"/>

  <xsl:variable name="source:is-mode-from-id" as="xs:boolean" select="$source:mode mod 2 eq 0"
    visibility="final"/>

  <xsl:variable name="source:is-mode-from-root-qname" as="xs:boolean"
    select="$source:mode mod 6 eq 5" visibility="final"/>

  <xsl:variable name="source:is-mode-from-root-lname" as="xs:boolean"
    select="$source:mode mod 6 eq 1" visibility="final"/>

  <xsl:variable name="source:is-mode-from-root-clarkname" as="xs:boolean" select="$source:mode eq 3"
    visibility="final"/>

  <xsl:variable name="source:is-mode-from-root-to-text-node-clarkname" as="xs:boolean"
    select="$source:mode eq 9" visibility="final"/>



  <xsl:template name="source:text-node" visibility="public">
    <xsl:context-item as="text()" use="required"/>
    <xsl:choose>
      <!-- take care! order may matter since test predicates are not disjunctive for performance reasons-->
      <xsl:when test="$source:mode eq 0">
        <!-- no source information -->
        <xsl:value-of select="."/>
      </xsl:when>
      <!-- the further order should depend on probablity of the value of $source:mode -->
      <xsl:when test="$source:is-mode-from-id">
        <span class="source-text">
          <xsl:attribute name="data-source-xpath"
            select="source:xpath-from-id(., $source:name-mode, $source:is-mode-to-text-node)"/>
          <xsl:attribute name="data-source-offset"
            select="source:offset(., $source:is-mode-to-text-node)"/>
          <xsl:attribute name="data-source-length" select="string-length(.)"/>
          <xsl:value-of select="."/>
        </span>
      </xsl:when>
      <xsl:when test="$source:is-mode-from-root-qname">
        <span class="source-text">
          <xsl:attribute name="data-source-xpath"
            select="source:xpath(., $source:name-mode, $source:is-mode-to-text-node)"/>
          <xsl:attribute name="data-source-offset"
            select="source:offset(., $source:is-mode-to-text-node)"/>
          <xsl:attribute name="data-source-length" select="string-length(.)"/>
          <xsl:value-of select="."/>
        </span>
      </xsl:when>
      <xsl:when test="$source:is-mode-from-root-clarkname">
        <span class="source-text">
          <xsl:attribute name="data-source-xpath" select="path(./parent::*)"/>
          <xsl:attribute name="data-source-offset"
            select="source:offset(., $source:is-mode-to-text-node)"/>
          <xsl:attribute name="data-source-length" select="string-length(.)"/>
          <xsl:value-of select="."/>
        </span>
      </xsl:when>
      <xsl:when test="$source:is-mode-from-root-to-text-node-clarkname">
        <span class="source-text">
          <xsl:attribute name="data-source-xpath" select="path(.)"/>
          <xsl:attribute name="data-source-offset"
            select="source:offset(., $source:is-mode-to-text-node)"/>
          <xsl:attribute name="data-source-length" select="string-length(.)"/>
          <xsl:value-of select="."/>
        </span>
      </xsl:when>
      <xsl:when test="$source:is-mode-from-root-lname">
        <span class="source-text">
          <xsl:attribute name="data-source-xpath"
            select="source:xpath-nons(., $source:name-mode, $source:is-mode-to-text-node)"/>
          <xsl:attribute name="data-source-offset"
            select="source:offset(., $source:is-mode-to-text-node)"/>
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
    <xsl:param name="name-mode" as="xs:integer"/>
    <xsl:param name="is-text-node-path-element" as="xs:boolean"/>
    <xsl:variable name="path-elements" as="xs:string*">
      <xsl:for-each select="$node/ancestor::*">
        <xsl:variable name="name" as="xs:string" select="local-name(.)"/>
        <xsl:variable name="nth" as="xs:integer"
          select="count(preceding-sibling::*[local-name(.) eq $name])"/>
        <xsl:sequence select="concat('/', $name, '[', $nth + 1, ']')"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:sequence
      select="string-join(($path-elements, source:text-node-path-element($node, $is-text-node-path-element)))"
    />
  </xsl:function>

  <xsl:function name="source:xpath" as="xs:string" visibility="final" new-each-time="no">
    <xsl:param name="node" as="text()"/>
    <xsl:param name="name-mode" as="xs:integer"/>
    <xsl:param name="is-text-node-path-element" as="xs:boolean"/>
    <xsl:variable name="path-elements" as="xs:string*">
      <xsl:for-each select="$node/ancestor::*">
        <xsl:variable name="name" as="xs:QName" select="node-name(.)"/>
        <xsl:variable name="nth" as="xs:integer"
          select="count(preceding-sibling::*[node-name(.) eq $name])"/>
        <xsl:sequence select="concat('/', source:name(., $name-mode), '[', $nth + 1, ']')"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:sequence
      select="string-join(($path-elements, source:text-node-path-element($node, $is-text-node-path-element)))"
    />
  </xsl:function>


  <xsl:function name="source:xpath-from-id" as="xs:string" visibility="final" new-each-time="no">
    <xsl:param name="node" as="text()"/>
    <xsl:param name="name-mode" as="xs:integer"/>
    <xsl:param name="is-text-node-path-element" as="xs:boolean"/>
    <xsl:value-of
      select="source:recurse-to-id($node/parent::*, source:text-node-path-element($node, $is-text-node-path-element), $name-mode, $is-text-node-path-element)"
    />
  </xsl:function>

  <xsl:function name="source:recurse-to-id" as="xs:string" visibility="private">
    <xsl:param name="node" as="element()"/>
    <xsl:param name="path" as="xs:string"/>
    <xsl:param name="name-mode" as="xs:integer"/>
    <xsl:param name="is-text-node-path-element" as="xs:boolean"/>
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
          select="source:recurse-to-id($node/parent::*, concat('/', source:name($node, $name-mode), '[', $nth + 1, ']', $path), $name-mode, $is-text-node-path-element)"
        />
      </xsl:when>
      <xsl:otherwise>
        <!-- root node reached -->
        <xsl:value-of select="concat('/', source:name($node, $name-mode), '[1]', $path)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="source:name" as="xs:string" visibility="private" new-each-time="no">
    <xsl:param name="node" as="element()"/>
    <!-- passing the $source:mode in as an argument makes this function side-effect free -->
    <xsl:param name="name-mode" as="xs:integer"/>
    <xsl:choose>
      <!-- first we have to handle unqualified names -->
      <xsl:when test="namespace-uri($node) eq ''">
        <xsl:sequence select="local-name($node)"/>
      </xsl:when>
      <!-- the further order should be determined by probable values of $source:mode -->
      <!-- the mapping of integers may depend on the calculation of $source:name-mode -->
      <xsl:when test="$name-mode eq 0">
        <xsl:sequence select="concat('{', namespace-uri($node), '}', local-name($node))"/>
      </xsl:when>
      <xsl:when test="$name-mode eq 1">
        <xsl:sequence select="concat('Q{', namespace-uri($node), '}', local-name($node))"/>
      </xsl:when>
      <xsl:when test="$name-mode eq 2">
        <xsl:sequence select="local-name($node)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="string(node-name($node))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="source:text-node-path-element" as="xs:string" visibility="private"
    new-each-time="no">
    <xsl:param name="node" as="text()"/>
    <xsl:param name="present" as="xs:boolean"/>
    <xsl:choose>
      <xsl:when test="$present">
        <xsl:value-of
          select="concat('/text()[', $node/preceding-sibling::text() => count() + 1, ']')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="''"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="source:offset" as="xs:integer" visibility="final" new-each-time="no">
    <xsl:param name="node" as="text()"/>
    <xsl:param name="zero" as="xs:boolean"/>
    <xsl:choose>
      <xsl:when test="$zero">
        <xsl:sequence select="0"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="parent" as="element()" select="$node/parent::*"/>
        <!-- expensive! -->
        <xsl:variable name="preceding-text" as="text()*"
          select="$node/preceding::text() intersect $parent/descendant::text()"/>
        <xsl:sequence select="sum($preceding-text ! string-length())"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:package>
