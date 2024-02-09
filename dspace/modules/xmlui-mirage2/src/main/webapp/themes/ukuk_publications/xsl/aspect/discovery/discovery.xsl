<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<xsl:stylesheet
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:encoder="xalan://java.net.URLEncoder"
    xmlns:stringescapeutils="org.apache.commons.lang3.StringEscapeUtils"
    xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
    exclude-result-prefixes="xalan encoder i18n dri mets dim  xlink xsl util stringescapeutils">
    <xsl:import href="../../custom/utility.xsl"/>
    <xsl:import href="../artifactbrowser/item-view-license.xsl"/>

    <xsl:output indent="yes"/>

<!--
    These templates are devoted to rendering the search results for discovery.
    Since discovery uses hit highlighting, separate templates are required !
-->


    <xsl:template match="dri:list[@type='dsolist']" priority="2">
        <xsl:apply-templates select="dri:head"/>
        <xsl:apply-templates select="*[not(name()='head')]" mode="dsoList"/>
    </xsl:template>

    <xsl:template match="dri:list/dri:list" mode="dsoList" priority="7">
        <xsl:apply-templates select="dri:head"/>
        <xsl:apply-templates select="*[not(name()='head')]" mode="dsoList"/>
    </xsl:template>

    <xsl:template match="dri:list/dri:list/dri:list" mode="dsoList" priority="8">
            <!--
                Retrieve the type from our name, the name contains the following format:
                    {handle}:{metadata}
            -->
            <xsl:variable name="handle">
                <xsl:value-of select="substring-before(@n, ':')"/>
            </xsl:variable>
            <xsl:variable name="type">
                <xsl:value-of select="substring-after(@n, ':')"/>
            </xsl:variable>
            <xsl:variable name="externalMetadataURL">
                <xsl:text>cocoon://metadata/handle/</xsl:text>
                <xsl:value-of select="$handle"/>
                <xsl:text>/mets.xml</xsl:text>
                <!-- Since this is a summary only grab the descriptive metadata, and the thumbnails -->
                <xsl:text>?sections=dmdSec,fileSec&amp;fileGrpTypes=THUMBNAIL</xsl:text>
                <!-- An example of requesting a specific metadata standard (MODS and QDC crosswalks only work for items)->
                <xsl:if test="@type='DSpace Item'">
                    <xsl:text>&amp;dmdTypes=DC</xsl:text>
                </xsl:if>-->
            </xsl:variable>


        <xsl:choose>
            <xsl:when test="$type='community'">
                <xsl:call-template name="communitySummaryList">
                    <xsl:with-param name="handle">
                        <xsl:value-of select="$handle"/>
                    </xsl:with-param>
                    <xsl:with-param name="externalMetadataUrl">
                        <xsl:value-of select="$externalMetadataURL"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$type='collection'">
                <xsl:call-template name="collectionSummaryList">
                    <xsl:with-param name="handle">
                        <xsl:value-of select="$handle"/>
                    </xsl:with-param>
                    <xsl:with-param name="externalMetadataUrl">
                        <xsl:value-of select="$externalMetadataURL"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="$type='item'">
                <xsl:call-template name="itemSummaryList">
                    <xsl:with-param name="handle">
                        <xsl:value-of select="$handle"/>
                    </xsl:with-param>
                    <xsl:with-param name="externalMetadataUrl">
                        <xsl:value-of select="$externalMetadataURL"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="communitySummaryList">
        <xsl:param name="handle"/>
        <xsl:param name="externalMetadataUrl"/>

        <xsl:variable name="metsDoc" select="document($externalMetadataUrl)"/>

        <div class="community-browser-row">
            <a href="{$metsDoc/mets:METS/@OBJID}">
                <xsl:choose>
                    <xsl:when test="dri:list[@n=(concat($handle, ':dc.title')) and descendant::text()]">
                        <xsl:apply-templates select="dri:list[@n=(concat($handle, ':dc.title'))]/dri:item"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
                <!--Display community strengths (item counts) if they exist-->
                <xsl:if test="string-length($metsDoc/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='format'][@qualifier='extent'][1]) &gt; 0">
                    <xsl:text> [</xsl:text>
                    <xsl:value-of
                            select="$metsDoc/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='format'][@qualifier='extent'][1]"/>
                    <xsl:text>]</xsl:text>
                </xsl:if>
            </a>
            <div class="artifact-info">
            <xsl:if test="dri:list[@n=(concat($handle, ':dc.description.abstract'))]/dri:item">
                <p>
                    <xsl:apply-templates select="dri:list[@n=(concat($handle, ':dc.description.abstract'))]/dri:item[1]"/>
                </p>
            </xsl:if>
        </div>

        </div>
    </xsl:template>

    <xsl:template name="collectionSummaryList">
        <xsl:param name="handle"/>
        <xsl:param name="externalMetadataUrl"/>

        <xsl:call-template name="communitySummaryList">
            <xsl:with-param name="handle">
                <xsl:value-of select="$handle"/>
            </xsl:with-param>
            <xsl:with-param name="externalMetadataUrl">
                <xsl:value-of select="$externalMetadataUrl"/>
            </xsl:with-param>
        </xsl:call-template>

    </xsl:template>

    <xsl:template name="itemSummaryList">
        <xsl:param name="handle"/>
        <xsl:param name="externalMetadataUrl"/>

        <xsl:variable name="metsDoc" select="document($externalMetadataUrl)"/>

        <div class="row ds-artifact-item ">

            <!--Generates thumbnails (if present)-->
            <div class="col-sm-3 hidden-xs">
                <xsl:apply-templates select="$metsDoc/mets:METS/mets:fileSec" mode="artifact-preview">
                    <xsl:with-param name="href" select="concat($context-path, '/handle/', $handle)"/>
                </xsl:apply-templates>
            </div>


            <div class="col-sm-9 artifact-description">
                <!-- <JR> - 2023-06-13: TODO: Try rendering uk.displayTitle when present, instead of dc.title in artifact description -->
                <!-- <JR> - 2023-06-13: TODO: Add template for rendering translated title and try rendering uk.displayTitle.translated when present, instead of dc.title.translated -->
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:choose>
                            <xsl:when test="$metsDoc/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/@withdrawn">
                                <xsl:value-of select="$metsDoc/mets:METS/@OBJEDIT"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat($context-path, '/handle/', $handle)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <h4 class="discovery-item-title">
                        <xsl:choose>
                            <xsl:when test="dri:list[@n=(concat($handle, ':uk.displayTitle'))]">
                                 <xsl:call-template name="utility-parse-display-title">
                                    <xsl:with-param name="title-string" select="$metsDoc/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='displayTitle']"/>
                                 </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="dri:list[@n=(concat($handle, ':dc.title'))]">
                                        <xsl:apply-templates select="dri:list[@n=(concat($handle, ':dc.title'))]/dri:item"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                        <!-- Generate COinS with empty content per spec but force Cocoon to not create a minified tag  -->
                        <span class="Z3988">
                            <xsl:attribute name="title">
                                <xsl:for-each select="$metsDoc/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim">
                                    <xsl:call-template name="renderCOinS"/>
                                </xsl:for-each>
                            </xsl:attribute>
                            <xsl:text>&#160;</xsl:text>
                            <!-- non-breaking space to force separating the end tag -->
                        </span>
                    </h4>
                </xsl:element>
                <!-- <JR> 2023-06-16: TODO: Add uk.displayTitle.translated or dc.title.translated when available, see above for implementation -->
                <div class="artifact-info">
                    <xsl:choose>
                        <xsl:when test="dri:list[@n=(concat($handle, ':uk.displayTitle.translated'))]">
                            <div class="item-title-translated">
                                <h5 class="discovery-item-title-translated">
                                    <xsl:call-template name="utility-parse-display-title">
                                        <xsl:with-param name="title-string" select="$metsDoc/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='displayTitle'][@qualifier='translated']"/>
                                    </xsl:call-template>
                                </h5>
                            </div>
                            <xsl:for-each select="$metsDoc/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='displayTitle'][@qualifier='translated']">
                                <xsl:if test="not(position() = 1)">
                                    <div class="item-title-translated-other">
                                        <h5 class="discovery-item-title-translated">
                                            <xsl:call-template name="utility-parse-display-title">
                                                <xsl:with-param name="title-string" select="./node()"/>
                                            </xsl:call-template>
                                        </h5>
                                    </div>
                                    <!-- <xsl:value-of select="./node()"/>-->
                                    <!-- <xsl:if test="count(following-sibling::dim:field[@element='displayTitle'][@qualifier='translated']) != 0">
                                        <xsl:text>; </xsl:text>
                                        <br/>
                                    </xsl:if> -->
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="dri:list[@n=(concat($handle, ':dc.title.translated'))]">
                                    <div class="item-title-translated">
                                        <h5 class="discovery-item-title-translated">
                                            <xsl:apply-templates select="dri:list[@n=(concat($handle, ':dc.title.translated'))]/dri:item"/>
                                        </h5>
                                    </div>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- <JR> - 2024-02-06: Adding template for additional info row -->
                    <xsl:call-template name="discovery-additional-info">
                        <xsl:with-param name="handleID" select="$handle"/>
                    </xsl:call-template>

                    <xsl:call-template name="discovery-authors">
                        <xsl:with-param name="handle" select="$handle"/>
                        <xsl:with-param name="metsDoc" select="$metsDoc"/>
                    </xsl:call-template>
                    
                    <xsl:text> </xsl:text>
                    <xsl:if test="dri:list[@n=(concat($handle, ':dc.date.issued'))]">
                        <span class="publisher-date h4">   <small>
                            <xsl:text>(</xsl:text>
                            <xsl:if test="dri:list[@n=(concat($handle, ':dc.publisher'))]">
                                <span class="publisher">
                                    <xsl:apply-templates select="dri:list[@n=(concat($handle, ':dc.publisher'))]/dri:item"/>
                                </span>
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <xsl:if test="dri:list[@n=(concat($handle, ':dc.publisher.publicationPlace'))]">
                                <span class="publisherPlace">
                                    <xsl:apply-templates select="dri:list[@n=(concat($handle, ':dc.publisher.publicationPlace'))]/dri:item"/>
                                </span>
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                            <span class="date">
                                <xsl:value-of
                                        select="substring(dri:list[@n=(concat($handle, ':dc.date.issued'))]/dri:item,1,10)"/>
                            </span>
                            <xsl:text>)</xsl:text>
                            </small></span>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="dri:list[@n=(concat($handle, ':dc.description.abstract'))]/dri:item/dri:hi">
                            <div class="abstract">
                                <xsl:for-each select="dri:list[@n=(concat($handle, ':dc.description.abstract'))]/dri:item">
                                    <xsl:apply-templates select="."/>
                                    <xsl:text>...</xsl:text>
                                    <br/>
                                </xsl:for-each>

                            </div>
                        </xsl:when>
                        <xsl:when test="dri:list[@n=(concat($handle, ':fulltext'))]">
                            <div class="abstract">
                                <xsl:for-each select="dri:list[@n=(concat($handle, ':fulltext'))]/dri:item">
                                    <xsl:apply-templates select="."/>
                                    <xsl:text>...</xsl:text>
                                    <br/>
                                </xsl:for-each>
                            </div>
                        </xsl:when>
                        <xsl:when test="dri:list[@n=(concat($handle, ':dc.description.abstract'))]/dri:item">
                        <div class="abstract">
                                <xsl:value-of select="util:shortenString(dri:list[@n=(concat($handle, ':dc.description.abstract'))]/dri:item[1], 220, 10)"/>
                        </div>
                    </xsl:when>
                    </xsl:choose>
                </div>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="dri:div[@id='aspect.discovery.SimpleSearch.div.discovery-filters-wrapper']/dri:head">
        <h3 class="ds-div-head discovery-filters-wrapper-head hidden">
            <xsl:apply-templates/>
        </h3>
    </xsl:template>

    <xsl:template match="dri:list[@id='aspect.discovery.SimpleSearch.list.primary-search']" priority="3">
        <xsl:apply-templates select="dri:head"/>
        <fieldset>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">
                    <!-- Provision for the sub list -->
                    <xsl:text>ds-form-</xsl:text>
                    <xsl:text>list </xsl:text>
                    <xsl:if test="count(dri:item) > 3">
                        <xsl:text>thick </xsl:text>
                    </xsl:if>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates select="*[not(name()='label' or name()='head')]" />
        </fieldset>
    </xsl:template>

    <xsl:template name="discovery-additional-info-type">
        <xsl:param name="handleID"/>
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
            <xsl:when test="dri:list[@n=(concat($handleID, ':dc.type.obdHierarchy', $languageCapitalized))]">
                
                <span class="label label-additional-info label-discovery-publication-type" aria-haspopup="true">
                    <xsl:value-of 
                        select="substring-after(substring-after(dri:list[@n=(concat($handleID, 
                        ':dc.type.obdHierarchy', $languageCapitalized))]/dri:item[1],'::'),'::')"/>
                </span>

            </xsl:when>
            <xsl:otherwise>
                    
                <span type="button" class="label label-additional-info label-discovery-publication-type" aria-haspopup="true">
                    <xsl:text>unknown type</xsl:text>
                </span>

            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="discovery-authors">
        <xsl:param name="handle"/>
        <xsl:param name="metsDoc"/>
        <div class="row authors-row">
            <div class="col-xs-12 col-sm-12 col-md-12 discovery-authors-row-column">
        
            <xsl:choose>
                <xsl:when test="dri:list[@n=(concat($handle, ':dc.contributor.author'))]">
                    <xsl:for-each select="dri:list[@n=(concat($handle, ':dc.contributor.author'))]/dri:item">
                        <xsl:if test="count(preceding-sibling::dri:item) &lt;= 2">
                            <xsl:variable name="author">
                                <xsl:apply-templates select="."/>
                            </xsl:variable>
                            <h4 class="discovery-author">
                                <!--Check authority in the mets document-->
                                <xsl:if test="$metsDoc/mets:METS/mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim/dim:field[@element='contributor' and @qualifier='author' and . = $author]/@authority">
                                    <xsl:attribute name="class">
                                        <xsl:text>ds-dc_contributor_author-authority</xsl:text>
                                    </xsl:attribute>
                                </xsl:if>
                                <xsl:apply-templates select="."/>
                            </h4>
                        </xsl:if>

                        <xsl:if test="count(preceding-sibling::dri:item) &lt;2 
                        and not(count(following-sibling::dri:item) = 0)">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                        <xsl:if test="count(preceding-sibling::dri:item) = 2">
                            <xsl:text>; </xsl:text><h4 class="discovery-author">et al.</h4>
                        </xsl:if>
                    </xsl:for-each>

                    <xsl:if test="count(dri:list[@n=(concat($handle, ':dc.contributor.author'))]/dri:item) > 3">
                        <div class="row authors-row">
                            <div class="col-xs-12 col-sm-12 col-md-12 discovery-authors-row-column">
                                <a role="button" data-toggle="collapse" data-parent="#discovery-authors" 
                                    href="#collapse-authors" aria-expanded="false" aria-controls="collapse-discovery-authors">
                                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-author-collapse</i18n:text>
                                </a>
                            </div>
                        </div>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="dri:list[@n=(concat($handle, ':dc.creator'))]">
                    <xsl:for-each select="dri:list[@n=(concat($handle, ':dc.creator'))]/dri:item">
                        <xsl:apply-templates select="."/>
                        <xsl:if test="count(following-sibling::dri:item) != 0">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="dri:list[@n=(concat($handle, ':dc.contributor'))]">
                    <xsl:for-each select="dri:list[@n=(concat($handle, ':dc.contributor'))]/dri:item">
                        <xsl:apply-templates select="."/>
                        <xsl:if test="count(following-sibling::dri:item) != 0">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                </xsl:otherwise>
            </xsl:choose>
            </div>
        </div>
    </xsl:template>

    <xsl:template name="discovery-additional-info-version">
        <xsl:param name="handleID"/>
        
        <xsl:choose>
            <xsl:when test="dri:list[@n=(concat($handleID, ':dc.type.version'))]">

                <xsl:variable name="publicationVersionValue">
                    <xsl:value-of select="substring-after(dri:list[@n=(concat($handleID, 
                                    ':dc.type.version'))]/dri:item[1], 'info:eu-repo/semantics/')" />
                </xsl:variable>
                    
                <span id="discovery-publication-version" class="label label-additional-info label-discovery-publication-version" aria-haspopup="true">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-publication-version-<xsl:value-of select="$publicationVersionValue" />
                    </i18n:text>
                </span>
                
            </xsl:when>
            <xsl:otherwise>
                
                <span id="discovery-publication-version" class="label label-additional-info label-discovery-publication-version" aria-haspopup="true">
                    <xsl:text>unknown version</xsl:text>
                </span>
                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="discovery-additional-info-access">
        <xsl:param name="handleID"/>

        <xsl:choose>
            <xsl:when test="dri:list[@n=(concat($handleID, ':dcterms.accessRights'))]">

                <xsl:variable name="publicationAccessRightsValue">
                    <xsl:value-of select="concat('xmlui.dri2xhtml.METS-1.0.item-publication-accessRights.',dri:list[@n=(concat($handleID, 
                                    ':dcterms.accessRights'))]/dri:item[1])" />
                </xsl:variable>
                
                <xsl:choose>
                    <xsl:when test="dri:list[@n=(concat($handleID, ':dc.date.embargoEndDate'))]">
                        <xsl:variable name="embargoEndDate" 
                        select="dri:list[@n=(concat($handleID, ':dc.date.embargoEndDate'))]/dri:item[1]"/>

                        <span class="label label-additional-info label-discovery-publication-accessRights"
                            data-toggle="tooltip" data-placement="bottom" 
                            aria-label="Access information">
                            <xsl:if test="$active-locale = 'cs'">
                                <xsl:attribute name="title"><xsl:text>Přístupné od: </xsl:text><xsl:value-of select="$embargoEndDate"/></xsl:attribute>
                            </xsl:if>
                            <xsl:if test="$active-locale = 'en'">
                                <xsl:attribute name="title"><xsl:text>Available from: </xsl:text><xsl:value-of select="$embargoEndDate"/></xsl:attribute>
                            </xsl:if>
                            
                            <i18n:text><xsl:value-of select="$publicationAccessRightsValue" /></i18n:text>
                        </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <span class="label label-additional-info label-discovery-publication-accessRights" 
                            aria-label="Access information">
                            <i18n:text><xsl:value-of select="$publicationAccessRightsValue" /></i18n:text>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <span class="label label-additional-info label-discovery-publication-accessRights" aria-haspopup="true">
                    <xsl:text>uknown access rights</xsl:text>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="discovery-additional-info-licence">
        <xsl:param name="handleID"/>
        
        <xsl:choose>
            <xsl:when test="dri:list[@n=(concat($handleID, ':dc.rights'))] and dri:list[@n=(concat($handleID, ':dcterms.license'))]">
                <xsl:variable name="licenseText" select="dri:list[@n=(concat($handleID, ':dc.rights'))]/dri:item[1]"/>
                <xsl:variable name="licenseUri" select="dri:list[@n=(concat($handleID, ':dcterms.license'))]/dri:item[1]"/>
                
                <div class="btn-group label-group discovery-additional-item-info-licence" 
                    data-toggle="tooltip" data-placement="bottom" title="{$licenseText}" role="group" aria-label="License information">
                    <xsl:call-template name="discovery-DIM-license-icons">
                        <xsl:with-param name="licenseText" select="$licenseText"/>
                        <xsl:with-param name="licenseUri" select="$licenseUri" />
                    </xsl:call-template>
                </div>
            </xsl:when>
            <xsl:otherwise>
                    <span class="label label-additional-info label-discovery-publication-licence" label="Uknown licence" aria-label="Licence information" aria-haspopup="true">
                        <xsl:text>unknown license</xsl:text>
                    </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="discovery-additional-info">
        <xsl:param name="handleID" />
        <div class="row discovery-additional-info-row">
            <div class="col-xs-6 col-sm-6 col-md-6 discovery-additional-info-column">
            
                <div aria-label="additional-item-info-type" role="group" class="btn-group label-group">
                    <xsl:call-template name="discovery-additional-info-type">
                        <xsl:with-param name="handleID" select="$handleID"/>
                    </xsl:call-template>
                </div>
            </div>
            <div class="col-xs-6 col-sm-6 col-md-6 discovery-additional-info-column discovery-additional-info-column-right">
                <div class="btn-group label-group discovery-additional-info-access" role="group" aria-label="additional-item-info-access">
                    <xsl:call-template name="discovery-additional-info-access">
                        <xsl:with-param name="handleID" select="$handleID"/>
                    </xsl:call-template>
                </div>
            
            </div>          
        </div>
        <div class="row discovery-additional-info-row">
            <div class="col-xs-6 col-sm-6 col-md-6 discovery-additional-info-column">
                <div aria-label="additional-item-info-version" role="group" class="btn-group label-group">
                    <xsl:call-template name="discovery-additional-info-version">
                        <xsl:with-param name="handleID" select="$handleID"/>
                    </xsl:call-template>
                </div>
            </div>
            <div class="col-xs-6 col-sm-6 col-md-6 discovery-additional-info-column discovery-additional-info-column-right">
                <div aria-label="additional-item-info-licence" role="group" class="btn-group label-group discovery-additional-info-licence">
                    <xsl:call-template name="discovery-additional-info-licence">
                        <xsl:with-param name="handleID" select="$handleID"/>
                    </xsl:call-template>
                </div>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="dri:list[@id='aspect.discovery.SimpleSearch.list.primary-search']//dri:item[dri:field[@id='aspect.discovery.SimpleSearch.field.query']]" priority="3">
        <div>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">
                    <xsl:text>ds-form-item row</xsl:text>
                </xsl:with-param>
            </xsl:call-template>

            <div class="col-sm-3">
                <p>
                    <xsl:apply-templates select="dri:field[@id='aspect.discovery.SimpleSearch.field.scope']"/>
                </p>
            </div>

            <div class="col-sm-9">
                <p class="input-group">
                    <xsl:apply-templates select="dri:field[@id='aspect.discovery.SimpleSearch.field.query']"/>
                    <span class="input-group-btn">
                        <xsl:apply-templates select="dri:field[@id='aspect.discovery.SimpleSearch.field.submit']"/>
                    </span>
                </p>
            </div>
        </div>

        <xsl:if test="dri:item[@id='aspect.discovery.SimpleSearch.item.did-you-mean']">
            <div class="row">
                <div class="col-sm-offset-3 col-sm-9">
                    <xsl:apply-templates select="dri:item[@id='aspect.discovery.SimpleSearch.item.did-you-mean']"/>
                </div>
            </div>
        </xsl:if>

        <div class="row">
            <div class="col-sm-offset-3 col-sm-9" id="filters-overview-wrapper-squared"/>
        </div>
    </xsl:template>

    <xsl:template match="dri:list[@id='aspect.discovery.SimpleSearch.list.primary-search']//dri:item[dri:field[@id='aspect.discovery.SimpleSearch.field.query'] and not(dri:field[@id='aspect.discovery.SimpleSearch.field.scope'])]" priority="3">
        <div>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">
                    <xsl:text>ds-form-item row</xsl:text>
                </xsl:with-param>
            </xsl:call-template>

            <div class="col-sm-12">
                <p class="input-group">
                    <xsl:apply-templates select="dri:field[@id='aspect.discovery.SimpleSearch.field.query']"/>
                    <span class="input-group-btn">
                        <xsl:apply-templates select="dri:field[@id='aspect.discovery.SimpleSearch.field.submit']"/>
                    </span>
                </p>
            </div>
        </div>
        <xsl:if test="dri:item[@id='aspect.discovery.SimpleSearch.item.did-you-mean']">
            <xsl:apply-templates select="dri:item[@id='aspect.discovery.SimpleSearch.item.did-you-mean']"/>
        </xsl:if>
        <div id="filters-overview-wrapper-squared"/>
    </xsl:template>

    <xsl:template match="dri:div[@id='aspect.discovery.SimpleSearch.div.search-results']/dri:head">
        <h4>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class" select="@rend"/>
            </xsl:call-template>
            <xsl:apply-templates />
        </h4>
    </xsl:template>

    <xsl:template match="dri:table[@id='aspect.discovery.SimpleSearch.table.discovery-filters']">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="dri:table[@id='aspect.discovery.SimpleSearch.table.discovery-filters']/dri:row">
        <xsl:variable name="display-value">
            <xsl:choose>
                <xsl:when test="dri:cell/dri:field[@rend = 'discovery-filter-display-value']/dri:value">
                    <xsl:value-of select="stringescapeutils:escapeEcmaScript(dri:cell/dri:field[@rend = 'discovery-filter-display-value']/dri:value)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="stringescapeutils:escapeEcmaScript(dri:cell/dri:field[@rend = 'discovery-filter-input']/dri:value)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <script type="text/javascript">
            <xsl:text>
                if (!window.DSpace) {
                    window.DSpace = {};
                }
                if (!window.DSpace.discovery) {
                    window.DSpace.discovery = {};
                }
                if (!window.DSpace.discovery.filters) {
                    window.DSpace.discovery.filters = [];
                }
                window.DSpace.discovery.filters.push({
                    type: '</xsl:text><xsl:value-of select="stringescapeutils:escapeEcmaScript(dri:cell/dri:field[starts-with(@n, 'filtertype')]/dri:value/@option)"/><xsl:text>',
                    relational_operator: '</xsl:text><xsl:value-of select="stringescapeutils:escapeEcmaScript(dri:cell/dri:field[starts-with(@n, 'filter_relational_operator')]/dri:value/@option)"/><xsl:text>',
                    query: '</xsl:text><xsl:value-of select="stringescapeutils:escapeEcmaScript(dri:cell/dri:field[@rend = 'discovery-filter-input']/dri:value)"/><xsl:text>',
                    display_value: '</xsl:text><xsl:value-of select="$display-value"/><xsl:text>'
                });
            </xsl:text>
        </script>
    </xsl:template>

    <xsl:template match="dri:row[starts-with(@id, 'aspect.discovery.SimpleSearch.row.filter-new-')]">
        <script type="text/javascript">
            <xsl:text>
                if (!window.DSpace) {
                    window.DSpace = {};
                }
                if (!window.DSpace.discovery) {
                    window.DSpace.discovery = {};
                }
                if (!window.DSpace.discovery.filters) {
                    window.DSpace.discovery.filters = [];
                }
            </xsl:text>
        </script>
        <script>
        <xsl:text>
            if (!window.DSpace.i18n) {
                window.DSpace.i18n = {};
            } 
            if (!window.DSpace.i18n.discovery) {
                window.DSpace.i18n.discovery = {};
            }
        </xsl:text>
            <xsl:for-each select="dri:cell/dri:field[@type='select']">
                <xsl:variable name="last_underscore_index">
                    <xsl:call-template name="lastCharIndex">
                        <xsl:with-param name="pText" select="@n"/>
                        <xsl:with-param name="pChar" select="'_'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="filter_name" select="substring(@n, 0, $last_underscore_index)"/>
                <xsl:text>
                    if (!window.DSpace.i18n.discovery.</xsl:text><xsl:value-of select="$filter_name"/><xsl:text>) {
                        window.DSpace.i18n.discovery.</xsl:text><xsl:value-of select="$filter_name"/><xsl:text> = {};
                    }
                </xsl:text>
                <xsl:for-each select="dri:option">
                    <xsl:text>window.DSpace.i18n.discovery.</xsl:text>
                    <xsl:value-of select="$filter_name"/>
                    <xsl:text>['</xsl:text>
                    <xsl:value-of select="@returnValue"/>
                    <xsl:text>']='</xsl:text>
                    <xsl:copy-of select="./*"/>
                    <xsl:text>';</xsl:text>
                 </xsl:for-each>
            </xsl:for-each>
        </script>
    </xsl:template>

    <xsl:template match="dri:row[@id='aspect.discovery.SimpleSearch.row.filter-controls']">
        <div>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">
                    <xsl:text>ds-form-item</xsl:text>
                </xsl:with-param>
            </xsl:call-template>

            <div>
                    <xsl:apply-templates/>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="dri:field[starts-with(@id, 'aspect.discovery.SimpleSearch.field.add-filter')]">
        <button>
            <xsl:call-template name="fieldAttributes"/>
            <xsl:attribute name="type">submit</xsl:attribute>
            <xsl:choose>
                <xsl:when test="dri:value/i18n:text">
                    <xsl:attribute name="title">
                        <xsl:apply-templates select="dri:value/*"/>
                    </xsl:attribute>
                    <xsl:attribute name="i18n:attr">
                        <xsl:text>title</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="title">
                        <xsl:value-of select="dri:value"/>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <span class="glyphicon glyphicon-plus-sign" aria-hidden="true"/>
        </button>
    </xsl:template>

    <xsl:template match="dri:field[starts-with(@id, 'aspect.discovery.SimpleSearch.field.remove-filter')]">
        <button>
            <xsl:call-template name="fieldAttributes"/>
            <xsl:attribute name="type">submit</xsl:attribute>
            <xsl:choose>
                <xsl:when test="dri:value/i18n:text">
                    <xsl:attribute name="title">
                        <xsl:apply-templates select="dri:value/*"/>
                    </xsl:attribute>
                    <xsl:attribute name="i18n:attr">
                        <xsl:text>title</xsl:text>
                    </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="title">
                        <xsl:value-of select="dri:value"/>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <span class="glyphicon glyphicon-minus-sign" aria-hidden="true"/>
        </button>
    </xsl:template>

    <xsl:template name="lastCharIndex">
        <xsl:param name="pText"/>
        <xsl:param name="pChar" select="' '"/>

        <xsl:variable name="vRev">
            <xsl:call-template name="reverse">
                <xsl:with-param name="pStr" select="$pText"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:value-of select="string-length($pText) - string-length(substring-before($vRev, $pChar))"/>
    </xsl:template>

    <xsl:template name="reverse">
        <xsl:param name="pStr"/>

        <xsl:variable name="vLength" select="string-length($pStr)"/>
        <xsl:choose>
            <xsl:when test="$vLength = 1">
                <xsl:value-of select="$pStr"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="vHalfLength" select="floor($vLength div 2)"/>
                <xsl:variable name="vrevHalf1">
                    <xsl:call-template name="reverse">
                        <xsl:with-param name="pStr"
                                        select="substring($pStr, 1, $vHalfLength)"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="vrevHalf2">
                    <xsl:call-template name="reverse">
                        <xsl:with-param name="pStr"
                                        select="substring($pStr, $vHalfLength+1)"/>
                    </xsl:call-template>
                </xsl:variable>

                <xsl:value-of select="concat($vrevHalf2, $vrevHalf1)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="dri:div[@rend='controls-gear-wrapper' and @n='search-controls-gear']">
        <div class="btn-group sort-options-menu pull-right">
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">btn-group discovery-sort-options-menu pull-right</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="renderGearButton"/>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="dri:list[@rend='gear-selection' and @n='sort-options']">
        <ul class="dropdown-menu" role="menu">
            <xsl:apply-templates/>
        </ul>
    </xsl:template>

    <xsl:template match="dri:list[@rend='gear-selection' and @n='sort-options']/dri:item">
        <xsl:if test="contains(@rend, 'dropdown-header') and position() > 1">
            <li class="divider"/>
        </xsl:if>
        <li>
            <xsl:call-template name="standardAttributes"/>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <xsl:template match="dri:list[@rend='gear-selection' and @n='sort-options']/dri:item/dri:xref">
        <a href="{@target}" class="{@rend}">
            <span>
                <xsl:attribute name="class">
                    <xsl:text>glyphicon glyphicon-ok btn-xs</xsl:text>
                    <xsl:choose>
                        <xsl:when test="contains(../@rend, 'gear-option-selected')">
                            <xsl:text> active</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text> invisible</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </span>
            <xsl:apply-templates/>
        </a>
    </xsl:template>


    <xsl:template
            match="dri:div[@n='masked-page-control'][dri:div/@n='search-controls-gear']">
        <xsl:variable name="other_content_besides_gear"
                      select="*[not(@rend='controls-gear-wrapper' and @n='search-controls-gear')]"/>
        <xsl:if test="$other_content_besides_gear">
            <div>
                <xsl:call-template name="standardAttributes"/>
                <xsl:apply-templates select="$other_content_besides_gear"/>
            </div>
        </xsl:if>

    </xsl:template>


</xsl:stylesheet>
