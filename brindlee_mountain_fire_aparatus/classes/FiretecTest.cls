/**
    @ Purpose : Tests the functionality of FiretecListViewBatch class.
*/

@isTest
public class FiretecTest {
    
    private static final String SITE_URL = 'http://www.firetec.com';
    
    @TestSetup static void insertTestData() {
        
        CompetitorSite__c site = new CompetitorSite__c
                                 (
                                  Site__c = SITE_URL,
                                  Active__c = TRUE,
                                  Batch_Class__c = 'FiretecListViewBatch'
                                 );
        INSERT site;
        System.assertEquals( 1, [ SELECT COUNT() FROM CompetitorSite__c WHERE ID =: site.Id ] );
    }
    
    public static TestMethod void testFiretec() {
        
        Test.startTest();
        
        Test.setMock( HttpCalloutMock.class, new MockResponseFiretec() );
        
        CompetitorSite__c site = [ SELECT ID, Site__c 
                                   FROM CompetitorSite__c 
                                   WHERE Active__c = TRUE AND Site__c =: SITE_URL 
                                   LIMIT 1 
                                 ];
        
        Database.executeBatch( new FiretecListViewBatch( site.Site__c, site.Id ), 1 );

        Test.stopTest();
        
        System.assertNotEquals( 0, [ SELECT COUNT() FROM Competitor_Site_Truck__c 
                                     WHERE Competitor_Site__c =: site.Id
                                   ] 
                              );
        System.assertNotEquals( NULL, [ SELECT Last_Record_Created_By_Batch__c 
                                         FROM CompetitorSite__c
                                        WHERE ID =: site.Id
                                        LIMIT 1
                                      ][0].Last_Record_Created_By_Batch__c
                              );
    }
}