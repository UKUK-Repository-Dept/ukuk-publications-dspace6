package cz.cuni.metadataconsumers;
import org.dspace.authorize.AuthorizeException;
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
import org.dspace.content.crosswalk.IngestionCrosswalk;
import org.dspace.content.crosswalk.XSLTIngestionCrosswalk;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.ItemService;
import org.dspace.services.ConfigurationService;
import org.dspace.services.factory.DSpaceServicesFactory;

import org.jdom.Element;

import static org.apache.commons.lang.StringUtils.isBlank;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import org.apache.log4j.Logger;


public class DIMMetadataTransformConsumer implements Consumer {

    static ConfigurationService configurationService = DSpaceServicesFactory.getInstance().getConfigurationService();
    private static final Logger log = Logger.getLogger(cz.cuni.metadataconsumers.DIMMetadataTransformConsumer.class);
    protected ItemService itemService = ContentServiceFactory.getInstance().getItemService();

    public static final String XSLT_CROSSWALK_NAME_CFG = "consumer.cunimetadatatransorm.crosswalk.name";
    public static final String XSLT_CROSSWALK_NAME = configurationService.getProperty(XSLT_CROSSWALK_NAME_CFG);
    
    @Override
    public void initialize() throws Exception {
        log.info("DIMMetadataTranformConsumer initialized...");
    }
    
    @Override
    public void consume(Context ctx, Event event) throws Exception {
        if (event.getSubjectType() == Constants.ITEM && (event.getEventType() == Event.INSTALL || event.getEventType() == Event.MODIFY_METADATA)) {
            checkConsumerConfig();            
            
            handleConsume(ctx, event);            
        }

        String xsltPath = configurationService.getProperty("crosswalk.ingestion." + XSLT_CROSSWALK_NAME + ".stylesheet");
        log.info("Using XSLTCrosswalk " + XSLT_CROSSWALK_NAME + "with a XSLT file: " + xsltPath);
    }

    private void handleConsume(Context ctx, Event event) throws SQLException, CrosswalkException, IOException, AuthorizeException {
        try {
            
            Item item = (Item) event.getSubject(ctx);
            if (!item.isArchived()) {
                return;
            }
            
            // Get the DIM dissemination crosswalk
            DisseminationCrosswalk dimXwalk = (DisseminationCrosswalk) CoreServiceFactory.getInstance().getPluginService().getNamedPlugin(DisseminationCrosswalk.class, "DIM");
            
            // Export metadata as JDOM Element
            Element dimElement = dimXwalk.disseminateElement(ctx, item);
            // Wrap it in a list
            List<Element> elements = new ArrayList<>();
            elements.add(dimElement);
            // Use it as input for your XSLT ingestion crosswalkXSLTIngestionCrosswalk
            XSLTIngestionCrosswalk xwalk = (XSLTIngestionCrosswalk) CoreServiceFactory.getInstance().getPluginService().getNamedPlugin(
                IngestionCrosswalk.class, XSLT_CROSSWALK_NAME);
                
            xwalk.ingest(ctx, item, elements, false);
            
        } catch (Exception e){
            log.error(String.format("An exception has occurred trying to map item " +
                    "(id:%s|handle:%s) => %s%n%s", event.getSubject(ctx) != null ? event.getSubject(ctx).getID() : "",
                event.getSubject(ctx) != null ? event.getSubject(ctx).getID() : "", e.getMessage(), e.toString()));
            e.printStackTrace();

            throw e;
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