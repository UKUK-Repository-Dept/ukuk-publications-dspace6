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

    <xsl:template name="typology-forms-create">
        <xsl:call-template name="typology-forms-table"/>
    </xsl:template>

    <xsl:template name="typology-forms-table">
        <div class="table-responsive">
            <table class="table table-condensed table-hover">
                <caption class="sr-only"><i18n:text>xmlui.mirage2.static-pages.heading.typology</i18n:text></caption>
                <thead>
                    <tr>
                        <!-- TODO: These should be an i18n text and should have translation keys in messages.xml and messages_cs.xml -->
                        <th>OBD - forma</th>
                        <th>OBD - poddruh</th>
                        <th>OBD - podřazený poddruh</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:call-template name="typology-forms-process-xml-file"/>
                </tbody>
            </table>
        </div>
    </xsl:template>

    <xsl:template name="typology-forms-table-row">

    </xsl:template>

    <xsl:template name="typology-forms-process-xml-file">
        <!--<xsl:copy-of select="document('../../static/OBD_publication_types_accepted.xml')" />-->
        <xsl:for-each select="$typologyFile//form">
            <tr>
                <td><i18n:text><xsl:value-of select="concat('obd.typology.form.id.',./@id)"/></i18n:text></td>
                <td><i18n:text><xsl:value-of select="concat('obd.typology.subform.id.',./subforms/subform/@id)"/></i18n:text></td>
            
                <xsl:choose>
                    <xsl:when test="./subforms/subform/child_subforms/@all-supported = 'true'">
                        <!-- TODO: This should be an i18n:text and it should have a translation message / key in messages.xml and messages_cs.xml -->
                        <td><xsl:text>všechny podřazené poddruhy</xsl:text></td>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="not(./subforms/subform/child_subforms/child_subform)">
                            <td></td>
                        </xsl:if>
                        <xsl:for-each select=".//child_subform">
                            <xsl:choose>
                                <xsl:when test="position() = 1">
                                    <td>
                                        <i18n:text><xsl:value-of select="concat('obd.typology.subform.child.id.',./@id)"/></i18n:text>
                                    </td>
                                </xsl:when>
                                <xsl:otherwise>
                                    <tr>
                                        <td></td>
                                        <td></td>
                                        <td>
                                            <i18n:text><xsl:value-of select="concat('obd.typology.subform.child.id.',./@id)"/></i18n:text>
                                        </td>
                                    </tr>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </tr>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>