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
 * @author Christian Scheible christian.scheible@uni-konstanz.de
 * 
 */
public class SolrServicePublicationOriginFromSeparateMetaFieldsPlugin implements SolrServiceIndexPlugin
{

    @Override
    public void additionalIndex(Context context, DSpaceObject dso, SolrInputDocument document)
    {
        if (dso instanceof Item)
        {
            ItemService itemService = dso.getItemService();

            List<MetadataValue> primaryFacultyCs = itemService.getMetadata(dso, "uk", "faculty", "primaryName", "cs");
            List<MetadataValue> primaryDepartmentCs = itemService.getMetadata(dso, "uk", "department", "primaryName", "cs");
            List<MetadataValue> secondaryFacultyCs = itemService.getMetadata(dso, "uk", "faculty", "secondaryName", "cs");
            List<MetadataValue> secondaryDepartmentCs = itemService.getMetadata(dso, "uk", "department", "secondaryName", "cs");
            // List<MetadataValue> primaryFacultyEn = item.getMetadata(item, "uk", "faculty", "primaryName", "en");
            // List<MetadataValue> primaryDepartmentEn = item.getMetadata(item, "uk", "department", "primaryName", "en");
            // List<MetadataValue> secondaryFacultyEn = item.getMetadata(item, "uk", "faculty", "secondaryName", "en");
            // List<MetadataValue> secondaryDepartmentEn = item.getMetadata(item, "uk", "department", "secondaryName", "en");

            // _keyword and _filter because
            // they are needed in order to work as a facet and filter.
            
            if (primaryFacultyCs.isEmpty() || primaryDepartmentCs.isEmpty())
            {
                // do not create a new solr field with value
            }
            else 
            {
                for (MetadataValue faculty : primaryFacultyCs)
                {
                    String facultyValue = faculty.getValue();
                    for (MetadataValue department : primaryDepartmentCs)
                    {
                        String departmentValue = department.getValue();

                        document.addField("uk.publicationOrigin.cs", facultyValue.concat("::").concat(departmentValue));
                        document.addField("uk.publicationOrigin.cs_keyword", facultyValue.concat("::").concat(departmentValue));
                        document.addField("uk.publicationOrigin.cs_filter", facultyValue.concat("::").concat(departmentValue));
                    }
                }
            }

            if (secondaryFacultyCs.isEmpty() || secondaryDepartmentCs.isEmpty())
            {
                // do not create a new solr field with value
            }
            else
            {
                for (MetadataValue faculty : secondaryFacultyCs)
                {
                    String facultyValue = faculty.getValue();
                    for (MetadataValue department : secondaryDepartmentCs)
                    {
                        String departmentValue = department.getValue();
                        document.addField("uk.publicationOrigin.cs", facultyValue.concat("::").concat(departmentValue));
                        document.addField("uk.publicationOrigin.cs_keyword", facultyValue.concat("::").concat(departmentValue));
                        document.addField("uk.publicationOrigin.cs_filter", facultyValue.concat("::").concat(departmentValue));
                    }
                }
            }

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
