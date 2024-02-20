<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Rendering of a list of items (e.g. in a search or
    browse results page)

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

-->

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
    xmlns:confman="org.dspace.core.ConfigurationManager"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util confman">
    <xsl:import href="../../custom/utility.xsl"/>
    <xsl:import href="../artifactbrowser/item-view-license.xsl"/>

    <xsl:output indent="yes"/>

    <!--these templates are modfied to support the 2 different item list views that
    can be configured with the property 'xmlui.theme.mirage.item-list.emphasis' in dspace.cfg-->

    <xsl:template name="itemSummaryList-DIM">
        <xsl:variable name="itemWithdrawn" select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim/@withdrawn" />

        <xsl:variable name="href">
            <xsl:choose>
                <xsl:when test="$itemWithdrawn">
                    <xsl:value-of select="@OBJEDIT"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@OBJID"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- <JR> - 2024-02-14: Always display thubmnail on item lists -->
        <!-- <xsl:variable name="emphasis" select="confman:getProperty('xmlui.theme.mirage.item-list.emphasis')"/> -->
        <!-- <xsl:choose>
            <xsl:when test="'file' = $emphasis"> -->


        <div class="item-wrapper row ds-artifact-item-in-list">
            <div class="col-sm-3 hidden-xs">
                <xsl:apply-templates select="./mets:fileSec" mode="artifact-preview">
                    <xsl:with-param name="href" select="$href"/>
                </xsl:apply-templates>
            </div>

            <div class="col-sm-9 artifact-description">
                <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                        mode="itemSummaryList-DIM-metadata">
                    <xsl:with-param name="href" select="$href"/>
                </xsl:apply-templates>
            </div>

        </div>
            <!-- </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                                     mode="itemSummaryList-DIM-metadata"><xsl:with-param name="href" select="$href"/></xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose> -->
    </xsl:template>

    <!--handles the rendering of a single item in a list in file mode-->
    <!--handles the rendering of a single item in a list in metadata mode-->
    <!-- <JR> - 2023-06-13: TODO: try handling uk.displayTitle and uk.displayTitle.translated when present -->
    <xsl:template match="dim:dim" mode="itemSummaryList-DIM-metadata">
        <xsl:param name="href"/>
        <div class="artifact-description artifact-info">
            <xsl:element name="a">
                <xsl:attribute name="href">
                    <xsl:value-of select="$href"/>
                </xsl:attribute>
                
                <h4 class="discovery-item-title artifact-title">
                
                    <xsl:choose>
                        <xsl:when test="dim:field[@element='displayTitle']">
                            <xsl:call-template name="utility-parse-display-title">
                                <xsl:with-param name="title-string" select="dim:field[@element='displayTitle'][1]"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="dim:field[@element='title']">
                                    <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                
                    <span class="Z3988">
                        <xsl:attribute name="title">
                            <xsl:call-template name="renderCOinS"/>
                        </xsl:attribute>
                        &#xFEFF; <!-- non-breaking space to force separating the end tag -->
                    </span>
                </h4>
            </xsl:element>
            <div class="artifact-info">
                
                <!-- <JR> - 2024-02-06: Adding template for additional info row -->
                <xsl:call-template name="itemSummaryList-additional-info" />

                <xsl:call-template name="itemSummaryList-authors">
                    <xsl:with-param name="handle" select="dim:field[@element='identifier'][@qualifier='uri']"/>
                    <!-- <xsl:with-param name="metsDoc" select="$metsDoc"/> -->
                </xsl:call-template>
                    
                <xsl:call-template name="itemSummaryList-publication-info" />

                <xsl:call-template name="itemSummaryList-abstract" />

            </div>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryList-additional-info">
        <div class="row discovery-additional-info-row">
            <div class="col-xs-6 col-sm-6 col-md-6 discovery-additional-info-column">
                <div aria-label="additional-item-info-type" role="group" class="btn-group label-group">
                    <xsl:call-template name="discovery-additional-info-type" />
                </div>
            </div>
            <div class="col-xs-6 col-sm-6 col-md-6 discovery-additional-info-column discovery-additional-info-column-right">
                <div class="btn-group label-group discovery-additional-info-access" role="group" aria-label="additional-item-info-access">
                    <xsl:call-template name="itemSummaryList-additional-info-access" />
                </div>
            </div>          
        </div>
        <div class="row discovery-additional-info-row">
            <div class="col-xs-6 col-sm-6 col-md-6 discovery-additional-info-column">
                <div aria-label="additional-item-info-version" role="group" class="btn-group label-group">
                    <xsl:call-template name="itemSummaryList-additional-info-version" />
                </div>
            </div>
            <div class="col-xs-6 col-sm-6 col-md-6 discovery-additional-info-column discovery-additional-info-column-right">
                <div aria-label="additional-item-info-licence" role="group" class="btn-group label-group discovery-additional-info-licence">
                    <xsl:call-template name="itemSummaryList-additional-info-licence" />
                </div>
            </div>
        </div>

    </xsl:template>

    <xsl:template name="itemSummaryList-additional-info-type">
        <xsl:variable name="languageCapitalized">
            <xsl:choose>
                <xsl:when test="$active-locale = 'cs'">
                    <xsl:text>Cs</xsl:text>
                </xsl:when> 
                <xsl:when test="$active-locale = 'en'">
                    <xsl:text>En</xsl:text>
                </xsl:when>
                <xsl:otherwise><xsl:text>En</xsl:text></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="dim:field[@element=type][@qualifier=concat('obdHierarchy', $languageCapitalized)]">
                
                <h4 class="label label-additional-info label-discovery-publication-type" aria-haspopup="true">
                    <xsl:value-of 
                        select="substring-after(substring-after(dim:field[@element=type][@qualifier=concat('obdHierarchy', $languageCapitalized)],'::'),'::')"/>
                </h4>
            </xsl:when>
            <xsl:otherwise>
                <h4 class="label label-additional-info label-discovery-publication-type" aria-haspopup="false">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-publication-type-unknown</i18n:text>
                </h4>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryList-additional-info-access">
        <xsl:choose>
            <xsl:when test="dim:field[@element='accessRights']">

                <xsl:variable name="accessRightsValue" select="dim:field[@element='accessRights']"/>

                <xsl:variable name="publicationAccessRightsValue">
                    <xsl:value-of select="concat('xmlui.dri2xhtml.METS-1.0.item-publication-accessRights.', $accessRightsValue)" />
                </xsl:variable>
                
                <xsl:choose>
                    <xsl:when test="dim:field[@element='date'][@qualifier='embargoEndDate']">
                        <xsl:variable name="embargoEndDate" select="dim:field[@element='date'][@qualifier='embargoEndDate']"/>

                        <h4 class="label label-additional-info label-discovery-publication-accessRights"
                            data-toggle="tooltip" data-placement="bottom" 
                            aria-label="Access information">
                            <xsl:if test="$active-locale = 'cs'">
                                <xsl:attribute name="title"><xsl:text>Přístupné od: </xsl:text><xsl:value-of select="$embargoEndDate"/></xsl:attribute>
                            </xsl:if>
                            <xsl:if test="$active-locale = 'en'">
                                <xsl:attribute name="title"><xsl:text>Available from: </xsl:text><xsl:value-of select="$embargoEndDate"/></xsl:attribute>
                            </xsl:if>
                            
                            <i18n:text><xsl:value-of select="$publicationAccessRightsValue" /></i18n:text>
                        </h4>
                    </xsl:when>
                    <xsl:otherwise>
                        <h4 class="label label-additional-info label-discovery-publication-accessRights" 
                            aria-label="Access information">
                            <i18n:text><xsl:value-of select="$publicationAccessRightsValue" /></i18n:text>
                        </h4>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <h4 class="label label-additional-info label-discovery-publication-accessRights" aria-haspopup="false">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-publication-accessRights.unknown</i18n:text>
                </h4>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryList-additional-info-version">
        <xsl:choose>
            <xsl:when test="dim:field[@element='type'][@qualifier='version']">
                <xsl:variable name="versionValue" select="dim:field[@element='type'][@qualifier='version']" />
                
                <xsl:variable name="publicationVersionValue">
                    <xsl:value-of select="substring-after($versionValue, 'info:eu-repo/semantics/')" />
                </xsl:variable>
                    
                <h4 id="discovery-publication-version" class="label label-additional-info label-discovery-publication-version" aria-haspopup="false">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-publication-version-<xsl:value-of select="$publicationVersionValue" />
                    </i18n:text>
                </h4>
                
            </xsl:when>
            <xsl:otherwise>
                
                <h4 id="discovery-publication-version" class="label label-additional-info label-discovery-publication-version" aria-haspopup="false">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-publication-version-unknown</i18n:text>
                </h4>
                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryList-additional-info-licence">
        <xsl:variable name="licenseText" select="dim:field[@element='rights']" />
        <xsl:variable name="licenseUri" select="dim:field[@element='license']" />
        
        <div class="btn-group label-group discovery-additional-item-info-licence" 
            data-toggle="tooltip" data-placement="bottom" title="{$licenseText}" role="group" aria-label="License information">
            <xsl:call-template name="discovery-DIM-license-icons">
                <xsl:with-param name="licenseText" select="$licenseText"/>
                <xsl:with-param name="licenseUri" select="$licenseUri" />
            </xsl:call-template>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryList-authors">
        <xsl:param name="handle"/>
        <!-- <xsl:param name="metsDoc"/> -->
        <xsl:variable name="handleNew">
            <xsl:value-of select="substring-after($handle, '/')"/>
        </xsl:variable>
        
        <xsl:variable name="authorsCount" select="count(dim:field[@element='contributor'][@qualifier='author'])"/>
        
        <div class="row discovery-authors-row">
            <div class="col-xs-12 col-sm-12 col-md-12 discovery-authors-row-column" id="discovery-item-authors-{$handleNew}">
                
                <xsl:choose>
                    <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                        <xsl:if test="$authorsCount &lt;= 3">
                            <xsl:call-template name="itemSummaryList-authors-three-or-less">
                                <xsl:with-param name="handle" select="$handle"/>
                                <!-- <xsl:with-param name="metsDoc" select="$metsDoc" /> -->
                            </xsl:call-template>
                        </xsl:if>

                        <xsl:if test="$authorsCount > 3">
                            <xsl:call-template name="itemSummaryList-authors-more-then-three">
                                <xsl:with-param name="handle" select="$handle"/>
                                <!-- <xsl:with-param name="metsDoc" select="$metsDoc"/> -->
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>

    </xsl:template>

    <xsl:template name="itemSummaryList-authors-value">
        <xsl:param name="authorItem"/>
        <!-- <xsl:param name="metsDoc"/> -->

        <xsl:variable name="author">
            <xsl:apply-templates select="$authorItem"/>
        </xsl:variable>
        <h4 class="discovery-author">
            <!--Check authority in the mets document-->
            <xsl:if test="@authority">
                <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="$authorItem"/>
        </h4>

    </xsl:template>

    <xsl:template name="itemSummaryList-authors-three-or-less">
        <xsl:param name="handle"/>
        <!-- <xsl:param name="metsDoc"/> -->

        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
            <xsl:if test="count(preceding-sibling::dim:field[@element='contributor'][@qualifier='author']) &lt;= 2">
                <xsl:call-template name="itemSummaryList-authors-value">
                    <xsl:with-param name="authorItem" select="." />
                    <!-- <xsl:with-param name="metsDoc" select="$metsDoc" /> -->
                </xsl:call-template>
            </xsl:if>

            <xsl:if test="count(preceding-sibling::dim:field[@element='contributor'][@qualifier='author']) &lt;2 
            and not(count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) = 0)">
                <xsl:text>; </xsl:text>
            </xsl:if>
            <xsl:if test="count(preceding-sibling::dim:field[@element='contributor'][@qualifier='author']) = 2 
            and count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) > 0">
                <xsl:text>; </xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="itemSummaryList-authors-more-then-three">
        <xsl:param name="handle"/>
        <!-- <xsl:param name="metsDoc"/> -->

        <xsl:variable name="handleNew">
            <xsl:value-of select="substring-after($handle, '123456789/')"/>
        </xsl:variable>

        <xsl:call-template name="itemSummaryList-authors-three-or-less">
            <xsl:with-param name="handle" select="$handle"/>
            <!-- <xsl:with-param name="metsDoc" select="$metsDoc" /> -->
        </xsl:call-template>
        
        <div id="collapse-discovery-authors-{$handleNew}" class="collapse" 
        aria-labelledby="discovery-item-authors-{$handleNew}">
            <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                <xsl:if test="count(preceding-sibling::dim:field[@element='contributor'][@qualifier='author']) >= 3 
                and count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) > 0">

                    <xsl:call-template name="itemSummaryList-authors-value">
                        <xsl:with-param name="authorItem" select="." />
                        <!-- <xsl:with-param name="metsDoc" select="$metsDoc" /> -->
                    </xsl:call-template>

                    <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                        <xsl:text>; </xsl:text>
                    </xsl:if>
                </xsl:if>
                <xsl:if test="count(preceding-sibling::dim:field[@element='contributor'][@qualifier='author']) >= 3 
                and count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) = 0">
                   
                    <xsl:call-template name="itemSummaryList-authors-value">
                        <xsl:with-param name="authorItem" select="." />
                        <!-- <xsl:with-param name="metsDoc" select="$metsDoc" /> -->
                    </xsl:call-template>
                </xsl:if>
                
            </xsl:for-each>
        </div>

        <div class="discovery-authors-button-div">
            <button class="btn btn-link collapsed discovery-show-authors-button" type="button" data-toggle="collapse" 
            data-target="#collapse-discovery-authors-{$handleNew}" aria-expanded="false"
            aria-controls="collapse-discovery-authors-{$handleNew}">
                <i18n:text>xmlui.dri2xhtml.METS-1.0.item-author-collapse</i18n:text>
            </button>
        </div>

    </xsl:template>

    <xsl:template name="itemSummaryList-publication-info">
        <div class="row discovery-publication-info-row">
            <div class="col-xs-12 col-sm-12 col-md-12 discovery-publication-info-column">
                <xsl:if test="dim:field[@element='date'][@qualifier='issued']">
                    <h4 class="discovery-publication-info-heading">
                        <xsl:value-of
                                select="substring(dim:field[@element='date'][@qualifier='issued'],1,10)"/>
                    </h4>
                </xsl:if>

                <xsl:if test="dim:field[@element='publisher'][@qualifier='publicationPlace']">
                    <xsl:text>, </xsl:text>
                    <h4 class="discovery-publication-info-heading">
                        <xsl:apply-templates select="dim:field[@element='publisher'][@qualifier='publicationPlace']"/>
                    </h4>
                </xsl:if>
                <xsl:if test="dim:field[@element='publisher'][not(@qualifier)]">
                    <xsl:text>, </xsl:text>
                    <h4 class="discovery-publication-info-heading">
                        <xsl:apply-templates select="dim:field[@element='publisher'][not(@qualifier)]"/>
                    </h4>
                </xsl:if>
                
                <xsl:if test="dim:field[@element='isPartOf'][@qualifier='name']">
                    <xsl:text>, </xsl:text>
                    <h4 class="discovery-publication-info-heading">
                        <xsl:apply-templates select="dim:field[@element='isPartOf'][@qualifier='name']"/>
                    </h4>
                </xsl:if>
                <xsl:if test="dim:field[@element='isPartOf'][@qualifier='journalVolume'] 
                or dim:field[@element='isPartOf'][@qualifier='journalIssue']">
                    <xsl:if test="dim:field[@element='isPartOf'][@qualifier='journalVolume']">
                        <xsl:text>, </xsl:text>
                        <h4 class="discovery-publication-info-heading">
                            <xsl:apply-templates select="dim:field[@element='isPartOf'][@qualifier='journalVolume']"/>
                        </h4>
                    </xsl:if>
                    <xsl:if test="dim:field[@element='isPartOf'][@qualifier='journalIssue']">
                        <xsl:text> </xsl:text>
                        <h4 class="discovery-publication-info-heading">
                            <xsl:text>(</xsl:text>
                            <xsl:apply-templates select="dim:field[@element='isPartOf'][@qualifier='journalIssue']"/>
                            <xsl:text>)</xsl:text>
                        </h4>
                    </xsl:if>
                </xsl:if>
            </div>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryList-abstract">
        
        <xsl:if test="dim:field[@element = 'description' and @qualifier='abstract']">
            <xsl:variable name="abstract" select="dim:field[@element = 'description' and @qualifier='abstract']/node()"/>
            <div class="row discovery-abstract-row">
                <div class="col-xs-12 col-sm-12 col-md-12 discovery-abstract-column">
                    <h4 class="discovery-abstract">
                        <xsl:value-of select="util:shortenString($abstract, 220, 10)"/>
                    </h4>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemDetailList-DIM">
        <xsl:call-template name="itemSummaryList-DIM"/>
    </xsl:template>


    <xsl:template match="mets:fileSec" mode="artifact-preview">
        <xsl:param name="href"/>
        <div class="thumbnail artifact-preview">
            <a class="image-link" href="{$href}">
                <xsl:choose>
                    <xsl:when test="mets:fileGrp[@USE='THUMBNAIL']">
                        <!-- Checking if Thumbnail is restricted and if so, show a restricted image --> 
                        <xsl:variable name="src">
                            <xsl:value-of select="mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="contains($src,'isAllowed=n')">
                                <div style="width: 100%; text-align: center">
                                    <i aria-hidden="true" class="glyphicon  glyphicon-lock"></i>
                                </div>
                            </xsl:when>
                            <xsl:otherwise>
                                <img class="img-responsive img-thumbnail" alt="xmlui.mirage2.item-list.thumbnail" i18n:attr="alt">
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="$src"/>
                                    </xsl:attribute>
                                </img>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <img class="img-thumbnail" alt="xmlui.mirage2.item-list.thumbnail" i18n:attr="alt">
                            <xsl:attribute name="data-src">
                                <xsl:text>holder.js/100%x</xsl:text>
                                <xsl:value-of select="$thumbnail.maxheight"/>
                                <xsl:text>/text:No Thumbnail</xsl:text>
                            </xsl:attribute>
                        </img>
                    </xsl:otherwise>
                </xsl:choose>
            </a>
        </div>
    </xsl:template>




    <!--
        Rendering of a list of items (e.g. in a search or
        browse results page)

        Author: art.lowel at atmire.com
        Author: lieven.droogmans at atmire.com
        Author: ben at atmire.com
        Author: Alexey Maslov

    -->



        <!-- Generate the info about the item from the metadata section -->
        <xsl:template match="dim:dim" mode="itemSummaryList-DIM">
            <xsl:variable name="itemWithdrawn" select="@withdrawn" />
            <div class="artifact-description">
                <div class="artifact-title">
                    <xsl:element name="a">
                        <xsl:attribute name="href">
                            <xsl:choose>
                                <xsl:when test="$itemWithdrawn">
                                    <xsl:value-of select="ancestor::mets:METS/@OBJEDIT" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="ancestor::mets:METS/@OBJID" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="dim:field[@element='title']">
                                <xsl:value-of select="dim:field[@element='title'][1]/node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </div>
                <span class="Z3988">
                    <xsl:attribute name="title">
                        <xsl:call-template name="renderCOinS"/>
                    </xsl:attribute>
                    &#xFEFF; <!-- non-breaking space to force separating the end tag -->
                </span>
                <div class="artifact-info">
                    <span class="author">
                        <xsl:choose>
                            <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                                <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                                    <span>
                                        <xsl:if test="@authority">
                                            <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
                                        </xsl:if>
                                        <xsl:copy-of select="node()"/>
                                    </span>
                                    <xsl:if test="count(following-sibling::dim:field[@element='contributor'][@qualifier='author']) != 0">
                                        <xsl:text>; </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:when test="dim:field[@element='creator']">
                                <xsl:for-each select="dim:field[@element='creator']">
                                    <xsl:copy-of select="node()"/>
                                    <xsl:if test="count(following-sibling::dim:field[@element='creator']) != 0">
                                        <xsl:text>; </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:when test="dim:field[@element='contributor']">
                                <xsl:for-each select="dim:field[@element='contributor']">
                                    <xsl:copy-of select="node()"/>
                                    <xsl:if test="count(following-sibling::dim:field[@element='contributor']) != 0">
                                        <xsl:text>; </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </span>
                    <xsl:text> </xsl:text>
                    <xsl:if test="dim:field[@element='date' and @qualifier='issued'] or dim:field[@element='publisher']">
                        <span class="publisher-date">
                            <xsl:text>(</xsl:text>
                            <xsl:if test="dim:field[@element='publisher']">
                                <span class="publisher">
                                    <!-- <JR> - 2022-10-07 -->
                                    <!-- PŮVODNÍ HODNOTA -->
                                    <!--<xsl:copy-of select="dim:field[@element='publisher']/node()"/>-->
                                    <xsl:value-of select="dim:field[@element='publisher']"/>
                                </span>
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <xsl:if test="dim:field[@element='publisher' and @qualifier='publicationPlace']">
                                <span class="publisherPlace">
                                    <xsl:value-of select="dim:field[@element='publisher' and @qualifier='publicationPlace']"/>
                                </span>
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <span class="date">
                                <xsl:value-of select="substring(dim:field[@element='date' and @qualifier='issued']/node(),1,10)"/>
                            </span>
                            <xsl:text>)</xsl:text>
                        </span>
                    </xsl:if>
                </div>
            </div>
        </xsl:template>

</xsl:stylesheet>
