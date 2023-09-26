<xsl:stylesheet
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:oreatom="http://www.openarchives.org/ore/atom/"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:encoder="xalan://java.net.URLEncoder"
    xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
    xmlns:jstring="java.lang.String"
    xmlns:rights="http://cosimo.stanford.edu/sdr/metsrights/"
    xmlns:confman="org.dspace.core.ConfigurationManager"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util jstring rights confman">
    
    
    <xsl:template name="itemSummaryView-DIM-citations-by-doc-type">
        <xsl:param name="documentType"/>

        <xsl:if test="$documentType = 73">
            <xsl:call-template name="itemSummaryView-DIM-citations-article"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-citations-article">
        <p class="citation">
            <xsl:for-each select="dim:field[@element='contributor' and @qualifier='author']">
                <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) = 1">
                    <xsl:if test="count(preceding-sibling::dim:field[@element='contributor'][@qualifier='author']) = 0">
                        <span class="contributor-surname"><xsl:value-of select="substring-before(.,',')"/></span><xsl:text>, </xsl:text><xsl:value-of select="substring-after(.,',')"/>
                    <xsl:if>
                </xsl:if>

                <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) > 1">
                    <xsl:if test="count(preceding-sibling::dim:field[@element='contributor'][@qualifier='author']) = 0">
                        <span class="contributor-surname"><xsl:value-of select="substring-before(.,',')"/></span><xsl:text>, </xsl:text><xsl:value-of select="substring-after(.,',')"/><xsl:text>, </xsl:text>
                    </xsl:if>
                    <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) = 0">
                        <xsl:value-of select="substring-after(.,',')"/><xsl:text> </xsl:text><span class="contributor-surname"><xsl:value-of select="substring-before(.,',')"/></span>
                    </xsl:if>

                    <xsl:value-of select="substring-after(.,',')"/><xsl:text> </xsl:text><span class="contributor-surname"><xsl:value-of select="substring-before(.,',')"/></span><xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </p>
    </xsl:template>

</xsl:stylesheet>