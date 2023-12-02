<?xml version="1.0" encoding="UTF-8"?>
<!-- A wrapper around aleabiblio.xsl that enables unit testing. -->
<xsl:package
    name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/html/libbiblio.xsl"
    package-version="1.0.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ref="http://scdh.wwu.de/transform/ref#"
    xmlns:i18n="http://scdh.wwu.de/transform/i18n#"
    xmlns:biblio="http://scdh.wwu.de/transform/biblio#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    version="3.0">

    <xsl:use-package
        name="https://scdh.zivgitlabpages.uni-muenster.de/tei-processing/transform/xsl/projects/alea/html/aleabiblio.xsl"
        package-version="1.0.0">
        <xsl:accept component="template" names="biblio:*" visibility="final"/>
        <xsl:override>
            <xsl:variable name="i18n:default-language" as="xs:string" select="'en'"/>
        </xsl:override>
    </xsl:use-package>


</xsl:package>
