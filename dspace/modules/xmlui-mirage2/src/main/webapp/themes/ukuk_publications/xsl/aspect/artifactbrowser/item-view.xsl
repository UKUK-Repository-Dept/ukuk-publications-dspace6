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
            <xsl:call-template name="itemSummaryView-DIM-title"/>
            <!-- <JR> - 2023-06-13: TODO: Add template for rendering translated title and try rendering uk.displayTitle.translated when present, instead of dc.title.translated -->
            <xsl:call-template name="itemSummaryView-DIM-title-translated"/>
            <div class="row">
                <div class="col-sm-4">
                    <div class="row">
                        <div class="col-xs-6 col-sm-12">
                            <xsl:call-template name="itemSummaryView-DIM-thumbnail"/>
                        </div>
                        <div class="col-xs-6 col-sm-12">
                            <xsl:call-template name="itemSummaryView-DIM-file-section"/>
                        </div>
                    </div>
					<xsl:call-template name="itemSummaryView-DIM-other-output-versions"/>
                    <xsl:call-template name="itemSummaryView-DIM-date"/>
                    <xsl:call-template name="itemSummaryView-DIM-authors"/>
                    <xsl:if test="$ds_item_view_toggle_url != ''">
                        <xsl:call-template name="itemSummaryView-show-full"/>
                    </xsl:if>
                </div>
                <div class="col-sm-8">
                    <xsl:call-template name="itemSummaryView-DIM-abstract"/>
                    <xsl:call-template name="itemSummaryView-DIM-URI"/>
                    <xsl:call-template name="license">
                        <xsl:with-param name="metadataURL" select="./dri:referenceSet/dri:reference/@url"/>
                    </xsl:call-template>
                    <!-- <xsl:call-template name="itemSummaryView-DIM-SOLR-test"/> -->
                    <xsl:call-template name="itemSummaryView-collections"/>
                </div>
            </div>
        </div>
    </xsl:template>

    <!-- <JR> - 2022-09-02 - THIS EXAMPLE WORKS -->
	<xsl:template name="itemSummaryView-DIM-other-output-versions">
		<xsl:variable name="solrURL">
			<xsl:text>http://localhost:8080/solr/search</xsl:text>
        </xsl:variable>
		<xsl:variable name="currentOutputVersion" select="dim:field[@element='type'][@qualifier='version']"/>
		<xsl:variable name="outputOBDid" select="dim:field[@element='identifier'][@qualifier='obd']"/>
		<xsl:apply-templates select="document(concat($solrURL,'/select?q=search.resourcetype%3A2+AND+!dc.type.version%3A%22',$currentOutputVersion,'%22+AND+dc.identifier.obd%3A',$outputOBDid,'&amp;fl=dc.identifier.uri%2Cdc.type.version&amp;wt=xml&amp;indent=true'))" mode="solrOtherOutputVersions"/>
	</xsl:template>



    <xsl:template match="*" mode="solrOtherOutputVersions">
        <xsl:if test="/response/result/@numFound != '0'">
            <div class="simple-item-view-otherOutputVersions item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-otherOutputVersions</i18n:text></h5>
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
                    <!-- 
                        Create link to other output version:
                            - href: value of otherOutputVersionURL variable - value is parsed directly from SOLR response
                            - link text: i18n string created by a prefix (hardcoded) and processed other output's version name, connected by '.'
                    -->
                    <a href="{$otherOutputVersionURL}" target="_blank">
                        <i18n:text><xsl:value-of select="concat('xmlui.publication.version.',$otherOutputVersionType)"/></i18n:text>
                    </a>
                </xsl:for-each>
            </div>
        </xsl:if>
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
                                        <xsl:value-of select="./node()"/>
                                    </h3>
                                </xsl:when>
                                <xsl:when test="position() = 1">
                                    <h3 class="first-page-header item-title">
                                            <xsl:value-of select="./node()"/>
                                    </h3>
                                    <p class="lead item-view-title-lead" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <h3 class="first-page-header item-title">
                                        <xsl:value-of select="./node()"/>
                                    </h3>
                                    <p class="lead item-view-title-lead" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="count(dim:field[@element='title'][@qualifier='translated']) = 1">
                        <h2 class="page-header first-page-header item-title-translated">
                            <xsl:value-of select="dim:field[@element='title'][@qualifier='translated'][1]/node()"/>
                        </h2>
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
                        <xsl:call-template name="utility-parse-display-title">
                            <xsl:with-param name="title-string" select="./node()"/>
                        </xsl:call-template>
                    </h3>
                </xsl:when>
                <xsl:when test="position() = 1">
                    <h3 class="first-page-header item-title-translated">
                        <xsl:call-template name="utility-parse-display-title">
                            <xsl:with-param name="title-string" select="./node()"/>
                        </xsl:call-template>
                    </h3>
                    <p class="lead item-view-title-lead" />
                </xsl:when>
                <xsl:otherwise>
                    <h3 class="first-page-header item-title-translated">
                        <xsl:call-template name="utility-parse-display-title">
                            <xsl:with-param name="title-string" select="./node()"/>
                        </xsl:call-template>
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
                        <xsl:when test="contains($src,'isAllowed=n')"/>
                        <xsl:otherwise>
                            <img class="img-thumbnail" alt="Thumbnail">
                                <xsl:attribute name="src">
                                    <xsl:value-of select="$src"/>
                                </xsl:attribute>
                            </img>
                        </xsl:otherwise>
                    </xsl:choose>
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
        </div>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-abstract">
        <xsl:if test="dim:field[@element='description' and @qualifier='abstract']">
            <div class="simple-item-view-description item-page-field-wrapper table">
                <!-- <JR> - Add heading for abstract visible all the time and specifying the abstract language -->
                <!-- <h5 class="visible-xs"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract</i18n:text></h5>-->
                <div>
                    <xsl:for-each select="dim:field[@element='description' and @qualifier='abstract']">
                        <xsl:variable name="language" select="@language"/>
                        <h5 class="item-view-metadata-heading" if="item-view-metadata-abstract-{$language}"><i18n:text>xmlui.dri2xhtml.METS-1.0.item-abstract</i18n:text> (<xsl:value-of select="$language"/>)</h5>
                        <xsl:choose>
                            <xsl:when test="node()">
                                <xsl:copy-of select="node()"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>&#160;</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(following-sibling::dim:field[@element='description' and @qualifier='abstract']) != 0">
                            <div class="spacer">&#160;</div>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="count(dim:field[@element='description' and @qualifier='abstract']) &gt; 1">
                        <div class="spacer">&#160;</div>
                    </xsl:if>
                </div>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-authors">
        
        <!-- 
            Variable holding SOLR XML response containing information about researcher identifiers of all authors of a given item.

            If the item is not found in SOLR, variable does not have a value and no identifiers are added to author's name in simple-item-view.
        -->
        <xsl:variable name="itemAuthorIdentifiers" select="document(concat($solrURL,'/select?q=search.resourcetype%3A2+AND+handle%3A', $itemHandle, '&amp;fl=uk.author.identifier&amp;wt=xml&amp;indent=true'))"/>
        
        <xsl:variable name="processedContributorsCount"><xsl:text>0</xsl:text></xsl:variable>

        <xsl:if test="dim:field[@element='contributor'][@qualifier='author' and descendant::text()] or dim:field[@element='creator' and descendant::text()] or dim:field[@element='contributor' and descendant::text()]">
            <div class="simple-item-view-authors item-page-field-wrapper table">
                <h5><i18n:text>xmlui.dri2xhtml.METS-1.0.item-author</i18n:text></h5>
                <xsl:choose>
                    <xsl:when test="dim:field[@element='contributor'][@qualifier='author']">
                        <xsl:for-each select="dim:field[@element='contributor'][@qualifier='author']">
                            <xsl:variable name="processedContributorsCount" select="count(number($processedContributorsCount)) + 1"/>
                            <!-- 
                                Calling template that matches author's name with names available in the metadata field holding his identifiers.
                                Since one item could have multiple authors with multiple researcher identifiers, each author's identifiers are stored in separate metadata fields.
                                To assign correct identifiers to a correct person, we need to match author's name with a correct metadata field holding his / her identifiers.

                                Correct metadata string for a given author is then stored in variable which value is passed to itemSummaryView-DIM-authors-entry template
                                responsible for adding author's name to HTML.
                            -->
                            <xsl:variable name="currentAuthorIdentifiers">
                                <xsl:call-template name="utility-authorIdentifiersParse">
                                    <xsl:with-param name="authorIdentifiersXML" select="$itemAuthorIdentifiers"/>
                                    <xsl:with-param name="authorNameInMetadata" select="node()"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry">
                                <xsl:with-param name="currentAuthorIdentifiersRecord" select="$currentAuthorIdentifiers"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="dim:field[@element='creator']">
                        <xsl:for-each select="dim:field[@element='creator']">
                            <xsl:variable name="processedContributorsCount" select="count(number($processedContributorsCount)) + 1"/>
                            <!-- 
                                Calling template that matches author's name with names available in the metadata field holding his identifiers.
                                Since one item could have multiple authors with multiple researcher identifiers, each author's identifiers are stored in separate metadata fields.
                                To assign correct identifiers to a correct person, we need to match author's name with a correct metadata field holding his / her identifiers.

                                Correct metadata string for a given author is then stored in variable which value is passed to itemSummaryView-DIM-authors-entry template
                                responsible for adding author's name to HTML.
                            -->
                            <xsl:variable name="currentAuthorIdentifiers">
                                <xsl:call-template name="utility-authorIdentifiersParse">
                                    <xsl:with-param name="authorIdentifiersXML" select="$itemAuthorIdentifiers"/>
                                    <xsl:with-param name="authorNameInMetadata" select="node()"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry">
                                <xsl:with-param name="currentAuthorIdentifiersRecord" select="$currentAuthorIdentifiers"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="dim:field[@element='contributor']">
                        <xsl:for-each select="dim:field[@element='contributor']">
                            <xsl:variable name="processedContributorsCount" select="count(number($processedContributorsCount)) + 1"/>
                            <!-- 
                                Calling template that matches author's name with names available in the metadata field holding his identifiers.
                                Since one item could have multiple authors with multiple researcher identifiers, each author's identifiers are stored in separate metadata fields.
                                To assign correct identifiers to a correct person, we need to match author's name with a correct metadata field holding his / her identifiers.

                                Correct metadata string for a given author is then stored in variable which value is passed to itemSummaryView-DIM-authors-entry template
                                responsible for adding author's name to HTML.
                            --> 
                            <xsl:variable name="currentAuthorIdentifiers">
                                <xsl:call-template name="utility-authorIdentifiersParse">
                                    <xsl:with-param name="authorIdentifiersXML" select="$itemAuthorIdentifiers"/>
                                    <xsl:with-param name="authorNameInMetadata" select="node()"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:call-template name="itemSummaryView-DIM-authors-entry">
                                <xsl:with-param name="currentAuthorIdentifiersRecord" select="$currentAuthorIdentifiers"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.no-author</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="$processedContributorsCount"/>
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
                <h5><i18n:text>item-view.cuni.permanent-link.heading</i18n:text></h5>
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

    <xsl:template name="itemSummaryView-DIM-date">
        <xsl:if test="dim:field[@element='date' and @qualifier='issued' and descendant::text()]">
            <div class="simple-item-view-date word-break item-page-field-wrapper table">
                <h5>
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

    <xsl:template name="itemSummaryView-show-full">
        <div class="simple-item-view-show-full item-page-field-wrapper table">
            <h5>
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
                <h5>
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
                    <h5>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-viewOpen</i18n:text>
                    </h5>

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
        <div>
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="$href"/>
                </xsl:attribute>
                <xsl:call-template name="getFileIcon">
                    <xsl:with-param name="mimetype">
                        <xsl:value-of select="substring-before($mimetype,'/')"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="substring-after($mimetype,'/')"/>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:choose>
                    <!-- <JR> - 21. 9. 2020 - Generate i18n text from file label (stored in <dim:field mdschema="dc" element="description" /> element 
                    of the SOURCEMD part of each file in mets.xml)
                    -->
                    <xsl:when test="contains($label-1, 'label') and string-length($label)!=0">
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-label.<xsl:value-of select="$label"/></i18n:text>
                    </xsl:when>
                    <xsl:when test="contains($label-1, 'title') and string-length($title)!=0">
                        <xsl:value-of select="$title"/>
                    </xsl:when>
                    <xsl:when test="contains($label-2, 'label') and string-length($label)!=0">
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.item-files-label.<xsl:value-of select="$label"/></i18n:text>
                    </xsl:when>
                    <xsl:when test="contains($label-2, 'title') and string-length($title)!=0">
                        <xsl:value-of select="$title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="getFileTypeDesc">
                            <xsl:with-param name="mimetype">
                                <xsl:value-of select="substring-before($mimetype,'/')"/>
                                <xsl:text>/</xsl:text>
                                <xsl:choose>
                                    <xsl:when test="contains($mimetype,';')">
                                        <xsl:value-of select="substring-before(substring-after($mimetype,'/'),';')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="substring-after($mimetype,'/')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text> (</xsl:text>
                <xsl:choose>
                    <xsl:when test="$size &lt; 1024">
                        <xsl:value-of select="$size"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-bytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="$size &lt; 1024 * 1024">
                        <xsl:value-of select="substring(string($size div 1024),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-kilobytes</i18n:text>
                    </xsl:when>
                    <xsl:when test="$size &lt; 1024 * 1024 * 1024">
                        <xsl:value-of select="substring(string($size div (1024 * 1024)),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-megabytes</i18n:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring(string($size div (1024 * 1024 * 1024)),1,5)"/>
                        <i18n:text>xmlui.dri2xhtml.METS-1.0.size-gigabytes</i18n:text>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>)</xsl:text>
            </a>
            <xsl:if test="$embargo">
                <span id="embargo-{$href}">
                    <xsl:text>(</xsl:text><i18n:text>xmlui.dri2xhtml.METS-1.0.embargo-text</i18n:text><xsl:value-of select="$embargo" /><xsl:text>)</xsl:text>
                </span>
            </xsl:if>
        </div>
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

    <xsl:template name="getFileIcon">
        <xsl:param name="mimetype"/>
            <i aria-hidden="true">
                <xsl:attribute name="class">
                <xsl:text>glyphicon </xsl:text>
                <xsl:choose>
                    <xsl:when test="contains(mets:FLocat[@LOCTYPE='URL']/@xlink:href,'isAllowed=n')">
                        <xsl:text> glyphicon-lock</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> glyphicon-file</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                </xsl:attribute>
            </i>
        <xsl:text> </xsl:text>
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


</xsl:stylesheet>
