/**
    @ Purpose : 1. Fetches the anchor links of all trucks from list views of BPAAparatus website.
                2. Passes these links to BPAapparatusDetailInfoBatch class.
*/
public class BPAapparatusDetailPageUrlBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
    
    public List<String> pageUrlList;
    
    public List<String> nextPageUrlList;
    
    public String siteId;
    
    public BPAapparatusDetailPageUrlBatch() {
        
        this.pageUrlList = new List<String>();
        this.nextPageUrlList = new List<String>();
        this.siteId = '';
    }
    
    public BPAapparatusDetailPageUrlBatch( List<String> pageUrlList, String siteId ) { 
        
        this();
        if( pageUrlList != NULL && !pageUrlList.isEmpty() ) {
            this.pageUrlList.addAll( pageUrlList );
        }
        this.siteId = siteId;
    }
    
    public Iterable<String> start( Database.BatchableContext BC ) {
        
        System.debug( 'BPAapparatusDetailPageUrlBatch-start-pageUrlList:-\n' + JSON.serialize( this.pageUrlList ) );
        return this.pageUrlList;
    }
    
    public void execute( Database.BatchableContext bc, List<String> urlList ) {
        
        for( String endPoint : urlList ) {
            this.nextPageUrlList.addAll( parseResponse( SiteCalloutHelper.getHtmlBody( endPoint ) ) );    
        }  
    }
    
    public void finish( Database.BatchableContext BC ) {
        
        System.debug( 'BPAapparatusDetailPageUrlBatch-finish-nextPageUrlList:-\n' + JSON.serialize( this.nextPageUrlList ) );
        if( !this.nextPageUrlList.isEmpty() ) {                            
            Database.executeBatch( new BPAapparatusDetailInfoBatch( this.nextPageUrlList, siteId ), 1 );
        }
    }
    
    private static Set<String> parseResponse( HTTPResponse httpResponse ) {
        
        System.debug( 'BPAapparatusDetailPageUrlBatch-httpResponse:-\n' + httpResponse );
        Set<String> urlSet = new Set<String>();
        if( httpResponse != NULL ) {
            
            String pageBody = httpResponse.getBody();
            if( String.isNotBlank( pageBody ) ) {
                pageBody = pageBody.substringBetween( '<table id="tablepress-1"', '</table' );
                if( String.isNotBlank( pageBody ) ) {
                    
                    pageBody = pageBody.substringBetween( '<tbody', '</tbody' );
                    if( String.isNotBlank( pageBody ) ) {
                        List<String> truckRecordRowList = pageBody.split( '</tr' );
                        
                        if( truckRecordRowList != NULL && !truckRecordRowList.isEmpty() ) {
                            String link;
                            for( String truckRecord : truckRecordRowList ) {
                                link = truckRecord.subStringBetween( 'href="', '"' );
                                if( String.isNotBlank( link ) ) {
                                    urlSet.add( link ); 
                                }
                            }
                        }
                    }
                }
            }
        }
        return urlSet;
    }    
}