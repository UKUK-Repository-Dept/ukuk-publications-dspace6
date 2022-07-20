package com.atmire.cli;

import java.util.Arrays;
import java.util.List;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;

public class RepeatableStringOption extends GenericOption {
    List<String> values;
    String separator;

    public RepeatableStringOption(char shortName, String longName, String description, boolean hasArg,
                                  boolean required, String separator) {
        super(shortName, longName, description, hasArg, required);
        this.separator = separator;
    }

    @Override
    public void addOption(Options options) {
        super.addOption(options);
    }

    @Override
    public void parse(CommandLine line) throws ParseException {
        if (line.hasOption(this.shortName)) {
            // If the separator string is included in the option we can assume multiple variables were supplied.
            // split the string on the separator and add those values to the list, otherwise we just add the value
            if (line.getOptionValues(this.shortName)[0].contains(this.separator)) {
                values = Arrays.asList(line.getOptionValues(this.shortName)[0]
                                           .replaceAll("\\s","")
                                           .split(this.separator));
            } else {
                this.values = Arrays.asList(line.getOptionValues(this.shortName));
            }
        }

    }

    public List<String> getValues() {
        return values;
    }

    public void setValues(List<String> values) {
        this.values = values;
    }
}
