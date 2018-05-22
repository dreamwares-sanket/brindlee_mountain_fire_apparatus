/*
  * @Description An apex test class examine the AmazonS3ImageUploaderPageExtention's functionality.
 */
@isTest
private class AmazonS3ImageUploaderPageExtentionTest {
    // Alternate method declaration
    @isTest static void testAmazonS3ImageUploaderPageExtention() {
        
        Fire_Truck__c fireTruck = new Fire_Truck__c(Year_of_Truck__c = 2015, Chassis_Manufacturer__c = 'FMC');
        insert fireTruck;
        Product2 prod1 = new Product2(Name = 'testProduct', 
                                      apparatusType__c = 'Used Pumpers and Engines', 
                                      Fire_Truck__c = fireTruck.id);
        insert prod1;    
        ApexPages.StandardController sc = new ApexPages.StandardController(prod1);
        AmazonS3ImageUploaderPageExtention ASPE = new AmazonS3ImageUploaderPageExtention(sc);
        System.assertNotEquals('',ASPE.getLoginCredentials());
    }
}