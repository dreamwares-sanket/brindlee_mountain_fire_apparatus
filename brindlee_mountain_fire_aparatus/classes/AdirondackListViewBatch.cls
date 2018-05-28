/**
    @ Purpose :
*/
public class AdirondackListViewBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
    
    public List<String> pageUrlList = new List<String>();
    
    public List<String> nextPageUrlList = new List<String>();
    
    public String siteId = '';
    
    public AdirondackListViewBatch( String pageUrl, String siteId ) {    
        
        if( String.isNotBlank( pageUrl ) ) {
            this.pageUrlList.add( pageUrl );
        }
        
        this.siteId = siteId;
    }
    
    public Iterable<String> start( Database.BatchableContext BC ) {
        
        System.debug( 'AdirondackListViewBatch-pageUrlList:-\n' + JSON.serialize( pageUrlList ) );
        return pageUrlList;
    }
    
    public void execute( Database.BatchableContext bc, List<String> urlList ) {
        
        for( String endPoint :urlList ) {
            nextPageUrlList.addAll( parseResponse( SiteCalloutHelper.getHtmlBody( endPoint ), endPoint ) );    
        }  
        System.debug( 'AdirondackListViewBatch-nextPageUrlList:-\n' + JSON.serialize( nextPageUrlList ) );
    }
    
    public void finish( Database.BatchableContext BC ) {
        
        System.debug( 'AdirondackListViewBatch-finish-nextPageUrlList:-\n' + JSON.serialize( nextPageUrlList ) );
        if( !nextPageUrlList.isEmpty() ) {
            Database.executeBatch( new AdirondackDetailPageUrlBatch( nextPageUrlList, siteId ), 1 );
        }
    }
    
    private static Set<String> parseResponse( HTTPResponse httpResponse, String endPoint ) {
        
        System.debug( 'AdirondackListViewBatch-httpResponse:-\n' + httpResponse );
        Set<String> urlSet = new Set<String>();
        if( httpResponse != NULL && String.isNotBlank( endPoint ) ) {
            
            // Parses types of trucks ( list views )        
            String pageBody = httpResponse.getBody().subStringBetween( '<div class="collapse navbar-collapse" id="myNavbar">', 
                                                                       '</ul></div>' 
                                                                     );
            System.debug( 'pageBody' + JSON.serialize( pageBody ) );
            List<String> substringList = String.isNotBlank( pageBody ) ? pageBody.split( '</a>' ) : new List<String>();
            System.debug( 'substringList\n' + JSON.serialize( substringList ) );
            
            String link;
            for( String menu : substringList ) {
                link = menu.substringAfterLast( 'href="' ).substringBefore( '"' );
                if( String.isNotBlank( link ) ) {
                    urlSet.add( link );
                }
            }
        }
        System.debug( 'AdirondackListViewBatch-urlSet:-\n' + JSON.serialize( urlSet ) );
        return urlSet;
    }    
}