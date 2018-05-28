/**
    @ Purpose : 1. Parses truck details into Competitor Truck records.
				2. Saves these records to database and updates Competitor site record.
*/
public class AdirondackDetailInfoBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
    
    public List<String> pageUrlList;
    
    public List<Competitor_Site_Truck__c> truckList;
    
    public String siteId;
    
	public AdirondackDetailInfoBatch() {
		
		this.pageUrlList = new List<String>();
		this.truckList = new List<Competitor_Site_Truck__c>();
		this.siteId = '';
	}
	
    public AdirondackDetailInfoBatch( List<String> pageUrlList, String siteId ) {
		
		this();
		if( pageUrlList != NULL && !pageUrlList.isEmpty() ) {
			this.pageUrlList.addAll( pageUrlList );
		}
        this.siteId = siteId;
    }
    
    public Iterable<String> start( Database.BatchableContext BC ) {
        
        System.debug( 'AdirondackDetailInfoBatch-start-pageUrlList:-\n' + JSON.serialize( this.pageUrlList ) );
        return this.pageUrlList;
    }
    
    public void execute( Database.BatchableContext bc, List<String> urlList ) {
        
        for( String endPoint : urlList ) {
            this.truckList.add( parseResponse( SiteCalloutHelper.getHtmlBody( endPoint ), endPoint, this.siteId ) );    
        }
        System.debug( 'AdirondackDetailInfoBatch-urlList:-\n' + JSON.serialize( urlList ) );
    }
    
    public void finish( Database.BatchableContext BC ) {
        
        System.debug( 'AdirondackDetailInfoBatch-truckList:-\n' + JSON.serialize( this.truckList ) );
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
            System.debug( 'pageBody:-\n' + pageBody );
            
			if( String.isNotBlank( pageBody ) ) {
				String mainTitle = pageBody.substringBetween( '<title>', 'Adirondack Fire Equipment website</title>' );
				truckRecord.Main_Title__c = SiteCalloutHelper.getReplaceString( mainTitle, FALSE );
				
				String price = pageBody.substringBetween( 'Asking $', '</li>' );
				if( String.isNotBlank( price ) ) {
					truckRecord.Asking_Price__c = Double.valueOf( price.replaceAll( ',', '' ) );
				}
				
				String engine = pageBody.substringBetween( '<p>Engine:', '</p>' );
				truckRecord.Additional_Apparatus_Info__c = SiteCalloutHelper.getReplaceString( engine, FALSE );
				
				String transmission = pageBody.substringBetween( '<p>Transmission:', '</p>' );
				truckRecord.Transmission_Model__c = transmission;
				
				String totalGVW = pageBody.substringBetween( '<p>Total GVW:', '</p>' );
				System.debug( 'totalGVW:-\n' + totalGVW );

				String mileage = pageBody.substringBetween( '<p>Mileage:', '</p>' );
				truckRecord.Mileage__c = mileage;
				
				String width = pageBody.substringBetween( '<p>Overall  Width:', '”</p>' );
				System.debug( 'width:-\n' + width );

				String length = pageBody.substringBetween( '<p>Overall Length:', '”</p>' );
				System.debug( 'length:-\n' + length );
				if( String.isNotBlank( length ) ) {
					length = length.replaceAll( '’', '.' ).replaceAll( '\'', '.' ).replaceAll( ' ', '' );
					truckRecord.Aerial_length__c = double.valueOf( length );
				}
				
				String height = pageBody.substringBetween( '<p>Overall  Height:', '”</p>' );
				System.debug( 'height:-\n' + height );

				String wheelBase = pageBody.substringBetween( '<p>Wheel Base:', '”</p>' );
				System.debug( 'wheelBase:-\n' + wheelBase );

				String frontTires = pageBody.substringBetween( '<p>Front Tires:', '</p>' );
				System.debug( 'frontTires:-\n' + frontTires );

				String rearTires = pageBody.substringBetween( '<p>Rear Tires:', '</p>' );
				System.debug( 'rearTires:-\n' + rearTires );
				
				Integer installedYearIndex = pageBody.indexOfIgnoreCase( ' – Installed' );
				if( installedYearIndex != -1 ) {
					Integer intDateIndex = pageBody.lastIndexOfIgnoreCase( '<p>', installedYearIndex );
					if( intDateIndex != -1 && pageBody.length() > 3 ) {
						
						String strYear = pageBody.subString( intDateIndex + 3, installedYearIndex );
						if( String.isNotBlank( strYear) ) {
							strYear = strYear.substringAfterLast( '/' );
							if( strYear.isNumeric() ) {
								truckRecord.Year__c = Integer.valueOf( strYear );
								if( truckRecord.Year__c < 100 ) {
									truckRecord.Year__c += 2000;
								}
							}
						}
					}
				}
				
				truckRecord.Chassis_Type__c = 'Custom';
				if( pageBody.contains( 'Commercial' ) ) {
					truckRecord.Chassis_Type__c = 'Commercial';
				}
			}
        }
        System.debug( 'AdirondackDetailPageUrlBatch-truckRecord:-\n' + JSON.serialize( truckRecord ) );
        return truckRecord;
    }
}