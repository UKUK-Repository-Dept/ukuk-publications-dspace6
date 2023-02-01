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

    <!--The License-->
    <xsl:template name="license">
        <xsl:param name="metadataURL"/>
        <xsl:variable name="externalMetadataURL">
            <xsl:text>cocoon:/</xsl:text>
            <xsl:value-of select="$metadataURL"/>
            <xsl:text>?sections=dmdSec,fileSec&amp;fileGrpTypes=THUMBNAIL</xsl:text>
        </xsl:variable>

        <xsl:variable name="licenseText"
                    select="document($externalMetadataURL)//dim:field[@element='rights']"
                />
        <!-- <JR> 2023-02-01 - by default, in our installation of DSpace for publications.cuni.cz, CC license URI is stored in dcterms.license -->
        <xsl:variable name="licenseUri"
                    select="document($externalMetadataURL)//dim:field[@element='license']"
                />
        <xsl:variable name="handleUri">
            <xsl:for-each select="document($externalMetadataURL)//dim:field[@element='identifier' and @qualifier='uri']">
                <a>
                    <xsl:attribute name="href">
                        <xsl:copy-of select="./node()"/>
                    </xsl:attribute>
                    <xsl:copy-of select="./node()"/>
                </a>
                <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <!-- <xsl:variable name="handleUri">
            <xsl:for-each select="document($externalMetadataURL)//dim:field[@element='identifier' and @qualifier='uri']">
                <a>
                    <xsl:attribute name="href">
                        <xsl:copy-of select="./node()"/>
                    </xsl:attribute>
                    <xsl:copy-of select="./node()"/>
                </a>
                <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable> -->

        
        <!--<div about="{$handleUri}" class="row">-->
        <div class="simple-item-view-description item-page-field-wrapper table">
            <!-- <JR> - Add heading for abstract visible all the time and specifying the abstract language -->
            <!-- <h5 class="visible-xs"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract</i18n:text></h5>-->
            <div about="{$handleUri}" class="row">
                <h5 class="item-view-metadata-heading" if="item-view-metadata-license"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-license</i18n:text></h5>
                
                <xsl:choose>
                    <xsl:when test="$licenseText and $licenseUri and contains($licenseUri, 'creativecommons')">
                        <a rel="license" href="{$licenseUri}" alt="{$licenseText}" title="{$licenseText}">
                            <xsl:call-template name="cc-logo">
                                <xsl:with-param name="licenseText" select="$licenseText"/>
                                <xsl:with-param name="licenseUri" select="$licenseUri"/>
                            </xsl:call-template>
                        </a>
            
                        <span>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.cc-license-text</i18n:text>
                            <xsl:value-of select="$licenseText"/>
                        </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="no-cc-license">
                            <xsl:with-param name="licenseText" select="$licenseText"/>
                            <xsl:with-param name="licenseUri" select="$licenseUri"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                
            </div>
        </div>
        
    </xsl:template>

    <xsl:template name="no-cc-license">
        <xsl:param name="licenseText"/>
        <xsl:param name="licenseUri"/>

        <xsl:choose>
            <xsl:when test="$licenseText and $licenseUri">
                <p>
                    <xsl:choose>
                        <xsl:when test="contains($licenseText, 'bez licence')">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-license-text</i18n:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$licenseText"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </p>
                
                <p>
                    <a rel="license" href="{$licenseUri}" alt="{$licenseText}" title="{$licenseText}">
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.no-cc-license-url</i18n:text>
                    </a>
                </p>
            </xsl:when>
            <xsl:when test="$licenseText">
                <p>
                    <xsl:value-of select="$licenseText"/>
                </p>
            </xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="cc-logo">
        <xsl:param name="licenseText"/>
        <xsl:param name="licenseUri"/>
        <xsl:variable name="ccLogo">
            <xsl:choose>
                <xsl:when test="starts-with($licenseUri,
                                        'http://creativecommons.org/licenses/by/')">
                    <xsl:value-of select="'cc-by.png'" />
                </xsl:when>
                <xsl:when test="starts-with($licenseUri,
                                        'http://creativecommons.org/licenses/by-sa/')">
                    <xsl:value-of select="'cc-by-sa.png'" />
                </xsl:when>
                <xsl:when test="starts-with($licenseUri,
                                        'http://creativecommons.org/licenses/by-nd/')">
                    <xsl:value-of select="'cc-by-nd.png'" />
                </xsl:when>
                <xsl:when test="starts-with($licenseUri,
                                        'http://creativecommons.org/licenses/by-nc/')">
                    <xsl:value-of select="'cc-by-nc.png'" />
                </xsl:when>
                <xsl:when test="starts-with($licenseUri,
                                        'http://creativecommons.org/licenses/by-nc-sa/')">
                    <xsl:value-of select="'cc-by-nc-sa.png'" />
                </xsl:when>
                <xsl:when test="starts-with($licenseUri,
                                        'http://creativecommons.org/licenses/by-nc-nd/')">
                    <xsl:value-of select="'cc-by-nc-nd.png'" />
                </xsl:when>
                <xsl:when test="starts-with($licenseUri,
                                        'http://creativecommons.org/publicdomain/zero/')">
                    <xsl:value-of select="'cc-zero.png'" />
                </xsl:when>
                <xsl:when test="starts-with($licenseUri,
                                        'http://creativecommons.org/publicdomain/mark/')">
                    <xsl:value-of select="'cc-mark.png'" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'cc-generic.png'" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <img class="img-responsive">
            <xsl:attribute name="src">
                <xsl:value-of select="concat($theme-path,'/images/creativecommons/', $ccLogo)"/>
            </xsl:attribute>
            <xsl:attribute name="alt">
                <xsl:value-of select="$licenseText"/>
            </xsl:attribute>
        </img>
    </xsl:template>
</xsl:stylesheet>