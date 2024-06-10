/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.xmlui.utils;

import org.apache.cocoon.environment.ObjectModelHelper;
import org.apache.cocoon.environment.Request;
import org.apache.commons.collections.CollectionUtils;
import org.dspace.app.xmlui.wing.Message;
import org.dspace.app.xmlui.wing.WingException;
import org.dspace.app.xmlui.wing.element.PageMeta;
import org.dspace.content.*;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.CollectionService;
import org.dspace.content.service.CommunityService;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.handle.factory.HandleServiceFactory;
import org.dspace.handle.service.HandleService;
import org.dspace.services.factory.DSpaceServicesFactory;
import org.dspace.translation.TranslateService;

import org.apache.commons.lang.StringUtils; //
import org.apache.http.HttpEntity; //
import org.apache.http.HttpResponse; //
import org.apache.http.client.methods.HttpPost; //
import org.apache.http.entity.ContentType; //
import org.apache.http.entity.mime.MultipartEntityBuilder; //
import org.apache.http.impl.client.CloseableHttpClient; //
import org.apache.http.impl.client.HttpClients; //
import org.json.JSONObject; //
import org.json.JSONException; //

import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.Stack;

/**
 * Simple utility class for reCaptchaValidation.
 * 
 * @author Jakub Řihák
 */
public class ReCaptchaUtil
{

    protected static final String RECATPCHA_RESPONSE_PARAM = "g-recaptcha-response";
    // <JR> - get reCAPTCHA API url from config file
    protected static final String RECAPTCHA_API_URL = DSpaceServicesFactory.getInstance().getConfigurationService().getProperty("xmlui.cuni.recaptcha.url");
    // <JR> - get reCAPTCHA secret key from config file 
    // (sitekey and secret key pair is generated in reCAPTCHA admin console when setting up a site)
    protected static final String RECAPTCHA_SECRET = DSpaceServicesFactory.getInstance().getConfigurationService().getProperty("xmlui.cuni.recaptcha.secretkey");
    
    
    /**
     * Creates HTTP POST request for reCAPTCHA validation and sends
     * it. Returns HTTP response with some reCAPTCHA API reponse data used for validation.
     * 
     * @param recaptchaResponse
     *            (Required) Value of g-recaptcha-response param.
     * @param remoteIpAddress
     *            (Required) Address of the user doing the reCAPTCHA validation
     */
    public static HttpResponse sendValidateRecaptchaRequest(String recaptchaResponse, String remoteIPAddress)
        throws Exception
    {

        //TODO Xforwardfor
    
        //<JR> - check if fromIPAddress is not blank
        if (StringUtils.isBlank(remoteIPAddress)) {
            throw new Exception("'fromIPAddress' is blank");
        }
        
        // <JR> create an http request and post created payload for reCAPTCHA evaluation
        CloseableHttpClient httpClient = HttpClients.createDefault();
        HttpPost httpPost = new HttpPost(RECAPTCHA_API_URL);
        
        MultipartEntityBuilder builder = MultipartEntityBuilder.create();
        builder.addTextBody("secret", RECAPTCHA_SECRET, ContentType.TEXT_PLAIN);
        builder.addTextBody("response", recaptchaResponse, ContentType.TEXT_PLAIN);
        builder.addTextBody("remoteip", remoteIPAddress, ContentType.TEXT_PLAIN);
        
        // <JR> - Build POST request payload
        HttpEntity entity = builder.build();
        httpPost.setEntity(entity);

        // <JR> - post payload and log the response
        HttpResponse httpResponse = httpClient.execute(httpPost);
        return httpResponse;

    }

    /**
     * Checks the reCAPTCHA server return status and validates the reCAPTCHA API response
     * if return status is 200.
     * 
     * @param recaptchaServerStatus
     *            (Required) HTTP response status.
     * @param recaptchaResponseString
     *            (Required) reCAPTCHA response data used for validation parsed as a String
     * 
     * @throws JSONException
     *            throws a JSONException when there's a problem with parsin recaptchaResponseString
     *            to JSON.
     */
    public static boolean checkReCaptchaValidationResponseStatus(Integer recaptchaServerStatus, 
    String recaptchaResponseString) 
        throws JSONException
    {
        boolean validRecaptcha = false;
        
        if (recaptchaServerStatus != 200) {
            validRecaptcha = false;
        } else {
            
            try {
                JSONObject recaptchaJSONResponse = new JSONObject(recaptchaResponseString);
                if (recaptchaJSONResponse.getBoolean("success")) {
                        validRecaptcha = true;
                } else {
                    validRecaptcha = false;
                }
            } catch (JSONException ex) {
                validRecaptcha = false;
                throw ex;
            }
        }

        return validRecaptcha;
    }

    public static String getRecaptchaResponseParam()
    {
        return RECATPCHA_RESPONSE_PARAM;
    }

}