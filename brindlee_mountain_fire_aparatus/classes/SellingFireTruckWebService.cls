/*
* @ClassName    : SellingFireTruckWebService 
* @Description  : To information of "Selling your Used FireTruck" form and store it in 
                  "DealerFTF Sales Submissions" object 
* @Author       : Dreamwares
* @CreatedDate  : 14/09/2017
*/

@RestResource ( urlMapping = '/SellingFireTruck/*' )
global class SellingFireTruckWebService {

    
    /*
    * @Purpose  : get available fire truck details.
    * @Return   : String
    */
    @HttpGet
    global static String getFireTruckCategoreyDetails() {
        
        List<Dealer_FTF_Account_Category__c > fireTruckDetailList;         
        String accountId = RestContext.request.params.get('accountId');
        System.debug('accountId-' + accountId);
        ResponseBase responseBase = new ResponseBase();
        
        if( String.isNotBlank( accountId )) {            
            
            List<Dealer_FTF_Account__c> dealerFTFAccountList;
            
            try {
                
                dealerFTFAccountList = [SELECT Id, Name, Dealer__c, Dealer_Truck_Details__c, Display_Truck_Pricing__c,
                                               Dealer_Language_Code__c, 
                                        (SELECT Id, Truck__c
                                         FROM Dealer_FTF_Suppressed_Trucks__r)
                                        
                                        FROM Dealer_FTF_Account__c
                                        WHERE Name =: accountId];
            }
            catch( Exception exc ) {
                System.debug('Exception - ' + exc.getMessage() + ' Line - ' + exc.getLineNumber() + exc.getStackTraceString());
            }
            
            String strQuery = 'SELECT Id, Name, Truck_Count__c, Thumbnail_Image_Url__c FROM Dealer_FTF_Account_Category__c WHERE  Dealer_FTF_Account__r.Name = : accountId';
                      
            try {                
                fireTruckDetailList = Database.query( strQuery );
                
                responseBase.isSuccess = true;
                responseBase.strMessage = 'Success';                           
                responseBase.recordList = fireTruckDetailList;
                if(!dealerFTFAccountList.isEmpty()){
                    responseBase.isDisplayTruckPricing = dealerFTFAccountList[0].Display_Truck_Pricing__c; 
                    responseBase.strLanguageCode = dealerFTFAccountList[0].Dealer_Language_Code__c; 
                }
            }
            catch( Exception exc ) {
                System.debug('Exception - ' + exc.getMessage() + ' Line - ' + exc.getLineNumber() + exc.getStackTraceString());
                
                responseBase.isSuccess = false;
                responseBase.strMessage = exc.getMessage();                           
                responseBase.recordList = fireTruckDetailList;
            }
        }
        return JSON.serialize( responseBase );        
    }  
    
    /*
    * @Purpose  : create Dealer Sales Submission record from "SellingYourUsedFireTruck" form submission.
    * @Param    : String
    * @Return   : String
    */
    @HttpPost
    global static String createDealerSalesSubmission() {        
        
             
        RestRequest req = RestContext.request;
        String formDetail = (req.requestBody.toString());
        system.debug('formDetail ::' + formDetail );
        if(String.isNotBlank(formDetail)) {
            
            //Desearialize JSON string into wrapper class record.
            SellingFireTruckWebService.WebsiteSellWrapper sellWrapper;
            sellWrapper = (SellingFireTruckWebService.WebsiteSellWrapper) JSON.deserialize( formDetail, SellingFireTruckWebService.WebsiteSellWrapper.class );
                                    
            return createDealerFTFSales(sellWrapper);      
        }
        return 'Please provide form details.';   
    }
    
    /*
    * @Purpose  : create Dealer Sales Submission record .
    * @Param    : WebsiteSellWrapper 
    * @Return   : String
    */
    public static String createDealerFTFSales(SellingFireTruckWebService.WebsiteSellWrapper sellWrapper) {
        
        ResponseBase response = new ResponseBase();
        response.isSuccess = true;
        
        if(sellWrapper != null){
            Dealer_FTF_Sales_Submissions__c sales = new Dealer_FTF_Sales_Submissions__c();
            sales.First_Name__c = sellWrapper.FirstName; 
            sales.Last_Name__c = sellWrapper.LastName;
            sales.Fire_Department__c = sellWrapper.FireDepartment;
            sales.Email__c = sellWrapper.Email;
            sales.Phone__c = sellWrapper.Phone;
            sales.State__c = sellWrapper.State;
            sales.How_many_trucks_would_you_like_to_sell__c = sellWrapper.HowManyTrucksWouldYouLikeToSell;
            sales.AreYouConsideringBuyingUsedTruck__c = sellWrapper.Areyoualsoconsideringbuyingausedtruck;
            sales.What_Year_Is_Your_Truck__c = sellWrapper.Whatyearisyourtruck;
            sales.What_Type_Of_Truck__c = sellWrapper.WhatTypeOfTruck;
            sales.What_Brand_Is_Your_Truck__c = sellWrapper.Whatbrandisyourtruck;
            sales.When_Would_You_Like_To_Sell_Your_Truck__c = sellWrapper.WhenWouldYouLikeToSellYourTruck;
            sales.Have_You_Ordered_Replacement_Truck__c = sellWrapper.Haveyouorderedareplacementtruck;
            sales.What_Price_Is_Needed_For_Your_Truck__c = sellWrapper.WhatPriceIsNeededForYourTruck;
            sales.Comments__c = sellWrapper.Comments; 
            system.debug('formDetail ::' + sales + '::' + sellWrapper );

            if(String.isNotBlank(sellWrapper.AccountId)){
                
                response = getAccountId(sellWrapper.AccountId);
                
            }
            
            if(response.isSuccess){ 
                
                if(!response.recordList.isEmpty()){
                    
                    Dealer_FTF_Account__c account = (Dealer_FTF_Account__c)response.recordList[0];
                    sales.Dealer_FTF_Account__c = account.Id; 
                }          
                try{
                    insert sales;
                    response.strMessage = 'Success';
                    response.recordList.add(sales);
                }catch(Exception exp){
                    response.isSuccess = false;
                    response.strMessage = exp.getMessage();
                    System.debug('Exception ::::'+exp.getStackTraceString());
                }
            }
        }else{
            response.isSuccess = false;
            response.strMessage = 'Please provide details in proper format';
        }
        return JSON.serialize(response);
    }
    
    /*
    * @Purpose  : get Dealer_FTF_Account id from Dealer_FTF_Account name
    * @Param    : String
    * @Return   : ResponseBase
    */
    private static ResponseBase getAccountId(String accountName){
        
        ResponseBase response = new ResponseBase();
        response.isSuccess = true;
        Dealer_FTF_Account__c dealerFTFAccount;
        
        if(String.isNotBlank(accountName)){
            try{
            
                dealerFTFAccount = [SELECT Id, Name, Dealer__c
                                    FROM Dealer_FTF_Account__c
                                    WHERE Name =: accountName];
                                    
                response.recordList.add(dealerFTFAccount);                
            }catch(Exception exp){
                response.isSuccess = false;
                response.strMessage = exp.getMessage();
                System.debug('Exception :::'+exp.getMessage());
            }
        }
        return response;
    }
    
     public class WebsiteSellWrapper { 
        
        public String FirstName;
        public String LastName;
        public String FireDepartment; 
        public String AccountId;      
        public String Email;
        public String Phone;
        public String State;
        public String Howmanytruckswouldyouliketosell;        
        public String Areyoualsoconsideringbuyingausedtruck;
        public String Whatyearisyourtruck;
        public String WhatTypeOfTruck;
        public String Whatbrandisyourtruck;
        public String WhenWouldYouLikeToSellYourTruck;
        public String Haveyouorderedareplacementtruck;
        public String WhatPriceIsNeededForYourTruck;
        public String Comments;
    }
    
    public class ResponseBase{        
        public Boolean isSuccess;
        public String strMessage;  
        public Boolean isDisplayTruckPricing;
        public String strLanguageCode;
        public List<Object> recordList;
        public Map<String, Integer>mapCatgoeryCount;
        public ResponseBase() {
            recordList = new List<Object>();
        }
    }
}