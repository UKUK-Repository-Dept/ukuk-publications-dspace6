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

    <xsl:template name="metadata-create">
            <xsl:call-template name="metadata-general"/>
            <!-- <xsl:call-template name="metadata-table-structure"/> -->
    </xsl:template>

    <xsl:template name="metadata-general">
        
        <xsl:call-template name="metadata-forms-process-xml-file-list"/>
<!--         
        <ul class="nav nav-pills nav-justified">
            <li id="metadata-abstract" role="presentation" data-toggle="collapse" data-target="#collapseAbstract"><a href="#">Abstrakt</a></li>
            <li id="metadata-article" role="presentation" data-toggle="collapse" data-target="#collapseArticle"><a href="#">Článek v časopisu</a></li>
            <li id="metadata-fsv-working-paper" role="presentation" data-toggle="collapse" data-target="#collapseFSVWorkingPaper"><a href="#">FSV: Working paper</a></li>
            <li id="metadata-book-chapter" role="presentation" data-toggle="collapse" data-target="#collapseBookChapter"><a href="#">Kapitola v knize</a></li>
            <li id="metadata-book" role="presentation" data-toggle="collapse" data-target="#collapseBook"><a href="#">Kniha</a></li>
            <li id="metadata-book-with-editors-only" role="presentation" data-toggle="collapse" data-target="#collapseBookWithEditorsOnly"><a href="#">Kniha pouze s editory</a></li>
            <li id="metadata-methodology" role="presentation" data-toggle="collapse" data-target="#collapseMethodology"><a href="#">Metodika, postup</a></li>
            <li id="metadata-lecture-poster" role="presentation" data-toggle="collapse" data-target="#collapseLecturePoster"><a href="#">Přednáška, poster</a></li>
            <li id="metadata-conference-proceedings" role="presentation" data-toggle="collapse" data-target="#collapseConferenceProceedings"><a href="#">Příspěvek v konferenčním sborníku</a></li>
            <li id="metadata-research-report" role="presentation" data-toggle="collapse" data-target="#collapseResearchReport"><a href="#">Souhrná výzkumná zpráva</a></li>
            <li id="metadata-article-in-collection-of-papers" role="presentation" data-toggle="collapse" data-target="#collapseArticleInCollectionOfPapers"><a href="#">Stať ve sborníku prací (nekonferenčním)</a></li>
            <li id="metadata-result-realised-by-the-funding-provider" role="presentation" data-toggle="collapse" data-target="#collapseResultRealisedByTheFundingProvider"><a href="#">Výsledek realizovaný poskytovatelem</a></li>
            <li id="metadata-other-result" role="presentation" data-toggle="collapse" data-target="#collapseArticle"><a href="#">Jiný výsledek</a></li>
        </ul> -->
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
                            <a href="#"><i18n:text><xsl:value-of select="concat('obd.typology.form.id.',./@id)"/></i18n:text></a>
                        </li>
                        <!-- <td><i18n:text><xsl:value-of select="concat('obd.typology.subform.id.',./subforms/subform/@id)"/></i18n:text></td> -->
                    </xsl:for-each>
                </ul>
            </li>
        </ul>
    </xsl:template>

    <!-- <xsl:template name="metadata-forms-process-xml-file">
        <xsl:for-each select="$typologyFile//form">
            <tr>
                <td><i18n:text><xsl:value-of select="concat('obd.typology.form.id.',./@id)"/></i18n:text></td>
                <td><i18n:text><xsl:value-of select="concat('obd.typology.subform.id.',./subforms/subform/@id)"/></i18n:text></td>
            
                <xsl:choose>
                    <xsl:when test="./subforms/subform/child_subforms/@all-supported = 'true'">
                        <td><i18n:text>obd.typology.subform.secondary.all</i18n:text></td>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="not(./subforms/subform/child_subforms/child_subform)">
                            <td></td>
                        </xsl:if>
                        <xsl:for-each select=".//child_subform">
                            <xsl:choose>
                                <xsl:when test="position() = 1">
                                    <td>
                                        <i18n:text><xsl:value-of select="concat('obd.typology.subform.secondary.id.',./@id)"/></i18n:text>
                                    </td>
                                </xsl:when>
                                <xsl:otherwise>
                                    <tr>
                                        <td></td>
                                        <td></td>
                                        <td>
                                            <i18n:text><xsl:value-of select="concat('obd.typology.subform.secondary.id.',./@id)"/></i18n:text>
                                        </td>
                                    </tr>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </tr>
        </xsl:for-each>
    </xsl:template> -->

    <xsl:template name="metadata-table-structure">
        <div class="panel panel-default">
            <xsl:for-each select="//li[@data-toggle='collapse']">
                <xsl:call-template name="metadata-table-content">
                    <xsl:with-param name="dataTarget" select="@data-target"/>
                </xsl:call-template>
            </xsl:for-each>
        </div>
    </xsl:template>
    
    <xsl:template name="metadata-table-content">
        <xsl:param name="dataTarget"/>

        <div id="$dataTarget" class="panel-collapse collapse">

                <div class="panel-body">
                    <table class="table">
                        <caption>Tabulka povinných údajů</caption>
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
                            <tr>
                              <th scope="row">Datum (rok) vydání dokumentu</th>
                              <td>Základní informace</td>
                              <td>Rok</td>
                              <td>X</td>
                              <td>X</td>
                            </tr>
                            <tr>
                              <th scope="row">Příjmení a jméno autora dokumentu</th>
                              <td>AUTOR</td>
                              <td></td>
                              <td>X</td>
                              <td>X</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
    </xsl:template>

</xsl:stylesheet>