<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Author: Jakub Řihák (jakub dot rihak at ruk dot cuni dot com)

    UTILIY XSLT templates for rendering various non-standard page components,
    like displayTitles, etc.

    

    Stylesheet is imported in the: 
    - aspect/artifactbrowser/item-view.xsl
    
-->
<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
                xmlns:dri="http://di.tamu.edu/DRI/1.0/"
                xmlns:mets="http://www.loc.gov/METS/"
                xmlns:xlink="http://www.w3.org/TR/xlink/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:confman="org.dspace.core.ConfigurationManager"
                exclude-result-prefixes="i18n dri mets xlink xsl dim xhtml mods dc confman">


    <!-- <JR>  2023-06-16 
        This template outputs the uk.displayTitle or uk.displayTitle.translated (it value is passed in 'title-string' param)
        in such a way, that html tags included in its value are not escaped on output.

        For example:
        
        If value of uk.displayTitle = "This is <strong>displayTitle</strong> string", the output will be:
            "This is " <strong>displayTitle</strong>" string" instead of "This is &lt;strong&gt;displayTitle&lt;strong&gt;"
        
        This results in parts of displayTitle being formatted in accordance to the valid HTML tags in which those parts of the string were enclosed
    -->
    <xsl:template name="utility-parse-display-title">
        <xsl:param name="title-string"/>
        <xsl:value-of disable-output-escaping="yes" select="$title-string"/>
    </xsl:template>

    <!--
        This template processes a XML response from SOLR and returns string containing author's research identifiers from it.

        If no item is found based on the SOLR query or more then 1 item is found, nothing happens.
    -->
    <xsl:template name="utility-authorIdentifiersParse">
        <xsl:param name="authorIdentifiersXML"/>
        <xsl:param name="authorNameInMetadata"/>
        <xsl:choose>
            <xsl:when test="$authorIdentifiersXML/response/result/@numFound = '0'">
                <!-- Don't do anything -->
            </xsl:when>
            <xsl:when test="$authorIdentifiersXML/response/result/@numFound = '1'">
                <xsl:for-each select="$authorIdentifiersXML/response/result/doc/arr[@name='uk.author.identifier']/str">
                    <xsl:if test="substring-before(./text(),'|') = $authorNameInMetadata">
                        <xsl:value-of select="./text()"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <!-- Don't do anything -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>