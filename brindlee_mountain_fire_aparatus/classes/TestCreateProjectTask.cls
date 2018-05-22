@isTest
public class TestCreateProjectTask{
    
     @isTest
    private static void TestController(){
        
        AcctSeed__Ledger__c al = new AcctSeed__Ledger__c();
        al.Name = 'Test Ledger';
        al.AcctSeed__Type__c = 'Transactional';
        insert al;
        
        AcctSeed__GL_Account__c ag = new AcctSeed__GL_Account__c();
        ag.Name = 'Revenue';
        ag.AcctSeed__Type__c = 'Expense';
        ag.AcctSeed__Bank__c = true;
        ag.AcctSeed__Active__c = true;
        insert ag;
        
        AcctSeed__Billing_Format__c abf  = new AcctSeed__Billing_Format__c();
        abf.name = 'Billing';
        abf.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        abf.AcctSeed__Type__c = 'Billing';
        abf.AcctSeed__Visualforce_PDF_Page__c = 'ProjectBillingPDF';
        insert abf;
        
        AcctSeed__Accounting_Settings__c aas = new AcctSeed__Accounting_Settings__c();
        aas.AcctSeed__Default_Project_Task_Labor_GL_Account__c = ag.id;
        aas.AcctSeed__Labor_GL_Account__c = ag.id;
        aas.AcctSeed__Default_Ledger__c = al.id;
        aas.AcctSeed__Current_Year_Earnings_GL_Account__c = ag.id;
        aas.AcctSeed__Default_Bank_Account__c = ag.id;
        aas.AcctSeed__Retained_Earnings_GL_Account__c = ag.id;
        aas.AcctSeed__Revenue_GL_Account__c = ag.id;
        aas.AcctSeed__AR_Control_GL_Account__c = ag.id;
        aas.AcctSeed__Unapplied_Cash_GL_Account__c = ag.id;
        aas.AcctSeed__AP_Control_GL_Account__c = ag.id;
        aas.AcctSeed__Default_Billing_Format__c = abf.id;
        aas.AcctSeed__Billing_Activity_Statement_Format__c = abf.id;
        aas.AcctSeed__Billing_Outstanding_Statement_Format__c = abf.id;
        
        insert aas;
        
        Account Acc = new Account();
        Acc.name = 'Test Account';
        //insert Acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Testing';
        opp.AccountID = Acc.id;
        opp.StageName = 'Warm - Sales';
        opp.CloseDate = System.Today();
        insert opp; 
        
        Contract_Item__c ci = new Contract_Item__c();
        ci.Name = 'Item1';
        ci.Description__c = 'Description Test';
        ci.Opportunity__c = opp.id;
        insert ci;
        
        AcctSeed__Project__c Pro = new AcctSeed__Project__c();
        Pro.name = 'Project 1';
        Pro.AcctSeed__Revenue_Recognition_Method__c = 'Cost Only';
        Pro.AcctSeed__Status__c = 'Active';
        Pro.AcctSeed__Opportunity__c = opp.id;
        insert Pro;
        Pro.Name = 'Pro 2';
        update Pro;
        AcctSeed__Project_Task__c apt = new AcctSeed__Project_Task__c();
        apt.Contract_Item__c = ci.id;
        apt.AcctSeed__Project__c = pro.id;
        insert apt;
        Pro.Name = 'Pro 3';
        update Pro;
        
    }
}