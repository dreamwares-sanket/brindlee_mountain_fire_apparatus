/*
 * @purpose: Controller Class for NewExpensePage 
 * @CreatedDate: 21 December, 2016
 */
public class NewExpensePageController {
    
    /*
     * @purpose: To Create new Expense Record
     * @param:   JSON of form input values
     * @return:  RequestBase - Informs if record is created along with the error or success message
     */
    @remoteAction
    public static NewExpensePageHelper.RequestBase createExpenseRecord(String newExpenseWrapperJson){
        System.debug('newExpenseWrapperJson : ' + JSON.serializePretty(newExpenseWrapperJson));
        return NewExpensePageHelper.createExpenseRecord(newExpenseWrapperJson);        
    } 

    /*
     * @purpose: To Create new Expense Merchant Record
     * @param:   Expense Merchant Name and Category
     * @return:  Expense Merchant Name and Category
     */
    @remoteAction
    public static NewExpensePageHelper.RequestBase createExpenseMerchantRecord(String merchantName, String merchantCategory){
                
        return NewExpensePageHelper.createExpenseMerchantRecord(merchantName , merchantCategory);        
    }     
    

    /*
     * @purpose: To Upload reciept image
     * @param:   ExpenseItemID, Attachment body, Attachment name; attachment id 
     * @return:  Attachment Id/ Error Message
     */
    @RemoteAction
    public static String doUploadAttachment(String expenseItemId, String attachmentBody, String attachmentName, String attachmentId) {
        return NewExpensePageHelper.doUploadAttachment(expenseItemId, attachmentBody, attachmentName, attachmentId);
    }      


        /*
         * @purpose: To get picklist entry of Category picklist of Expense_Item__c object
         * @param:   -
         * return:   Map of category picklist entries
         */
    public static Map<String, String> getCategory(){
        
        return NewExpensePageHelper.getCategoryList();
    }

        /*
         * @purpose: To get picklist enry of Payment Type picklist of Expense_Item__c object
         * @param:   -
         * return:   Map of paymet picklist entries
         */
    public static Map<String, String> getPaymentType(){

        return NewExpensePageHelper.getPaymentTypeList();
    }  
    
    /*
     * @purpose: To get picklist enry of Category of Expense_Merchant__c object
     * @param:   -
     * return:   Map of category picklist entries
     */
    public static Map<String, String> getMerchantCategory(){

        return NewExpensePageHelper.getMerchantCategoryList();
    }
    
    /*
     * @purpose: To get picklist enry of Expense Department of Expense_Item__c object
     * @param:   -
     * return:   Map of category picklist entries
     */
    public static Map<String, String> getExpenseDepartment(){
        return NewExpensePageHelper.getExpenseDepartmentList();
    } 
    
    /*
     * @purpose: To get picklist enry of User's Selected Department of current User.
     * @param:   -
     * return:   String.
     */
    public static String getUserDefaultData() {
        return NewExpensePageHelper.retrieveUserDefaultData();
    }    
    
    /* @purpose : To return the details of merchant
    */
    @RemoteAction
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