package com.atmire.itemmapper;

import java.sql.SQLException;
import java.util.HashSet;
import java.util.Set;

import com.atmire.cli.BooleanOption;
import com.atmire.cli.ContextScript;
import com.atmire.cli.OptionWrapper;
import com.atmire.cli.StringOption;
import org.dspace.core.Context;

public class ParametrizedItemMappingScript extends ContextScript {

    StringOption operationMode;
    StringOption sourceHandle;
    StringOption destinationHandle;
    BooleanOption dryRun;

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
        operationMode = new StringOption('o', "operation", "the operation mode for the script", true);
        sourceHandle = new StringOption('s', "source", "handle of the source collection", false);
        destinationHandle = new StringOption('d', "destination", "handle of the destination collection", isUnmapped);
        dryRun = new BooleanOption('t', "test", "script run is dry run, for testing purposes only", false);

        HashSet<OptionWrapper> options = new HashSet<>();
        options.add(operationMode);
        options.add(sourceHandle);
        options.add(destinationHandle);
        options.add(dryRun);

        return options;
    }

    @Override
    public void run(Context context) throws SQLException {

    }
}
