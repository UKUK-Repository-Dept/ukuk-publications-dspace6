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

import java.util.List;

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

    static ConfigurationService configurationService = DSpaceServicesFactory.getInstance().getConfigurationService();
    private static final Logger log = Logger.getLogger(cz.cuni.metadataconsumers.DIMMetadataTransformConsumer.class);
    private final ItemService itemService = ContentServiceFactory.getInstance().getItemService();

    // private static final String DIM_MIME_TYPE = "application/dim";
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
                
                // // Get the XSLT ingestion crosswalk to import the modified XML
                // StreamIngestionCrosswalk xsltIngester = 
                //     (StreamIngestionCrosswalk) CoreServiceFactory.getInstance().getPluginService().getNamedPlugin(
                //         StreamIngestionCrosswalk.class, XSLT_CROSSWALK_NAME); // Use the name from dspace.cfg
                
                // if (dimDisseminator == null || xsltIngester == null) {
                if (dimDisseminator == null) {
                    throw new CrosswalkException("Required crosswalk plugins not found.");
                }

                try (ByteArrayOutputStream dimOutputStream = new ByteArrayOutputStream()) {
                    // 1. Disseminate item's metadata to DIM XML
                    Element dimElement = dimDisseminator.disseminateElement(context, item);
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

                    // The following logic is an example; your update logic might differ based on the XSLT output.
                    // Here, we assume the XSLT replaces existing metadata.
                    
                    // Clear all existing metadata
                    itemService.clearMetadata(context, item, Item.ANY, Item.ANY, Item.ANY, Item.ANY);
                    
                    // The getChildren() method in JDOM 1.x returns a raw List
                    List<?> rawFieldElements = transformedDimElement.getChildren("field", transformedDimElement.getNamespace());

                    for (Object rawField : rawFieldElements) {
                        if (rawField instanceof Element) {
                            Element field = (Element) rawField;
                            String schema = field.getAttributeValue("mdschema");
                            String element = field.getAttributeValue("element");
                            String qualifier = field.getAttributeValue("qualifier");
                            String lang = field.getAttributeValue("lang");
                            String value = field.getTextTrim();
                            itemService.addMetadata(context, item, schema, element, qualifier, lang, value);
                        }
                    }
                    
                    // --- 4. Commit changes and update the item ---
                    itemService.update(context, item);
                    
                } catch (IOException | SQLException | JDOMException | javax.xml.transform.TransformerException e) {
                    throw new Exception("Error transforming metadata manually with XSLT", e);
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