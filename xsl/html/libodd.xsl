<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT for making project documentations based on an ODD

This transformation transforms the descriptive part of an ODD into an HTML documentation.
When the $odd:transform switch is turned on, each egXML code snipped with one or more
declared transformations is followed by an iframe with the transformation results.
This feature make this XSLT perfect for documentation which encoding crystals are supported
by a transformation and how the result looks like.

USAGE:

generate HTML representation of ODD

target/bin/xslt.sh -config:saxon.he.html.xml -xsl:xsl/html/libodd.xsl -s:doc/crystals.xml


generate examples only:

target/bin/xslt.sh -config:saxon.he.html.xml -xsl:xsl/html/libodd.xsl -s:doc/crystals.xml -it:examples


generate Apache Ant build file from an ODD:

target/bin/xslt.sh -config:saxon.he.html.xml -xsl:xsl/html/libodd.xsl -s:doc/crystals.xml -it:ant-build-file \!method=xml \!indent=true


generate an Apache Ant build file importing all other Apache Ant build files:

target/bin/xslt.sh -config:saxon.he.xml -xsl:xsl/html/libodd.xsl -it:importing-ant-build-file odd-dir=$(realpath doc) \!method=xml \!indent=true

-->
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libodd.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:eg="http://www.tei-c.org/ns/Examples"
    xmlns:i18n="http://scdh.wwu.de/transform/i18n#" xmlns:text="http://scdh.wwu.de/transform/text#"
    xmlns:html="http://scdh.wwu.de/transform/html#" xmlns:odd="http://scdh.wwu.de/transform/odd#"
    xmlns:source="http://scdh.wwu.de/transform/source#" xmlns:ox="http://scdh.wwu.de/transform/ox#"
    xmlns:ref="http://scdh.wwu.de/transform/ref#" xmlns:t="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    version="3.0" default-mode="odd:documentation">

    <xsl:output method="html" indent="false"/>

    <!-- path of outdir relative to the source file, defaults to the source's basename without extension -->
    <xsl:param name="outdir-rel" as="xs:string"
        select="(base-uri(.) => tokenize('/'))[last()] => replace('\.[^\.]*$', '')"/>

    <!-- outdir is based on an odd -->
    <xsl:param name="outdir" as="xs:string"
        select="resolve-uri(concat($outdir-rel, '/'), base-uri())"/>

    <!-- project directory URI -->
    <xsl:param name="pdu" as="xs:string" select="resolve-uri('../..', static-base-uri())"/>

    <!-- link to property file, relative to pdu -->
    <xsl:param name="properties" as="xs:string" select="'project.properties'"/>

    <xsl:param name="saxon-config" as="xs:string" select="resolve-uri('saxon.he.xml', $pdu)"/>

    <xsl:param name="default-app-info" as="element(appInfo)" select="id('diplomatic-render')"/>

    <!-- whether to use the HTML template from libhtml and make a full HTML file -->
    <xsl:param name="odd:transform" as="xs:boolean" select="true()"/>

    <!-- path to directory containing documentation ODDs, only required for template named 'importing-ant-build-file' -->
    <xsl:param name="odd-dir" as="xs:string" select="''"/>

    <!-- directory collection of ODDs, only required for template named 'importing-ant-build-file' -->
    <xsl:param name="odd-collection" as="xs:string" select="$odd-dir || '?select=*.odd'"/>

    <!-- suffix of generated Ant build files per ODD, only required for template named 'importing-ant-build-file' -->
    <xsl:param name="odd:build-suffix" as="xs:string" select="'-build.xml'"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libox.xsl"
        package-version="1.0.0"/>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libref.xsl"
        package-version="1.0.0"/>


    <xsl:mode name="odd:documentation" on-no-match="shallow-skip" visibility="public"/>

    <!-- if parameter $use-libhtml is true, switch to html:html mode -->
    <xsl:template match="/" mode="odd:documentation">
        <xsl:choose>
            <xsl:when test="$use-libhtml">
                <xsl:apply-templates mode="html:html" select="root()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="text:text" select="//body">
                    <xsl:with-param name="base-indentation" as="xs:integer" select="0" tunnel="true"
                    />
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libhtml.xsl"
        package-version="1.0.0">
        <xsl:accept component="mode" names="html:html" visibility="public"/>
        <xsl:accept component="template" names="html:*" visibility="public"/>
        <xsl:override>

            <xsl:template name="html:content">
                <xsl:apply-templates mode="text:text"/>
            </xsl:template>

            <xsl:param name="html:default-css" as="xs:anyURI?"
                select="resolve-uri('documentation.css', static-base-uri())"/>

            <xsl:param name="html:js" as="xs:string*"
                select="resolve-uri('resizer.js', static-base-uri())"/>

        </xsl:override>
    </xsl:use-package>

    <xsl:function name="odd:get-indent" as="xs:integer" visibility="final">
        <xsl:param name="context" as="node()"/>
        <xsl:analyze-string select="$context/text()[1]" regex="&#xa;(\s*)">
            <xsl:matching-substring>
                <xsl:sequence select="regex-group(1) => string-length()"/>
            </xsl:matching-substring>
            <xsl:fallback>
                <xsl:sequence select="0"/>
            </xsl:fallback>
        </xsl:analyze-string>
    </xsl:function>


    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libxmlsource.xsl"
        package-version="1.0.0">
        <xsl:override>

            <xsl:template mode="source:source" match="text()">
                <xsl:param name="base-indentation" as="xs:integer" tunnel="true"/>
                <span class="text" style="color:{$source:text-color}">
                    <xsl:analyze-string select="string(.)"
                        regex="&#xa;&#xd;?&#x20;{{0,{$base-indentation}}}(&#x20;*)">
                        <xsl:matching-substring>
                            <br/>
                            <xsl:if test="regex-group(1) => string-length() gt 0">
                                <span class="identation"
                                    style="margin-left:{regex-group(1) => string-length()}em;"/>
                            </xsl:if>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <!--xsl:analyze-string select="." regex="&amp;[^;]+;">
                    <xsl:matching-substring>
                        <span class="entity" style="color:{$source:entity-color}">
                            <xsl:value-of select="."/>
                        </span>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string-->
                            <xsl:value-of select="."/>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </span>
            </xsl:template>

            <xsl:template mode="source:source" match="@slot"/>

        </xsl:override>
    </xsl:use-package>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libprose.xsl"
        package-version="1.0.0">
        <xsl:accept component="mode" names="*" visibility="public"/>
        <xsl:override>

            <xsl:template mode="text:text" match="eg:egXML">
                <xsl:variable name="example" as="element(eg:egXML)" select="."/>
                <!-- render example source with libxmlsource -->
                <div class="xml-source code-example">
                    <xsl:apply-templates mode="source:source">
                        <xsl:with-param name="base-indentation" as="xs:integer"
                            select="odd:get-indent(.)" tunnel="true"/>
                    </xsl:apply-templates>
                </div>
                <!-- output for presentations declared with @ox:transformations -->
                <xsl:if test="$odd:transform">
                    <xsl:for-each
                        select="@ox:transformations ! ref:references-from-attribute(.) ! ox:scenario-by-uri(.)">
                        <xsl:call-template name="ox:transformation-info">
                            <xsl:with-param name="output" as="xs:string">
                                <xsl:value-of
                                    select="$outdir-rel || '/' || $example/@xml:id || '_' || ox:get-field(., 'name') => ox:scenario-identifier() || ox:suffix(.)"
                                />
                            </xsl:with-param>
                            <xsl:with-param name="level" as="xs:integer"
                                select="count($example/ancestor::div) + 1"/>
                        </xsl:call-template>
                    </xsl:for-each>
                    <xsl:for-each select="tokenize(@rendition) ! substring(., 2) ! id(., $example)">
                        <xsl:apply-templates mode="odd:transformation" select=".">
                            <xsl:with-param name="example" as="element(eg:egXML)" select="$example"
                                tunnel="true"/>
                            <xsl:with-param name="level" as="xs:integer"
                                select="count($example/ancestor::div) + 1" tunnel="true"/>
                        </xsl:apply-templates>
                    </xsl:for-each>
                </xsl:if>
            </xsl:template>

            <!-- drop the backmatter where wrapping templates are -->
            <xsl:template mode="text:text" match="back"/>

        </xsl:override>
    </xsl:use-package>


    <!-- a mode for presenting information about a transformation in HTML -->
    <xsl:mode name="odd:transformation" on-no-match="shallow-skip" visibility="public"/>

    <xsl:template mode="odd:transformation" match="appInfo">
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
                src="{$outdir-rel || '/'  || $example/@xml:id || '_' || @xml:id || '.html'}"
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
                        <xsl:apply-templates mode="odd:transformation" select="application"/>
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

    <xsl:template mode="odd:transformation" match="application">
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



    <!-- generating TEI source files from egXML -->

    <!-- entry point: output examples into separate result-documents -->
    <xsl:template name="examples" visibility="public">
        <xsl:context-item as="document-node(element(TEI))" use="required"/>
        <xsl:for-each select="/TEI/text/body//eg:egXML">
            <!-- the wrapped crystal goes into ID.xml -->
            <xsl:result-document href="{resolve-uri(@xml:id, $outdir)}.xml"
                exclude-result-prefixes="#all" indent="no" method="xml">
                <xsl:choose>
                    <xsl:when test="@source">
                        <xsl:apply-templates mode="wrap" select="substring(@source, 2) => id()">
                            <xsl:with-param name="slotted-children" as="node()*" select="node()"
                                tunnel="true"/>
                            <xsl:with-param name="base-indentation" as="xs:integer"
                                select="odd:get-indent(.)"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="example" select="node()">
                            <xsl:with-param name="base-indentation" as="xs:integer"
                                select="odd:get-indent(.)"/>
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
                            select="odd:get-indent(.)"/>
                    </xsl:apply-templates>
                </xsl:copy>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>

    <!-- mode for outputting part of a result-document containing the wrapping doc -->
    <xsl:mode name="wrap" on-no-match="shallow-copy"/>

    <!-- mode for outputting part of a result-document containing the example -->
    <xsl:mode name="example" on-no-match="shallow-copy"/>

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

    <!-- this removes the base indentation -->
    <xsl:template mode="example" match="text()">
        <xsl:analyze-string select="." regex="&#xa;\s{{1,12}}">
            <xsl:matching-substring>
                <xsl:text>&#xa;</xsl:text>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>



    <!-- generate an Apache build file for transforming the extracted examples -->

    <!-- entry point for generating an Apache Ant build file -->
    <xsl:template name="ant-build-file" visibility="public">
        <project basedir="." name="docs" default="transform">

            <dirname property="docs.basedir" file="${{ant.file.docs}}"/>
            <xsl:comment>pdu is the base directory URI of the project with the transformations</xsl:comment>
            <property name="pdu" value="${{docs.basedir}}/.."/>
            <property name="outdir" value="${{docs.basedir}}/{$outdir-rel}"/>
            <property name="seed-tei-transformations" value="${{pdu}}"/>

            <loadproperties srcFile="${{pdu}}/{$properties}"/>

            <property name="saxon-config-" value="${{pdu}}/saxon.he.xml"/>
            <property name="saxon-config-html" value="${{pdu}}/saxon.he.html.xml"/>
            <property name="saxon-config-latex" value="${{pdu}}/saxon.he.xml"/>

            <property name="post-size.js"
                value="${{seed-tei-transformations}}/xsl/html/post-size.js"/>


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
    <xsl:template mode="antcall target odd:transformation" match="back"/>

    <xsl:template mode="antcall" match="eg:egXML[@xml:id]">
        <xsl:choose>
            <xsl:when test="@ox:transformations">
                <xsl:variable name="context" as="element(eg:egXML)" select="."/>
                <xsl:for-each select="ref:references-from-attribute(@ox:transformations)">
                    <xsl:for-each select="tokenize(., '#')[2]">
                        <antcall target="{$context/@xml:id}_{.}"/>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:when>
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
    </xsl:template>


    <xsl:mode name="target" on-no-match="shallow-skip"/>

    <xsl:template mode="target" match="eg:egXML[@xml:id]">
        <xsl:variable name="context" as="element(eg:egXML)" select="."/>
        <xsl:choose>
            <xsl:when test="@ox:transformations">
                <xsl:for-each
                    select="ref:references-from-attribute(@ox:transformations) ! ox:scenario-by-uri(.)">
                    <target
                        name="{$context/@xml:id}_{ox:get-field(., 'name') => ox:scenario-identifier()}">
                        <xsl:call-template name="ox:xslt-target">
                            <xsl:with-param name="example" as="xs:string" select="$context/@xml:id"
                            />
                        </xsl:call-template>
                    </target>
                </xsl:for-each>
            </xsl:when>
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
        </xsl:choose>
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
                    value="${{saxon-config-{$rendition/@n}}}"/>
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
            expression="${{post-size.js}}"/>
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
        <xsl:variable name="saxon-config" as="node()" select="doc($saxon-config)"/>
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



    <!-- entry point for generating an apache Ant build file that imports all build files generated from ODDs -->
    <xsl:template name="importing-ant-build-file" visibility="public">
        <project basedir="." name="documentation" default="transform">
            <!--  ! tokenize(., '/') ! .[last()] -->
            <xsl:variable name="odds" as="xs:string*"
                select="uri-collection($odd-collection) ! tokenize(., '/')[last()]"/>
            <xsl:message>
                <xsl:text>found ODD files: </xsl:text>
                <xsl:value-of select="$odds"/>
            </xsl:message>
            <target name="docs">
                <xsl:for-each select="$odds">
                    <antcall target="{replace(., '\.[^\.]+$', '')}.transform"/>
                </xsl:for-each>
            </target>
            <xsl:for-each select="$odds">
                <import file="{replace(., '\.[^\.]+$', $odd:build-suffix)}"
                    as="{replace(., '\.[^\.]+$', '')}" optional="true"/>
            </xsl:for-each>
        </project>
    </xsl:template>

</xsl:package>
