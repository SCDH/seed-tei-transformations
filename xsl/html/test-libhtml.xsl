<?xml version="1.0" encoding="UTF-8"?>
<!-- this is just a wrapper around libhtml for unit testing -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:html="http://scdh.wwu.de/transform/html#"
    xmlns:i18n="http://scdh.wwu.de/transform/i18n#" exclude-result-prefixes="xs" version="2.0">

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libi18n.xsl"
        package-version="0.1.0">
        <xsl:override>
            <xsl:variable name="i18n:default-language" as="xs:string" select="'en'"/>
        </xsl:override>
    </xsl:use-package>

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libhtml.xsl"
        package-version="1.0.0">
        <xsl:accept component="*" names="*" visibility="public"/>
    </xsl:use-package>

</xsl:stylesheet>
