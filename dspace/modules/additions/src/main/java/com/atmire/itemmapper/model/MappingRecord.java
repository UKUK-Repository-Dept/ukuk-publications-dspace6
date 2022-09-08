
package com.atmire.itemmapper.model;

import java.util.List;
import javax.annotation.Generated;
import com.google.gson.annotations.SerializedName;

@Generated("net.hexar.json2pojo")
@SuppressWarnings("unused")
public class MappingRecord {

    @SerializedName("metadata_value")
    private String mMetadataValue;
    @SerializedName("record_id")
    private Long mRecordId;
    @SerializedName("target_collections")
    private List<TargetCollection> mTargetCollections;

    public String getMetadata_value() {
        return mMetadataValue;
    }

    public void setMetadata_value(String metadataValue) {
        mMetadataValue = metadataValue;
    }

    public Long getRecord_id() {
        return mRecordId;
    }

    public void setRecord_id(Long recordId) {
        mRecordId = recordId;
    }

    public List<TargetCollection> getTarget_collections() {
        return mTargetCollections;
    }

    public void setTarget_collections(List<TargetCollection> targetCollections) {
        mTargetCollections = targetCollections;
    }

}
