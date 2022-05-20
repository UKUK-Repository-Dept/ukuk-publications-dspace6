
package com.atmire.itemmapper.model;

import java.util.List;
import javax.annotation.Generated;
import com.google.gson.annotations.SerializedName;

@Generated("net.hexar.json2pojo")
@SuppressWarnings("unused")
public class Mapfile {

    @SerializedName("mapping_records")
    private List<MappingRecord> mMappingRecords;
    @SerializedName("metadata_fields")
    private List<MetadataField> mMetadataFields;
    @SerializedName("name")
    private String mName;
    @SerializedName("source_collections")
    private List<SourceCollection> mSourceCollections;

    public List<MappingRecord> getMapping_records() {
        return mMappingRecords;
    }

    public void setMapping_records(List<MappingRecord> mappingRecords) {
        mMappingRecords = mappingRecords;
    }

    public List<MetadataField> getMetadata_fields() {
        return mMetadataFields;
    }

    public void setMetadata_fields(List<MetadataField> metadataFields) {
        mMetadataFields = metadataFields;
    }

    public String getName() {
        return mName;
    }

    public void setName(String name) {
        mName = name;
    }

    public List<SourceCollection> getSource_collections() {
        return mSourceCollections;
    }

    public void setSource_collections(List<SourceCollection> sourceCollections) {
        mSourceCollections = sourceCollections;
    }

}
