/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.xmlui.aspect.eperson;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;

import org.apache.avalon.framework.parameters.Parameters;
import org.apache.cocoon.acting.AbstractAction;
import org.apache.cocoon.environment.ObjectModelHelper;
import org.apache.cocoon.environment.Redirector;
import org.apache.cocoon.environment.Request;
import org.apache.cocoon.environment.SourceResolver;
import org.apache.cocoon.environment.http.HttpEnvironment;
import org.apache.cocoon.sitemap.PatternException;
import org.dspace.app.xmlui.utils.AuthenticationUtil;
import org.dspace.services.factory.DSpaceServicesFactory;
import org.dspace.core.Context;
import org.dspace.eperson.EPerson;

/**
 * Attempt to authenticate the user based upon their presented credentials. 
 * This action uses the HTTP parameters of login_email, login_password, and
 * login_realm as credentials.
 * 
 * <p>If the authentication attempt is successful then an HTTP redirect will be
 * sent to the browser redirecting them to their original location in the 
 * system before authenticated or if none is supplied back to the DSpace 
 * home page. The action will also return true, thus contents of the action will
 * be executed.
 *
 * <p>If the authentication attempt fails, the action returns false.
 *
 * <p>Example use:
 *
 * <pre>
 * {@code
 * <map:act name="Authenticate">
 *   <map:serialize type="xml"/>
 * </map:act>
 * <map:transform type="try-to-login-again-transformer">
 * }
 * </pre>
 *
 * @author Scott Phillips
 */
public class AuthenticateAction extends AbstractAction
{
    /**
     * Attempt to authenticate the user. 
     * @param redirector redirector.
     * @param resolver source resolver.
     * @param objectModel object model.
     * @param source source
     * @param parameters sitemap parameters.
     * @return result of the action.
     * @throws java.lang.Exception on error.
     */
    @Override
    public Map act(Redirector redirector, SourceResolver resolver, Map objectModel,
            String source, Parameters parameters) throws Exception
    {
        // First check if we are performing a new login
        Request request = ObjectModelHelper.getRequest(objectModel);

        String email = request.getParameter("login_email");
        String password = request.getParameter("login_password");
        String realm = request.getParameter("login_realm");

        // Protect against NPE errors inside the authentication
        // class.
        if ((email == null) || (password == null))
		{
			return null;
		}
        
        try
        {
            Context context = AuthenticationUtil.authenticate(objectModel, email,password, realm);

            EPerson eperson = context.getCurrentUser();

            if (eperson != null)
            {
            	// The user has successfully logged in
            	String redirectURL = request.getContextPath();
            	
            	if (AuthenticationUtil.isInterupptedRequest(objectModel))
            	{
            		// Resume the request and set the redirect target URL to
            		// that of the originally interrupted request.
            		redirectURL += AuthenticationUtil.resumeInterruptedRequest(objectModel);
            	}
            	else
            	{
            		// Otherwise direct the user to the specified 'loginredirect' page (or homepage by default)
            		String loginRedirect = DSpaceServicesFactory.getInstance().getConfigurationService().getProperty("xmlui.user.loginredirect");
            		
                    // if loginredirect is not set in cfg file (e.g. is null)
                    // set loginredirect to be the one stored in session in attribute xmlui.user.loginredirect
                    if(loginRedirect==null) {
            			loginRedirect = (String)request.getSession().getAttribute("xmlui.user.loginredirect");
            		}

                    // if loginRedirect is not set in cfg file OR loginredirect set in cfg file ends with 'login' string
                    // set login redirect to homepage ('/')
            		if(loginRedirect == null || loginRedirect.endsWith("login")) {
            			loginRedirect = "/";
            		}     
                    // if loginredirect is set an has a value '/', trim the trailing slash and send a redirect (see code below)
                    redirectURL += (loginRedirect != null) ? loginRedirect.trim() : "/";	
            	}
            	
                // Authentication successful send a redirect.
                final HttpServletResponse httpResponse = (HttpServletResponse) objectModel.get(HttpEnvironment.HTTP_RESPONSE_OBJECT);
                
                httpResponse.sendRedirect(redirectURL);
                
                // log the user out for the rest of this current request, however they will be reauthenticated
                // fully when they come back from the redirect. This prevents caching problems where part of the
                // request is performed before the user was authenticated and the other half after it succeeded. This
                // way the user is fully authenticated from the start of the request.
                context.setCurrentUser(null);
                
                return new HashMap();
            }
        }
        catch (SQLException sqle)
        {
            throw new PatternException("Unable to perform authentication",
                    sqle);
        }
        
        return null;
    }

}