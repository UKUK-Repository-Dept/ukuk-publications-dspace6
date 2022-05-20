package com.atmire.itemmapper.service;

import static com.atmire.itemmapper.ParametrizedItemMappingScript.FILE_LOCATION;
import static com.atmire.itemmapper.ParametrizedItemMappingScript.LOCAL;
import static com.atmire.itemmapper.ParametrizedItemMappingScript.OPERATIONS;
import static com.atmire.itemmapper.ParametrizedItemMappingScript.REVERSED;
import static com.atmire.itemmapper.ParametrizedItemMappingScript.UNMAPPED;
import static com.atmire.itemmapper.ParametrizedItemMappingScript.URL;
import static org.apache.commons.lang3.StringUtils.isBlank;
import static org.apache.commons.lang3.StringUtils.isNotBlank;
import static org.apache.commons.lang3.StringUtils.substringAfterLast;

import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.UUID;

import com.atmire.itemmapper.ParametrizedItemMappingScript;
import com.atmire.itemmapper.model.CuniMapFile;
import com.atmire.itemmapper.model.GenericCollection;
import com.atmire.itemmapper.model.MappingRecord;
import com.atmire.itemmapper.model.MetadataField;
import com.atmire.itemmapper.model.TargetCollection;
import org.apache.commons.io.FileUtils;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Collection;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
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

    public static final String MAPPING_FILE_NAME = configurationService.getProperty("mapping.file.name");
    public static final String MAPPING_FILE_PATH = configurationService.getProperty("mapping.file.path");
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
            verifyValidAndMap(context, item, destinationCollection, dryRun);

        } else {
            logCLI("warning", String.format("Item (%s | %s) was not mapped because it is not owned by " +
                                                "collection (%s | %s)", item.getHandle(), item.getID(),
                                            sourceCollection.getHandle(), sourceCollection.getID()));
        }

    }

    @Override
    public void mapItem (Context context, Item item, Collection destinationCollection, boolean dryRun)
        throws SQLException, AuthorizeException {
            verifyValidAndMap(context, item, destinationCollection, dryRun);
    }

    @Override
    public void verifyParams(Context context, String operationMode, String sourceHandle, String destinationHandle,
                             String linkToFile, String pathToFile, boolean dryRun) {

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
                    logCLI(ERROR, "You should give a value for the link (-l) parameter when the" +
                        "file location property is set to URL");
                    System.exit(1);
                }
                break;
            case LOCAL:
                if (isBlank(pathToFile)) {
                    pathToFile = MAPPING_FILE_PATH + MAPPING_FILE_NAME;
                }

                if (!substringAfterLast(pathToFile, ".").equals("json")) {
                    logCLI(ERROR, pathToFile + " did not resolve to a valid .json file");
                }
                break;
            default:
                logCLI(ERROR, "The location for the file: " + FILE_LOCATION + " is not valid please pick either local or url");
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
    public void reverseMappedItem(Context context, Item item, String sourceHandle, String destinationHandle,
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
            for (Collection collection : itemCollections) {
                if (collection.equals(itemOwningCollection)) {
                    logCLI("info", "Current collection is the item's owning collection, skipping");
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

                logCLI("info", String.format("Item (%s | %s) was removed from collection (%s | %s),",
                                             item.getHandle(), item.getID(),
                                             collection.getHandle(),
                                             collection.getID()));
            }
        }
    }

    @Override
    public void showItemsInCollection(Context context, Collection collection) throws SQLException {
        int itemsCount = itemService.countItems(context, collection);
        System.out.println("#" + itemsCount + " item of collection: " + collection.getHandle() + ": " + collection.getID());
    }

    private void verifyValidAndMap(Context context, Item item, Collection destinationCollection, boolean dryRun)
        throws SQLException, AuthorizeException {
        if (item.getCollections().contains(destinationCollection)) {
            logCLI("warning", String.format("Item (%s | %s) was not mapped because it is already in destination " +
                                                "collection (%s | %s),",
                                            item.getHandle(), item.getID(),
                                            destinationCollection.getHandle(),
                                            destinationCollection.getID()));
        }

        else if (!item.getCollections().contains(destinationCollection)) {
            showItemsInCollection(context, destinationCollection);

            logCLI("info", String.format("Mapping item (%s | %s) to collection (%s | %s)",
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
        String content = FileUtils.readFileToString(jsonFile);
        return content;
    }

    @Override
    public Collection getCorrespondingCollection(Context context, GenericCollection col)
        throws SQLException {
        if (col.getId().getType().equals("handle")) {
            return (Collection) handleService.resolveToObject(context, col.getId().getValue());
        }
        else if (col.getId().getType().equals("uuid")) {
            return collectionService.find(context, UUID.fromString(col.getId().getValue()));
        }
        else {
            logCLI(ERROR, "Collection id type is not set correctly please use \"handle\" or \"uuid\"");
        }
        return null;
    }

    @Override
    public void mapItemsFromJson(Context context, Iterator<Item> items, CuniMapFile mapFile)
        throws SQLException, AuthorizeException {
        String primaryMdFieldValue = "";
        String secondaryMdFieldValue = "";

        while (items.hasNext()) {
            Item item = items.next();
            for (MetadataField mdField :mapFile.getMapfile().getMetadata_fields()) {
                if (mdField.getField_type().equals("primary")) {
                    primaryMdFieldValue = mdField.getField_identifier();
                }

                if (mdField.getField_type().equals("secondary")) {
                    secondaryMdFieldValue = mdField.getField_identifier();
                }
            }

            for (MappingRecord mappingRecord: mapFile.getMapfile().getMapping_records()) {
                if (primaryMdFieldValue.equals(mappingRecord.getMetadata_value()) ||
                    secondaryMdFieldValue.equals(mappingRecord.getMetadata_value())) {
                    for (TargetCollection col : mappingRecord.getTarget_collections()) {
                        Collection correspondingCol = getCorrespondingCollection(context, col);
                        mapItem(context, item, correspondingCol, false);
                    }
                }
            }
        }
    }
}
