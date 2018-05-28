/**
    @ Purpose : 1. Fetches the anchor links of all trucks from list views of Adirondack website.
				2. Passes these links to AdirondackDetailInfoBatch class.
*/
public class AdirondackDetailPageUrlBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
    
    public List<String> pageUrlList;
    
    public List<String> nextPageUrlList;
    
    public String siteId;
    
	public AdirondackDetailPageUrlBatch() {
		
		this.pageUrlList = new List<String>();
		this.nextPageUrlList = new List<String>();
		this.siteId = '';
	}
	
    public AdirondackDetailPageUrlBatch( List<String> pageUrlList, String siteId ) {
		
		this();
		if( pageUrlList != NULL && !pageUrlList.isEmpty() ) {
			this.pageUrlList.addAll( pageUrlList );
		}
        this.siteId = siteId;
    }
    
    public Iterable<String> start( Database.BatchableContext BC ) {
        
        System.debug( 'AdirondackDetailPageUrlBatch-start-pageUrlList:-\n' + JSON.serialize( this.pageUrlList ) );
        return this.pageUrlList;
    }
    
    public void execute( Database.BatchableContext bc, List<String> urlList ) {
        
        for( String endPoint : urlList ) {
            this.nextPageUrlList.addAll( parseResponse( SiteCalloutHelper.getHtmlBody( endPoint ) ) );    
        }
        System.debug( 'AdirondackDetailPageUrlBatch-nextPageUrlList:-\n' + JSON.serialize( this.nextPageUrlList ) );
    }
    
    public void finish( Database.BatchableContext BC ) {
        
        System.debug( 'AdirondackDetailPageUrlBatch-finish-nextPageUrlList:-\n' + JSON.serialize( this.nextPageUrlList ) );
        if( !this.nextPageUrlList.isEmpty() ) {                            
            Database.executeBatch( new AdirondackDetailInfoBatch( this.nextPageUrlList, siteId ), 1 );
        }
    }
    
    private static Set<String> parseResponse( HTTPResponse httpResponse ) {
        
        System.debug( 'AdirondackDetailPageUrlBatch-httpResponse:-\n' + httpResponse );
        Set<String> urlSet = new Set<String>();
        if( httpResponse != NULL ) {
            
            String pageBody = httpResponse.getBody();
			if( String.isNotBlank( pageBody ) ) {
				pageBody = pageBody.substringBetween
									( '<h1 class="page-title"', 
									  '<nav class="navigation posts-navigation"' 
									);
									
				if( String.isNotBlank( pageBody ) ) {
					List<String> truckRecordRowList = pageBody.split( '<h2 class="entry-title">' );
                    System.debug( 'truckRecordRowList\n' + JSON.serialize( truckRecordRowList ) );
                    
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
        System.debug( 'AdirondackDetailPageUrlBatch-urlSet:-\n' + JSON.serialize( urlSet ) );
        return urlSet;
    }    
}