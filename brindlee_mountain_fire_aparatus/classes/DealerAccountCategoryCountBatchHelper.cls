/*
@description - DealerAccountCategoryCountBatchHelper to create Count catgoery records
@createdDate - 28/09/2017
@createdBy   - Dreamwares
@lastModifiedDate - 20/12/2017
*/
global class DealerAccountCategoryCountBatchHelper {
    
    /**
    *    Execute batch class
    */
    webservice static void getDealerAccountCategoryCountBatch(String accountId){
        
        system.debug('accountId ::::'+accountId);
        if(String.isNotBlank(accountId)){
            
            try{
                Dealer_FTF_Account__c delarAccount = [SELECT Id, Name, Dealer__c, Dealer_Truck_Details__c, 
                                                             Display_Truck_Pricing__c, 
                                                        (SELECT Apparatus_Type__c, Truck_4x4__c, Truck_Brands__c, 
                                                                Truck_Chassis__c, Truck_Geographic_Region__c, 
                                                                Truck_Mileage__c, Truck_Price_Max__c, Truck_Price_Min__c, 
                                                                Truck_Pump_Size__c, Truck_Tank_Size__c, Truck_Warranty__c, 
                                                                Status__c, Type_of_Sale__c, Truck_Year_Max__c, Truck_Year_Min__c, 
                                                                Advertised_on_Brindlee_s_site__c 
                                                         FROM Dealer_FTF_Truck_Criteria__r 
                                                         LIMIT 90),
                                                        (SELECT Truck__c  FROM Dealer_FTF_Trucks__r),
                                                        (SELECT Id, Truck__c FROM Dealer_FTF_Suppressed_Trucks__r)  
                                                       FROM Dealer_FTF_Account__c
                                                       WHERE Id = :accountId];
                if(delarAccount != null){
                    
                   populateProductsPerFTFAccountBatch.saveDealerAccount(new List<Dealer_FTF_Account__c>{delarAccount}, false);
                }
            }catch(Exception exp){
                System.debug('Exception :::::'+exp.getMessage());
            }
        }
    }
    
    /**
    *    Update category records
    */    
    public static String UpdateCategoryForEachAccount(Dealer_FTF_Account__c delaerFTFAccount){
        
       
        ResponseBase response = new ResponseBase();
        response.isSuccess = true;
        List<Product2> fireTruckDetailList = new List<Product2>(); 
        Map<String, Integer> apparatusTypeToCountMap = new Map<String, Integer>();
        Integer count = 0;
        
        if(delaerFTFAccount != null ) {
            
            Set<String> truckIdSet = new Set<String>();
            Set<String> suppressedTruckIdSet = new Set<String>();
            // get existing records
            Map<String, Dealer_FTF_Account_Category__c> categoryNameToFTFAccountCategoryMap = getExistingDealerFTFAccountCategories(delaerFTFAccount.Id);
            
            if( !delaerFTFAccount.Dealer_FTF_Suppressed_Trucks__r.isEmpty() ) {
                
                for( Dealer_FTF_Suppressed_Truck__c suppressedTruck : delaerFTFAccount.Dealer_FTF_Suppressed_Trucks__r ) {
                    
                    if( suppressedTruck.Truck__c != null ) {
                        suppressedTruckIdSet.add( suppressedTruck.Truck__c );
                    }
                }
            }
            
            if( String.isNotBlank( delaerFTFAccount.Dealer_Truck_Details__c ) ) {
                truckIdSet.addAll( delaerFTFAccount.Dealer_Truck_Details__c.split(',') );                    
            }
            system.debug('truckIdSet :::'+truckIdSet);
            system.debug('suppressedTruckIdSet:::'+suppressedTruckIdSet);
            if(!truckIdSet.isEmpty()) {
                String strQuery = 'SELECT Id, ';
                
                List<Schema.FieldSetMember> fireTruckFieldSetMembersList = SObjectType.Product2.FieldSets.DFTF_Available_Truck_Detail.getFields();
                
                for( Schema.FieldSetMember member : fireTruckFieldSetMembersList) {
                    strQuery += member.getFieldPath() + ', ';
                }
                
                strQuery += '( SELECT Id, Amazon_S3_Image_URL__c, Amazon_S3_Main_Thumbnail_URL__c, Main_Image__c, Amazon_S3_Image_Thumbnail_URL__c' +
                    ' FROM Cloud_Documents__r' +
                    ' WHERE Show_Online__c = TRUE' + 
                    ' ORDER BY CreatedDate DESC ) FROM Product2' + 
                    ' WHERE Id IN : truckIdSet' + 
                    ' AND Id NOT IN : suppressedTruckIdSet' +  
                    ' AND IsActive = True' +                            
                    ' AND status__c IN (\'Available\', \'HOD\', \'Internal HOD\', \'On Lease\') ' + 
                    ' ORDER BY CreatedDate DESC';
            
            
                try {
                    
                    fireTruckDetailList = Database.query( strQuery );
                    if(!fireTruckDetailList.isEmpty()){
                        System.debug('fireTruckDetailList size ::::'+fireTruckDetailList.size());
                        
                        // create delar truck
                        saveDealerTrucks(delaerFTFAccount, fireTruckDetailList);
                        
                        for(Product2 currentProduct : fireTruckDetailList){
                            
                            if(currentProduct.apparatusType__c != null){
                                
                                for(String currentType :currentProduct.apparatusType__c.split(';')){
                                    if(!apparatusTypeToCountMap.containsKey(currentType)){
                                        apparatusTypeToCountMap.put(currentType, 1);
                                    }else{
                                        Integer typeCount = apparatusTypeToCountMap.get(currentType);
                                        apparatusTypeToCountMap.put(currentType, typeCount + 1);
                                    }
                                }
                            }
                            count ++;
                        }
                    }
                    System.debug('count 111111111 ::::'+count );
                    
                }catch( Exception exp) {
                    System.debug('Exception - ' + exp.getMessage() + ' Line - ' + exp.getLineNumber() + exp.getStackTraceString());
                    response.isSuccess = false;
                    response.message = exp.getMessage();
                }
                
                // to create new records
                if(response.isSuccess){
                    if(!apparatusTypeToCountMap.isEmpty()){
                        response = createDealerFTFAccountCategories(apparatusTypeToCountMap, delaerFTFAccount.Id, count, categoryNameToFTFAccountCategoryMap);
                    }else{
                        response = createDealerFTFAccountCategories(new Map<String, Integer>(), delaerFTFAccount.Id, 0, categoryNameToFTFAccountCategoryMap);
                    }
                }
            }else{
                response = createDealerFTFAccountCategories(new Map<String, Integer>(), delaerFTFAccount.Id, 0, categoryNameToFTFAccountCategoryMap);
            }
        }else{
            response.isSuccess = false;
            response.message = 'Please provide delaerFTFAccount record.';
        }        
        return JSON.serialize(response);
    }
    
    /**
    * To create new DealerFTFAccountCategory related to current account
    */
    private static ResponseBase createDealerFTFAccountCategories(Map<String, Integer> apparatusTypeToCountMap, String dealerFTFAccountId, Integer count, Map<String, Dealer_FTF_Account_Category__c> categoryNameToFTFAccountCategoryMap){
        
        ResponseBase response = new ResponseBase();
        response.isSuccess = true;
        List<Dealer_FTF_Account_Category__c> accountCategoryList = new List<Dealer_FTF_Account_Category__c>();
        
        if(String.isNotBlank(dealerFTFAccountId)){
            
            if(!apparatusTypeToCountMap.isEmpty()){
                for(String category : apparatusTypeToCountMap.keySet()){
                    Dealer_FTF_Account_Category__c dealerFTFAccount = new Dealer_FTF_Account_Category__c();
                    dealerFTFAccount.Name = category;
                    dealerFTFAccount.Dealer_FTF_Account__c = dealerFTFAccountId;
                    dealerFTFAccount.Thumbnail_Image_Url__c = categoryNameToFTFAccountCategoryMap != null 
                                                             && !categoryNameToFTFAccountCategoryMap.isEmpty() 
                                                             && categoryNameToFTFAccountCategoryMap.containsKey(category)?
                                                             categoryNameToFTFAccountCategoryMap.get(category).Thumbnail_Image_Url__c:
                                                             '';
                    dealerFTFAccount.Truck_Count__c = apparatusTypeToCountMap.get(category);
                    
                    accountCategoryList.add(dealerFTFAccount);                   
                }
            }
            accountCategoryList.add(new Dealer_FTF_Account_Category__c(Name = 'All', Dealer_FTF_Account__c = dealerFTFAccountId, Truck_Count__c = count));
            
            if(categoryNameToFTFAccountCategoryMap != null 
              && !categoryNameToFTFAccountCategoryMap.isEmpty()){
                try{
                    delete categoryNameToFTFAccountCategoryMap.values();
                }catch(Exception exp){
                    System.debug('Exception ::::'+exp.getMessage());
                    response.isSuccess = false;
                    response.message = exp.getMessage();
                }  
            }
            if(response.isSuccess && !accountCategoryList.isEmpty()){
                try{
                    insert accountCategoryList;
                }catch(Exception exp){
                    System.debug('Exception ::::'+exp.getMessage());
                    response.isSuccess = false;
                    response.message = exp.getMessage();
                }
            }
        }else{
            response.isSuccess = false;
            response.message = 'Please provide Dealer_FTF_Account Id.';
        }
        return response;
    }
    
    /**
    * To update/create Dealer Truck records
    */
    public static void saveDealerTrucks(Dealer_FTF_Account__c dealerAccount, List<Product2> fireTruckDetailList){
        
        
        if(dealerAccount != null && fireTruckDetailList != null && !fireTruckDetailList.isEmpty()){
            
            
            List<Dealer_Truck__c> dealerTruckList = new List<Dealer_Truck__c>();
            Map<String,String> accountProductToDealerTruckMap = getOldDealerTruck(new List<Dealer_FTF_Account__c>{dealerAccount});
            
            for(Product2 productRecord :fireTruckDetailList){
                
                if(!accountProductToDealerTruckMap.isEmpty() && accountProductToDealerTruckMap.containsKey(dealerAccount.Id+'-'+productRecord.Id)){
                    
                    dealerTruckList.add(new Dealer_Truck__c(Id = accountProductToDealerTruckMap.get(dealerAccount.Id+'-'+productRecord.Id), 
                                                            Status__c = 'Active'));
                    
                    // remove value from map
                    accountProductToDealerTruckMap.remove(dealerAccount.Id+'-'+productRecord.Id);
                }else{
                    
                    // for new record
                    dealerTruckList.add(new Dealer_Truck__c(Status__c = 'Active',
                                                            Dealer_Account__c = dealerAccount.Id,
                                                            TruckProduct__c = productRecord.Id));
                }
            }
              
            System.debug('accountProductToDealerTruckMap :::'+accountProductToDealerTruckMap);
            System.debug('accountProductToDealerTruckMap Size :::'+accountProductToDealerTruckMap.size());
            // for extra in valid record
            if(!accountProductToDealerTruckMap.isEmpty()){
                
                for(String dralerTruckId :accountProductToDealerTruckMap.values()){
                    
                    dealerTruckList.add(new Dealer_Truck__c(Id = dralerTruckId,
                                                            Status__c = 'Inactive'));
                    System.debug('Inactive dralerTruckId::::'+dralerTruckId);
                }
            }
            System.debug('dealerTruckList Size :::'+dealerTruckList.size());
            if(!dealerTruckList.isEmpty()){
                    
                try{
                    upsert dealerTruckList;
                }catch(Exception exp){
                    
                    System.debug('Eception ::::'+exp.getMessage());                    
                }
            } 
        }    
    }
    
    /**
    * get existing Dealer truck
    */
    private static Map<String,String> getOldDealerTruck(List<Dealer_FTF_Account__c> dealerAccountList){
        
        
        Map<String,String> accountProductToDealerTruckMap = new Map<String,String>();
        if(!dealerAccountList.isEmpty()){
        
            List<Dealer_Truck__c> truckList = new List<Dealer_Truck__c>();
            
            try{
                truckList = [SELECT Id, Dealer_Account__c, Status__c, TruckProduct__c
                             FROM Dealer_Truck__c
                             WHERE Dealer_Account__c IN :dealerAccountList
                             AND TruckProduct__c != null
                             LIMIT 50000];    
            }catch(Exception exp){
                System.debug('Exception :::'+exp.getMessage());
            }
            
            if(!truckList.isEmpty()){
                
                for(Dealer_Truck__c truck :truckList){
                
                   accountProductToDealerTruckMap.put(truck.Dealer_Account__c+'-'+ truck.TruckProduct__c, truck.Id); 
                }  
            }
        }
        return accountProductToDealerTruckMap;
    }
    
    /**
    * To get existing DealerFTFAccountCategory related to current account
    */
    private static Map<String, Dealer_FTF_Account_Category__c> getExistingDealerFTFAccountCategories(String dealerFTFAccountId){
        
        Map<String, Dealer_FTF_Account_Category__c> categoryNameToFTFAccountCategoryMap = new Map<String, Dealer_FTF_Account_Category__c>();
        if(String.isNotBlank(dealerFTFAccountId)){
            try{
                List<Dealer_FTF_Account_Category__c> accountCategoryList =  [SELECT Id, Name, Dealer_FTF_Account__c,                                                                Thumbnail_Image_Url__c, Truck_Count__c
                                                                             FROM Dealer_FTF_Account_Category__c
                                                                             WHERE Dealer_FTF_Account__c = :dealerFTFAccountId];
                for(Dealer_FTF_Account_Category__c category :accountCategoryList){
                    categoryNameToFTFAccountCategoryMap.put(category.Name, category);
                }
            }catch(Exception exp){
                System.debug('Exception ::::'+exp.getMessage());
            }    
        }
        return categoryNameToFTFAccountCategoryMap;
    }
    
    public class ResponseBase{        
        public Boolean isSuccess;
        public String message;  
    }
}