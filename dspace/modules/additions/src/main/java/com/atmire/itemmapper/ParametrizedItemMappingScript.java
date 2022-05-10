package com.atmire.itemmapper;

import java.io.IOException;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Set;
import java.util.UUID;

import com.atmire.cli.BooleanOption;
import com.atmire.cli.ContextScript;
import com.atmire.cli.HelpOption;
import com.atmire.cli.OptionWrapper;
import com.atmire.cli.StringOption;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Collection;
import org.dspace.content.Item;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.CollectionService;
import org.dspace.content.service.ItemService;
import org.dspace.core.Context;
import org.springframework.beans.factory.annotation.Autowired;

public class ParametrizedItemMappingScript extends ContextScript {

    private static final Logger log = LogManager.getLogger(ParametrizedItemMappingScript.class);

    public static void main(String[] args) {
        new ParametrizedItemMappingScript().mainImpl(args);
    }

    ItemService itemService = ContentServiceFactory.getInstance().getItemService();

    CollectionService collectionService = ContentServiceFactory.getInstance().getCollectionService();

    StringOption operationMode;
    StringOption sourceHandle;
    StringOption destinationHandle;
    BooleanOption dryRun;

    Collection resolvedSourceCollection;
    Collection resolvedDestinationCollection;

    String currentOperation;
    boolean isUnmapped;

    String[] operationModes = {
        "unmapped",
        "mapped",
        "reversed",
        "reverse-mapped"
    };

    @Override
    protected Set<OptionWrapper> getOptionWrappers() {
        this.helpOption = new HelpOption();
        operationMode = new StringOption('o', "operation", "the operation mode for the script", true);
        sourceHandle = new StringOption('s', "source", "handle of the source collection", false);
        destinationHandle = new StringOption('d', "destination", "handle of the destination collection", isUnmapped);
        dryRun = new BooleanOption('t', "test", "script run is dry run, for testing purposes only", false);

        HashSet<OptionWrapper> options = new HashSet<>();
        options.add(helpOption);
        options.add(operationMode);
        options.add(sourceHandle);
        options.add(destinationHandle);
        options.add(dryRun);

        return options;
    }

    @Override
    public void run(Context context) throws SQLException {
        context.turnOffAuthorisationSystem();
        verifyParams(context);
        Iterator<Item> itemsToMap = null;

        switch (currentOperation) {
            case "unmapped":
                // If no source collection is given we want to obtain all items
                if (StringUtils.isBlank(sourceHandle.getValue())) {
                    itemsToMap = itemService.findAll(context);
                    itemsToMap.forEachRemaining((item -> {
                        try {
                            mapItem(context, item, resolvedDestinationCollection);
                        } catch (SQLException | AuthorizeException e) {
                            logCLI("error", "Item could not be mapped for an unknown reason");
                            e.printStackTrace();
                        }
                    }));
                }

                // If a source collection is given we want to obtain the items inside that collection
                if (StringUtils.isNotBlank(sourceHandle.getValue())) {
                    resolvedSourceCollection
                        = collectionService.find(context, UUID.fromString(sourceHandle.getValue()));

                    // Check that the given UUID actually resolves to a valid collection
                    if (!resolvedSourceCollection.getID().toString().equals(sourceHandle.getValue())) {
                        logCLI("error", "No collection could be resolved with UUID:" + sourceHandle.getValue());
                        break;
                    }

                    showItemsInCollection(context, resolvedDestinationCollection);
                    itemsToMap = itemService.findAllByCollection(context, resolvedSourceCollection);
                    itemsToMap.forEachRemaining((item -> {
                        try {
                            System.out.println("Mapping item:" + item.getID());
                            Thread.sleep(1000);
                            mapItem(context, item, resolvedSourceCollection, resolvedDestinationCollection);
                            Thread.sleep(1000);
                            showItemsInCollection(context, resolvedSourceCollection);
                        } catch (SQLException | AuthorizeException | InterruptedException e) {
                            logCLI("error", "Item could not be mapped for an unknown reason");
                            e.printStackTrace();
                        }
                    }));
                }
                break;
            case "reversed":
                // If no destination collection is given we want to obtain all the items
                if (StringUtils.isBlank(destinationHandle.getValue())) {
                    itemsToMap = itemService.findAll(context);
                    itemsToMap.forEachRemaining((item) -> {
                        try {
                            reverseMappedItem(context, item);
                        } catch (SQLException | AuthorizeException | IOException e) {
                            logCLI("error", "Item could not be mapped for an unknown reason");
                            e.printStackTrace();
                        }
                    });
                }

                // If a destination collection is given we want to obtain only the items from that collection
                if (StringUtils.isNotBlank(destinationHandle.getValue())) {
                    resolvedDestinationCollection
                        = collectionService.find(context, UUID.fromString(destinationHandle.getValue()));

                    // Check that the given UUID actually resolves to a valid collection
                    if (!resolvedDestinationCollection.getID().toString().equals(destinationHandle.getValue())) {
                        logCLI("error", "No collection could be resolved with UUID:" + sourceHandle.getValue());
                        break;
                    }

                    showItemsInCollection(context, resolvedDestinationCollection);
                    itemsToMap = itemService.findAllByCollection(context, resolvedDestinationCollection);
                    itemsToMap.forEachRemaining((item) -> {
                        try {
                            reverseMappedItem(context, item);
                        } catch (SQLException | AuthorizeException | IOException e) {
                            logCLI("error", "Item could not be mapped for an unknown reason");
                            e.printStackTrace();
                        }
                    });
                }
                break;
        }
    }

    public void logCLI(String level, String message) {
        System.out.println(message);
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

    public void mapItem (Context context, Item item, Collection sourceCollection, Collection destinationCollection)
        throws SQLException, AuthorizeException {

        if (itemService.isOwningCollection(item, sourceCollection)) {
            if (item.getCollections().contains(destinationCollection)) {
                logCLI("warning", "Item with UUID:" + item.getID() +
                    "not mapped because it is already in collection with UUID: " + destinationCollection.getID());
            }

            if (!dryRun.isSelected()) {
                System.out.println("Current items in destination collection:");
                showItemsInCollection(context, destinationCollection);
                collectionService.addItem(context, destinationCollection, item);
                System.out.println("Current items in destination collection:");
                showItemsInCollection(context, destinationCollection);
            }

            logCLI("info", "Mapping item with UUID:" + item.getID() +
                " to collection with UUID: " + destinationCollection.getID());

        } else {
            logCLI("warning", "Item with UUID:" + item.getID() +
                       "not mapped because it is not owned by collection with UUID: " + sourceCollection.getID());
        }

    }

    public void mapItem (Context context, Item item, Collection destinationCollection)
        throws SQLException, AuthorizeException {
        mapItem(context, item, item.getOwningCollection(), destinationCollection);
    }

    public void verifyParams(Context context) throws SQLException {
        switch (operationMode.getValue()) {
            case "unmapped":
            case "mapped":
            case "reversed":
            case "reverse-mapped":
                currentOperation = operationMode.getValue();
                break;
            default:
                logCLI("error", "No valid operation mode was given");
        }

        if (currentOperation.equals("unmapped")) {
            if (StringUtils.isBlank(destinationHandle.getValue())) {
                logCLI("error", "No destination handle was given, this is required when the operation mode is " +
                    "set to unmapped");
            }

            resolvedDestinationCollection
                = collectionService.find(context, UUID.fromString(destinationHandle.getValue()));

            if (!resolvedDestinationCollection.getID().equals(destinationHandle.getValue())) {
                logCLI("error", "UUID:" + destinationHandle.getValue() + " did not resolve to a valid collection");
            }

        }

        if (dryRun.isSelected()) {
            context.setMode(Context.Mode.READ_ONLY);
        }
    }

    public void reverseMappedItem(Context context, Item item) throws SQLException, AuthorizeException, IOException {
        List<Collection> itemCollections = item.getCollections();
        Collection itemOwningCollection = item.getOwningCollection();

        for (Collection collection : itemCollections) {
            if (itemService.isOwningCollection(item, collection)) {
                logCLI("info", "owning collection --- skipping");
                break;
            }

            if (item.getCollections().size() == 1) {
                logCLI("info", "Item is only left in one collection, we're not removing it");
                if (!itemService.isOwningCollection(item, item.getCollections().get(0))) {
                    logCLI("warn", "The item with UUID:" + item.getID() + " is only left in one collection, which is " +
                        "not its owning collection, this should not be possible");
                }
                break;
            }

            collectionService.removeItem(context, collection, item);
            logCLI("info", "Item with UUID: " + item.getID() + " was removed from" +
                " collection with UUID: " + collection.getID());

        }

    }

    public void showItemsInCollection(Context context, Collection collection) throws SQLException {
        int itemsCount = itemService.countItems(context, collection);
        System.out.println(itemsCount + " items in collection: " + collection.getID() + ": " + collection.getName());
    }
}
