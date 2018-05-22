/**
 * @Purpose  	: Test class for FireTruckSunLimitedListViewBatch
 * @Name 		: FireTruckSunLimitedListViewBatchTest
 * @Created date: 15/05/2018
 */
@isTest
public class FireTruckSunLimitedListViewBatchTest {
    /**
     * @Purpose : Method to create test data
     */
    @TestSetup
    public static void createTestData(){
        CompetitorSite__c site = new CompetitorSite__c(Site__c='http://www.firetrucksunlimited.com/', Active__c=true,
                                                      Last_Record_Created_By_Batch__c=Date.today(), Batch_Class__c='Test');
        insert site;
    }
    
    /**
     * @Purpose : Test method
     */ 
    public static testMethod void testFireTruckViewBatch(){
        CompetitorSite__c site = [SELECT Id, Name, Site__c FROM CompetitorSite__c LIMIT 1];
          
        Test.setMock(HttpCalloutMock.class, new MockResponseFireTruckBatchTest());
        
        Test.startTest();
        
        fireTruckSunLimitedListViewBatch batchInstance = new fireTruckSunLimitedListViewBatch(site.Site__c, site.Id);
        DataBase.executeBatch(batchInstance);

        Test.stopTest();
        
        List<Competitor_Site_Truck__c> truckList = [SELECT Id, Name FROM Competitor_Site_Truck__c];
        System.assertNotEquals(0, truckList.size());
    }
}