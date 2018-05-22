/**
 * @Description : To test DealerWeeklyNotifierBatch and DealerTrucksPDFController classes.
 * @Created Date : 14-07-2017 
 */
@isTest
public class dealerWeeklyNotifierBatchTest {
    
    @testSetup
    private static void setupData(){        
        
        Account account = new Account(Name = 'Test Account');
        INSERT account;
    
        Contact contact = new Contact(LastName = 'Test Contact', Email = 'test@test.com', AccountId = account.Id);
        INSERT contact;
        
        Fire_Truck__c fireTruck = new Fire_Truck__c(Year_of_Truck__c = 2017, Chassis_Manufacturer__c = '3D');
        INSERT fireTruck;
        
        // Get record type
        Id truckRecordTypeId = Schema.SObjectType.Product2.RecordTypeInfosByName.get('Trucks').RecordTypeId;
        
        Product2 product = new Product2(RecordTypeId = truckRecordTypeId, Name = 'Test Product', Fire_Truck__c = fireTruck.Id, apparatusType__c = 'Used Pumpers and Engines',
                                        IsActive = True, Post_To_Website__c = True, status__c = 'Available');
        INSERT product;
        
        Product2 fireTruckProduct = new Product2(RecordTypeId = truckRecordTypeId, Name = 'Test Suppressed Product', Fire_Truck__c = fireTruck.Id, 
                                                  apparatusType__c = 'Used Pumpers and Engines', IsActive = True, Post_To_Website__c = True, status__c = 'Available');
        INSERT fireTruckProduct;
        
        Dealer_FTF_Account__c dealerAccount = new Dealer_FTF_Account__c(Dealer__c = account.Id, Dealer_Email__c = 'abc1@gmail.com', 
                                                                        Dealer_Truck_Details__c = String.valueOf(product.Id) + ',' +
                                                                        					      String.valueOf(fireTruckProduct.Id) ); 
        INSERT dealerAccount;
        
        Dealer_FTF_Truck__c dealerFTFTruck = new Dealer_FTF_Truck__c( Dealer_FTF_Account__c = dealerAccount.Id,
                                                                      Truck__c = fireTruckProduct.Id );        
        INSERT dealerFTFTruck;
    }
    
    private static testMethod void testDealerWeeklyNotifierScheduler() {
                
        Test.startTest();
        
            dealerWeeklyNotifierBatch notifierBatch = new dealerWeeklyNotifierBatch();               
            notifierBatch.execute(null);
        
        Test.stopTest();
    }
    
    private static testMethod void testDealerTrucksPDFController() {
                
        Test.startTest();  
            
            Account account = [SELECT Id, Name FROM Account WHERE Name = 'Test Account' LIMIT 1 ];
            
            Dealer_FTF_Account__c dealer = [SELECT Id, Name FROM Dealer_FTF_Account__c WHERE Dealer__c =: account.Id LIMIT 1];
            
            PageReference pageRef = Page.dealerTrucksPDF;        
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id', dealer.Id);
                        
            dealerTrucksPDFController dealerTrucksPDF = new dealerTrucksPDFController();            
            List<Product2> productList = dealerTrucksPDF.truckList;         
            System.assert( productList.size() > 0 );
        
            Dealer_FTF_Account__c dealerAccount = new Dealer_FTF_Account__c(Dealer__c = account.Id, Dealer_Email__c = 'abc2@gmail.com'); 
            INSERT dealerAccount;
            
            pageRef.getParameters().put('id', dealerAccount.Id);    
                
            dealerTrucksPDFController dealerTruckController = new dealerTrucksPDFController();          
            productList = dealerTruckController.truckList;          
            System.assert( productList.isEmpty() );
        
        Test.stopTest();
    }
}