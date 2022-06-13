package com.atmire.itemmapper;

import static com.atmire.itemmapper.ParametrizedItemMappingScript.LOCAL;
import static com.atmire.itemmapper.ParametrizedItemMappingScript.MAPPED;
import static com.atmire.itemmapper.ParametrizedItemMappingScript.URL;
import static com.atmire.itemmapper.ParametrizedItemMappingScript.configurationService;
import static org.apache.commons.lang3.StringUtils.substringAfterLast;

import java.io.File;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.atmire.itemmapper.factory.ItemMapperServiceFactory;
import com.atmire.itemmapper.model.CuniMapFile;
import com.atmire.itemmapper.model.SourceCollection;
import com.atmire.itemmapper.service.ItemMapperService;
import org.apache.log4j.Logger;
import org.dspace.content.Collection;
import org.dspace.content.Item;
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
    List<Item> itemList = new ArrayList<>();
    CuniMapFile cuniMapFile;

    @Override
    public void initialize() throws Exception {

    }

    @Override
    public void consume(Context ctx, Event event) throws Exception {
        if (CONSUMER_ITEM_MAPPER_ENABLED && event.getSubjectType() == Constants.ITEM && event.getEventType() == Event.INSTALL) {

            Item item = (Item) event.getSubject(ctx);

            if (CONSUMER_MAPPING_FILE_LOCATION.equals(URL) && isLinkValid()) {
                log.info("ItemMapperConsumer: Item install event, mapping items based on URL: " + CONSUMER_MAPPING_FILE_PATH);
                cuniMapFile = itemMapperService.getMapFileFromLink(CONSUMER_MAPPING_FILE_PATH);
                addItemToListIfInSourceCollection(ctx, item);
            }

            else if (CONSUMER_MAPPING_FILE_LOCATION.equals(LOCAL) && doesFileExist()) {
                log.info("ItemMapperConsumer: Item install event, mapping items based on local file located at : " + FULL_PATH_TO_FILE);
                cuniMapFile = itemMapperService.getMapFileFromPath(FULL_PATH_TO_FILE);
                addItemToListIfInSourceCollection(ctx, item);
            }
            else {
                log.error("ItemMapperConsumer: Item install event was called but the path to the file is not " +
                              "set correctly, please double check your consumer properties:" +
                              CONSUMER_MAPPING_FILE_LOCATION_CFG + ", " + CONSUMER_MAPPING_FILE_NAME_CFG + " and" + CONSUMER_MAPPING_FILE_LOCATION_CFG);

            }
        }
    }

    @Override
    public void end(Context ctx) throws Exception {
        if (!itemList.isEmpty()) {
            try {
                itemMapperService.checkMetadataValuesAndConvertToString(ctx, itemList.iterator(), cuniMapFile, MAPPED, false);
            } catch (Exception e) {
                log.error("ItemMapperConsumer: An exception occurred while mapping items", e);
            } finally {
                itemList.clear();
            }
        }
    }

    @Override
    public void finish(Context ctx) throws Exception {

    }

    public void addItemToListIfInSourceCollection(Context ctx, Item item) throws SQLException {
        for (SourceCollection col : cuniMapFile.getMapfile().getSource_collections()) {
            Collection collection =  itemMapperService.getCorrespondingCollection(ctx, col);
            if (collection.getID() == item.getOwningCollection().getID()) {
                itemList.add(item);
            }
        }
    }

    public boolean doesFileExist() {
        File jsonFile = new File(FULL_PATH_TO_FILE);
        return substringAfterLast(FULL_PATH_TO_FILE, ".").equals("json") && jsonFile.exists() && jsonFile.isFile();
    }

    public boolean isLinkValid() throws IOException {
        java.net.URL url = new URL(CONSUMER_MAPPING_FILE_PATH);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        int responseCode = connection.getResponseCode();
        return responseCode >= 200 && responseCode <= 300;
    }
}
