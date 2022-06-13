/*
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */

package com.atmire.cli;

import org.apache.commons.cli.CommandLine;

/**
 * Created by jonas - jonas@atmire.com on 2020-10-23.
 */
public class BooleanOption extends GenericOption {

    private boolean isSelected = false;

    public BooleanOption(char shortName, String longName, String description, boolean required) {
        super(shortName, longName, description, false, required);
    }

    public void parse(CommandLine line) {
        this.isSelected = line.hasOption(shortName);
    }

    public boolean isSelected() {
        return isSelected;
    }

}
