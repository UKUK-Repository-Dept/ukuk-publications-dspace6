package com.atmire.itemmapper.service;

import static com.atmire.itemmapper.ItemMapperConsumer.CONSUMER_MAPPING_FILE_PATH;
import static com.atmire.itemmapper.ItemMapperConsumer.CONSUMER_MAPPING_FILE_PATH_CFG;
import static com.atmire.itemmapper.ItemMapperConsumer.FULL_PATH_TO_FILE;
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
import java.net.MalformedURLException;
import java.net.URL;
import java.net.UnknownHostException;
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
import org.apache.commons.lang.StringUtils;
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

    List<Collection> resolvedDestinationCollections;
    List<Collection> resolvedSourceCollections;
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
    public static final String DRY_RUN_PREFIX = "( DRY RUN )";
    public static final String PROCESSING_COLLECTION_CHAR = " === ";
    public static final String PROCESSING_COLLECTION_HEADER = "PROCESSING SOURCE COLLECTION: ";

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
    public void logCLI(String level, String message, boolean dryRun) {
        if (!dryRun) {
            logCLI(level, message);
        } else {
            message = DRY_RUN_PREFIX + " " + message;
            logCLI(level, message);
        }
    }

    @Override
    public void mapItem (Context context, Item item, Collection sourceCollection,
                         Collection destinationCollection,
                         boolean dryRun)
        throws SQLException, AuthorizeException {

        if (itemService.isOwningCollection(item, sourceCollection)) {
            addItemToCollection(context, item, destinationCollection, dryRun);

        } else {
            logCLI(WARN, String.format("Item (%s | %s) was not mapped because it is not owned by " +
                                           "collection (%s | %s)", item.getHandle(), item.getID(),
                                       sourceCollection.getHandle(), sourceCollection.getID()), dryRun);
        }

    }

    @Override
    public void mapItem (Context context, Item item, Collection destinationCollection, boolean dryRun)
        throws SQLException, AuthorizeException {
        addItemToCollection(context, item, destinationCollection, dryRun);
    }

    @Override
    public boolean verifyParams(Context context, String operationMode, List<String> sourceHandle,
                                List<String> destinationHandle, String linkToFile,
                                String pathToFile, boolean dryRun) throws IOException {

        if (!Arrays.asList(OPERATIONS).contains(operationMode)) {
            logCLI(ERROR, "No valid operation mode was given", dryRun);
            return false;
        }

        if (operationMode.equals(UNMAPPED) && isBlankList(destinationHandle) ) {
                logCLI(ERROR, "No destination handle was given, this is required when the operation mode is " +
                    "set to unmapped", dryRun);
                return false;
        }

        if (operationMode.equals(REVERSED)) {
            if (isBlankList(destinationHandle) && !sourceHandle.isEmpty()) {
                logCLI(ERROR, "You should also give a destination parameter when giving a " +
                    "source parameter", dryRun);
                return false;
            }
        }

        if (dryRun) {
            context.setMode(Context.Mode.READ_ONLY);
        }

        if (operationMode.equals(MAPPED) || operationMode.equals(REVERSED_MAPPED)) {
            if (FILE_LOCATION.equals(URL) || isNotBlank(linkToFile)) {
                if (isBlank(linkToFile)) {
                    linkToFile = MAPPING_FILE_PATH;
                };
                if (!doesURLResolve(linkToFile)) {
                    return false;
                }
            }

            else if (FILE_LOCATION.equals(LOCAL) || isNotBlank(pathToFile)) {
                if (isBlank(pathToFile)) {
                    pathToFile = MAPPING_FILE_PATH + File.separator + MAPPING_FILE_NAME;
                }
                if (!isValidJSONFile(pathToFile)) {
                    return false;
                }
            }

            else {
                logCLI(ERROR, "No valid JSON data could be resolved please provide either a link to a JSON file " +
                    "or a path to a JSON file. Using either properties in item-mapping.cfg or the command line ", dryRun);
                return false;
            }
        }
        return true;
    }

    @Override
    public boolean isValidJSONFile(String pathToFile) throws IOException {
        File jsonFile = new File(pathToFile);
        if (!substringAfterLast(pathToFile, ".").equals("json") || !jsonFile.exists() || !jsonFile.isFile()) {
            logCLI(ERROR, String.format("%s did not resolve to a valid .json file. Either put path to valid json in '%s' option, or set configs %s/%s to point to valid json.",
                                        pathToFile, PATH_OPTION_CHAR, MAPPING_FILE_PATH_CFG, MAPPING_FILE_NAME_CFG));
            return false;
        }
        return true;
    }

    @Override
    public boolean doesURLResolve(String sUrl) throws IOException {
        java.net.URL url = new URL(sUrl);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        int responseCode = connection.getResponseCode();

        if (responseCode < 200 || responseCode > 300) {
            logCLI(ERROR, "The given file path " + url + " is not a valid URL, please give a valid URL" +
                " using the -l parameter or in a configuration file using the " + MAPPING_FILE_PATH_CFG + " " +
                "property");
            return false;
        }
        return true;
    }

    @Override
    public List<Collection> resolveCollections(Context context, List<String> collectionIDsList) throws SQLException {
        List<Collection> collections = new ArrayList<>();
        for (String id: collectionIDsList) {
            DSpaceObject dso = handleService.resolveToObject(context, id);

            if (dso == null) {
                try {
                    Collection resolvedCollection = collectionService.find(context, UUID.fromString(id));
                    if (resolvedCollection == null) {
                        logCLI(ERROR, id + " did not resolve to a valid collection");
                    }
                    collections.add(resolvedCollection);
                } catch (IllegalArgumentException e) {
                    logCLI(ERROR, id + " is not a valid UUID or handle");
                }
            }

            else if (dso.getType() != Constants.COLLECTION) {
                logCLI(ERROR, "Handle:" + id + " resolved to a " + dso.getType());
            }

            collections.add((Collection) dso);
        }
        return collections;
    }


    @Override
    public void unmapItem(Context context, Item item, List<String> sourceHandle, List<String> destinationHandle,
                          boolean dryRun) throws SQLException, AuthorizeException, IOException {
        List<Collection> itemCollections = item.getCollections();
        Collection itemOwningCollection = item.getOwningCollection();

        // if source and destination handle are given resolve them to their collections
        // We only want to remove the items originating from the source collections to be removed from the
        // destination collection (they were previously mapped)
        if (isNotBlankList(destinationHandle)) {
            if (isNotBlankList(sourceHandle)) {
                resolvedSourceCollections = resolveCollections(context, sourceHandle);
            }
            resolvedDestinationCollections = resolveCollections(context, destinationHandle);

            // If the item is mapped to the collection we want to remove from and that collection is not its owning
            // collection we can go ahead and remove the item from the collection (if the item is not mapped to only
            // that collection which should not be the case but check to be sure)
            for (Collection destinationCollection: resolvedDestinationCollections) {
                if (itemCollections.contains(destinationCollection)
                    && !destinationCollection.equals(itemOwningCollection)
                    && item.getCollections().size() > 1) {

                    if (!dryRun) {
                        collectionService.removeItem(context, destinationCollection, item);
                    }

                    logCLI("info", String.format("Item (%s | %s) was removed from collection (%s | %s)",
                                                 item.getHandle(), item.getID(),
                                                 destinationCollection.getHandle(), destinationCollection.getID()), dryRun);
                }
            }
        } else {
            removeItemFromAllCollectionsExceptOwning(context, itemCollections, itemOwningCollection, item, dryRun);
        }
    }

    @Override
    public void unmapItem(Context context, Item item, List<String> sourceHandle, boolean dryRun)
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
                                             item.getHandle(), item.getID()), dryRun);
                continue;
            }

            if (item.getCollections().size() == 1) {
                logCLI("info", String.format("Item (%s | %s) is left in only one collection (%s | %s), we're not " +
                                                 "removing it",
                                             item.getHandle(), item.getID(),
                                             item.getCollections().get(0).getHandle(),
                                             item.getCollections().get(0).getID()), dryRun);

                if (!itemService.isOwningCollection(item, item.getCollections().get(0))) {
                    logCLI("warn", String.format("Item (%s | %s) is only left in collection (%s | %s), which " +
                                                     "is not its owning collection, this shouldn't be possible",
                                                 item.getHandle(), item.getID(),
                                                 item.getCollections().get(0).getHandle(),
                                                 item.getCollections().get(0).getID()), dryRun);
                }
                continue;
            }

            if (!dryRun) {
                collectionService.removeItem(context, collection, item);
            }

            logCLI("info", String.format("Item (%s | %s) was removed from collection (%s | %s)",
                                         item.getHandle(), item.getID(),
                                         collection.getHandle(),
                                         collection.getID()), dryRun);
        }
    }

    @Override
    public void showItemsInCollection(Context context, Item item, Collection collection) throws SQLException {
        if (collection != null) {
            int itemsCount = itemService.countItems(context, collection);
            System.out.println("#" + itemsCount + " item " + item.getHandle() + " | " + item.getID() + " from" +
                                   " source collection " + collection.getHandle() + " | " + collection.getID());
        }
    }

    private void addItemToCollection(Context context, Item item, Collection destinationCollection, boolean dryRun)
        throws SQLException, AuthorizeException {
        if (item.getCollections().contains(destinationCollection)) {
            logCLI(WARN, String.format("Item (%s | %s) was not mapped because it is already in destination " +
                                                "collection (%s | %s),",
                                            item.getHandle(), item.getID(),
                                            destinationCollection.getHandle(),
                                            destinationCollection.getID()), dryRun);
        }

        else if (!item.getCollections().contains(destinationCollection)) {
            showItemsInCollection(context, item, item.getOwningCollection());

            logCLI(INFO, String.format("Mapping item (%s | %s) to collection (%s | %s)",
                                         item.getHandle(), item.getID(),
                                         destinationCollection.getHandle(),
                                         destinationCollection.getID()), dryRun);
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
                logCLI(ERROR, "Collection ( " + col.getName_en() + " | " + col.getName_cs()
                    + " ) could not be resolved with the " + "handle: " + col.getId().getValue());
            }
            return resolvedCollection;
        }
        else if (col.getId().getType().equals("uuid")) {
            resolvedCollection = collectionService.find(context, UUID.fromString(col.getId().getValue()));
            if (resolvedCollection == null) {
                logCLI(ERROR, "No collection could be resolved with the UUID:" + col.getId().getValue());
                return null;
            }
            return resolvedCollection;
        }
        else {
            logCLI(ERROR, "Collection id type is not set correctly please use \"handle\" or \"uuid\"");
        }
        return null;
    }

    @Override
    public void mapItemsFromJson(Context context, Iterator<Item> items, CuniMapFile mapFile, boolean dryRun,
                                 Collection collection)
        throws SQLException, AuthorizeException, IOException {
        logCLI(INFO,
               PROCESSING_COLLECTION_CHAR + PROCESSING_COLLECTION_HEADER + collection.getName() + " " + collection.getHandle() + " | "
            + collection.getID() + PROCESSING_COLLECTION_CHAR, dryRun);
        checkMetadataValuesAndConvertToString(context,items, mapFile, MAPPED, dryRun);
    }

    public List<String> convertMetadataValuesToString(List<MetadataValue> metadataValues) {
        return metadataValues.stream().map(MetadataValue::getValue).collect(Collectors.toList());
    }

    @Override
    public CuniMapFile getMapFileFromLink(String link) throws IOException {
        ObjectMapper objectMapper = new ObjectMapper();
        if (!doesURLResolve(link)) {
            return null;
        }
        java.net.URL jsonURL = new URL(link);
        return objectMapper.readValue(jsonURL, CuniMapFile.class);
    }

    @Override
    public CuniMapFile getMapFileFromPath(String path) throws IOException {
        ObjectMapper objectMapper = new ObjectMapper();
        return objectMapper.readValue(getContentFromFile(path), CuniMapFile.class);
    }

    @Override
    public void mapFromParams(Context context, List<String> destinationHandle, List<String> sourceHandle, boolean dryRun) throws SQLException {

        // Destination collection is required when case is unmapped
        resolvedDestinationCollections = resolveCollections(context, destinationHandle);

        // If no source collections are given we want to obtain all items
        if (isBlankList(sourceHandle)) {
            totalItems = itemService.countTotal(context);

            // Loop through all of our items in batches
            for (int i = 1; i <= Math.ceil(totalItems / batchSize); i++) {
                itemsToMap = itemService.findAllWithLimitAndOffset(context, batchSize,  offset);
                logCLI(INFO, "***** PROCESSING BATCH: " + i + " *****", dryRun);

                // Map all items in the current batch
                itemsToMap.forEachRemaining(item -> {
                    try {
                        for (Collection destinationCollection: resolvedDestinationCollections) {
                            mapItem(context, item, destinationCollection, dryRun);
                        }
                    } catch (SQLException | AuthorizeException e) {
                        logCLI(ERROR, String.format("Item (%s | %s) " + "could not be " +
                                                                          "mapped for an unknown reason",
                                                                      item.getHandle(), item.getID()), dryRun);
                        log.error(e.getMessage(), e);
                    }
                });
                offset += batchSize;
            }
        }

        // If a source collection is given we want to obtain the items inside that collection
        else if (isNotBlankList(sourceHandle)) {
            resolvedSourceCollections = resolveCollections(context, sourceHandle);
            for (Collection sourceCollection: resolvedSourceCollections)
            {
                logCLI(INFO,
                       PROCESSING_COLLECTION_CHAR + PROCESSING_COLLECTION_HEADER + sourceCollection.getName() + " " + sourceCollection.getHandle() + " | "
                    + sourceCollection.getID() + PROCESSING_COLLECTION_CHAR, dryRun);
                offset = 0;
                totalItems = itemService.countAllItems(context, sourceCollection);
                for (int i = 1; i <= Math.ceil(totalItems / batchSize); i++) {
                    itemsToMap = itemService.findAllByCollection(context, sourceCollection, batchSize, offset);
                    logCLI(INFO, "***** PROCESSING BATCH: " + i + " *****", dryRun);

                    itemsToMap.forEachRemaining((item -> {
                        try {
                            logCLI(INFO, String.format("Mapping item (%s | %s) ", item.getHandle(), item.getID()), dryRun);
                            for (Collection destinationCollection: resolvedDestinationCollections) {
                                mapItem(context, item, sourceCollection, destinationCollection, dryRun);
                            }
                        } catch (SQLException | AuthorizeException e) {
                            logCLI(ERROR, String.format("Item (%s | %s) could not be " + "mapped for an unknown " +
                                                            "reason", item.getHandle(), item.getID()), dryRun);
                            log.error(e.getMessage(), e);
                        }
                    }));
                    offset += batchSize;
                }
            }
        }
    }

    @Override
    public void reverseMapFromParams(Context context, List<String> destinationHandle, List<String> sourceHandle, boolean dryRun) throws SQLException {

        // If no destination and source collection is given we want to obtain all the items
        if (isBlankList(destinationHandle) && isBlankList(sourceHandle)) {
            totalItems = itemService.countTotal(context);

            // Loop through all of our items in batches
            for (int i = 1; i < Math.ceil(totalItems / batchSize) + 1; i++) {
                itemsToMap = itemService.findAllWithLimitAndOffset(context, batchSize, offset);
                logCLI(INFO, "***** PROCESSING BATCH: " + i + " *****", dryRun);

                // Reverse map all items in the current batch
                reverseMapItemsInBatch(context, itemsToMap, sourceHandle, destinationHandle, dryRun);
            }
        }

        // If only destination collection(s) is given we want to remove all mappings from that collection(s).
        if (isBlankList(sourceHandle) && isNotBlankList(destinationHandle)) {
            resolvedDestinationCollections = resolveCollections(context, destinationHandle);
            for (Collection destinationCollection: resolvedDestinationCollections) {
                logCLI(INFO, PROCESSING_COLLECTION_CHAR + PROCESSING_COLLECTION_HEADER + destinationCollection.getName() + " " + destinationCollection.getHandle() + " | "
                    + destinationCollection.getID() + PROCESSING_COLLECTION_CHAR, dryRun);
                offset = 0;
                totalItems = itemService.countAllItems(context, destinationCollection);

                // Loop through all of our items in batches
                for (int i = 1; i <= Math.ceil(totalItems / batchSize); i++) {
                    itemsToMap = itemService.findAllByCollection(context, destinationCollection, batchSize, offset);
                    logCLI(INFO, "***** PROCESSING BATCH: " + i + " *****", dryRun);

                    // Reverse map all items in the current batch
                    reverseMapItemsInBatch(context, itemsToMap, sourceHandle, destinationHandle, dryRun);
                }
            }
        }

        // If a destination and source collection is given we want to obtain only the items from the
        // destination collection as this is where we will be reverse mapping (removing) items from
        else if (isNotBlankList(destinationHandle)) {
            resolvedDestinationCollections = resolveCollections(context, destinationHandle);
            resolvedSourceCollections = resolveCollections(context, sourceHandle);

            for (Collection sourceCollection: resolvedSourceCollections) {
                logCLI(INFO,
                       PROCESSING_COLLECTION_CHAR + PROCESSING_COLLECTION_HEADER + sourceCollection.getName() + " " + sourceCollection.getHandle() + " | "
                    + sourceCollection.getID() + PROCESSING_COLLECTION_CHAR, dryRun);
                offset = 0;
                totalItems = itemService.countAllItems(context, sourceCollection);

                // Loop through all of our items in batches
                for (int i = 1; i <= Math.ceil(totalItems / batchSize); i++) {
                    itemsToMap = itemService.findAllByCollection(context, sourceCollection, batchSize, offset);
                    logCLI(INFO, "***** PROCESSING BATCH: " + i + " *****", dryRun);

                    // Reverse map all items in the current batch
                    reverseMapItemsInBatch(context, itemsToMap, sourceHandle, destinationHandle, dryRun);
                }
            }
        }
    }

    @Override
    public void reverseMapItemsInBatch(Context context, Iterator<Item> itemsToMap, List<String> sourceHandle,
                                       List<String> destinationHandle, boolean dryRun) {
        itemsToMap.forEachRemaining(item -> {
            try {
                unmapItem(context, item, sourceHandle, destinationHandle, dryRun);
            } catch (SQLException | AuthorizeException | IOException e) {
                logCLI(ERROR, String.format("Item (%s | %s) could not be mapped for an unknown reason ",
                                                              item.getHandle(), item.getID()), dryRun);
                log.error(e.getMessage(), e);
            }
        });
        offset += batchSize;
    }

    @Override
    public void mapFromMappingFile(Context context, List<String> sourceCol, String link, String path, boolean dryRun)
        throws IOException, SQLException, AuthorizeException {
        CuniMapFile cuniMapFile;
        if (isBlank(link) && isBlank(path) && FILE_LOCATION.equals(URL)) {
            link = MAPPING_FILE_PATH;
        }
        if (isNotBlank(link)) {
            cuniMapFile = getMapFileFromLink(link);
            if (cuniMapFile == null) {
                return;
            }
        }
        else if (isNotBlank(path)) {
            cuniMapFile = getMapFileFromPath(path);
        } else {
            cuniMapFile = getMapFileFromPath(MAPPING_FILE_PATH + File.separator + MAPPING_FILE_NAME);
        }

        if (isNotBlankList(sourceCol)) {
            resolvedSourceCollections = resolveCollections(context, sourceCol);
            for (Collection sourceCollection: resolvedSourceCollections) {
                mapItemsFromJson(context, itemService.findAllByCollection(context, sourceCollection), cuniMapFile,
                                 dryRun, sourceCollection);
            }
        }
        else if (cuniMapFile.getMapfile().getSource_collections() == null ||
                 cuniMapFile.getMapfile().getSource_collections().isEmpty()) {
            logCLI(WARN, "No source collections found in mapping file and no -s parameter was given." +
                          " Mapping will be performed on all items in the repository.", dryRun);
            List<Collection> collections = collectionService.findAll(context);
            for (Collection collection : collections) {
                mapItemsFromJson(context, itemService.findAllByCollection(context, collection), cuniMapFile, dryRun, collection);
            }
        } else {
            for (SourceCollection col : cuniMapFile.getMapfile().getSource_collections()) {
                Collection collection = getCorrespondingCollection(context, col);
                mapItemsFromJson(context, itemService.findAllByCollection(context,collection), cuniMapFile, dryRun,
                                 collection);
            }
        }

    }

    @Override
    public void reverseMapItemsFromJson(Context context, Iterator<Item> items, CuniMapFile mapFile, boolean dryRun,
                                        Collection collection)
        throws SQLException, AuthorizeException, IOException {
        logCLI(INFO,
               PROCESSING_COLLECTION_CHAR + PROCESSING_COLLECTION_HEADER + collection.getName() + " " + collection.getHandle() + " | "
            + collection.getID() + PROCESSING_COLLECTION_CHAR, dryRun);
        checkMetadataValuesAndConvertToString(context,items, mapFile, REVERSED_MAPPED, dryRun);
    }

    @Override
    public void reverseMapFromMappingFile(Context context, List<String> sourceCol, String link, String path, boolean dryRun)
        throws SQLException, IOException, AuthorizeException {
        CuniMapFile cuniMapFile;
        if (isBlank(link) && isBlank(path) && FILE_LOCATION.equals(URL)) {
            link = MAPPING_FILE_PATH;
            if (!doesURLResolve(link)) {
                return;
            }
        }
        if (isNotBlank(link)) {
            cuniMapFile = getMapFileFromLink(link);
            if (cuniMapFile == null) {
                return;
            }
        }
        else if (isNotBlank(path)) {
            cuniMapFile = getMapFileFromPath(path);
        } else {
            cuniMapFile = getMapFileFromPath(MAPPING_FILE_PATH +  File.separator + MAPPING_FILE_NAME);
        }

        if (isNotBlankList(sourceCol)) {
            resolvedSourceCollections = resolveCollections(context, sourceCol);
            for (Collection sourceCollection: resolvedSourceCollections) {
                logCLI(INFO,
                       PROCESSING_COLLECTION_CHAR + PROCESSING_COLLECTION_HEADER + sourceCollection.getName() + " " + sourceCollection.getHandle() + " | "
                    + sourceCollection.getID() + PROCESSING_COLLECTION_CHAR, dryRun);
                reverseMapItemsFromJson(context, itemService.findAllByCollection(context, sourceCollection),
                                        cuniMapFile, dryRun, sourceCollection);
            }
        }

       else if (cuniMapFile.getMapfile().getSource_collections() == null ||
                cuniMapFile.getMapfile().getSource_collections().isEmpty()) {
            logCLI(WARN, "No source collections found in mapping file and no -s parameter was given." +
                " Mapping will be performed on all items in the repository.", dryRun);
            List<Collection> collections = collectionService.findAll(context);
            for (Collection collection : collections) {
                reverseMapItemsFromJson(context, itemService.findAllByCollection(context, collection), cuniMapFile,
                                     dryRun, collection);
            }
        } else {
            for (SourceCollection col : cuniMapFile.getMapfile().getSource_collections()) {
                Collection collection =  getCorrespondingCollection(context, col);
                reverseMapItemsFromJson(context, itemService.findAllByCollection(context,collection), cuniMapFile,
                                        dryRun, collection);
            }
        }
    }

    @Override
    public void checkMetadataValuesAndConvertToString(Context context, Iterator<Item> items, CuniMapFile mapFile,
                                                      String mapMode, boolean dryRun)
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
                                        mapMode, item, dryRun);
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
                                        CuniMapFile mapFile, String mapMode,
                                        Item item, boolean dryRun)
        throws SQLException, AuthorizeException, IOException {
            if (!primaryStringMdFieldValues.isEmpty() || !secondaryStringMdFieldValues.isEmpty()) {
                for (MappingRecord mappingRecord: mapFile.getMapfile().getMapping_records()) {
                    if (primaryStringMdFieldValues.contains(mappingRecord.getMetadata_value())
                    || secondaryStringMdFieldValues.contains(mappingRecord.getMetadata_value())) {
                        for (TargetCollection col : mappingRecord.getTarget_collections()) {
                            Collection correspondingCol = getCorrespondingCollection(context, col);
                            List<String> handles = new ArrayList<>();
                            handles.add(correspondingCol.getHandle());
                            if (mapMode.equals(REVERSED_MAPPED)) {
                                unmapItem(context, item, handles, dryRun);
                            }
                            if (mapMode.equals(MAPPED)) {
                                mapItem(context, item, correspondingCol, dryRun);
                            }
                        }
                    }
                }
            }
        }

    @Override
    public void addItemToListIfInSourceCollection(Context ctx, Item item, CuniMapFile cuniMapFile,
                                                  List<Item> itemList) throws SQLException {

        for (SourceCollection col : cuniMapFile.getMapfile().getSource_collections()) {
            Collection collection =  getCorrespondingCollection(ctx, col);
            if (collection.getID() == item.getOwningCollection().getID()) {
                itemList.add(item);
            }
        }
    }

    @Override
    public boolean doesFileExist() {
        File jsonFile = new File(FULL_PATH_TO_FILE);
        return substringAfterLast(FULL_PATH_TO_FILE, ".").equals("json") && jsonFile.exists() && jsonFile.isFile();
    }

    @Override
    public boolean isLinkValid() throws IOException {
        try {
            java.net.URL url = new URL(CONSUMER_MAPPING_FILE_PATH);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            int responseCode = connection.getResponseCode();
            return responseCode >= 200 && responseCode <= 300;
        } catch (UnknownHostException | MalformedURLException e) {
            log.error("Invalid URL supplied at: " + CONSUMER_MAPPING_FILE_PATH_CFG + ": " + CONSUMER_MAPPING_FILE_PATH);
            return false;
        }
    }

    public boolean isBlankList(List<String> list) {
        return list == null || list.isEmpty();
    }

    public boolean isNotBlankList(List<String> list) {
        return list != null && !list.isEmpty();
    }
}

