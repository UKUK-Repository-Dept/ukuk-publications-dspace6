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
    <xsl:param name="mandatoryMetadataFile" select="document('../../static/OBD_mandatory_metadata.xml')"/>

    <xsl:template name="metadata-create">
            <xsl:call-template name="metadata-general"/>
            <!-- <xsl:call-template name="metadata-table-structure"/> -->
    </xsl:template>

    <xsl:template name="metadata-general">
        
        <xsl:call-template name="metadata-forms-process-xml-file-list"/>

    </xsl:template>

    <xsl:template name="metadata-forms-process-xml-file-list">
        
        <ul class="nav nav-pills"><!--<xsl:copy-of select="document('../../static/OBD_publication_types_accepted.xml')" />-->
            <li role="presentation" class="dropdown">
                <a class="dropdown-toggle" data-toggle="dropdown" href="#" role="button" aria-haspopup="true" aria-expanded="false">
                    Forma výsledku <span class="caret"></span>
                </a>
                <ul class="dropdown-menu">
                    <xsl:for-each select="$typologyFile//form">
                        <xsl:variable name="formValue" select="./@id"/>
                        <li role="presentation" data-toggle="collapse" data-target="#collapse{$formValue}">
                            <!-- TODO: Implement anchor link fix from CU Digital Repository before linking to a specific anchor in panel -->
                            <!-- <a href="#collapse{$formValue}"><i18n:text><xsl:value-of select="concat('obd.typology.form.id.',./@id)"/></i18n:text></a> -->
                            <a href="#"><i18n:text><xsl:value-of select="concat('obd.typology.form.id.',./@id)"/></i18n:text></a>
                        </li>
                        
                        <!-- <td><i18n:text><xsl:value-of select="concat('obd.typology.subform.id.',./subforms/subform/@id)"/></i18n:text></td> -->
                    </xsl:for-each>
                </ul>
            </li>
        </ul>

        <xsl:for-each select="$typologyFile//form">
            <xsl:variable name="formValueID" select="./@id"/>
            <xsl:call-template name="metadata-forms-generate-tables">
                <xsl:with-param name="publicationFormID" select="$formValueID"/>
            </xsl:call-template>
        </xsl:for-each>

    </xsl:template>

    <xsl:template name="metadata-forms-generate-tables">
        <xsl:param name="publicationFormID"/>

        <div class="panel panel-default">
            <div class="panel-heading">
                <h4 class="panel-title" data-toggle="collapse" data-target="#collapse{$publicationFormID}">
                    Tabulka povinných údajů - <i18n:text><xsl:value-of select="concat('obd.typology.form.id.', $publicationFormID)"/></i18n:text>
                </h4>
            </div>
            <div id="collapse{$publicationFormID}" class="panel-collapse collapse">

                <div class="panel-body">
                    <table class="table">
                        <caption class="sr-only">Tabulka povinných údajů - <i18n:text><xsl:value-of select="concat('obd.typology.form.id.', $publicationFormID)"/></i18n:text></caption>
                        <thead>
                            <tr>
                                <th scope="col">název údaje</th>
                                <th scope="col">OBD: sekce formuláře</th>
                                <th scope="col">OBD: pole formuláře</th>
                                <th scope="col">vydaný výsledek</th>
                                <th scope="col">nevydaný výsledek</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!-- TODO: Create table values based on a XML "configuration" file -->
                            <xsl:for-each select="$mandatoryMetadataFile//form">
                                <xsl:choose>
                                    <xsl:when test="./@id = $publicationFormID">
                                        <xsl:for-each select=".//metadatum">
                                            <xsl:variable name="systemMetadatum" select="./meta_info/@system"/>
                                            <xsl:variable name="metadatumID" select="./@id"/>
                                            <xsl:variable name="metadatumInternalName" select="./@internal_name"/>
                                            <xsl:variable name="obdSectionTranslationKey" select="./meta_info/@obd_section_translation"/>
                                            <xsl:variable name="obdFieldTranslationKey" select="./meta_info/@obd_field_translation"/>
                                            <xsl:variable name="validForPublicationState" select="./meta_info/@valid_for"/>
                                            
                                            <xsl:if test="./meta_info[@system = 'false']">
                                                <tr>
                                                    <td>
                                                        <i18n:text>obd.metadata.metadatum.id.<xsl:value-of select="$metadatumID"/></i18n:text>
                                                    </td>
                                                    <td>
                                                        <i18n:text>
                                                            <xsl:value-of select="concat('obd.form-id-',$publicationFormID,'.mandatory.metadata.',
                                                            'section-trl.',$obdSectionTranslationKey)"/>
                                                        </i18n:text>
                                                    </td>
                                                    <td>
                                                        <i18n:text>
                                                            <xsl:value-of select="concat('obd.form-id-',$publicationFormID,'.mandatory.metadata.id.',$metadatumID,
                                                            '.field-trl.',$obdFieldTranslationKey)"/>
                                                        </i18n:text>
                                                    </td>
                                                    <xsl:choose>
                                                        <xsl:when test="$validForPublicationState = 'both'">
                                                            <td>X</td>
                                                            <td>X</td>
                                                        </xsl:when>
                                                        <xsl:when test="$validForPublicationState = 'published'">
                                                            <td>X</td>
                                                            <td></td>
                                                        </xsl:when>
                                                        <xsl:when test="$validForPublicationState = 'not_published'">
                                                            <td></td>
                                                            <td>X</td>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </tr>
                                            </xsl:if>
                                        </xsl:for-each>
                                    </xsl:when>
                                    <xsl:otherwise>

                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </xsl:template>

</xsl:stylesheet>