/**
 * @Classname : DealerAccountCategoryCountBHTest
 * @Purpose   : To test DealerAccountCatgoryCountBatchHelper class.
 * @Date      : 05 October, 2017
 */
@isTest
private class DealerAccountCategoryCountBHTest{
    
    /**
     * @MethodName : createData
     * @Purpose    : To create data for testing.
     * @Parameters : -
     * @Return     : void
     */
    @testSetup
    static void createData() {
        
        List<Product2> productList = new List<Product2>();
        Product2 product;
        for(Integer count = 0; count < 50; count++){
            product = new Product2(Name = 'TestProduct', 
                                   isActive = true, 
                                   status__c = 'Available', 
                                   apparatusType__c = 'Used Pumpers and Engines;Rescue Pumpers and Engines;Pacific Rim Style Fire Apparatus');
            productList.add(product);
        }
        insert productList;
        
        String productIds = '';
        for(Product2 productTemp: productList){
            productIds = productIds + productTemp.Id + ',';
        }
        productIds = productIds.left(productIds.length() - 1);
        
        Dealer_FTF_Account__c dealerFTFAccount = new Dealer_FTF_Account__c(Dealer_Email__c = 'abc@example.com', 
                                                                           Dealer_Language_Code__c = 'en', 
                                                                           Dealer_Truck_Details__c = productIds);
        insert dealerFTFAccount;        
        
        List<Dealer_FTF_Suppressed_Truck__c> dealerFTFSuppressedTruckList = new List<Dealer_FTF_Suppressed_Truck__c>();
        Dealer_FTF_Suppressed_Truck__c dealerFTFSuppressedTruck;
        for(Integer count = 0; count < 50; count++){
            product = productList.get(count);
            if(Math.mod(count, 2) == 0){
                dealerFTFSuppressedTruck = new Dealer_FTF_Suppressed_Truck__c(Dealer_FTF_Account__c = dealerFTFAccount.Id, Truck__c = product.Id);
                dealerFTFSuppressedTruckList.add(dealerFTFSuppressedTruck);
            }
        }
        insert dealerFTFSuppressedTruckList;
        
        Dealer_Truck__c dealerTruck = new Dealer_Truck__c(Dealer_Account__c = dealerFTFAccount.Id, Status__c = 'Active', 
                                                          TruckProduct__c = productList[0].Id);
        insert dealerTruck;
    }
    
    /**
     * @MethodName : updateCategoryForEachAccountTest
     * @Purpose    : To test UpdateCategoryForEachAccount method.
     * @Parameters : -
     * @Return     : void
     */
    static testMethod void updateCategoryForEachAccountTest() {
        Test.startTest();
        
        Dealer_FTF_Account__c dealerFTFAccount = [SELECT Id, Dealer_Truck_Details__c, (SELECT Id, Truck__c FROM Dealer_FTF_Suppressed_Trucks__r) 
                                                  FROM Dealer_FTF_Account__c];
        
        DealerAccountCategoryCountBatchHelper dealerAccountCategory = new DealerAccountCategoryCountBatchHelper();
        String responseString = DealerAccountCategoryCountBatchHelper.UpdateCategoryForEachAccount(dealerFTFAccount);
        
        List<Dealer_FTF_Account_Category__c> dealerFTFAccountCategoryList = [SELECT Id, 
                                                                                 Truck_Count__c, 
                                                                                 Dealer_FTF_Account__c 
                                                                             FROM Dealer_FTF_Account_Category__c]; 
        
        System.debug(dealerFTFAccountCategoryList.size());
        
        for(Dealer_FTF_Account_Category__c accountCateory: dealerFTFAccountCategoryList){
            System.assertEquals(25, accountCateory.Truck_Count__c);
        }
        
        Database.executeBatch(new DealerAccountCategoryCountBatch(), 1);
        
        DealerAccountCategoryCountBatch testSchedular = new DealerAccountCategoryCountBatch();
        String sch = '0 0 * * * ?'; 
        system.schedule('Test Schedular', sch, testSchedular ); 
        
        DealerAccountCategoryCountBatchHelper.getDealerAccountCategoryCountBatch(dealerFTFAccount.Id);
        
        Test.stopTest();
    }

}