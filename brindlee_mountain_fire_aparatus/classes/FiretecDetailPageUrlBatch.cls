/**
    @ Purpose : 1. Fetches the anchor links of all trucks from list views of Firetec website.
                2. Passes these links to FiretecDetailInfoBatch class.
*/
public class FiretecDetailPageUrlBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
    
    public List<String> pageUrlList;
    
    public List<String> nextPageUrlList;
    
    public String siteId;
    
    public Map<String,String> pageUrlToCategory;
    
    public FiretecDetailPageUrlBatch() {
        
        this.pageUrlList = new List<String>();
        this.nextPageUrlList = new List<String>();
        this.pageUrlToCategory = new Map<String,String>();
        this.siteId = '';
    }
    
    public FiretecDetailPageUrlBatch( List<String> pageUrlList, String siteId ) {
        
        this();
        if( pageUrlList != NULL && !pageUrlList.isEmpty() ) {
            this.pageUrlList.addAll( pageUrlList );
        }
        this.siteId = siteId;
    }
    
    public Iterable<String> start( Database.BatchableContext BC ) {
        
        System.debug( 'FiretecDetailPageUrlBatch-start-pageUrlList:-\n' + JSON.serialize( this.pageUrlList ) );
        return this.pageUrlList;
    }
    
    public void execute( Database.BatchableContext bc, List<String> urlList ) {
        
        for( String endPoint : urlList ) {
            this.nextPageUrlList.addAll( parseResponse( SiteCalloutHelper.getHtmlBody( endPoint ), 
                                                        endPoint.subStringBefore( '/category' )
                                                      ) 
                                       );    
        }
        System.debug( 'FiretecDetailPageUrlBatch-nextPageUrlList:-\n' + JSON.serialize( this.nextPageUrlList ) );
    }
    
    public void finish( Database.BatchableContext BC ) {
        
        System.debug( 'FiretecDetailPageUrlBatch-finish-nextPageUrlList:-\n' + JSON.serialize( this.nextPageUrlList ) );
        if( !this.nextPageUrlList.isEmpty() ) {                            
            Database.executeBatch( new FiretecDetailInfoBatch( this.nextPageUrlList, siteId, this.pageUrlToCategory ), 1 );
        }
    }
    
    private Set<String> parseResponse( HTTPResponse httpResponse, String hostUrl ) {
        
        System.debug( 'FiretecDetailPageUrlBatch-httpResponse:-\n' + httpResponse );
        Set<String> urlSet = new Set<String>();
        if( httpResponse != NULL && String.isNotBlank( hostUrl ) ) {
           
            String pageBody = httpResponse.getBody();
            if( String.isNotBlank( pageBody ) ) {
                pageBody = pageBody.substringAfter( '<div class="listingMenu' );
                String category = pageBody.subStringBetween( 'h1>Used', '</' );
                pageBody = pageBody.SubStringBetween( '<table','</table' );
                
                if( String.isNotBlank( pageBody ) ) {
                    List<String> truckRecordRowList = pageBody.split( '</td' );
                    if( truckRecordRowList != NULL && !truckRecordRowList.isEmpty() ) {
                        
                        String link;
                        for( String truckRecord : truckRecordRowList ) {      
                            link = truckRecord.subStringBetween( 'href="', '"' );
                            if( String.isNotBlank( link ) ) {
                                urlSet.add( hostUrl + link ); 
                                this.pageUrlToCategory.put( hostUrl + link, category ); 
                            }  
                        }
                    }
                }
            }
        }
        System.debug( 'FiretecDetailPageUrlBatch-urlSet:-\n' + JSON.serialize( urlSet ) );
        return urlSet;
    }    
}