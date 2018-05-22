/*
 * @purpose: Controller Class for New Lightning Expense Component.
 * @CreatedDate: 15 June, 2017
 */
public class LightningExpensePageController {
    
    /*
     * @purpose: To Create new Expense Record
     * @param:   JSON of form input values
     * @return:  RequestBase - Informs if record is created along with the error or success message
     */
    @AuraEnabled
    public static String createExpenseItemRecord(String newExpenseWrapperJson){
        System.debug('######newExpenseWrapperJson : ' + JSON.serializePretty(newExpenseWrapperJson));
        NewExpensePageHelper.RequestBase expenseRecord = NewExpensePageHelper.createExpenseRecord(newExpenseWrapperJson);
        system.debug(expenseRecord);
        return JSON.serialize(expenseRecord); 
    } 
	
    /*
	 * @purpose: To search merchant(Account) and return result to the lightning component.
     * @param:   String
     * @return:  List<Account>
	 */
    @AuraEnabled
    public static List<Account> getExistingMerchant( String searchKey ){
        return NewExpensePageHelper.getExistingMerchant( searchKey );
    }
    
    /*
	 * @purpose: To search product and return result to the lightning component.
     * @param:   String
     * @return:  List<Product2>
	 */
    @AuraEnabled
    public static List<Product2> getExistingProduct( String searchKey ){
        return NewExpensePageHelper.getExistingProduct( searchKey );
    }
    
    /*
	 * @purpose: To search campaign and return result to the lightning component.
     * @param:   String
     * @return:  List<Account>
	 */
    @AuraEnabled
    public static List<Campaign> getExistingCampaign( String searchKey ){
        return NewExpensePageHelper.getExistingCampaign( searchKey );
    }
    
    /*
	 * @purpose: To search credit card and return result to the lightning component.
     * @param:   String
     * @return:  List<Employee_Credit_Cards__c>
	 */
    @AuraEnabled
    public static List<Employee_Credit_Cards__c> getExistingCreditCard( String searchKey ){
        return NewExpensePageHelper.getExistingCreditCard( searchKey );
    }
    
    /*
     * @purpose: To Create new Expense Merchant Record
     * @param:   Expense Merchant Name and Category
     * @return:  Expense Merchant Name and Category
     */
    @AuraEnabled
    public static String createExpenseMerchantRecord(String merchantName, String merchantCategory){
                
        return JSON.serialize(NewExpensePageHelper.createExpenseMerchantRecord(merchantName , merchantCategory));        
    }     
    

    /*
     * @purpose: To Upload reciept image
     * @param:   ExpenseItemID, Attachment body, Attachment name; attachment id 
     * @return:  Attachment Id/ Error Message
     */
    @AuraEnabled
    public static String doUploadAttachment(String expenseItemId, String attachmentBody, String attachmentName, String attachmentId) {        
        return NewExpensePageHelper.doUploadAttachment(expenseItemId, attachmentBody, attachmentName, attachmentId);
    }      


    /*
    * @purpose: To get picklist entry of Category picklist of Expense_Item__c object
    * @param:   -
    * return:   Map of category picklist entries
    */
    @AuraEnabled
    public static List<String> getCategory(){
        
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Expense_Item__c.Expense_Category__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntry = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry listEntry : picklistEntry) {
            options.add(listEntry.getValue());
        }       
        return options; 
    }

    /*
    * @purpose: To get picklist enry of Payment Type picklist of Expense_Item__c object
    * @param:   -
    * return:   Map of paymet picklist entries
    */
    @AuraEnabled
    public static List<String> getPaymentType(){

        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Expense_Item__c.Expense_Payment_Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntry = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry listEntry : picklistEntry) {
            options.add(listEntry.getValue());
        }       
        return options;
    }  
    
    /*
     * @purpose: To get picklist enry of Category of Expense_Merchant__c object
     * @param:   -
     * return:   Map of category picklist entries
     */
    @AuraEnabled
    public static List<String> getMerchantCategory(){

        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Account.Expense_Category__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntry = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry listEntry : picklistEntry) {
            options.add(listEntry.getValue());
        }       
        return options;
    }
    
    /*
     * @purpose: To get picklist enry of Expense Department of Expense_Item__c object
     * @param:   -
     * return:   Map of category picklist entries
     */
    @AuraEnabled
    public static List<String> getExpenseDepartment(){
        
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Expense_Item__c.Expense_Department__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntry = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry listEntry : picklistEntry) {
            options.add(listEntry.getValue());
        }       
        return options;
    } 
    
    /*
     * @purpose: To get picklist enry of User's Selected Department of current User.
     * @param:   -
     * return:   String.
     */
    @AuraEnabled
    public static String getUserDefaultData() {
        return NewExpensePageHelper.retrieveUserDefaultData();
    }    
    
    /* @purpose : To return the details of merchant
    */
    @AuraEnabled
    public static Account getExpenseMerchantDetails(Id merchangeId) {
        Account merchantAccount;
        
        try {
            merchantAccount = [SELECT Id, Expense_Category__c 
                               FROM Account  
                               WHERE Id = :merchangeId
                               Limit 1];
        } catch(Exception e) { }
        
        return merchantAccount;
    }
}