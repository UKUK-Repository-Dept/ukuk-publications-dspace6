package com.atmire.cli;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.ParseException;

public class StringOption extends GenericOption {
    private String value = null;

    public StringOption(char shortName, String longName, String description, boolean required) {
        super(shortName, longName, description, true, required);
    }

    public String getValue() {
        return this.value;
    }

    public void parse(CommandLine line) throws ParseException {
        if (line.hasOption(this.shortName)) {
            this.value = line.getOptionValue(this.shortName);
        }

    }
}
