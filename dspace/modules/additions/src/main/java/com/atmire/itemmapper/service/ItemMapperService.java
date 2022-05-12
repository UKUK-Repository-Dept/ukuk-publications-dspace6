package com.atmire.itemmapper.service;

import java.io.IOException;
import java.sql.SQLException;

import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Collection;
import org.dspace.content.Item;
import org.dspace.core.Context;

public interface ItemMapperService {

    public void logCLI(String level, String message);
    public void mapItem (Context context, Item item, Collection sourceCollection, Collection destinationCollection,
                         boolean dryRun)
        throws SQLException, AuthorizeException;
    public void mapItem (Context context, Item item, Collection destinationCollection, boolean dryRun) throws SQLException,
        AuthorizeException;
    public void verifyParams(Context context, String operationmode, String sourceHandle, String destinationHandle,
                             boolean dryRun) throws SQLException;
    public void reverseMappedItem(Context context, Item item, String sourceHandle, String destinationHandle,
                                  boolean dryRun)
                                  throws SQLException, AuthorizeException, IOException;
    public void showItemsInCollection(Context context, Collection collection) throws SQLException;
    public Collection resolveCollection(Context context, String collectionID) throws SQLException;
}
