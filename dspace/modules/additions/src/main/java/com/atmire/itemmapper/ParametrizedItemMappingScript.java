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

public class ParametrizedItemMappingScript extends ContextScript {

    private static final Logger log = LogManager.getLogger(ParametrizedItemMappingScript.class);

    public static void main(String[] args) {
        new ParametrizedItemMappingScript().mainImpl(args);
    }

    ItemMapperService itemMapperService = ItemMapperServiceFactory.getInstance().getItemMapperService();
    ItemService itemService = ContentServiceFactory.getInstance().getItemService();
    CollectionService collectionService = ContentServiceFactory.getInstance().getCollectionService();
    ConfigurationService configurationService = DSpaceServicesFactory.getInstance().getConfigurationService();

    StringOption operationMode;
    StringOption sourceHandle;
    StringOption destinationHandle;
    BooleanOption dryRun;

    Collection resolvedSourceCollection;
    Collection resolvedDestinationCollection;

    int batchSize = configurationService.getIntProperty("item.mapper.batchsize", 20);
    int offset = 0;

    String currentOperation;
    boolean isUnmapped;

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
        currentOperation = operationMode.getValue();
        itemMapperService.verifyParams(context, operationMode.getValue(), destinationHandle.getValue(), dryRun.isSelected());

        switch (currentOperation) {
            case "unmapped":
                Iterator<Item> itemsToMap;
                // Destination collection is required when case is unmapped
                resolvedDestinationCollection = itemMapperService.resolveCollection(context, destinationHandle.getValue());
                // If no source collection is given we want to obtain all items
                if (StringUtils.isBlank(sourceHandle.getValue())) {
                    itemsToMap = itemService.findAllWithLimitAndOffset(context, batchSize, 0);
                    itemsToMap.forEachRemaining((item -> {
                        try {
                            itemMapperService.mapItem(context, item, resolvedDestinationCollection, dryRun.isSelected());
                        } catch (SQLException | AuthorizeException e) {
                            itemMapperService.logCLI("error", "Item could not be mapped for an unknown reason");
                            e.printStackTrace();
                        }
                    }));
                }

                // If a source collection is given we want to obtain the items inside that collection
                if (StringUtils.isNotBlank(sourceHandle.getValue())) {
                    resolvedSourceCollection = itemMapperService.resolveCollection(context, sourceHandle.getValue());

                    itemMapperService.showItemsInCollection(context, resolvedDestinationCollection);
                    double totalItems = itemService.countAllItems(context, resolvedDestinationCollection);
                    double loops = Math.ceil(totalItems / batchSize);
                    for (int i = 1; i <= loops; i++) {
                        int batchnr = i;
                        itemsToMap = itemService.findAllByCollection(context, resolvedSourceCollection, batchSize, offset);
                        itemMapperService.logCLI("info", "PROCESSING BATCH:" + batchnr);
                        itemsToMap.forEachRemaining((item -> {
                            try {
                                System.out.println("Mapping item:" + item.getID());
                                itemMapperService.mapItem(context, item, resolvedSourceCollection,
                                                          resolvedDestinationCollection, dryRun.isSelected());
                                itemMapperService.showItemsInCollection(context, resolvedSourceCollection);
                            } catch (SQLException | AuthorizeException e) {
                                itemMapperService.logCLI("error", "Item could not be mapped for an unknown reason");
                                e.printStackTrace();
                            }
                        }));
                        offset += batchSize;
                    }
                }
                break;
            case "reversed":
                // If no destination collection is given we want to obtain all the items
                if (StringUtils.isBlank(destinationHandle.getValue())) {
                    itemsToMap = itemService.findAll(context);
                    itemsToMap.forEachRemaining((item) -> {
                        try {
                            itemMapperService.reverseMappedItem(context, item, sourceHandle.getValue(),
                                                                destinationHandle.getValue(), dryRun.isSelected());
                        } catch (SQLException | AuthorizeException | IOException e) {
                            itemMapperService.logCLI("error", "Item could not be mapped for an unknown reason");
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
                        itemMapperService.logCLI("error", "No collection could be resolved with UUID:" + sourceHandle.getValue());
                        break;
                    }

                    itemMapperService.showItemsInCollection(context, resolvedDestinationCollection);
                    itemsToMap = itemService.findAllByCollection(context, resolvedDestinationCollection);
                    itemsToMap.forEachRemaining((item) -> {
                        try {
                            itemMapperService.reverseMappedItem(context, item, sourceHandle.getValue(),
                                                                destinationHandle.getValue(), dryRun.isSelected());
                        } catch (SQLException | AuthorizeException | IOException e) {
                            itemMapperService.logCLI("error", "Item could not be mapped for an unknown reason");
                            e.printStackTrace();
                        }
                    });
                }
                break;
        }
    }
}
