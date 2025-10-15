package cz.cuni.metadataconsumers;
// import org.dspace.authorize.AuthorizeException;
import org.dspace.content.*;
import org.dspace.core.Context;
import org.dspace.core.factory.CoreServiceFactory;
import org.dspace.core.Constants;
import org.dspace.event.Consumer;
import org.dspace.event.Event;
//import org.dspace.event.EventConsumer;
//import org.dspace.event.EventFilter;
import org.dspace.content.crosswalk.CrosswalkException;
import org.dspace.content.crosswalk.DisseminationCrosswalk;
// import org.dspace.content.crosswalk.DisseminationCrosswalk;
// import org.dspace.content.crosswalk.IngestionCrosswalk;
// import org.dspace.content.crosswalk.StreamDisseminationCrosswalk;
import org.dspace.content.crosswalk.StreamIngestionCrosswalk;
// import org.dspace.content.crosswalk.XSLTIngestionCrosswalk;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.ItemService;
import org.dspace.services.ConfigurationService;
import org.dspace.services.factory.DSpaceServicesFactory;

// import org.jdom.Element;

import static org.apache.commons.lang.StringUtils.isBlank;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.sql.SQLException;

import org.jdom.Element;
import org.jdom.output.XMLOutputter;
// import java.util.List;
// import java.util.Map;
// import java.util.ArrayList;
// import java.util.HashMap;

import org.apache.log4j.Logger;


public class DIMMetadataTransformConsumer implements Consumer {

    static ConfigurationService configurationService = DSpaceServicesFactory.getInstance().getConfigurationService();
    private static final Logger log = Logger.getLogger(cz.cuni.metadataconsumers.DIMMetadataTransformConsumer.class);
    private final ItemService itemService = ContentServiceFactory.getInstance().getItemService();

    private static final String DIM_MIME_TYPE = "application/dim";
    public static final String XSLT_CROSSWALK_NAME_CFG = "consumer.cunimetadatatransorm.crosswalk.name";
    public static final String XSLT_CROSSWALK_NAME = configurationService.getProperty(XSLT_CROSSWALK_NAME_CFG);
    
    @Override
    public void initialize() throws Exception {
        log.info("DIMMetadataTranformConsumer initialized...");
        checkConsumerConfig();
    }

    
    @Override
    public void consume(Context context, Event event) throws Exception {
        // Ensure this consumer only acts on an Item object during CREATE or MODIFY
        if (event.getSubjectType() == Constants.ITEM) {
            if (event.getEventType() == Event.CREATE || event.getEventType() == Event.MODIFY || event.getEventType() == Event.MODIFY_METADATA) {
                Item item = (Item) event.getSubject(context);

                item = context.reloadEntity(item);
                // --- 1. Get the XSLT crosswalk plugins ---
                // Get the DIM crosswalk using the correct interface for DSpace 6.x
                DisseminationCrosswalk dimDisseminator = 
                    (DisseminationCrosswalk) CoreServiceFactory.getInstance().getPluginService().getNamedPlugin(
                        DisseminationCrosswalk.class, "dim");
                
                // Get the XSLT ingestion crosswalk to import the modified XML
                StreamIngestionCrosswalk xsltIngester = 
                    (StreamIngestionCrosswalk) CoreServiceFactory.getInstance().getPluginService().getNamedPlugin(
                        StreamIngestionCrosswalk.class, XSLT_CROSSWALK_NAME); // Use the name from dspace.cfg
                
                if (dimDisseminator == null || xsltIngester == null) {
                    throw new CrosswalkException("Required crosswalk plugins not found.");
                }

                try (ByteArrayOutputStream dimOutputStream = new ByteArrayOutputStream()) {
                    // Disseminate item's metadata to DIM XML as a JDOM Element
                    Element dimElement = dimDisseminator.disseminateElement(context, item);

                    // Use JDOM's XMLOutputter to write the element to the stream
                    new XMLOutputter().output(dimElement, dimOutputStream);
                    
                    ByteArrayInputStream dimInputStream = new ByteArrayInputStream(dimOutputStream.toByteArray());

                    // The ingest method expects a String for the MIMEType, which is "application/dim"
                    // in this case, as that is the format being ingested by the XSLT crosswalk.
                    xsltIngester.ingest(context, item, dimInputStream, DIM_MIME_TYPE);
                    
                    // --- 4. Commit changes and update the item ---
                    itemService.update(context, item);
                    
                } catch (IOException | CrosswalkException | SQLException e) {
                    // Log the error and handle exceptions
                    throw new Exception("Error transforming metadata with XSLT", e);
                }
            }
        }
    }
   
     public void checkConsumerConfig() throws IOException {
        String message = null;
        if (isBlank(XSLT_CROSSWALK_NAME)) 
        {
            message = "Missing configuration for your consumer property: " + XSLT_CROSSWALK_NAME_CFG ;
        }
        
        if (message != null) {
            log.error(message, null);
        } else {
            log.info("Consumer configuration is valid.");
        }
    }
    
    @Override
    public void end(Context context) throws Exception {

    }
    
    @Override
    public void finish(Context context) throws Exception {

    }

}