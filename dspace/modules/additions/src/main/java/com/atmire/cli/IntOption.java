package com.atmire.cli;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.ParseException;

/**
 * Created by: Antoine Snyers (antoine at atmire dot com)
 * Date: 07 Mar 2022
 */
public class IntOption extends GenericOption {

    private int value;

    public IntOption(char shortName, String longName, String description, boolean required) {
        super(shortName, longName, description, true, required);
    }

    public int getValue() {
        return value;
    }

    @Override
    public void parse(CommandLine line) throws ParseException {
        if (line.hasOption(shortName)) {
            String value = line.getOptionValue(shortName);
            try {
                this.value = Integer.parseInt(value);
            } catch (NumberFormatException n) {
                throw new ParseException(n.getMessage());
            }
        }
    }
}

