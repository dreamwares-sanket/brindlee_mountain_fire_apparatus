/*
 * @purpose: Test Class for NewExpensePageController 
 * @CreatedDate: 26 December, 2016
 */
@isTest
public class NewExpensePageControllerTest {
    
    //Positive Test New Expense Controller
    public static testMethod void testNewExpenseControllerPositive(){
        Integer currenMonth = Date.today().month();
        Integer nextMonth = Date.today().addMonths(1).month();
        Integer currentYear = Date.today().year();  
        
        NewExpensePageConfirmImage__c expenseItemImage = new NewExpensePageConfirmImage__c();
        expenseItemImage.Name = 'Confirmation Image';
        expenseItemImage.isActive__c = true;
        expenseItemImage.Image_Name__c = 'Image Name 1.png';
        insert expenseItemImage;
        
        List<Credit_Cards__c> expenseCreditCardList = new List<Credit_Cards__c>();
        expenseCreditCardList.add(new Credit_Cards__c(Name = 'Test Credit Card'));
        insert expenseCreditCardList;
        
        List<Expense_Statement__c> expenseStatementList = new List<Expense_Statement__c>();
        Expense_Statement__c expenseStatement1 = new Expense_Statement__c();
        expenseStatement1.Expense_Start_Date__c = Date.today().toStartOfMonth();        
        expenseStatement1.Expense_End_Date__c = Date.newInstance(currentYear, currenMonth, Date.daysInMonth(currentYear, currenMonth));
        expenseStatement1.Expense_Status__c  = 'Open';
        expenseStatement1.Credit_Card__c = expenseCreditCardList[0].id;
        expenseStatementList.add(expenseStatement1);
                
        insert expenseStatementList;
        
        
        Account expenseMerchantAcc = new Account();
        expenseMerchantAcc.Name = 'New Merchant';
        expenseMerchantAcc.Expense_Category__c = 'Events';
        insert expenseMerchantAcc;
        
        String newExpenseWrapperJson1 = '{"Merchant_Account__c":"'+ expenseMerchantAcc.Id +'",'+
                                        ' "Expense_Amount__c":"10.99",'+
                                        ' "Expense_Billable__c":true,'+
                                        ' "Expense_Date__c":'+ (DateTime.newInstance(currentYear, currenMonth, Date.today().addDays(5).day()).getTime()/1000)+','+
                                        ' "Expense_Reimbursable__c":true,'+
                                        ' "Expense_Category__c":"Meals",'+
                                        ' "Expense_Payment_Type__c":"Points",'+
            						    ' "Expense_Credit_Card__c":"' + expenseCreditCardList[0].id + '",'+
                                        ' "Expense_Department__c" : "Marketing"}';
        
        String newExpenseWrapperJson2 = '{"Merchant_Account__c":"'+ expenseMerchantAcc.Id +'",'+
                                        ' "Expense_Amount__c":"10.99",'+
                                        ' "Expense_Billable__c":true,'+
                                        ' "Expense_Date__c":'+ (DateTime.newInstance(currentYear, nextMonth, Date.today().addDays(5).day()).getTime()/1000)+','+
                                        ' "Expense_Reimbursable__c":true,'+
                                        ' "Expense_Category__c":"Meals",'+
                                        ' "Expense_Payment_Type__c":"Points",'+
            							' "Expense_Credit_Card__c":"' + expenseCreditCardList[0].id + '",'+
                                        ' "Expense_Department__c" : "Marketing"}';
        
        //Correct JSON format with no Credit Card ID
        String newExpenseWrapperJson3 = '{"Merchant_Account__c":"'+ expenseMerchantAcc.Id +'",'+
            							'"Expense_Amount__c":"10.99",'+
                                        ' "Expense_Billable__c":true,'+
                                        ' "Expense_Date__c":'+ (DateTime.newInstance(currentYear, nextMonth, Date.today().addDays(5).day()).getTime()/1000)+','+
                                        ' "Expense_Reimbursable__c":true,'+
                                        ' "Expense_Category__c":"Meals",'+
                                        ' "Expense_Payment_Type__c":"Points",'+            							
                                        ' "Expense_Department__c" : "Marketing"}';                                
        Test.startTest();
        //For Exist Expense Statement.
        NewExpensePageHelper.RequestBase expenseRecordResult1 = NewExpensePageController.createExpenseRecord(newExpenseWrapperJson1);        
        // For Create New Expense Statement.
        NewExpensePageHelper.RequestBase expenseRecordResult2 = NewExpensePageController.createExpenseRecord(newExpenseWrapperJson2);
        NewExpensePageHelper.RequestBase expenseMerchantRecordResult = NewExpensePageController.createExpenseMerchantRecord('Merchant Name', 'Meals');
        
        //No Credit Card value present
        NewExpensePageHelper.RequestBase expenseRecordResult3 = NewExpensePageController.createExpenseRecord(newExpenseWrapperJson3);
        
        Account expenseMerchantAccObj = NewExpensePageController.getExpenseMerchantDetails(expenseMerchantAcc.Id);
        String attId = NewExpensePageController.doUploadAttachment(expenseRecordResult1.id, 'test', 'testName', '');        
        Attachment att = NewExpensePageHelper.getAttachment(attId);
        
        Map<String, String> departmentOptions = NewExpensePageController.getExpenseDepartment();
        System.assert(departmentOptions.size() > 0);
        
        String UserSerializedData = NewExpensePageController.getUserDefaultData();
        System.assert(String.isNotBlank(UserSerializedData));
        
        Test.stopTest();
        
        List<Expense_Item__c> expenseItemList = [SELECT Id FROM Expense_Item__c];        
        System.assertEquals(2, expenseItemList.size());
        System.assert(expenseRecordResult1.isSuccess && expenseRecordResult2.isSuccess);
        System.assert(expenseMerchantRecordResult.isSuccess);
        System.assertEquals(false, expenseRecordResult3.isSuccess);
    }    

    //Test New Expense Controller when the Expense Statement record is present but JSON format is not correct
    public static testMethod void testNewExpenseController(){
        Integer currenMonth = Date.today().month();
        Integer currentYear = Date.today().year();
        
        Expense_Statement__c expenseStatement = new Expense_Statement__c();
        expenseStatement.Expense_Start_Date__c = Date.today().toStartOfMonth();
        expenseStatement.Expense_End_Date__c = Date.newInstance(currentYear, currenMonth, Date.daysInMonth(currentYear, currenMonth));
        expenseStatement.Expense_Status__c  = 'Open';
        insert expenseStatement;

        String newExpenseWrapperJson = '{"Expense_Amount__c":"abc",'+
                                       ' "Expense_Billable__c":true,'+
                                       ' "Expense_Date__c":'+ (DateTime.newInstance(currentYear, currenMonth, Date.today().addDays(5).day()).getTime()/1000) +','+
                                       ' "Expense_Reimbursable__c":true,'+
                                       ' "Expense_Category__c":"Meals",'+
                                       ' "Expense_Payment_Type__c":"Points",'+
                                       ' "Expense_Department__c" : "Marketing"}';
        
        Test.startTest();
        NewExpensePageHelper.RequestBase expenseRecordResult = NewExpensePageController.createExpenseRecord(newExpenseWrapperJson);                
        Test.stopTest();  
        
        List<Expense_Item__c> expenseItemList = [SELECT Id FROM Expense_Item__c];        
        System.assertEquals(0, expenseItemList.size());
        System.assert(!expenseRecordResult.isSuccess);        
    } 
    
    //Negative Test New Expense Controller
    public static testMethod void testNewExpenseControllerNegative(){
        Integer currenMonth = Date.today().month();
        Integer currentYear = Date.today().year();
        
        String newExpenseWrapperJson = '{"Expense_Amount__c":"abc",'+
                                       ' "Expense_Billable__c":true,'+
                                       ' "Expense_Date__c":'+ (DateTime.newInstance(currentYear, currenMonth, Date.today().addDays(5).day()).getTime()/1000) +','+
                                       ' "Expense_Reimbursable__c":true,'+
                                       ' "Expense_Category__c":"Meals",'+
                                       ' "Expense_Payment_Type__c":"Points"}';
                
        Test.startTest();
        NewExpensePageController.getCategory();
        NewExpensePageController.getPaymentType();
        NewExpensePageController.getMerchantCategory();
        NewExpensePageHelper.RequestBase expenseRecordResult = NewExpensePageController.createExpenseRecord(newExpenseWrapperJson);
        NewExpensePageHelper.RequestBase expenseMerchantRecordResult = NewExpensePageController.createExpenseMerchantRecord('Merchant Name', 'Meal');                
        Test.stopTest(); 
        
        List<Expense_Item__c> expenseItemList = [SELECT Id FROM Expense_Item__c];       
        System.assertEquals(0, expenseItemList.size());
        System.assertEquals(false, expenseRecordResult.isSuccess);
        System.assertEquals(false, expenseMerchantRecordResult.isSuccess);
    }  
}