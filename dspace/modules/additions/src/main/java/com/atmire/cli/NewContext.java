package com.atmire.cli;

import java.sql.SQLException;

import org.apache.commons.lang.UnhandledException;
import org.dspace.core.Context;

public class NewContext {
    public NewContext() {
    }

    public void run(NewContext.Function function) {
        Context context = null;

        try {
            context = new Context();
            function.run(context);
            context.complete();
        } catch (SQLException e) {
            throw new UnhandledException(e);
        } finally {
            if (context != null && context.isValid()) {
                context.abort();
            }

        }

    }

    public interface Function {
        void run(Context context) throws SQLException;
    }
}
