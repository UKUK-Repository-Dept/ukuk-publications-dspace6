/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.discovery;

import java.util.List;

import org.apache.solr.common.SolrInputDocument;
import org.dspace.content.Bitstream;
import org.dspace.content.Bundle;
import org.dspace.content.DSpaceObject;
import org.dspace.content.service.DSpaceObjectService;
import org.dspace.content.service.ItemService;
import org.dspace.content.Item;
import org.dspace.content.MetadataValue;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.core.Context;
import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.StringUtils;
import java.util.Arrays;
import org.apache.log4j.Logger;

/**
 * This plugin adds fields to the solr index to make facets from
 * metadata fields holding information about faculty / faculties
 * and department / departmets responsible for creation of the item.
 * 
 * These facets are used to limit the discovery results based on the faculty 
 * and / or department they were created on without any need to display
 * (rather deep) community & collection structure and depend on it for item 'discovery'.
 * 
 * The facet is added to Discovery in the usual way (create a searchFilter bean
 * and add it to the expected place) just with an empty list of used metadata
 * fields because there are none.
 * 
 * @author Jakub Řihák (jakub.rihak [at] ruk.cuni.cz)
 * 
 */
public class SolrServicePublicationResponsibilityFromSeparateMetaFieldsPlugin implements SolrServiceIndexPlugin
{
    
    private static final String SOLR_KEYWORD_FIELD_SUFFIX                       = "_keyword" ;
    private static final String SOLR_FILTER_FIELD_SUFFIX                        = "_filter" ;
    private static final String METADATA_SCHEMA                                 = "uk" ;
    private static final List<String> METADATA_RESPONSIBILITY_ELEMENTS          = Arrays.asList("faculty", "department") ;
    private static final List<String> METADATA_RESPONSIBILITY_QUALIFIERS        = Arrays.asList("primaryName", "secondaryName") ;
    private static final List<String> METADATA_LANGUAGES                        = Arrays.asList("cs", "en") ;
    

    private static final Logger log = Logger.getLogger(SolrServiceContentInOriginalBundleFilterPlugin.class);


    @Override
    public void additionalIndex(Context context, DSpaceObject dso, SolrInputDocument document)
    {
        if (dso instanceof Item)
        {
            Item item = (Item) dso;
            ItemService itemService = item.getItemService(); // We need this get metadat from the item DSO

            // for each language variant...
            for (String language : METADATA_LANGUAGES) 
            {
                // ...of each 'responsiblity' metadata element...
                for (String element : METADATA_RESPONSIBILITY_ELEMENTS)
                {
                    // ...with possible qualifiers...
                    for (String qualifier : METADATA_RESPONSIBILITY_QUALIFIERS)
                    {
                        // ... get matadata values stored in that metadata field...
                        log.debug("ITEM: [" + item.getHandle() + "/" + item.getName() + "]: " + "Trying to get metadata from field [" + METADATA_SCHEMA + "." + element + "." + qualifier + "[lang=" + language + "]") ;
                        List<MetadataValue> responsibilityMetadataValues = itemService.getMetadata(item, METADATA_SCHEMA, element, qualifier, language) ;

                        // .. if there are any... (list of metadata values is not empty)...
                        if (!responsibilityMetadataValues.isEmpty())
                        {
                            
                            // ... add each metadata value to appropriate SOLR fields
                            for (MetadataValue metadataValueObj : responsibilityMetadataValues)
                            {
                                String metadataValue = metadataValueObj.getValue() ;
                                log.debug("Found " + metadataValue + "in metadata field " + METADATA_SCHEMA + "." + element + "." + qualifier + "[lang=" + language + "]" ) ;

                                String solrFieldName = METADATA_SCHEMA.concat(".")
                                .concat("publication").concat(StringUtils.capitalize(element)).concat("Responsiblity").concat(".").concat(language) ;

                                log.debug("Adding metadata value [" + metadataValue + "] to SOLR field [" + solrFieldName + "]") ;
                                document.addField(solrFieldName, metadataValue) ;

                                log.debug("Adding metadata value [" + metadataValue + "] to SOLR field [" + solrFieldName.concat(SOLR_KEYWORD_FIELD_SUFFIX) + "]") ;
                                document.addField(solrFieldName.concat(SOLR_KEYWORD_FIELD_SUFFIX), metadataValue) ;
                                
                                log.debug("Adding metadata value [" + metadataValue + "] to SOLR field [" + solrFieldName.concat(SOLR_FILTER_FIELD_SUFFIX) + "]") ;
                                document.addField(solrFieldName.concat(SOLR_FILTER_FIELD_SUFFIX), metadataValue) ;
                                
                            }
                            
                        }
                        else
                        {
                            log.warn("ITEM: [" + item.getHandle() + "/" + item.getName() + "]: " + "Didn't find any values for metadata field " 
                            + METADATA_SCHEMA + "." + element + "." + qualifier + "[" + language + "]");
                        }
                    }
                }
                
            }
        }
    }
}
