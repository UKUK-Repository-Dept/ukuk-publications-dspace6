
package com.atmire.itemmapper.model;

import javax.annotation.Generated;
import com.google.gson.annotations.SerializedName;

@Generated("net.hexar.json2pojo")
@SuppressWarnings("unused")
public class MetadataField {

    @SerializedName("field_identifier")
    private String mFieldIdentifier;
    @SerializedName("field_type")
    private String mFieldType;

    public String getField_identifier() {
        return mFieldIdentifier;
    }

    public void setField_identifier(String fieldIdentifier) {
        mFieldIdentifier = fieldIdentifier;
    }

    public String getField_type() {
        return mFieldType;
    }

    public void setField_type(String fieldType) {
        mFieldType = fieldType;
    }

}
