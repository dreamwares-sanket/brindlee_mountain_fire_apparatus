/**
    @ Purpose : 1. Fetches the anchor links of different types of trucks from home page of BPAAparatus website.
                2. Passes these links to BPAapparatusDetailPageUrlBatch class.
*/
public class BPAapparatusListViewBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
    
    public List<String> pageUrlList;
    
    public List<String> nextPageUrlList;
    
    public String siteId;
    
    public BPAapparatusListViewBatch() {
        
        this.pageUrlList = new List<String>();
        this.nextPageUrlList = new List<String>();
        this.siteId = '';
    }
    
    public BPAapparatusListViewBatch( String pageUrl, String siteId ) { 
        
        this();
        System.debug( 'BPAapparatusListViewBatch-pageUrl:-\n' + pageUrl );
        if( String.isNotBlank( pageUrl ) ) {
            this.pageUrlList.add( pageUrl );
        }
        this.siteId = siteId;
    }
    
    public Iterable<String> start( Database.BatchableContext BC ) {
        
        System.debug( 'BPAapparatusListViewBatch-start-pageUrlList:-\n' + JSON.serialize( this.pageUrlList ) );
        return this.pageUrlList;
    }
    
    public void execute( Database.BatchableContext bc, List<String> urlList ) {
        
        System.debug( 'BPAapparatusListViewBatch-execute-urlList:-\n' + urlList );
        for( String endPoint : urlList ) {
            this.nextPageUrlList.addAll( parseResponse( SiteCalloutHelper.getHtmlBody( endPoint ), endPoint ) );    
        }  
    }
    
    public void finish( Database.BatchableContext BC ) {
        
        System.debug( 'BPAapparatusListViewBatch-finish-nextPageUrlList:-\n' + JSON.serialize( this.nextPageUrlList ) );
        if( !this.nextPageUrlList.isEmpty() ) {
            Database.executeBatch( new BPAapparatusDetailPageUrlBatch( this.nextPageUrlList, siteId ), 1 );
        }
    }
    
    private static Set<String> parseResponse( HTTPResponse httpResponse, String endPoint ) {
        
        System.debug( 'BPAapparatusListViewBatch-httpResponse:-\n' + httpResponse );
        Set<String> urlSet = new Set<String>();
        if( httpResponse != NULL && String.isNotBlank( endPoint ) ) {
                    
            String pageBody = httpResponse.getBody();
            System.debug( 'BPAapparatusListViewBatch-pageBody:-\n' + pageBody );
            
            if( String.isNotBlank( pageBody ) ) {
                pageBody = pageBody.subStringBetween( '<div class="ht-service-post-wrap','</section' );
                System.debug( 'pageBody:-\n' + pageBody );
                
                if( String.isNotBlank( pageBody ) ) {
                    List<String> substringList = pageBody.split( 'Read More' );
                    System.debug( 'substringList:-\n' + JSON.serialize( substringList ) );
                    
                    if( substringList != NULL && !substringList.isEmpty() ) {
                        String link;
                        for( String menu: substringList ) {
                            link = menu.substringAfterLast( 'href="' ).substringBefore( '"' );
                            if( String.isNotBlank( link ) ) {
                                urlSet.add( link );
                            }
                        }
                    }
                }
            }
        }
        System.debug( 'BPAapparatusListViewBatch-urlSet:-\n' + JSON.serialize( urlSet ) );
        return urlSet;
    }    
}