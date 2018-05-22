/*
 * @Description: Test Class for LightningExpensePageController 
 * @CreatedDate: 20 June, 2017
 */
@isTest
public class LightningExpensePageControllerTest {
    
    @testSetup
    private static void setupData(){
        
        Credit_Cards__c creditCard = new Credit_Cards__c(Name = 'Credit Card 123');
        INSERT creditCard;  
        
        Employee_Credit_Cards__c employeeCard = new Employee_Credit_Cards__c(Credit_Cards__c = creditCard.Id);
        INSERT employeeCard;
        
        
        Account merchantAccount = new Account(Name = 'Test Account');
        INSERT merchantAccount;
        
        // Get record type
        Id serviceRecordTypeId = Schema.SObjectType.Product2.RecordTypeInfosByName.get('Service').RecordTypeId;
        
        Product2 product = new Product2(RecordTypeId = serviceRecordTypeId, Name = 'Test Product', Stock_Number__c = 'test12354');
        INSERT product;
        
        Campaign campaign = new Campaign(Name='Test Campaign');
        INSERT campaign;
    }
    
    //Positive Test Lightning Expense Page Controller
    public static testMethod void testPositive(){
        
        List<Account> existingMerchantList = LightningExpensePageController.getExistingMerchant('Test');
        System.assert(existingMerchantList.size() > 0);
        
        List<Product2> existingProductList = LightningExpensePageController.getExistingProduct('Test');
        System.assert(existingProductList.size() > 0);
        
        List<Campaign> existingCampaignList= LightningExpensePageController.getExistingCampaign('Test');
        System.assert(existingCampaignList.size() > 0);
        
        List<Employee_Credit_Cards__c> existingCreditCardList = LightningExpensePageController.getExistingCreditCard('Credit');
        System.assert(existingCreditCardList.size() > 0);
        
        Integer currenMonth = Date.today().month();
        Integer nextMonth = Date.today().addMonths(1).month();
        Integer currentYear = Date.today().year();  
        
        NewExpensePageConfirmImage__c expenseItemImage = new NewExpensePageConfirmImage__c();
        expenseItemImage.Name = 'Confirmation Image';
        expenseItemImage.isActive__c = true;
        expenseItemImage.Image_Name__c = 'Image Name 1.png';
        INSERT expenseItemImage;
        
        List<Credit_Cards__c> expenseCreditCardList = new List<Credit_Cards__c>();
        expenseCreditCardList.add(new Credit_Cards__c(Name = 'Test Credit Card'));
        INSERT expenseCreditCardList;
        
        List<Expense_Statement__c> expenseStatementList = new List<Expense_Statement__c>();
        Expense_Statement__c expenseStatement1 = new Expense_Statement__c();
        expenseStatement1.Expense_Start_Date__c = Date.today().toStartOfMonth();        
        expenseStatement1.Expense_End_Date__c = Date.newInstance(currentYear, currenMonth, Date.daysInMonth(currentYear, currenMonth));
        expenseStatement1.Expense_Status__c  = 'Open';
        expenseStatement1.Credit_Card__c = expenseCreditCardList[0].id;
        expenseStatementList.add(expenseStatement1);
                
        INSERT expenseStatementList;        
        
        Account expenseMerchantAcc = new Account();
        expenseMerchantAcc.Name = 'New Merchant';
        expenseMerchantAcc.Expense_Category__c = 'Events';
        INSERT expenseMerchantAcc;
        
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
        NewExpensePageHelper.RequestBase expenseRecordResult1 = (NewExpensePageHelper.RequestBase)JSON.deserialize
                                                                (
                                                                    LightningExpensePageController.createExpenseItemRecord(newExpenseWrapperJson1), 
                                                                    NewExpensePageHelper.RequestBase.class
                                                                );  

        // For Create New Expense Statement.
        NewExpensePageHelper.RequestBase expenseRecordResult2 = (NewExpensePageHelper.RequestBase)JSON.deserialize
                                                                (
                                                                    LightningExpensePageController.createExpenseItemRecord(newExpenseWrapperJson2), 
                                                                    NewExpensePageHelper.RequestBase.class
                                                                );
                                                                
        NewExpensePageHelper.RequestBase expenseMerchantRecordResult = (NewExpensePageHelper.RequestBase)JSON.deserialize
                                                                        (
                                                                            LightningExpensePageController.createExpenseMerchantRecord('Merchant Name', 'Meals'), 
                                                                            NewExpensePageHelper.RequestBase.class
                                                                        );
        
        //No Credit Card value present
        NewExpensePageHelper.RequestBase expenseRecordResult3 = (NewExpensePageHelper.RequestBase)JSON.deserialize
                                                                (
                                                                    LightningExpensePageController.createExpenseItemRecord(newExpenseWrapperJson3), 
                                                                    NewExpensePageHelper.RequestBase.class
                                                                );      
        
        Account expenseMerchantAccObj = LightningExpensePageController.getExpenseMerchantDetails(expenseMerchantAcc.Id);
        String attId = LightningExpensePageController.doUploadAttachment(expenseRecordResult1.id, 'test', 'testName', '');        
        Attachment att = NewExpensePageHelper.getAttachment(attId);
        
        List<String> departmentOptions = LightningExpensePageController.getExpenseDepartment();
        System.assert(departmentOptions.size() > 0);
        
        String UserSerializedData = LightningExpensePageController.getUserDefaultData();
        System.assert(String.isNotBlank(UserSerializedData));
        
        Test.stopTest();
        
        List<Expense_Item__c> expenseItemList = [SELECT Id FROM Expense_Item__c];        
        System.assertEquals(2, expenseItemList.size());
        System.assert(expenseRecordResult1.isSuccess && expenseRecordResult2.isSuccess);
        System.assert(expenseMerchantRecordResult.isSuccess);
        System.assertEquals(false, expenseRecordResult3.isSuccess);
    }    

    //Test New Expense Controller when the Expense Statement record is present but JSON format is not correct
    public static testMethod void testLightningExpensePageController(){
        Integer currenMonth = Date.today().month();
        Integer currentYear = Date.today().year();
        
        Expense_Statement__c expenseStatement = new Expense_Statement__c();
        expenseStatement.Expense_Start_Date__c = Date.today().toStartOfMonth();
        expenseStatement.Expense_End_Date__c = Date.newInstance(currentYear, currenMonth, Date.daysInMonth(currentYear, currenMonth));
        expenseStatement.Expense_Status__c  = 'Open';
        INSERT expenseStatement;

        String newExpenseWrapperJson = '{"Expense_Amount__c":"abc",'+
                                       ' "Expense_Billable__c":true,'+
                                       ' "Expense_Date__c":'+ (DateTime.newInstance(currentYear, currenMonth, Date.today().addDays(5).day()).getTime()/1000) +','+
                                       ' "Expense_Reimbursable__c":true,'+
                                       ' "Expense_Category__c":"Meals",'+
                                       ' "Expense_Payment_Type__c":"Points",'+
                                       ' "Expense_Department__c" : "Marketing"}';
        
        Test.startTest();
        NewExpensePageHelper.RequestBase expenseRecordResult = (NewExpensePageHelper.RequestBase)JSON.deserialize
                                                                (
                                                                    LightningExpensePageController.createExpenseItemRecord(newExpenseWrapperJson),    
                                                                    NewExpensePageHelper.RequestBase.class
                                                                );                  
        Test.stopTest();  
        
        List<Expense_Item__c> expenseItemList = [SELECT Id FROM Expense_Item__c];        
        System.assertEquals(0, expenseItemList.size());
        System.assert(!expenseRecordResult.isSuccess);        
    } 
    
    //Negative Test Lightning Expense Page Controller
    public static testMethod void testNegative(){
        Integer currenMonth = Date.today().month();
        Integer currentYear = Date.today().year();
        
        String newExpenseWrapperJson = '{"Expense_Amount__c":"abc",'+
                                       ' "Expense_Billable__c":true,'+
                                       ' "Expense_Date__c":'+ (DateTime.newInstance(currentYear, currenMonth, Date.today().addDays(5).day()).getTime()/1000) +','+
                                       ' "Expense_Reimbursable__c":true,'+
                                       ' "Expense_Category__c":"Meals",'+
                                       ' "Expense_Payment_Type__c":"Points"}';
                
        Test.startTest();
        LightningExpensePageController.getCategory();
        LightningExpensePageController.getPaymentType();
        LightningExpensePageController.getMerchantCategory();
        NewExpensePageHelper.RequestBase expenseRecordResult = (NewExpensePageHelper.RequestBase)JSON.deserialize
                                                                (
                                                                    LightningExpensePageController.createExpenseItemRecord(newExpenseWrapperJson),    
                                                                    NewExpensePageHelper.RequestBase.class
                                                                );      
        NewExpensePageHelper.RequestBase expenseMerchantRecordResult = (NewExpensePageHelper.RequestBase)JSON.deserialize
                                                                        (
                                                                            LightningExpensePageController.createExpenseMerchantRecord('Merchant Name', 'Meal'),    
                                                                            NewExpensePageHelper.RequestBase.class
                                                                        );
        Test.stopTest(); 
        
        List<Expense_Item__c> expenseItemList = [SELECT Id FROM Expense_Item__c];       
        System.assertEquals(0, expenseItemList.size());
        System.assertEquals(false, expenseRecordResult.isSuccess);
        System.assertEquals(false, expenseMerchantRecordResult.isSuccess);
    }  
}