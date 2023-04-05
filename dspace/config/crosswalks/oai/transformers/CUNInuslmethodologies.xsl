<?xml version="1.0" encoding="UTF-8"?>
<!-- 

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

	Developed by DSpace @ Lyncode <dspace@lyncode.com> 
	Following OpenAIRE Guidelines 1.1:
		- http://www.openaire.eu/component/content/article/207

 -->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:doc="http://www.lyncode.com/xoai">
	<xsl:output indent="yes" method="xml" omit-xml-declaration="yes" />

	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" />
		</xsl:copy>
	</xsl:template>
 
 	<!-- Formatting dc.date.issued -->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field/text()">
		<xsl:call-template name="formatdate">
			<xsl:with-param name="datestr" select="." />
		</xsl:call-template>
	</xsl:template>

	<!-- Formatting dc.date.embargoStartDate and dc.date.embargoEndDate -->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='embargoStartDate']/doc:element/doc:field/text()">
		<xsl:call-template name="formatEmbargoDate">
			<xsl:with-param name="datestr" select="." />
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='embargoEndDate']/doc:element/doc:field/text()">
		<xsl:call-template name="formatEmbargoDate">
			<xsl:with-param name="datestr" select="." />
		</xsl:call-template>
	</xsl:template>
	
	<!-- Removing other dc.date.*, except for dc.date.embargoStartDate and dc.date.embargoEndDate -->
	<!--<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name!='issued' or 'embargoEndDate' or 'embargoStartDate']" />-->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='updated']" />
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='available']" />
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='accessioned']" />

	<!-- Prefixing dc.type -->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='obdHierarchyCode']/doc:element/doc:field/text()">
		<xsl:call-template name="addPrefix">
			<xsl:with-param name="typeValue" select="." />
			<xsl:with-param name="prefix" select="'info:eu-repo/semantics/'"></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- Prefixing and Modifying dcterms.accessRights -->
	<!-- Removing unwanted -->
	<xsl:template match="/doc:metadata/doc:element[@name='dcterms']/doc:element[@name='accessRights']/doc:element/doc:element" />
	<!-- Replacing -->
	<xsl:template match="/doc:metadata/doc:element[@name='dcterms']/doc:element[@name='accessRights']/doc:element/doc:field/text()">
		<xsl:choose>
			<xsl:when test="contains(., 'open access')">
				<xsl:text>info:eu-repo/semantics/openAccess</xsl:text>
			</xsl:when>
			<xsl:when test="contains(., 'openAccess')">
				<xsl:text>info:eu-repo/semantics/openAccess</xsl:text>
			</xsl:when>
			<xsl:when test="contains(., 'restrictedAccess')">
				<xsl:text>info:eu-repo/semantics/restrictedAccess</xsl:text>
			</xsl:when>
			<xsl:when test="contains(., 'embargoedAccess')">
				<xsl:text>info:eu-repo/semantics/embargoedAccess</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>info:eu-repo/semantics/restrictedAccess</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Modifying dc.rights in cases when no license is set -->
	<!-- LICENSE CONDITION -->
	<!-- Removing unwanted -->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:element" />
	<!-- Replacing -->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:field/text()">
		<xsl:choose>
			<xsl:when test="contains(.,'bez licence')">
				<xsl:variable name="licenseConditionCs">
					<xsl:text>Plný text výsledku zpřístupněn v repozitáři v režimu gratis open access, tj. pouze pro čtení. Dále lze plné texty v režimu gratis open access z repozitáře stahovat, případně tisknout, ale pouze pro osobní potřebu (viz § 30 zákona č. 121/2000 Sb., autorského zákona).</xsl:text>
				</xsl:variable>
				<xsl:variable name="licenseConditionEn">
					<xsl:text>The fulltext is published in the repository as read-only, i.e. in gratis open access mode. Repository visitors are entitled to download and print the fulltext published without a licence for their personal use only (in accordance with § 30 of Act No. 121/2000 Coll., the Copyright Act).</xsl:text>
				</xsl:variable>
				<xsl:value-of select="concat($licenseConditionCs, ' / ', $licenseConditionEn)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="."/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Modifying dc.identifier.* -->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element/doc:element/doc:field/text()">
		<xsl:call-template name="prefixAltIdentifiers">
				<xsl:with-param name="identifier">
						<xsl:value-of select="."/>
				</xsl:with-param>
				<xsl:with-param name="scheme">
						<xsl:value-of select="../../../@name"/>
				</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<!-- AUXILIARY TEMPLATES -->
	
	<!-- dc.type prefixing -->
	<xsl:template name="addPrefix">
		<xsl:param name="typeValue" />
		<xsl:param name="prefix" />
		<xsl:choose>
			<xsl:when test="starts-with($typeValue, $prefix)">
				<xsl:value-of select="$typeValue" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="openaireTypeValue">
					<xsl:call-template name="substituteOBDType">
						<xsl:with-param name="obdTypeHierarchy" select="$typeValue" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="concat($prefix, $openaireTypeValue)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Substitute OBD Type -->
	<xsl:template name="substituteOBDType">
		<xsl:param name="obdTypeHierarchy"/>
		<xsl:variable name="hierarchyPartOne" select="substring-before($obdTypeHierarchy,'::')"/>
		<xsl:variable name="hierarchyPartTwoThree" select="substring-after($obdTypeHierarchy,'::')"/>
		<xsl:variable name="hierarchyPartThree" select="substring-after($hierarchyPartTwoThree,'::')"/>
		
		<xsl:choose>
			<xsl:when test="$hierarchyPartOne = '73'">
				<xsl:choose>
					<xsl:when test="$hierarchyPartThree = '203'">
						<xsl:text>review</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>article</xsl:text>		
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$hierarchyPartOne = '67'">
				<xsl:text>bookPart</xsl:text>
			</xsl:when>
			<xsl:when test="$hierarchyPartOne = '63'">
				<xsl:choose>
					<xsl:when test="$hierarchyPartThree = '248'">
						<xsl:text>report</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>book</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$hierarchyPartOne = '131'">
				<xsl:text>book</xsl:text>
			</xsl:when>
			<xsl:when test="$hierarchyPartOne = '129'">
				<xsl:text>workflow</xsl:text>
			</xsl:when>
			<xsl:when test="$hierarchyPartOne = '133'">
				<xsl:text>article</xsl:text>
			</xsl:when>
			<xsl:when test="$hierarchyPartOne = '106'">
				<xsl:text>bookPart</xsl:text>
			</xsl:when>
			<xsl:when test="$hierarchyPartOne = '117'">
				<xsl:text>workingPaper</xsl:text>
			</xsl:when>
			<xsl:when test="$hierarchyPartOne = '122'">
				<xsl:text>other</xsl:text>
			</xsl:when>
			<xsl:when test="$hierarchyPartOne = '81'">
				<xsl:choose>
					<xsl:when test="$hierarchyPartThree = '338'">
						<xsl:text>lecture</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>conferenceObject</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$hierarchyPartOne = '57'">
				<xsl:text>conferenceObject</xsl:text>
			</xsl:when>
			<xsl:when test="$hierarchyPartOne = '213'">
				<xsl:text>report</xsl:text>
			</xsl:when>
			<xsl:when test="$hierarchyPartOne = '121'">
				<xsl:choose>
					<xsl:when test="$hierarchyPartThree = '153'">
						<xsl:text>report</xsl:text>
					</xsl:when>
					<xsl:when test="$hierarchyPartThree = '154'">
						<xsl:text>bookPart</xsl:text>
					</xsl:when>
					<xsl:when test="$hierarchyPartThree = '500'">
						<xsl:text>workflow</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>other</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$hierarchyPartOne = '110'">
				<xsl:choose>
					<xsl:when test="$hierarchyPartThree = '462'">
						<xsl:text>conferenceObject</xsl:text>
					</xsl:when>
					<xsl:when test="$hierarchyPartThree = '135'">
						<xsl:text>article</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>other</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>other</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Date format -->
	<xsl:template name="formatdate">
		<xsl:param name="datestr" />
		<xsl:variable name="sub">
			<xsl:value-of select="substring($datestr,1,10)" />
		</xsl:variable>
		<xsl:value-of select="$sub" />
	</xsl:template>

	<!-- Embargo Date format -->
	<xsl:template name="formatEmbargoDate">
		<xsl:param name="datestr" />
		<xsl:variable name="sub">
			<xsl:value-of select="substring($datestr,1,10)" />
		</xsl:variable>
		<xsl:variable name="prefix">
			<xsl:text>info:eu-repo/date/embargoEnd/</xsl:text>
		</xsl:variable>
		<xsl:value-of select="concat($prefix,$sub)" />
	</xsl:template>

	<!-- alternate identifiers prefixing -->
	<xsl:template name="prefixAltIdentifiers">
		<xsl:param name="identifier"/>
		<xsl:param name="scheme"/>
		<xsl:choose>
			<xsl:when test="$scheme = 'none'">
				<xsl:value-of select="$identifier"/>
			</xsl:when>
			<xsl:when test="$scheme = 'uri'">
				<xsl:value-of select="$identifier"/>
			</xsl:when>
			<xsl:otherwise>
					<xsl:variable name="newSchemeName">
						<xsl:choose>
							<xsl:when test="$scheme = 'utWos'">
									<xsl:text>wos</xsl:text>
							</xsl:when>
							<xsl:when test="$scheme = 'eidScopus'">
									<xsl:text>purl</xsl:text>
							</xsl:when>
							<xsl:when test="$scheme = 'isbn'">
									<xsl:text>isbn</xsl:text>
							</xsl:when>
							<xsl:when test="$scheme = 'issn'">
									<xsl:text>issn</xsl:text>
							</xsl:when>
							<xsl:when test="$scheme = 'eissn'">
									<xsl:text>eissn</xsl:text>
							</xsl:when>
							<xsl:when test="$scheme = 'doi'">
									<xsl:text>doi</xsl:text>
							</xsl:when>
							<xsl:when test="$scheme = 'pubmed'">
									<xsl:text>pubmed</xsl:text>
							</xsl:when>
							<xsl:when test="$scheme = 'handle'">
									<xsl:text>hdl</xsl:text>
							</xsl:when>
							<!-- <JR> - 2023-04-05: we know, that in dc.identifier.uri is always a Handle identifier, so we can prefix it safely with 'hdl:' -->
							<xsl:when test="$scheme = 'uri'">
									<xsl:text>hdl</xsl:text>
							</xsl:when>
							<xsl:otherwise>
									<xsl:value-of select="$scheme"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:value-of select="concat($newSchemeName,':',$identifier)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
