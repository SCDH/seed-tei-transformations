<?xml version="1.0" encoding="UTF-8"?>
<!-- a package for processing oXygen transformation scenarios or oxygen project files (xpr)

USAGE:

generate HTML info:

target/bin/xslt.sh -config:saxon.he.xml -xsl:xsl/common/libox.xsl -it:test-info \!method=html uri=$(realpath transformation.scenarios)'#Diplomatic'

generate ant xslt task:

target/bin/xslt.sh -config:saxon.he.xml -xsl:xsl/common/libox.xsl -it:test-ant-xslt-target uri=$(realpath transformation.scenarios)'#Diplomatic'


Note that the fragment identifier of the uri parameter must contain the name, but spaces and hash tag must be stripped of.
-->
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libox.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ox="http://scdh.wwu.de/transform/ox#"
  xmlns:eg="http://www.tei-c.org/ns/Examples" exclude-result-prefixes="#all" version="3.0">

  <xsl:output method="xml" indent="true"/>


  <!-- an uri with a fragment identifier abused for identifying the scenario, used for testing -->
  <xsl:param name="uri" as="xs:string" select="''"/>

  <!-- an example Identifier or URL for testing -->
  <xsl:param name="example" as="xs:string" select="'test'"/>


  <!-- entry point for testing the HTML info -->
  <xsl:template name="test-info" visibility="final">
    <xsl:for-each select="ox:scenario-by-uri($uri)">
      <xsl:call-template name="ox:transformation-info">
        <xsl:with-param name="output" as="xs:string" select="$example"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>


  <!-- a special function that dereferences a URI with fragment identifier to scenario where spaces must be stripped from the fragment identifier -->
  <xsl:function name="ox:scenario-by-uri" as="element(scenario)?" visibility="final">
    <xsl:param name="uri" as="xs:string"/>
    <xsl:if test="matches($uri, '#')">
      <xsl:variable name="name" as="xs:string" select="tokenize($uri, '#')[2]"/>
      <xsl:sequence select="tokenize($uri, '#')[1] => doc() => ox:scenario($name)"/>
    </xsl:if>
  </xsl:function>

  <!-- returns a scenario with given name, the name must be given without spaces -->
  <xsl:function name="ox:scenario" as="element(scenario)?" visibility="final">
    <xsl:param name="root" as="node()"/>
    <xsl:param name="name" as="xs:string"/>
    <xsl:sequence
      select="$root//scenario[ox:get-field(., 'name') => ox:scenario-identifier() eq $name]"/>
  </xsl:function>

  <!-- strips characters from the name so that it can be used as a fragment identifier -->
  <xsl:function name="ox:scenario-identifier" as="xs:string" visibility="final">
    <xsl:param name="name" as="xs:string"/>
    <xsl:value-of select="replace($name, '[#\s]+', '')"/>
  </xsl:function>

  <xsl:function name="ox:get-field" as="xs:string?" visibility="final">
    <xsl:param name="scenario" as="element()"/>
    <xsl:param name="name" as="xs:string"/>
    <xsl:sequence select="$scenario/field[@name eq $name]/String ! string() [1]"/>
  </xsl:function>

  <xsl:function name="ox:get-bool" as="xs:boolean?" visibility="final">
    <xsl:param name="scenario" as="element()"/>
    <xsl:param name="name" as="xs:string"/>
    <xsl:sequence select="$scenario/field[@name eq $name]/Boolean ! string() ! xs:boolean(.) [1]"/>
  </xsl:function>

  <xsl:function name="ox:get-list" as="element()*" visibility="final">
    <xsl:param name="scenario" as="element()"/>
    <xsl:param name="name" as="xs:string"/>
    <xsl:sequence select="$scenario/field[@name eq $name]/list/*"/>
  </xsl:function>

  <xsl:function name="ox:normalize-value" as="xs:string">
    <xsl:param name="value" as="xs:string"/>
    <xsl:value-of select="replace($value, '[)(]', '.')"/>
  </xsl:function>



  <!-- html output with information about a scenario -->
  <xsl:template name="ox:transformation-info" visibility="final">
    <xsl:context-item as="element(scenario)" use="required"/>
    <xsl:param name="output" as="xs:string"/>
    <xsl:param name="level" as="xs:integer" select="5"/>
    <xsl:variable name="scenario" as="element(scenario)" select="."/>
    <section class="transformation">
      <xsl:element name="h{min(($level, 6))}">
        <xsl:value-of select="ox:get-field($scenario, 'name')"/>
      </xsl:element>

      <iframe
        class="transformation-result {ox:get-field(., 'name') => ox:scenario-identifier()}-transformation"
        src="{$output}" onload="javascript:registerIFrameResizer(this)"/>

      <section class="stylesheet">
        <xsl:element name="h{min(($level + 1, 6))}">stylesheet</xsl:element>
        <xsl:text> </xsl:text>
        <code>
          <xsl:value-of
            select="ox:get-field($scenario, 'inputXSLURL') ! replace(., '^\$\{[^\}]*\}/', '')"/>
        </code>
      </section>

      <section class="stylesheet">
        <xsl:element name="h{min(($level + 1, 6))}">Saxon config</xsl:element>
        <xsl:text> </xsl:text>
        <code>
          <xsl:value-of
            select="ox:get-field($scenario//xsltSaxonBAdvancedOptions, 'configSystemID') ! replace(., '^\$\{[^\}]*\}/', '')"
          />
        </code>
      </section>

      <section class="parameters">
        <xsl:element name="h{min(($level + 1, 6))}">Parameters</xsl:element>
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
        <pre><xsl:value-of select="ox:get-bool(., 'hasXPathValue')"/></pre>
      </td>
      <td>
        <pre><xsl:value-of select="ox:get-bool(., 'isStatic')"/></pre>
      </td>
    </tr>
  </xsl:template>


  <!-- Apache Ant target -->


  <!-- entry point for testing during development -->
  <xsl:template name="test-ant-xslt-target" visibility="final">
    <xsl:for-each select="ox:scenario-by-uri($uri)">
      <xsl:call-template name="ox:xslt-target">
        <xsl:with-param name="example" select="$example"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>


  <!-- make xslt target -->
  <xsl:template name="ox:xslt-target" visibility="public">
    <xsl:context-item as="element(scenario)" use="required"/>
    <xsl:param name="example" as="xs:string"/>
    <xsl:param name="project" as="xs:string"/>
    <xslt>
      <xsl:attribute name="classpathref">project.class.path</xsl:attribute>
      <xsl:attribute name="style" select="ox:get-field(., 'inputXSLURL')"/>
      <xsl:attribute name="in" select="'${' || $project || '-outdir}/' || $example || '.xml'"/>
      <xsl:attribute name="out"
        select="'${' || $project || '-outdir}/' || $example || '_' || (ox:get-field(., 'name') => ox:scenario-identifier()) || ox:suffix(.)"/>
      <factory name="net.sf.saxon.TransformerFactoryImpl">
        <xsl:if test="ox:get-field(.//xsltSaxonBAdvancedOptions, 'configSystemID')">
          <attribute name="http://saxon.sf.net/feature/configuration-file"
            value="{ox:get-field(.//xsltSaxonBAdvancedOptions, 'configSystemID')}"/>
        </xsl:if>
      </factory>
      <xsl:call-template name="ox:post-size-js"/>
      <xsl:apply-templates mode="ox:xslt-target-parameters" select=".">
        <xsl:with-param name="stylesheet" as="xs:string" select="ox:get-field(., 'inputXSLURL')"
          tunnel="true"/>
      </xsl:apply-templates>
    </xslt>
  </xsl:template>

  <xsl:template name="ox:post-size-js">
    <param name="{{http://scdh.wwu.de/transform/html#}}after-body-js" expression="${{post-size.js}}"
    />
  </xsl:template>

  <xsl:function name="ox:name-to-id" as="xs:string">
    <xsl:param name="name" as="xs:string"/>
    <xsl:value-of select="replace($name, '\s+', '')"/>
  </xsl:function>

  <xsl:function name="ox:suffix" as="xs:string" visibility="final">
    <xsl:param name="scenario" as="element(scenario)"/>
    <xsl:value-of
      select="ox:get-field($scenario, 'outputResource') => replace('\$\{[a-zA-Z]+\}', '')"/>
  </xsl:function>

  <xsl:mode name="ox:xslt-target-parameters" on-no-match="shallow-skip"/>

  <xsl:template mode="ox:xslt-target-parameters" match="transformationParameter">
    <param>
      <xsl:attribute name="name">
        <xsl:if test="ox:get-field(descendant::paramDescriptor, 'namespace')">
          <xsl:text>{</xsl:text>
          <xsl:value-of select="ox:get-field(descendant::paramDescriptor, 'namespace')"/>
          <xsl:text>}</xsl:text>
        </xsl:if>
        <xsl:value-of select="ox:get-field(descendant::paramDescriptor, 'localName')"/>
      </xsl:attribute>
      <xsl:attribute name="expression" select="ox:get-field(., 'value')"/>
      <xsl:apply-templates mode="ox:xslt-target-parameter-type" select="."/>
    </param>
  </xsl:template>

  <xsl:mode name="ox:xslt-target-parameter-type" on-no-match="deep-skip"/>

  <xsl:template mode="ox:xslt-target-parameter-type"
    match="transformationParameter[ox:get-bool(., 'hasXPathValue') and ox:get-field(., 'value') => matches('^(true|false)\(\)$')]">
    <xsl:attribute name="type">XPATH_BOOLEAN</xsl:attribute>
  </xsl:template>

</xsl:package>
