/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package com.atmire.cli;

import org.apache.log4j.Logger;
import org.dspace.content.DCDate;

import java.util.Date;

/**
 * Logger class to pass along to services to print output for CLI Scripts
 *
 * @author Marie Verdonck (Atmire) on 18/08/2021
 */
public class CLILogger {

    private Logger dspaceLogger;

    public CLILogger(Logger dspaceLogger) {
        this.dspaceLogger = dspaceLogger;
    }

    public void printInfo(final String message) {
        System.out.println(String.format("%s - %s", this.getTimeStamp(), message));
        dspaceLogger.info(message);
    }

    public void printError(final String message, final Exception e) {
        System.out.println(String.format("%s - ERROR: %s", this.getTimeStamp(), message));
        dspaceLogger.error(message, e);
    }

    private String getTimeStamp() {
        return new DCDate(new Date()).toString();
    }
}
