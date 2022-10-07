package com.atmire.itemmapper;

import static com.atmire.itemmapper.ParametrizedItemMappingScript.LOCAL;
import static com.atmire.itemmapper.ParametrizedItemMappingScript.MAPPED;
import static com.atmire.itemmapper.ParametrizedItemMappingScript.URL;
import static com.atmire.itemmapper.ParametrizedItemMappingScript.configurationService;
import static com.atmire.itemmapper.service.ItemMapperServiceImpl.ERROR;
import static com.atmire.itemmapper.service.ItemMapperServiceImpl.INFO;
import static com.atmire.itemmapper.service.ItemMapperServiceImpl.WARN;
import static org.apache.commons.lang.StringUtils.isBlank;

import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.Set;
import javax.annotation.Nullable;

import com.atmire.itemmapper.factory.ItemMapperServiceFactory;
import com.atmire.itemmapper.model.CuniMapFile;
import com.atmire.itemmapper.service.ItemMapperService;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.dspace.content.Item;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.ItemService;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.event.Consumer;
import org.dspace.event.Event;

public class ItemMapperConsumer implements Consumer {
    private static final Logger log = org.apache.log4j.LogManager.getLogger(ItemMapperConsumer.class);
    protected ItemService itemService = ContentServiceFactory.getInstance().getItemService();
    private final ItemMapperService itemMapperService =
        ItemMapperServiceFactory.getInstance().getItemMapperService();
    public static final String CONSUMER_MAPPING_FILE_LOCATION_CFG = "consumer.mapping.file.location";
    public static final String CONSUMER_MAPPING_FILE_NAME_CFG = "consumer.mapping.file.name";
    public static final String CONSUMER_MAPPING_FILE_PATH_CFG = "consumer.mapping.file.path";
    public static final String CONSUMER_MAPPING_FILE_LOCATION = configurationService.getProperty(CONSUMER_MAPPING_FILE_LOCATION_CFG);
    public static final String CONSUMER_MAPPING_FILE_NAME = configurationService.getProperty(CONSUMER_MAPPING_FILE_NAME_CFG);
    public static final String CONSUMER_MAPPING_FILE_PATH = configurationService.getProperty(CONSUMER_MAPPING_FILE_PATH_CFG);
    public static final String FULL_PATH_TO_FILE = CONSUMER_MAPPING_FILE_PATH + File.separator + CONSUMER_MAPPING_FILE_NAME;
    public static final String CONSUMER_ITEM_MAPPED_ENABLED_CONFIG = "consumer.item.mapper.enabled";
    public static final boolean CONSUMER_ITEM_MAPPER_ENABLED =
        configurationService.getBooleanProperty(CONSUMER_ITEM_MAPPED_ENABLED_CONFIG, true);
    Set<Item> itemList = new HashSet<>();
    CuniMapFile cuniMapFile;
    private boolean validConsumerConfig = true;

    @Override
    public void initialize() {
        // nothing
    }
    @Override
    public void consume(Context ctx, Event event) throws Exception {
        if (event.getSubjectType() == Constants.ITEM && (event.getEventType() == Event.INSTALL || event.getEventType() == Event.MODIFY_METADATA)) {
            if (validConsumerConfig) {
                checkConsumerConfig();
            } else {
                return;
            }
            if (CONSUMER_ITEM_MAPPER_ENABLED) {
                handleConsume(ctx, event);
            }
        }
    }

    private void handleConsume(Context ctx, Event event) throws SQLException, IOException {
        if(validConsumerConfig) {
            Item item = (Item) event.getSubject(ctx);
            if (!item.isArchived()) {
                return;
            }
            if (CONSUMER_MAPPING_FILE_LOCATION.equals(URL)) {
                cuniMapFile = itemMapperService.getMapFileFromLink(CONSUMER_MAPPING_FILE_PATH);
                itemMapperService.addItemToListIfInSourceCollection(ctx, item, cuniMapFile, itemList);
            } else if (CONSUMER_MAPPING_FILE_LOCATION.equals(LOCAL)) {
                cuniMapFile = itemMapperService.getMapFileFromPath(FULL_PATH_TO_FILE);
                itemMapperService.addItemToListIfInSourceCollection(ctx, item, cuniMapFile, itemList);
            } else {
                logMessage(INFO, "Item install event was called but the path to the file is not " +
                    "set correctly, please double check your consumer properties:" +
                    CONSUMER_MAPPING_FILE_LOCATION_CFG + ", " + CONSUMER_MAPPING_FILE_NAME_CFG + " and" +
                    CONSUMER_MAPPING_FILE_LOCATION_CFG, null);
            }
        }
    }

    @Override
    public void end(Context ctx) {
        if (validConsumerConfig) {
            if (!itemList.isEmpty()) {
                try {
                    if (CONSUMER_MAPPING_FILE_LOCATION.equals(URL)) {
                        logMessage(INFO, "Item install event, mapping items based on URL: "
                            + CONSUMER_MAPPING_FILE_PATH, null);
                    } else {
                        logMessage(INFO, "Item install event, mapping items based on local file located at : "
                            + FULL_PATH_TO_FILE, null);
                    }
                    itemMapperService.reverseMapItemsInBatch(ctx, itemList.iterator(), null, null, false);
                    itemMapperService.checkMetadataValuesAndConvertToString(ctx, itemList.iterator(), cuniMapFile, MAPPED, false);
                } catch (Exception e) {
                    logMessage(ERROR,"An exception occurred while mapping items", e);
                } finally {
                    itemList.clear();
                }
            }
        }
    }

    @Override
    public void finish(Context ctx) {
        // nothing
    }

    public void checkConsumerConfig() throws IOException {
        String message = null;
        if (isBlank(CONSUMER_MAPPING_FILE_LOCATION) || isBlank(CONSUMER_MAPPING_FILE_PATH) ||
            isBlank(CONSUMER_MAPPING_FILE_NAME)) {
            message =
                "Missing configuration for one of your consumer properties: " + CONSUMER_MAPPING_FILE_LOCATION_CFG +
                    ", " + CONSUMER_MAPPING_FILE_PATH_CFG + ", " + CONSUMER_MAPPING_FILE_NAME_CFG;
        }
        if (CONSUMER_MAPPING_FILE_LOCATION.equalsIgnoreCase(URL) && !itemMapperService.isLinkValid()) {
            message = "The given URL does not resolve: " + CONSUMER_MAPPING_FILE_PATH;
        }
        if (CONSUMER_MAPPING_FILE_LOCATION.equalsIgnoreCase(LOCAL) && !itemMapperService.doesFileExist()) {
            message = "The file you supplied is not a valid JSON file: " + FULL_PATH_TO_FILE;
        }
        if (message != null) {
            validConsumerConfig = false;
            logMessage(ERROR, message, null);
        } else {
            validConsumerConfig = true;
        }
        if (!CONSUMER_ITEM_MAPPER_ENABLED) {
            logMessage(INFO, String.format("Mapping consumer disabled with config '%s'.",
                CONSUMER_ITEM_MAPPED_ENABLED_CONFIG), null);
        }
    }

    private void logMessage(String level, String message, @Nullable Exception e) {
        if (StringUtils.isNotBlank(message)) {
            message = "ItemMapperConsumer: " + message;
            switch (level) {
                case INFO:
                    log.info(message);
                    break;
                case ERROR:
                    log.error(message, e);
                    break;
                case WARN:
                    log.warn(message);
                    break;
                default:
                    throw new IllegalArgumentException(level + "is not a valid log level");
            }
        }
    }

}
