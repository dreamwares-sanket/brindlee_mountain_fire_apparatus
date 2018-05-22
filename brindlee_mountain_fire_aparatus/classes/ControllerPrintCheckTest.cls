/**  
 * @Purpose      : Test Class for ControllerPrintCheck
 * @Author       : Dreamwares 
 * @Created Date : 03/05/2018
 */
@isTest
public class ControllerPrintCheckTest {
    /**
     * @Purpose : Method to create test data
     */
    @TestSetup
    public static void createTestData(){
        Account account = new Account(Name='Test Account');
        insert account;
                
        Contact contact = new Contact(FirstName='Test', LastName='Sample', AccountId=account.Id);
        insert contact;
                
        AcctSeed__Cash_Disbursement_Batch__c cashDisBatch = new AcctSeed__Cash_Disbursement_Batch__c(Name='Test');
                                                                                                    //AcctSeed__Current_Cash_Balance__c=200);
        insert cashDisBatch;
                
        AcctSeed__Accounting_Period__c accountingPeriod = new AcctSeed__Accounting_Period__c(Name='2018-05', AcctSeed__Start_Date__c=Date.today(),
                                                                                            AcctSeed__End_Date__c=Date.today().addMonths(3), AcctSeed__Status__c='Open');
        insert accountingPeriod;
                
        AcctSeed__GL_Account__c glAccount = new AcctSeed__GL_Account__c(Name='Test', AcctSeed__Active__c=true,
                                                                        AcctSeed__Type__c='Balance Sheet', 
                                                                        AcctSeed__Sub_Type_1__c='Assets',
                                                                        AcctSeed__Bank__c=true);
        insert glAccount;
                
        AcctSeed__Cash_Disbursement__c cashDisburse = new AcctSeed__Cash_Disbursement__c(AcctSeed__Cash_Disbursement_Batch__c=cashDisBatch.Id,
                                                                              AcctSeed__Type__c='Check', AcctSeed__Disbursement_Date__c=Date.today(),
                                                                              AcctSeed__Amount__c=5000, AcctSeed__Check_Number__c=12345,
                                                                              AcctSeed__Contact__c=contact.Id, AcctSeed__Accounting_Period__c=accountingPeriod.Id,
                                                                              AcctSeed__Source__c= 'Account Payable', AcctSeed__Bank_Account__c=glAccount.Id);
        insert cashDisburse;
                
        AcctSeed__Account_Payable__c accountPayable = new AcctSeed__Account_Payable__c(AcctSeed__Status__c='In Process',
                                                                                      AcctSeed__Discount_Amount__c=200,
                                                                                      AcctSeed__Credit_Memo_Applied_Amount__c=50,
                                                                                      AcctSeed__Contact__c=contact.Id, AcctSeed__Payee_Reference__c='Sample',
                                                                                      AcctSeed__Date__c=Date.today());
        insert accountPayable;
                
        AcctSeed__AP_Disbursement__c apDisburse = new AcctSeed__AP_Disbursement__c(AcctSeed__Accounting_Period__c=accountingPeriod.Id,
                                                                                  AcctSeed__Cash_Disbursement__c=cashDisburse.Id,
                                                                                  AcctSeed__Account_Payable__c=accountPayable.Id,
                                                                                  AcctSeed__Paid_Amount__c=8000);
        insert apDisburse;
    }
    
    /**
     * @Purpose: Test page for Cash Disbursement
     */
    static testMethod void testCashDisburse() {
        AcctSeed__Cash_Disbursement__c cashDisburse = [SELECT Id, Name FROM AcctSeed__Cash_Disbursement__c LIMIT 1];
        System.debug('cashDisburse::'+cashDisburse);
        
        Test.startTest();
    	PageReference pageRef = Page.PrintCheckPDF;
        pageRef.getParameters().put('id', cashDisburse.Id);
        Test.setCurrentPage(pageRef);
        
        ControllerPrintCheck controller = new ControllerPrintCheck();
        Test.stopTest();
        
        System.assertEquals(1, controller.cashDisbursementWrapperList.size());
    }
}