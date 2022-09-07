package com.atmire.itemmapper.service;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Iterator;
import java.util.List;

import com.atmire.itemmapper.model.CuniMapFile;
import com.atmire.itemmapper.model.GenericCollection;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Collection;
import org.dspace.content.Item;
import org.dspace.core.Context;

public interface ItemMapperService {

    public void logCLI(String level, String message);

    public void mapItem(Context context, Item item, Collection sourceCollection, Collection destinationCollection,
                        boolean dryRun)
        throws SQLException, AuthorizeException;

    public void mapItem(Context context, Item item, Collection destinationCollection, boolean dryRun)
        throws SQLException,
        AuthorizeException;

    public void verifyParams(Context context, String operationmode, String sourceHandle, String destinationHandle,
                             String linkToFile, String pathToFile, boolean dryRun)
        throws SQLException, IOException;

    public void unmapItem(Context context, Item item, String sourceHandle, String destinationHandle,
                          boolean dryRun)
        throws SQLException, AuthorizeException, IOException;

    public void unmapItem(Context context, Item item, String sourceHandle,  boolean dryRun)
        throws SQLException, AuthorizeException, IOException;

    public void showItemsInCollection(Context context, Collection collection) throws SQLException;

    public Collection resolveCollection(Context context, String collectionID) throws SQLException;

    public String getContentFromFile(String filepath) throws IOException;

    public Collection getCorrespondingCollection(Context context, GenericCollection col)
        throws SQLException;

    public void mapItemsFromJson(Context context, Iterator<Item> items, CuniMapFile mapFile, boolean dryRun)
        throws SQLException, AuthorizeException, IOException;

    public void reverseMapItemsFromJson(Context context, Iterator<Item> items, CuniMapFile mapFile, boolean dryRun)
        throws SQLException, AuthorizeException, IOException;

    public CuniMapFile getMapFileFromLink(String link) throws IOException;

    public CuniMapFile getMapFileFromPath(String path) throws IOException;

    public void mapFromParams(Context context, String destinationHandle, String sourceHandle, boolean dryRun) throws SQLException;

    public void reverseMapFromParams(Context context, String destinationHandle, String sourceHandle, boolean dryRun) throws SQLException;

    public void mapFromMappingFile(Context context, String link, String path, boolean dryRun)
        throws IOException, SQLException, AuthorizeException;

    public void reverseMapFromMappingFile(Context context, String link, String path, boolean dryRun)
        throws SQLException, IOException, AuthorizeException;

    public void doesURLResolve(String url) throws IOException;

    public void isValidJSONFile(String path) throws IOException;

    public void checkMetadataValuesAndConvertToString(Context context, Iterator<Item> items, CuniMapFile mapFile,
                                                      String mapMode, boolean dryRun)
        throws SQLException, AuthorizeException, IOException;

    public void addItemToListIfInSourceCollection(Context ctx, Item item, CuniMapFile cuniMapFile,
                                                  List<Item> itemList) throws SQLException;

    public boolean doesFileExist();

    public boolean isLinkValid() throws IOException;
}
