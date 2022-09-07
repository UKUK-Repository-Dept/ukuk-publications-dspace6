package com.atmire.cli;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.Options;

public class HelpOption implements OptionWrapper {
    private static final String help_param = "h";
    private boolean help = false;

    public HelpOption() {
    }

    public boolean isHelp() {
        return this.help;
    }

    public void addOption(Options options) {
        options.addOption("h", "help", false, "Prints a helpful message about this script's usage");
    }

    public void parse(CommandLine line) {
        this.help = line.hasOption("h");
    }
}
