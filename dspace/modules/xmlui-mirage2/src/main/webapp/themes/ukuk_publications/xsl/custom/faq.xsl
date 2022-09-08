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

    <xsl:template name="faq-create">
        <xsl:call-template name="faq-intro-text"/>

        <xsl:call-template name="faq-section-repository"></xsl:call-template>
    </xsl:template>

    <xsl:template name="faq-intro-text">
        <p>
            <i18n:text>obd.faq.intro-text</i18n:text>
        </p>
    </xsl:template>

    <xsl:template name="faq-section-repository">
        <h2><i18n:text>obd.faq.section.repository.heading</i18n:text></h2>
    </xsl:template>

</xsl:stylesheet>