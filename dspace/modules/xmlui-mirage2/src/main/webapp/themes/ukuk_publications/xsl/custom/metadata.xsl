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

    <xsl:template name="metadata-create">
            <xsl:call-template name="metadata-general"/>
    </xsl:template>

    <xsl:template name="metadata-general">
        <ul class="nav nav-pills nav-justified">
            <li id="metadata-abstract" role="presentation" data-toggle="collapse" data-target="#collapseTableDiv"><a href="#">Abstrakt</a></li>
            <li id="metadata-article" role="presentation" data-toggle="collapse" data-target="#collapseTableDiv"><a href="#">Článek v časopisu</a></li>
        </ul>

        <xsl:if test="//div[@id='metadata']/ul/li[@aria-expanded='true']">
            <xsl:attribute name="class">active</xsl:attribute>
            <xsl:for-each select="following-sibling::li">
                <xsl:attribute name="class">disabled</xsl:attribute>
            </xsl:for-each>

            <xsl:for-each select="preceding-sibling::li">
                <xsl:attribute name="class">disabled</xsl:attribute>
            </xsl:for-each>
        </xsl:if>

        <div class="panel panel-default">
            <div class="panel-heading">
              <h3 class="panel-title">Tabulka povinných popisných údajů</h3>
            </div>
            <div id="collapseTableDiv" class="panel-collapse collapse">

                <div class="panel-body">
                    <table class="table">
                        <caption>Tabulka povinných údajů - forma výsledku: Abstrakt</caption>
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
            <div id="collapseTableDiv" class="panel-collapse collapse">
                <div class="panel-body">
                    <table class="table">
                        <caption>Tabulka povinných údajů - forma výsledku: Článek v časopisu</caption>
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
        </div>
    </xsl:template>

</xsl:stylesheet>