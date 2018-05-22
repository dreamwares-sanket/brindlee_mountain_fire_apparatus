/*
* @ClassName    : FireTruckProductDeliveryWebService
* @Description  : To get Fire Truck related Information 
* @Author       : Dreamwares
* @CreatedDate  : 06 Oct, 2017
*/

@RestResource ( urlMapping = '/FireTruckProductDelivery/*' )
global class FireTruckProductDeliveryWebService {
    
    /*
    * @Purpose  : get available fire truck details.
    * @Return   : String
    */
    @HttpGet
    global static String getFireTruckDetails() {
        
        List<Product2> fireTruckDetailList; 
        List<Product2> fireTruckRelatedProductList;
        String accountId = RestContext.request.params.get('accountId');
        String category = RestContext.request.params.get('Category');     
        system.debug('category ::::category ' +category  );   
        category = String.isNotBlank(category) ? EncodingUtil.urlDecode(category , 'UTF-8') : '';        
        system.debug('category ::::category 2' +category  );   
        String page = RestContext.request.params.get('Page');        
        String pageSize = RestContext.request.params.get('PageSize');
        String stockNo = RestContext.request.params.get('Stockno'); 
        RequestBase requestBase = new RequestBase();
        requestBase.isSuccess = true;
        
        if( String.isNotBlank( accountId )) {            
            
            List<Dealer_FTF_Account__c> dealerFTFAccountList;
            
            try {
                
                dealerFTFAccountList = [SELECT Id, Name, Dealer__c, Dealer_Truck_Details__c, Display_Truck_Pricing__c,
                                        
                                          (SELECT Id, Truck__c
                                             FROM Dealer_FTF_Suppressed_Trucks__r)
                                        
                                        FROM Dealer_FTF_Account__c
                                        WHERE Name =: accountId];
            }
            catch( Exception exc ) {
                System.debug('Exception - ' + exc.getMessage() + ' Line - ' + exc.getLineNumber() + exc.getStackTraceString());
            }
            System.debug('dealerFTFAccountList ::::'+dealerFTFAccountList);                                                        
            if( !dealerFTFAccountList.isEmpty() ) {
                
                Set<String> truckIdSet = new Set<String>();
                List<String> categoryList = new List<String>();
                Set<String> suppressedTruckIdSet = new Set<String>();
                                                
                if( !dealerFTFAccountList[0].Dealer_FTF_Suppressed_Trucks__r.isEmpty() ) {
                    
                    for( Dealer_FTF_Suppressed_Truck__c suppressedTruck : dealerFTFAccountList[0].Dealer_FTF_Suppressed_Trucks__r ) {
                        
                        if( suppressedTruck.Truck__c != null ) {
                          suppressedTruckIdSet.add( suppressedTruck.Truck__c );
                        }
                    }
                }
                
                if( String.isNotBlank( dealerFTFAccountList[0].Dealer_Truck_Details__c ) ) {
                    truckIdSet.addAll( dealerFTFAccountList[0].Dealer_Truck_Details__c.split(',') );                    
                }
                System.debug('truckIdSet::::'+truckIdSet); 
                String strQuery = 'SELECT Id, ';
                
                List<Schema.FieldSetMember> fireTruckFieldSetMembersList = SObjectType.Product2.FieldSets.DFTF_Available_Truck_Detail.getFields();
                
                for( Schema.FieldSetMember member : fireTruckFieldSetMembersList) {
                   strQuery += member.getFieldPath() + ', ';
                }
                
                if(!truckIdSet.isEmpty() ) {
                    
                    strQuery += '( SELECT Id, Amazon_S3_Image_URL__c, Amazon_S3_Main_Thumbnail_URL__c, Main_Image__c, Amazon_S3_Image_Thumbnail_URL__c' +
                             ' FROM Cloud_Documents__r' +
                             ' WHERE Show_Online__c = TRUE' + 
                             ' ORDER BY CreatedDate DESC ) FROM Product2' + 
                            ' WHERE Id IN : truckIdSet' + 
                            ' AND Id NOT IN : suppressedTruckIdSet' +  
                            ' AND IsActive = True' +                            
                            ' AND status__c IN (\'Available\', \'HOD\', \'Internal HOD\', \'On Lease\') ';
                    
                    // for stock NO
                    if(String.isNotBlank(stockNo)){                     
                        strQuery = strQuery + ' AND Stock_Number__c = :stockNo';
                    }
                    System.debug('category ::::'+category);
                    if( String.isNotBlank(category) ) {
                        if(!category.equalsIgnoreCase('All')){
                            categoryList.addAll(category.split(';') ); 
                        
                            String newCategoryList = '';
                            
                            for(String currentCategory : categoryList){
                                System.debug('currentCategory ::::'+currentCategory );
                                newCategoryList  = newCategoryList  + '\''+String.escapeSingleQuotes(currentCategory)+ '\',';
                            }
                            newCategoryList = newCategoryList.removeEnd(',');
                            strQuery = strQuery +' AND apparatusType__c INCLUDES ('+newCategoryList+') ';
                        }
                    }
                    strQuery = strQuery + ' ORDER BY CreatedDate DESC';
                    requestBase.isDisplayTruckPricing = dealerFTFAccountList[0].Display_Truck_Pricing__c;
                    
                    try {
                        System.debug('Query strQuery ::::'+strQuery );
                        fireTruckDetailList = Database.query( strQuery );
                        requestBase.recordList = fireTruckDetailList;
                        
                        if(!fireTruckDetailList.isEmpty()){
                            
                            if(String.isBlank(stockNo)){
                            
                                fireTruckRelatedProductList = new List<Product2>();
                                
                                Integer currentPageSize = String.isNotBlank(pageSize)? 
                                                          Integer.valueOf(pageSize) > 0 ? Integer.valueOf(pageSize) :
                                                          1 :
                                                          1;
                                Integer currentPageNo = String.isNotBlank(page)? 
                                                        Integer.valueOf(page) > 0 ? Integer.valueOf(page) : 
                                                        1 : 
                                                        1;
                                                                
                                Integer index = (currentPageSize * currentPageNo) - currentPageSize; 
                                Integer numberOfRecords = (index + currentPageSize) - 1;
                                
                                System.debug('index :::'+index);
                                System.debug('numberOfRecords :::'+numberOfRecords);
                                // when page is last page
                                if(numberOfRecords > (fireTruckDetailList.size() - 1)){
                                    numberOfRecords = fireTruckDetailList.size() - 1;
                                }
                                
                                for(Integer currentIndex = index ; currentIndex <= numberOfRecords; currentIndex ++){                                 
                                    fireTruckRelatedProductList.add(fireTruckDetailList[currentIndex]);
                                }                               
                                requestBase.recordList = fireTruckRelatedProductList;
                            }
                        }
                        requestBase.isSuccess = true;
                        requestBase.strMessage = 'Success';
                    }
                    catch( Exception exc ) {
                        System.debug('Exception - ' + exc.getMessage() + ' Line - ' + exc.getLineNumber() + exc.getStackTraceString());
                        requestBase.isSuccess = false;
                        requestBase.strMessage = exc.getMessage();                           
                        requestBase.recordList = fireTruckDetailList;
                    }
                }else{
                    requestBase.isSuccess = false;
                    requestBase.strMessage = 'Please provide Dealer Truck Details.'; 
                }
            }else{
                requestBase.strMessage = 'No record found related to current Account Id.'; 
            }
        }else{
            requestBase.isSuccess = false;
            requestBase.strMessage = 'Please provide proper Account Id.'; 
        }
        System.debug('JSON :::::'+JSON.serialize(requestBase));
        return JSON.serialize(requestBase);
    }
    
     public class RequestBase {
        
        public Boolean isSuccess;
        public String strMessage;  
        public Boolean isDisplayTruckPricing;
        public List<Object> recordList;
        
        public RequestBase() {
            recordList = new List<Object>();
        }
    }
}