/**
    @ Purpose : 1. Parses truck details into Competitor Truck records.
                2. Saves these records to database and updates Competitor site record.
*/
public class BPAapparatusDetailInfoBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
    
    public List<String> pageUrlList;
    
    public List<Competitor_Site_Truck__c> truckList;
    
    public String siteId;
    
    public BPAapparatusDetailInfoBatch() {
        
        this.pageUrlList = new List<String>();
        this.truckList = new List<Competitor_Site_Truck__c>();
        this.siteId = '';
    }
    
    public BPAapparatusDetailInfoBatch( List<String> pageUrlList, String siteId ) {
     
        this();
        if( pageUrlList != NULL && !pageUrlList.isEmpty() ) {
            this.pageUrlList.addAll( pageUrlList );
        }
        this.siteId = siteId;
    }
    
    public Iterable<String> start( Database.BatchableContext BC ) {
        
        System.debug( 'BPAapparatusDetailInfoBatch-start-pageUrlList:-\n' + JSON.serialize( this.pageUrlList ) );
        return this.pageUrlList;
    }
    
    public void execute( Database.BatchableContext bc, List<String> urlList ) {
        
        for( String endPoint :urlList ) {
            this.truckList.add( parseResponse( SiteCalloutHelper.getHtmlBody( endPoint ), endPoint, this.siteId ) );    
        }  
    }
    
    public void finish( Database.BatchableContext BC ) {
        
        System.debug( 'BPAapparatusDetailInfoBatch-truckList:-\n' + JSON.serialize( this.truckList ) );
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
    
    private static Competitor_Site_Truck__c parseResponse( HTTPResponse httpResponse, String endPoint, String siteId ) {
        
        System.debug( 'AdirondackDetailPageUrlBatch-httpResponse:-\n' + httpResponse );
        Competitor_Site_Truck__c truckRecord = new Competitor_Site_Truck__c( Competitor_Site__c = siteId );
        if( httpResponse != NULL ) {
            
            String pageBody = httpResponse.getBody();
            if( String.isNotBlank( pageBody ) ) {
                
                truckRecord.Main_Title__c = SiteCalloutHelper.getReplaceString
                                            ( pageBody.subStringBetween( '<h1 class="ht-main-title">', '</' ), 
                                              FALSE
                                            );
                truckRecord.Category__c = endPoint.subStringBetween( 'com/', '/' );
                truckRecord.Truck_Public_Site_Url__c = endPoint;
                
                String price = SiteCalloutHelper.getReplaceString( pageBody.subStringBetween( 'List Price', '<' ), TRUE );
                truckRecord.Asking_Price__c = String.isNotBlank( price ) && price.isNumeric() ? Decimal.valueOf( price ): NULL;
                
                String year = SiteCalloutHelper.getReplaceString( pageBody.subStringBetween( 'Year', '</div' ), TRUE );
                truckRecord.Year__c = String.isNotBlank( year ) && year.isNumeric() ? Integer.valueOf( year ) : NULL;
                
                truckRecord.Mileage__c = SiteCalloutHelper.getReplaceString( pageBody.subStringBetween( 'Miles', '</div' ), TRUE );
                truckRecord.Additional_Chassis_Info__c = SiteCalloutHelper.getReplaceString
                                                         ( pageBody.subStringBetween( 'Chassis', '</div' ), 
                                                           TRUE
                                                         );
                truckRecord.Transmission_Model__c = SiteCalloutHelper.getReplaceString
                                                    ( pageBody.subStringBetween( 'Trans.','</div' ), 
                                                      TRUE
                                                    );
                
                String pumpGPM = SiteCalloutHelper.getSplitValue
                                 ( SiteCalloutHelper.getReplaceString( pageBody.subStringBetween( 'Pump', 'G.P.M.' ), 
                                                                       TRUE 
                                                                     ),
                                   ' ', 'last'
                                 );
                                 
                truckRecord.Pump_GPM__c = String.isNotBlank( pumpGPM ) ? pumpGPM + ' GPM' : '';
                truckRecord.Tank_size__c = SiteCalloutHelper.getReplaceString( pageBody.subStringBetween( 'Tank', '</div' ), TRUE );
            }
        }
        System.debug( 'BPAapparatusDetailInfoBatch-truckRecord:-\n' + JSON.serialize( truckRecord ) );
        return truckRecord;
    }   
}