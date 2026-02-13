<?xml version="1.0" encoding="UTF-8"?>
<!-- A TEI document may contain full witness information locally, in the header
    or it may contain only stubs that relate to a witnesses in central catalog.

    This is an XSLT library to deal with this.
    It hides away the details of the witness catalog and provides lookup functions.

    It defines an abstract global variable called wit:witnesses which is a sequence of elements
    holding the witness information, e.g. a sequence of <witness>. This variable must be over-
    ridden by a template that uses this package.

    It also defines two an XPath expression that tell, where how to get the siglum from such an
    element and how to get a witness description.
-->
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/common/libwit.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:wit="http://scdh.wwu.de/transform/wit#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs wit"
    version="3.0">

    <xsl:expose component="function" names="wit:*" visibility="public"/>
    <xsl:expose component="variable" names="wit:*" visibility="public"/>
    <xsl:expose component="variable" names="wit:witnesses" visibility="abstract"/>

    <!-- Determins which witness's text is present in the main text.
        This can be used to alter the default output in text and apparatus.
        The default is the empty sequence, which MUST not alter the outputs.
    -->
    <xsl:param name="wit:witness" as="xs:string?" select="()"/>

    <!-- OVERRIDE! -->
    <xsl:variable name="wit:witnesses" as="element()*" visibility="abstract"/>

    <!-- XPath where to get the siglum of a witness -->
    <xsl:variable name="wit:siglum-xpath" as="xs:string" visibility="public">
        <xsl:text>descendant::abbr[@type eq 'siglum'][1]</xsl:text>
    </xsl:variable>

    <!-- XPath where to get the description of a witness -->
    <xsl:variable name="wit:description-xpath" as="xs:string" visibility="public">
        <xsl:text>string-join(descendant::text(), '') => normalize-space()</xsl:text>
    </xsl:variable>


    <!-- returns a sequence of sigla for IDREFs e.g. in @wit -->
    <xsl:function name="wit:sigla-for-idrefs" as="xs:string*" visibility="public">
        <xsl:param name="attr" as="node()"/>
        <xsl:sequence
            select="tokenize($attr) ! substring(., 2) ! xs:ID(.) ! wit:get-witness(., $attr) ! wit:siglum(.)"
        />
    </xsl:function>

    <!-- returns a sequence of sigla for a IDs e.g. in @xml:id -->
    <xsl:function name="wit:sigla-for-ids" as="xs:string*" visibility="public">
        <xsl:param name="attr" as="node()"/>
        <xsl:sequence
            select="tokenize($attr) ! xs:ID(.) ! wit:get-witness(., $attr) ! wit:siglum(.)"/>
    </xsl:function>

    <!-- returns a sequence of descriptions for IDREFs e.g. in @wit -->
    <xsl:function name="wit:descriptions-for-idrefs" as="xs:string*" visibility="public">
        <xsl:param name="attr" as="node()"/>
        <xsl:sequence
            select="tokenize($attr) ! substring(., 2) ! xs:ID(.) ! wit:get-witness(., $attr) ! wit:description(.)"
        />
    </xsl:function>

    <!-- returns a siglum for an ID e.g. in @xml:id -->
    <xsl:function name="wit:descriptions-for-ids" as="xs:string*" visibility="public">
        <xsl:param name="attr" as="node()"/>
        <xsl:sequence
            select="tokenize($attr) ! xs:ID(.) ! wit:get-witness(., $attr) ! wit:description(.)"/>
    </xsl:function>

    <!-- get the witness with the given ID -->
    <xsl:function name="wit:get-witness" as="element()?" visibility="public">
        <xsl:param name="id" as="xs:ID"/>
        <xsl:param name="context" as="node()"/>
        <!-- maybe TODO: collect witnesses from other locations than $wit:witnesses -->
        <xsl:variable name="witnesses" as="element()*" select="$wit:witnesses"/>
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>count of witnesses: </xsl:text>
            <xsl:value-of select="count($witnesses)"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$witnesses/@xml:id" separator=", "/>
            <xsl:text>), searching witness with ID: '</xsl:text>
            <xsl:value-of select="$id"/>
            <xsl:text>'</xsl:text>
        </xsl:message>
        <xsl:sequence select="$witnesses[@xml:id eq $id][1]"/>
    </xsl:function>

    <!-- get the siglum for a given witness -->
    <xsl:function name="wit:siglum" as="xs:string*" visibility="public">
        <xsl:param name="witness" as="element()"/>
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>witness </xsl:text>
            <xsl:value-of select="$witness/@xml:id"/>
        </xsl:message>
        <xsl:variable name="siglum">
            <xsl:evaluate as="xs:string*" xpath="$wit:siglum-xpath" context-item="$witness"
                expand-text="true"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$siglum and $siglum ne ''">
                <xsl:value-of select="$siglum"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$witness/@xml:id"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- get the description for a given witness -->
    <xsl:function name="wit:description" as="xs:string*" visibility="public">
        <xsl:param name="witness" as="element()"/>
        <xsl:sequence>
            <xsl:evaluate as="xs:string*" xpath="$wit:description-xpath" context-item="$witness"
                expand-text="true"/>
        </xsl:sequence>
    </xsl:function>

    <xsl:function name="wit:debug" visibility="private">
        <xsl:param name="something"/>
        <xsl:message use-when="system-property('debug') eq 'true'">
            <xsl:text>debug: </xsl:text>
            <xsl:value-of select="normalize-space($something)"/>
        </xsl:message>
        <xsl:sequence select="$something"/>
    </xsl:function>


    <!-- a function for getting a sortkey for the witnesses used in @wit.
        This hands over to wit:sortkey-single for each witness reference in @wit.
    -->
    <xsl:function name="wit:sortkey" as="item()" visibility="final">
        <xsl:param name="wit" as="attribute()?"/>
        <xsl:choose>
            <xsl:when test="$wit">
                <xsl:variable name="wits" as="item()"
                    select="tokenize($wit) ! wit:sortkey-single(.)"/>
                <xsl:sequence select="sort($wits)[1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="0"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- Get a sortkey for a single witness reference.
        This default implementation gets the position of the witness. -->
    <xsl:function name="wit:sortkey-single" as="item()" visibility="public">
        <xsl:param name="wit" as="xs:string"/>
        <xsl:sequence
            select="$wit:witnesses/descendant-or-self::witness[@xml:id eq substring($wit, 2)]/preceding::witness => count()"
        />
    </xsl:function>

</xsl:package>
