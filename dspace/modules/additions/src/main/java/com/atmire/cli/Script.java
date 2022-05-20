package com.atmire.cli;

import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.cli.PosixParser;
import org.apache.commons.collections4.CollectionUtils;
import org.apache.log4j.Logger;

public abstract class Script {
    private static Logger log = Logger.getLogger(Script.class);
    private final Set<OptionWrapper> options = new HashSet();
    protected HelpOption helpOption;

    protected Script() {
        Set<OptionWrapper> optionWrappers = this.getOptionWrappers();
        if (CollectionUtils.isNotEmpty(optionWrappers)) {
            this.options.addAll(optionWrappers);
        }

        if (this.addHelpOption()) {
            this.helpOption = new HelpOption();
            this.options.add(this.helpOption);
        }

    }

    protected void mainImpl(String[] args) {
        if (this.hasHelp(args)) {
            this.printHelp();
        } else {
            try {
                CommandLineParser parser = new PosixParser();
                Options options = this.getOptions();
                CommandLine line = parser.parse(options, args);
                Iterator i$ = this.options.iterator();

                while (i$.hasNext()) {
                    OptionWrapper option = (OptionWrapper) i$.next();
                    option.parse(line);
                }

                this.run();
            } catch (Exception e) {
                this.print(e.getMessage());
                this.printHelp();
            }
        }

    }

    private boolean hasHelp(String[] args) {
        boolean hasHelp = false;
        if (this.addHelpOption()) {
            try {
                Options options = new Options();
                this.helpOption.addOption(options);
                CommandLineParser parser = new PosixParser();
                CommandLine line = parser.parse(options, args, true);
                this.helpOption.parse(line);
                hasHelp = this.helpOption.isHelp();
            } catch (ParseException e) {
                log.warn("This ParseException should not happen");
            }
        }

        return hasHelp;
    }

    protected Set<OptionWrapper> getOptionWrappers() {
        return null;
    }

    protected abstract void run() throws Exception;

    protected boolean addHelpOption() {
        return true;
    }

    protected void print(String message) {
        System.out.println(message);
    }

    public void printHelp() {
        HelpFormatter helpFormatter = new HelpFormatter();
        helpFormatter.printHelp("dsrun " + this.getClass().getCanonicalName(), this.getOptions());
    }

    public Options getOptions() {
        Options options = new Options();
        if (CollectionUtils.isNotEmpty(this.options)) {
            Iterator i$ = this.options.iterator();

            while (i$.hasNext()) {
                OptionWrapper option = (OptionWrapper) i$.next();
                option.addOption(options);
            }
        }

        return options;
    }
}
