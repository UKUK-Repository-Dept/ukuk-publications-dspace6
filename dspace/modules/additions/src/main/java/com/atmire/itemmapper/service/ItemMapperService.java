package com.atmire.itemmapper.service;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Iterator;

import com.atmire.itemmapper.model.CuniMapFile;
import com.atmire.itemmapper.model.GenericCollection;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Collection;
import org.dspace.content.Item;
import org.dspace.core.Context;

public interface ItemMapperService {

    void logCLI(String level, String message);

    public void logCLI(String level, String message, Exception e);

    public void logCLI(String level, String message, boolean dryRun);

    void logCLI(String level, String message, boolean dryRun);

    void mapItem(Context context, Item item, Collection sourceCollection, Collection destinationCollection,
        boolean dryRun) throws SQLException, AuthorizeException;

    void mapItem(Context context, Item item, Collection destinationCollection, boolean dryRun)
        throws SQLException, AuthorizeException;

    boolean verifyParams(Context context, String operationmode, List<Collection> validSources,
        List<Collection> validDestinations, String linkToFile, String pathToFile, boolean dryRun)
        throws SQLException, IOException;

    void unmapItem(Context context, Item item, List<Collection> sources, List<Collection> destinations,
        boolean dryRun) throws SQLException, AuthorizeException, IOException;

    void unmapItem(Context context, Item item, List<Collection> sources, boolean dryRun)
        throws SQLException, AuthorizeException, IOException;

    void showItemsInCollection(Context context, Item item, Collection collection) throws SQLException;

    List<Collection> resolveCollections(Context context, List<String> collectionIDsList) throws SQLException;

    String getContentFromFile(String filepath) throws IOException;

    Collection getCorrespondingCollection(Context context, GenericCollection col) throws SQLException;

    void mapItemsFromJson(Context context, Iterator<Item> items, CuniMapFile mapFile, boolean dryRun,
        Collection collection) throws SQLException, AuthorizeException, IOException;

    void reverseMapItemsFromJson(Context context, Iterator<Item> items, CuniMapFile mapFile, boolean dryRun,
        Collection collection) throws SQLException, AuthorizeException, IOException;

    CuniMapFile getMapFileFromLink(String link) throws IOException;

    CuniMapFile getMapFileFromPath(String path) throws IOException;

    void mapFromParams(Context context, List<Collection> destinations, List<Collection> sources, boolean dryRun)
        throws SQLException;

    void reverseMapFromParams(Context context, List<Collection> destinations, List<Collection> sources, boolean dryRun)
        throws SQLException;

    void mapFromMappingFile(Context context, List<Collection> sources, String link, String path, boolean dryRun)
        throws IOException, SQLException, AuthorizeException;

    void reverseMapFromMappingFile(Context context, List<Collection> sources, String link, String path, boolean dryRun)
        throws SQLException, IOException, AuthorizeException;

    boolean doesURLResolve(String url) throws IOException;

    boolean isValidJSONFile(String path) throws IOException;

    void checkMetadataValuesAndConvertToString(Context context, Iterator<Item> items, CuniMapFile mapFile,
        String mapMode, boolean dryRun) throws SQLException, AuthorizeException, IOException;

    void addItemToListIfInSourceCollection(Context ctx, Item item, CuniMapFile cuniMapFile,
        List<Item> itemList) throws SQLException;

    boolean doesFileExist();

    boolean isLinkValid() throws IOException;

    void reverseMapItemsInBatch(Context context, Iterator<Item> itemsToMap, List<Collection> sources,
        List<Collection> destinations, boolean dryRun) throws SQLException;
}
