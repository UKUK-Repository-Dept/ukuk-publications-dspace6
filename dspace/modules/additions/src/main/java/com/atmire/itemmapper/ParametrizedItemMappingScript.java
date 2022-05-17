package com.atmire.itemmapper;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Arrays;
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
import com.atmire.itemmapper.factory.ItemMapperServiceFactory;
import com.atmire.itemmapper.service.ItemMapperService;
import com.atmire.itemmapper.service.ItemMapperServiceImpl;
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
import org.dspace.services.ConfigurationService;
import org.dspace.services.factory.DSpaceServicesFactory;
import org.springframework.beans.factory.annotation.Autowired;


/**
 * CLI script for mapping / unmapping items from and to collections
 *
 * @author jens vannerum
 */
public class ParametrizedItemMappingScript extends ContextScript {

    private static final Logger log = LogManager.getLogger(ParametrizedItemMappingScript.class);

    public static void main(String[] args) {
        new ParametrizedItemMappingScript().mainImpl(args);
    }

    ItemMapperService itemMapperService = ItemMapperServiceFactory.getInstance().getItemMapperService();
    ItemService itemService = ContentServiceFactory.getInstance().getItemService();
    CollectionService collectionService = ContentServiceFactory.getInstance().getCollectionService();
    ConfigurationService configurationService = DSpaceServicesFactory.getInstance().getConfigurationService();

    Iterator<Item> itemsToMap;

    StringOption operationMode;
    StringOption sourceHandle;
    StringOption destinationHandle;
    BooleanOption dryRun;
    Collection resolvedSourceCollection;
    Collection resolvedDestinationCollection;
    String currentOperation;

    boolean isUnmapped;
    double totalItems;
    int batchSize = configurationService.getIntProperty("item.mapper.batch.size", 100);
    int offset = 0;

    public static final String UNMAPPED = "unmapped";
    public static final String MAPPED = "mapped";
    public static final String REVERSED = "reversed";
    public static final String REVERSE_MAPPED = "reverse-mapped";

    public static final String[] OPERATIONS = {
        UNMAPPED,
        MAPPED,
        REVERSED,
        REVERSE_MAPPED
    };


    @Override
    protected Set<OptionWrapper> getOptionWrappers() {
        this.helpOption = new HelpOption();
        operationMode = new StringOption('o', "operation",
                                         "the operation mode for the script, should be one of following: " +
                                             Arrays.toString(OPERATIONS),
                                         true);
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
        try {
            context.turnOffAuthorisationSystem();
            currentOperation = operationMode.getValue();
            itemMapperService.verifyParams(context, operationMode.getValue(), sourceHandle.getValue(),
                                           destinationHandle.getValue(),
                                           dryRun.isSelected());

            switch (currentOperation) {
                case UNMAPPED:
                    // Destination collection is required when case is unmapped
                    resolvedDestinationCollection = itemMapperService.resolveCollection(context, destinationHandle.getValue());

                    // If no source collection is given we want to obtain all items
                    if (StringUtils.isBlank(sourceHandle.getValue())) {
                        totalItems = itemService.countTotal(context);

                        // Loop through all of our items in batches
                        for (int i = 1; i <= Math.ceil(totalItems / batchSize); i++) {
                            itemsToMap = itemService.findAllWithLimitAndOffset(context, batchSize, offset);
                            itemMapperService.logCLI("info", "***** PROCESSING BATCH:" + i + " *****");

                            // Map all items in the current batch
                            itemsToMap.forEachRemaining((item) -> {
                                try {
                                    itemMapperService.logCLI("info", String.format("Mapping item (%s | %s) ",
                                                                 item.getHandle(), item.getID()));
                                    itemMapperService.mapItem(context, item, resolvedDestinationCollection, dryRun.isSelected());
                                } catch (SQLException | AuthorizeException e) {
                                    itemMapperService.logCLI("error", String.format("Item (%s | %s) could not be " +
                                                                                        "mapped for an unknown reason",
                                                                                   item.getHandle(), item.getID()));
                                    e.printStackTrace();
                                }
                            });
                            offset += batchSize;
                        }
                    }

                    // If a source collection is given we want to obtain the items inside that collection
                    else if (StringUtils.isNotBlank(sourceHandle.getValue())) {
                        resolvedSourceCollection = itemMapperService.resolveCollection(context, sourceHandle.getValue());
                        totalItems = itemService.countAllItems(context, resolvedSourceCollection);

                        for (int i = 1; i <= Math.ceil(totalItems / batchSize); i++) {
                            itemsToMap = itemService.findAllByCollection(context, resolvedSourceCollection, batchSize, offset);
                            itemMapperService.logCLI("info", "***** PROCESSING BATCH:" + i + " *****");

                            itemsToMap.forEachRemaining((item -> {
                                try {
                                    itemMapperService.logCLI("info", String.format("Mapping item (%s | %s) ",
                                                                                   item.getHandle(), item.getID()));
                                    itemMapperService.mapItem(context, item, resolvedSourceCollection,
                                                              resolvedDestinationCollection, dryRun.isSelected());
                                } catch (SQLException | AuthorizeException e) {
                                    itemMapperService.logCLI("error", String.format("Item (%s | %s) could not be " +
                                                                                        "mapped for an unknown reason",
                                                                                    item.getHandle(), item.getID()));
                                    e.printStackTrace();
                                }
                            }));
                            offset += batchSize;
                        }
                    }
                    break;
                case REVERSED:
                    // If no destination and source collection is given we want to obtain all the items
                    if (StringUtils.isBlank(destinationHandle.getValue()) && StringUtils.isBlank(sourceHandle.getValue())) {
                        totalItems = itemService.countTotal(context);

                        // Loop through all of our items in batches
                        for (int i = 1; i <= Math.ceil(totalItems / batchSize); i++) {
                            itemsToMap = itemService.findAllWithLimitAndOffset(context, batchSize, offset);
                            itemMapperService.logCLI("info", "***** PROCESSING BATCH:" + i + " *****");

                            // Reverse map all items in the current batch
                            reverseMapItemsInBatch(context);
                        }
                    }

                    // If a destination and source collection is given we want to obtain only the items from the
                    // destination collection as this is where we will be reverse mapping (removing) items from
                    else if (StringUtils.isNotBlank(destinationHandle.getValue())) {
                        resolvedDestinationCollection =
                            itemMapperService.resolveCollection(context, destinationHandle.getValue());
                        resolvedSourceCollection =
                            itemMapperService.resolveCollection(context, sourceHandle.getValue());

                        totalItems = itemService.countAllItems(context, resolvedSourceCollection);

                        // Loop through all of our items in batches
                        for (int i = 1; i <= Math.ceil(totalItems / batchSize); i++) {
                            itemsToMap = itemService.findAllByCollection(context, resolvedSourceCollection, batchSize, offset);
                            itemMapperService.logCLI("info", "***** PROCESSING BATCH:" + i + " *****");

                            // Reverse map all items in the current batch
                            reverseMapItemsInBatch(context);
                        }
                    }
                    break;
            }
        } catch (Exception e) {
            itemMapperService.logCLI("error", "An exception has occurred! => " + e.getCause().toString());
            e.printStackTrace();
            throw e;
        }
    }

    private void reverseMapItemsInBatch(Context context) {
        itemsToMap.forEachRemaining((item) -> {
            try {
                itemMapperService.reverseMappedItem(context, item, sourceHandle.getValue(),
                                                    destinationHandle.getValue(), dryRun.isSelected());
            } catch (SQLException | AuthorizeException | IOException e) {
                itemMapperService.logCLI("error", String.format("Item (%s | %s) could not be mapped for an unknown reason ",
                                                                item.getHandle(), item.getID()));
                e.printStackTrace();
            }
        });
        offset += batchSize;
    }
}
