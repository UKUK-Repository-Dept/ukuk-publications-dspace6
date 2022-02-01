<?xml version="1.0" encoding="UTF-8"?>
<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Author: Jakub Řihák (jakub dot rihak at ruk dot cuni dot com)

    XSLT templates related to generation of HTML code for 'typology'
    static page.

    On this page, users can find information about what forms of research
    outputs are accepted into the CUNI Research Outputs repository from
    CUNI CRIS system (OBD).

    Stylesheet is imported in the core/page-structure.xsl. Templates related to
    'typology' page are then called from within the appropriate part of
    core/page-structure.xsl (see <xsl:template match="dri:body"> in core/page-structure.xsl).
-->

<xsl:stylesheet xmlns="http://di.tamu.edu/DRI/1.0/"
                xmlns:dri="http://di.tamu.edu/DRI/1.0/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
                exclude-result-prefixes="xsl dri i18n">

    <xsl:output indent="yes"/>
    <xsl:param name="typologyFile" select="document('../../static/OBD_publication_types_accepted.xml')"/>

    <xsl:template name="disclaimer-create">
        <xsl:call-template name="disclaimer-text"/>
    </xsl:template>

    <xsl:template name="disclaimer-text">
        <h1><i18n:text>xmlui.mirage2.static-pages.title.disclaimer</i18n:text></h1>
        <br/>
        <h2><i18n:text>xmlui.mirage2.static-pages.disclaimer.section.cooauthors</i18n:text></h2>
        <br/>
        <p>
            <i18n:text>xmlui.mirage2.static-pages.disclaimer.section.cooauthors.para.1</i18n:text>
        </p>
        <p>
            <i18n:text>xmlui.mirage2.static-pages.disclaimer.section.cooauthors.para.2</i18n:text>
        </p>
        <p>
            <i18n:text>xmlui.mirage2.static-pages.disclaimer.section.cooauthors.para.3</i18n:text>
        </p>
        <br/>
        <h2><i18n:text>xmlui.mirage2.static-pages.disclaimer.section.publisher-third-parties</i18n:text></h2>
        <br/>
        <p>
            <i18n:text>xmlui.mirage2.static-pages.disclaimer.section.publisher-third-parties.para.1</i18n:text>
        </p>
        <p>
            <i18n:text>xmlui.mirage2.static-pages.disclaimer.section.publisher-third-parties.para.2</i18n:text>
        </p>
    </xsl:template>

</xsl:stylesheet>