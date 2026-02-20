<?xml version="1.0" encoding="UTF-8"?>
<!-- a package for processing oXygen transformation scenarios
-->
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libox.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ox="http://scdh.wwu.de/transform/ox#"
  exclude-result-prefixes="#all" version="3.0" default-mode="test">

  <xsl:output method="html" indent="true"/>

  <!-- choose a transformation scenario during testing -->
  <xsl:param name="name" as="xs:string?" select="()"/>


  <xsl:mode name="test" on-no-match="deep-skip"/>

  <!-- entry point for testing during development -->
  <xsl:template mode="test" match="document-node()">
    <xsl:message>hallo1</xsl:message>
    <xsl:for-each select="ox:scenario(., $name)">
      <xsl:message>hallo2</xsl:message>
      <xsl:call-template name="ox:transformation-info">
        <xsl:with-param name="scenario" as="element(scenario)" select="."/>
        <xsl:with-param name="output" as="xs:anyURI" select="xs:anyURI('test.html')"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>


  <xsl:function name="ox:scenario" as="element(scenario)?" visibility="final">
    <xsl:param name="root" as="node()"/>
    <xsl:param name="name" as="xs:string"/>
    <xsl:sequence select="$root//scenario[ox:get-field(., 'name') eq $name]"/>
  </xsl:function>

  <xsl:function name="ox:get-field" as="xs:string?" visibility="final">
    <xsl:param name="scenario" as="element()"/>
    <xsl:param name="name" as="xs:string"/>
    <xsl:sequence select="$scenario/field[@name eq $name]/String ! string() [1]"/>
  </xsl:function>

  <xsl:function name="ox:get-list" as="element()*" visibility="final">
    <xsl:param name="scenario" as="element()"/>
    <xsl:param name="name" as="xs:string"/>
    <xsl:sequence select="$scenario/field[@name eq $name]/list/*"/>
  </xsl:function>



  <!-- html output with information about a scenario -->
  <xsl:template name="ox:transformation-info" visibility="final">
    <xsl:param name="scenario" as="element(scenario)"/>
    <xsl:param name="output" as="xs:anyURI"/>
    <xsl:param name="level" as="xs:integer" select="7"/>
    <section>
      <xsl:element name="h{$level}">
        <xsl:value-of select="ox:get-field($scenario, 'name')"/>
      </xsl:element>

      <iframe src="{$output}"/>

      <section>
        <xsl:element name="h{$level + 1}">stylesheet / package</xsl:element>
        <code>
          <xsl:value-of
            select="ox:get-field($scenario, 'inputXSLURL') ! replace(., '^\$\{[^\}]*\}/', '')"/>
        </code>
      </section>

      <section>
        <xsl:element name="h{$level + 1}">Saxon config</xsl:element>
        <code>
          <xsl:value-of
            select="ox:get-field($scenario//xsltSaxonBAdvancedOptions, 'configSystemID') ! replace(., '^\$\{[^\}]*\}/', '')"
          />
        </code>
      </section>

      <section>
        <xsl:element name="h{$level + 1}">Parameters</xsl:element>
        <table>
          <thead>
            <th>local name</th>
            <th>prefix</th>
            <th>namespace</th>
            <th>value</th>
            <th>XPath</th>
            <th>static</th>
          </thead>
          <tbody>
            <xsl:apply-templates mode="ox:parameter-html"
              select="ox:get-list($scenario, 'xsltParams')"/>
          </tbody>
        </table>
      </section>

    </section>
  </xsl:template>

  <xsl:mode name="ox:parameter-html" on-no-match="shallow-skip"/>

  <xsl:template mode="ox:parameter-html" match="transformationParameter">
    <tr>
      <td>
        <pre><xsl:value-of select="ox:get-field(field[@name='paramDescription']/paramDescriptor, 'localName')"/></pre>
      </td>
      <td>
        <pre><xsl:value-of select="ox:get-field(field[@name='paramDescription']/paramDescriptor, 'prefix')"/></pre>
      </td>
      <td>
        <pre><xsl:value-of select="ox:get-field(field[@name='paramDescription']/paramDescriptor, 'namespace')"/></pre>
      </td>
      <td>
        <pre><xsl:value-of select="ox:get-field(., 'value')"/></pre>
      </td>
      <td>
        <pre><xsl:value-of select="ox:get-field(., 'hasXPathValue')"/></pre>
      </td>
      <td>
        <pre><xsl:value-of select="ox:get-field(., 'isStatic')"/></pre>
      </td>
    </tr>
  </xsl:template>

</xsl:package>
