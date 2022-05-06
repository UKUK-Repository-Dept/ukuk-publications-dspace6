package com.atmire.cli;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.Options;

/**
 * Created by: Antoine Snyers (antoine at atmire dot com)
 * Date: 26 Jul 2016
 */
public class VerboseOption implements OptionWrapper {

    private static final String verbose_param = "v";

    private boolean verbose = false;

    public boolean isVerbose() {
        return verbose;
    }

    @Override
    public void addOption(Options options) {
        options.addOption(verbose_param, "verbose", false, "Enable verbose output");
    }

    @Override
    public void parse(CommandLine line) {
        this.verbose = line.hasOption(verbose_param);
    }
}
