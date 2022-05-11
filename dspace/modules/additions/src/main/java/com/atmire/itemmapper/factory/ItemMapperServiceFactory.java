package com.atmire.itemmapper.factory;

import com.atmire.itemmapper.service.ItemMapperService;
import org.dspace.services.factory.DSpaceServicesFactory;

public abstract class ItemMapperServiceFactory {

    public abstract ItemMapperService getItemMapperService();

    public static ItemMapperServiceFactory getInstance() {
        return DSpaceServicesFactory.getInstance().getServiceManager()
                                    .getServiceByName("itemMapperServiceFactory", ItemMapperServiceFactory.class);
    }
}
