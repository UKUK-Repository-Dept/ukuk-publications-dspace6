<xsl:stylesheet
    xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:ore="http://www.openarchives.org/ore/terms/"
    xmlns:oreatom="http://www.openarchives.org/ore/atom/"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:encoder="xalan://java.net.URLEncoder"
    xmlns:util="org.dspace.app.xmlui.utils.XSLUtils"
    xmlns:jstring="java.lang.String"
    xmlns:rights="http://cosimo.stanford.edu/sdr/metsrights/"
    xmlns:confman="org.dspace.core.ConfigurationManager"
    exclude-result-prefixes="xalan encoder i18n dri mets dim xlink xsl util jstring rights confman">
    <xsl:import href="../../custom/utility.xsl"/>
    
    
    <xsl:template name="itemSummaryView-DIM-citations-by-doc-type">
        <xsl:param name="documentType"/>
        
        <p class="citation">
            <xsl:if test="$documentType = 73">
                <xsl:call-template name="itemSummaryView-DIM-citations-contributors"/>
                <xsl:call-template name="itemSummaryView-DIM-citations-title"/>
                <xsl:call-template name="itemSummaryView-DIM-citations-source-title" />
                <xsl:call-template name="itemSummaryView-DIM-citations-publication-year" />
            </xsl:if>
        </p>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-citations-contributors">
        
            <xsl:if test="count(dim:field[@element='contributor' and @qualifier='author']) >= 1">
                <xsl:call-template name="itemSummaryView-DIM-citations-add-contributors-authors">
                    <xsl:with-param name="translatorsPresent">
                        <xsl:choose>
                            <xsl:when test="count(dim:field[@element='contributor' and @qualifier='translator']) >= 1">
                                <xsl:text>true</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>false</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="illustratorsPresent">
                        <xsl:choose>
                            <xsl:when test="count(dim:field[@element='contributor' and @qualifier='illustrator']) >= 1">
                                <xsl:text>true</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>false</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="editorsPresent">
                        <xsl:choose>
                            <xsl:when test="count(dim:field[@element='contributor' and @qualifier='editor']) >= 1">
                                <xsl:text>true</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>false</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            
            <xsl:if test="count(dim:field[@element='contributor' and @qualifier='translator']) >= 1">
                <xsl:call-template name="itemSummaryView-DIM-citations-add-contributors-translators">
                    <xsl:with-param name="illustratorsPresent">
                        <xsl:choose>
                            <xsl:when test="count(dim:field[@element='contributor' and @qualifier='illustrator']) >= 1">
                                <xsl:text>true</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>false</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="editorsPresent">
                        <xsl:choose>
                            <xsl:when test="count(dim:field[@element='contributor' and @qualifier='editor']) >= 1">
                                <xsl:text>true</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>false</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="count(dim:field[@element='contributor' and @qualifier='illustrator']) >= 1">
                <xsl:call-template name="itemSummaryView-DIM-citations-add-contributors-illustrators">
                    <xsl:with-param name="editorsPresent">
                        <xsl:choose>
                            <xsl:when test="count(dim:field[@element='contributor' and @qualifier='editor']) >= 1">
                                <xsl:text>true</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>false</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="count(dim:field[@element='contributor' and @qualifier='editor']) >= 1">
                <xsl:call-template name="itemSummaryView-DIM-citations-add-contributors-editors"/>
            </xsl:if>

    </xsl:template>


    <xsl:template name="itemSummaryView-DIM-citations-title">
        <xsl:choose>
            <xsl:when test="dim:field[@element='displayTitle'][not(@qualifier)]">
                <xsl:for-each select="dim:field[@element='displayTitle'][not(@qualifier)]">
                    <span class="citation-title">
                        <xsl:text> </xsl:text>
                        <xsl:call-template name="utility-parse-display-title">
                            <xsl:with-param name="title-string" select="./node()"/>
                        </xsl:call-template>
                        <xsl:text>. </xsl:text>
                    </span>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="dim:field[@element='title'][not(@qualifier)]">
                    <span class="citation-title"><xsl:text> </xsl:text><xsl:value-of select="."/><xsl:text>. </xsl:text></span>
                </xsl:for-each>        
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-citations-source-title">
        <xsl:for-each select="dim:field[@element='isPartOf' and @qualifier = 'name']">
            <span class="citation-source-title"><xsl:value-of select="."/></span><xsl:text>. </xsl:text>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-citations-publication-year">
        <xsl:for-each select="dim:field[@element='date' and @qualifier = 'issued']">
            <span class="citation-publication-year"><xsl:value-of select="."/></span><xsl:text>, </xsl:text>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-citations-add-contributors-authors">
        <xsl:param name="translatorsPresent" />
        <xsl:param name="illustratorsPresent" />
        <xsl:param name="editorsPresent" />
        <xsl:for-each select="dim:field[@element='contributor' and @qualifier='author']">
            
            <xsl:call-template name="handle-contributors" />
            
            <xsl:if test="position() = 1 and position() = last()">
                <xsl:choose>
                    <xsl:when test="$translatorsPresent = 'true' or $illustratorsPresent = 'true' or $editorsPresent = 'true'">
                        <xsl:text>, </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>.</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:if test="position() = 1 and not(position() = last())">
                <xsl:choose>
                    <xsl:when test="count(following-sibling::dim:field[@element='contributor' and @qualifier='author']) = 1">
                    </xsl:when>
                    <xsl:otherwise><xsl:text>, </xsl:text></xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:if test="position() != 1 and not(position() = last())">
                <xsl:choose>
                    <xsl:when test="count(following-sibling::dim:field[@element='contributor' and @qualifier='author']) = 1">
                    </xsl:when>
                    <xsl:otherwise><xsl:text>, </xsl:text></xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:if test="position() != 1 and position() = last()">
                <xsl:choose>
                    <xsl:when test="$translatorsPresent = 'true' or $illustratorsPresent = 'true' or $editorsPresent = 'true'">
                        <xsl:text>, </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>.</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-citations-add-contributors-translators">
        <xsl:param name="illustratorsPresent" />
        <xsl:param name="editorsPresent" />
        <xsl:for-each select="dim:field[@element='contributor' and @qualifier='translator']">
            <xsl:call-template name="handle-contributors" />
            
            <xsl:if test="position() = 1 and position() = last()">
                <xsl:choose>
                    <xsl:when test="$illustratorsPresent = 'true' or $editorsPresent = 'true'">
                        <xsl:text>, </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>.</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:if test="position() = 1 and not(position() = last())">
                <xsl:choose>
                    <xsl:when test="count(following-sibling::dim:field[@element='contributor' and @qualifier='translator']) = 1">
                    </xsl:when>
                    <xsl:otherwise><xsl:text>, </xsl:text></xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:if test="position() != 1 and not(position() = last())">
                <xsl:choose>
                    <xsl:when test="count(following-sibling::dim:field[@element='contributor' and @qualifier='translator']) = 1">
                    </xsl:when>
                    <xsl:otherwise><xsl:text>, </xsl:text></xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:if test="position() != 1 and position() = last()">
                <xsl:choose>
                    <xsl:when test="$illustratorsPresent = 'true' or $editorsPresent = 'true'">
                        <xsl:text>, </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>.</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-citations-add-contributors-illustrators">
        <xsl:param name="editorsPresent" />
        <xsl:for-each select="dim:field[@element='contributor' and @qualifier='illustrator']">
            <xsl:call-template name="handle-contributors" />
            
            <xsl:if test="position() = 1 and position() = last()">
                <xsl:choose>
                    <xsl:when test="$editorsPresent = 'true'">
                        <xsl:text>, </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>.</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:if test="position() = 1 and not(position() = last())">
                <xsl:choose>
                    <xsl:when test="count(following-sibling::dim:field[@element='contributor' and @qualifier='illustrator']) = 1">
                    </xsl:when>
                    <xsl:otherwise><xsl:text>, </xsl:text></xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:if test="position() != 1 and not(position() = last())">
                    <xsl:choose>
                        <xsl:when test="count(following-sibling::dim:field[@element='contributor' and @qualifier='illustrator']) = 1">
                        </xsl:when>
                        <xsl:otherwise><xsl:text>, </xsl:text></xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:if test="position() != 1 and position() = last()">
                <xsl:choose>
                    <xsl:when test="$editorsPresent = 'true'">
                        <xsl:text>, </xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>.</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="itemSummaryView-DIM-citations-add-contributors-editors">
        
        <xsl:for-each select="dim:field[@element='contributor' and @qualifier='editor']">
            <xsl:call-template name="handle-contributors" />
            
            <xsl:if test="position() = 1 and position() = last()">
                <xsl:text>, ed.</xsl:text>
            </xsl:if>
            <xsl:if test="position() = 1 and not(position() = last())">
                <xsl:choose>
                    <xsl:when test="count(following-sibling::dim:field[@element='contributor' and @qualifier='editor']) = 1">
                    </xsl:when>
                    <xsl:otherwise><xsl:text>, </xsl:text></xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:if test="position() != 1 and not(position() = last())">
                    <xsl:choose>
                        <xsl:when test="count(following-sibling::dim:field[@element='contributor' and @qualifier='editor']) = 1">
                        </xsl:when>
                        <xsl:otherwise><xsl:text>, </xsl:text></xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:if test="position() != 1 and position() = last()">
                <xsl:text>, ed.</xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>


    <xsl:template name="handle-contributors">
        <xsl:if test="position() = 1 and position() = last()">
                <span class="citation-contributor-surname"><xsl:value-of select="substring-before(.,',')"/></span><xsl:text>, </xsl:text><xsl:value-of select="substring-after(.,',')"/>
            </xsl:if>
            
            <xsl:if test="position() = 1 and not(position() = last())">
                <span class="citation-contributor-surname"><xsl:value-of select="substring-before(.,',')"/></span><xsl:text>, </xsl:text><xsl:value-of select="substring-after(.,',')"/>
            </xsl:if>

            <xsl:if test="position() != 1 and not(position() = last())">
                <xsl:value-of select="substring-after(.,',')"/><xsl:text> </xsl:text><span class="citation-contributor-surname"><xsl:value-of select="substring-before(.,',')"/></span>
            </xsl:if>

            <xsl:if test="position() != 1 and position() = last()">
                <xsl:text> a </xsl:text><xsl:value-of select="substring-after(.,',')"/><xsl:text> </xsl:text><span class="citation-contributor-surname"><xsl:value-of select="substring-before(.,',')"/></span>
            </xsl:if>
    </xsl:template>
</xsl:stylesheet>