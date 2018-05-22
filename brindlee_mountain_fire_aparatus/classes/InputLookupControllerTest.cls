/*
 * @purpose: Test Class for InputLookupController
 * @CreatedDate: 3 Jan, 2017
 */
@isTest
public class InputLookupControllerTest {
    
    //Positive Test New Expense Controller
    public static testMethod void testNewExpenseControllerPositive(){
                
        Expense_Merchant__c expenseMerchant = new Expense_Merchant__c();
        expenseMerchant.Name = 'New Merchant';
        expenseMerchant.Category__c = 'Events';
        insert expenseMerchant;
        
        List<sObject> lstSelectedRecords = new List<sObject>();
        Test.startTest();
        lstSelectedRecords = InputLookupController.searchRecord('', 'Expense_Merchant__c', '','Name','Id','');
        lstSelectedRecords = InputLookupController.searchRecord('new', 'Expense_Merchant__c', 'Name','Name','Id','');
        Test.stopTest();  
        
        System.assertEquals(1, lstSelectedRecords.size());
    }
}