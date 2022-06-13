package com.atmire.cli;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.ParseException;
import org.apache.commons.lang3.StringUtils;

import java.io.File;

/**
 * Created by: Antoine Snyers (antoine at atmire dot com)
 * Date: 28 Sep 2016
 */
public class FileOption extends StringOption {
    private boolean mustExist;

    public File getFile(){
        return new File(getValue());
    }

    public FileOption(char shortName, String longName, String description, boolean required, boolean mustExist) {
        super(shortName, longName, description, required);
        this.mustExist = mustExist;
    }

    @Override
    public void parse(CommandLine line) throws ParseException {
        super.parse(line);
        if (mustExist) {
            boolean exists = false;
            String value = getValue();
            if (StringUtils.isNotBlank(value)) {
                File file = new File(value);
                exists = file.exists() && isFine(file);
            }
            if (!exists) {
                throw new FileDoesNotExistException("No file found at " + value);
            }
        }
    }

    protected boolean isFine(File file) {
        return file.isFile();
    }

    static class FileDoesNotExistException extends ParseException {

        /**
         * Construct a new <code>ParseException</code>
         * with the specified detail message.
         *
         * @param message the detail message
         */
        public FileDoesNotExistException(String message) {
            super(message);
        }
    }
}
