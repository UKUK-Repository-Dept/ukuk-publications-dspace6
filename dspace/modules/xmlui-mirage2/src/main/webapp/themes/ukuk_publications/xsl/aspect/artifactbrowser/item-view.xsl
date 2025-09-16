<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Rendering specific to the item display page.

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
    xmlns:jstring="java.lang.String"
    xmlns:rights="http://cosimo.stanford.edu/sdr/metsrights/"
    xmlns:confman="org.dspace.core.ConfigurationManager"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util jstring rights confman">
    <xsl:import href="item-view-license.xsl" />
    <xsl:import href="../../custom/utility.xsl"/>

    <xsl:output indent="yes"/>

    <xsl:variable name="itemHandle">
        <xsl:choose>
            <xsl:when test="$pagemeta/dri:metadata[@element='identifier'][@qualifier='handle']">
                <xsl:value-of select="$pagemeta/dri:metadata[@element='identifier'][@qualifier='handle']"/>
            </xsl:when>
            <xsl:when test="$pagemeta/dri:metadata[@element='focus'][@qualifier='object']">
                <xsl:variable name="handleWithPrefix" select="$pagemeta/dri:metadata[@element='focus'][@qualifier='object']"/>
                <xsl:value-of select="substring-after($handleWithPrefix, 'hdl:')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>no handle</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="solrURL">
        <!--<xsl:text>http://localhost:8080/solr/search</xsl:text>-->
        <xsl:value-of select="concat(confman:getProperty('solr.server'), '/search')" />
    </xsl:variable>

    <!-- Grouping the keyword fields based on language -->
    <xsl:key name="keyword-language-group" match="dim:field[@element='subject' and @qualifier='keyword']" use="@language" />
    <xsl:key name="abstract-language-group" match="dim:field[@element='description' and @qualifier='abstract']" use="@language"/>

    <xsl:template name="itemSummaryView-DIM">
        <!-- Generate the info about the item from the metadata section -->
        <xsl:apply-templates select="./mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
        mode="itemSummaryView-DIM"/>

        <xsl:copy-of select="$SFXLink" />

        <!-- Generate the Creative Commons license information from the file section (DSpace deposit license hidden by default)-->
        <xsl:if test="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']">
            <div class="license-info table">
                <p>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.license-text</i18n:text>
                </p>
                <ul class="list-unstyled">
                    <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CC-LICENSE' or @USE='LICENSE']" mode="simple"/>
                </ul>
            </div>
        </xsl:if>


    </xsl:template>

    <!-- An item rendered in the detailView pattern, the "full item record" view of a DSpace item in Manakin. -->
    <xsl:template name="itemDetailView-DIM">
        <!-- Output all of the metadata about the item from the metadata section -->
        <xsl:apply-templates select="mets:dmdSec/mets:mdWrap[@OTHERMDTYPE='DIM']/mets:xmlData/dim:dim"
                             mode="itemDetailView-DIM"/>

        <!-- Generate the bitstream information from the file section -->
        <xsl:choose>
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                <h3><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h3>
                <div class="file-list">
                    <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE' or @USE='CC-LICENSE']">
                        <xsl:with-param name="context" select="."/>
                        <xsl:with-param name="primaryBitstream" select="./mets:structMap[@TYPE='LOGICAL']/mets:div[@TYPE='DSpace Item']/mets:fptr/@FILEID"/>
                    </xsl:apply-templates>
                </div>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="./mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="./mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemDetailView-DIM" />
            </xsl:when>
            <xsl:otherwise>
                <h2><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-head</i18n:text></h2>
                <table class="ds-table file-list">
                    <tr class="ds-table-header-row">
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-file</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text></th>
                        <th><i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-view</i18n:text></th>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <p><i18n:text>xmlui.dri2xhtml.METS-1.0.item-no-files</i18n:text></p>
                        </td>
                    </tr>
                </table>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>


    <xsl:template match="dim:dim" mode="itemSummaryView-DIM">
        <div class="item-summary-view-metadata">
            <div class="row item-view-titles-row">
                <div class="col-sm-12 col-md-12 item-view-title-column">
                    <xsl:call-template name="itemSummaryView-DIM-title"/>
                </div>
                <div class="col-sm-12 col-md-12 item-view-translated-title-column">
                    <xsl:call-template name="itemSummaryView-DIM-title-translated"/>
                </div>
            </div>
            <div class="row item-view-additional-info-row">
                <div class="col-xs-12 col-sm-12 item-view-additional-info-column">
                    <div class="btn-group label-group" role="group" aria-label="additional-item-info">
                        <xsl:call-template name="itemSummaryView-DIM-publication-type"/>
                    </div>
                    <div class="btn-group label-group" role="group" aria-label="additional-item-info">
                        <xsl:call-template name="itemSummaryView-DIM-license-icons"/>
                    </div>
                    <div class="btn-group label-group" role="group" aria-label="additional-item-info">
                        <xsl:call-template name="itemSummaryView-DIM-item-language-icon"/>
                    </div>
                    <!-- <JR> - 2023-11-08: TODO: Merge dropdown for selecting other versions of the publication with the label used to display current version -->
                    <div class="btn-group label-group" role="group" aria-label="additional-item-versions" style="float: right;">
                        <xsl:call-template name="itemSummaryView-DIM-publication-version"/>
                    </div>
    
                </div>
            </div>

            <div class="row">
                <div class="col-sm-4">
                    <div class="row">
                        <div class="col-xs-12 col-sm-12 item-view-thumbnail-column">
                            <xsl:call-template name="itemSummaryView-DIM-thumbnail"/>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-xs-12 col-sm-12 item-view-file-section-column">
                            <xsl:call-template name="itemSummaryView-DIM-file-section"/>
                        </div>
                    </div>
                    <xsl:call-template name="itemSummaryView-DIM-authors"/>
                    <xsl:call-template name="itemSummaryView-DIM-date"/>
                    <xsl:call-template name="itemSummaryView-DIM-source-publication-name"/>
                    <xsl:call-template name="itemSummaryView-DIM-publisher-publicationPlace"/>
                    <xsl:call-template name="itemSummaryView-DIM-source-publication-volume-issue"/>
                    <xsl:call-template name="itemSummaryView-DIM-source-publication-isbn-issn" />
                    <xsl:call-template name="itemSummaryView-DIM-publication-isbn-issn" />
                    <xsl:call-template name="itemSummaryView-DIM-fundingReference" />
                    <xsl:if test="$ds_item_view_toggle_url != ''">
                        <xsl:call-template name="itemSummaryView-show-full"/>
                    </xsl:if>
                    <xsl:call-template name="itemSummaryView-collections"/>
                </div>
                <div class="col-sm-8">
                    <!-- <JR> - 2024-01-30: We are still unable to generate citations, disabling this template,
                                for now
                    -->
                    <!-- <xsl:call-template name="itemSummaryView-DIM-citation"/> -->
                    <xsl:call-template name="itemSummaryView-DIM-DOI"/>
                    <xsl:call-template name="itemSummaryView-DIM-abstract"/>
                    <xsl:call-template name="itemSummaryView-DIM-keywords"/>
                    <xsl:call-template name="itemSummaryView-DIM-URI"/>
                    <xsl:call-template name="itemSummaryView-DIM-otherIdentifiers"/>
                    <xsl:call-template name="license">
                        <xsl:with-param name="metadataURL" select="./dri:referenceSet/dri:reference/@url"/>
                    </xsl:call-template>
                    <xsl:call-template name="itemSummaryView-DIM-other-output-versions"/>
                </div>
            </div>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-title">
        <!-- <JR> - 2023-06-13: TODO: try handling uk.displayTitle when present -->
        <xsl:choose>
            <xsl:when test="count(dim:field[@element='displayTitle'][not(@qualifier)]) &gt; 1">
                <xsl:call-template name="itemSummaryView-DIM-displayTitle"/>
            </xsl:when>
            <xsl:when test="count(dim:field[@element='displayTitle'][not(@qualifier)]) = 1">
                <xsl:call-template name="itemSummaryView-DIM-displayTitle"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) &gt; 1">
                        <xsl:for-each select="dim:field[@element='title'][not(@qualifier)]">
                            <xsl:choose>
                                <xsl:when test="position() = last()">
                                    <h2 class="first-page-header item-title">
                                        <xsl:value-of select="./node()"/>
                                    </h2>
                                </xsl:when>
                                <xsl:when test="position() = 1">
                                    <h2 class="first-page-header item-title">
                                            <xsl:value-of select="./node()"/>
                                    </h2>
                                    <p class="lead item-view-title-lead" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <h2 class="first-page-header item-title">
                                        <xsl:value-of select="./node()"/>
                                    </h2>
                                    <p class="lead item-view-title-lead" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="count(dim:field[@element='title'][not(@qualifier)]) = 1">
                        <xsl:choose>
                            <xsl:when test="dim:field[@element='title'][@qualifier='translated']">
                                <h2 class="first-page-header item-title">
                                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                                </h2>
                            </xsl:when>
                            <xsl:otherwise>
                                <h2 class="page-header first-page-header item-title">
                                    <xsl:value-of select="dim:field[@element='title'][not(@qualifier)][1]/node()"/>
                                </h2>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <h2 class="page-header first-page-header item-title">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </h2>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-displayTitle">
        <!-- <JR> - 2023-06-16: Call utility-parse-display-title form utility.xsl to handle rendering of the uk.displayTitle -->
        <!-- <JR> - 2023-06-23: Reworked title generation, if bugy, use default implementation in official DSpace repo -->
        
        <xsl:for-each select="dim:field[@element='displayTitle'][not(@qualifier)]">
            <xsl:choose>
                <xsl:when test="position() = last()">
                    <h2 class="first-page-header item-title">
                        <xsl:call-template name="utility-parse-display-title">
                            <xsl:with-param name="title-string" select="./node()"/>
                        </xsl:call-template>
                    </h2>
                </xsl:when>
                <xsl:when test="position() = 1">
                    <h2 class="first-page-header item-title">
                        <xsl:call-template name="utility-parse-display-title">
                            <xsl:with-param name="title-string" select="./node()"/>
                        </xsl:call-template>
                    </h2>
                    <p class="lead item-view-title-lead" />
                </xsl:when>
                <xsl:otherwise>
                    <h2 class="first-page-header item-title">
                        <xsl:call-template name="utility-parse-display-title">
                            <xsl:with-param name="title-string" select="./node()"/>
                        </xsl:call-template>
                    </h2>
                    <p class="lead item-view-title-lead" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <!-- <JR> - 2023-06-14: Render translated title -->
    <xsl:template name="itemSummaryView-DIM-title-translated">
        <xsl:choose>
            <xsl:when test="count(dim:field[@element='displayTitle'][@qualifier='translated']) &gt; 1">
                <xsl:call-template name="itemSummaryView-DIM-displayTitle-translated" />
            </xsl:when>
            <xsl:when test="count(dim:field[@element='displayTitle'][@qualifier='translated']) = 1">
                <xsl:call-template name="itemSummaryView-DIM-displayTitle-translated" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="count(dim:field[@element='title'][@qualifier='translated']) &gt; 1">
                        <xsl:for-each select="dim:field[@element='title'][@qualifier='translated']">
                            <xsl:choose>
                                <xsl:when test="position() = last()">
                                    <h3 class="page-header first-page-header item-title">
                                        <xsl:text>( </xsl:text> <xsl:value-of select="./node()"/> <xsl:text> )</xsl:text>
                                    </h3>
                                </xsl:when>
                                <xsl:when test="position() = 1">
                                    <h3 class="first-page-header item-title">
                                        <xsl:text>( </xsl:text> <xsl:value-of select="./node()"/> <xsl:text> )</xsl:text>
                                    </h3>
                                    <p class="lead item-view-title-lead" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <h3 class="first-page-header item-title">
                                        <xsl:text>( </xsl:text> <xsl:value-of select="./node()"/> <xsl:text> )</xsl:text>
                                    </h3>
                                    <p class="lead item-view-title-lead" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="count(dim:field[@element='title'][@qualifier='translated']) = 1">
                        <h3 class="page-header first-page-header item-title-translated">
                            <xsl:text>( </xsl:text><xsl:value-of select="dim:field[@element='title'][@qualifier='translated'][1]/node()"/><xsl:text> )</xsl:text>
                        </h3>
                    </xsl:when>
                    <xsl:otherwise>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-displayTitle-translated">
        <!-- <JR> - 2023-06-16: Call utility-parse-display-title form utility.xsl to handle rendering of the uk.displayTitle.translated -->
        <!-- <JR> - 2023-06-23: Reworked title.translated generation, if bugy, use implementation based on dc.title template from official DSpace repo -->
        <xsl:for-each select="dim:field[@element='displayTitle'][@qualifier='translated']">
            <xsl:choose>
                <xsl:when test="position() = last()">
                    <h3 class="page-header first-page-header item-title-translated">
                        <xsl:text>( </xsl:text>
                        <xsl:call-template name="utility-parse-display-title">
                            <xsl:with-param name="title-string" select="./node()"/>
                        </xsl:call-template>
                        <xsl:text> )</xsl:text>
                    </h3>
                </xsl:when>
                <xsl:when test="position() = 1">
                    <h3 class="first-page-header item-title-translated">
                        <xsl:text>( </xsl:text>
                        <xsl:call-template name="utility-parse-display-title">
                            <xsl:with-param name="title-string" select="./node()"/>
                        </xsl:call-template>
                        <xsl:text> )</xsl:text>
                    </h3>
                    <p class="lead item-view-title-lead" />
                </xsl:when>
                <xsl:otherwise>
                    <h3 class="first-page-header item-title-translated">
                        <xsl:text>( </xsl:text>
                        <xsl:call-template name="utility-parse-display-title">
                            <xsl:with-param name="title-string" select="./node()"/>
                        </xsl:call-template>
                        <xsl:text> )</xsl:text>
                    </h3>
                    <p class="lead item-view-title-lead" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-thumbnail">
        <div class="thumbnail">
            <xsl:choose>
                <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']">
                    <xsl:variable name="src">
                        <xsl:choose>
                            <xsl:when test="/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=../../mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID][1]/@GROUPID]">
                                <xsl:value-of
                                        select="/mets:METS/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file[@GROUPID=../../mets:fileGrp[@USE='CONTENT']/mets:file[@GROUPID=../../mets:fileGrp[@USE='THUMBNAIL']/mets:file/@GROUPID][1]/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                        select="//mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/mets:file/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <!-- Checking if Thumbnail is restricted and if so, show a restricted image --> 
                    <xsl:choose>
                        <xsl:when test="contains($src,'isAllowed=n')">
                            <img class="img-thumbnail  item-view-thumbnail" alt="Thumbnail">
                                <xsl:attribute name="data-src">
                                    <xsl:text>holder.js/126x</xsl:text>
                                    <xsl:value-of select="$thumbnail.maxheight"/>
                                    <xsl:text>/colors:#ffffff:#d22d40</xsl:text>
                                    <xsl:if test="$active-locale = 'en'">
                                        <xsl:text>/text:Thubmnail Restricted</xsl:text>
                                    </xsl:if>
                                    <xsl:if test="$active-locale = 'cs'">
                                        <xsl:text>/text:Náhled není přístupný</xsl:text>
                                    </xsl:if>
                                </xsl:attribute>
                            </img>
                        </xsl:when>
                        <xsl:otherwise>
                            <img class="img-thumbnail item-view-thumbnail" alt="Thumbnail">
                                <xsl:attribute name="src">
                                    <xsl:value-of select="$src"/>
                                </xsl:attribute>            
                            </img>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <img class="img-thumbnail  item-view-thumbnail" alt="Thumbnail">
                        <xsl:attribute name="data-src">
                            <xsl:text>holder.js/126x</xsl:text>
                            <xsl:value-of select="$thumbnail.maxheight"/>
                            <xsl:text>/colors:#ffffff:#d22d40</xsl:text>
                            <xsl:if test="$active-locale = 'en'">
                                <xsl:text>/text:No Thumbnail</xsl:text>
                            </xsl:if>
                            <xsl:if test="$active-locale = 'cs'">
                                <xsl:text>/text:Náhled není k dispozici</xsl:text>
                            </xsl:if>
                        </xsl:attribute>
                    </img>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-DOI">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='doi']">
            <xsl:variable name="doiIdentifier" select="dim:field[@element='identifier' and @qualifier='doi']"/>
            <div id="item-view-DOI" class="simple-item-view-DOI simple-item-view-first-in-second-column item-page-field-wrapper table">
                <div class="alert alert-success item-view-doi-alert" role="alert">
                    <p class="item-view-doi-alert-text">
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-doi-alert-text</i18n:text><xsl:text> </xsl:text>
                        <a href="https://doi.org/{$doiIdentifier}" target="_blank" class="item-view-doi-alert-link">
                            <xsl:value-of select="$doiIdentifier"/>
                        </a>
                    </p>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- <JR> - 2024-01-30: We are still unable to generate citation,
    so this template is disabled, for now -->
    <xsl:template name="itemSummaryView-DIM-citation">
        <div id="item-view-citation" class="simple-item-view-citation item-page-field-wrapper table">
            <h5 class="item-view-metadata-heading" id="item-view-metadata-citation">Citace</h5>
            <div class="row citation-row">
                <xsl:call-template name="getCitation" />
            </div>
        </div>
    </xsl:template>

    <xsl:template name="getCitation">
        <xsl:choose>
            <xsl:when test="dim:field[@element='identifier' and @qualifier='doi']">

            </xsl:when>
            <xsl:otherwise>

            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="citationEmbed">
        <div class="col-xs-12 col-sm-12 col-md-12">
            <embed type="text/html" style="width:100%;" src="https://www.citacepro.com/sfx?instituce=cuni&amp;citacepro_display=bibliography&amp;sid=UK&amp;genre=article&amp;doi=10.3390/jpm11030164" />
        </div>
    </xsl:template>

    <!-- <JR> - 2023-11-07: Handling abstracts -->
    <xsl:template name="itemSummaryView-DIM-abstract">
        <!-- <xsl:variable name="publication-language" select="dim:field[@element='language'][@qualifier='iso']" /> -->
        <xsl:variable name="iso-lang" select="//dim:field[@element='language' and @qualifier='iso']" />
        <xsl:variable name="key-name"><xsl:text>abstract-language-group</xsl:text></xsl:variable>
        <xsl:variable name="element"><xsl:text>description</xsl:text></xsl:variable>
        <xsl:variable name="qualifier"><xsl:text>abstract</xsl:text></xsl:variable>
        <xsl:variable name="class">
            <xsl:choose>
                <xsl:when test="not(dim:field[@element='identifier' and @qualifier='doi'])">
                    <xsl:text>simple-item-view-description simple-item-view-first-in-second-column item-page-field-wrapper table</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>simple-item-view-description item-page-field-wrapper table</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="dim:field[@element=$element and @qualifier=$qualifier]">
            <div id="item-view-abstract">
                <xsl:attribute name="class">
                    <xsl:value-of select="$class"/>
                </xsl:attribute>
                <h5 class="item-view-metadata-heading" id="item-view-metadata-abstract"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract</i18n:text></h5>
                    
                <xsl:call-template name="process-language-groups">
                    <xsl:with-param name="iso-lang" select="$iso-lang" />
                    <xsl:with-param name="key-name" select="$key-name"/>
                    <xsl:with-param name="element" select="$element"/>
                    <xsl:with-param name="qualifier" select="$qualifier"/>
                </xsl:call-template>
            </div>
        </xsl:if>
    </xsl:template>
    <!-- END OF: Handling abstracts -->

    <!-- <JR> - 2023-11-03: Handling keywords -->
    <xsl:template name="itemSummaryView-DIM-keywords">
        <!-- Find the language group matching the iso value -->
        <xsl:variable name="iso-lang" select="//dim:field[@element='language' and @qualifier='iso']" />
        <xsl:variable name="key-name"><xsl:text>keyword-language-group</xsl:text></xsl:variable>
        <xsl:variable name="element"><xsl:text>subject</xsl:text></xsl:variable>
        <xsl:variable name="qualifier"><xsl:text>keyword</xsl:text></xsl:variable>
        <xsl:if test="dim:field[@element=$element and @qualifier=$qualifier]">
            <div id="item-view-keywords" class="simple-item-view-keywords item-page-field-wrapper table">
                <h5 class="item-view-metadata-heading"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-keywords</i18n:text></h5>

                <xsl:call-template name="process-language-groups">
                    <xsl:with-param name="iso-lang" select="$iso-lang" />
                    <xsl:with-param name="key-name" select="$key-name"/>
                    <xsl:with-param name="element" select="$element"/>
                    <xsl:with-param name="qualifier" select="$qualifier"/>
                </xsl:call-template>
            </div>
        </xsl:if>
        
    </xsl:template>
    
    <!-- END OF: Handling keywords-->

    <!-- 
        <JR> - 2023-09-12: Different handling of the dc.contributor.* information

        Display first three values of dc.contributor.*

        When there are more than 3 dc.contributor.* elements present, create link that expands a div (hidden by default)
        listing all value from the remaining dc.contributor.* elements

        WARN: dc.creator, nor dc.contributor (without a qualifier) are not being displayed, as they should not be used in the publication.cuni.cz metadata schema
    -->
    <xsl:template name="itemSummaryView-DIM-authors">
        
        <!-- 
            Variable holding SOLR XML response containing information about researcher identifiers of all authors of a given item.

            If the item is not found in SOLR, variable does not have a value and no identifiers are added to author's name in simple-item-view.
        -->
        <xsl:variable name="itemAuthorIdentifiers" select="document(concat($solrURL,'/select?q=search.resourcetype%3A2+AND+handle%3A', $itemHandle, '&amp;fl=uk.author.identifier&amp;wt=xml&amp;indent=true'))"/>
        
        <xsl:if test="dim:field[@element='contributor'][@qualifier='author' and descendant::text()] or dim:field[@element='creator' and descendant::text()] or dim:field[@element='contributor' and descendant::text()]">
            <div class="simple-item-view-authors item-page-field-wrapper table" id="item-view-authors">
                <h5 class="item-view-metadata-heading"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-author</i18n:text></h5>
                <xsl:for-each select="dim:field[@element='contributor'][@qualifier]">
                    <xsl:if test="count(preceding-sibling::dim:field[@element='contributor'][@qualifier]) &lt;= 2">
                        <xsl:variable name="currentAuthorIdentifiers">
                                <xsl:call-template name="utility-authorIdentifiersParse">
                                    <xsl:with-param name="authorIdentifiersXML" select="$itemAuthorIdentifiers"/>
                                    <xsl:with-param name="authorNameInMetadata" select="node()"/>
                                </xsl:call-template>
                        </xsl:variable>
                        <xsl:call-template name="itemSummaryView-DIM-authors-entry">
                            <xsl:with-param name="currentAuthorIdentifiersRecord" select="$currentAuthorIdentifiers"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="count(dim:field[@element='contributor'][@qualifier]) > 3">
                
                    <div id="collapse-authors" class="collapse" aria-labelledby="item-view-authors">
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier]">
                            <xsl:if test="count(preceding-sibling::dim:field[@element='contributor'][@qualifier]) >= 3">
                                <xsl:variable name="currentAuthorIdentifiers">
                                    <xsl:call-template name="utility-authorIdentifiersParse">
                                        <xsl:with-param name="authorIdentifiersXML" select="$itemAuthorIdentifiers"/>
                                        <xsl:with-param name="authorNameInMetadata" select="node()"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <xsl:call-template name="itemSummaryView-DIM-authors-entry">
                                    <xsl:with-param name="currentAuthorIdentifiersRecord" select="$currentAuthorIdentifiers"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:for-each>
                    </div>

                    <p>
                        <a role="button" data-toggle="collapse" data-parent="#item-view-authors" href="#collapse-authors" aria-expanded="false" aria-controls="collapse-authors">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-author-collapse</i18n:text>
                        </a>
                    </p>
                </xsl:if>
                
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-authors-entry">
        <!-- 
            String containing currently processed author's name and researcher identifiers.

            passed from template:   itemSummaryView-DIM-authors
        -->
        <xsl:param name="currentAuthorIdentifiersRecord"/>
        <div class="simple-item-view-author-line">
            <xsl:if test="@authority">
                <xsl:attribute name="class"><xsl:text>ds-dc_contributor_author-authority</xsl:text></xsl:attribute>
            </xsl:if>
            <!-- Adding author's name from metadata -->
            <span>
                <xsl:copy-of select="node()"/>
            </span>
            
            <!--
                Calling template that actually creates the HTML elements holding author's identifiers information
            -->
            <xsl:call-template name="addAuthorIdentifiers">
                <xsl:with-param name="authorIdentifiersRecord" select="$currentAuthorIdentifiersRecord"/>
            </xsl:call-template>

        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-URI">
        <xsl:if test="dim:field[@element='identifier' and @qualifier='uri' and descendant::text()]">
            <div class="simple-item-view-uri item-page-field-wrapper table">
                <!-- <JR> 2022-09-19: Added a new translation key for permanent link to DSpace item record -->
                <!--<h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-uri</i18n:text></h5>-->
                <h5 class="item-view-metadata-heading"><i18n:text>item-view.cuni.permanent-link.heading</i18n:text></h5>
                <span>
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='uri']">
                        <a>
                            <xsl:attribute name="href">
                                <xsl:copy-of select="./node()"/>
                            </xsl:attribute>
                            <xsl:copy-of select="./node()"/>
                        </a>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-otherIdentifiers">
        <!-- <JR> - 2024-01-30 - removed DOI from the condition, since we want it displayed in differnt way and place -->
        <!-- <xsl:if test="dim:field[@element='identifier'][@qualifier='obd' or @qualifier='doi' or @qualifier='utWos' or @qualfier='eidScopus' or @qualifier='pubmed']"> -->
        <xsl:if test="dim:field[@element='identifier'][@qualifier='utWos' or @qualfier='eidScopus' or @qualifier='pubmed']">
            <div id="item-view-otherIdentifiers" class="simple-item-view-description item-page-field-wrapper table">
                <h5 class="item-view-metadata-heading" id="item-view-metadata-other-system-identifiers"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-other-systems-identifiers</i18n:text></h5>
                <div class="row other-identifiers-row">
                    <!-- <JR> - 2024-01-30 - removed DOI from the condition, since we want it displayed in differnt way and place -->
                    <!-- <xsl:variable name="otherIdentifiersCount" select="count(dim:field[@element='identifier'][@qualifier='obd' or @qualifier='doi' or @qualifier='utWos' or @qualifier='eidScopus' or @qualifier='pubmed'])"/> -->
                    <xsl:variable name="otherIdentifiersCount" select="count(dim:field[@element='identifier'][@qualifier='utWos' or @qualifier='eidScopus' or @qualifier='pubmed'])"/>
                    <xsl:call-template name="itemSummaryView-DIM-otherIdentifiers-content">
                        <xsl:with-param name="identifiersCount" select="$otherIdentifiersCount" />
                    </xsl:call-template>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-otherIdentifiers-content">
        <xsl:param name="identifiersCount" />
        <xsl:variable name="grid-columns-width" select="number(12 div $identifiersCount)" />
        
        <xsl:if test="number(12 mod $identifiersCount) = 0">
            <xsl:variable name="gridColumnsWidth" select="number(12 div $identifiersCount)"/>
            <!-- <JR> - 2024-01-30 - removed DOI from the condition, since we want it displayed in differnt way and place -->
            <!-- <xsl:for-each select="dim:field[@element='identifier'][@qualifier='obd' or @qualifier='doi' or @qualifier='utWos' or @qualifier='eidScopus' or @qualifier='pubmed']"> -->
            <xsl:for-each select="dim:field[@element='identifier'][@qualifier='utWos' or @qualifier='eidScopus' or @qualifier='pubmed']">
                <div class="col-xs-12 col-sm-3 col-md-3 other-identifier-column">
                    <xsl:call-template name="itemSummaryView-DIM-otherIdentifiers-create-link-icons">
                        <xsl:with-param name="qualifier" select="@qualifier"/>
                        <xsl:with-param name="otherIdentifierValue" select="./node()"/>
                    </xsl:call-template>
                </div>
            </xsl:for-each>
        </xsl:if>
        <xsl:if test="not(number(12 mod $identifiersCount = 0)) and $identifiersCount &lt; 6">
            <xsl:for-each select="dim:field[@element='identifier'][@qualifier='utWos' or @qualifier='eidScopus' or @qualifier='pubmed']">
                <xsl:sort select="(position( ) - 1) mod 3"/>
                <div class="col-xs-12 col-sm-3 col-md-3 other-identifier-column">
                    <xsl:call-template name="itemSummaryView-DIM-otherIdentifiers-create-link-icons">
                        <xsl:with-param name="qualifier" select="@qualifier"/>
                        <xsl:with-param name="otherIdentifierValue" select="./node()"/>
                    </xsl:call-template>
                </div>
            </xsl:for-each>
        </xsl:if>

    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-otherIdentifiers-create-link-icons">
        <xsl:param name="qualifier"/>
        <xsl:param name="otherIdentifierValue"/>
        <xsl:choose>
            <!-- <JR> - 2024-01-30: Removed DOI from condition since we want to display it in a different way / place -->
            <!-- <xsl:when test="$qualifier='doi'">
                <a href="https://doi.org/{$otherIdentifierValue}" class="other-identifier-link" target="_blank">
                    <img class="other-identifier-image" src="{$theme-path}images/logo_DOI.svg" alt="DOI:{$otherIdentifierValue}"/>
                </a>
            </xsl:when> -->
            <xsl:when test="$qualifier='utWos'">
                <a href="https://www.webofscience.com/wos/woscc/full-record/WOS:{$otherIdentifierValue}" class="other-identifier-link" target="_blank">
                    <img class="other-identifier-image" src="{$theme-path}images/wos-logo.svg" alt="WOS:{$otherIdentifierValue}"/>
                </a>
            </xsl:when>
            <xsl:when test="$qualifier='eidScopus'">
                <a href="https://www.scopus.com/record/display.uri?eid={$otherIdentifierValue}&amp;origin=resultslist" class="other-identifier-link" target="_blank">
                    <img class="other-identifier-image" src="{$theme-path}images/logo_Scopus.svg" alt="SCOPUS:{$otherIdentifierValue}"/>
                </a>
            </xsl:when>
            <xsl:when test="$qualifier='pubmed'">
                <a href="https://pubmed.ncbi.nlm.nih.gov/{$otherIdentifierValue}/" class="other-identifier-link" target="_blank">
                    <img class="other-identifier-image" src="{$theme-path}images/logo_PubMed.svg" alt="PUBMED:{$otherIdentifierValue}"/>
                </a>
            </xsl:when>
            <!-- <xsl:when test="$qualifier='obd'">
                <a href="https://verso.is.cuni.cz/pub/verso.fpl/?fname=obd_publicnew_det&amp;id={$otherIdentifierValue}" class="other-identifier-link" target="_blank">
                    <img class="other-identifier-image" src="{$theme-path}images/logo_isveda.svg" alt="OBD:{$otherIdentifierValue}"/>
                </a>
            </xsl:when> -->
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-date">
        <xsl:if test="dim:field[@element='date' and @qualifier='issued' and descendant::text()]">
            <div class="simple-item-view-date word-break item-page-field-wrapper table">
                <h5 class="item-view-metadata-heading">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-date</i18n:text>
                </h5>
                <xsl:for-each select="dim:field[@element='date' and @qualifier='issued']">
                    <xsl:copy-of select="substring(./node(),1,10)"/>
                    <xsl:if test="count(following-sibling::dim:field[@element='date' and @qualifier='issued']) != 0">
                        <br/>
                    </xsl:if>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- <JR> - 2023-10-26: Adding publication type information to item-view -->
    <xsl:template name="itemSummaryView-DIM-publication-type">
        
        <xsl:if test="$active-locale = 'cs'">
            <xsl:if test="dim:field[@element='type' and @qualifier='obdHierarchyCs']">
                <xsl:call-template name="itemSummaryView-DIM-publication-type-content">
                    <xsl:with-param name="qualifier">
                        <xsl:text>obdHierarchyCs</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>

        <xsl:if test="$active-locale = 'en'">
            <xsl:if test="dim:field[@element='type' and @qualifier='obdHierarchyEn']">
                <xsl:call-template name="itemSummaryView-DIM-publication-type-content">
                    <xsl:with-param name="qualifier">
                        <xsl:text>obdHierarchyEn</xsl:text>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-item-language-icon">
        <!-- Check if the dc.language.iso is present in metadata -->
        <xsl:if test="dim:field[@element='language' and @qualifier='iso']">
            <xsl:variable name="languagecode" select="dim:field[@element='language' and @qualifier='iso']"/>
            <xsl:variable name="languagecodetranslation"><i18n:text>xmlui.publication.language.<xsl:value-of select='$languagecode'/></i18n:text></xsl:variable>
            <!-- <xsl:element name="span" i18n:attr="title">
                <xsl:attribute name="class">
                    <xsl:text>badge publication-language-badge</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="title">
                    <xsl:value-of select="$languagecodetranslation"/>
                </xsl:attribute>
                <xsl:value-of select="$languagecode"/>
            </xsl:element> -->
            <span class="badge publication-language-badge" i18n:attr="title" title="{$languagecodetranslation}"><xsl:value-of select="$languagecode"/></span>
            <!-- <img class="img-responsive">
                <xsl:attribute name="src">
                    <xsl:value-of select="concat($theme-path,'/images/languages/', $languagecode, '.png')"/>
                </xsl:attribute>
                <xsl:attribute name="alt">
                    <xsl:value-of select="$licenseText"/>
                </xsl:attribute>
            </img> -->
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-publication-type-content">
        
        <xsl:param name="qualifier"/>        
            
        <xsl:for-each select="dim:field[@element='type' and @qualifier=$qualifier]">

            <span type="button" class="label label-additional-info" aria-haspopup="true">
                <xsl:copy-of select="substring-after(substring-after(./node(),'::'),'::')" />
            </span>
            
        </xsl:for-each>
    </xsl:template>

    
    <!-- END OF: Adding publication type information to item-view -->


    

    <!-- <JR> - 2023-11-08: Adding publication version info to item-view -->
    <xsl:template name="itemSummaryView-DIM-publication-version">
        <xsl:if test="dim:field[@element='type'][@qualifier='version']">
            <xsl:variable name="outputOBDid" select="dim:field[@element='identifier'][@qualifier='obd']"/>
            <xsl:for-each select="dim:field[@element='type'][@qualifier='version']">
                <xsl:call-template name="itemSummaryView-DIM-other-output-versions">
                    <xsl:with-param name="OBDid"><xsl:value-of select="$outputOBDid" /></xsl:with-param>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    <!-- END OF: Adding publication version info to item-view-->

    <!-- <JR> - 2022-09-02 - Checking other publications versiosn - THIS EXAMPLE WORKS -->
	<xsl:template name="itemSummaryView-DIM-other-output-versions">
        <xsl:param name="OBDid" />
		<xsl:variable name="solrURL">
			<xsl:text>http://localhost:8080/solr/search</xsl:text>
        </xsl:variable>
		<xsl:variable name="currentOutputVersion" select="./node()"/>
		

        <span type="button" id="publication-versions-toggle" class="label label-additional-info dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-publication-version-<xsl:copy-of select="substring-after(./node(), 'info:eu-repo/semantics/')" />
            </i18n:text>
            <span class="caret"></span>
        </span>
	
        <xsl:apply-templates select="document(concat($solrURL,'/select?q=search.resourcetype%3A2+AND+!dc.type.version%3A%22',$currentOutputVersion,'%22+AND+dc.identifier.obd%3A',$OBDid,'&amp;fl=dc.identifier.uri%2Cdc.type.version&amp;wt=xml&amp;indent=true'))" mode="solrOtherOutputVersions"/>
	</xsl:template>

    <xsl:template match="*" mode="solrOtherOutputVersions">
        <xsl:if test="/response/result/@numFound != '0'">
            <ul class="dropdown-menu dropdown-menu-right publications-versions-toggle" aria-labelledby="publications-versions-toggle">
                <xsl:for-each select="/response/result/doc">
                    <xsl:variable name="otherOutputVersionURL" select="./arr[@name='dc.identifier.uri']/str/text()"/>
                    <!-- 
                        Get other output's version and process the value:
                            1) search for the string after last separator ('/')
                            2) return just the last string after last separator
                            3) store value in this variable
                    -->
                    <xsl:variable name="otherOutputVersionType">
                        <xsl:call-template name="GetLastSegment">
                            <xsl:with-param name="value" select="./arr[@name='dc.type.version']/str/text()" />
                            <xsl:with-param name="separator" select="'/'" />
                        </xsl:call-template>
                    </xsl:variable>
                    <li>
                        <a href="{$otherOutputVersionURL}" class="publication-versions-toggle-link">
                            <i18n:text><xsl:value-of select="concat('xmlui.dri2xhtml.METS-1.0.item-publication-version-',$otherOutputVersionType)"/></i18n:text>
                        </a>
                    </li>
                </xsl:for-each>
            </ul>
        </xsl:if>
        <xsl:if test="/response/result/@numFound = '0'">
            <ul class="dropdown-menu dropdown-menu-right" aria-labelledby="publications-versions-toggle">
                <li class="disabled">
                    <a>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-publication-version-none</i18n:text>
                    </a>
                </li>
            </ul>
        </xsl:if>
    </xsl:template>

    <!-- <JR> - 2023-10-27: Source publication name -->
    <xsl:template name="itemSummaryView-DIM-source-publication-name">
        <xsl:if test="dim:field[@element='isPartOf' and @qualifier='name']">
            <div class="simple-item-view-source-publication-name word-break item-page-field-wrapper table">
                <h5 class="item-view-metadata-heading" id="itemSummaryView-DIM-source-publication-name">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-source-publication-name</i18n:text>
                </h5>

                <xsl:for-each select="dim:field[@element='isPartOf' and @qualifier='name']">
                    <xsl:copy-of select="./node()" />
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>
    <!-- END OF: Source document name -->

    <!-- <JR> - 2023-10-27: Source  publication volume & issue -->

    <xsl:template name="itemSummaryView-DIM-source-publication-volume-issue">
        <xsl:if test="dim:field[@element='isPartOf' and @qualifier='journalVolume'] or 
        dim:field[@element='isPartOf' and @qualifier='journalIssue']">
            <div class="simple-item-view-source-publication-volume-issue word-break item-page-field-wrapper table">
                <h5 class="item-view-metadata-heading" id="itemSummaryView-DIM-source-publication-volume-issue">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-source-publication-volume-issue</i18n:text>
                </h5>

                <xsl:if test="dim:field[@element='isPartOf' and @qualifier='journalVolume']">
                    <xsl:for-each select="dim:field[@element='isPartOf' and @qualifier='journalVolume']">
                        <xsl:copy-of select="./node()"/>
                    </xsl:for-each>
                </xsl:if>

                <xsl:if test="dim:field[@element='isPartOf' and @qualifier='journalIssue']">
                    <xsl:for-each select="dim:field[@element='isPartOf' and @qualifier='journalIssue']">
                        <xsl:text> (</xsl:text><xsl:copy-of select="./node()" /><xsl:text>)</xsl:text>
                    </xsl:for-each>
                </xsl:if>
            </div>
        </xsl:if>
    </xsl:template>
    <!-- END OF: Source  publication volume & issue -->

    <!-- <JR> - 2023-10-27: TODO: Information about the source publication's ISBN / ISSN or E-ISSN identifiers
                
            TODO: Create better template!
    -->
    <xsl:template name="itemSummaryView-DIM-source-publication-isbn-issn">
        <xsl:if test="dim:field[@element='isPartOf'][@qualifier='isbn' or @qualifier='issn' or @qualifier='eissn']">
            <div class="simple-item-view-source-publication-isbn-issn word-break item-page-field-wrapper table">
                <h5 class="item-view-metadata-heading" id="itemSummaryView-DIM-source-publication-isbn-issn">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-source-publication-isbn-issn</i18n:text>
                </h5>

                <xsl:if test="dim:field[@element='isPartOf' and @qualifier='isbn']">
                    <xsl:for-each select="dim:field[@element='isPartOf' and @qualifier='isbn']">
                        <xsl:text>ISBN: </xsl:text><xsl:copy-of select="./node()"/>
                    </xsl:for-each>
                </xsl:if>

                <xsl:if test="dim:field[@element='isPartOf' and @qualifier='issn']">
                    <xsl:for-each select="dim:field[@element='isPartOf' and @qualifier='issn']">
                        <xsl:text>ISSN: </xsl:text><xsl:copy-of select="./node()"/>
                    </xsl:for-each>
                </xsl:if>

                <xsl:if test="dim:field[@element='isPartOf' and @qualifier='eissn']">
                    <xsl:for-each select="dim:field[@element='isPartOf' and @qualifier='eissn']">
                        <xsl:text>eISSN: </xsl:text><xsl:copy-of select="./node()"/>
                    </xsl:for-each>
                </xsl:if>
            </div>
        </xsl:if>
    </xsl:template>

    <!-- <JR> - 2023-10-27: TODO: Information about the publication's ISBN / ISSN or E-ISSN identifiers
                
            TODO: Create better template!
    -->
    <xsl:template name="itemSummaryView-DIM-publication-isbn-issn">

        <xsl:if test="dim:field[@element='identifier'][@qualifier='isbn' or @qualifier='issn' or @qualifier='eissn']">
            <div class="simple-item-view-publication-isbn-issn word-break item-page-field-wrapper table">
                <h5 class="item-view-metadata-heading" id="itemSummaryView-DIM-publication-isbn-issn">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-publication-isbn-issn</i18n:text>
                </h5>

                <xsl:if test="dim:field[@element='identifier' and @qualifier='isbn']">
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='isbn']">
                        <xsl:text>ISBN: </xsl:text><xsl:copy-of select="./node()"/>
                    </xsl:for-each>
                </xsl:if>

                <xsl:if test="dim:field[@element='identifier' and @qualifier='issn']">
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='issn']">
                        <xsl:text>ISSN: </xsl:text><xsl:copy-of select="./node()"/>
                    </xsl:for-each>
                </xsl:if>

                <xsl:if test="dim:field[@element='identifier' and @qualifier='eissn']">
                    <xsl:for-each select="dim:field[@element='identifier' and @qualifier='eissn']">
                        <xsl:text>eISSN: </xsl:text><xsl:copy-of select="./node()"/>
                    </xsl:for-each>
                </xsl:if>
            </div>
        </xsl:if>

    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-fundingReference">
        <!-- <JR> - 2025-09-16: Adding funding reference information to item-view -->
        <xsl:if test="dim:field[@element='relation' and @qualifier='fundingReference']">
            <div class="simple-item-view-publication-fundingReference word-break item-page-field-wrapper table">
                <h5 class="item-view-metadata-heading" id="itemSummaryView-DIM-publication-fundingReference">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-publication-fundingReference</i18n:text>
                </h5>
                <xsl:for-each select="dim:field[@element='relation'][@qualifier='fundingReference']">
                    <xsl:call-template name="addFundingEntry">
                        <xsl:with-param name="currentFundingReference" select="node()"/>
                    </xsl:call-template>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="addFundingEntry">
        <xsl:param name="currentFundingReference"/>
        <div class="simple-item-view-fundingReference-line">
            <!-- Adding author's name from metadata -->
            <span>
                <xsl:copy-of select="node()"/>
            </span>
            
            <!--
                Calling template that actually creates the HTML elements holding author's identifiers information
            -->
            <!-- <xsl:call-template name="addAuthorIdentifiers">
                <xsl:with-param name="authorIdentifiersRecord" select="$currentAuthorIdentifiersRecord"/>
            </xsl:call-template> -->

        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-publisher-publicationPlace">
        <xsl:if test="dim:field[@element='publisher' and not(@qualifier)] or dim:field[@element='publisher' and @qualifier='publicationPlace']">
            <div class="simple-item-view-publication-publisher word-break item-page-field-wrapper table">
                <h5 class="item-view-metadata-heading" id="itemSummaryView-DIM-publisher-info">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-publisher</i18n:text>
                    <xsl:text> / </xsl:text>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-publisher-publication-place</i18n:text>
                </h5>

                <xsl:if test="dim:field[@element='publisher' and not(@qualifier)]">
                    <xsl:for-each select="dim:field[@element='publisher' and not(@qualifier)]">
                        <xsl:copy-of select="./node()"/>
                    </xsl:for-each>
                </xsl:if>

                <xsl:if test="dim:field[@element='publisher' and @qualifier='publicationPlace']">
                    <xsl:text> (</xsl:text>
                    <xsl:for-each select="dim:field[@element='publisher' and @qualifier='publicationPlace']">
                        <xsl:copy-of select="./node()"/>
                    </xsl:for-each>
                    <xsl:text>)</xsl:text>
                </xsl:if>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-show-full">
        <div class="simple-item-view-show-full item-page-field-wrapper table">
            <h5 class="item-view-metadata-heading">
                <i18n:text>xmlui.mirage2.itemSummaryView.MetaData</i18n:text>
            </h5>
            <a>
                <xsl:attribute name="href"><xsl:value-of select="$ds_item_view_toggle_url"/></xsl:attribute>
                <i18n:text>xmlui.ArtifactBrowser.ItemViewer.show_full</i18n:text>
            </a>
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-collections">
        <xsl:if test="$document//dri:referenceSet[@id='aspect.artifactbrowser.ItemViewer.referenceSet.collection-viewer']">
            <div class="simple-item-view-collections item-page-field-wrapper table">
                <h5 class="item-view-metadata-heading">
                    <i18n:text>xmlui.mirage2.itemSummaryView.Collections</i18n:text>
                </h5>
                <xsl:apply-templates select="$document//dri:referenceSet[@id='aspect.artifactbrowser.ItemViewer.referenceSet.collection-viewer']/dri:reference"/>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-file-section">
        <xsl:choose>
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                <div class="item-page-field-wrapper table word-break">
                    <!-- <JR> - 2024-01-30: Just confirming we don't want this heading to be displayed -->
                    <!-- <h5>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                    </h5> -->

                    <xsl:variable name="label-1">
                            <xsl:choose>
                                <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.1')">
                                    <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.1')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>label</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                    </xsl:variable>

                    <xsl:variable name="label-2">
                            <xsl:choose>
                                <xsl:when test="confman:getProperty('mirage2.item-view.bitstream.href.label.2')">
                                    <xsl:value-of select="confman:getProperty('mirage2.item-view.bitstream.href.label.2')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>title</xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                    </xsl:variable>

                    <xsl:for-each select="//mets:fileSec/mets:fileGrp[@USE='CONTENT' or @USE='ORIGINAL' or @USE='LICENSE']/mets:file">
                        <div class="row item-view-filesection-file-row">
                            <div class="btn-group download-button-group col-xs-12">
                                <xsl:call-template name="itemSummaryView-DIM-file-section-entry">
                                    <xsl:with-param name="href" select="mets:FLocat[@LOCTYPE='URL']/@xlink:href" />
                                    <xsl:with-param name="mimetype" select="@MIMETYPE" />
                                    <xsl:with-param name="label-1" select="$label-1" />
                                    <xsl:with-param name="label-2" select="$label-2" />
                                    <xsl:with-param name="title" select="mets:FLocat[@LOCTYPE='URL']/@xlink:title" />
                                    <xsl:with-param name="label" select="mets:FLocat[@LOCTYPE='URL']/@xlink:label" />
                                    <xsl:with-param name="size" select="@SIZE" />
                                    <xsl:with-param name="embargo" select="//dim:dim/dim:field[@element='date' and @qualifier='embargoEndDate']" />
                                </xsl:call-template>
                            </div>
                        </div>
                    </xsl:for-each>
                </div>
            </xsl:when>
            <!-- Special case for handling ORE resource maps stored as DSpace bitstreams -->
            <xsl:when test="//mets:fileSec/mets:fileGrp[@USE='ORE']">
                <xsl:apply-templates select="//mets:fileSec/mets:fileGrp[@USE='ORE']" mode="itemSummaryView-DIM" />
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-file-section-entry">
        <xsl:param name="href" />
        <xsl:param name="mimetype" />
        <xsl:param name="label-1" />
        <xsl:param name="label-2" />
        <xsl:param name="title" />
        <xsl:param name="label" />
        <xsl:param name="size" />
        <xsl:param name="embargo" />
            <a type="button" id="{$label}" class="button-file-icon btn btn-default col-xs-2" aria-haspopup="true">
                <xsl:attribute name="href">
                    <xsl:value-of select="$href"/>
                </xsl:attribute>
                <xsl:call-template name="getFileIcon">
                    <xsl:with-param name="mimetype">
                        <xsl:value-of select="substring-before($mimetype,'/')"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="substring-after($mimetype,'/')"/>
                    </xsl:with-param>
                    <xsl:with-param name="embargoValue">
                        <xsl:value-of select="$embargo" />
                    </xsl:with-param>
                </xsl:call-template>
            </a>
            <a type="button" class="button-file-text btn btn-default col-xs-10" aria-haspopup="true">
                <xsl:attribute name="href">
                    <xsl:value-of select="$href"/>
                </xsl:attribute>
                <xsl:call-template name="getFileText">
                    <xsl:with-param name="embargoValue">
                        <xsl:value-of select="$embargo"/>
                    </xsl:with-param>
                </xsl:call-template>
            </a>
            
    </xsl:template>

    <xsl:template match="dim:dim" mode="itemDetailView-DIM">
        <xsl:call-template name="itemSummaryView-DIM-title"/>
        <div class="ds-table-responsive">
            <table class="ds-includeSet-table detailtable table table-striped table-hover">
                <xsl:apply-templates mode="itemDetailView-DIM"/>
            </table>
        </div>

        <span class="Z3988">
            <xsl:attribute name="title">
                 <xsl:call-template name="renderCOinS"/>
            </xsl:attribute>
            &#xFEFF; <!-- non-breaking space to force separating the end tag -->
        </span>
        <xsl:copy-of select="$SFXLink" />
    </xsl:template>

    <xsl:template match="dim:field" mode="itemDetailView-DIM">
            <tr>
                <xsl:attribute name="class">
                    <xsl:text>ds-table-row </xsl:text>
                    <xsl:if test="(position() div 2 mod 2 = 0)">even </xsl:if>
                    <xsl:if test="(position() div 2 mod 2 = 1)">odd </xsl:if>
                </xsl:attribute>
                <td class="label-cell">
                    <xsl:value-of select="./@mdschema"/>
                    <xsl:text>.</xsl:text>
                    <xsl:value-of select="./@element"/>
                    <xsl:if test="./@qualifier">
                        <xsl:text>.</xsl:text>
                        <xsl:value-of select="./@qualifier"/>
                    </xsl:if>
                </td>
            <td class="word-break">
              <xsl:copy-of select="./node()"/>
            </td>
                <td><xsl:value-of select="./@language"/></td>
            </tr>
    </xsl:template>

    <!-- don't render the item-view-toggle automatically in the summary view, only when it gets called -->
    <xsl:template match="dri:p[contains(@rend , 'item-view-toggle') and
        (preceding-sibling::dri:referenceSet[@type = 'summaryView'] or following-sibling::dri:referenceSet[@type = 'summaryView'])]">
    </xsl:template>

    <!-- don't render the head on the item view page -->
    <xsl:template match="dri:div[@n='item-view']/dri:head" priority="5">
    </xsl:template>

   <xsl:template match="mets:fileGrp[@USE='CONTENT']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
            <xsl:choose>
                <!-- If one exists and it's of text/html MIME type, only display the primary bitstream -->
                <xsl:when test="mets:file[@ID=$primaryBitstream]/@MIMETYPE='text/html'">
                    <xsl:apply-templates select="mets:file[@ID=$primaryBitstream]">
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:when>
                <!-- Otherwise, iterate over and display all of them -->
                <xsl:otherwise>
                    <xsl:apply-templates select="mets:file">
                     	<!--Do not sort any more bitstream order can be changed-->
                        <xsl:with-param name="context" select="$context"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>

   <xsl:template match="mets:fileGrp[@USE='LICENSE']">
        <xsl:param name="context"/>
        <xsl:param name="primaryBitstream" select="-1"/>
            <xsl:apply-templates select="mets:file">
                        <xsl:with-param name="context" select="$context"/>
            </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="mets:file">
        <xsl:param name="context" select="."/>
        <div class="file-wrapper row">
            <div class="col-xs-6 col-sm-3">
                <div class="thumbnail">
                    <a class="image-link">
                        <xsl:attribute name="href">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                        mets:file[@GROUPID=current()/@GROUPID]">
                                <img class="img-thumbnail" alt="Thumbnail">
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="$context/mets:fileSec/mets:fileGrp[@USE='THUMBNAIL']/
                                    mets:file[@GROUPID=current()/@GROUPID]/mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
                                    </xsl:attribute>
                                </img>
                            </xsl:when>
                            <xsl:otherwise>
                                <img class="img-thumbnail" alt="Thumbnail">
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
            </div>

            <div class="col-xs-6 col-sm-7">
                <dl class="file-metadata dl-horizontal">
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-name</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:attribute name="title">
                            <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:title"/>
                        </xsl:attribute>
                        <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:title, 30, 5)"/>
                    </dd>
                <!-- File size always comes in bytes and thus needs conversion -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-size</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:choose>
                            <xsl:when test="@SIZE &lt; 1024">
                                <xsl:value-of select="@SIZE"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div 1024),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                            </xsl:when>
                            <xsl:when test="@SIZE &lt; 1024 * 1024 * 1024">
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="substring(string(@SIZE div (1024 * 1024 * 1024)),1,5)"/>
                                <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </dd>
                <!-- Lookup File Type description in local messages.xml based on MIME Type.
         In the original DSpace, this would get resolved to an application via
         the Bitstream Registry, but we are constrained by the capabilities of METS
         and can't really pass that info through. -->
                    <dt>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-format</i18n:text>
                        <xsl:text>:</xsl:text>
                    </dt>
                    <dd class="word-break">
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before(@MIMETYPE,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="contains(@MIMETYPE,';')">
                                <xsl:value-of select="substring-before(substring-after(@MIMETYPE,'/'),';')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring-after(@MIMETYPE,'/')"/>
                                    </xsl:otherwise>
                                </xsl:choose>

                            </xsl:with-param>
                        </xsl:call-template>
                    </dd>
                <!-- Display the contents of 'Description' only if bitstream contains a description -->
                <xsl:if test="mets:FLocat[@LOCTYPE='URL']/@xlink:label != ''">
                        <dt>
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-description</i18n:text>
                            <xsl:text>:</xsl:text>
                        </dt>
                        <dd class="word-break">
                            <xsl:attribute name="title">
                                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:label"/>
                            </xsl:attribute>
                            <xsl:value-of select="util:shortenString(mets:FLocat[@LOCTYPE='URL']/@xlink:label, 30, 5)"/>
                        </dd>
                </xsl:if>
                </dl>
            </div>

            <div class="file-link col-xs-6 col-xs-offset-6 col-sm-2 col-sm-offset-0">
                <xsl:choose>
                    <xsl:when test="@ADMID">
                        <xsl:call-template name="display-rights"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="view-open"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>

</xsl:template>

    <xsl:template name="view-open">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="mets:FLocat[@LOCTYPE='URL']/@xlink:href"/>
            </xsl:attribute>
            <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
        </a>
    </xsl:template>

    <xsl:template name="display-rights">
        <xsl:variable name="file_id" select="jstring:replaceAll(jstring:replaceAll(string(@ADMID), '_METSRIGHTS', ''), 'rightsMD_', '')"/>
        <xsl:variable name="rights_declaration" select="../../../mets:amdSec/mets:rightsMD[@ID = concat('rightsMD_', $file_id, '_METSRIGHTS')]/mets:mdWrap/mets:xmlData/rights:RightsDeclarationMD"/>
        <xsl:variable name="rights_context" select="$rights_declaration/rights:Context"/>
        <xsl:variable name="users">
            <xsl:for-each select="$rights_declaration/*">
                <xsl:value-of select="rights:UserName"/>
                <xsl:choose>
                    <xsl:when test="rights:UserName/@USERTYPE = 'GROUP'">
                       <xsl:text> (group)</xsl:text>
                    </xsl:when>
                    <xsl:when test="rights:UserName/@USERTYPE = 'INDIVIDUAL'">
                       <xsl:text> (individual)</xsl:text>
                    </xsl:when>
                </xsl:choose>
                <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="not ($rights_context/@CONTEXTCLASS = 'GENERAL PUBLIC') and ($rights_context/rights:Permissions/@DISPLAY = 'true')">
                <a href="{mets:FLocat[@LOCTYPE='URL']/@xlink:href}">
                    <img width="64" height="64" src="{concat($theme-path,'/images/Crystal_Clear_action_lock3_64px.png')}" title="Read access available for {$users}"/>
                    <!-- icon source: http://commons.wikimedia.org/wiki/File:Crystal_Clear_action_lock3.png -->
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="view-open"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getFileText">
        <xsl:param name="embargoValue"/>

        <xsl:choose>
            <xsl:when test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
                <xsl:if test="$embargoValue">
                    <span><i18n:text>xmlui.dri2xhtml.METS-1.0.item-file-button-embargoed</i18n:text></span>
                    <br/>
                    <span><xsl:value-of select="concat(' ', $embargoValue)" /></span>
                </xsl:if>
                <xsl:if test="not($embargoValue)">
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-file-button-restricted</i18n:text>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                    <i18n:text>xmlui.dri2xhtml.METS-1.0.item-file-button-download</i18n:text>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>

    <xsl:template name="getFileIcon">
        <xsl:param name="mimetype"/>
        <xsl:param name="embargoValue" />

        <img aria-hidden="true">
            <xsl:attribute name="class">
                <xsl:text>filesection-file-icon </xsl:text>
            </xsl:attribute>
            <xsl:attribute name="src">
                <xsl:choose>
                    <xsl:when test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
                        <xsl:if test="$embargoValue">
                            <xsl:value-of select="concat($theme-path,'/', 'images', '/', 'embargoed_access.svg')" />
                        </xsl:if>
                        <xsl:if test="not($embargoValue)">
                            <xsl:value-of select="concat($theme-path,'/', 'images', '/', 'restricted_access.svg')" />
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($theme-path,'/', 'images', '/', 'open_access.svg')" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            
        </img>
        <!-- TODO: Use i18n:text for translating these sr-only strings -->
        <xsl:choose>
            <xsl:when test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
                <xsl:if test="$embargoValue">
                    <span class="sr-only">File can be accessed after logging in from <xsl:value-of select="$embargoValue" />.</span>        
                </xsl:if>
                <xsl:if test="not($embargoValue)">
                    <span class="sr-only">File can be accessed only after logging in.</span>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <span class="sr-only">File can be accessed.</span>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- Generate the license information from the file section -->
    <xsl:template match="mets:fileGrp[@USE='CC-LICENSE']" mode="simple">
        <li><a href="{mets:file/mets:FLocat[@xlink:title='license_text']/@xlink:href}"><i18n:text>xmlui.dri2xhtml.structural.link_cc</i18n:text></a></li>
    </xsl:template>

    <!-- Generate the license information from the file section -->
    <xsl:template match="mets:fileGrp[@USE='LICENSE']" mode="simple">
        <li><a href="{mets:file/mets:FLocat[@xlink:title='license.txt']/@xlink:href}"><i18n:text>xmlui.dri2xhtml.structural.link_original_license</i18n:text></a></li>
    </xsl:template>

    <!--
    File Type Mapping template

    This maps format MIME Types to human friendly File Type descriptions.
    Essentially, it looks for a corresponding 'key' in your messages.xml of this
    format: xmlui.dri2xhtml.mimetype.{MIME Type}

    (e.g.) <message key="xmlui.dri2xhtml.mimetype.application/pdf">PDF</message>

    If a key is found, the translated value is displayed as the File Type (e.g. PDF)
    If a key is NOT found, the MIME Type is displayed by default (e.g. application/pdf)
    -->
    <xsl:template name="getFileTypeDesc">
        <xsl:param name="mimetype"/>

        <!--Build full key name for MIME type (format: xmlui.dri2xhtml.mimetype.{MIME type})-->
        <xsl:variable name="mimetype-key">xmlui.dri2xhtml.mimetype.<xsl:value-of select='$mimetype'/></xsl:variable>

        <!--Lookup the MIME Type's key in messages.xml language file.  If not found, just display MIME Type-->
        <i18n:text i18n:key="{$mimetype-key}"><xsl:value-of select="$mimetype"/></i18n:text>
    </xsl:template>

    <!-- 
        Get last segment of a string, following after last occurence of a given separator 

        @author: JLRishe@stackoverflow: https://stackoverflow.com/users/1945651/jlrishe
        
        For details see accepted answer at: https://stackoverflow.com/questions/17468891/substring-after-last-character-in-xslt
    -->
    <xsl:template name="GetLastSegment">
        <xsl:param name="value" />
        <xsl:param name="separator" /><!-- select="'.'" />-->

        <xsl:choose>
            <xsl:when test="contains($value, $separator)">
                <xsl:call-template name="GetLastSegment">
                    <xsl:with-param name="value" select="substring-after($value, $separator)" />
                    <xsl:with-param name="separator" select="$separator" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$value" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- 
        Template for adding author's identifiers to his name in the item-view 
    
        @author:    Jakub Řihák <JR>
        @date:      2023-09-06
    -->
    <xsl:template name="addAuthorIdentifiers">
        <!-- 
            String containing author's name and his researcher identifiers
            
            passed from template: itemSummaryView-DIM-authors-entry
        -->
        <xsl:param name="authorIdentifiersRecord"/>

        <xsl:if test="substring-before(substring-after($authorIdentifiersRecord, 'orcid_'), '|') != ''">
            <xsl:variable name="authorORCID" select="substring-before(substring-after($authorIdentifiersRecord, 'orcid_'), '|')"/>
            <span class="author-identifier">
                <a href="https://orcid.org/{$authorORCID}" target="_blank" class="author-identifier-link" title="ORCiD Profile - {$authorORCID}">
                    <img src="{$theme-path}/images/ORCID_iD.svg" class="author-identifier-icon" alt="ORCiD Profile - {$authorORCID}" title="ORCiD Profile - {$authorORCID}"/>
                </a>
            </span>
        </xsl:if>
                    
        <xsl:if test="substring-before(substring-after($authorIdentifiersRecord, 'researcherid_'), '|') != ''">
            <xsl:variable name="authorResearcherID" select="substring-before(substring-after($authorIdentifiersRecord, 'researcherid_'), '|')"/>
            <span class="author-identifier">
                <a href="https://www.webofscience.com/wos/author/record/{$authorResearcherID}" target="_blank" class="author-identifier-link" title="WoS Profile - {$authorResearcherID}">
                    <img src="{$theme-path}/images/CLVT.svg" class="author-identifier-icon" alt="WoS Profile - {$authorResearcherID}" title="WoS Profile - {$authorResearcherID}" />
                </a>
            </span>
        </xsl:if>

        <xsl:if test="substring-after($authorIdentifiersRecord, 'scopus_') != ''">
            <xsl:variable name="authorScopusID" select="substring-after($authorIdentifiersRecord, 'scopus_')"/>
            <span class="author-identifier">
                <a href="https://www.scopus.com/authid/detail.uri?authorId={$authorScopusID}" target="_blank" class="author-identifier-link" title="Scopus Profile - {$authorScopusID}">
                    <img src="{$theme-path}/images/sc.png" class="author-identifier-icon" alt="Scopus Profile - {$authorScopusID}" title="Scopus Profile - {$authorScopusID}"/>
                </a>
            </span>
        </xsl:if>
        
    </xsl:template>

    <!-- UTILITY TEMPLATES -->
    <!-- Template to process each language group -->
    <xsl:template name="process-language-groups">
        <xsl:param name="iso-lang"/>
        <xsl:param name="key-name"/>
        <xsl:param name="element"/>
        <xsl:param name="qualifier"/>
       
        <!-- Retrieve all language groups -->
        <xsl:variable name="languageGroups" select="//dim:field[generate-id() = generate-id(key($key-name, @language)[1]) and @element=$element and @qualifier=$qualifier]"/>
        <xsl:variable name="firstLang" select="$languageGroups[1]/@language"/>

        <xsl:choose>
            <xsl:when test="count($languageGroups[@language = $iso-lang]) > 0">
            <!-- There are keywords in publication's (ISO) language -->
                <xsl:call-template name="process-non-collapsible">
                    <!-- Crate a non colapsible row for items in iso-lang -->
                    <xsl:with-param name="language-groups" select="$languageGroups[@language = $iso-lang]" />
                    <xsl:with-param name="element" select="$element"/>
                    <xsl:with-param name="qualifier" select="$qualifier"/>
                </xsl:call-template>
                <xsl:if test="count($languageGroups[@language != $iso-lang]) > 0">
                    <!-- There are more kewords in other languages -->
                    <xsl:call-template name="process-collapsible">
                        <!-- Create a collapsible row for all other langauges -->
                        <xsl:with-param name="language-groups" select="$languageGroups[@language != $iso-lang]"/>
                        <xsl:with-param name="iso-lang" select="$iso-lang"/>
                        <xsl:with-param name="element" select="$element"/>
                        <xsl:with-param name="qualifier" select="$qualifier"/>
                        <xsl:with-param name="key-name" select="$key-name"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
            <!-- There are not keywords in publication's (ISO) language-->
                <xsl:call-template name="process-non-collapsible">
                    <!-- Create a non colapsible row for items in fist language group -->
                    <xsl:with-param name="language-groups" select="$languageGroups[@language = $firstLang]" />
                    <xsl:with-param name="element" select="$element"/>
                    <xsl:with-param name="qualifier" select="$qualifier"/>
                </xsl:call-template>
                <xsl:call-template name="process-collapsible">
                <!-- Crate a collapsible row for all other language groups-->
                    <xsl:with-param name="language-groups" select="$languageGroups[@language != $firstLang]"/>
                    <xsl:with-param name="iso-lang" select="$iso-lang"/>
                    <xsl:with-param name="element" select="$element"/>
                    <xsl:with-param name="qualifier" select="$qualifier"/>
                    <xsl:with-param name="key-name" select="$key-name"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>

    <!-- Template to process each language group -->
    <xsl:template name="process-language-group">
        <xsl:param name="iso-lang"/>
        <xsl:param name="element"/>
        <xsl:param name="qualifier"/>
        <xsl:param name="key-name"/>
        <xsl:if test="@language = $iso-lang">
        <div class="row">
            <div class="col-md-12">
            <span id="language-{@language}">
                <xsl:value-of select="@language"/>
                <xsl:text>: </xsl:text>
                <xsl:for-each select="//dim:field[@language = current()/@language and @element=$element and @qualifier=$qualifier]">
                    <xsl:value-of select="."/>
                    <xsl:if test="position() != last()">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </span>
            </div>
        </div>
        </xsl:if>
        <xsl:if test="@language != $iso-lang">
        <xsl:call-template name="collapsible-row">
            <xsl:with-param name="language" select="@language"/>
            <xsl:with-param name="key-name" select="$key-name"/>
            <xsl:with-param name="element" select="$element"/>
            <xsl:with-param name="qualifier" select="$qualifier"/>
        </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <!-- Template to process non-collapsible row -->
    <xsl:template name="process-non-collapsible">
        <xsl:param name="language-groups"/>
        <xsl:param name="element"/>
        <xsl:param name="qualifier"/>
        <xsl:choose>
        <xsl:when test="$language-groups">
            <div class="row">
                <div class="col-md-12">
                    <xsl:for-each select="$language-groups[1]">
                        <xsl:variable name="currentLanguage" select="@language"/>
                        <span id="language-{$currentLanguage}">
                            <!-- <xsl:value-of select="$currentLanguage"/>
                            <xsl:text>: </xsl:text> -->
                            <xsl:for-each select="//dim:field[@language = $currentLanguage and @element=$element and @qualifier=$qualifier]">
                                <xsl:value-of select="."/>
                                <xsl:if test="position() != last()">
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </span>
                        <xsl:if test="position() != last()">
                            <br/>
                        </xsl:if>
                    </xsl:for-each>
                </div>
            </div>
        </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- Template to process collapsible rows -->
    <xsl:template name="process-collapsible">
        <xsl:param name="language-groups"/>
        <xsl:param name="iso-lang"/>
        <xsl:param name="element"/>
        <xsl:param name="qualifier"/>
        <xsl:param name="key-name"/>
            <div class="row">
            <div class="col-md-12">
                <div id="{$element}-{$qualifier}-other-languages" class="collapse">
                <!-- <xsl:for-each select="$language-groups[position() &gt; 1]"> -->
                <xsl:for-each select="$language-groups">
                    <xsl:call-template name="process-language-group">
                        <xsl:with-param name="iso-lang" select="$iso-lang"/>
                        <xsl:with-param name="element" select="$element"/>
                        <xsl:with-param name="qualifier" select="$qualifier"/>
                        <xsl:with-param name="key-name" select="$key-name"/>
                    </xsl:call-template>
                </xsl:for-each>
                </div>
                <a data-toggle="collapse" href="#{$element}-{$qualifier}-other-languages"><i18n:text>xmlui.dri2xhtml.METS-1.0.item.show-metadata.other-languages</i18n:text></a>
            </div>
            </div>

    </xsl:template>

    <!-- Template to create collapsible rows -->
    <xsl:template name="collapsible-row">
        <xsl:param name="language"/>
        <xsl:param name="key-name"/>
        <xsl:param name="element"/>
        <xsl:param name="qualifier"/>
        <div class="spacer">&#160;</div>
        <div class="row">
        <div class="col-md-12">
            <!-- <a data-toggle="collapse" href="#language-{$language}"><xsl:value-of select="$language"/></a> -->
            <span id="{$element}-{$qualifier}-language-{$language}">
            <xsl:for-each select="key($key-name, $language)">
                <xsl:value-of select="."/>
                <xsl:if test="position() != last()">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>
            </span>
        </div>
        </div>
    </xsl:template>

</xsl:stylesheet>
