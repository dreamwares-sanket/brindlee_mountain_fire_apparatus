/*
* @ClassName    : FireTruckDeliveryWebService
* @Description  : Webservice to provide available fire truck details to the different web sites and
                  submit truck inquiry details in salesforce. 
* @Author       : Dreamwares
* @CreatedDate  : 12 May, 2017
*/

@RestResource ( urlMapping = '/FireTruckDelivery/*' )
global class FireTruckDeliveryWebService {
    
    /*
    * @Purpose  : get available fire truck details.
    * @Return   : String
    */
    @HttpGet
    global static String getFireTruckDetails() {
        
        List<Product2> fireTruckDetailList;         
        String accountId = RestContext.request.params.get('accountId');
        System.debug('accountId-' + accountId);
        RequestBase requestBase = new RequestBase();
        
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
                                                                    
            if( !dealerFTFAccountList.isEmpty() ) {
                
                Set<String> truckIdSet = new Set<String>();
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
                
                if( !truckIdSet.isEmpty() ) {
                    
                    requestBase.isDisplayTruckPricing = dealerFTFAccountList[0].Display_Truck_Pricing__c;
                    
                    try {
                        
                        fireTruckDetailList = Database.query( strQuery );
                    	
                        requestBase.isSuccess = true;
                    	requestBase.strMessage = 'Success';                           
                    	requestBase.recordList = fireTruckDetailList;
                    }
                    catch( Exception exc ) {
                        System.debug('Exception - ' + exc.getMessage() + ' Line - ' + exc.getLineNumber() + exc.getStackTraceString());
                        
                        requestBase.isSuccess = false;
                    	requestBase.strMessage = exc.getMessage();                           
                    	requestBase.recordList = fireTruckDetailList;
                    }
                }
            }
        }
        
        return JSON.serialize( requestBase );
    }
    
    /*
    * @Purpose  : create fire truck inquiry detail record related to website.
    * @Param    : String
    * @Return   : String
    */
    @HttpPost
    global static String createDealerWebsiteInquiry() {        
                
        RestRequest req = RestContext.request;
        String inquiryDetail = (req.requestBody.toString());
        if( String.isNotBlank( InquiryDetail ) ) {
            
            //Desearialize JSON string into wrapper class record.
            FireTruckDeliveryWebService.WebsiteInquiryWrapper inquiryWrapper;
            inquiryWrapper = (FireTruckDeliveryWebService.WebsiteInquiryWrapper) JSON.deserialize( InquiryDetail, FireTruckDeliveryWebService.WebsiteInquiryWrapper.class );
            
            System.debug('inquiryWrapper--'+inquiryWrapper);                        
            return createDealerFTFInquirer( inquiryWrapper );       // Create Dealer Website Inquirer from wrapper instance.
        }
        return 'Error';   
    }
    
    /*
     * @Purpose : get website inquiry record from wrapper instance and if Inquirer not exist then 
     *              create Inquirer (Contact) record.
     * @Param   : WebsiteInquiryWrapper
     * @Return  : DealerWebsiteInquiry 
     */
    public static String createDealerFTFInquirer( FireTruckDeliveryWebService.WebsiteInquiryWrapper inquiryWrapper ) {        
        
        RequestBase requestBase = new RequestBase();
        
        if( inquiryWrapper != NULL 
            && inquiryWrapper.LastName != NULL 
            && String.isNotBlank( inquiryWrapper.AccountId )
          ) {
              
            Dealer_FTF_Account__c dealerFTFAccount;
                        
            List<Contact> existingInquirerList;
            Contact inquirer;   
            
            try {
                  
                dealerFTFAccount = [SELECT Id, Name, Dealer__c
                                    FROM Dealer_FTF_Account__c
                                    WHERE Name =: inquiryWrapper.AccountId];
            }
            catch( Exception exc ) {
                System.debug('Exception - ' + exc.getMessage() + ' Line - ' + exc.getLineNumber() + exc.getStackTraceString());
            }
              
            if( inquiryWrapper.Email != NULL ) {
                
                try {
                    
                    existingInquirerList = [SELECT Id, FirstName, LastName, Phone, Email, AccountId, MailingCity, MailingState, 
                                                Inquiry_Truck_Message__c, Inquiry_Timeframe_for_Purchase__c
                                            FROM Contact
                                            WHERE Email =: inquiryWrapper.Email ];
                }
                catch( Exception exc ) {
                    System.debug('Exception - ' + exc.getMessage() + ' Line - ' + exc.getLineNumber() + exc.getStackTraceString());
                }                
            }
            
            if( existingInquirerList != NULL &&
                !existingInquirerList.isEmpty()) {
                    
                    inquirer = existingInquirerList.get( 0 );
                    
                    requestBase.isSuccess = true;
                    requestBase.strMessage = 'Success';
                    requestBase.recordList.add( inquirer );
            }
            else {         
                
                Account newFDorCompany = new Account();
                inquirer = new Contact();
                
                if( String.isNotBlank( inquiryWrapper.FDorCompany ) ) {
                    
                    newFDorCompany.Name = inquiryWrapper.FDorCompany;
                    
                    try {
                    
                        INSERT newFDorCompany;     // insert new Account record.        
                        inquirer.AccountId = newFDorCompany.Id; 
                    }
                    catch( Exception exc ) {
                        System.debug('Exception - ' + exc.getMessage() + ' Line - ' + exc.getLineNumber() + exc.getStackTraceString());
                    }
                }
                else {
                    inquirer.AccountId = dealerFTFAccount.Dealer__c;
                }
                
                // populate field values from wrapper instance.                
                 
                inquirer.FirstName = inquiryWrapper.FirstName;
                inquirer.LastName = inquiryWrapper.LastName;        
                //inquirer.Department = inquiryWrapper.FireDepartment;
                inquirer.Phone = inquiryWrapper.Phone;
                inquirer.Email = inquiryWrapper.Email;
                inquirer.Inquiry_Timeframe_for_Purchase__c = inquiryWrapper.PurchaseTimeFrame;                
                //inquirer.Interested_in_financing__c = inquiryWrapper.InterestedInFinancing == 'yes' ? true : false;
                inquirer.Inquiry_Truck_Message__c = inquiryWrapper.InquiryMessage;
                //inquirer.MailingCountry = inquiryWrapper.Country;
                inquirer.MailingCity = inquiryWrapper.City;
                inquirer.MailingState = inquiryWrapper.State; 
                inquirer.Contact_Frequency__c = 'No Goal';
                
                try {
                    
                    INSERT inquirer;     // insert dealer website inquirer record.                               
                    
                    requestBase.isSuccess = true;
                    requestBase.strMessage = 'Success';
                    requestBase.recordList.add( inquirer );
                }
                catch( Exception exc ) {
                    System.debug('Exception - ' + exc.getMessage() + ' Line - ' + exc.getLineNumber() + exc.getStackTraceString());
                    
                    requestBase.isSuccess = false;
                    requestBase.strMessage = exc.getMessage();
                    requestBase.recordList.add( inquirer );
                }
            }
            
            System.debug('inquiry--'+inquirer); 
            RequestBase inquiryRequestBase = createDealerFTFInquiry( inquirer, dealerFTFAccount.Id, inquiryWrapper );   // create dealer website inquiry record.
            requestBase.isSuccess = inquiryRequestBase.isSuccess;
            requestBase.strMessage = inquiryRequestBase.strMessage;
            requestBase.recordList.addAll( inquiryRequestBase.recordList );                
        }        
       
        return JSON.serialize( requestBase );
    }
    
    /*
     * @Purpose : create website Dealer FTF inquiry record related to Inquirer (ContactS) and
                    Truck (Product).
     * @Param   : Contact
     * @Return  : DealerWebsiteInquiry 
     */
    public static RequestBase createDealerFTFInquiry( Contact inquirer, ID webSiteAccountId,
                                                 				FireTruckDeliveryWebService.WebsiteInquiryWrapper inquiryWrapper ) { 
        RequestBase requestBase = new RequestBase();                                                            
        
        if( inquirer != NULL && 
           webSiteAccountId != NULL &&
           inquiryWrapper != NULL
          ) {              
                Dealer_FTF_Inquiry__c inquiry = new Dealer_FTF_Inquiry__c();
                
                inquiry.Dealer_FTF_Account__c = webSiteAccountId; 
                inquiry.Inquirer__c = inquirer.Id;
                inquiry.Truck__c = inquiryWrapper.TruckId;
                if( String.isNotBlank( inquiryWrapper.InquiryMessage ) ) {
                    inquiry.Inquiry_Message__c = inquiryWrapper.InquiryMessage;
                }
                if( String.isNotBlank( inquiryWrapper.PurchaseTimeFrame ) ) {
                    inquiry.Purchase_Timeframe__c = inquiryWrapper.PurchaseTimeFrame;
                }                
                
                try {
                    INSERT inquiry;
                    
                    requestBase.isSuccess = true;
                    requestBase.strMessage = 'Success';
                    requestBase.recordList.add( inquiry );                    
                }
                catch( Exception exc ) {
                    System.debug('Exception - ' + exc.getMessage() + ' Line - ' + exc.getLineNumber() + exc.getStackTraceString());
                    
                    requestBase.isSuccess = false;
                    requestBase.strMessage = exc.getMessage();
                    requestBase.recordList.add( inquiry );
                }
        }
        
        return requestBase;
    }
        
    public class WebsiteInquiryWrapper { 
        
        public String AccountId;
        public String FDorCompany;
        public String TruckId;
        public String FirstName;
        public String LastName;
        //public String FireDepartment;
        public String Phone;
        public String Email;
        public String PurchaseTimeFrame;        
        //public String InterestedInFinancing;
        public String InquiryMessage;
        //public String Country;
        public String City;
        public String State;
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