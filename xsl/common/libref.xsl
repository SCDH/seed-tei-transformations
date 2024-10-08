<?xml version="1.0" encoding="UTF-8"?>
<!-- A generic implementation of processing references.
This includes the expansion of local URIs defined with <prefixDef> and processing the XML Base property.
The suggestion to use the XML Base property either of the occurrence or of the definition context like
proposed on TEI-L on 2022-05-29 is convered in this implementation.
Cf. https://tei-l.markmail.org/thread/eogjsbfing65ubm4

Example usage:

Generate a links for all references given in ptr/@target

    <xsl:template match="tei:ptr[@target]">
        <xsl:for-each select="ref:references-from-attribute(@target)">
            <a href="{.}">
                <xsl:value-of select="."/>
            </a>
        </xsl:for-each>
    </xsl:template>

Generate a link to the bibliography. Only use the first reference in @corresp is used.

    <xsl:template match="tei:bibl[@corresp]">
        <a href="{ref:references-from-attribute(@corresp)[1]}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    
Note, that the function used above requires an attribute as argument, not a string!
The reason: The implementation gets the context from the argument. Strings do not have
any context.
ref:references-from-attribute($attribute as attribute()) as xs:string*
    
The function
ref:dereference($reference as xs:string, $context as node()*) as node()*
can be used to dereference a reference,
i.e. get the document or its fragment referenced. This function should be used
to de-reference references processed with the above function.

Example usage:

ref:references-from-attribute(@target)[1] => ref:dereference()
-->
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libref.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ref="http://scdh.wwu.de/transform/ref#"
    exclude-result-prefixes="xs ref" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0">

    <xsl:expose component="function" names="ref:*" visibility="public"/>

    <!-- whether to handle references starting with the number sign '#' as same-document references -->
    <xsl:param name="is-fragment-same-doc" as="xs:boolean" select="true()"/>

    <!-- same as resolve-uri(), but returns the href if is a fragment identifier -->
    <xsl:function name="ref:resolve-uri-or-fragment" as="xs:string">
        <xsl:param name="href" as="xs:string"/>
        <xsl:param name="base" as="node()"/>
        <xsl:choose>
            <xsl:when test="substring($href, 1, 1) eq '#' and $is-fragment-same-doc">
                <xsl:value-of select="$href"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="resolve-uri($href, base-uri($base))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- Process any type of 'reference' given at context 'occurrence'.
        This expands local URIs as defined in <prefixDef> and
        uses the XML Base property for dealing with relative paths. -->
    <xsl:function name="ref:process-reference" as="xs:string">
        <xsl:param name="reference" as="xs:string"/>
        <xsl:param name="occurrence" as="node()"/>
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>Resolving </xsl:text>
            <xsl:value-of select="$reference"/>
            <xsl:text> in the context of </xsl:text>
            <xsl:value-of select="name($occurrence)"/>
        </xsl:message>
        <xsl:choose>
            <xsl:when test="starts-with($reference, '#') and $is-fragment-same-doc">
                <xsl:value-of select="$reference"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="definitions" as="node()*"
                    select="($occurrence/ancestor-or-self::TEI | (root($occurrence) treat as document-node())/teiCorpus)/teiHeader/encodingDesc/listPrefixDef//prefixDef[matches($reference, concat('^', @ident, ':', @matchPattern))]"/>
                <xsl:message use-when="system-property('debug') eq 'true'">
                    <xsl:text>prefixDef found: </xsl:text>
                    <xsl:value-of select="count($definitions)"/>
                </xsl:message>
                <xsl:choose>
                    <xsl:when test="empty($definitions)">
                        <!-- not a local URI, return without expanding/replacing -->
                        <xsl:value-of select="resolve-uri($reference, base-uri($occurrence))"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- using the first match only. We can assert that it is present, because we are on a branch
                            where $definitions is non-empty. -->
                        <xsl:variable name="definition" as="node()"
                            select="$definitions[1] treat as node()"/>
                        <!-- expand/replace the URI -->
                        <xsl:variable name="href" as="xs:string"
                            select="replace($reference, concat($definition/@ident, ':', $definition/@matchPattern), $definition/@replacementPattern)"/>
                        <xsl:message use-when="system-property('debug') eq 'true'">
                            <xsl:text>Local URI </xsl:text>
                            <xsl:value-of select="$reference"/>
                            <xsl:text> expanded to </xsl:text>
                            <xsl:value-of select="$href"/>
                        </xsl:message>
                        <xsl:choose>
                            <xsl:when test="starts-with($href, '#') and $is-fragment-same-doc">
                                <xsl:value-of select="$href"/>
                            </xsl:when>
                            <!-- get XML Base property of definition or occurrence
                                Cf. https://tei-l.markmail.org/thread/eogjsbfing65ubm4 -->
                            <xsl:when
                                test="$definition/@xml:base or $definition/@relativeFrom eq 'definition'">
                                <xsl:value-of select="resolve-uri($href, base-uri($definition))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="resolve-uri($href, base-uri($occurrence))"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- process all references given in an attribute -->
    <xsl:function name="ref:references-from-attribute" as="xs:string*">
        <xsl:param name="attribute" as="attribute()"/>
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>Processing references form attribute </xsl:text>
            <xsl:value-of select="$attribute/parent::* => name()"/>
            <xsl:text>/@</xsl:text>
            <xsl:value-of select="name($attribute)"/>
        </xsl:message>
        <xsl:for-each select="tokenize($attribute)">
            <xsl:value-of select="ref:process-reference(., $attribute)"/>
        </xsl:for-each>
    </xsl:function>

    <!-- process all references given in an attribute -->
    <xsl:template name="ref:references-from-attribute" as="xs:string*">
        <xsl:param name="attribute" as="attribute()"/>
        <xsl:sequence select="ref:references-from-attribute($attribute)"/>
    </xsl:template>



    <!-- Dereference any given 'reference' in 'context'.
        The 'reference' is expected to be either a absolute path / URI with
        optional fragment identifier, or a same-doc reference.
        The context is necessary to dereference same-doc references.
        If the reference contains a fragment identifier, the fragment is returned. -->
    <xsl:function name="ref:dereference" as="node()*">
        <xsl:param name="reference" as="xs:string"/>
        <xsl:param name="context" as="node()"/>
        <xsl:variable name="tokens" as="xs:string*" select="tokenize($reference, '#')"/>
        <xsl:choose>
            <xsl:when test="count($tokens) eq 1">
                <xsl:sequence select="doc($tokens[1])"/>
            </xsl:when>
            <xsl:when test="$tokens[1] eq ''">
                <xsl:sequence
                    select="(root($context) treat as document-node())//*[@xml:id eq $tokens[2]]"/>
            </xsl:when>
            <xsl:when test="doc-available($tokens[1])">
                <xsl:sequence select="doc($tokens[1])//*[@xml:id eq $tokens[2]]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>
                    <xsl:text>WARNING: </xsl:text>
                    <xsl:text>dereferencing </xsl:text>
                    <xsl:value-of select="$reference"/>
                    <xsl:text> failed. Returning empty sequence</xsl:text>
                </xsl:message>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:package>
