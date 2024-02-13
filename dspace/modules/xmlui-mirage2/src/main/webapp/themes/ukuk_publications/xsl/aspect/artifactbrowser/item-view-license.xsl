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

        <xsl:variable name="licenseText" select="dim:field[@element='rights']" />
        <!-- <JR> 2023-02-01 - by default, in our installation of DSpace for publications.cuni.cz, CC license URI is stored in dcterms.license -->
        <xsl:variable name="licenseUri" select="dim:field[@element='license']" />
        <xsl:variable name="handleUri">
            <xsl:for-each select="dim:field[@element='identifier' and @qualifier='uri']">
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
        
        
        <div class="simple-item-view-description item-page-field-wrapper table" about="{$handleUri}">
        
            <h5 class="item-view-metadata-heading" id="item-view-metadata-license"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-license</i18n:text></h5>
                
            <xsl:choose>
                <xsl:when test="$licenseText and $licenseUri and contains($licenseUri, 'creativecommons')">
                    <p>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.cc-license-text-custom</i18n:text>
                        <xsl:value-of select="$licenseText"/>
                    </p>
                    <p>
                        <a rel="license" target="_blank" href="{$licenseUri}" alt="{$licenseText}" title="{$licenseText}">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.link-to-license-text</i18n:text>
                        </a>
                    </p>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="no-cc-license">
                        <xsl:with-param name="licenseText" select="$licenseText"/>
                        <xsl:with-param name="licenseUri" select="$licenseUri"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
                
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
                    <xsl:text>(</xsl:text>
                    <a rel="license" href="{$licenseUri}" alt="{$licenseText}" title="{$licenseText}">
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.no-cc-license-url</i18n:text>
                    </a>
                    <xsl:text>)</xsl:text>
                </p>
            </xsl:when>
            <xsl:when test="$licenseText">
                <xsl:choose>
                    <xsl:when test="contains($licenseText, 'bez licence')">
                        <p>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-license-text</i18n:text>
                        </p>    
                    </xsl:when>
                    <xsl:otherwise>
                        <p>
                            <xsl:value-of select="$licenseText"/>
                        </p>
                    </xsl:otherwise>
                </xsl:choose>
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

    <xsl:template name="itemSummaryView-DIM-license-icons">
        <xsl:param name="licenseText"/>
        <xsl:param name="licenseUri"/>
        <xsl:variable name="licenseText" select="dim:field[@element='rights']" />
        <!-- <JR> 2023-02-01 - by default, in our installation of DSpace for publications.cuni.cz, CC license URI is stored in dcterms.license -->
        <xsl:variable name="licenseUri" select="dim:field[@element='license']" />

        <xsl:choose>
            <xsl:when test="$licenseText and $licenseUri and contains($licenseUri, 'creativecommons')">
                <a rel="license" href="#item-view-metadata-license" alt="{$licenseText}" title="{$licenseText}">
                    <xsl:call-template name="cc-icon">
                        <xsl:with-param name="licenseURL" select="$licenseUri"/>
                    </xsl:call-template>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <a rel="license" href="#item-view-metadata-license" alt="{$licenseText}" title="{$licenseText}">
                    <xsl:call-template name="no-cc-license-icon">
                        <xsl:with-param name="licenseText" select="$licenseText"/>
                        <xsl:with-param name="licenseURL" select="$licenseUri"/>
                    </xsl:call-template>
                </a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="discovery-DIM-license-icons">
        <xsl:param name="licenseText"/>
        <xsl:param name="licenseUri"/>

        <xsl:choose>
            <xsl:when test="$licenseText and $licenseUri and contains($licenseUri, 'creativecommons')">
                <!-- <a rel="license" href="{$licenseUri}" target="_blank" alt="{$licenseText}" title="{$licenseText}"> -->
                    <xsl:call-template name="cc-icon">
                        <xsl:with-param name="licenseURL" select="$licenseUri"/>
                    </xsl:call-template>
                <!-- </a> -->
            </xsl:when>
            <xsl:otherwise>
                <!-- <a rel="license" href="{$licenseUri}" target="_blank" alt="{$licenseText}" title="{$licenseText}"> -->
                    <xsl:call-template name="no-cc-license-icon">
                        <xsl:with-param name="licenseText" select="$licenseText"/>
                        <xsl:with-param name="licenseURL" select="$licenseUri"/>
                    </xsl:call-template>
                <!-- </a> -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="no-cc-license-icon">
        <xsl:param name="licenseText"/>
        <xsl:param name="licenseURL"/>
        
        <xsl:choose>
            <xsl:when test="not($licenseText)">
                <span class="label label-additional-info label-discovery-publication-licence" label="Unknown licence" aria-label="Licence information" aria-haspopup="true">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-publication-licence-unknown</i18n:text>
                </span>
            </xsl:when>
            <xsl:when test="contains($licenseText, 'gratis open access')">
                <span id="gratis-oa-icon" class="custom-licence-icon-gratis">
                    <img src="{$theme-path}/images/cc/gratis_oa.svg" class="custom-licence-gratis-icon-image" alt="Gratis Apen Access Icon"/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$active-locale = 'cs'">
                    <span id="custom-licence-icon" class="custom-licence-icon">
                        <img src="{$theme-path}/images/cc/other_license_cs.svg" class="custom-licence-icon-image" title="{$licenseText}" alt="Ikona Jiná licence"/>
                    </span>
                </xsl:if>
                <xsl:if test="$active-locale = 'en'">
                    <span id="custom-licence-icon" class="custom-licence-icon">
                        <img src="{$theme-path}/images/cc/other_license_en.svg" class="custom-licence-icon-image-en" title="{$licenseText}" alt="Custom Licence Icon"/>
                    </span>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template name="cc-icon">
        <xsl:param name="licenseURL"/>
        
        <xsl:call-template name="cc-icon-content">
            <xsl:with-param name="licenseTerms" select="substring-before(substring-after($licenseURL, 'https://creativecommons.org/licenses/'),'/')" />
        </xsl:call-template>
        
    </xsl:template>

    <xsl:template name="cc-icon-content">
        <xsl:param name="licenseTerms"/>
        
        <span id="cc-icon-general" class="cc-icon">
            <img src="{$theme-path}/images/cc/cc_square.svg" class="cc-icon-image" alt="Creative Commons License Icon" />
        </span>

        <xsl:choose>
            <xsl:when test="$licenseTerms = 'by'">
                <span id="cc-icon-by" class="cc-icon">
                    <img src="{$theme-path}/images/cc/by_square.svg" class="cc-icon-image" alt="Creative Commons BY Icon" />
                </span>
            </xsl:when>

            <xsl:when test="$licenseTerms = 'by-nc'">
                <span id="cc-icon-by" class="cc-icon">
                    <img src="{$theme-path}/images/cc/by_square.svg" class="cc-icon-image" alt="Creative Commons BY Icon" />
                </span>
                <span id="cc-icon-nc" class="cc-icon">
                    <img src="{$theme-path}/images/cc/nc_square.svg" class="cc-icon-image" alt="Creative Commons NC Icon" />
                </span>
            </xsl:when>

            <xsl:when test="$licenseTerms = 'by-nc-nd'">
                <span id="cc-icon-by" class="cc-icon">
                    <img src="{$theme-path}/images/cc/by_square.svg" class="cc-icon-image" alt="Creative Commons BY Icon" />
                </span>
                <span id="cc-icon-nc" class="cc-icon">
                    <img src="{$theme-path}/images/cc/nc_square.svg" class="cc-icon-image" alt="Creative Commons NC Icon" />
                </span>
                <span id="cc-icon-nd" class="cc-icon">
                    <img src="{$theme-path}/images/cc/nd_square.svg" class="cc-icon-image" alt="Creative Commons NC Icon" />
                </span>
            </xsl:when>

            <xsl:when test="$licenseTerms = 'by-nc-sa'">
                <span id="cc-icon-by" class="cc-icon">
                    <img src="{$theme-path}/images/cc/by_square.svg" class="cc-icon-image" alt="Creative Commons BY Icon" />
                </span>
                <span id="cc-icon-nc" class="cc-icon">
                    <img src="{$theme-path}/images/cc/nc_square.svg" class="cc-icon-image" alt="Creative Commons NC Icon" />
                </span>
                <span id="cc-icon-sa" class="cc-icon">
                    <img src="{$theme-path}/images/cc/sa_square.svg" class="cc-icon-image" alt="Creative Commons SA Icon" />
                </span>
            </xsl:when>

            <xsl:when test="$licenseTerms = 'by-nd'">
                <span id="cc-icon-by" class="cc-icon">
                    <img src="{$theme-path}/images/cc/by_square.svg" class="cc-icon-image" alt="Creative Commons BY Icon" />
                </span>
                <span id="cc-icon-nd" class="cc-icon">
                    <img src="{$theme-path}/images/cc/nd_square.svg" class="cc-icon-image" alt="Creative Commons ND Icon" />
                </span>
            </xsl:when>

            <xsl:when test="$licenseTerms = 'by-sa'">
                <span id="cc-icon-by" class="cc-icon">
                    <img src="{$theme-path}/images/cc/by_square.svg" class="cc-icon-image" alt="Creative Commons BY Icon" />
                </span>
                <span id="cc-icon-sa" class="cc-icon">
                    <img src="{$theme-path}/images/cc/sa_square.svg" class="cc-icon-image" alt="Creative Commons SA Icon" />
                </span>
            </xsl:when>

            <xsl:otherwise>
                <span id="cc-text-other" class="cc-text-other">
                    <xsl:value-of select="$licenseTerms" />
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>