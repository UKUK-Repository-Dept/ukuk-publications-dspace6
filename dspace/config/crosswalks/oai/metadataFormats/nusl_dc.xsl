<?xml version="1.0" encoding="UTF-8" ?>
<!-- 
    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at
    http://www.dspace.org/license/
	Developed by DSpace @ Lyncode <dspace@lyncode.com>
	
	> http://www.openarchives.org/OAI/2.0/oai_dc.xsd
 -->
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:doc="http://www.lyncode.com/xoai"
	version="1.0">
	<xsl:output omit-xml-declaration="yes" method="xml" indent="yes" />
	
	<xsl:template match="/">
		<xsl:variable name="handle" select="substring-after(doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value'],':')"/>
		<xsl:variable name="uk-authors" select="document(concat('http://localhost:8080/solr/search/select?q=handle%3A%22',$handle,'%22&amp;rows=1&amp;fl=uk.author.identifier&amp;omitHeader=true'))"/>

		<oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" 
			xmlns:dc="http://purl.org/dc/elements/1.1/" 
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
			xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
			
			<!-- TITLE INFORMATION -->
			<!-- dc.title -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:field[@name='value']">
				<dc:title><xsl:value-of select="." /></dc:title>
			</xsl:for-each>
			<!-- dc.title.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='title']/doc:element/doc:element/doc:field[@name='value']">
				<dc:title><xsl:value-of select="." /></dc:title>
			</xsl:for-each>

			<!-- AUTHORS -->
			<!-- uk.author.identifier -> dc.creator WITH ORCID, RESEARCHERID and SCOPUS ID -->
			<xsl:for-each select="$uk-authors//str">
				<dc:creator>
					<xsl:call-template name="process-author-with-identifiers">
						<xsl:with-param name="uk-author-identifier-value">
							<xsl:value-of select="."/>
						</xsl:with-param>
					</xsl:call-template>
				</dc:creator>
			</xsl:for-each>

			<!-- CONTRIBUTORS -->
			<!-- dc.contributor.* (not author) -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name!='author']/doc:element/doc:field[@name='value']">
				<dc:contributor><xsl:value-of select="." /></dc:contributor>
			</xsl:for-each>
			<!-- dc.contributor -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element/doc:field[@name='value']">
				<dc:contributor><xsl:value-of select="." /></dc:contributor>
			</xsl:for-each>

			<!-- RESOURCE IDENTIFIER -->
			<!-- dc.identifier.uri  - persistent identifier of an object in repository -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value']">
				<dc:systemIdentifier><xsl:value-of select="." /></dc:systemIdentifier>
			</xsl:for-each>

			<!-- ALTERNATIVE IDENFIERS -->
			<!-- List alternative identifiers for this publication that are not the primary identifier (repository splash page), e.g., the DOI of publisher’s version, the PubMed/arXiv ID. -->
			<!-- dc.identifier.doi -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='doi']/doc:element/doc:field[@name='value']">
				<dc:identifier><xsl:value-of select="." /></dc:identifier>
			</xsl:for-each>
	
			<!-- dc.identifier.isbn - ISBN identifier of a resource -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='isbn']/doc:element/doc:field[@name='value']">
				<dc:identifier><xsl:value-of select="." /></dc:identifier>
			</xsl:for-each>

			<!-- dc.identifier.issn - issn identifier of a resource -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='issn']/doc:element/doc:field[@name='value']">
				<dc:identifier><xsl:value-of select="." /></dc:identifier>
			</xsl:for-each>

			<!-- dc.identifier.eissn -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='eissn']/doc:element/doc:field[@name='value']">
				<dc:identifier><xsl:value-of select="." /></dc:identifier>
			</xsl:for-each>

			<!-- dc.identifier.handle -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='handle']/doc:element/doc:field[@name='value']">
				<dc:identifier><xsl:value-of select="." /></dc:identifier>
			</xsl:for-each>

			<!-- dc.identifier.ark -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='ark']/doc:element/doc:field[@name='value']">
				<dc:identifier><xsl:value-of select="." /></dc:identifier>
			</xsl:for-each>

			<!-- dc.identifier.arxiv -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='arxiv']/doc:element/doc:field[@name='value']">
				<dc:identifier><xsl:value-of select="." /></dc:identifier>
			</xsl:for-each>

			<!-- dc.identifier.pubmed -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='pubmed']/doc:element/doc:field[@name='value']">
				<dc:identifier><xsl:value-of select="." /></dc:identifier>
			</xsl:for-each>

			<!-- dc.identifier.purl -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='purl']/doc:element/doc:field[@name='value']">
				<dc:identifier><xsl:value-of select="." /></dc:identifier>
			</xsl:for-each>

			<!-- dc.identifier.urn -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='urn']/doc:element/doc:field[@name='value']">
				<dc:identifier><xsl:value-of select="." /></dc:identifier>
			</xsl:for-each>

			<!-- dc.identifier.utWos -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='utWos']/doc:element/doc:field[@name='value']">
				<dc:identifier><xsl:value-of select="." /></dc:identifier>
			</xsl:for-each>
			
			<!-- dc.identifier.eidScopus -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='eidScopus']/doc:element/doc:field[@name='value']">
				<dc:identifier><xsl:value-of select="." /></dc:identifier>
			</xsl:for-each>

			<!-- FUNDING REFERENCE -->
			<!-- dc.relation.fundingReference-->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='fundingReference']/doc:element/doc:field[@name='value']">
				<dc:fundingReference><xsl:value-of select="."/></dc:fundingReference>
			</xsl:for-each>

			<!-- DOCUMENT TYPE -->
			<!-- dc.type.obdHierarchyCs -> dc.resourceType -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='obdHierarchyCs']/doc:element/doc:field[@name='value']">
				<dc:resourceType><xsl:value-of select="."/></dc:resourceType>
			</xsl:for-each>
			<!-- dc.type.obdHierarchyEn -> dc.resourceType -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='obdHierarchyEn']/doc:element/doc:field[@name='value']">
				<dc:resourceType><xsl:value-of select="."/></dc:resourceType>
			</xsl:for-each>

			<!-- LANGUAGE (ISO) -->
			<!-- dc.language.iso -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element[@name='iso']/doc:element/doc:field[@name='value']">
				<dc:language><xsl:value-of select="." /></dc:language>
			</xsl:for-each>

			<!-- PUBLICATION DATE -->
			<!-- dc.date.issued -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']">
				<dc:dateIssued><xsl:value-of select="." /></dc:dateIssued>
			</xsl:for-each>

			<!-- ACCESSION DATE -->
			<!-- dc.date.accessioned -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='accessioned']/doc:element/doc:field[@name='value']">
				<dc:dateCrated><xsl:value-of select="." /></dc:dateCrated>
			</xsl:for-each>

			<!-- ACCESS RIGHTS -->
			<!-- dcterms.accessRights -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='accessRights']/doc:element/doc:field[@name='value']">
				<dc:accessRights><xsl:value-of select="." /></dc:accessRights>
			</xsl:for-each>

			<!-- ABSTRACT -->
			<!-- dc.description.abstract-->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='abstract']/doc:element/doc:field[@name='value']">
				<dc:abstract><xsl:value-of select="." /></dc:abstract>
			</xsl:for-each>

			<!-- SUBJECT -->
			<!-- dc.subject.keyword, dc.subject.rivPrimary & dc.subject.rivSecondary -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element">
				<xsl:if test="@name='keyword'">
					<dc:subject><xsl:value-of select="./doc:element/doc:field[@name='value']" /></dc:subject>
				</xsl:if>

				<xsl:if test="@name='rivPrimary' or 'rivSecondary'">
					<dc:subjectCategories><xsl:value-of select="./doc:element//doc:field[@name='value']" /></dc:subjectCategories>
				</xsl:if>
			</xsl:for-each>

			<!-- SOURCE -->
			<!-- dcterms.isPartOf.name -> dc.relatedItem -->
			<!-- <JR> - 2023-04-05: Only the name of the related broader (source) item. This will most probably be subject of a change -->
			<xsl:variable name="sourceInfo">
				<xsl:call-template name="createSourceCitation"/>
			</xsl:variable>
			<dc:relatedItem><xsl:value-of select="$sourceInfo"/></dc:relatedItem>
			
			<!-- FILES -->
			<!-- bundles/bundle/[@name='ORIGINAL']/bitstreams/bitstream/field[@name='url']-->
			<xsl:for-each select="doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle']/doc:element[@name='bitstreams']/doc:element[@name='bitstream']/doc:field[@name='url']">
				<xsl:if test="../../../../doc:element[@name='bundle']/doc:field[@name='ORIGINAL']">
					<dc:fileUrl><xsl:value-of select="." /></dc:fileUrl>
				</xsl:if>
			</xsl:for-each>
		</oai_dc:dc>
	</xsl:template>

	<xsl:template name="process-author-with-identifiers">
		<xsl:param name="uk-author-identifier-value"/>
		<xsl:value-of select="concat(substring-before($uk-author-identifier-value,'|'),'|','orcid:',substring-before(substring-after($uk-author-identifier-value,'orcid_'),'|'),'|','researcherid:',substring-before(substring-after($uk-author-identifier-value,'researcherid_'),'|'),'|','scopus:',substring-after($uk-author-identifier-value,'scopus_'))"/>
	</xsl:template>

	<xsl:template name="createSourceCitation">
		
		<xsl:variable name="sourceName">
			<xsl:if test="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='isPartOf']/doc:element[@name='name']/doc:element/doc:field[@name='value']">
				<xsl:value-of select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='isPartOf']/doc:element[@name='name']/doc:element/doc:field[@name='value']"/>
			</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="sourceInformation">
			<xsl:value-of select="$sourceName"/>	
		</xsl:variable>

		<xsl:value-of select="$sourceInformation"/>

	</xsl:template>

</xsl:stylesheet>