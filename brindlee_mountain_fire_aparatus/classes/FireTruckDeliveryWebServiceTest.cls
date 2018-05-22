/*
 * @Description: Test Class for FireTruckDeliveryWebService 
 * @CreatedDate: 20 June, 2017
 */
@isTest
public class FireTruckDeliveryWebServiceTest {
    
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
        
        Product2 suppressedProduct = new Product2(RecordTypeId = truckRecordTypeId, Name = 'Test Suppressed Product', Fire_Truck__c = fireTruck.Id, 
                                                  apparatusType__c = 'Used Pumpers and Engines', IsActive = True, Post_To_Website__c = True, status__c = 'Available');
        INSERT suppressedProduct;
        
        Dealer_FTF_Account__c dealerAccount = new Dealer_FTF_Account__c(Dealer__c = account.Id, Dealer_Truck_Details__c = String.valueOf(product.Id) + ',' +
                                                                                                   String.valueOf(suppressedProduct.Id),
                                                                        Dealer_Language_Code__c = 'en',
                                                                        Dealer_Email__c = 'test@test.com'); 
        INSERT dealerAccount;
        
        Dealer_FTF_Suppressed_Truck__c suppressedTruck = new Dealer_FTF_Suppressed_Truck__c( Dealer_FTF_Account__c = dealerAccount.Id,
                                                                                             Truck__c = suppressedProduct.Id );        
        INSERT suppressedTruck;
    }
    
    //Positive Test Fire Truck Delivery WebService
    private static testMethod void testPositive(){
        Test.setMock(HttpCalloutMock.class, new FireTruckDeliveryMock());
        
        Test.startTest();
            
            Account account = [SELECT Id, Name FROM Account WHERE Name = 'Test Account' LIMIT 1 ];
            
            Dealer_FTF_Account__c dealer = [SELECT Id, Name FROM Dealer_FTF_Account__c WHERE Dealer__c =: account.Id LIMIT 1];
            
            Product2 product = [SELECT Id, Name FROM Product2 WHERE Name = 'Test Product' LIMIT 1 ];
            
            RestRequest req = new RestRequest(); 

            req.requestURI = '/services/apexrest/FireTruckDelivery';  
            req.addParameter('accountId', dealer.Name);         
            req.httpMethod = 'GET';
            
            RestContext.request = req;
            
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped( FireTruckDeliveryWebService.getFireTruckDetails() );          
            System.assert(resultMap.get('isSuccess') == true);
            
            String inquiryWrapperJson = '{ "AccountId" : "'+ dealer.Name +'",'+
                                        ' "TruckId" : "'+ product.Id +'",'+
                                        ' "FDorCompany": "Test FD or Company",' +
                                        ' "FirstName": "",' +
                                        ' "LastName": "test12354",'+
                                        ' "Phone": "",'+
                                        ' "Email": "",'+                                        
                                        ' "City": "",'+
                                        ' "PurchaseTimeframe": "",'+
                                        ' "State": "CA",'+
                                        ' "InquiryMessage": ""}';
                                        
            RestRequest req1 = new RestRequest(); 

            req1.requestURI = '/services/apexrest/FireTruckDelivery';
            req1.requestBody = Blob.valueOf(inquiryWrapperJson);
            req1.httpMethod = 'POST';
            
            RestContext.request = req1;
            
            resultMap = (Map<String, Object>) JSON.deserializeUntyped( FireTruckDeliveryWebService.createDealerWebsiteInquiry() );
            
            System.assert( resultMap.get('isSuccess') == true );          
            
        Test.stopTest();        
        
    }
    
    //Positive Test Existing Contact
    private static testmethod void testExistingContact() {
        
        Test.setMock(HttpCalloutMock.class, new FireTruckDeliveryMock());
        
        Test.startTest();
        
            Account account = [SELECT Id, Name FROM Account WHERE Name = 'Test Account' LIMIT 1 ];
            
            Dealer_FTF_Account__c dealer = [SELECT Id, Name FROM Dealer_FTF_Account__c WHERE Dealer__c =: account.Id LIMIT 1];
            
            Product2 product = [SELECT Id, Name FROM Product2 WHERE Name = 'Test Product' LIMIT 1 ];
        
            String inquiryWrapperJson1 = '{ "AccountId" : "'+ dealer.Name +'",'+
                                        ' "TruckId" : "'+ product.Id +'",'+
                                        ' "FDorCompany": "",' +
                                        ' "FirstName": "",' +
                                        ' "LastName": "test12354",'+
                                        ' "Phone": "",'+
                                        ' "Email": "test@test.com",'+                                        
                                        ' "City": "",'+
                                        ' "PurchaseTimeframe": "6 months - 12 months",'+
                                        ' "State": "CA",'+
                                        ' "InquiryMessage": "test"}';

            RestRequest req2 = new RestRequest(); 

            req2.requestURI = '/services/apexrest/FireTruckDelivery';
            req2.requestBody = Blob.valueOf(inquiryWrapperJson1);
            req2.httpMethod = 'POST';
            
            RestContext.request = req2; 
            
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped( FireTruckDeliveryWebService.createDealerWebsiteInquiry() );
            
            System.assert( resultMap.get('isSuccess') == true );
        
        Test.stopTest();
        
    }
    
    //Positive Test Existing Account
    private static testmethod void testExistingAccount() {
        
        Test.setMock(HttpCalloutMock.class, new FireTruckDeliveryMock());
        
        Test.startTest();
        
            Account account = [SELECT Id, Name FROM Account WHERE Name = 'Test Account' LIMIT 1 ];
            
            Dealer_FTF_Account__c dealer = [SELECT Id, Name FROM Dealer_FTF_Account__c WHERE Dealer__c =: account.Id LIMIT 1];
            
            Product2 product = [SELECT Id, Name FROM Product2 WHERE Name = 'Test Product' LIMIT 1 ];
        
            String inquiryWrapperJson1 = '{ "AccountId" : "'+ dealer.Name +'",'+
                                        ' "TruckId" : "'+ product.Id +'",'+
                                        ' "FDorCompany": "",' +
                                        ' "FirstName": "",' +
                                        ' "LastName": "test12354",'+
                                        ' "Phone": "",'+
                                        ' "Email": "",'+                                        
                                        ' "City": "",'+
                                        ' "PurchaseTimeframe": "6 months - 12 months",'+
                                        ' "State": "CA",'+
                                        ' "InquiryMessage": "test"}';

            RestRequest req2 = new RestRequest(); 

            req2.requestURI = '/services/apexrest/FireTruckDelivery';
            req2.requestBody = Blob.valueOf(inquiryWrapperJson1);
            req2.httpMethod = 'POST';
            
            RestContext.request = req2; 
            
            Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped( FireTruckDeliveryWebService.createDealerWebsiteInquiry() );
            
            System.assert( resultMap.get('isSuccess') == true );
        
        Test.stopTest();
        
    }
    
    public class FireTruckDeliveryMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"foo":"bar"}');
            response.setStatusCode(200);
            
            return response;
        }
    }
}