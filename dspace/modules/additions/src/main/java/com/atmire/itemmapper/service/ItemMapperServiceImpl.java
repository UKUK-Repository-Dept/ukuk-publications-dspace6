package com.atmire.itemmapper.service;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.UUID;

import com.atmire.itemmapper.ParametrizedItemMappingScript;
import org.apache.commons.lang3.StringUtils;
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

public class ItemMapperServiceImpl implements ItemMapperService {

    private static final Logger log = LogManager.getLogger(ParametrizedItemMappingScript.class);
    ItemService itemService = ContentServiceFactory.getInstance().getItemService();
    CollectionService collectionService = ContentServiceFactory.getInstance().getCollectionService();
    HandleService handleService = HandleServiceFactory.getInstance().getHandleService();


    Collection resolvedSourceCollection;
    Collection resolvedDestinationCollection;

    @Override
    public void logCLI(String level, String message) {
        System.out.println(level.toUpperCase() + ": " + message);
        switch (level) {
            case "info":
                log.info(message);
                break;
            case "error":
                log.error(message);
                break;
            case "warn":
                log.warn(message);
                break;
        }
    }

    @Override
    public void mapItem (Context context, Item item, Collection sourceCollection, Collection destinationCollection,
                         boolean dryRun)
        throws SQLException, AuthorizeException {

        if (itemService.isOwningCollection(item, sourceCollection)) {
            verifyValidAndMap(context, item, destinationCollection, dryRun);

        } else {
            logCLI("warning", "Item with UUID:" + item.getID() +
                "not mapped because it is not owned by collection with UUID: " + sourceCollection.getID());
        }

    }

    @Override
    public void mapItem (Context context, Item item, Collection destinationCollection, boolean dryRun)
        throws SQLException, AuthorizeException {
            verifyValidAndMap(context, item, destinationCollection, dryRun);
    }

    @Override
    public void verifyParams(Context context, String operationMode, String sourceHandle, String destinationHandle,
                             boolean dryRun) throws SQLException {
        switch (operationMode) {
            case "unmapped":
            case "mapped":
            case "reversed":
            case "reverse-mapped":
                break;
            default:
                logCLI("error", "No valid operation mode was given");
        }

        if (operationMode.equals("unmapped")) {
            if (StringUtils.isBlank(destinationHandle)) {
                logCLI("error", "No destination handle was given, this is required when the operation mode is " +
                    "set to unmapped");
                System.exit(1);
            }
        }

        if (operationMode.equals("reversed")) {
            if (StringUtils.isBlank(destinationHandle) && StringUtils.isNotBlank(sourceHandle)) {
                logCLI("error", "You should also give a destination parameter when giving a " +
                    "source parameter");
                System.exit(1);
            }

            if (StringUtils.isNotBlank(destinationHandle) && StringUtils.isBlank(sourceHandle)) {
                logCLI("error", "You should also give a source parameter when giving a " +
                    "destination parameter");
                System.exit(1);
            }
        }

        if (dryRun) {
            context.setMode(Context.Mode.READ_ONLY);
        }
    }

    @Override
    public Collection resolveCollection(Context context, String collectionID) throws SQLException {
        DSpaceObject dso = handleService.resolveToObject(context, collectionID);

        if (dso == null) {
            try {
                Collection resolvedCollection = collectionService.find(context, UUID.fromString(collectionID));
                if (resolvedCollection == null) {
                    logCLI("error", collectionID + " did not resolve to a valid collection");
                }
            } catch (IllegalArgumentException e) {
                logCLI("error", collectionID + " is not a valid UUID or handle");
            }
        }

        else if (dso.getType() != Constants.COLLECTION) {
            logCLI("error", "Handle:" + collectionID + " resolved to a " + dso.getType());
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
        if (StringUtils.isNotBlank(sourceHandle) && StringUtils.isNotBlank(destinationHandle)) {
            resolvedSourceCollection = collectionService.find(context, UUID.fromString(sourceHandle));
            resolvedDestinationCollection = collectionService.find(context, UUID.fromString(destinationHandle));

            // If the item is mapped to the collection we want to remove from and that collection is not its owning
            // collection we can go ahead and remove the item from the collection (if the item is not mapped to only
            // that collection which should not be the case but check to be sure)
            if (itemCollections.contains(resolvedDestinationCollection)
                && !resolvedDestinationCollection.equals(itemOwningCollection)
                && item.getCollections().size() > 1) {

                if (!dryRun) {
                    collectionService.removeItem(context, resolvedDestinationCollection, item);
                }
                logCLI("info", "Item with UUID: " + item.getID() + " was removed from" +
                    " collection with UUID: " + resolvedDestinationCollection.getID());
            }
        } else {
            for (Collection collection : itemCollections) {
                if (collection.equals(itemOwningCollection)) {
                    logCLI("info", "Current collection is the item's owning collection, skipping");
                    continue;
                }

                if (item.getCollections().size() == 1) {
                    logCLI("info", "Item is only left in one collection, we're not removing it");
                    if (!itemService.isOwningCollection(item, item.getCollections().get(0))) {
                        logCLI("warn", "The item with UUID:" + item.getID() + " is only left in one collection, which is " +
                            "not its owning collection, this should not be possible");
                    }
                    continue;
                }

                if (!dryRun) {
                    collectionService.removeItem(context, collection, item);
                }
                logCLI("info", "Item with UUID: " + item.getID() + " was removed from" +
                    " collection with UUID: " + collection.getID());

            }
        }
    }

    @Override
    public void showItemsInCollection(Context context, Collection collection) throws SQLException {
        int itemsCount = itemService.countItems(context, collection);
        System.out.println(itemsCount + " items in collection: " + collection.getID() + ": " + collection.getName());
    }

    private void verifyValidAndMap(Context context, Item item, Collection destinationCollection, boolean dryRun)
        throws SQLException, AuthorizeException {
        if (item.getCollections().contains(destinationCollection)) {
            logCLI("warning", "Item with UUID: " + item.getID() +
                " was not mapped because it is already in destination collection");
        }

        else if (!item.getCollections().contains(destinationCollection)) {
            showItemsInCollection(context, destinationCollection);
            logCLI("info", "Mapping item with UUID: " + item.getID() +
                " to collection with UUID: " + destinationCollection.getID());
            if (!dryRun) {
                collectionService.addItem(context, destinationCollection, item);
            }
        }
    }
}
