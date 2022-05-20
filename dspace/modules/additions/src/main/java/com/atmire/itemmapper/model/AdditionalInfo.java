
package com.atmire.itemmapper.model;

import javax.annotation.Generated;
import com.google.gson.annotations.SerializedName;

@Generated("net.hexar.json2pojo")
@SuppressWarnings("unused")
public class AdditionalInfo {

    @SerializedName("description")
    private String mDescription;
    @SerializedName("parent_id")
    private ParentId mParentId;

    public String getDescription() {
        return mDescription;
    }

    public void setDescription(String description) {
        mDescription = description;
    }

    public ParentId getParent_id() {
        return mParentId;
    }

    public void setParent_id(ParentId parentId) {
        mParentId = parentId;
    }

}
