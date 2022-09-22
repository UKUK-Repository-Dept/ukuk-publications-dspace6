
package com.atmire.itemmapper.model;

import static com.atmire.itemmapper.service.ItemMapperServiceImpl.WARN;

import java.sql.SQLException;
import java.util.UUID;
import javax.annotation.Generated;

import com.atmire.itemmapper.factory.ItemMapperServiceFactory;
import com.atmire.itemmapper.service.ItemMapperService;
import com.google.gson.annotations.SerializedName;
import org.dspace.content.Collection;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.CollectionService;
import org.dspace.core.Context;
import org.dspace.handle.factory.HandleServiceFactory;
import org.dspace.handle.service.HandleService;

@Generated("net.hexar.json2pojo")
@SuppressWarnings("unused")
public class Id {

    ItemMapperService itemMapperService = ItemMapperServiceFactory.getInstance().getItemMapperService();
    HandleService handleService = HandleServiceFactory.getInstance().getHandleService();
    CollectionService collectionService = ContentServiceFactory.getInstance().getCollectionService();

    @SerializedName("type")
    private String mType;
    @SerializedName("value")
    private String mValue;

    public String getType() {
        return mType;
    }

    public void setType(String type) {
        mType = type;
    }

    public String getValue() {
        return mValue;
    }

    public void setValue(String value) throws SQLException {
        Context context = new Context();
        Collection resolvedCollection;
        if (value.contains("/")) {
            resolvedCollection = (Collection) handleService.resolveToObject(context, value);
            if (resolvedCollection == null) {
                itemMapperService.logCLI(WARN, "Collection with handle " + value + " not found");
            }
        } else {
            resolvedCollection = collectionService.find(context, UUID.fromString(value));
            if (resolvedCollection == null) {
                itemMapperService.logCLI(WARN, "Collection with uuid " + value + " not found");
            }
        }
        mValue = value;
    }
}
