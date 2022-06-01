package com.atmire.itemmapper;

import static com.atmire.itemmapper.ParametrizedItemMappingScript.LOCAL;
import static com.atmire.itemmapper.ParametrizedItemMappingScript.URL;
import static com.atmire.itemmapper.ParametrizedItemMappingScript.configurationService;

import java.io.File;

import com.atmire.itemmapper.factory.ItemMapperServiceFactory;
import com.atmire.itemmapper.service.ItemMapperService;
import org.apache.log4j.Logger;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.ItemService;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.event.Consumer;
import org.dspace.event.Event;

public class ItemMapperConsumer implements Consumer {
    private static Logger log = Logger.getLogger(ItemMapperConsumer.class);
    protected ItemService itemService = ContentServiceFactory.getInstance().getItemService();
    ItemMapperService itemMapperService = ItemMapperServiceFactory.getInstance().getItemMapperService();
    public static final String CONSUMER_MAPPING_FILE_LOCATION_CFG = "consumer.mapping.file.location";
    public static final String CONSUMER_MAPPING_FILE_NAME_CFG = "consumer.mapping.file.name";
    public static final String CONSUMER_MAPPING_FILE_PATH_CFG = "consumer.mapping.file.path";
    public static final String CONSUMER_MAPPING_FILE_LOCATION = configurationService.getProperty(CONSUMER_MAPPING_FILE_LOCATION_CFG);
    public static final String CONSUMER_MAPPING_FILE_NAME = configurationService.getProperty(CONSUMER_MAPPING_FILE_NAME_CFG);
    public static final String CONSUMER_MAPPING_FILE_PATH = configurationService.getProperty(CONSUMER_MAPPING_FILE_PATH_CFG);
    public static final String FULL_PATH_TO_FILE = CONSUMER_MAPPING_FILE_PATH + File.separator + CONSUMER_MAPPING_FILE_NAME;
    public static final boolean CONSUMER_ITEM_MAPPER_ENABLED = configurationService.getBooleanProperty("consumer" +
                                                                                                            ".item.mapper.enabled", true);

    @Override
    public void initialize() throws Exception {

    }

    @Override
    public void consume(Context ctx, Event event) throws Exception {
        if (CONSUMER_ITEM_MAPPER_ENABLED) {
            if (event.getSubjectType() == Constants.ITEM && event.getEventType() == Event.INSTALL) {
                    if (CONSUMER_MAPPING_FILE_LOCATION.equals(URL)) {
                        log.info("ItemMapperConsumer: Item install event, mapping items based on URL: " +
                                     CONSUMER_MAPPING_FILE_PATH);
                    }
                    if (CONSUMER_MAPPING_FILE_LOCATION.equals(LOCAL)) {
                        log.info("ItemMapperConsumer: Item install event, mapping items based on local file located " +
                                     "at : " + FULL_PATH_TO_FILE);
                    }
                    itemMapperService.consumerMapFromMappingFile(ctx, CONSUMER_MAPPING_FILE_PATH, FULL_PATH_TO_FILE);
            }
        }
    }

    @Override
    public void end(Context ctx) throws Exception {

    }

    @Override
    public void finish(Context ctx) throws Exception {

    }
}
