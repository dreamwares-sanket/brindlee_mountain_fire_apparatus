/**
    @ Purpose : 1. Parses truck details into Competitor Truck records.
                2. Saves these records to database and updates Competitor site record.
*/
public class FiretecDetailInfoBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
    
    public List<String> pageUrlList;
    
    public List<Competitor_Site_Truck__c> truckList;
    
    public Map<String,String> pageUrlToCategory = new Map<String,String>();
    
    public String siteId;
    
    public FiretecDetailInfoBatch() {
        
        this.pageUrlList = new List<String>();
        this.truckList = new List<Competitor_Site_Truck__c>();
        this.pageUrlToCategory = new Map<String,String>();
        this.siteId = '';
    }
    
    public FiretecDetailInfoBatch( List<String> pageUrlList, String siteId, Map<String,String> pageUrlToCategory ) {
        
        this();
        if( pageUrlList != NULL && !pageUrlList.isEmpty() ) {
            this.pageUrlList.addAll( pageUrlList );
        }
        this.siteId = siteId;
        if( pageUrlToCategory != NULL && !pageUrlToCategory.isEmpty() ) {
            this.pageUrlToCategory.putAll( pageUrlToCategory );
        }
    }
    
    public Iterable<String> start( Database.BatchableContext BC ) {
        
        System.debug( 'FiretecDetailInfoBatch-start-pageUrlList:-\n' + JSON.serialize( this.pageUrlList ) );
        return this.pageUrlList;
    }
    
    public void execute( Database.BatchableContext bc, List<String> urlList ) {
        
        for( String endPoint : urlList ) {
            this.truckList.add( parseResponse( SiteCalloutHelper.getHtmlBody( endPoint ), endPoint, siteId ) );    
        }  
    }
    
    public void finish( Database.BatchableContext BC ) {
        
        if( !this.truckList.isEmpty() ) {            
            try {
                INSERT this.truckList;
                UPDATE new CompetitorSite__c( Id = this.siteId, Last_Record_Created_By_Batch__c = DateTime.now() );
            }
            catch( Exception exp ) {
                System.debug( 'Exception:-\n' + exp.getMessage() );
            }
        }
    }
    
    private Competitor_Site_Truck__c parseResponse( HTTPResponse httpResponse, String endPoint, String siteId ) {        
        
        System.debug( 'FiretecDetailInfoBatch-httpResponse:-\n' + httpResponse );
        Competitor_Site_Truck__c truckRecord = new Competitor_Site_Truck__c( Competitor_Site__c = siteId );
        
        if( httpResponse != NULL ) {
            String pageBody = httpResponse.getBody();
            System.debug( 'pageBody:-\n' + pageBody );
            
            if( String.isNotBlank( pageBody ) ) {
                
                String title = pageBody.subStringBetween( '<div id="contentcolumn"','<div class="container' );   
                if( String.isNotBlank( title ) ) {
                    truckRecord.Main_Title__c = SiteCalloutHelper.getReplaceString
                                                                  ( title.subStringBetween( '<h1', '</h1' ).remove( '>' ),
                                                                    FALSE
                                                                  );
                }
                truckRecord.Truck_Public_Site_Url__c = endPoint;
                truckRecord.Category__c = pageUrlToCategory.containsKey( endPoint ) ? pageUrlToCategory.get( endPoint ) : '';        
        
                String otherInfo = pageBody.substringBetween( '<div class="WebAd', '</div' );
                if( String.isNotBlank( otherInfo ) ) {
        
                    truckRecord.Stock__c = otherInfo.subStringBetween( 'h3>', '</h3' );   
                    truckRecord.Description__c = otherInfo.subStringBetween( '/h3>', '<style' ); 
                    
                    String price = otherInfo.subStringBetween( 'Asking ', '<' );
                    price  = String.isNotBlank( price ) ? SiteCalloutHelper.getReplaceString( price, TRUE ) : '';
                    
                    if( String.isNotBlank( price ) ) {
                        for( String tempStr :price.split( ' ' ) ) {
                            if( tempStr.trim().isNumeric() ) {
                                price = tempStr.trim(); 
                                break;   
                            }
                            price = '';
                        }
                    }
                    truckRecord.Asking_Price__c = String.isNotBlank( price )? Decimal.valueOf( price ): NULL; 
                }
            }
        }
        System.debug( 'FiretecDetailInfoBatch-truckRecord:-\n' + JSON.serialize( truckRecord ) );
        return truckRecord;
    }   
}