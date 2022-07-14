package com.atmire.itemmapper.model;

import static com.atmire.itemmapper.service.ItemMapperServiceImpl.WARN;
import static org.apache.commons.lang.StringUtils.isBlank;

import com.atmire.itemmapper.factory.ItemMapperServiceFactory;
import com.atmire.itemmapper.service.ItemMapperService;
import com.google.gson.annotations.SerializedName;

public class GenericCollection {

    ItemMapperService itemMapperService = ItemMapperServiceFactory.getInstance().getItemMapperService();

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
        if (id.getValue() == null || id.getType() == null) {
            throw new IllegalArgumentException("Id must have a value and type");
        }

        mId = id;
    }

    public String getName_cs() {
        return mNameCs;
    }

    public void setName_cs(String nameCs) {
        if (isBlank(nameCs)) {
            itemMapperService.logCLI(WARN, "name_cs is empty for collection with " +
                mId.getType() + " " + mId.getValue());
        }
        mNameCs = nameCs;
    }

    public String getName_en() {
        return mNameEn;
    }

    public void setName_en(String nameEn) {
        if (isBlank(nameEn)) {
            itemMapperService.logCLI(WARN, "name_en is empty for collection with " +
                mId.getType() + " " + mId.getValue());
        }
        mNameEn = nameEn;
    }

}
