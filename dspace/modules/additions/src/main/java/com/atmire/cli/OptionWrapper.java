package com.atmire.cli;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;

public interface OptionWrapper {
    void addOption(Options option);

    void parse(CommandLine line) throws ParseException;
}
