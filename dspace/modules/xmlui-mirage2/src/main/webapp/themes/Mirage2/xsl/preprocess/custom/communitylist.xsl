<?xml version="1.0" encoding="UTF-8"?>
<!--
    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at
    http://www.dspace.org/license/
-->

<!--
    Author: Art Lowel (art at atmire dot com)
    The purpose of this file is to transform the DRI for some parts of
    DSpace into a format more suited for the theme xsls. This way the
    theme xsl files can stay cleaner, without having to change Java
    code and interfere with other themes
    e.g. this file can be used to add a class to a form field, without
    having to duplicate the entire form field template in the theme xsl
    Simply add it here to the rend attribute and let the default form
    field template handle the rest.
-->

<xsl:stylesheet
        xmlns="http://di.tamu.edu/DRI/1.0/"
        xmlns:dri="http://di.tamu.edu/DRI/1.0/"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
        xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
        xmlns:mets="http://www.loc.gov/METS/"
        xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
        exclude-result-prefixes="xsl dri dim mets i18n">

    <xsl:output indent="yes"/>

    <xsl:variable name="currentLocale" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='page'][@qualifier='currentLocale']"/>

    <xsl:template match="mets:METS" mode="community-browser">
        <xsl:variable name="dim" select="mets:dmdSec/mets:mdWrap/mets:xmlData/dim:dim"/>
        <xref target="{@OBJID}" n="community-browser-link">
            <xsl:choose>
                <xsl:when
                        test="$currentLocale = 'cs' and string-length($dim/dim:field[@element='translatedcollectiontitle'][1]) &gt; 0">
                    <xsl:value-of select="$dim/dim:field[@element='translatedcollectiontitle'][1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$dim/dim:field[@element='title']"/>
                </xsl:otherwise>
            </xsl:choose>

        </xref>
        <!--Display community strengths (item counts) if they exist-->
        <xsl:if test="string-length($dim/dim:field[@element='format'][@qualifier='extent'][1]) &gt; 0">
            <span>
                <xsl:text> [</xsl:text>
                <xsl:value-of
                        select="$dim/dim:field[@element='format'][@qualifier='extent'][1]"/>
                <xsl:text>]</xsl:text>
            </span>
        </xsl:if>

        <xsl:variable name="description" select="$dim/dim:field[@element='description'][@qualifier='abstract']"/>
        <xsl:if test="string-length($description/text()) > 0">
            <p rend="hidden-xs">
                <xsl:value-of select="$description"/>
            </p>
        </xsl:if>

    </xsl:template>





</xsl:stylesheet>