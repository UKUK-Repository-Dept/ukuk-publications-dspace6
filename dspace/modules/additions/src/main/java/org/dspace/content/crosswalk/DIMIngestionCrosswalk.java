package org.dspace.content.crosswalk;
import org.apache.log4j.Logger;
/** 
 * Custom ingestion crosswalk that applies an XSLT transformation
 * to DIM metadata during METS ingest. 
 * 
 * This class extends the standard XSLTIngestionCrosswalk and can be * registered under the alias "DIM" to override the default DIMIngestionCrosswalk. 
*/
public class DIMIngestionCrosswalk extends XSLTIngestionCrosswalk {

    private static final Logger log = Logger.getLogger(DIMIngestionCrosswalk.class);
    
    public DIMIngestionCrosswalk() {
        super();
        log.info("Custom DIMIngestionCrosswalk initialized.");
    }
}