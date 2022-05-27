package com.atmire.itemmapper;

import static com.atmire.itemmapper.service.ItemMapperServiceImpl.ERROR;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import com.atmire.cli.BooleanOption;
import com.atmire.cli.ContextScript;
import com.atmire.cli.HelpOption;
import com.atmire.cli.OptionWrapper;
import com.atmire.cli.StringOption;
import com.atmire.itemmapper.factory.ItemMapperServiceFactory;
import com.atmire.itemmapper.service.ItemMapperService;
import org.dspace.content.service.CollectionService;
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
    static ConfigurationService configurationService = DSpaceServicesFactory.getInstance().getConfigurationService();

    StringOption operationMode;
    StringOption sourceHandle;
    StringOption destinationHandle;
    StringOption linkToFile;
    StringOption pathToFile;
    BooleanOption dryRun;
    String currentOperation;

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
                    itemMapperService.mapFromParams(context, destinationHandle.getValue(), sourceHandle.getValue(), dryRun.isSelected());
                    break;
                case REVERSED:
                    itemMapperService.reverseMapFromParams(context, destinationHandle.getValue(), sourceHandle.getValue(), dryRun.isSelected());
                    break;
                case MAPPED:
                    itemMapperService.mapFromMappingFile(context, linkToFile.getValue(), pathToFile.getValue());
                    break;
                case REVERSE_MAPPED:
                    itemMapperService.reverseMapFromMappingFile(context, linkToFile.getValue(), pathToFile.getValue());
                    break;
                default:
                    itemMapperService.logCLI(ERROR, "The mapping operation resolved to: " + currentOperation + " this is not supported");
            }
        } catch (Exception e) {
            itemMapperService.logCLI(ERROR, "An exception has occurred! => " + e.getCause().toString());
            e.printStackTrace();
            throw e;
        }
    }
}
