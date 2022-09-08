package com.atmire.itemmapper.factory;

import com.atmire.itemmapper.service.ItemMapperService;
import org.springframework.beans.factory.annotation.Autowired;

public class ItemMapperServiceFactoryImpl extends ItemMapperServiceFactory {

        @Autowired(required = true)
        private ItemMapperService itemMapperService;

        @Override
        public ItemMapperService getItemMapperService() {
        return itemMapperService;
        }
}
