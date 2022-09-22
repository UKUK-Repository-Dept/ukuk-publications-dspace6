package org.dspace.translation;

import java.util.Locale;

import org.apache.commons.lang3.StringUtils;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.DSpaceObjectService;
import org.dspace.core.Context;

public class TranslateService {

    public String retrieveTranslationByContextLocale(Context context, DSpaceObject dSpaceObject) {
        Locale currentLocale = context.getCurrentLocale();
        String name = dSpaceObject.getName();


        if (StringUtils.equals(currentLocale.getLanguage(), "cs")) {
            DSpaceObjectService<DSpaceObject> dSpaceObjectService = ContentServiceFactory.getInstance()
                                                                                         .getDSpaceObjectService(
                                                                                                 dSpaceObject);



            String translatedCollectionTitle = dSpaceObjectService.getMetadataFirstValue(dSpaceObject, "dc",
                                                                                           "translatedcollectiontitle", null,
                                                                                           Item.ANY);
            if (StringUtils.isNotBlank(translatedCollectionTitle)) {
                name = translatedCollectionTitle;
            }
        }

       return name;

    }


}