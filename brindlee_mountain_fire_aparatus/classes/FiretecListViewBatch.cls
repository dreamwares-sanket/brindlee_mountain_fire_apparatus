/**
    @ Purpose : 1. Fetches the anchor links of different types of trucks from home page of Firetec website.
                2. Passes these links to FiretecDetailPageUrlBatch class.
*/
public class FiretecListViewBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
    
    public List<String> pageUrlList;
    
    public List<String> nextPageUrlList;
    
    public String siteId;
    
    public FiretecListViewBatch() {
        
        this.pageUrlList = new List<String>();
        this.nextPageUrlList = new List<String>();
        this.siteId = '';
    }
    
    public FiretecListViewBatch( String pageUrl, String siteId ) {    
        
        this();
        if( String.isNotBlank( pageUrl ) ) {
            this.pageUrlList.add( pageUrl );
        }
        this.siteId = siteId;
    }
    
    public Iterable<String> start( Database.BatchableContext BC ) {
        
        System.debug( 'FiretecListViewBatch-start-pageUrlList:-\n' + JSON.serialize( this.pageUrlList ) );
        return this.pageUrlList;
    }
    
    public void execute( Database.BatchableContext bc, List<String> urlList ) {
        
        for( String endPoint : urlList ) {
            this.nextPageUrlList.addAll( parseResponse( SiteCalloutHelper.getHtmlBody( endPoint ), endPoint ) );    
        }  
        System.debug( 'FiretecListViewBatch-nextPageUrlList:-\n' + JSON.serialize( this.nextPageUrlList ) );
    }
    
    public void finish( Database.BatchableContext BC ) {
        
        System.debug( 'FiretecListViewBatch-finish-nextPageUrlList:-\n' + JSON.serialize( this.nextPageUrlList ) );
        if( !this.nextPageUrlList.isEmpty() ) {
            Database.executeBatch( new FiretecDetailPageUrlBatch( this.nextPageUrlList, this.siteId ), 1 );
        }
    }
    
    private static Set<String> parseResponse( HTTPResponse httpResponse, String endPoint ) {
        
        System.debug( 'FiretecListViewBatch-httpResponse:-\n' + httpResponse );
        Set<String> urlSet = new Set<String>();
        if( httpResponse != NULL && String.isNotBlank( endPoint ) ) {
            
            String pageBody = httpResponse.getBody();
            System.debug( 'pageBody' + pageBody );
            
            if( String.isNotBlank( pageBody ) ) {
                pageBody = pageBody.subStringBetween( '<div class="leftmenuWHITE">', '</ul' );
                
                while( pageBody.containsIgnoreCase( '<!--' ) && 
                       String.isNotBlank(pageBody.subStringBetween( '<!--', '-->' ) ) 
                ) {
                    pageBody = pageBody.remove( pageBody.SubStringBetween( '<!--', '-->' ) ).remove( '<!---->' );
                }
                
                if( String.isNotBlank( pageBody ) ) {
                    List<String> menuList = pageBody.split( '</li' );
                    System.debug( 'menuList:-\n' + JSON.serialize( menuList ) );
                    
                    if( menuList != NULL && !menuList.isEmpty() ) {
                        String link;
                        for( String menu : menuList ) {  
                            link = menu.subStringBetween( 'href="', '"' );
                            if( String.isNotBlank( link ) ) {
                                urlSet.add( endPoint + link );
                            }
                        }
                    }
                }
            }
        }
        System.debug( 'FiretecListViewBatch-urlSet:-\n' + JSON.serialize( urlSet ) );
        return urlSet;
    }    
}