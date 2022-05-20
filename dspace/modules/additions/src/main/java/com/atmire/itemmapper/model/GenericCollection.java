package com.atmire.itemmapper.model;

import com.google.gson.annotations.SerializedName;

public class GenericCollection {

    @SerializedName("additional_info")
    private AdditionalInfo mAdditionalInfo;
    @SerializedName("id")
    private Id mId;
    @SerializedName("name_cs")
    private String mNameCs;
    @SerializedName("name_en")
    private String mNameEn;

    public AdditionalInfo getAdditional_info() {
        return mAdditionalInfo;
    }

    public void setAdditional_info(AdditionalInfo additionalInfo) {
        mAdditionalInfo = additionalInfo;
    }

    public Id getId() {
        return mId;
    }

    public void setId(Id id) {
        mId = id;
    }

    public String getName_cs() {
        return mNameCs;
    }

    public void setName_cs(String nameCs) {
        mNameCs = nameCs;
    }

    public String getName_en() {
        return mNameEn;
    }

    public void setName_en(String nameEn) {
        mNameEn = nameEn;
    }

}
