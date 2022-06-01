package com.atmire.itemmapper.service;

import static com.atmire.itemmapper.ParametrizedItemMappingScript.CONSUMER_FILE_LOCATION;
import static com.atmire.itemmapper.ParametrizedItemMappingScript.FILE_LOCATION;
import static com.atmire.itemmapper.ParametrizedItemMappingScript.LOCAL;
import static com.atmire.itemmapper.ParametrizedItemMappingScript.MAPPED;
import static com.atmire.itemmapper.ParametrizedItemMappingScript.OPERATIONS;
import static com.atmire.itemmapper.ParametrizedItemMappingScript.REVERSED;
import static com.atmire.itemmapper.ParametrizedItemMappingScript.REVERSED_MAPPED;
import static com.atmire.itemmapper.ParametrizedItemMappingScript.UNMAPPED;
import static com.atmire.itemmapper.ParametrizedItemMappingScript.URL;
import static org.apache.commons.lang3.StringUtils.isBlank;
import static org.apache.commons.lang3.StringUtils.isNotBlank;
import static org.apache.commons.lang3.StringUtils.substringAfterLast;

import java.io.File;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.URL;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import com.atmire.itemmapper.ParametrizedItemMappingScript;
import com.atmire.itemmapper.model.CuniMapFile;
import com.atmire.itemmapper.model.GenericCollection;
import com.atmire.itemmapper.model.MappingRecord;
import com.atmire.itemmapper.model.MetadataField;
import com.atmire.itemmapper.model.SourceCollection;
import com.atmire.itemmapper.model.TargetCollection;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.commons.io.FileUtils;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Collection;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.content.MetadataValue;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.CollectionService;
import org.dspace.content.service.ItemService;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.handle.factory.HandleServiceFactory;
import org.dspace.handle.service.HandleService;
import org.dspace.services.ConfigurationService;
import org.dspace.services.factory.DSpaceServicesFactory;

public class ItemMapperServiceImpl implements ItemMapperService {

    private static final Logger log = LogManager.getLogger(ParametrizedItemMappingScript.class);
    ItemService itemService = ContentServiceFactory.getInstance().getItemService();
    CollectionService collectionService = ContentServiceFactory.getInstance().getCollectionService();
    HandleService handleService = HandleServiceFactory.getInstance().getHandleService();
    static ConfigurationService configurationService = DSpaceServicesFactory.getInstance().getConfigurationService();



    Collection resolvedSourceCollection;
    Collection resolvedDestinationCollection;
    Iterator<Item> itemsToMap;
    double totalItems;
    int batchSize = configurationService.getIntProperty("item.mapper.batch.size", 100);
    int offset = 0;

    public static final char PATH_OPTION_CHAR = 'p';
    public static final String MAPPING_FILE_NAME_CFG = "mapping.file.name";
    public static final String MAPPING_FILE_PATH_CFG = "mapping.file.path";
    public static final String MAPPING_FILE_NAME = configurationService.getProperty(MAPPING_FILE_NAME_CFG);
    public static final String MAPPING_FILE_PATH = configurationService.getProperty(MAPPING_FILE_PATH_CFG);
    public static final String INFO = "info";
    public static final String ERROR = "error";
    public static final String WARN = "warn";

    @Override
    public void logCLI(String level, String message) {
        System.out.println(level.toUpperCase() + ": " + message);
        switch (level) {
            case INFO:
                log.info(message);
                break;
            case ERROR:
                log.error(message);
                break;
            case WARN:
                log.warn(message);
                break;
            default:
                throw new IllegalArgumentException(level + "is not a valid log level");
        }
    }

    @Override
    public void mapItem (Context context, Item item, Collection sourceCollection, Collection destinationCollection,
                         boolean dryRun)
        throws SQLException, AuthorizeException {

        if (itemService.isOwningCollection(item, sourceCollection)) {
            addItemToCollection(context, item, destinationCollection, dryRun);

        } else {
            logCLI(WARN, String.format("Item (%s | %s) was not mapped because it is not owned by " +
                                                "collection (%s | %s)", item.getHandle(), item.getID(),
                                            sourceCollection.getHandle(), sourceCollection.getID()));
        }

    }

    @Override
    public void mapItem (Context context, Item item, Collection destinationCollection, boolean dryRun)
        throws SQLException, AuthorizeException {
            addItemToCollection(context, item, destinationCollection, dryRun);
    }

    @Override
    public void verifyParams(Context context, String operationMode, String sourceHandle, String destinationHandle,
                             String linkToFile, String pathToFile, boolean dryRun) throws IOException {

        if (!Arrays.asList(OPERATIONS).contains(operationMode)) {
            logCLI(ERROR, "No valid operation mode was given");
        }

        if (operationMode.equals(UNMAPPED) && isBlank(destinationHandle) ) {
                logCLI(ERROR, "No destination handle was given, this is required when the operation mode is " +
                    "set to unmapped");
                System.exit(1);
        }

        if (operationMode.equals(REVERSED)) {
            if (isBlank(destinationHandle) && isNotBlank(sourceHandle)) {
                logCLI(ERROR, "You should also give a destination parameter when giving a " +
                    "source parameter");
                System.exit(1);
            }

            if (isNotBlank(destinationHandle) && isBlank(sourceHandle)) {
                logCLI(ERROR, "You should also give a source parameter when giving a " +
                    "destination parameter");
                System.exit(1);
            }
        }

        if (dryRun) {
            context.setMode(Context.Mode.READ_ONLY);
        }

        switch (FILE_LOCATION) {
            case URL:
                if (isBlank(linkToFile)) {
                    linkToFile = MAPPING_FILE_PATH;
                }
                doesURLResolve(linkToFile);
                break;
            case LOCAL:
                if (isBlank(pathToFile)) {
                    pathToFile = MAPPING_FILE_PATH + File.separator + MAPPING_FILE_NAME;
                }

                File jsonFile = new File(pathToFile);
                if (!substringAfterLast(pathToFile, ".").equals("json") || !jsonFile.exists() || !jsonFile.isFile()) {
                    logCLI(ERROR, String.format("%s did not resolve to a valid .json file. Either put path to valid json in '%s' option, or set configs %s/%s to point to valid json.",
                                                pathToFile, PATH_OPTION_CHAR, MAPPING_FILE_PATH_CFG, MAPPING_FILE_NAME_CFG));
                }
                break;
            default:
                logCLI(ERROR, "The location for the file: " + FILE_LOCATION + " is not valid please pick either " + LOCAL + " or " + URL);
        }
    }


    public void doesURLResolve(String sUrl) throws IOException {
        java.net.URL url = new URL(sUrl);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        int responseCode = connection.getResponseCode();

        if (responseCode < 200 || responseCode > 300) {
            logCLI(ERROR, "The given file path " + url + " is not a valid URL, please give a valid URL" +
                " using the -l parameter or in a configuration file using the " + MAPPING_FILE_PATH_CFG + " " +
                "property");
            System.exit(1);
        }
    }

    @Override
    public Collection resolveCollection(Context context, String collectionID) throws SQLException {
        DSpaceObject dso = handleService.resolveToObject(context, collectionID);

        if (dso == null) {
            try {
                Collection resolvedCollection = collectionService.find(context, UUID.fromString(collectionID));
                if (resolvedCollection == null) {
                    logCLI(ERROR, collectionID + " did not resolve to a valid collection");
                }
                return resolvedCollection;
            } catch (IllegalArgumentException e) {
                logCLI(ERROR, collectionID + " is not a valid UUID or handle");
            }
        }

        else if (dso.getType() != Constants.COLLECTION) {
            logCLI(ERROR, "Handle:" + collectionID + " resolved to a " + dso.getType());
        }

        return (Collection) dso;
    }


    @Override
    public void unmapItem(Context context, Item item, String sourceHandle, String destinationHandle,
                          boolean dryRun) throws SQLException, AuthorizeException, IOException {
        List<Collection> itemCollections = item.getCollections();
        Collection itemOwningCollection = item.getOwningCollection();

        // if source and destination handle are given resolve them to their collections
        // We only want to remove the items originating from the source collections to be removed from the
        // destination collection (they were previously mapped)
        if (isNotBlank(sourceHandle) && isNotBlank(destinationHandle)) {
            resolvedSourceCollection = resolveCollection(context, sourceHandle);
            resolvedDestinationCollection = resolveCollection(context, destinationHandle);

            // If the item is mapped to the collection we want to remove from and that collection is not its owning
            // collection we can go ahead and remove the item from the collection (if the item is not mapped to only
            // that collection which should not be the case but check to be sure)
            if (itemCollections.contains(resolvedDestinationCollection)
                && !resolvedDestinationCollection.equals(itemOwningCollection)
                && item.getCollections().size() > 1) {

                if (!dryRun) {
                    collectionService.removeItem(context, resolvedDestinationCollection, item);
                }

                logCLI("info", String.format("Item (%s | %s) was removed from collection (%s | %s)",
                                             item.getHandle(), item.getID(),
                                             resolvedDestinationCollection.getHandle(), resolvedDestinationCollection.getID()));
            }
        } else {
            removeItemFromAllCollectionsExceptOwning(context, itemCollections, itemOwningCollection, item, dryRun);
        }
    }

    @Override
    public void unmapItem(Context context, Item item, String sourceHandle, boolean dryRun)
        throws SQLException, AuthorizeException, IOException {
        unmapItem(context, item, sourceHandle, null, dryRun);
    }

    public void removeItemFromAllCollectionsExceptOwning(Context context, List<Collection> itemCollections, Collection itemOwningCollection,
                                                         Item item, boolean dryRun) throws SQLException, AuthorizeException, IOException {
        for (Collection collection : itemCollections) {
            if (collection.equals(itemOwningCollection)) {
                logCLI("info", String.format("Current collection (%s | %s) is the item's (%s | %s) owning " +
                                                 "collection, skipping",
                                             collection.getHandle(), collection.getID(),
                                             item.getHandle(), item.getID()));
                continue;
            }

            if (item.getCollections().size() == 1) {
                logCLI("info", String.format("Item (%s | %s) is left in only one collection (%s | %s), we're not " +
                                                 "removing it",
                                             item.getHandle(), item.getID(),
                                             item.getCollections().get(0).getHandle(),
                                             item.getCollections().get(0).getID()));

                if (!itemService.isOwningCollection(item, item.getCollections().get(0))) {
                    logCLI("warn", String.format("Item (%s | %s) is only left in collection (%s | %s), which " +
                                                     "is not its owning collection, this shouldn't be possible",
                                                 item.getHandle(), item.getID(),
                                                 item.getCollections().get(0).getHandle(),
                                                 item.getCollections().get(0).getID()));
                }
                continue;
            }

            if (!dryRun) {
                collectionService.removeItem(context, collection, item);
            }

            logCLI("info", String.format("Item (%s | %s) was removed from collection (%s | %s)",
                                         item.getHandle(), item.getID(),
                                         collection.getHandle(),
                                         collection.getID()));
        }
    }

    @Override
    public void showItemsInCollection(Context context, Collection collection) throws SQLException {
        int itemsCount = itemService.countItems(context, collection);
        System.out.println("#" + itemsCount + " item of collection: " + collection.getHandle() + ": " + collection.getID());
    }

    private void addItemToCollection(Context context, Item item, Collection destinationCollection, boolean dryRun)
        throws SQLException, AuthorizeException {
        if (item.getCollections().contains(destinationCollection)) {
            logCLI(WARN, String.format("Item (%s | %s) was not mapped because it is already in destination " +
                                                "collection (%s | %s),",
                                            item.getHandle(), item.getID(),
                                            destinationCollection.getHandle(),
                                            destinationCollection.getID()));
        }

        else if (!item.getCollections().contains(destinationCollection)) {
            showItemsInCollection(context, destinationCollection);

            logCLI(INFO, String.format("Mapping item (%s | %s) to collection (%s | %s)",
                                         item.getHandle(), item.getID(),
                                         destinationCollection.getHandle(),
                                         destinationCollection.getID()));
            if (!dryRun) {
                collectionService.addItem(context, destinationCollection, item);
            }
        }
    }

    @Override
    public String getContentFromFile(String filepath) throws IOException {
        File jsonFile = new File(filepath);
        return FileUtils.readFileToString(jsonFile);
    }

    @Override
    public Collection getCorrespondingCollection(Context context, GenericCollection col)
        throws SQLException {
        Collection resolvedCollection;
        if (col.getId().getType().equals("handle")) {
            resolvedCollection = (Collection) handleService.resolveToObject(context, col.getId().getValue());
            if (resolvedCollection == null) {
                logCLI(ERROR, "No collection could be resolved with the handle: " + col.getId().getValue());
                System.exit(1);
            }
            return resolvedCollection;
        }
        else if (col.getId().getType().equals("uuid")) {
            resolvedCollection = collectionService.find(context, UUID.fromString(col.getId().getValue()));
            if (resolvedCollection == null) {
                logCLI(ERROR, "No collection could be resolved with the UUID:" + col.getId().getValue());
                System.exit(1);
            }
            return resolvedCollection;
        }
        else {
            logCLI(ERROR, "Collection id type is not set correctly please use \"handle\" or \"uuid\"");
        }
        return null;
    }

    @Override
    public void mapItemsFromJson(Context context, Iterator<Item> items, CuniMapFile mapFile)
        throws SQLException, AuthorizeException, IOException {
        checkMetadataValuesAndConvertToString(context,items, mapFile, MAPPED);
    }

    public List<String> convertMetadataValuesToString(List<MetadataValue> metadataValues) {
        return metadataValues.stream().map(MetadataValue::getValue).collect(Collectors.toList());
    }

    @Override
    public CuniMapFile getMapFileFromLink(String link) throws IOException {
        ObjectMapper objectMapper = new ObjectMapper();
        java.net.URL jsonURL = new URL(link);
        return objectMapper.readValue(jsonURL, CuniMapFile.class);
    }

    @Override
    public CuniMapFile getMapFileFromPath(String path) throws IOException {
        ObjectMapper objectMapper = new ObjectMapper();
        return objectMapper.readValue(getContentFromFile(path), CuniMapFile.class);
    }

    @Override
    public void mapFromParams(Context context, String destinationHandle, String sourceHandle, boolean dryRun) throws SQLException {

        // Destination collection is required when case is unmapped
        resolvedDestinationCollection = resolveCollection(context, destinationHandle);

        // If no source collection is given we want to obtain all items
        if (isBlank(sourceHandle)) {
            totalItems = itemService.countTotal(context);

            // Loop through all of our items in batches
            for (int i = 1; i <= Math.ceil(totalItems / batchSize); i++) {
                itemsToMap = itemService.findAllWithLimitAndOffset(context, batchSize,  offset);
                logCLI(INFO, "***** PROCESSING BATCH:" + i + " *****");

                // Map all items in the current batch
                itemsToMap.forEachRemaining(item -> {
                    try {
                        logCLI(INFO, String.format("Mapping item (%s | %s) ",
                                                                     item.getHandle(), item.getID()));
                        mapItem(context, item, resolvedDestinationCollection, dryRun);
                    } catch (SQLException | AuthorizeException e) {
                        logCLI(ERROR, String.format("Item (%s | %s) " + "could not be " +
                                                                          "mapped for an unknown reason",
                                                                      item.getHandle(), item.getID()));
                        e.printStackTrace();
                    }
                });
                offset += batchSize;
            }
        }

        // If a source collection is given we want to obtain the items inside that collection
        else if (isNotBlank(sourceHandle)) {
            resolvedSourceCollection = resolveCollection(context, sourceHandle);
            totalItems = itemService.countAllItems(context, resolvedSourceCollection);

            for (int i = 1; i <= Math.ceil(totalItems / batchSize); i++) {
                itemsToMap = itemService.findAllByCollection(context, resolvedSourceCollection, batchSize, offset);
                logCLI(INFO, "***** PROCESSING BATCH:" + i + " *****");

                itemsToMap.forEachRemaining((item -> {
                    try {
                        logCLI(INFO, String.format("Mapping item (%s | %s) ", item.getHandle(), item.getID()));
                        mapItem(context, item, resolvedSourceCollection, resolvedDestinationCollection, dryRun);
                    } catch (SQLException | AuthorizeException e) {
                        logCLI(ERROR, String.format("Item (%s | %s) could not be " + "mapped for an unknown reason", item.getHandle(), item.getID()));
                        e.printStackTrace();
                    }
                }));
                offset += batchSize;
            }
        }
    }

    @Override
    public void reverseMapFromParams(Context context, String destinationHandle, String sourceHandle, boolean dryRun) throws SQLException {

        // If no destination and source collection is given we want to obtain all the items
        if (isBlank(destinationHandle) && isBlank(sourceHandle)) {
            totalItems = itemService.countTotal(context);

            // Loop through all of our items in batches
            for (int i = 1; i < Math.ceil(totalItems / batchSize) + 1; i++) {
                itemsToMap = itemService.findAllWithLimitAndOffset(context, batchSize, offset);
                logCLI(INFO, "***** PROCESSING BATCH:" + i + " *****");

                // Reverse map all items in the current batch
                reverseMapItemsInBatch(context, itemsToMap, sourceHandle, destinationHandle, dryRun);
            }
        }

        // If a destination and source collection is given we want to obtain only the items from the
        // destination collection as this is where we will be reverse mapping (removing) items from
        else if (isNotBlank(destinationHandle)) {
            resolvedDestinationCollection =
                resolveCollection(context, destinationHandle);
            resolvedSourceCollection =
                resolveCollection(context, sourceHandle);

            totalItems = itemService.countAllItems(context, resolvedSourceCollection);

            // Loop through all of our items in batches
            for (int i = 1; i <= Math.ceil(totalItems / batchSize); i++) {
                itemsToMap = itemService.findAllByCollection(context, resolvedSourceCollection, batchSize, offset);
                logCLI(INFO, "***** PROCESSING BATCH:" + i + " *****");

                // Reverse map all items in the current batch
                reverseMapItemsInBatch(context, itemsToMap, sourceHandle, destinationHandle, dryRun);
            }
        }
    }

    private void reverseMapItemsInBatch(Context context, Iterator<Item> itemsToMap, String sourceHandle,
                                        String destinationHandle, boolean dryRun) {
        itemsToMap.forEachRemaining(item -> {
            try {
                unmapItem(context, item, sourceHandle, destinationHandle, dryRun);
            } catch (SQLException | AuthorizeException | IOException e) {
                logCLI(ERROR, String.format("Item (%s | %s) could not be mapped for an unknown reason ",
                                                              item.getHandle(), item.getID()));
                e.printStackTrace();
            }
        });
        offset += batchSize;
    }

    @Override
    public void mapFromMappingFile(Context context, String link, String path)
        throws IOException, SQLException, AuthorizeException {
        CuniMapFile cuniMapFile;
        if (isBlank(link) && FILE_LOCATION.equals(URL)) {
            link = MAPPING_FILE_PATH;
            doesURLResolve(link);
        }
        if (isNotBlank(link) && FILE_LOCATION.equals(URL)) {
            doesURLResolve(link);
            cuniMapFile = getMapFileFromLink(link);
        }
        else if (isNotBlank(path)) {
            cuniMapFile = getMapFileFromPath(path);
        } else {
            cuniMapFile = getMapFileFromPath(MAPPING_FILE_PATH + File.separator + MAPPING_FILE_NAME);
        }
        for (SourceCollection col : cuniMapFile.getMapfile().getSource_collections()) {
            Collection collection =  getCorrespondingCollection(context, col);
            mapItemsFromJson(context, itemService.findAllByCollection(context,collection), cuniMapFile);
        }
    }

    @Override
    public void consumerMapFromMappingFile(Context context, String link, String path)
        throws IOException, SQLException, AuthorizeException {
        CuniMapFile cuniMapFile;
        if (isBlank(link) && CONSUMER_FILE_LOCATION.equals(URL)) {
            link = MAPPING_FILE_PATH;
            doesURLResolve(link);
        }
        if (isNotBlank(link) && CONSUMER_FILE_LOCATION.equals(URL)) {
            cuniMapFile = getMapFileFromLink(link);
        }
        else if (isNotBlank(path)) {
            cuniMapFile = getMapFileFromPath(path);
        } else {
            cuniMapFile = getMapFileFromPath(MAPPING_FILE_PATH + File.separator + MAPPING_FILE_NAME);
        }
        for (SourceCollection col : cuniMapFile.getMapfile().getSource_collections()) {
            Collection collection =  getCorrespondingCollection(context, col);
            mapItemsFromJson(context, itemService.findAllByCollection(context,collection), cuniMapFile);
        }
    }

    @Override
    public void reverseMapItemsFromJson(Context context, Iterator<Item> items, CuniMapFile mapFile)
        throws SQLException, AuthorizeException, IOException {
        checkMetadataValuesAndConvertToString(context,items, mapFile, REVERSED_MAPPED);
    }

    @Override
    public void reverseMapFromMappingFile(Context context, String link, String path)
        throws SQLException, IOException, AuthorizeException {
        CuniMapFile cuniMapFile;
        if (isBlank(link) && FILE_LOCATION.equals(URL)) {
            link = MAPPING_FILE_PATH;
            doesURLResolve(link);
        }
        if (isNotBlank(link)) {
            cuniMapFile = getMapFileFromLink(link);
        }
        else if (isNotBlank(path)) {
            cuniMapFile = getMapFileFromPath(path);
        } else {
            cuniMapFile = getMapFileFromPath(MAPPING_FILE_PATH +  File.separator + MAPPING_FILE_NAME);
        }
        for (SourceCollection col : cuniMapFile.getMapfile().getSource_collections()) {
            Collection collection =  getCorrespondingCollection(context, col);
            reverseMapItemsFromJson(context, itemService.findAllByCollection(context,collection), cuniMapFile);
        }
    }

    public void checkMetadataValuesAndConvertToString(Context context, Iterator<Item> items, CuniMapFile mapFile,
                                                      String mapMode)
        throws SQLException, AuthorizeException, IOException {
            while (items.hasNext()) {
                List<MetadataValue> primaryMdFieldValues;
                List<MetadataValue> secondaryMdFieldValues;
                List<String> primaryStringMdFieldValues = new ArrayList<>();
                List<String> secondaryStringMdFieldValues = new ArrayList<>();

                Item item = items.next();

                for (MetadataField mdField :mapFile.getMapfile().getMetadata_fields()) {
                    if (mdField.getField_type().equals("primary")) {
                        primaryMdFieldValues = splitMetadataField(item,mdField.getField_identifier());
                        primaryStringMdFieldValues = convertMetadataValuesToString(primaryMdFieldValues);

                    }

                    if (mdField.getField_type().equals("secondary")) {
                        secondaryMdFieldValues = splitMetadataField(item,mdField.getField_identifier());
                        secondaryStringMdFieldValues = convertMetadataValuesToString(secondaryMdFieldValues);
                    }
                }

                mapOnMetadataValueMatch(context, primaryStringMdFieldValues, secondaryStringMdFieldValues, mapFile,
                                        mapMode, item);
        }
    }

    public List<MetadataValue> splitMetadataField(Item item, String metadataFieldString) {
        String[] metadataFieldParts = metadataFieldString.split("\\.");
        List<MetadataValue> metadataValues = new ArrayList<>();
        if (metadataFieldParts.length == 2) {
            metadataValues = itemService.getMetadata(item, metadataFieldParts[0],
                                                                         metadataFieldParts[1], Item.ANY, Item.ANY);
        }
        if (metadataFieldParts.length == 3) {
            metadataValues = itemService.getMetadata(item, metadataFieldParts[0],
                                                                         metadataFieldParts[1], metadataFieldParts[2],
                                                                         Item.ANY);
        }
        return metadataValues;
    }

    public void mapOnMetadataValueMatch(Context context,
                                        List<String> primaryStringMdFieldValues,
                                        List<String> secondaryStringMdFieldValues,
                                        CuniMapFile mapFile, String mapMode, Item item)
        throws SQLException, AuthorizeException, IOException {
            if (!primaryStringMdFieldValues.isEmpty() || !secondaryStringMdFieldValues.isEmpty()) {
                for (MappingRecord mappingRecord: mapFile.getMapfile().getMapping_records()) {
                    if (primaryStringMdFieldValues.contains(mappingRecord.getMetadata_value())
                    || secondaryStringMdFieldValues.contains(mappingRecord.getMetadata_value())) {
                        for (TargetCollection col : mappingRecord.getTarget_collections()) {
                            Collection correspondingCol = getCorrespondingCollection(context, col);
                            if (mapMode.equals(REVERSED_MAPPED)) {
                                unmapItem(context, item, correspondingCol.getHandle(),false);
                            }
                            if (mapMode.equals(MAPPED)) {
                                mapItem(context, item, correspondingCol,false);
                            }
                        }
                    }
                }
            }
        }
}

