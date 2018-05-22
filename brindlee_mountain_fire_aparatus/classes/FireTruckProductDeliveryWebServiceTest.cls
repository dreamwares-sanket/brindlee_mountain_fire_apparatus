/*
 * @Description: Test Class for FireTruckProductDeliveryWebService
 * @CreatedDate: 9/10/2017
 */
@isTest
public class FireTruckProductDeliveryWebServiceTest{
    
    /**
    * Initial setup
    */
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
                                        IsActive = True, Post_To_Website__c = True, status__c = 'Available', Stock_Number__c = '123');
        INSERT product;
        
        Product2 suppressedProduct = new Product2(RecordTypeId = truckRecordTypeId, Name = 'Test Suppressed Product', Fire_Truck__c = fireTruck.Id, 
                                                  apparatusType__c = 'Used Pumpers and Engines', IsActive = True, Post_To_Website__c = True, 
                                                  status__c = 'Available', Stock_Number__c = '456');
        INSERT suppressedProduct;
        
        Dealer_FTF_Account__c dealerAccount = new Dealer_FTF_Account__c(Dealer__c = account.Id, Dealer_Truck_Details__c = String.valueOf(product.Id) + ',' +
                                                                                                   String.valueOf(suppressedProduct.Id),
                                                                        Dealer_Email__c = 'test@test.com', Dealer_Language_Code__c = 'en'); 
        INSERT dealerAccount;
        
        Dealer_FTF_Suppressed_Truck__c suppressedTruck = new Dealer_FTF_Suppressed_Truck__c( Dealer_FTF_Account__c = dealerAccount.Id,
                                                                                             Truck__c = suppressedProduct.Id);        
        INSERT suppressedTruck;
    }
    
    /**
    * To test get method for pagination
    */
    private static testMethod void testGetFireTruckDetailsForPagination(){
        
        Test.setMock(HttpCalloutMock.class, new FireTruckProductDeliveryMock());
        
        Dealer_FTF_Account__c dealer = [SELECT Id, Name 
                                         FROM Dealer_FTF_Account__c 
                                         LIMIT 1];
        
        Test.startTest();
        
        // for pagination
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/FireTruckProductDelivery';
        req.addParameter('accountId', ''+dealer.Name);
        req.addParameter('Category', 'Used Pumpers and Engines');
        req.addParameter('Page', '1');
        req.addParameter('PageSize', '10');
        req.httpMethod = 'GET';        
        RestContext.request = req; 
        
        Map<String, Object> resultOfPaginationMap = (Map<String, Object>) JSON.deserializeUntyped(FireTruckProductDeliveryWebService.getFireTruckDetails() );
        
        Test.stopTest();
        System.assert(resultOfPaginationMap.get('isSuccess') == true );
    }
    
    /**
    * To test get method for stockNo
    */
    private static testMethod void testGetFireTruckDetailsForStockNo(){
        Test.setMock(HttpCalloutMock.class, new FireTruckProductDeliveryMock());
        
         Dealer_FTF_Account__c dealer = [SELECT Id, Name 
                                         FROM Dealer_FTF_Account__c 
                                         LIMIT 1];
        
        Test.startTest();
        // for stock no
       
        RestRequest req2 = new RestRequest();
        req2.requestURI = '/services/apexrest/FireTruckProductDelivery';
        req2.addParameter('accountId', ''+dealer.Name);
        req2.addParameter('Category', 'Used Pumpers and Engines');
        req2.addParameter('Stockno', '123');
        req2.httpMethod = 'GET';        
        RestContext.request = req2; 
        
        Map<String, Object> resultOfStockMap = (Map<String, Object>) JSON.deserializeUntyped(FireTruckProductDeliveryWebService.getFireTruckDetails() );
       
        Test.stopTest();
        System.assert(resultOfStockMap.get('isSuccess') == true );
    }
    
    public class FireTruckProductDeliveryMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"foo":"bar"}');
            response.setStatusCode(200);
            
            return response;
        }
    }
}