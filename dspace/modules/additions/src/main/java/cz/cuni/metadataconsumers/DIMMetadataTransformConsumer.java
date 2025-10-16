package cz.cuni.metadataconsumers;
import org.dspace.authorize.AuthorizeException;
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
// import org.dspace.content.crosswalk.StreamIngestionCrosswalk;
// import org.dspace.content.crosswalk.XSLTIngestionCrosswalk;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.ItemService;
import org.dspace.services.ConfigurationService;
import org.dspace.services.factory.DSpaceServicesFactory;

// import org.jdom.Element;

import static org.apache.commons.lang.StringUtils.isBlank;

// import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
// import java.util.Collections;
import java.util.Set;
// import java.util.UUID;

import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.jdom.Element;
import org.jdom.input.SAXBuilder;
import org.jdom.output.XMLOutputter;
import org.jdom.Document;
import org.jdom.JDOMException;

import javax.xml.transform.Source;
import javax.xml.transform.Transformer;

import org.apache.log4j.Logger;


public class DIMMetadataTransformConsumer implements Consumer {

    // Use a static, synchronized Set to track item IDs being processed
    // private static final Set<UUID> inProgressItemIds = Collections.synchronizedSet(new HashSet<>());

    static ConfigurationService configurationService = DSpaceServicesFactory.getInstance().getConfigurationService();
    private static final Logger log = Logger.getLogger(cz.cuni.metadataconsumers.DIMMetadataTransformConsumer.class);
    private final ItemService itemService = ContentServiceFactory.getInstance().getItemService();

    // private static final String DIM_MIME_TYPE = "application/dim";
    public static final String XSLT_CROSSWALK_NAME_CFG = "consumer.cunimetadatatransorm.crosswalk.name";
    public static final String XSLT_CROSSWALK_NAME = configurationService.getProperty(XSLT_CROSSWALK_NAME_CFG);
    Set<Item> itemList = new HashSet<>();

    @Override
    public void initialize() throws Exception {
        log.info("DIMMetadataTranformConsumer initialized...");
        checkConsumerConfig();
    }

    
    @Override
    public void consume(Context context, Event event) throws Exception {
        
        // Ensure this consumer only acts on an Item object during CREATE or MODIFY
        if (event.getSubjectType() == Constants.ITEM) {
            if (event.getEventType() == Event.INSTALL || event.getEventType() == Event.MODIFY_METADATA) {
                handleConsume(context, event);                
            }
        }
    }

    private void handleConsume(Context context, Event event) throws Exception {

        try {
            
            Item item = (Item) event.getSubject(context);
            log.info("Processing item: " + "HANDLE: " + item.getHandle() + "(" + item.getID() +")");
            if (!item.isArchived()) {
                log.info("ITEM: HANDLE: " + item.getHandle() + "(" + item.getID() + ") is NOT ARCHIVED! ENDING PROCESSING");
                return;
            }
            itemList.add(item);
        } catch (Exception e) {
            log.error(e.getMessage());
            log.error(e.toString());
        }
        


        

        
        

                // Check if this item is already being processed
                // if (inProgressItemIds.contains(itemId)) {
                //     return; // Exit to prevent the infinite loop
                // }

                // // --- 1. Get the XSLT crosswalk plugins ---
                // // Get the DIM crosswalk using the correct interface for DSpace 6.x
                // DisseminationCrosswalk dimDisseminator = 
                //     (DisseminationCrosswalk) CoreServiceFactory.getInstance().getPluginService().getNamedPlugin(
                //         DisseminationCrosswalk.class, "dim");
                
                // // // Get the XSLT ingestion crosswalk to import the modified XML
                // // StreamIngestionCrosswalk xsltIngester = 
                // //     (StreamIngestionCrosswalk) CoreServiceFactory.getInstance().getPluginService().getNamedPlugin(
                // //         StreamIngestionCrosswalk.class, XSLT_CROSSWALK_NAME); // Use the name from dspace.cfg
                
                // // if (dimDisseminator == null || xsltIngester == null) {
                // if (dimDisseminator == null) {
                //     throw new CrosswalkException("Required crosswalk plugins not found.");
                // }

                // try (ByteArrayOutputStream dimOutputStream = new ByteArrayOutputStream()) {
                    
                    // Add the item ID to the set to mark it as in-progress
                    // inProgressItemIds.add(itemId);

                    // 1. Disseminate item's metadata to DIM XML
                    // Element dimElement = dimDisseminator.disseminateElement(context, item);
                    // new XMLOutputter().output(dimElement, dimOutputStream);
                    
                    // String originalDimXml = dimOutputStream.toString("UTF-8");

                    // 2. Perform the XSLT transformation using standard Java libraries
                    // TransformerFactory factory = TransformerFactory.newInstance();
                    
                    // Load the XSLT stylesheet from the configuration directory
                    // String xsltPath = configurationService.getProperty("dspace.dir") + "/config/crosswalks/cuni_dim_crosswalk.xsl";
                    // Source xsltSource = new StreamSource(Files.newInputStream(Paths.get(xsltPath)));
                    // Transformer transformer = factory.newTransformer(xsltSource);

                    // Source xmlSource = new StreamSource(new StringReader(originalDimXml));
                    // StringWriter resultWriter = new StringWriter();
                    // transformer.transform(xmlSource, new StreamResult(resultWriter));
                    // String transformedXml = resultWriter.toString();

                    // 3. Parse the transformed XML and update the item
                    // SAXBuilder saxBuilder = new SAXBuilder();
                    // Document transformedDimDoc = saxBuilder.build(new StringReader(transformedXml));
                    // Element transformedDimElement = transformedDimDoc.getRootElement();

                    // The following logic is an example; your update logic might differ based on the XSLT output.
                    // Here, we assume the XSLT replaces existing metadata.
                    
                    // Clear all existing metadata
                    // itemService.clearMetadata(context, item, Item.ANY, Item.ANY, Item.ANY, Item.ANY);
                    
                    // The getChildren() method in JDOM 1.x returns a raw List
                    // List<?> rawFieldElements = transformedDimElement.getChildren("field", transformedDimElement.getNamespace());

                    // for (Object rawField : rawFieldElements) {
                    //     if (rawField instanceof Element) {
                    //         Element field = (Element) rawField;
                    //         String schema = field.getAttributeValue("mdschema");
                    //         String element = field.getAttributeValue("element");
                    //         String qualifier = field.getAttributeValue("qualifier");
                    //         String lang = field.getAttributeValue("lang");
                    //         String value = field.getTextTrim();
                    //         itemService.addMetadata(context, item, schema, element, qualifier, lang, value);
                    //     }
                    // }
                    
                    // // --- 4. Commit changes and update the item ---
                    // itemService.update(context, item);
                    
                // } catch (IOException | SQLException | JDOMException | javax.xml.transform.TransformerException e) {
                //     throw new Exception("Error transforming metadata manually with XSLT", e);
                // } finally {
                //     // Remove the item ID from the set after the consumer's execution
                //     inProgressItemIds.remove(itemId);
                    // Restore the event dispatcher after your modifications are complete
                    // This is critical to ensure other events are processed correctly
        //         }
        //     }
        // }
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

    private DisseminationCrosswalk createDisseminator(Context context) throws CrosswalkException {
        // --- 1. Get the XSLT crosswalk plugins ---
        // Get the DIM crosswalk using the correct interface for DSpace 6.x
        DisseminationCrosswalk dimDisseminator = 
            (DisseminationCrosswalk) CoreServiceFactory.getInstance().getPluginService().getNamedPlugin(
                DisseminationCrosswalk.class, "dim");
        
        if (dimDisseminator == null) {
            throw new CrosswalkException("Required crosswalk plugins " + XSLT_CROSSWALK_NAME + " not found.");
        }
        return dimDisseminator;
    }

    private void handleTransform(Context context, Iterator<Item> items, DisseminationCrosswalk disseminator) {
        while (items.hasNext()) {
            try {
                Item item = items.next();
                // Reload since attached metadata/bundles/etc hibernate error when from consumer
                item = context.reloadEntity(item);

                transform(context, item, disseminator);
            } catch (SQLException e) {
                log.error(e.getMessage());
                log.error(e.toString());
            }
        }
    }

    private void transform(Context context, Item item, DisseminationCrosswalk disseminator) {
        try (ByteArrayOutputStream dimOutputStream = new ByteArrayOutputStream()) {
                    
            // 1. Disseminate item's metadata to DIM XML
            Element dimElement = disseminator.disseminateElement(context, item);
            
            new XMLOutputter().output(dimElement, dimOutputStream);
            
            String originalDimXml = dimOutputStream.toString("UTF-8");

            // 2. Perform the XSLT transformation using standard Java libraries
            TransformerFactory factory = TransformerFactory.newInstance();
            
            // Load the XSLT stylesheet from the configuration directory
            String xsltPath = configurationService.getProperty("dspace.dir") + "/config/crosswalks/cuni_dim_crosswalk.xsl";
            Source xsltSource = new StreamSource(Files.newInputStream(Paths.get(xsltPath)));
            Transformer transformer = factory.newTransformer(xsltSource);

            Source xmlSource = new StreamSource(new StringReader(originalDimXml));
            StringWriter resultWriter = new StringWriter();
            transformer.transform(xmlSource, new StreamResult(resultWriter));
            String transformedXml = resultWriter.toString();

            // 3. Parse the transformed XML and update the item
            SAXBuilder saxBuilder = new SAXBuilder();
            Document transformedDimDoc = saxBuilder.build(new StringReader(transformedXml));
            Element transformedDimElement = transformedDimDoc.getRootElement();
            
            // Clear all existing metadata
            itemService.clearMetadata(context, item, Item.ANY, Item.ANY, Item.ANY, Item.ANY);
            
            // The getChildren() method in JDOM 1.x returns a raw List
            List<?> rawFieldElements = transformedDimElement.getChildren("field", transformedDimElement.getNamespace());

            addTransformedMetadata(context, item, rawFieldElements);
        } catch (IOException | SQLException | JDOMException | javax.xml.transform.TransformerException | CrosswalkException | AuthorizeException e) {
            log.error(e.getMessage());
            log.error(e.toString());    
        }
            
    }

    public void addTransformedMetadata(Context context, Item item, List<?> rawFieldElements) {
        try {
            for (Object rawField : rawFieldElements) {
            
                if (rawField instanceof Element) {
                    Element field = (Element) rawField;
                    
                    String schema = field.getAttributeValue("mdschema");
                    String element = field.getAttributeValue("element");
                    String qualifier = field.getAttributeValue("qualifier");
                    String lang = field.getAttributeValue("lang");
                    String value = field.getTextTrim();
                    
                    log.debug("Adding metadata field " + schema + "." + element + "." + qualifier + "[" + lang + "]" + "with VALUE = " + value);

                    itemService.addMetadata(context, item, schema, element, qualifier, lang, value);
                }
            }
            itemService.update(context, item);
        } catch (AuthorizeException | SQLException e) {
                log.error(e.getMessage());
                log.error(e.toString());
        }
        
    }
    
    @Override
    public void end(Context context) throws Exception {
        
        if (!itemList.isEmpty()) {
            try {
                log.info("Creating DISSEMINATOR base on CROSSWALK " + XSLT_CROSSWALK_NAME);
                DisseminationCrosswalk disseminator = createDisseminator(context);
                log.info("Disseminator CREATED.");

                log.info("Starting transform...");
                handleTransform(context, itemList.iterator(), disseminator);


            } catch (Exception e) {
                log.error(e.getMessage());
                log.error(e.toString());
            } finally {
                itemList.clear();
            }
            
        }
    }
    
    @Override
    public void finish(Context context) throws Exception {

    }

}