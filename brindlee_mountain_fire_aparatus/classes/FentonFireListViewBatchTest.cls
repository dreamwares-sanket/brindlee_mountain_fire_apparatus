/**
 * @Purpose  	: Test class for FentonFireListViewBatch
 * @Name 		: FentonFireListViewBatchTest
 * @Created date: 16/05/2018
 */
@isTest
public class FentonFireListViewBatchTest {
    /**
     * @Purpose : Method to create test data
     */
    @TestSetup
    public static void createTestData(){
        CompetitorSite__c site = new CompetitorSite__c(Site__c='http://www.firetrucksunlimited.com/', Active__c=true,
                                                      Batch_Class__c='Fenton fire test');
                                            
        insert site;
    }
    
    /**
     * @Purpose : Test method
     */ 
    public static testMethod void testFireTruckViewBatch(){
        CompetitorSite__c site = [SELECT Id, Name, Site__c FROM CompetitorSite__c LIMIT 1];
          
        Test.setMock(HttpCalloutMock.class, new MockResponseFentonFireBatchTest());
        
        Test.startTest();
        
        fentonFireListViewBatch batchInstance = new fentonFireListViewBatch(site.Site__c, site.Id);
        DataBase.executeBatch(batchInstance);
		
        Test.stopTest();
        
        Competitor_Site_Truck__c truck = [SELECT Id, Name FROM Competitor_Site_Truck__c LIMIT 1];
        System.assertNotEquals(null, truck.Id);
        
        CompetitorSite__c testSite = [SELECT Id, Name, Last_Record_Created_By_Batch__c FROM CompetitorSite__c LIMIT 1];
        System.assertNotEquals(null, testSite.Last_Record_Created_By_Batch__c);
    }
}