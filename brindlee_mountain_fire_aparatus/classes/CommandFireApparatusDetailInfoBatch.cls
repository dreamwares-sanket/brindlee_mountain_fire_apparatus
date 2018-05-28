/**
    @ Purpose : 1. Parses truck details into Competitor Truck records.
                2. Saves these records to database and updates Competitor site record.
*/
public class CommandFireApparatusDetailInfoBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
    
    public List<String> pageUrlList;
    
    public List<Competitor_Site_Truck__c> truckList;
    
    public String siteId;
    
    public CommandFireApparatusDetailInfoBatch() {
        
        this.pageUrlList = new List<String>();
        this.truckList = new List<Competitor_Site_Truck__c>();
        this.siteId = '';
    }
    
    public CommandFireApparatusDetailInfoBatch( Set<String> pageUrls, String siteId ) {    
        
        this();
        if( pageUrls != NULL && !pageUrls.isEmpty() ) {
            this.pageUrlList.addAll( pageUrls );
        }
        this.siteId = siteId;
    }
    
    public Iterable<String> start( Database.BatchableContext BC ) {
        
        System.debug( 'CommandFireApparatusDetailInfoBatch-start-pageUrlList:-\n' + JSON.serialize( this.pageUrlList ) );
        return this.pageUrlList;
    }   
    
    public void execute(Database.BatchableContext bc, List<String> urlList){
        
        for( String endPoint : urlList ) {
            this.truckList.add( parseResponse( getHtmlBody( endPoint ), this.siteId, endPoint ) );    
        } 
    }
    
    public void finish( Database.BatchableContext BC ) {
        
        System.debug( 'CommandFireApparatusDetailInfoBatch-truckList:-\n' + JSON.serialize( this.truckList ) );
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
    
    public static HTTPResponse getHtmlBody( String endPoint ) {
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint( endPoint );
        req.setMethod( 'GET' );
        Http http = new Http();
        return http.send( req );
    }
    
    private static Competitor_Site_Truck__c parseResponse( HTTPResponse httpResponse,  String siteId, String endPoint ) {
        
        System.debug( 'CommandFireApparatusDetailInfoBatch-httpResponse:-\n' + httpResponse );
        Competitor_Site_Truck__c siteTruck = new Competitor_Site_Truck__c();
        if( httpResponse != NULL ) {
            
            List<String> tableDataList = new List<String>();
            
            String pageBody = httpResponse.getBody();
            if( String.isNotBlank( pageBody ) ) {
                
                String price = pageBody.substringAfterLast('<div class="single-regular-price').substringAfter('<span class="h3">').substringBefore('</span>').split(' ')[0].remove( ',' );
                siteTruck.Asking_Price__c = String.isNotBlank( price ) ? Decimal.valueof(price) : 0.0;                           
                siteTruck.Competitor_Site__c = siteId;
                siteTruck.Truck_Public_Site_Url__c = endPoint;
                
                String location = pageBody.substringBetween( 'Unit Location:', '</span>' );
                siteTruck.Location__c =  string.isNotBlank( location ) ? location.subStringAfter( 'span>' ) : '';
            
                // for description
                String description = pageBody.subStringAfter( 'Vehicle overview' );
                siteTruck.Description__c = String.isNotBlank( description ) ? description.substringBetween( '<div class="wpb_wrapper">','</div>' ): description;
              
                // for title
                siteTruck.Main_Title__c =  pageBody.subStringBetween( '<h1 class="title h2">', '</h1>' );
                
                String tempData = pageBody.substringBetween( '<div class="single-car-data">', '</div>' );
                tempData = String.isNotBlank( tempData ) ? tempData.remove( '<table>' ).remove( '</table>' ) : '';
                
                if( String.isNotBlank( tempData ) ) {
                    tableDataList.addAll( tempData.split( 'tr' ) );
                }
            
                for( String tableData :tableDataList ) {
                    if(tableData.containsIgnoreCase( '<td class="t-value h6">' ) ) {
                        
                        if( tableData.substringBetween( '<td class="t-label">', '</td>' ).equalsIgnoreCase( 'UNIT TYPE' ) ) {
                            String category = tableData.substringBetween( '<td class="t-value h6">', '</td>' ); 
                            siteTruck.Category__c = String.isNotBlank( category ) ? category.replaceAll( ',', ';' ) : category;   
                        }
                        else if( tableData.substringBetween( '<td class="t-label">', '</td>' ).equalsIgnoreCase( 'Manufacturer' ) ) {
                            siteTruck.Make__c = tableData.substringBetween( '<td class="t-value h6">', '</td>' );                        
                        }
                        else if( tableData.substringBetween( '<td class="t-label">', '</td>' ).equalsIgnoreCase( 'YEAR' ) ) {
                            siteTruck.Year__c = Integer.valueOf( tableData.substringBetween( '<td class="t-value h6">', '</td>' ).remove( ',' ) );                 
                        }
                        else if( tableData.substringBetween( '<td class="t-label">', '</td>' ).equalsIgnoreCase( 'MILEAGE' ) ) {
                            siteTruck.Mileage__c = tableData.substringBetween( '<td class="t-value h6">', '</td>' );                        
                        }
                    }
                }
            }
        }
        System.debug( 'AdirondackDetailPageUrlBatch-siteTruck:-\n' + JSON.serialize( siteTruck ) );
        return siteTruck;
    }
}