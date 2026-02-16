<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:eg="http://www.tei-c.org/ns/Examples"
    xml:t="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all" version="3.0">

    <xsl:output method="xml" indent="true"/>

    <xsl:param name="outdir" as="xs:string" select="resolve-uri('examples/', static-base-uri())"/>

    <!-- project directory URI -->
    <xsl:param name="pdu" as="xs:string" select="resolve-uri('..', static-base-uri())"/>

    <xsl:param name="saxon-config" as="xs:string" select="'saxon.he.xml'"/>

    <xsl:param name="default-app-info" as="element(appInfo)" select="id('diplomatic-render')"/>

    <xsl:template match="document-node()">
        <xsl:call-template name="examples"/>
        <xsl:call-template name="ant-build-file"/>
    </xsl:template>


    <!-- output examples to separate result-documents -->
    <xsl:template name="examples">
        <xsl:context-item as="document-node(element(TEI))" use="required"/>
        <xsl:for-each select="/TEI/text/body//eg:egXML">
            <xsl:result-document href="{resolve-uri(@xml:id, $outdir)}.xml"
                exclude-result-prefixes="#all" indent="no">
                <xsl:choose>
                    <xsl:when test="@source">
                        <xsl:apply-templates mode="wrap" select="substring(@source, 2) => id()">
                            <xsl:with-param name="slotted-children" as="node()*" select="node()"
                                tunnel="true"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates mode="example" select="node()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>

    <!-- mode for outputting part of a result-document containing the wrapping doc -->
    <xsl:mode name="wrap" on-no-match="shallow-copy"/>

    <!-- mode for outputting part of a result-document containing the example -->
    <xsl:mode name="example" on-no-match="shallow-copy"/>

    <!-- change namespace from example to tei -->
    <xsl:template mode="wrap example" match="eg:*">
        <xsl:element name="{local-name()}" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates mode="#current" select="node() | @*"/>
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


    <xsl:template name="ant-build-file">
        <project basedir="." name="transform-examples" default="transform">

            <property name="pdu" value=".."/>
            <property name="outdir" value="examples"/>


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

    <xsl:template mode="antcall target" match="back"/>

    <xsl:template mode="antcall" match="eg:egXML[@xml:id]">
        <xsl:choose>
            <xsl:when test="@rendition">
                <xsl:variable name="context" as="element(eg:egXML)" select="."/>
                <xsl:for-each select="tokenize(@rendition)">
                    <antcall target="{$context/@xml:id}_{substring(., 2)}"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <antcall target="{@xml:id}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:mode name="target" on-no-match="shallow-skip"/>

    <xsl:template mode="target" match="eg:egXML[@xml:id]">
        <xsl:variable name="context" as="element(eg:egXML)" select="."/>
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
                <target target="{@xml:id}">
                    <xsl:call-template name="xslt-target">
                        <xsl:with-param name="example" as="element(eg:egXML)" select="$context"/>
                    </xsl:call-template>
                </target>
            </xsl:otherwise>
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
                    value="${{pdu}}/{$saxon-config}"/>
            </factory>
            <xsl:apply-templates mode="xslt-target-parameters" select="$rendition">
                <xsl:with-param name="stylesheet" as="xs:anyURI"
                    select="resolve-uri($rendition/@source, $pdu)" tunnel="true"/>
            </xsl:apply-templates>
        </xslt>
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


</xsl:stylesheet>
