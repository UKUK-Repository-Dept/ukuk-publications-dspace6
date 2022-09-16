<?xml version="1.0" encoding="UTF-8"?>
<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->

<!--
    Author: Jakub Řihák (jakub dot rihak at ruk dot cuni dot com)

    XSLT templates related to generation of HTML code for 'about'
    static page.

    On this page, users can find basic information about the repository and submission process.

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

    <!-- page/about constructor -->
    <xsl:template name="about-create">
        <xsl:call-template name="about-toc-help" />

        <xsl:call-template name="about-intro-text"/>

        <xsl:call-template name="about-typology-availability" />

        <xsl:call-template name="about-fulltext-versions" />

        <xsl:call-template name="about-licensing" />
        
        <xsl:call-template name="about-metadata" />
        
        <xsl:call-template name="about-confirmations" />
        
        <xsl:call-template name="about-workflow" />
    </xsl:template>

    <!-- GENERATE TOC and HELP -->
    <xsl:template name="about-toc-help">
        <div class="row">
            <div class="col-xs-12 col-sm-12 col-md-6" id="about-toc">
                <div class="media">
                    <div class="media-body">
                        <h2 class="media-heading">Obsah</h2>
                        <nav>
                            <ul class="list-unstyled">
                                <li role="presentation">
                                    <a href="#heading-about-intro-text"><i18n:text>obd.about-toc.heading-about-intro-text</i18n:text></a>
                                </li>
                                <li role="presentation">
                                    <a href="#heading-about-typology-availability"><i18n:text>obd.about-toc.heading-about-typology-availability</i18n:text></a>
                                </li>
                                <li role="presentation">
                                    <a href="#heading-about-fulltext-versions"><i18n:text>obd.about-toc.heading-about-fulltext-versions</i18n:text></a>
                                </li>
                                <li role="presentation">
                                    <a href="#heading-about-licensing"><i18n:text>obd.about-toc.heading-about-licensing</i18n:text></a>
                                </li>
                                <li role="presentation">
                                    <a href="#heading-about-metadata"><i18n:text>obd.about-toc.heading-about-metadata</i18n:text></a>
                                </li>
                                <li role="presentation">
                                    <a href="#heading-about-confirmations"><i18n:text>obd.about-toc.heading-about-confirmations</i18n:text></a>
                                </li>
                                <li role="presentation">
                                    <a href="#heading-about-workflow"><i18n:text>obd.about-toc.heading-about-workflow</i18n:text></a>
                                </li>
                            </ul>
                        </nav>
                    </div>
                </div>
            </div>
            <div class="col-xs-12 col-sm-12 col-md-6" id="about-help">
                <div class="media">
                    <!-- <div class="media-left"> -->
                    <!-- <a href="#"> -->
                        <!-- <span class="glyphicon glyphicon-info-sign" aria-hidden="true"></span> -->
                        <!-- <img class="media-object" src="..." alt="..."> -->
                    <!-- </a> -->
                    <!-- </div> -->
                    <div class="media-body">
                        <h2 class="media-heading"><i18n:text>obd.about-help.heading</i18n:text></h2>
                        <p>
                            <i18n:text>obd.about-help.text</i18n:text>
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>

    <!-- generate INTRO text -->
    <xsl:template name="about-intro-text">
        <h2 id="heading-about-intro-text">Obecné informace</h2>
        <p>
            <i18n:text>obd.about-intro-text.para.1</i18n:text>
        </p>
        <p>
            <i18n:text>obd.about-intro-text.para.2</i18n:text>
        </p>
        <p>
            <i18n:text>obd.about-intro-text.para.3</i18n:text>
        </p>
    </xsl:template>

    <!-- GENERATE INFO ON TYPOLOGY and fulltext AVAILABILITY -->
    <xsl:template name="about-typology-availability">
        <h2 id="heading-about-typology-availability"><i18n:text>obd.about-typology-availability.heading</i18n:text></h2>
        <p>
            <i18n:text>obd.about-typology-availability.para.1</i18n:text> 
        </p>
        <p>
            <i18n:text>obd.about-typology-availability.para.2</i18n:text> 
        </p>
        <div class="table-responsive">
            <table id="about-table-availability" class="table-bordered table-condensed">
                <caption class="sr-only"><i18n:text>obd.about-typology.table-availability.caption</i18n:text></caption>
                <thead>
                    <tr>
                        <th scope="col"><i18n:text>obd.about-typology.table-availability.header.1</i18n:text></th>
                        <th scope="col"><i18n:text>obd.about-typology.table-availability.header.2</i18n:text></th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            <i18n:text>obd.about-typology.table-availability.tr.1.td.1</i18n:text>
                        </td>
                        <td>
                            <i18n:text>obd.about-typology.table-availability.tr.1.td.2</i18n:text> 
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <i18n:text>obd.about-typology.table-availability.tr.2.td.1</i18n:text>
                        </td>
                        <td>
                            <i18n:text>obd.about-typology.table-availability.tr.2.td.2</i18n:text> 
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <i18n:text>obd.about-typology.table-availability.tr.3.td.1</i18n:text>
                        </td>
                        <td>
                            <i18n:text>obd.about-typology.table-availability.tr.3.td.2</i18n:text>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </xsl:template>

    <!-- GENERATE INFO ABOUT FULLTEXT VERSIONS ACCEPTED INTO THE REPOSITORY -->
    <xsl:template name="about-fulltext-versions">
        <h2 id="heading-about-fulltext-versions"><i18n:text>obd.about-fulltext-versions.heading</i18n:text></h2>
        <p>
            <i18n:text>obd.about-fulltext-versions.para.1</i18n:text>
        </p>
        <div class="table-responsive">
            <table id="about-table-fulltext-versions" class="table-bordered table-condensed">
                <caption class="sr-only"><i18n:text>obd.about-fulltext-versions.table-fulltext-versions.caption</i18n:text></caption>
                <thead>
                    <tr>
                        <th scope="col"><i18n:text>obd.about-fulltext-versions.table-fulltext-versions.header.1</i18n:text></th>
                        <th scope="col"><i18n:text>obd.about-fulltext-versions.table-fulltext-versions.header.2</i18n:text></th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            <i18n:text>obd.about-fulltext-versions.table-fulltext-versions.tr.1.td.1</i18n:text>
                        </td>
                        <td>
                            <i18n:text>obd.about-fulltext-versions.table-fulltext-versions.tr.1.td.2</i18n:text>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <i18n:text>obd.about-fulltext-versions.table-fulltext-versions.tr.2.td.1</i18n:text>
                        </td>
                        <td>
                            <i18n:text>obd.about-fulltext-versions.table-fulltext-versions.tr.2.td.2</i18n:text>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <i18n:text>obd.about-fulltext-versions.table-fulltext-versions.tr.3.td.1</i18n:text>
                        </td>
                        <td>
                            <i18n:text>obd.about-fulltext-versions.table-fulltext-versions.tr.3.td.2</i18n:text>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <i18n:text>obd.about-fulltext-versions.table-fulltext-versions.tr.4.td.1</i18n:text>
                        </td>
                        <td>
                            <i18n:text>obd.about-fulltext-versions.table-fulltext-versions.tr.4.td.2</i18n:text>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <i18n:text>obd.about-fulltext-versions.table-fulltext-versions.tr.5.td.1</i18n:text>
                        </td>
                        <td>
                            <i18n:text>obd.about-fulltext-versions.table-fulltext-versions.tr.5.td.2</i18n:text>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
        
    </xsl:template>

    <!-- GENERATE INFO ABOUT LICENSING -->
    <xsl:template name="about-licensing">
        <h2 id="heading-about-licensing"><i18n:text>obd.about-licensing.heading</i18n:text></h2>
        <p>
            <i18n:text>obd.about-licensing.para.1</i18n:text>
        </p>
        <p>
            <i18n:text>obd.about-licensing.para.2</i18n:text>
        </p>
        <div class="table-responsive">
            <table id="about-table-licensing" class="table-bordered table-condensed">
                <caption class="sr-only"><i18n:text>obd.about-licensing.table-licensing.caption</i18n:text></caption>
                <thead>
                    <tr>
                        <th scope="col"><i18n:text>obd.about-licensing.table-licensing.header.1</i18n:text></th>
                        <th scope="col"><i18n:text>obd.about-licensing.table-licensing.header.2</i18n:text></th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            <i18n:text>obd.about-licensing.table-licensing.tr.1.td.1</i18n:text>
                        </td>
                        <td>
                            <i18n:text>obd.about-licensing.table-licensing.tr.1.td.2</i18n:text>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <i18n:text>obd.about-licensing.table-licensing.tr.2.td.1</i18n:text>
                        </td>
                        <td>
                            <i18n:text>obd.about-licensing.table-licensing.tr.2.td.2</i18n:text>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <i18n:text>obd.about-licensing.table-licensing.tr.3.td.1</i18n:text>
                        </td>
                        <td>
                            <i18n:text>obd.about-licensing.table-licensing.tr.3.td.2</i18n:text> 
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
        <p>
            <i18n:text>obd.about-licensing.para.3</i18n:text>
        </p>
    </xsl:template>

    <!-- GENERATE INFO ABOUT MANDATORY MEDATADA -->
    <xsl:template name="about-metadata">
        <h2 id="heading-about-metadata"><i18n:text>obd.about-metadata.heading</i18n:text></h2>
        <p>
            <i18n:text>obd.about-metadata.para.1</i18n:text>
        </p>
        <p>
            <i18n:text>obd.about-metadata.para.2</i18n:text> 
        </p>
        <p>
            <i18n:text>obd.about-metadata.para.3</i18n:text>
        </p>
        <ul>
            <li><i18n:text>obd.about-metadata.ul.1.li.1</i18n:text></li>
            <li><i18n:text>obd.about-metadata.ul.1.li.2</i18n:text></li>
            <li><i18n:text>obd.about-metadata.ul.1.li.3</i18n:text></li>
            <li><i18n:text>obd.about-metadata.ul.1.li.4</i18n:text></li>
        </ul>
        <p>
            <i18n:text>obd.about-metadata.para.4</i18n:text>
        </p>
    </xsl:template>

    <!-- GENERATE INFO ABOUT ACKNOWLEDGEMENTS-->

    <xsl:template name="about-confirmations">
        <h2 id="heading-about-confirmations"><i18n:text>obd.about-confirmations.heading</i18n:text></h2>
        <p>
            <i18n:text>obd.about-confirmations.para.1</i18n:text>
        </p>
        <p>
            <i18n:text>obd.about-confirmations.para.2</i18n:text>
        </p>
        <p>
            <i18n:text>obd.about-confirmations.para.3</i18n:text>
        </p>
        <div class="table-responsive">
            <table id="about-table-confirmations" class="table-bordered table-condensed">
                <caption class="sr-only"><i18n:text>obd.about-confirmations.table-confirmations.caption</i18n:text></caption>
                <thead>
                    <tr>
                        <th scope="col"><i18n:text>obd.about-confirmations.table-confirmations.header.1</i18n:text></th>
                        <th scope="col"><i18n:text>obd.about-confirmations.table-confirmations.header.2</i18n:text></th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            <i18n:text>obd.about-confirmations.table-confirmations.tr.1.td.1</i18n:text>
                        </td>
                        <td>
                            <i>
                                <i18n:text>obd.about-confirmations.table-confirmations.tr.1.td.2</i18n:text>
                            </i>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <i18n:text>obd.about-confirmations.table-confirmations.tr.2.td.1</i18n:text>
                        </td>
                        <td>
                            <i>
                                <i18n:text>obd.about-confirmations.table-confirmations.tr.2.td.2</i18n:text>
                            </i> 
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
        <p>
            <i18n:text>obd.about-confirmations.para.4</i18n:text>
        </p>
    </xsl:template>

    <!-- GENERATE INFO ABOUT WORKFLOW -->
    <xsl:template name="about-workflow">
        <h2><i18n:text>obd.about-workflow.heading</i18n:text></h2>
        <p><i18n:text>obd.about-workflow.para.1</i18n:text></p>
        <div class="table-responsive">
            <table id="about-table-workflow" class="table-bordered table-condensed">
                <caption class="sr-only"><i18n:text>obd.about-workflow.table-workflow.caption</i18n:text></caption>
                <thead>
                    <tr>
                        <th><i18n:text>obd.about-workflow.table-workflow.header.1</i18n:text>pořadí</th>
                        <th><i18n:text>obd.about-workflow.table-workflow.header.2</i18n:text>popis kroku</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            <i18n:text>obd.about-workflow.table-workflow.tr.1.td.1</i18n:text>
                        </td>
                        <td>
                            <i18n:text>obd.about-workflow.table-workflow.tr.1.td.2</i18n:text>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <i18n:text>obd.about-workflow.table-workflow.tr.2.td.1</i18n:text>
                        </td>
                        <td>
                            <i18n:text>obd.about-workflow.table-workflow.tr.2.td.2</i18n:text>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <i18n:text>obd.about-workflow.table-workflow.tr.3.td.1</i18n:text>
                        </td>
                        <td>
                            <i18n:text>obd.about-workflow.table-workflow.tr.3.td.2</i18n:text>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <i18n:text>obd.about-workflow.table-workflow.tr.4.td.1</i18n:text>
                        </td>
                        <td>
                            <i18n:text>obd.about-workflow.table-workflow.tr.4.td.2</i18n:text>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <i18n:text>obd.about-workflow.table-workflow.tr.5.td.1</i18n:text>
                        </td>
                        <td>
                            <i18n:text>obd.about-workflow.table-workflow.tr.5.td.2</i18n:text>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <i18n:text>obd.about-workflow.table-workflow.tr.6.td.1</i18n:text>
                        </td>
                        <td>
                            <i18n:text>obd.about-workflow.table-workflow.tr.6.td.2</i18n:text>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <i18n:text>obd.about-workflow.table-workflow.tr.7.td.1</i18n:text>
                        </td>
                        <td>
                            <i18n:text>obd.about-workflow.table-workflow.tr.7.td.2</i18n:text>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <i18n:text>obd.about-workflow.table-workflow.tr.8.td.1</i18n:text>
                        </td>
                        <td>
                            <i18n:text>obd.about-workflow.table-workflow.tr.8.td.2</i18n:text>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <i18n:text>obd.about-workflow.table-workflow.tr.9.td.1</i18n:text>
                        </td>
                        <td>
                            <i18n:text>obd.about-workflow.table-workflow.tr.9.td.2</i18n:text>
                            <ul>
                                <li>
                                    <i18n:text>obd.about-workflow.table-workflow.tr.9.td.2.ul.1.li.1</i18n:text>
                                </li>
                                <li>
                                    <i18n:text>obd.about-workflow.table-workflow.tr.9.td.2.ul.1.li.2</i18n:text>
                                </li>
                            </ul>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <i18n:text>obd.about-workflow.table-workflow.tr.10.td.1</i18n:text>
                        </td>
                        <td>
                            <i18n:text>obd.about-workflow.table-workflow.tr.10.td.2</i18n:text>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
        <p>
            <i18n:text>obd.about-workflow.para.2</i18n:text> 
        </p>
        <p>
            <i18n:text>obd.about-workflow.para.3</i18n:text>
        </p>
        <p>
            <i18n:text>obd.about-workflow.para.4</i18n:text>
        </p>
    </xsl:template>

</xsl:stylesheet>