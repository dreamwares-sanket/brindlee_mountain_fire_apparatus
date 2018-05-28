/**
    @ Purpose : 1. Fetches the anchor links of different types of trucks from home page of CommandFireApparatus website.
                2. Passes these links to CommandFireApparatusDetailPageLinkBatch class.
*/
public class CommandFireApparatusListViewBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
   
    public List<String> pageUrlList;
    Public List<String> pageUrlCategoryList;
    public String siteId;
    
    public CommandFireApparatusListViewBatch() {
        
        this.pageUrlList = new List<String>();
        this.pageUrlCategoryList = new List<String>();
        this.siteId = '';
    }
    
    public CommandFireApparatusListViewBatch( String pageUrl, String siteId ) {  
        
        this();
        if( String.isNotBlank( pageUrl ) ) {
            this.pageUrlCategoryList.add( pageUrl );
        }
        this.siteId = siteId;
    }
    
    public Iterable<String> start( Database.BatchableContext BC ) {
        
        System.debug( 'CommandFireApparatusListViewBatch-start-pageUrlCategoryList:-\n' + JSON.serialize( this.pageUrlCategoryList ) );
        return this.pageUrlCategoryList;
    }   
    
    public void execute( Database.BatchableContext bc, List<String> urlList ) {
        
        for( String siteUrl : urlList ) {
            siteUrl = siteUrl + 'inventory/';
            this.pageUrlList.addAll( parseResponse( SiteCalloutHelper.getHtmlBody( siteUrl ), siteUrl ) );   
        }
    }
    
    public void finish( Database.BatchableContext BC ) {
        
        System.debug( 'CommandFireApparatusListViewBatch-finish-pageUrlList:-\n' + JSON.serialize( this.pageUrlList ) );
        if( !this.pageUrlList.isEmpty() ) {
            Database.executeBatch( new CommandFireApparatusDetailPageLinkBatch( this.pageUrlList, this.siteId ) );
        }
    }
    
    private static List<String> parseResponse( HTTPResponse httpResponse, String endPoint ) {
        
        System.debug( 'CommandFireApparatusListViewBatch-httpResponse:-\n' + httpResponse );
        List<String> pageUrlList = new List<String>();
        Integer pageNo = 1;
        if( httpResponse != NULL && String.isNotBlank( endPoint ) ) {
            
            String pageBody = httpResponse.getBody();
            if( String.isNotBlank( pageBody ) ) {
                pageBody = pageBody.substringBetween( '<ul class=\'page-numbers\'>', '</ul>' );
                if( String.isNotBlank( pageBody ) ) {
                    
                    pageBody = pageBody.substringAfterLast( '<a class=\'page-numbers\' href=\'' ).substringBefore( '</a>' ).substringAfter('>');
                    if( String.isNotBlank( pageBody ) ) {
                        pageNo = Integer.valueof( pageBody );
                    }
                }
                for( Integer index = 1; index <= pageNo; index ++ ) {                
                    pageUrlList.add( endPoint + 'page/' + index + '/' );    
                }
            }
        }
        System.debug( 'CommandFireApparatusListViewBatch-pageUrlList:-\n' + JSON.serialize( pageUrlList ) );
        return pageUrlList;     
    }
}