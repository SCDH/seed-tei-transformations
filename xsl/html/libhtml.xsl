<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT package with components for a HTML output file

Note, that the default mode is html:html!
-->
<!DOCTYPE package [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
    <!ENTITY nbsp "&#xa0;" >
    <!ENTITY emsp "&#x2003;" >
    <!ENTITY lb "&#xa;" >
]>
<xsl:package
  name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libhtml.xsl"
  package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:app="http://scdh.wwu.de/transform/app#"
  xmlns:seed="http://scdh.wwu.de/transform/seed#"
  xmlns:common="http://scdh.wwu.de/transform/common#"
  xmlns:html="http://scdh.wwu.de/transform/html#"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="3.1"
  default-mode="html:html">

  <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

  <!-- a sequence of CSS files -->
  <xsl:param name="html:css" as="xs:string*" select="()"/>

  <!-- should be one of 'internal', 'absolute', 'relative' -->
  <xsl:param name="html:css-method" as="xs:string" select="'internal'"/>

  <!-- a sequence of Javascript files to be included on the header -->
  <xsl:param name="html:js" as="xs:string*" select="()"/>

  <!-- should be one of 'internal', 'absolute', 'relative' -->
  <xsl:param name="html:js-method" as="xs:string" select="'internal'"/>

  <!-- a sequence of javascript files to be included after the document body -->
  <xsl:param name="html:after-body-js" as="xs:string*" select="()"/>

  <!-- javascript file defining the makeScrollTarget function -->
  <xsl:param name="html:scroll-target" as="xs:string*" select="()"/>

  <!-- should be one of 'internal', 'absolute', 'relative' -->
  <xsl:param name="html:scroll-target-method" as="xs:string" select="'internal'"/>


  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libi18n.xsl"
    package-version="0.1.0">
    <xsl:accept component="function" names="i18n:language#1" visibility="private"/>
  </xsl:use-package>

  <xsl:use-package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libprose.xsl"
    package-version="1.0.0"/>

  <xsl:mode name="html:html" on-no-match="shallow-skip" visibility="public"/>

  <xsl:template match="/*">
    <xsl:text disable-output-escaping="yes" use-when="false()">&lt;!DOCTYPE html&gt;&lb;</xsl:text>
    <xsl:for-each select="//xi:include">
      <xsl:message>
        <xsl:call-template name="html:xi-warning">
          <xsl:with-param name="include-element" select="."/>
        </xsl:call-template>
      </xsl:message>
      <xsl:comment>
        <xsl:call-template name="html:xi-warning">
          <xsl:with-param name="include-element" select="."/>
        </xsl:call-template>
      </xsl:comment>
    </xsl:for-each>
    <html lang="{i18n:language(.)}">
      <xsl:if test="@xml:id">
        <xsl:attribute name="id" select="@xml:id"/>
      </xsl:if>
      <head>
        <meta charset="utf-8"/>
        <xsl:call-template name="html:meta-hook"/>
        <title>
          <xsl:call-template name="html:title"/>
        </title>
        <xsl:call-template name="html:css"/>
        <xsl:call-template name="html:js"/>
        <xsl:call-template name="html:last-in-head-hook"/>
      </head>
      <body>
        <xsl:call-template name="html:first-in-body-hook"/>
        <div class="content">
          <xsl:call-template name="html:content"/>
        </div>
        <xsl:call-template name="html:last-in-body-hook"/>
      </body>
      <xsl:call-template name="html:after-body-hook"/>
      <xsl:call-template name="html:after-body-js"/>
    </html>
  </xsl:template>

  <xsl:template name="html:meta-hook" visibility="public">
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  </xsl:template>

  <xsl:template name="html:title" visibility="public">
    <xsl:value-of select="(//title ! normalize-space()) => string-join(' :: ')"/>
    <xsl:text> :: SEED transformations</xsl:text>
  </xsl:template>

  <xsl:template name="html:css" visibility="public">
    <xsl:variable name="base-uri" select="base-uri()"/>
    <xsl:choose>
      <xsl:when test="$html:css-method eq 'internal'">
        <xsl:for-each select="$html:css">
          <xsl:variable name="href" select="resolve-uri(., $base-uri)"/>
          <xsl:choose>
            <xsl:when test="unparsed-text-available($href)">
              <xsl:comment>
                <xsl:text>CSS from </xsl:text>
                <xsl:value-of select="$href"/>
              </xsl:comment>
              <style>
                <xsl:value-of select="unparsed-text($href)"/>
              </style>
            </xsl:when>
            <xsl:otherwise>
              <xsl:comment>
              <xsl:text>CSS not available </xsl:text>
              <xsl:value-of select="$href"/>
            </xsl:comment>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$html:css-method eq 'absolute'">
        <xsl:for-each select="$html:css">
          <link rel="stylesheet" type="text/css" href="{resolve-uri(., $base-uri)}"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$html:css-method eq 'relative'">
        <xsl:for-each select="$html:css">
          <link rel="stylesheet" type="text/css" href="{.}"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          <xsl:text>ERROR: invalid value for parameter html:css-method: </xsl:text>
          <xsl:value-of select="$html:css-method"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="html:additional-css"/>
  </xsl:template>

  <xsl:template name="html:additional-css" visibility="public"/>

  <xsl:template name="html:js">
    <xsl:variable name="base-uri" select="base-uri()"/>
    <xsl:choose>
      <xsl:when test="$html:js-method eq 'internal'">
        <xsl:for-each select="$html:js">
          <xsl:variable name="href" select="resolve-uri(., $base-uri)"/>
          <xsl:choose>
            <xsl:when test="unparsed-text-available($href)">
              <xsl:comment>
                <xsl:text>CSS from </xsl:text>
                <xsl:value-of select="$href"/>
              </xsl:comment>
              <script>
                <xsl:value-of select="unparsed-text($href)"/>
              </script>
            </xsl:when>
            <xsl:otherwise>
              <xsl:comment>
              <xsl:text>JS not available </xsl:text>
              <xsl:value-of select="$href"/>
            </xsl:comment>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$html:js-method eq 'absolute'">
        <xsl:for-each select="$html:js">
          <link rel="stylesheet" type="text/css" href="{resolve-uri(., $base-uri)}"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$html:js-method eq 'relative'">
        <xsl:for-each select="$html:js">
          <link rel="stylesheet" type="text/css" href="{.}"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          <xsl:text>ERROR: invalid value for parameter html:css-method: </xsl:text>
          <xsl:value-of select="$html:js-method"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="html:additional-js"/>
  </xsl:template>

  <xsl:template name="html:additional-js" visibility="public"/>

  <xsl:template name="html:after-body-js" visibility="public">
    <!-- javascript after the body is always internalized -->
    <xsl:variable name="base-uri" select="base-uri()"/>
    <xsl:for-each select="$html:after-body-js">
      <xsl:variable name="href" select="resolve-uri(., $base-uri)"/>
      <xsl:choose>
        <xsl:when test="unparsed-text-available($href)">
          <xsl:comment>
                <xsl:text>JS from </xsl:text>
                <xsl:value-of select="$href"/>
              </xsl:comment>
          <script>
            <xsl:value-of select="unparsed-text($href)"/>
          </script>
        </xsl:when>
        <xsl:otherwise>
          <xsl:comment>
              <xsl:text>JS not available </xsl:text>
              <xsl:value-of select="$href"/>
            </xsl:comment>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    <!-- let's set this up for cosumation in an iframe -->
    <xsl:variable name="message-body" as="map(xs:string, item()*)">
      <xsl:map>
        <xsl:map-entry key="'doc-origin'" select="base-uri()"/>
        <xsl:map-entry key="'filename'" select="(base-uri() => tokenize('/'))[last()]"/>
      </xsl:map>
    </xsl:variable>
    <script>
      <!-- We set up notification of the scroll position in an iframe using the postMessage channel.
        Cf. https://davidwalsh.name/window-iframe -->
      <xsl:text>// a map for identifying the document&lb;var msg = </xsl:text>
      <xsl:value-of
        select="$message-body => serialize(map {'method': 'json', 'use-character-maps' : map { '/' : '/' }})"/>
      <xsl:text>;&lb;</xsl:text>
      <xsl:text>
  // set up an event handler for scroll events, it simply calls notifyScrolled()
  var scrollTimeout = null;
  window.onscroll = function(){
    if (scrollTimeout) clearTimeout(scrollTimeout);
    scrollTimeout = setTimeout(notifyScrolled,250);
  };

  // get all divs and their Y positions
  var divs;
  var divsY;
  window.onload = function() {
    divs = Array.from(document.querySelectorAll('div'));
    divsY = divs.map(d => d.offsetTop);
    notifyScrolled();
  }
  
  function notifyScrolled() {
    console.log("scrolled");
    var y = window.scrollY;
    // get the first div that is visible
    for (i=0; i &lt; divs.length; i++) {
      if (divsY[i] &gt;= y &amp;&amp; divs[i].id != "") {
        console.log("scrolled to " + i + "th div: " + divs[i].id);
        // pass a message using the postMessage channel, cf. https://davidwalsh.name/window-iframe
        parent.postMessage({ ...msg, 'event': 'scrolled', 'top': divs[i].id }, window.location.protocol + window.location.host);
        break;
      }
    }
  }
  
  window.onmessage = notifySyncScroll;

  function notifySyncScroll(e) {
    console.log("filtering event from notifySync");
    if (e.data?.event == "sync" &amp;&amp; e.data?.source != msg.filename) {
      var newPos =  makeScrollTarget(e.data?.position);
      console.log("performing a sync for " + msg.filename + " aka " + e.data?.source + ", scrolling to: " + newPos);
      location.href = "#"; // bug fix for webkit
      location.href = "#" + newPos;
    }
  }
      </xsl:text>
    </script>
    <xsl:call-template name="html:scroll-target"/>
    <xsl:call-template name="html:after-body-additional-js"/>
  </xsl:template>

  <xsl:template name="html:scroll-target">
    <xsl:variable name="base-uri" select="base-uri()"/>
    <xsl:choose>
      <xsl:when test="$html:scroll-target-method eq 'internal'">
        <xsl:for-each select="$html:scroll-target">
          <xsl:variable name="href" select="resolve-uri(., $base-uri)"/>
          <xsl:choose>
            <xsl:when test="unparsed-text-available($href)">
              <xsl:comment>
                <xsl:text>JS from </xsl:text>
                <xsl:value-of select="$href"/>
              </xsl:comment>
              <script>
                <xsl:value-of select="unparsed-text($href)"/>
              </script>
            </xsl:when>
            <xsl:otherwise>
              <xsl:comment>
              <xsl:text>JS not available </xsl:text>
              <xsl:value-of select="$href"/>
            </xsl:comment>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$html:scroll-target-method eq 'absolute'">
        <xsl:for-each select="$html:scroll-target">
          <link rel="stylesheet" type="text/css" href="{resolve-uri(., $base-uri)}"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$html:scroll-target-method eq 'relative'">
        <xsl:for-each select="$html:scroll-target">
          <link rel="stylesheet" type="text/css" href="{.}"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="yes">
          <xsl:text>ERROR: invalid value for parameter html:css-method: </xsl:text>
          <xsl:value-of select="$html:scroll-target-method"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="html:after-body-additional-js" visibility="public"/>

  <xsl:template name="html:last-in-head-hook" visibility="public"/>

  <xsl:template name="html:content" visibility="public"/>

  <xsl:template name="html:first-in-body-hook" visibility="public"/>
  <xsl:template name="html:last-in-body-hook" visibility="public"/>

  <xsl:template name="html:after-body-hook" visibility="public"/>

  <xsl:template name="html:xi-warning" visibility="final">
    <xsl:param name="include-element" as="element()"/>
    <xsl:text>WARNING: </xsl:text>
    <xsl:text>XInclude element not expanded! @href="</xsl:text>
    <xsl:value-of select="$include-element/@href"/>
    <xsl:text>" @xpointer="</xsl:text>
    <xsl:value-of select="$include-element/@xpointer"/>
    <xsl:text>"</xsl:text>
  </xsl:template>

</xsl:package>