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


    <xsl:template match="/dri:document/dri:body/dri:div[@n='main-recent-submissions']/dri:div[@n='main-recent-submissions-search']">
    <!-- Basic example can be found at https://getbootstrap.com/docs/3.4/examples/jumbotron/ -->
        <div class="row recent-submissions-search-form-row">
            <div id="recent-submissions-search-form" class="col-lg-12 recent-submissions-search-form-column">
                <xsl:call-template name="addSearch"/>   
            </div>
        </div>
        
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

</xsl:stylesheet>