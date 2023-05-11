/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.content.packager;

// <JR> 2023-05-11 - Fix imports since we are overriding methods that use them, in contrast to a regular DSpaceMETSIngester
import java.io.File;
import org.dspace.workflow.WorkflowException;
import org.apache.log4j.Logger;
import org.dspace.core.LogManager;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.InProgressSubmission;
import org.dspace.workflow.factory.WorkflowServiceFactory;

import java.io.IOException;
import java.io.InputStream;
import java.sql.SQLException;

import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Bitstream;
import org.dspace.content.Collection;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.content.crosswalk.CrosswalkException;
import org.dspace.content.crosswalk.MetadataValidationException;
import org.dspace.core.Context;
import org.dspace.core.Constants;
import org.dspace.app.mediafilter.MediaFilter;
import org.dspace.core.factory.CoreServiceFactory;
import org.dspace.core.service.PluginService;

import org.jdom.Element;

/**
 * Packager plugin to ingest a
 * METS (Metadata Encoding and Transmission Standard) package
 * that conforms to the DSpace METS SIP (Submission Information Package) Profile.
 * See <a href="http://www.loc.gov/standards/mets/">http://www.loc.gov/standards/mets/</a>
 * for more information on METS, and
 * <a href="http://www.dspace.org/standards/METS/SIP/profilev0p9p1/metssipv0p9p1.pdf">
 * http://www.dspace.org/standards/METS/SIP/profilev0p9p1/metssipv0p9p1.pdf</a>
 * (or a similar file in the /standards/METS/SIP resource hierarchy)
 * for more information about the DSpace METS SIP profile.
 *
 * @author Larry Stone
 * @author Tim Donohue
 * @version $Revision$
 * @see org.dspace.content.packager.METSManifest
 * @see AbstractMETSIngester
 * @see AbstractPackageIngester
 * @see PackageIngester
 */
public class CUNIDSpaceMETSIngester
       extends AbstractMETSIngester
{

    /** log4j category */
    private static Logger log = Logger.getLogger(CUNIDSpaceMETSIngester.class);

    // first part of required mets@PROFILE value
    protected static final String PROFILE_START = "DSpace METS SIP Profile";

    /**
     * Choose DMD section(s) to crosswalk.
     * <p>
     * The algorithm is:<br>
     * 1. Use whatever the <code>dmd</code> parameter specifies as the primary DMD.<br>
     * 2. If (1) is unspecified, find MODS (preferably) or DC as primary DMD.<br>
     * 3. If (1) or (2) succeeds, crosswalk it and ignore all other DMDs with
     *    same GROUPID<br>
     * 4. Crosswalk remaining DMDs not eliminated already.
     * @throws CrosswalkException if crosswalk error
     * @throws PackageValidationException if validation error
     * @throws IOException if IO error
     * @throws SQLException if database error
     * @throws AuthorizeException if authorization error
     */
    @Override
    public void crosswalkObjectDmd(Context context, DSpaceObject dso,
                              METSManifest manifest,
                              MdrefManager callback,
                              Element dmds[], PackageParameters params)
        throws CrosswalkException, PackageValidationException,
               AuthorizeException, SQLException, IOException
    {
        int found = -1;

        // Check to see what dmdSec the user specified in the 'dmd' parameter
        String userDmd = null;
        if (params != null)
        {
            userDmd = params.getProperty("dmd");
        }
        if (userDmd != null && userDmd.length() > 0)
        {
            for (int i = 0; i < dmds.length; ++i)
            {
                if (userDmd.equalsIgnoreCase(manifest.getMdType(dmds[i])))
                {
                    found = i;
                }
            }
        }

        // MODS is preferred, if nothing specified by user
        if (found == -1)
        {
            for (int i = 0; i < dmds.length; ++i)
            {
                //NOTE: METS standard actually says this should be MODS (all uppercase). But,
                // just in case, we're going to be a bit more forgiving.
                if ("MODS".equalsIgnoreCase(manifest.getMdType(dmds[i])))
                {
                    found = i;
                }
            }
        }

        // DC acceptable if no MODS
        if (found == -1)
        {
            for (int i = 0; i < dmds.length; ++i)
            {
                //NOTE: METS standard actually says this should be DC (all uppercase). But,
                // just in case, we're going to be a bit more forgiving.
                if ("DC".equalsIgnoreCase(manifest.getMdType(dmds[i])))
                {
                    found = i;
                }
            }
        }

        String groupID = null;
        if (found >= 0)
        {
            manifest.crosswalkItemDmd(context, params, dso, dmds[found], callback);
            groupID = dmds[found].getAttributeValue("GROUPID");

            if (groupID != null)
            {
                for (int i = 0; i < dmds.length; ++i)
                {
                    String g = dmds[i].getAttributeValue("GROUPID");
                    if (g != null && !g.equals(groupID))
                    {
                        manifest.crosswalkItemDmd(context, params, dso, dmds[i], callback);
                    }
                }
            }
        }
        else
        {
            // otherwise take the first.  Don't xwalk more than one because
            // each xwalk _adds_ metadata, and could add duplicate fields.
            if (dmds.length > 0)
            {
                manifest.crosswalkItemDmd(context, params, dso, dmds[0], callback);
            }
        }
    }


    

    // just check the profile name.
    @Override
    void checkManifest(METSManifest manifest)
        throws MetadataValidationException
    {
        String profile = manifest.getProfile();
        if (profile == null)
        {
            throw new MetadataValidationException("Cannot accept METS with no PROFILE attribute!");
        }
        else if (!profile.startsWith(PROFILE_START))
        {
            throw new MetadataValidationException("METS has unacceptable PROFILE value, profile=" + profile);
        }
    }



    /**
     * Replace an existing DSpace object with the contents of a METS-based
     * package. All contents are dictated by the METS manifest. Package is a ZIP
     * archive (or optionally bare manifest XML document). In a Zip, all files
     * relative to top level and the manifest (as per spec) in mets.xml.
     * <P>
     * This method is similar to ingest(), except that if the object already
     * exists in DSpace, it is emptied of files and metadata. The METS-based
     * package is then used to ingest new values for these.
     * 
     * @param context
     *            DSpace Context
     * @param dsoToReplace
     *            DSpace Object to be replaced (may be null if it will be
     *            specified in the METS manifest itself)
     * @param pkgFile
     *            The package file to ingest
     * @param params
     *            Parameters passed from the packager script
     * @return DSpaceObject created by ingest.
     * @throws PackageValidationException if package validation error
     *             if package is unacceptable or there is a fatal error turning
     *             it into a DSpace Object.
     * @throws IOException if IO error
     * @throws SQLException if database error
     * @throws AuthorizeException if authorization error
     * @throws CrosswalkException if crosswalk error
     * @throws WorkflowException if workflow error
     */
    @Override
    public DSpaceObject replace(Context context, DSpaceObject dsoToReplace,
            File pkgFile, PackageParameters params)
            throws PackageValidationException, CrosswalkException,
            AuthorizeException, SQLException, IOException, WorkflowException {
        // parsed out METS Manifest from the file.
        METSManifest manifest = null;

        // resulting DSpace Object
        DSpaceObject dso = null;

        try
        {
            log.info(LogManager.getHeader(context, "package_parse",
                    "CUNIIIIIIII Parsing package for replace, file=" + pkgFile.getName()));

            // Parse our ingest package, extracting out the METS manifest in the
            // package
            manifest = parsePackage(context, pkgFile, params);

            // must have a METS Manifest to replace anything
            if (manifest == null)
            {
                throw new PackageValidationException(
                        "CUNIIIIIIII No METS Manifest found (filename="
                                + METSManifest.MANIFEST_FILE
                                + ").  Package is unacceptable!");
            }

            // It's possible that the object to replace will be passed in as
            // null.  Let's determine the handle of the object to replace.
            if (dsoToReplace == null)
            {
                // since we don't know what we are replacing, we'll have to
                // try to determine it from the parsed manifest

                // Handle of object described by METS should be in OBJID
                String handleURI = manifest.getObjID();
                String handle = decodeHandleURN(handleURI);
                try
                {
                    // Attempt to resolve this handle to an existing object
                    dsoToReplace = handleService.resolveToObject(context,
                            handle);
                }
                catch (IllegalStateException ie)
                {
                    // We don't care if this errors out -- we can continue
                    // whether or not an object exists with this handle.
                }
            }
            // NOTE: At this point, it's still possible we don't have an object
            // to replace. This could happen when there is actually no existing
            // object in DSpace using that handle. (In which case, we're
            // actually just doing a "restore" -- so we aren't going to throw an
            // error or complain.)

            // If we were unable to find the object to replace, then assume we
            // are restoring it
            if (dsoToReplace == null)
            {
                // As this object doesn't already exist, we will perform an
                // ingest of a new object in order to restore it
                // NOTE: passing 'null' as parent object in order to force
                // ingestObject() method to determine parent using manifest.
                dso = ingestObject(context, null, manifest, pkgFile, params,
                        null);

                //if ingestion was successful
                if(dso!=null)
                {
                    // Log that we created an object
                    log.info(LogManager.getHeader(context, "package_replace",
                            "CUNIIIIIIII Created new Object, type="
                                    + Constants.typeText[dso.getType()]
                                    + ", handle=" + dso.getHandle() + ", dbID="
                                    + String.valueOf(dso.getID())));
                }
            }
            else
            // otherwise, we found the DSpaceObject to replace -- so, replace
            // it!
            {
                // Actually replace the object described by the METS Manifest.
                // NOTE: This will perform an in-place replace of all metadata
                // and files currently associated with the object.
                dso = replaceObject(context, dsoToReplace, manifest, pkgFile,
                        params, null);

                // Log that we replaced an object
                log.info(LogManager.getHeader(context, "package_replace",
                        "CUNIIIIIIII Replaced Object, type="
                                + Constants.typeText[dso.getType()]
                                + ", handle=" + dso.getHandle() + ", dbID="
                                + String.valueOf(dso.getID())));
            }

            //if ingest/restore/replace successful
            if(dso!=null)
            {
                // Check if the Packager is currently running recursively.
                // If so, this means the Packager will attempt to recursively
                // replace all referenced child packages.
                if (params.recursiveModeEnabled())
                {
                    // Retrieve list of all Child object METS file paths from the
                    // current METS manifest.
                    // This is our list of known child packages.
                    String[] childFilePaths = manifest.getChildMetsFilePaths();

                    // Save this list to our AbstractPackageIngester (and note which
                    // DSpaceObject the pkgs relate to)
                    // NOTE: The AbstractPackageIngester itself will perform the
                    // recursive ingest call, based on these child pkg references.
                    for (int i = 0; i < childFilePaths.length; i++)
                    {
                        addPackageReference(dso, childFilePaths[i]);
                    }
                }
            }

            return dso;
        }
        catch (SQLException se)
        {
            // no need to really clean anything up,
            // transaction rollback will get rid of it anyway, and will also
            // restore everything to previous state.
            dso = null;

            // Pass this exception on to the next handler.
            throw se;
        }
    }

/**
     * Replace the contents of a single DSpace Object, based on the associated
     * METS Manifest and the parameters passed to the METSIngester.
     * 
     * @param context
     *            DSpace Context
     * @param dso
     *            DSpace Object to replace
     * @param manifest
     *            the parsed METS Manifest
     * @param pkgFile
     *            the full package file (which may include content files if a
     *            zip)
     * @param params
     *            Parameters passed to METSIngester
     * @param license
     *            DSpace license agreement
     * @return completed result as a DSpace object
     * @throws IOException if IO error
     * @throws SQLException if database error
     * @throws AuthorizeException if authorization error
     * @throws CrosswalkException if crosswalk error
     * @throws MetadataValidationException if metadata validation error
     * @throws PackageValidationException if package validation error
     */
    @Override
    protected DSpaceObject replaceObject(Context context, DSpaceObject dso,
            METSManifest manifest, File pkgFile, PackageParameters params,
            String license) throws IOException, SQLException,
            AuthorizeException, CrosswalkException,
            MetadataValidationException, PackageValidationException
    {
        // -- Step 1 --
        // Before going forward with the replace, let's verify these objects are
        // of the same TYPE! (We don't want to go around trying to replace a
        // COMMUNITY with an ITEM -- that's dangerous.)
        int manifestType = getObjectType(manifest);
        if (manifestType != dso.getType())
        {
            throw new PackageValidationException(
                    "CUNIIIIIIII The object type of the METS manifest ("
                            + Constants.typeText[manifestType]
                            + ") does not match up with the object type ("
                            + Constants.typeText[dso.getType()]
                            + ") of the DSpaceObject to be replaced!");
        }

        if (log.isDebugEnabled())
        {
            log.debug("CUNIIIIIIII Object to be replaced (handle=" + dso.getHandle()
                    + ") is " + Constants.typeText[dso.getType()] + " id="
                    + dso.getID());
        }

        // -- Step 2 --
        // Clear out current object (as we are replacing all its contents &
        // metadata)

        // remove all files attached to this object
        // (For communities/collections this just removes the logo bitstream)
        PackageUtils.removeAllBitstreams(context, dso);

        // clear out all metadata values associated with this object
        // <JR> 2023-05-11
        //PackageUtils.clearAllMetadata(context, dso);
        PackageUtils.clearAllMetadataExceptOriginalDates(context, dso);

        // TODO -- We are currently NOT clearing out the following during a
        // replace.  So, even after a replace, the following information may be
        // retained in the system:
        // o  Rights/Permissions in system or on objects
        // o  Collection item templates or Content Source info (e.g. OAI
        //    Harvesting collections)
        // o  Item status (embargo, withdrawn) or mappings to other collections

        // -- Step 3 --
        // Run our Administrative metadata crosswalks!

        // initialize callback object which will retrieve external inputstreams
        // for any <mdRef>s found in METS

        // <JR> - 2023-05-11: FIX: /opt/dspace.build/dspace/modules/additions/src/main/java/cz/cuni/content/packager/CUNIDSpaceMETSIngester.java:[431,54] 
        // MdrefManager(java.io.File,org.dspace.content.packager.PackageParameters) has private access in org.dspace.content.packager.AbstractMETSIngester.MdrefManager
        MdrefManager callback = new MdrefManager(pkgFile, params);

        // Crosswalk the sourceMD first, so that we make sure to fill in
        // submitter info (and any other initial applicable info)
        manifest.crosswalkObjectSourceMD(context, params, dso, callback);

        // Next, crosswalk techMD, digiprovMD, rightsMD
        manifest.crosswalkObjectOtherAdminMD(context, params, dso, callback);

        // -- Step 4 --
        // Add all content files as bitstreams on new DSpace Object
        if (dso.getType() == Constants.ITEM)
        {
            Item item = (Item) dso;

            // save manifest as a bitstream in Item if desired
            if (preserveManifest())
            {
                addManifestBitstream(context, item, manifest);
            }

            // save all other bitstreams in Item
            addBitstreams(context, item, manifest, pkgFile, params, callback);

            // have subclass manage license since it may be extra package file.
            Collection owningCollection = (Collection) ContentServiceFactory.getInstance().getDSpaceObjectService(dso).getParentObject(context, dso);
            if(owningCollection == null)
            {
                //We are probably dealing with an item that isn't archived yet
                InProgressSubmission inProgressSubmission = workspaceItemService.findByItem(context, item);
                if(inProgressSubmission == null)
                {
                    inProgressSubmission = WorkflowServiceFactory.getInstance().getWorkflowItemService().findByItem(context, item);
                }
                owningCollection = inProgressSubmission.getCollection();
            }

            addLicense(context, item, license, owningCollection
                    , params);

            // FIXME ?
            // should set lastModifiedTime e.g. when ingesting AIP.
            // maybe only do it in the finishObject() callback for AIP.

        } // end if ITEM
        else if (dso.getType() == Constants.COLLECTION
                || dso.getType() == Constants.COMMUNITY)
        {
            // Add logo if one is referenced from manifest
            addContainerLogo(context, dso, manifest, pkgFile, params);
        } // end if Community/Collection
        else if (dso.getType() == Constants.SITE)
        {
            // Do nothing -- Crosswalks will handle anything necessary to replace at Site-level
        }

        // -- Step 5 --
        // Run our Descriptive metadata (dublin core, etc) crosswalks!
        crosswalkObjectDmd(context, dso, manifest, callback, manifest
                .getItemDmds(), params);

        // For Items, also sanity-check the metadata for minimum requirements.
        if (dso.getType() == Constants.ITEM)
        {
            PackageUtils.checkItemMetadata((Item) dso);
        }

        // -- Step 6 --
        // Finish things up!

        // Subclass hook for final checks and rearrangements
        // (this allows subclasses to do some final validation / changes as
        // necessary)
        finishObject(context, dso, params);

        // Update the object to make sure all changes are committed
        PackageUtils.updateDSpaceObject(context, dso);

        return dso;
    }


    


    /**
     * Policy:  For DSpace deposit license, take deposit license
     * supplied by explicit argument first, else use collection's
     * default deposit license.
     * For Creative Commons, look for a rightsMd containing a CC license.
     * @throws PackageValidationException if validation error
     * @throws IOException if IO error
     * @throws SQLException if database error
     * @throws AuthorizeException if authorization error
     */
    @Override
    public void addLicense(Context context, Item item, String license,
                                    Collection collection, PackageParameters params)
        throws PackageValidationException,
               AuthorizeException, SQLException, IOException
    {
        if (PackageUtils.findDepositLicense(context, item) == null)
        {
            PackageUtils.addDepositLicense(context, license, item, collection);
        }
    }

    @Override
    public void finishObject(Context context, DSpaceObject dso,
                             PackageParameters params)
        throws PackageValidationException, CrosswalkException,
         AuthorizeException, SQLException, IOException
    {
        // nothing to do.
    }

    @Override
    public int getObjectType(METSManifest manifest)
        throws PackageValidationException
    {
        return Constants.ITEM;
    }

    // return name of derived file as if MediaFilter created it, or null
    // only needed when importing a SIP without canonical DSpace derived file naming.
    private String makeDerivedFilename(String bundleName, String origName)
    {
        PluginService pluginService = CoreServiceFactory.getInstance().getPluginService();

        // get the MediaFilter that would create this bundle:
        String mfNames[] = pluginService.getAllPluginNames(MediaFilter.class);

        for (int i = 0; i < mfNames.length; ++i)
        {
            MediaFilter mf = (MediaFilter)pluginService.getNamedPlugin(MediaFilter.class, mfNames[i]);
            if (bundleName.equals(mf.getBundleName()))
            {
                return mf.getFilteredName(origName);
            }
        }

        return null;
    }

    /**
     * Take a second pass over files to correct names of derived files
     * (e.g. thumbnails, extracted text) to what DSpace expects:
     * @throws MetadataValidationException if validation error
     * @throws IOException if IO error
     * @throws SQLException if database error
     * @throws AuthorizeException if authorization error
     */
    @Override
    public void finishBitstream(Context context,
                                                Bitstream bs,
                                                Element mfile,
                                                METSManifest manifest,
                                                PackageParameters params)
        throws MetadataValidationException, SQLException, AuthorizeException, IOException
    {
        String bundleName = METSManifest.getBundleName(mfile);
        if (!bundleName.equals(Constants.CONTENT_BUNDLE_NAME))
        {
            String opath = manifest.getOriginalFilePath(mfile);
            if (opath != null)
            {
                // String ofileId = origFile.getAttributeValue("ID");
                // Bitstream obs = (Bitstream)fileIdToBitstream.get(ofileId);

                String newName = makeDerivedFilename(bundleName, opath);

                if (newName != null)
                {
                    //String mfileId = mfile.getAttributeValue("ID");
                    //Bitstream bs = (Bitstream)fileIdToBitstream.get(mfileId);
                    bs.setName(context, newName);
                    bitstreamService.update(context, bs);
                }
            }
        }
    }

    @Override
    public String getConfigurationName()
    {
        return "dspaceSIP";
    }


    public boolean probe(Context context, InputStream in, PackageParameters params)
    {
        throw new UnsupportedOperationException("PDF package ingester does not implement probe()");
    }

    /**
     * Returns a user help string which should describe the
     * additional valid command-line options that this packager
     * implementation will accept when using the <code>-o</code> or
     * <code>--option</code> flags with the Packager script.
     *
     * @return a string describing additional command-line options available
     * with this packager
     */
    @Override
    public String getParameterHelp()
    {
        String parentHelp = super.getParameterHelp();

        //Return superclass help info, plus the extra parameter/option that this class supports
        return parentHelp +
                "\n\n" +
                "* dmd=[dmdSecType]      " +
                   "Type of the METS <dmdSec> which should be used for primary item metadata (defaults to MODS, then DC)";
    }
}
