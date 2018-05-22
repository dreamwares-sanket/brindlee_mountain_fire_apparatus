/*
        Name            :    TestCreateBillingController
        Author          :    
        Date            :    
        Description     :    this test class use to testing to the CreateBillingController
*/

@isTest
public class TestCreateBillingController{   
     static testmethod void unittest(){
        Id rcTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Service - Heavy Refurb').getRecordTypeId();
        Id rcTypeProdId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Trucks').getRecordTypeId();
        Id rcTypePrjId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByName().get('Work Order').getRecordTypeId();
         
          // insert Ledger testing data
        AcctSeed__Ledger__c al = new AcctSeed__Ledger__c();
        al.Name = 'Test Ledger';
        al.AcctSeed__Type__c = 'Transactional';
        insert al;
        
        // insert GL_Account testing data
        AcctSeed__GL_Account__c ag = new AcctSeed__GL_Account__c();
        ag.Name = 'Revenue';
        ag.AcctSeed__Type__c = 'Expense';
        ag.AcctSeed__Bank__c = true;
        ag.AcctSeed__Active__c = true;
        insert ag;
        
        // insert Billing_Format testing data
        AcctSeed__Billing_Format__c abf  = new AcctSeed__Billing_Format__c();
        abf.name = 'Billing';
        abf.AcctSeed__Default_Email_Template__c = 'Activity_Statement_Email_Template';
        abf.AcctSeed__Type__c = 'Billing';
        abf.AcctSeed__Visualforce_PDF_Page__c = 'ProjectBillingPDF';
        insert abf;
        
        // insert Accounting_Settings testing data
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
        
        date dtToday = date.parse((date.today()).format());
            
        // insert Accounting_Period testing data
        AcctSeed__Accounting_Period__c accPeriod = new AcctSeed__Accounting_Period__c(Name = '2015-05',AcctSeed__Start_Date__c = dtToday,AcctSeed__End_Date__c = dtToday,AcctSeed__Status__c = 'Open'); 
        insert accPeriod;
        
        // insert Accounting_Period testing data
        Account Acc = new Account();
        Acc.name = 'Test Account';
        insert Acc;
        
        // insert Opportunity testing data
        Opportunity opp = new Opportunity();
        opp.recordTypeId = rcTypeId; 
        opp.Name = 'Testing';
        opp.AccountID = Acc.id;
        opp.StageName = 'Warm - Sales';
        opp.CloseDate = System.Today();
        insert opp; 
        
        // insert Opportunity 1 testing data
        Opportunity opp1 = new Opportunity();
        opp1.recordTypeId = rcTypeId; 
        opp1.Name = 'Testing';
        opp1.AccountID = Acc.id;
        opp1.StageName = 'Warm - Sales';
        opp1.CloseDate = System.Today();
        insert opp1;
        
        Product2 prd = new Product2(recordTypeId = rcTypeProdId,Family='Trucks',Stock_Number__c='01757',Name='01757'); 
        insert prd;
        // insert Project testing data
        AcctSeed__Project__c  accPrj = new AcctSeed__Project__c(recordtypeId=rcTypePrjId,Name='testProject',AcctSeed__Account__c=Acc.id,AcctSeed__Revenue_Recognition_Method__c='Cost Only',AcctSeed__Status__c='Active',Project_Labor_Bill_Rate__c=90,AcctSeed__Opportunity__c = opp.id,AcctSeedERP__Quantity_Ordered__c=1,AcctSeedERP__Manufactured_Product__c = prd.id, Labor_Product__C = prd.id);
        insert accPrj;
        
       // insert GL Account testing data
        AcctSeed__GL_Account__c glAccount = new AcctSeed__GL_Account__c();
        glAccount.AcctSeed__Type__c = 'Expense';
        glAccount.name = 'Testing Gl Account';
        glAccount.AcctSeed__Active__c = true;
        insert glAccount;
        
        
        // insert project task testing data
        AcctSeed__Project_Task__c task = new AcctSeed__Project_Task__c(AcctSeed__Project__c = accPrj.id);
        task.AcctSeed__Labor_GL_Account__c = glAccount.id;
        task.name = 'Test task';
        task.Description__c = 'Tesing Description for task';
        task.AcctSeed__Status__c = 'Active';
        
        insert task;
        
        AcctSeedERP__Material__c accMaterial = new AcctSeedERP__Material__c(AcctSeedERP__Project__c = accPrj.id,AcctSeedERP__Project_Task__c = task.id,AcctSeedERP__Product__c = prd.id,AcctSeedERP__Quantity_Per_Unit__c = 1);
        insert accMaterial; 
        
        CreateBillingController cBillCntrl = new CreateBillingController();
        ApexPages.currentpage().getParameters().put('id',accPrj.id);
        cBillCntrl.inIt();
        
         AcctSeed__Billing__c accBill = [select id,project__c from AcctSeed__Billing__c where Project__c =:accPrj.id limit 1];
         
         ////confirm expectation Values 
         system.assertNotEquals(accBill,null);
         system.assertEquals(accBill.project__c,accPrj.id);
         
        list<AcctSeed__Billing_Line__c> accBillLineList =  [select id from AcctSeed__Billing_Line__c where AcctSeed__Project__c =: accPrj.id];
        
        ////confirm expectation Values  
            system.assertEquals(accBillLineList.size(),2);
        
         
                                 
    }
}