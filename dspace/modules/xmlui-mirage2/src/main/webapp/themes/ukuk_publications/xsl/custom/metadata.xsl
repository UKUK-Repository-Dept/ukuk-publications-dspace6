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
    <xsl:param name="mandatoryMetadataFile" select="document('../../static/OBD_mandatory_metadata_by_form.xml')"/>
    <xsl:param name="mandatoryMetadataGeneralFile" select="document('../../static/OBD_mandatory_metadata_general.xml')"/>

    <xsl:template name="metadata-create">
            <xsl:call-template name="metadata-general"/>
            <!-- <xsl:call-template name="metadata-table-structure"/> -->
    </xsl:template>

    <xsl:template name="metadata-general">
        
        <xsl:call-template name="metadata-general-info"/>
        <!-- <xsl:call-template name="metadata-forms-process-xml-file-list"/> -->

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
        <div class="table-responsive">
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
                            <b><i18n:text>xmlui.mirage2.static-pages.metadata.section.mandatory-metadata.table.mandatory-if-aplicable-metadata.title</i18n:text></b>
                        </td>
                        <td>
                            <i18n:text>xmlui.mirage2.static-pages.metadata.section.mandatory-metadata.table.mandatory-if-aplicable-metadata.description.1</i18n:text>
                        </td>
                    </tr>
                    <tr>
                        <td></td>
                        <td>
                            <i18n:text>xmlui.mirage2.static-pages.metadata.section.mandatory-metadata.table.mandatory-if-aplicable-metadata.description.2</i18n:text>
                        </td>
                    </tr>
                    <tr>
                        <td></td>
                        <td><i18n:text>xmlui.mirage2.static-pages.metadata.section.mandatory-metadata.table.mandatory-if-aplicable-metadata.description.3</i18n:text></td>
                    </tr>
                </tbody>
            </table>
        </div>
        <br/>
        <p><i18n:text>xmlui.mirage2.static-pages.metadata.section.mandatory-metadata.para.1</i18n:text></p>
        
        <div>
            <xsl:call-template name="create_general_mandatory_metadata_tabs" />
        </div>

        <p><i18n:text>xmlui.mirage2.static-pages.metadata.section.mandatory-metadata.para.2</i18n:text></p>
        <ul>
            <li><i18n:text>xmlui.mirage2.static-pages.metadata.section.mandatory-metadata.para.2.list.item.1</i18n:text></li>
            <li><i18n:text>xmlui.mirage2.static-pages.metadata.section.mandatory-metadata.para.2.list.item.2</i18n:text></li>
        </ul>
        <p><i18n:text>xmlui.mirage2.static-pages.metadata.section.mandatory-metadata.para.3</i18n:text></p>
        <br/>
        
        <!-- MANDATORY / MANDATORY IF APPLICABLE METADATA TABLES-->
        <div>
            <xsl:call-template name="generate-metadata-tables-by-form"/>
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

    <xsl:template name="create_general_mandatory_metadata_tables">
        <xsl:param name="meta_type"/>
       
        <div class="table-responsive">
            <table class="table">
                <!--<caption class="sr-only">Seznam povinných údajů</caption>-->
                <thead>
                    <tr>
                        <th scope="col">údaj</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select=".//metadatum">
                        <!--<xsl:if test="$meta_type = 'mandatory'">-->
                            <tr>
                                <td><i18n:text>obd.metadata.metadatum.id.<xsl:value-of select="./@id"/></i18n:text></td>
                            </tr>
                        <!--</xsl:if>-->
                    </xsl:for-each>
                </tbody>
            </table>
        </div>
    </xsl:template>

    <xsl:template name="create_general_mandatory_metadata_tabs">
            <!-- Nav tabs -->
            <ul class="nav nav-tabs" role="tablist">
                <xsl:for-each select="$mandatoryMetadataGeneralFile//metadata">
                    <xsl:variable name="metadata_type" select="./@type"/>
                    
                    <xsl:choose>
                        <xsl:when test="$metadata_type = 'mandatory'">
                            <li role="presentation" class="active">
                                <a href="#{$metadata_type}-metadata-contents" id="{$metadata_type}-metadata-general" data-toggle="tab" aria-expanded="true">
                                    <i18n:text>xmlui.mirage2.static-pages.metadata.section.mandatory-metadata.table.<xsl:value-of select="$metadata_type"/>-metadata.title</i18n:text>
                                </a>
                            </li>
                        </xsl:when>
                        <xsl:otherwise>
                            <li role="presentation">
                                <a href="#{$metadata_type}-metadata-contents" id="{$metadata_type}-metadata-general" data-toggle="tab" aria-expanded="false">
                                    <i18n:text>xmlui.mirage2.static-pages.metadata.section.mandatory-metadata.table.<xsl:value-of select="$metadata_type"/>-metadata.title</i18n:text>
                                </a>
                            </li>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </ul>
          
             <!-- Tab panes -->
            <div class="tab-content">
                <xsl:for-each select="$mandatoryMetadataGeneralFile//metadata">
                    <xsl:variable name="metadata_type_name" select="./@type"/>
                    <xsl:choose>
                        <xsl:when test="$metadata_type_name = 'mandatory'">
                            <div role="tabpanel" class="tab-pane fade in active" id="{$metadata_type_name}-metadata-contents" aria-labelledby="${metadata_type_name}-metadata-general">
                                <xsl:call-template name="create_general_mandatory_metadata_tables">
                                    <xsl:with-param name="meta_type" select="$metadata_type_name"/>
                                </xsl:call-template>
                            </div>
                        </xsl:when>
                        <xsl:otherwise>
                            <div role="tabpanel" class="tab-pane fade" id="{$metadata_type_name}-metadata-contents" aria-labelledby="${metadata_type_name}-metadata-general">
                                <xsl:call-template name="create_general_mandatory_metadata_tables">
                                    <xsl:with-param name="meta_type" select="$metadata_type_name"/>
                                </xsl:call-template>
                            </div>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </div>
          
    </xsl:template>

    <xsl:template name="generate-metadata-tables-by-form">
        <!-- Nav tabs -->
        <ul class="nav nav-tabs" role="tablist">
            <!-- List of forms in dropdown for "mandatory metadata by form" dispaly  -->
            <li role="presentation" class="dropdown">
                <a href="#" id="mandatory-metadata-dropdown" class="dropdown-toggle" data-toggle="dropdown" aria-controls="mandatory-metadata-dropdown-contents" aria-expanded="true">
                    <i18n:text>xmlui.mirage2.static-pages.metadata.section.mandatory-metadata.table.mandatory-metadata.title</i18n:text> <span class="caret"></span>
                </a>
                <ul class="dropdown-menu" aria-labelledby="mandatory-metadata-dropdown" id="mandatory-metadata-dropdown-contents" aria-expanded="false">
                    <xsl:for-each select="$typologyFile//form">
                        <xsl:variable name="formValue" select="./@id"/>
                        <xsl:variable name="ariaExpanded"><xsl:text>false</xsl:text></xsl:variable>

                        <xsl:choose>
                            <xsl:when test="position() = 1">
                                <xsl:variable name="ariaExpanded"><xsl:text>true</xsl:text></xsl:variable>

                                <li role="presentation" class="active">
                                    <a href="#metadata-contents-{$formValue}" aria-expanded="{$ariaExpanded}" aria-controls="metadata-contents-{$formValue}" data-toggle="tab">
                                        <i18n:text><xsl:value-of select="concat('obd.typology.form.id.',./@id)"/></i18n:text>
                                    </a>
                                </li>
                                
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="ariaExpanded"><xsl:text>false</xsl:text></xsl:variable>

                                <li role="presentation">
                                    <a href="#metadata-contents-{$formValue}" aria-expanded="{$ariaExpanded}" aria-controls="metadata-contents-{$formValue}" data-toggle="tab">
                                        <i18n:text><xsl:value-of select="concat('obd.typology.form.id.',./@id)"/></i18n:text>
                                    </a>
                                </li>
                            </xsl:otherwise>
                        </xsl:choose>
                        <!-- <JR> - 2022-08-22 - předchozí funkční verze -->
                        <!-- 
                        <li role="presentation">
                            <a href="#mandatory-metadata-contents-{$formValue}" aria-expanded="false" aria-controls="mandatory-metadata-contents-{$formValue}" data-toggle="tab">
                                <i18n:text><xsl:value-of select="concat('obd.typology.form.id.',./@id)"/></i18n:text>
                            </a>
                        </li>
                         -->
                        <!-- END OF: <JR> - 2022-08-22 - předchozí funkční verze -->
                    </xsl:for-each>
                </ul>
            </li>
            
            <!-- <JR> - 2022-08-22 - předchozí funkční verze -->
            <!-- List of forms in dropdown for "mandatory-if-applicable metadata by form" display -->
            <!-- <li role="presentation" class="dropdown">
                <a href="#" id="mandatory-if-applicable-metadata-dropdown" class="dropdown-toggle" data-toggle="dropdown" aria-controls="mandatory-if-applicable-metadata-dropdown-contents" aria-expanded="false">
                    <i18n:text>xmlui.mirage2.static-pages.metadata.section.mandatory-metadata.table.mandatory-if-aplicable-metadata.title</i18n:text> <span class="caret"></span>
                </a>
                <ul class="dropdown-menu" aria-labelledby="mandatory-metadata-dropdown" id="mandatory-metadata-dropdown-contents" aria-expanded="false">
                    <xsl:for-each select="$typologyFile//form">
                        <xsl:variable name="formValue" select="./@id"/>
                        <li role="presentation">
                            <a href="#mandatory-if-applicable-metadata-contents-{$formValue}" aria-expanded="false" aria-controls="mandatory-if-applicable-metadata-contents-{$formValue}" data-toggle="tab">
                                <i18n:text><xsl:value-of select="concat('obd.typology.form.id.',./@id)"/></i18n:text>
                            </a>
                        </li>
                    </xsl:for-each>
                </ul>
            </li> -->
            <!-- END OF: <JR> - 2022-08-22 - předchozí funkční verze -->
            
        </ul>
      
        <!-- Tab panes -->
        <div class="tab-content">
            <xsl:for-each select="$mandatoryMetadataFile//form">
                <xsl:variable name="formValueID" select="./@id"/>
                

                <xsl:choose>
                    <xsl:when test="position() = 1">
                        <div role="tabpanel" class="tab-pane fade active in" id="metadata-contents-{$formValueID}">
                    </xsl:when>
                    <xsl:otherwise>
                        <div role="tabpanel" class="tab-pane fade" id="metadata-contents-{$formValueID}">
                    </xsl:othewise>
                </xsl:choose>

                

                <!-- <JR> - 2022-08-22 - předchozí funkční verze -->
                <!-- <xsl:for-each select=".//metadata">
                    <xsl:variable name="metadata-typeID" select="./@type"/>
                    <div role="tabpanel" class="tab-pane fade" id="{$metadata-typeID}-metadata-contents-{$formValueID}">
                        <xsl:call-template name="metadata-forms-generate-tables-for-tabpanel">
                            <xsl:with-param name="publicationFormID" select="$formValueID"/>
                            <xsl:with-param name="metadata-type" select="$metadata-typeID"/>
                        </xsl:call-template>
                    </div>
                </xsl:for-each>
                
                <div role="tabpanel" class="tab-pane fade" id="metadata-contents-{$formValueID}"> -->
                <!-- END OF: <JR> - 2022-08-22 - předchozí funkční verze -->
                    <xsl:for-each select=".//metadata">
                        <xsl:variable name="metadata-typeID" select="./@type"/>
                        <xsl:call-template name="metadata-forms-generate-tables-for-tabpanel">
                            <xsl:with-param name="publicationFormID" select="$formValueID"/>
                            <xsl:with-param name="metadata-type" select="$metadata-typeID"/>
                        </xsl:call-template>
                    </xsl:for-each>
                </div>
            </xsl:for-each>
        </div>
    </xsl:template>


    <xsl:template name="metadata-forms-generate-tables-for-tabpanel">
        <xsl:param name="publicationFormID"/>
        <xsl:param name="metadata-type"/>
        
        <table class="table">
            <xsl:choose>
                <xsl:when test="$metadata-type = 'mandatory'">
                    <caption>Tabulka povinných údajů - <i18n:text><xsl:value-of select="concat('obd.typology.form.id.', $publicationFormID)"/></i18n:text></caption>
                </xsl:when>
                <xsl:when test="$metadata-type = 'mandatory-if-applicable'">
                    <caption>Tabulka podmíněně povinných údajů - <i18n:text><xsl:value-of select="concat('obd.typology.form.id.', $publicationFormID)"/></i18n:text></caption>
                </xsl:when>
                <xsl:otherwise></xsl:otherwise>
            </xsl:choose>

            <thead>
                <tr>
                    <th scope="col">název údaje</th>
                    <th scope="col">OBD: sekce formuláře</th>
                    <th scope="col">OBD: pole formuláře</th>
                </tr>
            </thead>
            <tbody>
                <!-- TODO: Create table values based on a XML "configuration" file -->
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
                        </tr>
                    </xsl:if>
                </xsl:for-each>
            </tbody>
        </table>

    </xsl:template>

</xsl:stylesheet>