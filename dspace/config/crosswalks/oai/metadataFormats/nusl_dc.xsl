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
		<xsl:variable name="handle" select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='handle']/doc:element/doc:field[@name='value']"/>
		<xsl:variable name="uk-authors" select="document(concat('http://localhost:8080/solr/search/select?q=handle:',$handle,'&amp;rows=1&amp;fl=uk.author.identifier&amp;omitHeader=true'))"/>

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
			<!-- dc.creator -->
			<!-- <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='creator']/doc:element/doc:field[@name='value']">
				<dc:creator><xsl:value-of select="." /></dc:creator>
			</xsl:for-each> -->
			<!-- dc.contributor.author -->
			<!-- <xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name='author']/doc:element/doc:field[@name='value']">
				<dc:creator><xsl:value-of select="." /></dc:creator>
			</xsl:for-each> -->

			<!-- uk.author.identifier -> dc.creator WITH ORCID, RESEARCHERID and SCOPUS ID -->
			<xsl:for-each select="document($uk-authors,'.')/response/result/doc/arr/str">
				<dc:creator>
					<xsl:call-template name="process-author-with-identifiers">
						<xsl:with-param name="uk-author-identifier-value">
							<xsl:value-of select="text()"/>
						</xsl:with-param>
					</xsl:call-template>
				</dc:creator>
			</xsl:for-each>
			<!-- <xsl:apply-templates select="document(concat('http://localhost:8080/solr/search/select?q=handle:',$handle,'&amp;rows=1&amp;fl=uk.author.identifier&amp;omitHeader=true'))"
mode="solr-response"/> -->

			<!-- PROJECT IDENTIFIER -->
			<!-- dc.relation.fundingReference-->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='fundingReference']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="."/></dc:relation>
			</xsl:for-each>

			<!-- ACCESS LEVEL -->
			<!-- dcterms.accessRights -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='accessRights']/doc:element/doc:field[@name='value']">
				<dc:rights><xsl:value-of select="." /></dc:rights>
			</xsl:for-each>

			<!-- LICENSE CONDITION -->
			<!-- dc.rights -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:field[@name='value']">
				<dc:rights><xsl:value-of select="." /></dc:rights>
			</xsl:for-each>
			<!-- dc.rights.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='rights']/doc:element/doc:element/doc:field[@name='value']">
				<dc:rights><xsl:value-of select="." /></dc:rights>
			</xsl:for-each>
			<!-- LICENSE URL -->
			<!-- dcterms.license -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='license']/doc:element/doc:field[@name='value']">
				<dc:rights><xsl:value-of select="." /></dc:rights>
			</xsl:for-each>

			<!-- EMBARGO END DATE -->
			<!-- dc.date.embargoEndDate -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='embargoEndDate']/doc:element/doc:field[@name='value']">
				<dc:date><xsl:value-of select="." /></dc:date>
			</xsl:for-each>

			<!-- ALTERNATIVE IDENFIERS -->
			<!-- List alternative identifiers for this publication that are not the primary identifier (repository splash page), e.g., the DOI of publisher’s version, the PubMed/arXiv ID. -->
	
			<!-- dc.identifier.isbn - ISBN identifier of a resource -->
			<!-- Whole BOOKS -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='isbn']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="." /></dc:relation>
			</xsl:for-each>

			<!-- dc.identifier.issn - issn identifier of a resource -->
			<!-- WHOLE KONFERENCE PROCEEDINGS -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='issn']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="." /></dc:relation>
			</xsl:for-each>

			<!-- dc.identifier.eissn -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='eissn']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="." /></dc:relation>
			</xsl:for-each>

			<!-- dc.identifier.doi -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='doi']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="." /></dc:relation>
			</xsl:for-each>

			<!-- dc.identifier.handle -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='handle']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="." /></dc:relation>
			</xsl:for-each>

			<!-- dc.identifier.ark -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='ark']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="." /></dc:relation>
			</xsl:for-each>

			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='arxiv']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="." /></dc:relation>
			</xsl:for-each>

			<!-- dc.identifier.pubmed -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='pubmed']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="." /></dc:relation>
			</xsl:for-each>

			<!-- dc.identifier.purl -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='purl']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="." /></dc:relation>
			</xsl:for-each>

			<!-- dc.identifier.urn -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='urn']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="." /></dc:relation>
			</xsl:for-each>

			<!-- dc.identifier.utWos -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='utWos']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="." /></dc:relation>
			</xsl:for-each>
			
			<!-- dc.identifier.eidScopus -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='eidScopus']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="." /></dc:relation>
			</xsl:for-each>

			<!-- DATASET REFERENCE -->
			<!-- dc.relation.datasetUrl -->
			<!-- TODO: Check if this is already implemented in CUNI CRIS system -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name='datasetUrl']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="concat('info:eu-repo/semantics/dataset/url/',.)"/></dc:relation>
			</xsl:for-each>

			<!-- SUBJECT -->
			<!-- dc.subject.keyword -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='subject']/doc:element[@name='keyword']/doc:element/doc:field[@name='value']">
				<dc:subject><xsl:value-of select="." /></dc:subject>
			</xsl:for-each>

			<!-- DESCRIPTION -->
			<!-- dc.description -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element/doc:field[@name='value']">
				<dc:description><xsl:value-of select="." /></dc:description>
			</xsl:for-each>
			<!-- dc.description.* (not provenance, not startPage, not endPage, not pagination, not pageRange, not edition)-->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name!=('provenance' or 'startPage' or 'endPage' or 'pagination' or 'pageRange' or 'edition')]/doc:element/doc:field[@name='value']">
				<dc:description><xsl:value-of select="." /></dc:description>
			</xsl:for-each>

			<!-- PUBLISHER -->
			<!-- dc.publisher -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']">
				<dc:publisher><xsl:value-of select="." /></dc:publisher>
			</xsl:for-each>
			
			<!-- CONTRIBUTOR -->
			<!-- dc.contributor.* (not author) -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element[@name!='author']/doc:element/doc:field[@name='value']">
				<dc:contributor><xsl:value-of select="." /></dc:contributor>
			</xsl:for-each>
			<!-- dc.contributor -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='contributor']/doc:element/doc:field[@name='value']">
				<dc:contributor><xsl:value-of select="." /></dc:contributor>
			</xsl:for-each>

			<!-- PUBLICATION DATE -->
			<!-- dc.date.issued -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']">
				<dc:date><xsl:value-of select="." /></dc:date>
			</xsl:for-each>

			<!-- PUBLICATION TYPE -->
			<!-- dc.type.obdHierarchyCode -->
			<!-- This field contains a hierarchy of OBD types/subtypes, that are transformed in CUNIopenaire.xsl transformer stylesheet to openAIRE standards -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='obdHierarchyCode']/doc:element/doc:field[@name='value']">
				<dc:type><xsl:value-of select="." /></dc:type>
			</xsl:for-each>

			<!-- PUBLICATION VERSION -->
			<!-- dc.type.version-->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='type']/doc:element[@name='version']/doc:element/doc:field[@name='value']">
				<dc:type><xsl:value-of select="." /></dc:type>
			</xsl:for-each>

			<!-- FORMAT -->
			<!-- Gathered from ORIGINAL bundle information -->
			<!-- doc:metadata/doc:element[@name='bundles'/doc:element[@name='bundle']/doc:field[@name='name'][text()='ORIGINAL']/../doc:element[@name='bitstreams']/doc:element[@name='bitstream']/doc:field[@name='format'] -->
			<xsl:for-each select="doc:metadata/doc:element[@name='bundles']/doc:element[@name='bundle']/doc:field[@name='name'][text()='ORIGINAL']/../doc:element[@name='bitstreams']/doc:element[@name='bitstream']/doc:field[@name='format']">
				<dc:format><xsl:value-of select="." /></dc:format>
			</xsl:for-each>

			<!-- RESOURCE IDENTIFIER -->
			<!-- dc.identifier.uri  - persistent identifier of an object in repository -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='identifier']/doc:element[@name='uri']/doc:element/doc:field[@name='value']">
				<dc:identifier><xsl:value-of select="." /></dc:identifier>
			</xsl:for-each>

			<!-- SOURCE -->
			<!-- The present resource may be derived from the Source resource in whole or in part. Recommended best practice is to reference the resource by means of a string or number conforming to a formal identification system.
			Best practice: Use only when the described resource is the result of digitization of non-digital originals. 
			Otherwise, use Relation. Optionally metadata about the current location and call number of the digitized publication can be added. -->
			<!-- HOWEVER: we have a born-digital documents that are part of a broader BORN-DIGITAL resouce:
				 in this case we probably should:
				 1. include a ISBN, ISSN, eISSN or any other supported identifier of a related resource to dc:relation element (as suggested above, or so I think)
				 2. add dc:source element, in which the bibliographic catation of the source document / resource will be placed
				 In theory, there shouldn't be a case, when (for example) a resource in DSpace repository has by itself a ISBN identifier in dc.identifier.isbn element and is also a part of a resource identified by ISBN stored
				 in dcterms.isPartOf.isbn element. So no duplicate dc.relation values should be provided in OAI-PMH record...
			-->
			<xsl:variable name="sourceInfo">
				<xsl:call-template name="createSourceCitation"/>
			</xsl:variable>
			<dc:source><xsl:value-of select="$sourceInfo"/></dc:source>

			<!-- LANGUAGE (ISO) -->
			
			<!-- dc.language.iso -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='language']/doc:element[@name='iso']/doc:element/doc:field[@name='value']">
				<dc:language><xsl:value-of select="." /></dc:language>
			</xsl:for-each>
			
			<!-- dc.coverage -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='coverage']/doc:element/doc:field[@name='value']">
				<dc:coverage><xsl:value-of select="." /></dc:coverage>
			</xsl:for-each>
			<!-- dc.coverage.* -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dc']/doc:element[@name='coverage']/doc:element/doc:element/doc:field[@name='value']">
				<dc:coverage><xsl:value-of select="." /></dc:coverage>
			</xsl:for-each>
			
			<!-- RELATION -->
			<!-- dcterms.isPartOf.isbn -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='isPartOf']/doc:element[@name='isbn']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="concat('info:eu-repo/semantics/altIdentifier/isbn:', .)" /></dc:relation>
			</xsl:for-each>

			<!-- dcterms.isPartOf.issn -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='isPartOf']/doc:element[@name='issn']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="concat('info:eu-repo/semantics/altIdentifier/issn:', .)" /></dc:relation>
			</xsl:for-each>

			<!-- dcterms.isPartOf.eissn -->
			<xsl:for-each select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='isPartOf']/doc:element[@name='eissn']/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="concat('info:eu-repo/semantics/altIdentifier/eissn:', .)" /></dc:relation>
			</xsl:for-each>

			<!-- dc.relation.* (not datasetUrl, not fundingReference) -->
			<xsl:for-each select="dc:metadata/doc:element[@name='dc']/doc:element[@name='relation']/doc:element[@name!=('datasetUrl' or 'fundingReference')]/doc:element/doc:field[@name='value']">
				<dc:relation><xsl:value-of select="."/></dc:relation>
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

		<xsl:variable name="eventName">
			<xsl:if test="doc:metadata/doc:element[@name='uk']/doc:element[@name='event']/doc:element[@name='name']/doc:element/doc:field[@name='value']">
				<xsl:value-of select="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='isPartOf']/doc:element[@name='name']/doc:element/doc:field[@name='value']"/>
			</xsl:if>
		</xsl:variable>
			
		<xsl:variable name="sourcePublisher">
			<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']">
				<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='publisher']/doc:element/doc:field[@name='value']"/>
			</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="sourceJournalYear">	
			<xsl:if test="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='isPartOf']/doc:element[@name='journalYear']/doc:element/doc:field[@name='value']">
				<xsl:value-of select="concat('(', doc:metadata/doc:element[@name='dcterms']/doc:element[@name='isPartOf']/doc:element[@name='journalYear']/doc:element/doc:field[@name='value'], ')')"/>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="sourceJournalVolume">	
			<xsl:if test="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='isPartOf']/doc:element[@name='journalVolume']/doc:element/doc:field[@name='value']">
				<xsl:value-of select="concat(' ', doc:metadata/doc:element[@name='dcterms']/doc:element[@name='isPartOf']/doc:element[@name='journalVolume']/doc:element/doc:field[@name='value'])"/>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="sourceJournalIssue">		
			<xsl:if test="doc:metadata/doc:element[@name='dcterms']/doc:element[@name='isPartOf']/doc:element[@name='journalIssue']/doc:element/doc:field[@name='value']">
					<xsl:value-of select="concat('(', doc:metadata/doc:element[@name='dcterms']/doc:element[@name='isPartOf']/doc:element[@name='journalIssue']/doc:element/doc:field[@name='value'], ')')"/>
			</xsl:if>
		</xsl:variable>
			
		<xsl:variable name="sourceStartPage">
			<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='startPage']/doc:element/doc:field[@name='value']">
				<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='startPage']/doc:element/doc:field[@name='value']"/>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="sourceEndPage">
			<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='endPage']/doc:element/doc:field[@name='value']">
				<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='endPage']/doc:element/doc:field[@name='value']"/>		
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="sourcePageRange">
			<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='pageRange']/doc:element/doc:field[@name='value']">	
				<xsl:value-of select="concat(' ', doc:metadata/doc:element[@name='dc']/doc:element[@name='description']/doc:element[@name='pageRange']/doc:element/doc:field[@name='value'])"/>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="sourceDateIssued">
			<xsl:if test="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']">
				<xsl:value-of select="doc:metadata/doc:element[@name='dc']/doc:element[@name='date']/doc:element[@name='issued']/doc:element/doc:field[@name='value']"/>
			</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="sourceInformation">
			<!-- TODO: Different source information for different dc.type values - e.g. book part should have a different source citation, than a contribution to journal or conference object -->
			<xsl:value-of select="concat($sourceName, $sourceJournalVolume, $sourceJournalIssue, ',', $sourcePageRange,'. ', $sourceJournalYear)"/>	
		</xsl:variable>

		<xsl:value-of select="$sourceInformation"/>

	</xsl:template>

</xsl:stylesheet>