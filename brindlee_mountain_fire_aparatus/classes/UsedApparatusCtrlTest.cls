/**
 * @created date : 16 Dec, 2015
 * @purpose      : To test the class UsedApparatusCtrlTest.
 */
@isTest
public class UsedApparatusCtrlTest {
	
    public testmethod static void testUsedApparatus() {
        Fire_Truck__c fireTruck = new Fire_Truck__c(Year_of_Truck__c = 2015);
        insert fireTruck;
        
        List<Product2> productList = new List<Product2>();
              
        for( Integer count =0; count < 5 ; count++ ){
            productList.add(new Product2(Name = 'Truck no. '+ count,
                                         Stock_Number__c = 'STK#' + count,
                                         Post_To_Website__c = True,
                                         apparatusType__c = 'Used Pumpers and Engines',
                                         Scene_Lights__c = 'Vibrant',
                                         Fire_Truck__c = fireTruck.Id));
        }
        insert productList;
        
        //ApexPages.StandardController sc = new ApexPages.StandardController();
        UsedApparatusCtrl usedApparatusCtrl  = new UsedApparatusCtrl();
        usedApparatusCtrl.getProducts();
    }
    	
}