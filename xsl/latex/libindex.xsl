<!-- components for latex indices in latex

The generation of \index[type]{key} in text is mainly done in librend.xsl,
where the value of {key} is the output of a named template.
This package provides a named template for generation of {key} by taking it
from entity registries.

-->
<!DOCTYPE package [
    <!ENTITY lb "&#xa;" >
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >]>
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libindex.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:index="http://scdh.wwu.de/transform/index#" xmlns:ref="http://scdh.wwu.de/transform/ref#"
  xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:edmac="http://scdh.wwu.de/transform/edmac#"
  exclude-result-prefixes="#all" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0"
  default-mode="index:translations">

  <xsl:output method="text" indent="false"/>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libref.xsl"
    package-version="1.0.0">
    <xsl:accept component="*" names="*" visibility="private"/>
  </xsl:use-package>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/latex/libi18n.xsl"
    package-version="1.0.0">
    <xsl:accept component="function" names="i18n:babel-language#1" visibility="private"/>
  </xsl:use-package>

  <!-- an entry point which writes the index as a package into a tex file -->
  <xsl:template name="index:translation-package-filecontents" visibility="final">
    <xsl:context-item as="node()" use="required"/>
    <xsl:param name="package-name" as="xs:string" select="'i18n-index'" required="false"/>
    <xsl:param name="use" as="xs:boolean" select="true()" required="false"/>
    <xsl:text>&lb;%% this needs \usepackage{filecontents} to work!</xsl:text>
    <xsl:text>&lb;\begin{filecontents}{</xsl:text>
    <xsl:value-of select="$package-name"/>
    <xsl:text>.sty}</xsl:text>
    <xsl:call-template name="index:translation-package"/>
    <xsl:text>&lb;\end{filecontents}</xsl:text>
    <xsl:if test="$use">
      <xsl:text>&lb;\usepackage{</xsl:text>
      <xsl:value-of select="$package-name"/>
      <xsl:text>}&lb;</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- an entry point that makes a translation package -->
  <xsl:template name="index:translation-package" visibility="final">
    <xsl:context-item as="node()" use="required"/>
    <xsl:param name="package-name" as="xs:string" select="'i18n-index'" required="false"/>
    <xsl:text>&lb;\ProvidesPackage{</xsl:text>
    <xsl:value-of select="$package-name"/>
    <xsl:text>}</xsl:text>
    <xsl:text>&lb;\RequirePackage{translations}</xsl:text>
    <xsl:call-template name="index:translations"/>
  </xsl:template>

  <!-- an entry point that  -->
  <xsl:template name="index:translations" visibility="final">
    <xsl:context-item as="node()" use="required"/>
    <xsl:apply-templates mode="index:translations" select="."/>
    <xsl:text>&lb;</xsl:text>
  </xsl:template>


  <!-- mode applied on the main document to get the index keys -->
  <xsl:mode name="index:translations" on-no-match="shallow-skip" visibility="public"/>
  
  <!-- Note, that this will write out the same translation for each reference to an entity.
    This does not matter, but is a TODO.

    We could first collect the entity keys/references, drop duplicates
    and write out the translations.
  -->

  <xsl:template match="persName" mode="index:translations">
    <xsl:call-template name="index:translate-entity">
      <xsl:with-param name="index" select="'person'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="placeName" mode="index:translations">
    <xsl:call-template name="index:translate-entity">
      <xsl:with-param name="index" select="'place'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="orgName" mode="index:translations">
    <xsl:call-template name="index:translate-entity">
      <xsl:with-param name="index" select="'org'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="eventName" mode="index:translations">
    <xsl:call-template name="index:translate-entity">
      <xsl:with-param name="index" select="'event'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="rs" mode="index:translations">
    <xsl:call-template name="index:translate-entity">
      <xsl:with-param name="index" select="@type"/>
    </xsl:call-template>
  </xsl:template>



  <!-- workhorse to be called from templates of mode index:translations -->
  <xsl:template name="index:translate-entity" visibility="final">
    <xsl:context-item as="element()" use="required"/>
    <xsl:param name="index" as="xs:string"/>
    <xsl:message use-when="system-property('debug') eq 'true'">
      <xsl:text>found </xsl:text>
      <xsl:value-of select="$index"/>
      <xsl:text> entity in </xsl:text>
      <xsl:value-of select="name(.)"/>
    </xsl:message>
    <xsl:variable name="entries" as="map(xs:string, node()*)" select="index:index(., $index)"/>
    <xsl:for-each select="map:keys($entries)">
      <xsl:variable name="key" as="xs:string" select="."/>
      <xsl:variable name="singletons" as="map(xs:string, item())*">
        <xsl:apply-templates mode="index:languages" select="map:get($entries, $key)">
          <xsl:with-param name="index" select="$index" tunnel="true"/>
        </xsl:apply-templates>
      </xsl:variable>
      <!-- merging the singleton maps will drop entries for the same language -->
      <xsl:variable name="languages" as="map(xs:string, item())" select="map:merge($singletons)"/>
      <!-- write out translation entries for each language found for the index -->
      <xsl:for-each select="$languages => map:keys()">
        <xsl:variable name="language" as="xs:string" select="."/>
        <xsl:text>&lb;\DeclareTranslation{</xsl:text>
        <xsl:value-of select="$language => i18n:babel-language()"/>
        <xsl:text>}{</xsl:text>
        <xsl:value-of select="$key"/>
        <xsl:text>}{</xsl:text>
        <xsl:value-of select="map:get($languages, $language)"/>
        <xsl:text>}</xsl:text>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>


  <!-- for the element given as $context: return a map of keys/references and entities
    
    This must get a sequence of all the keys/references in the the @ref or @key attribute
    and the dereference it to the element in the registry
    
    This should not already evaluate the dereferenced entity element but return itselt.
  -->
  <xsl:function name="index:index" as="map(xs:string, node()*)">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="index" as="xs:string"/>
    <xsl:choose>
      <xsl:when test="$context/@ref">
        <xsl:for-each select="tokenize($context/@ref)">
          <xsl:sequence
            select="map { . :  ref:process-reference(., $context) => ref:dereference($context) }"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$context/@key">
        <xsl:sequence select="index:from-key-attribute($context/@key, $index, $context/@key)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="map {}"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- If @key is used, this must be overridden by a downstream package.
    Since @key's "form will depend entirely on practice within a given project",
    there is no generic implementation of this function.
    See https://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-att.canonical.html
  -->
  <xsl:function name="index:from-key-attribute" as="map(xs:string, node()*)" visibility="public">
    <xsl:param name="key" as="xs:string"/>
    <xsl:param name="index" as="xs:string"/>
    <xsl:param name="context" as="attribute()"/>
    <xsl:map>
      <xsl:map-entry key="'??'">
        <xsl:text>not implemented</xsl:text>
      </xsl:map-entry>
    </xsl:map>
  </xsl:function>

  <!-- this mode is used to get the index entries from the registry files -->
  <xsl:mode name="index:languages" on-no-match="shallow-skip" visibility="public"/>

  <xsl:template match="person" mode="index:languages">
    <xsl:apply-templates select="persName" mode="#current">
      <!-- by using the reverse order we will only keep the first name.
        See comment about map:merge() in the index:translate-entity
        named template -->
      <xsl:sort select="1 div position()"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="place" mode="index:languages">
    <xsl:apply-templates select="placeName" mode="#current">
      <xsl:sort select="1 div position()"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="org" mode="index:languages">
    <xsl:apply-templates select="orgName" mode="#current">
      <xsl:sort select="1 div position()"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="event" mode="index:languages">
    <xsl:apply-templates select="eventName" mode="#current">
      <xsl:sort select="1 div position()"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- make a singleton map { language: name } -->
  <xsl:template match="persName | placeName | orgName | eventName" mode="index:languages">
    <xsl:map>
      <!-- we get the language from the ancestor-or-self axis -->
      <xsl:map-entry key="('??', ancestor-or-self::*/@xml:lang ! string(.))[last()]"
        select="normalize-space(.)"/>
    </xsl:map>
  </xsl:template>



  <xsl:function name="index:describes-entity" as="xs:boolean" visibility="public">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="index" as="xs:string"/>
    <xsl:param name="entity" as="element()*"/>
    <xsl:variable name="context-tagname" as="xs:string" select="name($context)"/>
    <xsl:variable name="is-child" as="xs:boolean" select="exists($entity/* intersect $context)"/>
    <xsl:choose>
      <xsl:when test="not($is-child)">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <xsl:when test="$index eq 'person' and $context-tagname eq 'persName'">
        <xsl:sequence select="true()"/>
      </xsl:when>
      <xsl:when test="$index eq 'place' and $context-tagname eq 'placeName'">
        <xsl:sequence select="true()"/>
      </xsl:when>
      <xsl:when test="$index eq 'org' and $context-tagname eq 'orgName'">
        <xsl:sequence select="true()"/>
      </xsl:when>
      <xsl:when test="$index eq 'event' and $context-tagname eq 'eventName'">
        <xsl:sequence select="true()"/>
      </xsl:when>
    </xsl:choose>
  </xsl:function>


  <!-- index:key is the mode for generating the key for the index -->
  <xsl:mode name="index:key" on-no-match="shallow-skip"/>

  <xsl:template mode="index:key" match="persName">
    <xsl:param name="index" as="xs:string" tunnel="true"/>
    <xsl:param name="entity" as="element()*" tunnel="true"/>
    <xsl:if test="index:describes-entity(., $index, $entity)">
      <xsl:apply-templates mode="index:key-content"/>
    </xsl:if>
  </xsl:template>


  <xsl:mode name="index:key-content" on-no-match="shallow-skip"/>

  <!-- shrink multiple whitespace characters to a single space -->
  <xsl:template mode="index:key-content" match="text()">
    <xsl:value-of select="replace(., '\s+', ' ')"/>
  </xsl:template>



</xsl:package>
