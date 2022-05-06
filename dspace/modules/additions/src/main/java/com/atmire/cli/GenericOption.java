package com.atmire.cli;

import org.apache.commons.cli.Option;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;

public abstract class GenericOption implements OptionWrapper {
    protected final char shortName;
    protected final String longName;
    protected final String description;
    protected boolean hasArg;
    protected boolean required;

    public GenericOption(char shortName, String longName, String description, boolean hasArg, boolean required) {
        this.shortName = shortName;
        this.longName = longName;
        this.description = description;
        this.hasArg = hasArg;
        this.required = required;
    }

    public void addOption(Options options) {
        OptionBuilder.withLongOpt(this.longName);
        OptionBuilder.hasArg(this.hasArg);
        OptionBuilder.withDescription(this.description);
        OptionBuilder.isRequired(this.required);
        Option option = OptionBuilder.create(this.shortName);
        options.addOption(option);
    }
}
