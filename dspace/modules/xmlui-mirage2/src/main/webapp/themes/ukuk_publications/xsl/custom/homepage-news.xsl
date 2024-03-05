<?xml version="1.0" encoding="UTF-8"?>

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
    <xsl:import href="../aspect/artifactbrowser/item-view-license.xsl" />
    <xsl:import href="utility.xsl"/>

    <xsl:output indent="yes"/>

    <xsl:variable name="solrURL">
        <xsl:value-of select="concat(confman:getProperty('solr.server'), '/search')" />
    </xsl:variable>

    <xsl:variable name="solrOpenAccessItemsQuery">
        <!-- <xsl:text>search.resourcetype%3A2+AND+dcterms.accessRights%3A%27openAccess%27&amp;sort=dc.date.accessioned_dt+DESC</xsl:text> -->
        <!-- <xsl:text>search.resourcetype%3A2+AND+dcterms.accessRights%3A(%27openAccess%27+OR+%27embargoedAccess%27)&amp;sort=dc.date.accessioned_dt+DESC&amp;order=desc</xsl:text> -->
        <xsl:text>dcterms.accessRights%3A(%27openAccess%27+OR+%27embargoedAccess%27)&amp;sort=dc.date.accessioned_dt+DESC&amp;order=desc</xsl:text>
    </xsl:variable>

    <xsl:variable name="openAccessItemsInDiscoveryURL">
        <xsl:value-of select="concat(confman:getProperty('dspace.baseUrl'),'/discover?query=',$solrOpenAccessItemsQuery)"/>
    </xsl:variable>

    <xsl:variable name="solrAllItemsQuery">
        <xsl:text>search.resourcetype%3A2&amp;sort=dc.date.accessioned_dt+DESC&amp;order=desc</xsl:text>
    </xsl:variable>

    <xsl:variable name="totalItemsInDiscoveryURL">
        <xsl:value-of select="concat(confman:getProperty('dspace.baseUrl'),'/discover?query=',$solrAllItemsQuery)"/>
    </xsl:variable>

    <xsl:variable name="recentSubmissionsURL">
        <xsl:value-of select="concat(confman:getProperty('dspace.baseUrl'), '/recent-submissions')"/>
    </xsl:variable>

<xsl:template match="/dri:document/dri:body/dri:div[@id='file.news.div.news'][@n='news']">
<!-- Basic example can be found at https://getbootstrap.com/docs/3.4/examples/jumbotron/ -->
    <div class="jumbotron jumbotron-muted homepage-jumbotron">
        <div class="container homepage-jumbotron-container">
            <div class="col-lg-6 col-md-6 col-sm-6 col-xs-12 homepage-jumbotron-column">
                <h2 class="lead"><i18n:text>xmlui.homepage.jumbotron.welcome.heading</i18n:text></h2>
                <p class="lead">
                    <i18n:text>xmlui.homepage.jumbotron.welcome.text.part.1</i18n:text>
                    <xsl:text> </xsl:text> <!-- Adding whitespace before number -->
                    <strong>
                        <xsl:call-template name="getTotalItemsCountWithLink"/>
                    </strong>
                    <xsl:text> </xsl:text> <!-- Adding whitespace after the number --> 
                    <i18n:text>xmlui.homepage.jumbotron.welcome.text.part.2</i18n:text>
                    <xsl:text> </xsl:text> <!-- Adding whitespace before number -->
                    <strong>
                        <xsl:call-template name="getOpenAccessItemsCountWithLink"/>
                    </strong>
                    <xsl:text> </xsl:text> <!-- Adding whitespace after the number --> 
                    <i18n:text>xmlui.homepage.jumbotron.welcome.text.part.3</i18n:text>
                </p>
                <!-- <xsl:call-template name="addSearch"/> -->
                <!-- <div class="input-group">
                    <input type="text" class="form-control" placeholder="Enter your email"></input>
                    <span class="input-group-btn">
                        <button class="btn btn-primary" type="button">Download My Free Ebook</button>
                    </span>
                </div> -->
                <!-- <br></br>
                <small>
                    By submitting this form, you agree to our <a href="#!" target="_blank">Terms of Service <i class="fa fa-external-link" aria-hidden="true"></i></a> 
                    and <a href="#!" target="_blank">Privacy Policy <i class="fa fa-external-link" aria-hidden="true"></i></a>.
                </small> -->
            </div>
            <!-- <div class="col-lg-1 col-md-1 homepage-jumbotron-column"></div> -->
            <div class="col-lg-6 col-md-6 col-sm-6 col-xs-12 homepage-jumbotron-column hidden-xs">
                <!-- <img class="img-responsive" src="{$theme-path}/images/repository_homepage-jumbo_picture.png"/> -->
            </div>
            <div id="jumbotron-search-form" class="col-lg-12 col-sm-12 col-xs-12 homepage-jumbotron-column">
                <xsl:call-template name="addSearch"/>   
            </div>
        </div>
    </div>
    <div class="container-fluid homepage-selection">
        <div class="row feature-row">
            <div class="col-xs-12 col-sm-12 col-md-4 feature-column">
                <div class="col-md-12 feature-box">
                    <a role="button" class="btn btn-primary site-btn homepage-options-button" href="{$recentSubmissionsURL}">
                        <img class="img img-responsive" src="{$theme-path}/images/repository_homepage_recent-submissions.png"/>
                    </a>
                    <h4>
                        <i18n:text>xmlui.ArtifactBrowser.CollectionViewer.head_recent_submissions</i18n:text>
                    </h4>
                    <p>
                        <i18n:text>xmlui.homepage.recentSubmissions.info.text</i18n:text>
                    </p>
                    <div class="row feature-box-button-row">
                        <div class="col-md-12 feature-box-column-content">
                            <a role="button" class="btn btn-primary site-btn homepage-options-button" href="{$recentSubmissionsURL}">
                                <i18n:text>xmlui.homepage.recentSubmissions.button.text</i18n:text>
                            </a>
                        </div>
                    </div>
                </div>
            </div> <!-- End Col -->
            <div class="col-xs-12 col-sm-6 col-md-4 feature-column">
                <div class="col-md-12 feature-box">
                    <xsl:variable name="howToDepositURL" select="concat(confman:getProperty('dspace.baseUrl'),'/page/about#heading-about-workflow')"/>
                    <a role="button" class="btn btn-primary site-btn homepage-options-button" href="{$howToDepositURL}" target="_blank">
                        <img class="img img-responsive" src="{$theme-path}/images/repository_homepage_how-to-deposit.png"/>
                    </a>
                    <h4>
                        <i18n:text>xmlui.homepage.howToDeposit</i18n:text>
                    </h4>
                    <p>
                        <i18n:text>xmlui.homepage.howToDeposit.info.text</i18n:text>
                    </p>
                    <div class="row feature-box-button-row">
                        <div class="col-md-12 feature-box-column-content">
                            
                            <a role="button" class="btn btn-primary site-btn homepage-options-button" href="{$howToDepositURL}" target="_blank">
                                <i18n:text>xmlui.homepage.howToDeposit.button.text</i18n:text>
                            </a>
                        </div>
                    </div>
                </div>
            </div> <!-- End Col -->	
            
            <div class="col-xs-12 col-sm-6 col-md-4 feature-column">
                <div class="col-md-12 feature-box">
                    <a role="button" class="btn btn-primary site-btn homepage-options-button" target="_blank">
                        <xsl:if test="$active-locale = 'cs'">
                            <xsl:attribute name="href"><xsl:text>https://openscience.cuni.cz/OSCI-1.html</xsl:text></xsl:attribute>
                        </xsl:if>
                        <xsl:if test="$active-locale = 'en'">
                            <xsl:attribute name="href"><xsl:text>https://openscience.cuni.cz/OSCIEN-1.html</xsl:text></xsl:attribute>
                        </xsl:if>
                        <img class="img img-responsive" src="{$theme-path}/images/repository_homepage_help.png"/>
                    </a>
                    <h4>
                        <i18n:text>xmlui.homepage.getHelp</i18n:text>
                    </h4>
                    <p>
                        <i18n:text>xmlui.homepage.getHelp.info.text</i18n:text>
                    </p>
                    <div class="row feature-box-button-row">
                        <div class="col-md-12 feature-box-column-content">
                            <a role="button" class="btn btn-primary site-btn homepage-options-button" target="_blank">
                                <xsl:if test="$active-locale = 'cs'">
                                    <xsl:attribute name="href"><xsl:text>https://openscience.cuni.cz/OSCI-1.html</xsl:text></xsl:attribute>
                                </xsl:if>
                                <xsl:if test="$active-locale = 'en'">
                                    <xsl:attribute name="href"><xsl:text>https://openscience.cuni.cz/OSCIEN-1.html</xsl:text></xsl:attribute>
                                </xsl:if>
                                <i18n:text>xmlui.homepage.getHelp.button.text</i18n:text>
                            </a>
                        </div>
                    </div>
                </div>
            </div> <!-- End Col -->
        </div>
    </div>
</xsl:template>

<xsl:template name="getTotalItemsCountWithLink">

    <xsl:variable name="totalItemsCountXML" select="document(concat($solrURL,'/select?q=',$solrAllItemsQuery,'&amp;rows=0&amp;wt=xml&amp;indent=true'))"/>

    <a id="homepage-jumbotron-total-items-count" class="homepage-jumbotron-link" href="{$totalItemsInDiscoveryURL}">
        <xsl:value-of select="$totalItemsCountXML/response/result/@numFound"/>
    </a>

</xsl:template>

<xsl:template name="getOpenAccessItemsCountWithLink">
    
    <!-- http://localhost:1234/solr/search/select?q=search.resourcetype%3A2+and+dcterms.accessRights%3A%27openAccess%27&rows=0&wt=xml&indent=true -->
    <xsl:variable name="openAccessItemsCountXML" select="document(concat($solrURL,'/select?q=',$solrOpenAccessItemsQuery,'&amp;rows=0&amp;wt=xml&amp;indent=true'))"/>
    
    <a id="homepage-jumbotron-openAcess-items-count" class="homepage-jumbotron-link" href="{$openAccessItemsInDiscoveryURL}">
        <xsl:value-of select="$openAccessItemsCountXML/response/result/@numFound"/>
    </a>

</xsl:template>

<xsl:template name="addSearch">
    <xsl:if test="not(contains(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI'], 'discover'))">
        <div id="ds-search-option" class="ds-option-set">
            <!-- The form, complete with a text box and a button, all built from attributes referenced
            from under pageMeta. -->
            <form id="ds-search-form" class="" method="post">
                <xsl:attribute name="action">
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath']"/>
                    <xsl:value-of
                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='simpleURL']"/>
                </xsl:attribute>
                <fieldset>
                    <div class="input-group">
                        <input class="ds-text-field form-control" type="text" placeholder="xmlui.general.search"
                                i18n:attr="placeholder">
                            <xsl:attribute name="name">
                                <xsl:value-of
                                        select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='queryField']"/>
                            </xsl:attribute>
                        </input>
                        <span class="input-group-btn">
                            <button class="ds-button-field btn btn-primary" title="xmlui.general.go" i18n:attr="title" id="homepage-jumbotron-search-button">
                                <span class="glyphicon glyphicon-search" aria-hidden="true"/>
                                <xsl:attribute name="onclick">
                                            <xsl:text>
                                                var radio = document.getElementById(&quot;ds-search-form-scope-container&quot;);
                                                if (radio != undefined &amp;&amp; radio.checked)
                                                {
                                                var form = document.getElementById(&quot;ds-search-form&quot;);
                                                form.action=
                                            </xsl:text>
                                    <xsl:text>&quot;</xsl:text>
                                    <xsl:value-of
                                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath']"/>
                                    <xsl:text>/handle/&quot; + radio.value + &quot;</xsl:text>
                                    <xsl:value-of
                                            select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='simpleURL']"/>
                                    <xsl:text>&quot; ; </xsl:text>
                                            <xsl:text>
                                                }
                                            </xsl:text>
                                </xsl:attribute>
                            </button>
                        </span>
                    </div>

                    <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='focus'][@qualifier='container']">
                        <div class="radio">
                            <label>
                                <input id="ds-search-form-scope-all" type="radio" name="scope" value=""
                                        checked="checked"/>
                                <i18n:text>xmlui.dri2xhtml.structural.search</i18n:text>
                            </label>
                        </div>
                        <div class="radio">
                            <label>
                                <input id="ds-search-form-scope-container" type="radio" name="scope">
                                    <xsl:attribute name="value">
                                        <xsl:value-of
                                                select="substring-after(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='focus'][@qualifier='container'],':')"/>
                                    </xsl:attribute>
                                </input>
                                <xsl:choose>
                                    <xsl:when
                                            test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='focus'][@qualifier='containerType']/text() = 'type:community'">
                                        <i18n:text>xmlui.dri2xhtml.structural.search-in-community</i18n:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <i18n:text>xmlui.dri2xhtml.structural.search-in-collection</i18n:text>
                                    </xsl:otherwise>

                                </xsl:choose>
                            </label>
                        </div>
                    </xsl:if>
                </fieldset>
            </form>
        </div>
    </xsl:if>
</xsl:template>

<xsl:template match="/dri:document/dri:body/dri:div[@id='aspect.artifactbrowser.CommunityBrowser.div.comunity-browser'][@n='comunity-browser']">

    <!--  If we are no homepage, don't render community-browser...-->
    <xsl:choose>
        <xsl:when test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI'] = ''">

        </xsl:when>
        <xsl:otherwise>
            <!--  ...apply necessary templates otherwise, i.e. render communities and collections on /community-list page -->
            <xsl:apply-templates/>
        </xsl:otherwise>
    </xsl:choose>


</xsl:template>

<xsl:template match="/dri:document/dri:body/dri:div[@id='aspect.discovery.SiteRecentSubmissions.div.site-home'][@n='site-home']">

</xsl:template>

<xsl:template match="dri:list[@n='uk.publicationFacultyResponsibility.cs']">
    <xsl:choose>
        <!--  If we are no homepage, don't render this facet list...-->
        <xsl:when test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI'] = ''">

        </xsl:when>
        <xsl:otherwise>
            <xsl:apply-templates/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="dri:list[@n='uk.publicationDepartmentResponsibility.cs']">
    <xsl:choose>
        <!--  If we are no homepage, don't render this facet list...-->
        <xsl:when test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI'] = ''">

        </xsl:when>
        <xsl:otherwise>
            <xsl:apply-templates/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>