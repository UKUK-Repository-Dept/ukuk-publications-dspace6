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

<xsl:stylesheet
                xmlns="http://di.tamu.edu/DRI/1.0/"
                xmlns:dri="http://di.tamu.edu/DRI/1.0/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
                exclude-result-prefixes="xsl dri i18n">

    <xsl:output indent="yes"/>

    <xsl:template name="typology-forms-create">
        <xsl:call-template name="typology-forms-table"/>
    </xsl:template>

    <xsl:template name="typology-forms-table">
        <div class="table-responsive">
            <table class="table table-condensed table-hover">
                <caption class="sr-only"><i18n:text>xmlui.mirage2.static-pages.heading.typology</i18n:text></caption>
                <thead>
                    <tr>
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
        <xsl:variable name="typologyFileLocation">
            <xsl:text>OBD_publication_types_accepted.xml</xsl:text>
        </xsl:variable>
        <xsl:apply-templates select="document($typologyFileLocation)"/>
        <!-- TODO: read XML map file containing:
            * FORM ID
            * FORM NAME (CS)
            * FORM NAME (EN)
                * SUBFORMS:
                    * SUBFORM ID
                    * SUBFORM NAME (CS)
                    * SUBFORM NAME (EN)
                        * CHILD SUBFORMS:
                            * CHILD SUBFORM ID
                            * CHILD SUBFORM NAME (CS)
                            * CHILD SUBFORM NAME (EN)
            
            To indicate, that all child subforms of a given subform are accepted into DSpace,
            <child_subforms> element has an atribute 'all-supported' = "true" - this way we don't list
            individual supported child subforms, we only display information "všechny podřazené poddruhy" / "all child subforms".
            
            We might decide to USE IDs instead of NAME strings to ensure translation (using <i18n:text>)
        -->
        <!-- <tr>
            <td>ČLÁNEK V ČASOPISU</td>
            <td>článek v časopisu</td>
            <td>všechny podřazené poddruhy</td>
        </tr>
        <tr>
            <td>KAPITOLA V KNIZE</td>
            <td>kapitola v knize</td>
            <td>všechny podřazené poddruhy</td>
        </tr>
        <tr>
            <td>KNIHA</td>
            <td>kniha</td>
            <td>všechny podřazené poddruhy</td>
        </tr>
        <tr>
            <td>KNIHA POUZE S EDITORY (EDITOR = AUTOR)</td>
            <td>kniha pouze s editory</td>
            <td>všechny podřazené poddruhy</td>
        </tr>
        <tr>
            <td>METODIKA, POSTUP</td>
            <td>certifikované postupy</td>
            <td>všechny podřazené poddruhy</td>
        </tr>
        <tr>
            <td>[FSV] Pražské sociálně vědní studie</td>
            <td>Pražské sociálně vědní studie</td>
            <td>všechny podřazené poddruhy</td>
        </tr>
        <tr>
            <td>VÝSLEDEK REALIZOVANÝ POSKYTOVATELEM</td>
            <td>poskytovatelem realizovaný výsledek</td>
            <td>všechny podřazené poddruhy</td>
        </tr>
        <tr>
            <td>PŘEDNÁŠKA, POSTER</td>
            <td>přednáška nebo poster</td>
            <td>všechny podřazené poddruhy</td>
        </tr>
        <tr>
            <td>SOFTWARE</td>
            <td>software</td>
            <td></td>
        </tr>
        <tr>
            <td>PŘÍSPĚVEK V KONFERENČNÍM SBORNÍKU</td>
            <td>příspěvek v konferenčním sborníku</td>
            <td>všechny podřazené poddruhy</td>
        </tr>
        <tr>
            <td>SOUHRNNÁ VÝZKUMNÁ ZPRÁVA</td>
            <td>souhrnná výzkumná zpráva</td>
            <td></td>
        </tr>
        <tr>
            <td>JINÝ VÝSLEDEK</td>
            <td>jiné výsledky</td>
            <td>výzkumná zpráva</td>
        </tr>
        <tr>
            <td></td>
            <td></td>
            <td>jiný příspěvek ve sborníku</td>
        </tr>
        <tr>
            <td></td>
            <td></td>
            <td>internetový zdroj</td>
        </tr>
        <tr>
            <td></td>
            <td></td>
            <td>necertifikovaná metodika</td>
        </tr>
        <tr>
            <td></td>
            <td></td>
            <td>popularizující internetová prezentace</td>
        </tr>
        <tr>
            <td>ABSTRAKT</td>
            <td>abstrakt</td>
            <td>všechny podřazené poddruhy</td>
        </tr> -->
    </xsl:template>

    <xsl:template match="/supported_forms">
        <xsl:value-of select="." />
    </xsl:template>

</xsl:stylesheet>