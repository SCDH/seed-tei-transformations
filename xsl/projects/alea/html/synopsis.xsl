<?xml version="1.0" encoding="UTF-8"?>
<!-- ALEA Synopsis for Diwan

This XSLT package makes the HTML synopsis for MRE documents

USAGE:

target/bin/xslt.sh \
    -config:saxon.he.html.xml \
    -xsl:xsl/projects/alea/html/synopsis.xsl \
    -xi \
    -s:/home/clueck/Projekte/edition-ibn-nubatah/Diwan/dal/dal12/dal12.tei.xml 

-->
<!DOCTYPE stylesheet [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
    <!ENTITY nbsp "&#xa0;" >
    <!ENTITY emsp "&#x2003;" >
    <!ENTITY lb "&#xa;" >
]>
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/html/diwan.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:app="http://scdh.wwu.de/transform/app#"
  xmlns:seed="http://scdh.wwu.de/transform/seed#" xmlns:text="http://scdh.wwu.de/transform/text#"
  xmlns:common="http://scdh.wwu.de/transform/common#"
  xmlns:meta="http://scdh.wwu.de/transform/meta#" xmlns:wit="http://scdh.wwu.de/transform/wit#"
  xmlns:html="http://scdh.wwu.de/transform/html#"
  xmlns:biblio="http://scdh.wwu.de/transform/biblio#"
  xmlns:alea="http://scdh.wwu.de/transform/alea#" xmlns:ref="http://scdh.wwu.de/transform/ref#"
  xmlns:test="http://scdh.wwu.de/transform/test#" exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0" default-mode="synopsis">

  <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

  <!-- whether to use the HTML template from libhtml and make a full HTML file -->
  <xsl:param name="use-libhtml" as="xs:boolean" select="true()"/>


  <xsl:mode name="preview" on-no-match="shallow-copy" visibility="public"/>

  <xsl:variable name="language" as="xs:string" visibility="public">
    <xsl:try select="/*/@xml:lang">
      <xsl:catch errors="*" select="'ar'"/>
    </xsl:try>
  </xsl:variable>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libi18n.xsl"
    package-version="0.1.0">
    <xsl:override>
      <xsl:variable name="i18n:default-language" as="xs:string" select="$language"/>
    </xsl:override>
  </xsl:use-package>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libcouplet.xsl"
    package-version="1.0.0">
    <xsl:override>

      <!-- colorize and filter choice/seg  -->
      <xsl:template mode="text:text" match="text()[ancestor::seg[parent::choice]/@source]">
        <xsl:param name="recension" as="xs:string" tunnel="yes"/>
        <xsl:variable name="recensions" as="xs:string+"
          select="ancestor::seg[parent::choice]/@source ! tokenize(.) ! substring(., 2)"/>
        <xsl:if test="$recensions = $recension">
          <span
            class="variation variation-{generate-id(ancestor::seg)} variation-parent-{generate-id(ancestor::seg/parent::choice)}">
            <xsl:value-of select="."/>
          </span>
        </xsl:if>
      </xsl:template>

      <xsl:function name="common:line-number" as="xs:string">
        <xsl:param name="context" as="node()"/>
        <xsl:value-of select="''"/>
      </xsl:function>

    </xsl:override>
  </xsl:use-package>



  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libhtml.xsl"
    package-version="1.0.0">

    <xsl:accept component="mode" names="html:html" visibility="public"/>
    <xsl:accept component="template" names="html:*" visibility="public"/>

    <xsl:override>

      <!-- a comma separated list of CSS files -->
      <xsl:param name="html:css-csv" as="xs:string"
        select="resolve-uri('diwan.css', static-base-uri())"/>

      <!-- this makes the page content -->
      <xsl:template name="html:content">
        <div>
          <section class="content">
            <xsl:variable name="recensions" as="attribute()*"
              select="/TEI/teiHeader//listWit/@xml:id"/>
            <table class="synopsis">
              <thead>
                <tr>
                  <xsl:for-each select="$recensions">
                    <td>
                      <xsl:value-of select="."/>
                    </td>
                  </xsl:for-each>
                </tr>
                <tr>
                  <xsl:for-each select="$recensions">
                    <xsl:variable name="recension" as="xs:string" select="."/>
                    <td>
                      <!-- only output head if it is not restricted to a @source -->
                      <xsl:variable name="context" select="/TEI/text//head"/>
                      <xsl:if
                        test="not($context/@source) or ((tokenize($context/@source) ! substring(., 2)) = $recension)">
                        <xsl:apply-templates mode="text:text" select="$context">
                          <xsl:with-param name="recension" as="xs:string" select="." tunnel="yes"/>
                        </xsl:apply-templates>
                      </xsl:if>
                    </td>
                  </xsl:for-each>
                </tr>
              </thead>
              <tbody>
                <xsl:for-each select="/TEI/text//l">
                  <xsl:variable name="context" as="element(l)" select="."/>
                  <tr>
                    <xsl:for-each select="$recensions">
                      <xsl:variable name="recension" as="xs:string" select="."/>
                      <td>
                        <xsl:choose>
                          <!-- l not bound to any @source -->
                          <xsl:when test="not($context/@source)">
                            <div class="couplet-container">
                              <xsl:apply-templates select="$context" mode="text:text">
                                <xsl:with-param name="recension" as="xs:string" select="$recension"
                                  tunnel="yes"/>
                              </xsl:apply-templates>
                            </div>
                          </xsl:when>
                          <!-- l bound to @source -->
                          <xsl:when
                            test="$context[(tokenize(@source) ! substring(., 2)) = $recension]">
                            <div
                              class="couplet-container variation variation-{generate-id($context)}">
                              <xsl:apply-templates select="$context" mode="text:text">
                                <xsl:with-param name="recension" as="xs:string" select="$recension"
                                  tunnel="yes"/>
                              </xsl:apply-templates>
                            </div>
                          </xsl:when>
                        </xsl:choose>
                      </td>
                    </xsl:for-each>
                  </tr>
                </xsl:for-each>
              </tbody>
            </table>
          </section>
        </div>
      </xsl:template>

      <xsl:template name="html:title" visibility="public">
        <xsl:value-of select="(/*/@xml:id, //title ! normalize-space())[1]"/>
        <xsl:text> :: ALEA</xsl:text>
      </xsl:template>

    </xsl:override>
  </xsl:use-package>

  <xsl:mode name="synopsis" on-no-match="shallow-copy" visibility="public"/>

  <!-- if parameter $use-libhtml is true, switch to html:html mode -->
  <xsl:template match="/ | TEI" priority="10" mode="synopsis">
    <xsl:choose>
      <xsl:when test="$use-libhtml">
        <xsl:apply-templates mode="html:html" select="root()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="html:content"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:package>
