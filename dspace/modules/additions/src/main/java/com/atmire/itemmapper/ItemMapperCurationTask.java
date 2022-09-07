package com.atmire.itemmapper;

import static com.atmire.itemmapper.ItemMapperConsumer.CONSUMER_MAPPING_FILE_LOCATION;
import static com.atmire.itemmapper.ItemMapperConsumer.CONSUMER_MAPPING_FILE_PATH;
import static com.atmire.itemmapper.ItemMapperConsumer.FULL_PATH_TO_FILE;
import static com.atmire.itemmapper.ParametrizedItemMappingScript.LOCAL;
import static com.atmire.itemmapper.ParametrizedItemMappingScript.MAPPED;
import static com.atmire.itemmapper.ParametrizedItemMappingScript.URL;
import static org.dspace.curate.Curator.CURATE_ERROR;
import static org.dspace.curate.Curator.CURATE_SUCCESS;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.atmire.itemmapper.factory.ItemMapperServiceFactory;
import com.atmire.itemmapper.model.CuniMapFile;
import com.atmire.itemmapper.service.ItemMapperService;
import org.apache.log4j.Logger;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.curate.AbstractCurationTask;
import org.dspace.curate.Curator;

public class ItemMapperCurationTask extends AbstractCurationTask {

    private static Logger log = Logger.getLogger(ItemMapperConsumer.class);
    ItemMapperService itemMapperService = ItemMapperServiceFactory.getInstance().getItemMapperService();

    List<Item> itemList = new ArrayList<>();
    CuniMapFile cuniMapFile;

    @Override
    protected void performItem(Item item) throws SQLException, IOException {
        itemList.clear();

        if (CONSUMER_MAPPING_FILE_LOCATION.equals(URL) && itemMapperService.isLinkValid()) {
            log.info(String.format("ItemMapperCurationTask: Starting map-items curation on item ( %s | %s ) based on " +
                "URL: %s", item.getID(), item.getHandle(), CONSUMER_MAPPING_FILE_PATH));
            cuniMapFile = itemMapperService.getMapFileFromLink(CONSUMER_MAPPING_FILE_PATH);
            itemMapperService.addItemToListIfInSourceCollection(Curator.curationContext(), item, cuniMapFile, itemList);

            try {
                itemMapperService.checkMetadataValuesAndConvertToString(Curator.curationContext(), itemList.iterator(), cuniMapFile,
                                                                        MAPPED, false);
            } catch (Exception e) {
                log.error("ItemMapperCurationTask: An exception occurred while mapping items", e);
            }
        }

        else if (CONSUMER_MAPPING_FILE_LOCATION.equals(LOCAL) && itemMapperService.doesFileExist()) {
            log.info(String
                .format("ItemMapperCurationTask: Starting map-items curation on item ( %s | %s ) based on %s JSON",
                    item.getHandle(), item.getID().toString(), CONSUMER_MAPPING_FILE_LOCATION));
            cuniMapFile = itemMapperService.getMapFileFromPath(FULL_PATH_TO_FILE);
            itemMapperService.addItemToListIfInSourceCollection(Curator.curationContext(), item, cuniMapFile, itemList);

            try {
                itemMapperService.checkMetadataValuesAndConvertToString(Curator.curationContext(), itemList.iterator(), cuniMapFile,
                                                                        MAPPED, false);
            } catch (Exception e) {
                log.error("ItemMapperCurationTask: An exception occurred while mapping items", e);
            }
        }

    }

    @Override
    public int perform(DSpaceObject dso) throws IOException {
        try {
            performObject(dso);
        } catch (Exception e) {
            return CURATE_ERROR;
        }
        return CURATE_SUCCESS;
    }
}
