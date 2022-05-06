package com.atmire.cli;

import com.atmire.cli.NewContext.Function;

public abstract class ContextScript extends Script implements Function {
    public ContextScript() {
    }

    protected void run() {
        (new NewContext()).run(this);
    }
}
