/*
 * @purpose: Helper Class for NewExpensePage Controller
 * @CreatedDate: 21 December, 2016
 */
public class NewExpensePageHelper {       
        
    /*
     * @purpose: To Create new Expense Record
     * @param:   JSON of form input values
     * @return:  RequestBase result and message
     */
    public static RequestBase createExpenseRecord(String newExpenseWrapperJson){
                
        RequestBase requestResult = new RequestBase();
        Expense_Item__c expenseItem = deserializeExpenseDetails(newExpenseWrapperJson);
        Boolean isExtendMsg = false;
        
        if(expenseItem == null){
            requestResult.isSuccess = false;
            requestResult.strError = 'Expense record not be created. Please enter valid values in all the fields.';
            return requestResult;
        }
        
        if(String.isBlank(expenseItem.Expense_Credit_Card__c)){
            requestResult.isSuccess = false;
            requestResult.strError = 'Please Select Expense Credit Card.';
            return requestResult;
        }
        Expense_Statement__c expenseStatement = getExpenseStatement(expenseItem.Expense_Date__c,expenseItem.Expense_Credit_Card__c); 
        Id loggedInUserId = UserInfo.getUserId();
        Date currentMonthDate = expenseItem.Expense_Date__c;
        
        if(expenseStatement == null){
            
            Integer numberOfDays = Date.daysInMonth(currentMonthDate.year(), currentMonthDate.month());
            
            expenseStatement = new Expense_Statement__c();
            expenseStatement.Expense_Status__c = 'Open';
            expenseStatement.Expense_Start_Date__c = currentMonthDate.toStartOfMonth();
            expenseStatement.Expense_End_Date__c = Date.newInstance(currentMonthDate.year(), currentMonthDate.month(), numberOfDays);
            expenseStatement.Employee__c = loggedInUserId;
            expenseStatement.Credit_Card__c = expenseItem.Expense_Credit_Card__c;
            try {
                insert expenseStatement;
                isExtendMsg = true;
            } catch(Exception e) {
                System.debug('Error in inserting Expense Statement record: ' + e.getMessage() + 'At Line No.: ' + e.getLineNumber());
                requestResult.isSuccess = false;
                requestResult.strError = 'Expense Statement not found.';
                return requestResult;
            }
        }
        
        expenseItem.Expense_Statement__c = expenseStatement.Id;
        expenseItem.Employee__c = loggedInUserId;
        
        try{
            insert expenseItem;       
            requestResult.id = expenseItem.Id;
            requestResult.isSuccess = true;
            requestResult.strError = 'Expense Record Created Successfully!!!';
            if(isExtendMsg) requestResult.strError += ' We Have Created New Expense Statement for Month : ' + 
                                                      DateTime.newInstance(currentMonthDate.year(), currentMonthDate.month(),currentMonthDate.day()).format('MMMMM');
            requestResult.confirmationImage = getConfirmationImageName();
            return requestResult;
        } catch(Exception e){
            System.debug('Error in inserting Expense Item record: ' + e.getMessage() + 'At Line No.: ' + e.getLineNumber());
            requestResult.isSuccess = false;
            requestResult.strError = 'Expense Record could not be created.\n ' + e.getMessage();
            requestResult.confirmationImage = '';
            return requestResult;
        }            
    }

    /*
     * @purpose: To get name of the confirmation Image
     * @param:   -
     * @return:  Confirmation Image Name
     */    
    public static String getConfirmationImageName(){
        String imageName = '';
        List<NewExpensePageConfirmImage__c> newExpensePageImageLsit = NewExpensePageConfirmImage__c.getall().values();
        
        for(NewExpensePageConfirmImage__c newExpenseImageName : newExpensePageImageLsit){            
            if(newExpenseImageName.isActive__c && String.isNotBlank(newExpenseImageName.Image_Name__c)){
                imageName = newExpenseImageName.Image_Name__c;
                break;
            }            
        }       
        return imageName;        
    }    

	/*
	 * @purpose: To search merchant(Account) and return result to the lightning component.
     * @param:   String
     * @return:  List<Account>
	 */
    public static List<Account> getExistingMerchant( String strSearchKey ) {
        
        List<Account> existingMerchantList;
        
        if( String.isNotBlank( strSearchKey ) ) {
            
        	strSearchKey += '%';
      
            try{
                existingMerchantList =  [SELECT Id, Name
                                         FROM Account 
                                         WHERE Name
                                         LIKE : strSearchKey ];
            }
            catch(Exception e){
                System.debug('Exception : ' + e);           
            }       
        
    	}
        return existingMerchantList;
    }
    
    /*
	 * @purpose: To search product and return result to the lightning component.
     * @param:   String
     * @return:  List<Product2>
	 */
    public static List<Product2> getExistingProduct( String strSearchKey ) {
        
        List<Product2> existingProductList;
        
        if( String.isNotBlank( strSearchKey ) ) {
            
        	strSearchKey += '%';
      
            try{
                existingProductList =  [SELECT Id, Name
                                        FROM Product2 
                                        WHERE Name
                                        LIKE : strSearchKey ];
            }
            catch(Exception e){
                System.debug('Exception : ' + e);           
            }       
        
    	}
        return existingProductList;
    }
    
    /*
	 * @purpose: To search campaign and return result to the lightning component.
     * @param:   String
     * @return:  List<Campaign>
	 */
    public static List<Campaign> getExistingCampaign( String strSearchKey ) {
        
        List<Campaign> existingCampaignList;
        
        if( String.isNotBlank( strSearchKey ) ) {
            
        	strSearchKey += '%';
      
            try{
                existingCampaignList =  [SELECT Id, Name
                                         FROM Campaign 
                                         WHERE Name
                                         LIKE : strSearchKey ];
            }
            catch(Exception e){
                System.debug('Exception : ' + e);           
            }       
        
    	}
        return existingCampaignList;
    }
    /*
	 * @purpose: To search credit card and return result to the lightning component.
     * @param:   String
     * @return:  List<Employee_Credit_Cards__c>
	 */
    public static List<Employee_Credit_Cards__c> getExistingCreditCard( String strSearchKey ) {
        
        List<Employee_Credit_Cards__c> existingCreditCardList;
        
        if( String.isNotBlank( strSearchKey ) ) {
            
        	strSearchKey += '%';
      
            try{
                existingCreditCardList =  [SELECT Id, Name, Credit_Cards__r.Id, Credit_Cards__r.Name,
                                           		Credit_Cards__r.Credit_Card_Number_E__c
                                           FROM Employee_Credit_Cards__c 
                                           WHERE Credit_Cards__r.Name
                                           LIKE : strSearchKey ];
            }
            catch(Exception e){
                System.debug('Exception : ' + e);           
            }       
        
    	}
        return existingCreditCardList;
    }
    
    
    /*
     * @purpose: To Create new Expense Merchant Record
     * @param:   Expense Merchant Name and Category
     * @return:  Expense Merchant Name and Category
     */    
    public static RequestBase createExpenseMerchantRecord(String merchantName, String merchantCategory){
        
        RequestBase requestResult = new RequestBase();
        Account expenseMerchantAcc = new Account();
        expenseMerchantAcc.Name = merchantName;        
        expenseMerchantAcc.Expense_Category__c = merchantCategory;
        expenseMerchantAcc.Company_Type__c = 'Vendor';
        try {
            insert expenseMerchantAcc;            
            requestResult.isSuccess = true;
            requestResult.id = expenseMerchantAcc.Id;
            requestResult.strError = 'Expense Merchant Record Created Successfully!!!';
            return requestResult;
        }
        catch(Exception e){
            System.debug('Error in inserting Expense Merchant record: ' + e.getMessage() + 'At Line No.: ' + e.getLineNumber());
            requestResult.isSuccess = false;
            requestResult.strError = 'Expense Merchant Record could not be created.\n ' + e.getMessage();
            return requestResult;            
        }        
    }   
    
    /*
     * @purpose: Get Expense Statement of Current month
     * @param:   -
     * @return:  Expense Statement Id
     */
    public static Expense_Statement__c getExpenseStatement(Date expenseDate, String expenseCreditCard){
        
        Expense_Statement__c expenseStatement;
        try {
            expenseStatement = [SELECT Id 
                                FROM Expense_Statement__c 
                                WHERE Expense_Start_Date__c <= :expenseDate AND 
                                      Expense_End_Date__c >= :expenseDate AND
                                      Expense_Status__c = 'Open' AND
                                	  Credit_Card__c = :expenseCreditCard AND
                                	  Employee__c =: UserInfo.getUserId()
                                LIMIT 1];            
        } catch(Exception e){
            System.debug('Could not fetch Expense_Statement__c record: ' + e.getMessage() + 'At Line No.: ' + e.getLineNumber());
        }
        return expenseStatement;
    }
    /*
     * @purpose: To Upload reciept image
     * @param:   ExpenseItemID, Attachment body, Attachment name; attachment id 
     * @return:  Attachment Id/ Error Message
     */
    
    public static String doUploadAttachment(String expenseItemId, String attachmentBody, String attachmentName, String attachmentId) {
        
        if(expenseItemId != null) {
            
            if(attachmentBody != null) {
                Attachment attachment = getAttachment(attachmentId);
                String newBody = '';
                
                if(attachment.Body != null) {
                    newBody = EncodingUtil.base64Encode(attachment.Body);
                }
                newBody += attachmentBody;
                attachment.Body = EncodingUtil.base64Decode(newBody);
                if(String.isBlank(attachmentId)) {
                    attachment.Name = attachmentName;
                    attachment.parentId = expenseItemId;
                }
                try{                    
                    upsert attachment;
                }
                catch(Exception e){
                    System.debug('Error in fetching Attachment. ' + e.getMessage() + '. At Line No.: ' + e.getLineNumber());
                    return 'Error in Uploading reciept photo. The following error has occurred: ' + e.getMessage();
                }                                
                
                return attachment.Id;
            } else {
                return 'Attachment Body was null';
            }
          
        } else {
            return 'Expense Item Id was null';
        }
    }      

    
    /*
     * @purpose: To get created attachment/ instantiate created attachment
     * @param:   Attachment Od
     * @return:  Attachment
     */
    
    public static Attachment getAttachment(String attachmentId){       
        if(String.isBlank(attachmentId)){
            Attachment attachment = new Attachment();
            return attachment;
        }
        else{
            Attachment attachment;
            try{
                attachment = [SELECT Name, Body FROM Attachment WHERE Id = :attachmentId ];
                
            }
            catch(Exception e){
                System.debug('Error in fetching Attachment. ' + e.getMessage() + '. At Line No.: ' + e.getLineNumber() );
            }
            return attachment;
        }
        
    }    
    
    /*
     * @purpose: To deserialize expense details which were sent as Json from the form
     * @param:   JSON String of expense details
     * @return:  ExpenseDetailWrapper object
     */
    public static Expense_Item__c deserializeExpenseDetails(String newExpenseWrapperJson){
        
        System.debug('newExpenseWrapperJson: ' + newExpenseWrapperJson);
        Expense_Item__c newExpenseDetails;
        try{
            newExpenseDetails = (Expense_Item__c)JSON.deserialize(newExpenseWrapperJson, Expense_Item__c.class);
        }
        catch(Exception e){
            System.debug('Could not deserialize Expense Details Search Wrapper Object : '+ e);
        }
        System.debug('****newExpenseDetails:****** ' + newExpenseDetails);
        return newExpenseDetails;
    }
    
    /*
    * @purpose: To get picklist entry of Category picklist of Expense_Item__c object
    * @param:   -
    * return:   Map of category picklist entries
    */
    public static Map<String, String> getCategoryList(){
        Map<String, String> mapOfCategory = new Map<String,String>();
        try{
            for(Schema.PicklistEntry entry : Expense_Item__c.Expense_Category__c.getDescribe().getPicklistValues()){
                mapOfCategory.put(entry.getValue() , entry.getLabel());
            }
        }
        catch(Exception e){
            System.debug('The following error has occurred: ' + e.getMessage() + '. At Line No.: ' + e.getLineNumber());
        }
        return mapOfCategory;
    }

    /*
     * @purpose: To get picklist enry of Payment Type picklist of Expense_Item__c object
     * @param:   -
     * return:   Map of paymet picklist entries
     */
    public static Map<String, String> getPaymentTypeList(){
        Map<String, String> mapOfPaymentType = new Map<String,String>();
        try{
            for(Schema.PicklistEntry entry : Expense_Item__c.Expense_Payment_Type__c.getDescribe().getPicklistValues()){
                mapOfPaymentType.put(entry.getValue() , entry.getLabel());
            }
        }
        catch(Exception e){
            System.debug('The following error has occurred: ' + e.getMessage() + '. At Line No.: ' + e.getLineNumber());
        }        
        return mapOfPaymentType;
    } 
    
    /*
     * @purpose: To get picklist enry of Expense Department picklist of Expense_Item__c object
     * @param:   -
     * return:   Map of paymet picklist entries
     */
    public static Map<String, String> getExpenseDepartmentList(){
        Map<String, String> mapOfPaymentType = new Map<String,String>();
        try{
            for(Schema.PicklistEntry entry : Expense_Item__c.Expense_Department__c.getDescribe().getPicklistValues()){
                mapOfPaymentType.put(entry.getValue() , entry.getLabel());
            }
        }
        catch(Exception e){
            System.debug('The following error has occurred: ' + e.getMessage() + '. At Line No.: ' + e.getLineNumber());
        }        
        return mapOfPaymentType;
    }
    
    /*
     * @purpose: To get Selected Department of current User
     * @param:   -
     * return:   String.
     */
    public static String retrieveUserDefaultData(){
        Map<String, String> userDefaultDataMap = new Map<String, String>();
        User loggedUser;
        try{
            loggedUser = [SELECT Expense_Department__c, (SELECT Id, Credit_Cards__r.Id, Credit_Cards__r.Name 
                                                         FROM Employee_Credit_Cards__r 
                                                         WHERE Default_Card__c = true) 
                          FROM User 
                          WHERE Id =: UserInfo.getUserId()];
        } catch(Exception e){
            System.debug('The following error has occurred: ' + e.getMessage() + '. At Line No.: ' + e.getLineNumber());
        }
        if(loggedUser != null) {
            userDefaultDataMap.put('UserSelectedDepartment', loggedUser.Expense_Department__c);
            if(loggedUser.Employee_Credit_Cards__r.size() > 0) {
                userDefaultDataMap.put('UserDefaultCreditCardName', loggedUser.Employee_Credit_Cards__r[0].Credit_Cards__r.Name);
                userDefaultDataMap.put('UserDefaultCreditCardId', loggedUser.Employee_Credit_Cards__r[0].Credit_Cards__r.Id);
            }
        }
        
        return JSON.Serialize(userDefaultDataMap);
    }
    
    /*
     * @purpose: To get picklist enry of Payment Type picklist of Expense_Item__c object
     * @param:   -
     * return:   Map of paymet picklist entries
     */
    public static Map<String, String> getMerchantCategoryList(){
        Map<String, String> mapOfCategory = new Map<String,String>();
        try{
            for(Schema.PicklistEntry entry : Account.Expense_Category__c.getDescribe().getPicklistValues()){
                mapOfCategory.put(entry.getValue() , entry.getLabel());
            }
        }
        catch(Exception e){
            System.debug('The following error has occurred: ' + e.getMessage() + '. At Line No.: ' + e.getLineNumber());
        }        
        return mapOfCategory;
    }     

    //Returns the response in the following format to the page
    public class RequestBase {
        public Boolean isSuccess;
        public String strError;
        public String id;
        public String confirmationImage;
    }
}