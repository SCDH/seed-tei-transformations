<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:test="http://scdh.wwu.de/transform/test#"
    exclude-result-prefixes="#all" version="3.0">

    <!-- returns the readings in the html apparatus output -->
    <xsl:function name="test:reading" as="element()*">
        <xsl:param name="context" as="item()*"/>
        <xsl:sequence select="$context//span[tokenize(@class) = 'reading']"/>
    </xsl:function>

</xsl:stylesheet>
