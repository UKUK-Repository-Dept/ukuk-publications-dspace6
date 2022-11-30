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
	
	<!-- Removing other dc.date.* -->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name!='issued']" />

	<!-- Prefixing dc.type -->
	<xsl:template match="/doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='obdHierarchyCode']/doc:element/doc:field/text()">
		<xsl:call-template name="addPrefix">
			<xsl:with-param name="typeValue" select="." />
			<xsl:with-param name="prefix" select="'info:eu-repo/semantics/'"></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- Prefixing and Modifying dc.rights -->
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
						<xsl:text>conferencePoster</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$hierarchyPartOne = '57'">
				<xsl:text>conferencePaper</xsl:text>
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
						<xsl:text>conferencePaper</xsl:text>
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
</xsl:stylesheet>
