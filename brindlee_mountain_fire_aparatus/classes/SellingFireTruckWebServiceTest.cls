/**
* @Purpose : To test SellingFireTruckWebService class
* @Date    : 15/09/2017
* @Author  : Dreamwares
*/
@isTest
public class SellingFireTruckWebServiceTest{
    
    /**
    * To test post method
    */
    private static testmethod void testExistingAccount() {
        
        Dealer_FTF_Account__c account = new Dealer_FTF_Account__c();
        account.Dealer_Email__c = 'test@test.com';
        account.Dealer_Language_Code__c = 'en';
        insert account;
        
        Dealer_FTF_Account__c newAccount = [SELECT Id, Name
                                            FROM Dealer_FTF_Account__c 
                                            LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new SellingFireTruckMock());
        
        Test.startTest();
    
        String sellWrapperJson = '{ "FirstName": "Test", "LastName": "Test", "Phone": "989-999-9999", '+
                                 '"Email": "DWS@dreamwares.com", "FireDepartment": "Test", "State": "Alabama", '+
                                 '"Howmanytruckswouldyouliketosell": "10", "Areyoualsoconsideringbuyingausedtruck": "Yes", '+
                                 '"Whatyearisyourtruck": "10", "WhatTypeOfTruck": "Command Units", '+
                                 '"Whatbrandisyourtruck": "Test", "Haveyouorderedareplacementtruck": "Yes", '+
                                 '"WhatPriceIsNeededForYourTruck": "100", "Comments": "Test Comment", '+
                                 '"WhenWouldYouLikeToSellYourTruck":"Today", "AccountId" : "'+newAccount.Name+'"}';

        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/SellingFireTruck';
        req.requestBody = Blob.valueOf(sellWrapperJson);
        req.httpMethod = 'POST';        
        RestContext.request = req; 
        
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(SellingFireTruckWebService.createDealerSalesSubmission() );
        
        System.assert(resultMap.get('isSuccess') == true );
        
        Test.stopTest();
        
    }
    
    /**
    * To test post method
    */
    private static testmethod void testGetFireTruckCategoreyDetails() {
        Dealer_FTF_Account__c account = new Dealer_FTF_Account__c();
        account.Dealer_Email__c = 'test@test.com';
        account.Dealer_Language_Code__c = 'en';
        insert account;
        
        Dealer_FTF_Account__c newAccount = [SELECT Id, Name
                                            FROM Dealer_FTF_Account__c 
                                            LIMIT 1];
        
        Test.setMock(HttpCalloutMock.class, new SellingFireTruckMock());
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/SellingFireTruck';
        req.addParameter('accountId', ''+newAccount.Id);
        req.httpMethod = 'GET';        
        RestContext.request = req; 
        
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(SellingFireTruckWebService.getFireTruckCategoreyDetails() );
        System.assert(resultMap.get('isSuccess') == true );
        
        Test.stopTest();
    }
    
    public class SellingFireTruckMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"isSuccess":"true"}');
            response.setStatusCode(200);
            
            return response;
        }
    }
}