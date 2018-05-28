/**
    @ Purpose : 1. Fetches the anchor links of all trucks from list views of CommandFireApparatus website.
                2. Passes these links to CommandFireApparatusDetailInfoBatch class.
*/
public class CommandFireApparatusDetailPageLinkBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
    
    public List<String> pageUrlList;
    public Set<String> detailPageUrlList;
    public String siteId;
    
    public CommandFireApparatusDetailPageLinkBatch() {
        
        this.pageUrlList = new List<String>();
        this.detailPageUrlList = new Set<String>();
        this.siteId = '';
    }
    
    public CommandFireApparatusDetailPageLinkBatch( List<String> pageUrls, String siteId ) { 
        
        this();
        if( pageUrls != NULL && !pageUrls.isEmpty() ) {
            pageUrlList.addAll( pageUrls );
        }
        this.siteId = siteId;
    }
    
    public Iterable<String> start( Database.BatchableContext BC ) {
        
        System.debug( 'CommandFireApparatusDetailPageLinkBatch-start-pageUrlList:-\n' + JSON.serialize( this.pageUrlList ) );
        return this.pageUrlList;
    }   
    
    public void execute( Database.BatchableContext bc, List<String> urlList ) {
        
        for( String endPoint :urlList ) {
            this.detailPageUrlList.addAll( parseResponse( SiteCalloutHelper.getHtmlBody( endPoint ), endPoint ) );    
        } 
    }
    
    public void finish( Database.BatchableContext BC ) {
        
        System.debug( 'CommandFireApparatusDetailPageLinkBatch-finish-detailPageUrlList:-\n' + JSON.serialize( this.detailPageUrlList ) );
        if( !this.detailPageUrlList.isEmpty() ) {
            Database.executeBatch( new CommandFireApparatusDetailInfoBatch( this.detailPageUrlList, this.siteId ), 1 );  
        }    
    }
       
    private static List<String> parseResponse( HTTPResponse httpResponse, String endPoint ) {
        
        System.debug( 'CommandFireApparatusDetailPageLinkBatch-httpResponse:-\n' + httpResponse );
        List<String> pageUrlList = new List<String>();
        if( httpResponse != NULL && String.isNotBlank( endPoint ) ) {
            
            String pageBody = httpResponse.getBody();
            if( String.isNotBlank( pageBody ) ) {
                
                List<String> recordUrlBlockList = pageBody.substringAfterLast( '<div class="stm-isotope-sorting stm-isotope-sorting-list">').substringBeforeLast( '<div class="stm_ajax_pagination stm-blog-pagination">' ).removeEndIgnoreCase( '</div>' ).split( '<div class="title heading-font">' );
                
                String link;
                for( Integer index = 1; index < recordUrlBlockList.size(); index++ ) {    
                    link = recordUrlBlockList[ index ].substringBetween( '<a href="', '"' );
                    if( String.isNotBlank( link ) ) {
                        pageUrlList.add( link ); 
                    }
                }
            }         
        }
        System.debug( 'CommandFireApparatusDetailPageLinkBatch-finish-pageUrlList:-\n' + JSON.serialize( pageUrlList ) );
        return pageUrlList;
    }
}