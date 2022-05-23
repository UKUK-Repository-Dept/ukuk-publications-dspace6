package com.atmire.itemmapper;

import static com.atmire.itemmapper.service.ItemMapperServiceImpl.ERROR;
import static com.atmire.itemmapper.service.ItemMapperServiceImpl.INFO;
import static com.atmire.itemmapper.service.ItemMapperServiceImpl.MAPPING_FILE_NAME;
import static com.atmire.itemmapper.service.ItemMapperServiceImpl.MAPPING_FILE_PATH;

import java.io.IOException;
import java.net.URL;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

import com.atmire.cli.BooleanOption;
import com.atmire.cli.ContextScript;
import com.atmire.cli.HelpOption;
import com.atmire.cli.OptionWrapper;
import com.atmire.cli.StringOption;
import com.atmire.itemmapper.factory.ItemMapperServiceFactory;
import com.atmire.itemmapper.model.CuniMapFile;
import com.atmire.itemmapper.model.SourceCollection;
import com.atmire.itemmapper.service.ItemMapperService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.commons.lang3.StringUtils;
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
    public static void main(String[] args) {
        new ParametrizedItemMappingScript().mainImpl(args);
    }

    @Autowired
    CollectionService collectionService;

    ItemMapperService itemMapperService = ItemMapperServiceFactory.getInstance().getItemMapperService();
    ItemService itemService = ContentServiceFactory.getInstance().getItemService();
    static ConfigurationService configurationService = DSpaceServicesFactory.getInstance().getConfigurationService();

    Iterator<Item> itemsToMap;

    StringOption operationMode;
    StringOption sourceHandle;
    StringOption destinationHandle;
    StringOption linkToFile;
    StringOption pathToFile;
    BooleanOption dryRun;
    Collection resolvedSourceCollection;
    Collection resolvedDestinationCollection;
    String currentOperation;

    double totalItems;
    int batchSize = configurationService.getIntProperty("item.mapper.batch.size", 100);
    int offset = 0;

    public static final String UNMAPPED = "unmapped";
    public static final String MAPPED = "mapped";
    public static final String REVERSED = "reversed";
    public static final String REVERSE_MAPPED = "reverse-mapped";
    public static final String LOCAL = "local";
    public static final String URL = "url";
    public static final String FILE_LOCATION = configurationService.getProperty("mapping.file.location", LOCAL);
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
                                         "the operation mode for the script, should be one of following: " + Arrays.toString(OPERATIONS),true);
        sourceHandle = new StringOption('s', "source", "handle of the source collection", false);
        destinationHandle = new StringOption('d', "destination", "handle of the destination collection", false);
        linkToFile = new StringOption('l',"link", "URL address leading to the mapped file", false);
        pathToFile = new StringOption('p',"localpath", "Path to the mapped file in local storage system", false);
        dryRun = new BooleanOption('t', "test", "script run is dry run, for testing purposes only", false);

        HashSet<OptionWrapper> options = new HashSet<>();
        options.add(helpOption);
        options.add(operationMode);
        options.add(sourceHandle);
        options.add(destinationHandle);
        options.add(linkToFile);
        options.add(pathToFile);
        options.add(dryRun);

        return options;
    }

    @Override
    public void run(Context context) throws Exception {
        try {
            context.turnOffAuthorisationSystem();

            currentOperation = operationMode.getValue();
            itemMapperService.verifyParams(context, operationMode.getValue(), sourceHandle.getValue(),
                                           destinationHandle.getValue(), linkToFile.getValue(), pathToFile.getValue(),
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
                            itemMapperService.logCLI(INFO, "***** PROCESSING BATCH:" + i + " *****");

                            // Map all items in the current batch
                            itemsToMap.forEachRemaining((item) -> {
                                try {
                                    itemMapperService.logCLI(INFO, String.format("Mapping item (%s | %s) ",
                                                                 item.getHandle(), item.getID()));
                                    itemMapperService.mapItem(context, item, resolvedDestinationCollection, dryRun.isSelected());
                                } catch (SQLException | AuthorizeException e) {
                                    itemMapperService.logCLI(ERROR, String.format("Item (%s | %s) " + "could not be " +
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
                            itemMapperService.logCLI(INFO, "***** PROCESSING BATCH:" + i + " *****");

                            itemsToMap.forEachRemaining((item -> {
                                try {
                                    itemMapperService.logCLI(INFO, String.format("Mapping item (%s | %s) ",
                                                                                   item.getHandle(), item.getID()));
                                    itemMapperService.mapItem(context, item, resolvedSourceCollection,
                                                              resolvedDestinationCollection, dryRun.isSelected());
                                } catch (SQLException | AuthorizeException e) {
                                    itemMapperService.logCLI(ERROR, String.format("Item (%s | %s) could not be " +
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
                            itemMapperService.logCLI(INFO, "***** PROCESSING BATCH:" + i + " *****");

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
                            itemMapperService.logCLI(INFO, "***** PROCESSING BATCH:" + i + " *****");

                            // Reverse map all items in the current batch
                            reverseMapItemsInBatch(context);
                        }
                    }
                    break;
                case MAPPED:
                    CuniMapFile cuniMapFile;
                    ObjectMapper objectMapper = new ObjectMapper();
                    if (StringUtils.isNotBlank(linkToFile.getValue())) {
                        java.net.URL jsonURL = new URL(linkToFile.getValue());
                        cuniMapFile = objectMapper.readValue(jsonURL, CuniMapFile.class);
                    }
                    else if (StringUtils.isNotBlank(pathToFile.getValue())) {
                        cuniMapFile = objectMapper.readValue(itemMapperService.getContentFromFile(pathToFile.getValue()), CuniMapFile.class);
                    } else {
                        cuniMapFile = objectMapper.readValue(itemMapperService.getContentFromFile(MAPPING_FILE_PATH + MAPPING_FILE_NAME), CuniMapFile.class);
                    }
                    for (SourceCollection col : cuniMapFile.getMapfile().getSource_collections()) {
                        Collection collection =  itemMapperService.getCorrespondingCollection(context, col);
                        itemMapperService.mapItemsFromJson(context, itemService.findAllByCollection(context,collection), cuniMapFile);
                    }


            }
        } catch (Exception e) {
            itemMapperService.logCLI(ERROR, "An exception has occurred! => " + e.getCause().toString());
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
                itemMapperService.logCLI(ERROR, String.format("Item (%s | %s) could not be mapped for an unknown reason ",
                                                                item.getHandle(), item.getID()));
                e.printStackTrace();
            }
        });
        offset += batchSize;
    }
}
