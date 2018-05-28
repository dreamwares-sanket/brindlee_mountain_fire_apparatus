/**
    @ Purpose :
*/
public class AdirondackDetailPageUrlBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
    
    public List<String> pageUrlList = new List<String>();
    
    public List<String> nextPageUrlList = new List<String>();
    
    public String siteId = '';
    
    public AdirondackDetailPageUrlBatch( List<String> pageUrlList, String siteId ) {
		
		if( pageUrlList != NULL && !pageUrlList.isEmpty() ) {
			this.pageUrlList.addAll( pageUrlList );
		}
        this.siteId = siteId;
    }
    
    public Iterable<String> start( Database.BatchableContext BC ) {
        
        System.debug( 'AdirondackDetailPageUrlBatch-pageUrlList:-\n' + JSON.serialize( pageUrlList ) );
        return pageUrlList;
    }
    
    public void execute( Database.BatchableContext bc, List<String> urlList ) {
        
        for( String endPoint :urlList ) {
            nextPageUrlList.addAll( parseResponse( SiteCalloutHelper.getHtmlBody( endPoint ) ) );    
        }
        System.debug( 'AdirondackDetailPageUrlBatch-nextPageUrlList:-\n' + JSON.serialize( nextPageUrlList ) );
    }
    
    public void finish( Database.BatchableContext BC ) {
        
        System.debug( 'AdirondackDetailPageUrlBatch-finish-nextPageUrlList:-\n' + JSON.serialize( nextPageUrlList ) );
        if( !nextPageUrlList.isEmpty() ) {                            
            Database.executeBatch( new AdirondackDetailInfoBatch( nextPageUrlList, siteId ), 1 );
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
			}
			
            List<String> truckRecordRowList = new List<String>();
			if( String.isNotBlank( pageBody ) ) {
				truckRecordRowList = pageBody.split( '<h2 class="entry-title">' );
			}
			
			String link;
            for( String truckRecord : truckRecordRowList ) {
				link = truckRecord.subStringBetween( 'href="','"' );
				if( String.isNotBlank( link ) ) {
					urlSet.add( link );    
				}
            }
        }
        System.debug( 'AdirondackDetailPageUrlBatch-urlSet:-\n' + JSON.serialize( urlSet ) );
        return urlSet;
    }    
}