package org.dspace.content.crosswalk;
import org.apache.log4j.Logger;
/** 
 * Custom ingestion crosswalk that applies an XSLT transformation
 * to DIM metadata during METS ingest. 
 * 
 * This class extends the standard XSLTIngestionCrosswalk and can be * registered under the alias "DIM" to override the default DIMIngestionCrosswalk. 
*/
public class CUNICRISDIMXSLTCrosswalk extends XSLTIngestionCrosswalk {

    private static final Logger log = Logger.getLogger(CUNICRISDIMXSLTCrosswalk.class);
    
    public CUNICRISDIMXSLTCrosswalk() {
        super();
        log.info("CUNICRISDIMXSLTCrosswalk initialized.");
    }
}