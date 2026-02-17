<?xml version="1.0" encoding="UTF-8"?>
<!-- 

USAGE:

generate examples only:

target/bin/xslt.sh -xsl:doc/crystals.xsl -s:doc/crystals.xml -it:examples

generate Apache Ant build file:

target/bin/xslt.sh -xsl:doc/crystals.xsl -s:doc/crystals.xml -it:ant-build-file \!method=xml \!indent=true

generate HTML overview:

target/bin/xslt.sh -xsl:doc/crystals.xsl -s:doc/crystals.xml -it:overview-html

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:eg="http://www.tei-c.org/ns/Examples"
    xmlns:t="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all" version="3.0">

    <xsl:output method="html" indent="false"/>

    <xsl:param name="outdir" as="xs:string" select="resolve-uri('examples/', static-base-uri())"/>

    <!-- project directory URI -->
    <xsl:param name="pdu" as="xs:string" select="resolve-uri('..', static-base-uri())"/>

    <xsl:param name="saxon-config" as="xs:string" select="'saxon.he.xml'"/>

    <xsl:param name="default-app-info" as="element(appInfo)" select="id('diplomatic-render')"/>

    <xsl:template match="document-node()">
        <xsl:call-template name="examples"/>

    </xsl:template>


    <!-- entry point: output examples into separate result-documents -->
    <xsl:template name="examples">
        <xsl:context-item as="document-node(element(TEI))" use="required"/>
        <xsl:for-each select="/TEI/text/body//eg:egXML">
            <xsl:variable name="base-indent" as="xs:integer">
                <xsl:analyze-string select="text()[1]" regex="&#xa;(\s*)">
                    <xsl:matching-substring>
                        <xsl:sequence select="regex-group(1) => string-length()"/>
                    </xsl:matching-substring>
                    <xsl:fallback>
                        <xsl:sequence select="0"/>
                    </xsl:fallback>
                </xsl:analyze-string>
            </xsl:variable>
            <xsl:message>
                <xsl:text>indentation</xsl:text>
                <xsl:value-of select="$base-indent"/>
            </xsl:message>
            <!-- the wrapped crystal goes into ID.xml -->
            <xsl:result-document href="{resolve-uri(@xml:id, $outdir)}.xml"
                exclude-result-prefixes="#all" indent="no" method="xml">
                <xsl:choose>
                    <xsl:when test="@source">
                        <xsl:apply-templates mode="wrap" select="substring(@source, 2) => id()">
                            <xsl:with-param name="slotted-children" as="node()*" select="node()"
                                tunnel="true"/>
                            <xsl:with-param name="base-indentation" as="xs:integer"
                                select="$base-indent"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="example" select="node()">
                            <xsl:with-param name="base-indentation" as="xs:integer"
                                select="$base-indent"/>
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:result-document>
            <!--
                The crystal with eg:egXML wrapper goes into ID.crystal.xml which
                is used for generating a view on the XML source.
                The wrapper is required to make the result document wellformed and
                will be invisible.
            -->
            <xsl:result-document href="{resolve-uri(@xml:id, $outdir)}.crystal.xml"
                exclude-result-prefixes="#all" indent="no" method="xml" omit-xml-declaration="true">
                <xsl:copy>
                    <xsl:apply-templates mode="source" select="node()">
                        <xsl:with-param name="base-indentation" as="xs:integer"
                            select="$base-indent"/>
                    </xsl:apply-templates>
                </xsl:copy>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>

    <!-- mode for outputting part of a result-document containing the wrapping doc -->
    <xsl:mode name="wrap" on-no-match="shallow-copy"/>

    <!-- mode for outputting part of a result-document containing the example -->
    <xsl:mode name="example" on-no-match="shallow-copy"/>

    <!-- mode for outputting the source code -->
    <xsl:mode name="source" on-no-match="shallow-copy"/>

    <!-- change namespace from example to tei -->
    <xsl:template mode="wrap example" match="eg:*">
        <xsl:param name="slotted-children" as="node()*" tunnel="true"/>
        <xsl:variable name="lname" as="xs:string" select="local-name(.)"/>
        <!-- change namesapce -->
        <xsl:element name="{local-name()}" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates mode="#current" select="node() | @*"/>
            <!-- add slotted children -->
            <xsl:for-each select="$slotted-children/self::*[@slot eq $lname]">
                <xsl:text>&#xa;</xsl:text>
                <xsl:apply-templates mode="#current" select=".">
                    <xsl:with-param name="slotted-children" select="()"/>
                </xsl:apply-templates>
                <xsl:text>&#xa;</xsl:text>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>

    <xsl:template mode="wrap" match="eg:egXML">
        <xsl:apply-templates mode="wrap"/>
    </xsl:template>

    <xsl:template mode="wrap" match="*[@n eq 'slot']">
        <xsl:param name="slotted-children" as="node()*" tunnel="true"/>
        <xsl:element name="{local-name()}" namespace="http://www.tei-c.org/ns/1.0"
            exclude-result-prefixes="#all">
            <xsl:apply-templates mode="wrap" select="@*"/>
            <xsl:apply-templates mode="example" select="$slotted-children"/>
        </xsl:element>
    </xsl:template>

    <!-- drop elements that have to go into a slot -->
    <xsl:template mode="example" match="*[@slot]" priority="100"/>

    <!-- drop @slot from source view -->
    <xsl:template mode="source" match="@slot"/>

    <!-- this removes the base indentation -->
    <xsl:template mode="example source" match="text()">
        <xsl:analyze-string select="." regex="&#xa;\s{{1,12}}">
            <xsl:matching-substring>
                <xsl:text>&#xa;</xsl:text>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>



    <!-- entry point for generating an Apache Ant build file -->
    <xsl:template name="ant-build-file">
        <project basedir="." name="docs" default="transform">

            <dirname property="docs.basedir" file="${{ant.file.docs}}"/>
            <property name="pdu" value="${{docs.basedir}}/.."/>
            <property name="outdir" value="${{docs.basedir}}/examples"/>


            <path id="project.class.path">
                <fileset dir="${{pdu}}/target/lib/">
                    <include name="*.jar"/>
                </fileset>
            </path>

            <!-- default target -->
            <target name="transform">
                <xsl:apply-templates mode="antcall"/>
            </target>

            <target name="clean-transformed">
                <delete dir="${{outdir}}" includes="**/*.html,**/*.tex"/>
            </target>

            <xsl:apply-templates mode="target"/>

        </project>
    </xsl:template>

    <xsl:mode name="antcall" on-no-match="shallow-skip"/>

    <!-- drop everything in back matter -->
    <xsl:template mode="antcall target html" match="back"/>

    <xsl:template mode="antcall" match="eg:egXML[@xml:id]">
        <xsl:choose>
            <xsl:when test="@rendition">
                <xsl:variable name="context" as="element(eg:egXML)" select="."/>
                <xsl:for-each select="tokenize(@rendition)">
                    <antcall target="{$context/@xml:id}_{substring(., 2)}"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <!--antcall target="{@xml:id}"/-->
            </xsl:otherwise>
        </xsl:choose>
        <!-- allways make a generic HTML representation of the crystal -->
        <antcall target="{@xml:id}.crystal.html"/>
    </xsl:template>


    <xsl:mode name="target" on-no-match="shallow-skip"/>

    <xsl:template mode="target" match="eg:egXML[@xml:id]">
        <xsl:variable name="context" as="element(eg:egXML)" select="."/>
        <xsl:call-template name="ant-target-crystal"/>
        <xsl:choose>
            <xsl:when test="@rendition">
                <xsl:for-each select="tokenize(@rendition)">
                    <xsl:variable name="rendition" as="xs:string" select="substring(., 2)"/>
                    <target name="{$context/@xml:id}_{$rendition}">
                        <xsl:call-template name="xslt-target">
                            <xsl:with-param name="example" as="element(eg:egXML)" select="$context"/>
                            <xsl:with-param name="rendition" as="element(appInfo)"
                                select="id($rendition, root($context))"/>
                        </xsl:call-template>
                    </target>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <!--target name="{@xml:id}">
                    <xsl:call-template name="xslt-target">
                        <xsl:with-param name="example" as="element(eg:egXML)" select="$context"/>
                    </xsl:call-template>
                </target-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="ant-target-crystal">
        <xsl:context-item as="element(eg:egXML)" use="required"/>
        <target name="{@xml:id}.crystal.html">
            <xslt>
                <xsl:attribute name="classpathref">project.class.path</xsl:attribute>
                <xsl:attribute name="style" select="'${pdu}/xsl/html/xml-source.xsl'"/>
                <xsl:attribute name="in" select="'${outdir}/' || @xml:id || '.crystal.xml'"/>
                <xsl:attribute name="out" select="'${outdir}/' || @xml:id || '.crystal.html'"/>
                <factory name="net.sf.saxon.TransformerFactoryImpl">
                    <attribute name="http://saxon.sf.net/feature/configuration-file"
                        value="${{pdu}}/{$saxon-config}"/>
                </factory>
                <xsl:call-template name="post-size-js"/>
            </xslt>
        </target>
    </xsl:template>

    <xsl:template name="xslt-target">
        <xsl:param name="example" as="element(eg:egXML)"/>
        <xsl:param name="rendition" as="element(appInfo)" required="false"
            select="$default-app-info"/>
        <xslt>
            <xsl:attribute name="classpathref">project.class.path</xsl:attribute>
            <xsl:attribute name="style" select="'${pdu}/' || $rendition/@source"/>
            <xsl:attribute name="in" select="'${outdir}/' || $example/@xml:id || '.xml'"/>
            <xsl:attribute name="out"
                select="'${outdir}/' || $example/@xml:id || '_' || $rendition/@xml:id || '.' || $rendition/@n"/>
            <factory name="net.sf.saxon.TransformerFactoryImpl">
                <attribute name="http://saxon.sf.net/feature/configuration-file"
                    value="${{pdu}}/{$saxon-config}"/>
            </factory>
            <xsl:call-template name="post-size-js"/>
            <xsl:apply-templates mode="xslt-target-parameters" select="$rendition">
                <xsl:with-param name="stylesheet" as="xs:anyURI"
                    select="resolve-uri($rendition/@source, $pdu)" tunnel="true"/>
            </xsl:apply-templates>
        </xslt>
    </xsl:template>

    <xsl:template name="post-size-js">
        <param name="{{http://scdh.wwu.de/transform/html#}}after-body-js"
            expression="${{docs.basedir}}/post-size.js"/>
    </xsl:template>

    <xsl:mode name="xslt-target-parameters" on-no-match="shallow-skip"/>

    <xsl:template mode="xslt-target-parameters" match="application">
        <param>
            <xsl:attribute name="name">
                <xsl:call-template name="xslt-target-parameter-name"/>
            </xsl:attribute>
            <xsl:attribute name="expression" select="@n"/>
        </param>
    </xsl:template>

    <!-- convention for no parameter -->
    <xsl:template mode="xslt-target-parameters" match="application[@ident eq '_']"/>

    <xsl:variable name="prefixed-name" as="xs:string" select="'([a-zA-Z_][a-zA-Z0-9_-]*):(.*)'"/>

    <xsl:template name="xslt-target-parameter-name">
        <xsl:context-item as="element(application)" use="required"/>
        <xsl:param name="stylesheet" as="xs:anyURI" tunnel="true"/>
        <xsl:choose>
            <xsl:when test="matches(@ident, $prefixed-name)">
                <xsl:value-of>
                    <xsl:text>{</xsl:text>
                    <xsl:apply-templates mode="namespace-for-prefix" select="doc($stylesheet)">
                        <xsl:with-param name="prefix" as="xs:string"
                            select="replace(@ident, $prefixed-name, '$1')" tunnel="true"/>
                    </xsl:apply-templates>
                    <xsl:text>}</xsl:text>
                    <xsl:value-of select="replace(@ident, $prefixed-name, '$2')"/>
                </xsl:value-of>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@ident"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:mode name="namespace-for-prefix" on-no-match="shallow-skip"/>

    <xsl:template mode="namespace-for-prefix" match="xsl:stylesheet | xsl:package">
        <xsl:param name="prefix" as="xs:string" tunnel="true"/>
        <xsl:variable name="context" select="."/>
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>looking for prefix '</xsl:text>
            <xsl:value-of select="$prefix"/>
            <xsl:text>' in </xsl:text>
            <xsl:value-of select="base-uri(.)"/>
        </xsl:message>
        <xsl:choose>
            <xsl:when test="namespace::*[local-name(.) eq $prefix]">
                <xsl:value-of select="namespace::*[local-name(.) eq $prefix]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:iterate select="xsl:use-package | xsl:import | xsl:include">
                    <xsl:param name="found" as="item()*" select="()"/>
                    <xsl:on-completion>
                        <xsl:message use-when="system-property('debug') eq 'true'">
                            <xsl:text>prefix '</xsl:text>
                            <xsl:value-of select="$prefix"/>
                            <xsl:text>' neither found in </xsl:text>
                            <xsl:value-of select="base-uri($context)"/>
                            <xsl:text> nor in one of its imports</xsl:text>
                        </xsl:message>
                    </xsl:on-completion>
                    <xsl:choose>
                        <xsl:when test="$found">
                            <xsl:break select="$found[1]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:next-iteration>
                                <xsl:with-param name="found" as="item()*">
                                    <xsl:apply-templates mode="namespace-for-prefix" select="."/>
                                </xsl:with-param>
                            </xsl:next-iteration>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:iterate>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="namespace-for-prefix" match="xsl:import | xsl:include">
        <xsl:apply-templates mode="namespace-for-prefix"
            select="doc(resolve-uri(@href, base-uri(.)))"/>
    </xsl:template>

    <xsl:template mode="namespace-for-prefix" match="xsl:use-package">
        <xsl:variable name="saxon-config" as="node()" select="doc(resolve-uri($saxon-config, $pdu))"/>
        <xsl:variable name="name" as="xs:string" select="@name"/>
        <xsl:variable name="version" as="xs:string" select="@package-version"/>
        <xsl:variable name="package-configuration" as="element()?"
            select="$saxon-config//*:xsltPackages/*:package[@name eq $name and @version eq $version][1]"/>
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>looking for prefix in package </xsl:text>
            <xsl:value-of select="$name || ':' || $version"/>
            <xsl:text> in file </xsl:text>
            <xsl:value-of select="$package-configuration/@sourceLocation"/>
        </xsl:message>
        <xsl:if test="$package-configuration">
            <xsl:apply-templates mode="namespace-for-prefix"
                select="resolve-uri($package-configuration/@sourceLocation, base-uri($package-configuration)) => doc()"
            />
        </xsl:if>
    </xsl:template>



    <xsl:template name="overview-html">
        <html>
            <head>
                <title>
                    <xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title"/>
                </title>
                <link rel="stylesheet" href="crystal.css"/>
                <xsl:call-template name="resize-iframes"/>
            </head>
            <body>
                <div class="content">
                    <div class="content-wrapper">
                        <xsl:apply-templates mode="html">
                            <xsl:with-param name="level" as="xs:integer" select="0" tunnel="true"/>
                        </xsl:apply-templates>
                    </div>
                </div>
            </body>
        </html>
    </xsl:template>

    <xsl:template name="resize-iframes">
        <script type="application/javascript">
            <!--
            xsl: text >
            window.addEventListener('message', (event) => {
                console.log("message received", event.target);
            }); < / xsl: text////-->
            <xsl:value-of select="unparsed-text(resolve-uri('resizer.js', static-base-uri()))"/>
        </script>
    </xsl:template>

    <xsl:mode name="html" on-no-match="shallow-skip"/>

    <xsl:template mode="html" match="teiHeader"/>

    <xsl:template mode="html" match="div">
        <xsl:param name="level" as="xs:integer" tunnel="true"/>
        <section>
            <xsl:apply-templates mode="#current" select="@* | node()">
                <xsl:with-param name="level" as="xs:integer" select="$level + 1" tunnel="true"/>
            </xsl:apply-templates>
        </section>
    </xsl:template>

    <xsl:template mode="html" match="head">
        <xsl:param name="level" as="xs:integer" tunnel="true"/>
        <!--xsl:variable name="level" as="xs:integer" select="count(ancestor::div) + 1"/-->
        <xsl:element name="h{$level}">
            <xsl:apply-templates mode="#current" select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template mode="html" match="text()">
        <xsl:copy/>
    </xsl:template>

    <xsl:template mode="html" match="eg:egXML">
        <xsl:variable name="example" as="element(eg:egXML)" select="."/>

        <iframe src="examples/{@xml:id}.crystal.html"
            onload="javascript:registerIFrameResizer(this)"/>

        <xsl:for-each select="tokenize(@rendition) ! substring(., 2) ! id(., $example)">
            <xsl:apply-templates mode="html" select=".">
                <xsl:with-param name="example" as="element(eg:egXML)" select="$example"
                    tunnel="true"/>
            </xsl:apply-templates>
        </xsl:for-each>

    </xsl:template>

    <xsl:template mode="html" match="appInfo">
        <xsl:param name="level" as="xs:integer" tunnel="true"/>
        <xsl:param name="example" as="element(eg:egXML)" tunnel="true"/>
        <section class="transformation">
            <xsl:element name="h{$level + 1}">
                <xsl:value-of select="descendant::desc[1]"/>
                <xsl:text> (</xsl:text>
                <xsl:value-of select="@n"/>
                <xsl:text>)</xsl:text>
            </xsl:element>
            <iframe class="transformation-result {@n}-transformation"
                src="examples/{$example/@xml:id}_{@xml:id}.html"
                onload="javascript:registerIFrameResizer(this)"/>
            <section class="stylesheet">
                <xsl:element name="h{$level + 2}">stylesheet / package</xsl:element>
                <pre><xsl:value-of select="@source"/></pre>
            </section>
            <section class="parameters">
                <xsl:element name="h{$level + 2}">parameters</xsl:element>
                <table>
                    <thead>
                        <th>local name</th>
                        <th>prefix</th>
                        <th>namespace</th>
                        <th>value</th>
                        <th>type</th>
                    </thead>
                    <tbody>
                        <xsl:apply-templates mode="html" select="application"/>
                    </tbody>
                </table>
            </section>
            <section>
                <xsl:element name="h{$level + 2}">Ant target</xsl:element>
                <pre>
                    <target name="...">
                       <xsl:call-template name="xslt-target">
                           <xsl:with-param name="example" select="$example"/>
                           <xsl:with-param name="rendition" select="."/>
                       </xsl:call-template>
                    </target>
                </pre>
            </section>
        </section>
    </xsl:template>

    <xsl:template mode="html" match="application">
        <xsl:choose>
            <xsl:when test="matches(@ident, '^_$')"/>
            <xsl:when test="matches(@ident, $prefixed-name)">
                <xsl:variable name="lname" select="replace(@ident, $prefixed-name, '$2')"/>
                <xsl:variable name="prefix" select="replace(@ident, $prefixed-name, '$1')"/>
                <tr>
                    <td>
                        <pre><xsl:value-of select="$lname"/></pre>
                    </td>
                    <td>
                        <pre><xsl:value-of select="$prefix"/></pre>
                    </td>
                    <td>
                        <pre><xsl:apply-templates mode="namespace-for-prefix" select="parent::appInfo/@source => resolve-uri($pdu) => doc()">
                            <xsl:with-param name="prefix" as="xs:string" select="$prefix" tunnel="true"/>
                        </xsl:apply-templates></pre>
                    </td>
                    <td>
                        <pre><xsl:value-of select="@n"/></pre>
                    </td>
                    <td>runtime</td>
                </tr>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="html" match="gi">
        <span class="element">
            <span class="angle-brackets">
                <xsl:text>&lt;</xsl:text>
            </span>
            <span class="element-name">
                <xsl:apply-templates mode="#current" select="@* | node()"/>
            </span>
            <span class="angle-brackets">
                <xsl:text>&gt;</xsl:text>
            </span>
        </span>
    </xsl:template>

    <xsl:template mode="html" match="att">
        <span class="attribute">
            <span class="attribute-at">
                <xsl:text>@</xsl:text>
            </span>
            <span class="attribute-name">
                <xsl:apply-templates mode="#current" select="@* | node()"/>
            </span>
        </span>
    </xsl:template>

    <xsl:template mode="html" match="val">
        <span class="value">
            <span class="quotes">
                <xsl:text>&quot;</xsl:text>
            </span>
            <span class="value">
                <xsl:apply-templates mode="#current" select="@* | node()"/>
            </span>
            <span class="quotes">
                <xsl:text>&quot;</xsl:text>
            </span>
        </span>
    </xsl:template>
    <xsl:template mode="html" match="p">
        <p>
            <xsl:apply-templates mode="#current" select="@* | node()"/>
        </p>
    </xsl:template>

    <xsl:template mode="html" match="hi">
        <xsl:element name="{@rend}">
            <xsl:apply-templates mode="#current" select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template mode="html" match="code">
        <code>
            <xsl:apply-templates mode="#current" select="@* | node()"/>
        </code>
    </xsl:template>

    <xsl:template mode="html" match="ref">
        <a href="{@target}">
            <xsl:apply-templates mode="#current"/>
        </a>
    </xsl:template>

    <xsl:template mode="html" match="ptr">
        <a href="{@target}">
            <xsl:value-of select="@target"/>
        </a>
    </xsl:template>



</xsl:stylesheet>
