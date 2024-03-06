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

/**
 * This plugin adds three fields to the solr index to make a facet with/without
 * content in the ORIGINAL Bundle possible (like full text, images...). It is
 * activated simply by adding this class as a bean to discovery.xml.
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
    
    // private static final String SOLR_FACULTY_RESPONSIBILITY_FIELD               = "uk.publicationFacultyResponsibility" ;
    // private static final String SOLR_DEPT_RESPONSIBILITY_FIELD                  = "uk.publicationDepartmentResponsibility" ;
    private static final String SOLR_KEYWORD_FIELD_SUFFIX                       = "_keyword" ;
    private static final String SOLR_FILTER_FIELD_SUFFIX                        = "_filter" ;
    private static final String METADATA_SCHEMA                                 = "uk" ;
    private static final List<String> METADATA_RESPONSIBILITY_ELEMENTS          = Arrays.asList("faculty", "department") ;
    private static final List<String> METADATA_RESPONSIBILITY_QUALIFIERS        = Arrays.asList("primaryName", "secondaryName") ;
    private static final List<String> METADATA_LANGUAGES                        = Arrays.asList("cs", "en") ;
    // private static final List<String> METADATA_FACULTY_RESPONSIBILITY_FIELDS    = Arrays.asList("uk.faculty.primaryName", "uk.faculty.secondaryName") ;
    // private static final List<String> METADATA_DEPT_RESPONSIBILITY_FIELDS       = Arrays.asList("uk.department.primaryName", "uk.department.secondaryName") ;
    

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
                        List<MetadataValue> reponsibilityMetadataValues = itemService.getMetadata(item, METADATA_SCHEMA, element, qualifier, language) ;

                        // .. if there are any... (list of metadata values is not empty)...
                        if (!reponsibilityMetadataValues.isEmpty())
                        {
                            
                            // ... add each metadata value to appropriate SOLR fields
                            for (String metadataValue : responsibilityMetadataValues)
                            {
                                String solrFieldName = METADATA_SCHEMA.concat(".").concat("publication").concat(StringUtils.capitalize(element)).concat("Responsiblity").concat('.').concat(language) ;
                            
                                document.addField(solrFieldName, metadataValue) ;
                                document.addField(solrFieldName.concat(SOLR_KEYWORD_FIELD_SUFFIX), metadataValue) ;
                                document.addField(solrFieldName.concat(SOLR_FILTER_FIELD_SUFFIX), metadataValue) ;
                                    // document.addField(METADATA_SCHEMA.concat('.').concat(language), facultyMetadataValue) ;
                                    // document.addField(SOLR_FACULTY_RESPONSIBILITY_FIELD.concat('.').concat(language).concat(SOLR_KEYWORD_FIELD_SUFFIX), facultyMetadataValue) ;
                                    // document.addField(SOLR_FACULTY_RESPONSIBILITY_FIELD.concat('.').concat(language).concat(SOLR_FILTER_FIELD_SUFFIX), facultyMetadataValue) ;
                            }
                            
                        }
                        else
                        {
                            log.warn("Didn't find any values for metadata field " + facultyField);
                        }
                    }
                }
                
                // for (String facultyField : METADATA_FACULTY_RESPONSIBILITY_FIELDS)
                // {
                //     try 
                //     {
                //         schema, element, qualifier = facultyField.split(".") ;
                //     } catch (IllegalArgumentException e) {
                //         log.error("Metadata field doesn't contain 'splitter character' ('.')!\n" + e.getMessage());
                //     }

                //     List<MetadataValue> responsibilityMetadataValues = itemService.getMetadata(item, schema, element, qualifier, language) ;

                //     if (!responsibilityMetadataValues.isEmpty())
                //     {
                //         for (MetadataValue facultyMetadataValue : responsibilityMetadataValues)
                //         {
                //             document.addField(SOLR_FACULTY_RESPONSIBILITY_FIELD.concat('.').concat(language), facultyMetadataValue) ;
                //             document.addField(SOLR_FACULTY_RESPONSIBILITY_FIELD.concat('.').concat(language).concat(SOLR_KEYWORD_FIELD_SUFFIX), facultyMetadataValue) ;
                //             document.addField(SOLR_FACULTY_RESPONSIBILITY_FIELD.concat('.').concat(language).concat(SOLR_FILTER_FIELD_SUFFIX), facultyMetadataValue) ;
                //         }
                        
                //     } else {
                //         log.error("Didn't find any values for metadata field " + facultyField);
                //     }
                // }
            }

            // List<MetadataValue> primaryFacultyCs = itemService.getMetadata(item, "uk", "faculty", "primaryName", "cs");
            // List<MetadataValue> primaryDepartmentCs = itemService.getMetadata(item, "uk", "department", "primaryName", "cs");
            // List<MetadataValue> secondaryFacultyCs = itemService.getMetadata(item, "uk", "faculty", "secondaryName", "cs");
            // List<MetadataValue> secondaryDepartmentCs = itemService.getMetadata(item, "uk", "department", "secondaryName", "cs");
            // List<MetadataValue> primaryFacultyEn = item.getMetadata(item, "uk", "faculty", "primaryName", "en");
            // List<MetadataValue> primaryDepartmentEn = item.getMetadata(item, "uk", "department", "primaryName", "en");
            // List<MetadataValue> secondaryFacultyEn = item.getMetadata(item, "uk", "faculty", "secondaryName", "en");
            // List<MetadataValue> secondaryDepartmentEn = item.getMetadata(item, "uk", "department", "secondaryName", "en");

            // _keyword and _filter because
            // they are needed in order to work as a facet and filter.
            
            // if (primaryFacultyCs.isEmpty() || secondaryFacultyCs.isEmpty())
            // {
            //     // do not create a new solr field with value
            // }
            // else 
            // {
            //     for (MetadataValue primaryFaculty : primaryFacultyCs)
            //     {
            //         String primaryFacultyValueCs = primaryFaculty.getValue();
                    

            //         document.addField("uk.publicationFacultyResponsibility.cs", primaryFacultyValueCs);
            //         document.addField("uk.publicationFacultyResponsibility.cs_keyword", primaryFacultyValueCs);
            //         document.addField("uk.publicationFacultyResponsibility.cs_filter", primaryFacultyValueCs);
                    
            //     }

            //     for (MetadataValue secondaryFaculty : secondaryFacultyCs)
            //     {
            //         String secondaryFacultyValueCs = secondaryFaculty.getValue();

            //         document.addField("uk.publicationFacultyResponsibility.cs", secondaryFacultyValueCs);
            //         document.addField("uk.publicationFacultyResponsibility.cs_keyword", secondaryFacultyValueCs);
            //         document.addField("uk.publicationFacultyResponsibility.cs_filter", secondaryFacultyValueCs);
            //     }
            // }


            // if (primaryDepartmentCs.isEmpty() || secondaryDepartmentCs.isEmpty())
            // {
            //     // do not create a new solr field with value
            // }
            // else 
            // {
            //     for (MetadataValue primaryDepartment : primaryDepartmentCs)
            //     {
            //         String primaryDepartmentValueCs = primaryDepartment.getValue();
                    

            //         document.addField("uk.publicationDepartmentResponsibility.cs", primaryDepartmentValueCs);
            //         document.addField("uk.publicationDepartmentResponsibility.cs_keyword", primaryDepartmentValueCs);
            //         document.addField("uk.publicationDepartmentResponsibility.cs_filter", primaryDepartmentValueCs);
                    
            //     }

            //     for (MetadataValue secondaryDepartment : secondaryDepartmentCs)
            //     {
            //         String secondaryDepartmentValueCs = secondaryDepartment.getValue();

            //         document.addField("uk.publicationDepartmentResponsibility.cs", secondaryDepartmentValueCs);
            //         document.addField("uk.publicationDepartmentResponsibility.cs_keyword", secondaryDepartmentValueCs);
            //         document.addField("uk.publicationDepartmentResponsibility.cs_filter", secondaryDepartmentValueCs);
            //     }
            // }

            

            // if (primaryFacultyEn.isEmpty() || primaryDepartmentEn.isEmpty()) {
            //     // do not create a new solr field with value
            // }
            // else
            // {
            //     document.addField("uk.publicationOrigin.en", concat(primaryFacultyEn[0],"::",primaryDepartmentEn[0]));
            //     document.addField("uk.publicationOrigin.en_keyword", concat(primaryFacultyEn[0],"::",primaryDepartmentEn[0]));
            //     document.addField("uk.publicationOrigin.en_filter", concat(primaryFacultyEn[0],"::",primaryDepartmentEn[0]));
            // }

            

            // if (secondaryFacultyEn.isEmpty() || secondaryDepartmentEn.isEmpty())
            // {
            //     // do not create a new solr field with value
            // }
            // else 
            // {
            //     document.addField("uk.publicationOrigin.cs", concat(secondaryFacultyEn[0],"::",secondaryDepartmentEn[0]));
            //     document.addField("uk.publicationOrigin.cs_keyword", concat(secondaryFacultyEn[0],"::",secondaryDepartmentEn[0]));
            //     document.addField("uk.publicationOrigin.cs_filter", concat(secondaryFacultyEn[0],"::",secondaryDepartmentEn[0]));
            // }


            
            // if (!hasOriginalBundleWithContent)
            // {
            //     // no content in the original bundle
            //     document.addField("has_content_in_original_bundle", false);
            //     document.addField("has_content_in_original_bundle_keyword", false);
            //     document.addField("has_content_in_original_bundle_filter", false);
            // }
            // else
            // {
            //     document.addField("has_content_in_original_bundle", true);
            //     document.addField("has_content_in_original_bundle_keyword", true);
            //     document.addField("has_content_in_original_bundle_filter", true);
            // }
        }
    }

    // private List<MetadataValue> getMetadata(DspaceObject item, String schema, String element, String qualifier, String lang) {
        
    //     return item.getMetadata(item, schema, element, qualifier, lang);

    // }

    /**
     * Checks whether the given item has a bundle with the name ORIGINAL
     * containing at least one bitstream.
     * 
     * @param item
     *            to check
     * @return true if there is at least on bitstream in the bundle named
     *         ORIGINAL, otherwise false
     */
    // private boolean hasOriginalBundleWithContent(Item item)
    // {
    //     List<Bundle> bundles;
    //     bundles = item.getBundles();
    //     if (bundles != null)
    //     {
    //         for (Bundle curBundle : bundles)
    //         {
    //             String bName = curBundle.getName();
    //             if ((bName != null) && bName.equals("ORIGINAL"))
    //             {
    //                 List<Bitstream> bitstreams = curBundle.getBitstreams();
    //                 if (bitstreams != null && bitstreams.size() > 0)
    //                 {
    //                     return true;
    //                 }
    //             }
    //         }
    //     }
    //     return false;
    // }
}
