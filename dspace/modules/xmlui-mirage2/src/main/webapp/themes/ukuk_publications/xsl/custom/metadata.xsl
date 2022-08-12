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
        
        <xsl:call-template name="metadata-general-info"/>
        <xsl:call-template name="metadata-forms-process-xml-file-list"/>

    </xsl:template>

    <xsl:template name="metadata-general-info">
        <br/>
        <p><i18n:text>xmlui.mirage2.static-pages.metadata.section.intro.para.1</i18n:text></p>
        <br/>
        <blockquote>
            <p><i18n:text>xmlui.mirage2.static-pages.metadata.section.intro.para.2</i18n:text></p>
        </blockquote>
        <br/>
        <p><i18n:text>xmlui.mirage2.static-pages.metadata.section.intro.para.3</i18n:text></p>
        <br/>
        <div class=".table-responsive">
            <table class="table-bordered table-condensed">
                <caption class="sr-only">Rozdíly mezi povinnými a podmíněně povinnými popisnými údaji</caption>
                <thead>
                    <tr>
                        <th scope="col">typ údaje</th>
                        <th scope="col">popis</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            <b><i18n:text>xmlui.mirage2.static-pages.metadata.section.mandatory-metadata.table.mandatory-metadata.title</i18n:text></b>
                        </td>
                        <td>
                            <i18n:text>xmlui.mirage2.static-pages.metadata.section.mandatory-metadata.table.mandatory-metadata.description.2</i18n:text>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <b><i18n:text>xmlui.mirage2.static-pages.metadata.section.mandatory-metadata.table.mandatory-if-apliacable-metadata.title</i18n:text></b>
                        </td>
                        <td>
                            <i18n:text>xmlui.mirage2.static-pages.metadata.section.mandatory-metadata.table.mandatory-if-apliacable-metadata.description.1</i18n:text>
                        </td>
                    </tr>
                    <tr>
                        <td></td>
                        <td>
                            <i18n:text>xmlui.mirage2.static-pages.metadata.section.mandatory-metadata.table.mandatory-if-apliacable-metadata.description.2</i18n:text>
                        </td>
                    </tr>
                    <tr>
                        <td></td>
                        <td><i18n:text>xmlui.mirage2.static-pages.metadata.section.mandatory-metadata.table.mandatory-if-apliacable-metadata.description.3</i18n:text></td>
                    </tr>
                </tbody>
            </table>
        </div>
        <br/>
        <p><i18n:text>xmlui.mirage2.static-pages.metadata.section.mandatory-metadata.para.1</i18n:text></p>
        <br/>
        <!-- MANDATORY / MANDATORY IF APPLICABLE METADATA TABLES-->
        <div>

            <!-- Nav tabs -->
            <ul class="nav nav-tabs" role="tablist">
                <li role="presentation" class="dropdown">
                    <a href="#" id="mandatory-metadata-dropdown" class="dropdown-toggle" data-toggle="dropdown" aria-controls="mandatory-metadata-dropdown-contents" aria-haspopup="true" aria-expanded="false">
                        <i18n:text>xmlui.mirage2.static-pages.metadata.section.mandatory-metadata.table.mandatory-metadata.title</i18n:text> <span class="caret"></span>
                    </a>
                    <ul class="dropdown-menu" aria-labelledby="mandatory-metadata-dropdown" id="mandatory-metadata-dropdown-contents" aria-expanded="false">
                        <xsl:for-each select="$typologyFile//form">
                            <xsl:variable name="formValue" select="./@id"/>
                            <li role="presentation">
                                <a href="#mandatory-metadata-contents-{$formValue}" aria-expanded="false" aria-controls="mandatory-metadata-contents-{$formValue}" data-toggle="tab">
                                    <i18n:text><xsl:value-of select="concat('obd.typology.form.id.',./@id)"/></i18n:text>
                                </a>
                            </li>
                                
                            <!-- TODO: Implement anchor link fix from CU Digital Repository before linking to a specific anchor in panel -->
                            <!-- <a href="#collapse{$formValue}"><i18n:text><xsl:value-of select="concat('obd.typology.form.id.',./@id)"/></i18n:text></a> -->
                            <!--<a href="#"><i18n:text><xsl:value-of select="concat('obd.typology.form.id.',./@id)"/></i18n:text></a>-->
                        </xsl:for-each>
                    </ul>
                        <!-- <td><i18n:text><xsl:value-of select="concat('obd.typology.subform.id.',./subforms/subform/@id)"/></i18n:text></td> -->
                </li>
                <!-- <li role="presentation"><a href="#profile" aria-controls="profile" role="tab" data-toggle="tab">Profile</a></li>
                <li role="presentation"><a href="#messages" aria-controls="messages" role="tab" data-toggle="tab">Messages</a></li>
                <li role="presentation"><a href="#settings" aria-controls="settings" role="tab" data-toggle="tab">Settings</a></li> -->
            </ul>
          
            <!-- Tab panes -->
            <div class="tab-content">
                <xsl:for-each select="$typologyFile//form">
                    <xsl:variable name="formValueID" select="./@id"/>

                    <div role="tabpanel" class="tab-pane fade" id="mandatory-metadata-contents-{$formValueID}">
                        <xsl:call-template name="metadata-forms-generate-tables-for-tabpanel">
                            <xsl:with-param name="publicationFormID" select="$formValueID"/>
                        </xsl:call-template>
                    </div>
                </xsl:for-each>
            </div>
            <!-- <div class="tab-content">
              <div role="tabpanel" class="tab-pane active" id="home">...</div>
              <div role="tabpanel" class="tab-pane" id="profile">...</div>
              <div role="tabpanel" class="tab-pane" id="messages">...</div>
              <div role="tabpanel" class="tab-pane" id="settings">...</div>
            </div> -->
          
        </div>
        <br/>

        <h1><i18n:text>xmlui.mirage2.static-pages.metadata.section.optional-metadata.title</i18n:text></h1>
        <br/>
        <p><i18n:text>xmlui.mirage2.static-pages.metadata.section.optional-metadata.para.1</i18n:text></p>
        <ul>
            <li><i18n:text>xmlui.mirage2.static-pages.metadata.section.optional-metadata.list.item.1</i18n:text></li>
            <li><i18n:text>xmlui.mirage2.static-pages.metadata.section.optional-metadata.list.item.2</i18n:text></li>
            <li><i18n:text>xmlui.mirage2.static-pages.metadata.section.optional-metadata.list.item.3</i18n:text></li>
            <li><i18n:text>xmlui.mirage2.static-pages.metadata.section.optional-metadata.list.item.4</i18n:text></li>
        </ul>
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

    <xsl:template name="metadata-forms-generate-tables-for-tabpanel">
        <xsl:param name="publicationFormID"/>

        
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
                                <xsl:variable name="obdFieldID" select="./@obd_field_id"/>
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
                                                <xsl:value-of select="concat('obd.metadata.',$obdSectionTranslationKey)"/>
                                            </i18n:text>
                                        </td>
                                        <td>
                                            <xsl:choose>
                                                <xsl:when test="$obdFieldID != 'none'">
                                                    <i18n:text>
                                                        <xsl:value-of select="concat('obd.metadata.', $obdFieldTranslationKey)"/>
                                                    </i18n:text>
                                                </xsl:when>
                                                <xsl:otherwise></xsl:otherwise>
                                            </xsl:choose>
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
                                            <xsl:variable name="obdFieldID" select="./@obd_field_id"/>
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
                                                            <xsl:value-of select="concat('obd.metadata.',$obdSectionTranslationKey)"/>
                                                        </i18n:text>
                                                    </td>
                                                    <td>
                                                        <xsl:choose>
                                                            <xsl:when test="$obdFieldID != 'none'">
                                                                <i18n:text>
                                                                    <xsl:value-of select="concat('obd.metadata.', $obdFieldTranslationKey)"/>
                                                                </i18n:text>
                                                            </xsl:when>
                                                            <xsl:otherwise></xsl:otherwise>
                                                        </xsl:choose>
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