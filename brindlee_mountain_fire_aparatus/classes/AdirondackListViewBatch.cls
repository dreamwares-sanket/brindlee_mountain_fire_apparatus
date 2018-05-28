/**
    @ Purpose : 1. Fetches the anchor links of different types of trucks from home page of Adirondack website.
				2. Passes these links to AdirondackDetailPageUrlBatch class.
*/
public class AdirondackListViewBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
    
    public List<String> pageUrlList;
    
    public List<String> nextPageUrlList;
    
    public String siteId;
    
	public AdirondackListViewBatch() {
		
		this.pageUrlList = new List<String>();
		this.nextPageUrlList = new List<String>();
		this.siteId = '';
	}
	
    public AdirondackListViewBatch( String pageUrl, String siteId ) {    
		
		this();
        if( String.isNotBlank( pageUrl ) ) {
            this.pageUrlList.add( pageUrl );
        }
        
        this.siteId = siteId;
    }
    
    public Iterable<String> start( Database.BatchableContext BC ) {
        
        System.debug( 'AdirondackListViewBatch-start-pageUrlList:-\n' + JSON.serialize( this.pageUrlList ) );
        return this.pageUrlList;
    }
    
    public void execute( Database.BatchableContext bc, List<String> urlList ) {
        
        for( String endPoint : urlList ) {
            this.nextPageUrlList.addAll( parseResponse( SiteCalloutHelper.getHtmlBody( endPoint ), endPoint ) );    
        }  
        System.debug( 'AdirondackListViewBatch-nextPageUrlList:-\n' + JSON.serialize( this.nextPageUrlList ) );
    }
    
    public void finish( Database.BatchableContext BC ) {
        
        System.debug( 'AdirondackListViewBatch-finish-nextPageUrlList:-\n' + JSON.serialize( this.nextPageUrlList ) );
        if( !this.nextPageUrlList.isEmpty() ) {
            Database.executeBatch( new AdirondackDetailPageUrlBatch( this.nextPageUrlList, this.siteId ), 1 );
        }
    }
    
    private static Set<String> parseResponse( HTTPResponse httpResponse, String endPoint ) {
        
        System.debug( 'AdirondackListViewBatch-httpResponse:-\n' + httpResponse );
        Set<String> urlSet = new Set<String>();
        if( httpResponse != NULL && String.isNotBlank( endPoint ) ) {
            
            // Parses types of trucks ( list views )        
            String pageBody = httpResponse.getBody();
			System.debug( 'pageBody' + pageBody );
			
			if( String.isNotBlank( pageBody ) ) {
				pageBody = pageBody.subStringBetween
									( '<div class="collapse navbar-collapse" id="myNavbar">', 
									  '</ul></div>' 
									);
				
				List<String> substringList = new List<String>();
				if( String.isNotBlank( pageBody ) ) {
					substringList = pageBody.split( '</a>' );
					System.debug( 'substringList\n' + JSON.serialize( substringList ) );
                    
                    if( substringList != NULL && !substringList.isEmpty() ) {
                        String link;
                        for( String menu : substringList ) {
                            link = menu.substringAfterLast( 'href="' ).substringBefore( '"' );
                            if( String.isNotBlank( link ) ) {
                                urlSet.add( link );
                            }
                        }
                    }
				}
			}
        }
        System.debug( 'AdirondackListViewBatch-urlSet:-\n' + JSON.serialize( urlSet ) );
        return urlSet;
    }    
}