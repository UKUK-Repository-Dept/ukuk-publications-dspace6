package com.atmire.itemmapper;

import static com.atmire.itemmapper.service.ItemMapperServiceImpl.ERROR;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import com.atmire.cli.BooleanOption;
import com.atmire.cli.ContextScript;
import com.atmire.cli.HelpOption;
import com.atmire.cli.OptionWrapper;
import com.atmire.cli.StringOption;
import com.atmire.itemmapper.factory.ItemMapperServiceFactory;
import com.atmire.itemmapper.service.ItemMapperService;
import org.dspace.content.Collection;
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

    protected ItemService itemService = ContentServiceFactory.getInstance()
                                                             .getItemService();

    ItemMapperService itemMapperService = ItemMapperServiceFactory.getInstance().getItemMapperService();
    static ConfigurationService configurationService = DSpaceServicesFactory.getInstance().getConfigurationService();

    StringOption operationMode;
    RepeatableStringOption sourceIdOption;
    RepeatableStringOption destinationIdOption;
    StringOption linkToFile;
    StringOption pathToFile;
    BooleanOption dryRun;
    String currentOperation;

    public static final String UNMAPPED = "unmapped";
    public static final String MAPPED = "mapped";
    public static final String REVERSED = "reversed";
    public static final String REVERSED_MAPPED = "reversed-mapped";
    public static final String LOCAL = "local";
    public static final String URL = "url";
    public static final String FILE_LOCATION = configurationService.getProperty("mapping.file.location", LOCAL);
    public static final String CONSUMER_FILE_LOCATION = configurationService.getProperty("consumer.mapping.file.location", LOCAL);
    public static final String[] OPERATIONS = {
        UNMAPPED,
        MAPPED,
        REVERSED,
        REVERSED_MAPPED
    };


    @Override
    protected Set<OptionWrapper> getOptionWrappers() {
        this.helpOption = new HelpOption();
        operationMode = new StringOption('o', "operation",
                                         "the operation mode for the script, should be one of following: " + Arrays.toString(OPERATIONS),true);
        sourceIdOption = new RepeatableStringOption('s', "source", String.format("handle or uuid of the source " +
            "collection(s). Note that multiple collections should be separated by character '%s'. It is also possible" +
            " to provide this parameter multiple times with different collections", MULTIPLE_ID_SEPARATOR), true, false,
            MULTIPLE_ID_SEPARATOR);
        destinationIdOption = new RepeatableStringOption('d', "destination", String.format("handle or uuid of the " +
            "destination collection(s).multiple collections should be separated by character '%s'. It is also " +
            "possible to provide this parameter multiple times with different collections", MULTIPLE_ID_SEPARATOR),
            true, false,
            MULTIPLE_ID_SEPARATOR);
        linkToFile = new StringOption('l',"link", "URL address leading to a valid link containing the raw json data " +
            "of the mapping file", false);
        pathToFile = new StringOption('p',"localpath", "Path to the json mapping file on your local storage system",
                                      false);
        dryRun = new BooleanOption('t', "test", "script run is dry run, no changes will be made to the database, for " +
            "testing purposes only", false);

        HashSet<OptionWrapper> options = new HashSet<>();
        options.add(helpOption);
        options.add(operationMode);
        options.add(sourceIdOption);
        options.add(destinationIdOption);
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
            List<Collection> validSources = itemMapperService.resolveCollections(context, sourceIdOption.getValues());
            List<Collection> validDestinations =
                itemMapperService.resolveCollections(context, destinationIdOption.getValues());
            boolean paramsAreValid = itemMapperService.verifyParams(context, operationMode.getValue(),
                validSources, validDestinations, linkToFile.getValue(), pathToFile.getValue(),
                dryRun.isSelected());
            if (!paramsAreValid) {
                System.exit(1);
            }

            if (dryRun.isSelected()) {
                itemMapperService.logCLI(INFO, "This is a dry run / test run of the script, no changes will be made to the database");
            }

            switch (currentOperation) {
                case UNMAPPED:
                    itemMapperService.mapFromParams(context, validDestinations, validSources, dryRun.isSelected());
                    break;
                case REVERSED:
                    itemMapperService.reverseMapFromParams(context, validDestinations, validSources, dryRun.isSelected());
                    break;
                case MAPPED:
                    itemMapperService.mapFromMappingFile(context, validSources, linkToFile.getValue(),
                                                         pathToFile.getValue(), dryRun.isSelected());
                    break;
                case REVERSED_MAPPED:
                    itemMapperService.reverseMapFromMappingFile(context, validSources, linkToFile.getValue(),
                                                                pathToFile.getValue(), dryRun.isSelected());
                    break;
                default:
                    itemMapperService.logCLI(ERROR, "The mapping operation resolved to: " + currentOperation + " this is not supported");
            }
            context.commit();
        } catch (Exception e) {
            itemMapperService.logCLI(ERROR, "An exception has occurred! => " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }
}
