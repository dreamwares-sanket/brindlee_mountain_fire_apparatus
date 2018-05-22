/*
        Name            :    CreateBillingController
        Author          :    
        Date            :    
        Description     :    this class use to controlling to the CreateBilling page it is creating Billing and Billing Line item in Bulk
*/

public class CreateBillingController{
    private string projectId;
    private AcctSeed__Project__c projectRecord;
    private id billId;
    private date dtToday;
    // inIt method calling from page when page id load and this method controlles all the methods
    public pageReference inIt(){
        projectRecord = new AcctSeed__Project__c();   
        projectId = ApexPages.currentpage().getParameters().get('id');
        dtToday = date.Today();
        dtToday = date.parse(dtToday.format());
        
        if(projectId!=null&&projectId!=''){
           //projectRecord  = [select id,GL_Revenue_for_Parts__c,GL_Revenue_for_Labor__c,GL_Revenue_for_Sublet_Parts__c,GL_Expense_for_Parts__c,GL_Expense_for_Sublet_Parts__c,BS_WIP_Account__c,AcctSeedERP__Manufactured_Product__c,AcctSeed__Account__c,AcctSeed__Opportunity__c from AcctSeed__Project__c where id=:projectId];
           projectRecord  = [select id,Labor_Product__c,GL_Revenue_for_Parts__c,GL_Revenue_for_Labor__c,GL_Revenue_for_Sublet_Parts__c,GL_Expense_for_Parts__c,GL_Expense_for_Sublet_Parts__c,BS_WIP_Account__c,AcctSeedERP__Manufactured_Product__c,AcctSeed__Account__c,AcctSeed__Opportunity__c from AcctSeed__Project__c where id=:projectId];
           
           if(projectRecord.AcctSeed__Account__c!=null){
               CreateBilling();
               return new pageReference('/' + billId).setRedirect(true);
            }
            return new pageReference('/' + projectId).setRedirect(true);
                                
        }else{
           return null;
        }
    }
    
    private void createBilling(){
        AcctSeed__Billing__c billRecord = new AcctSeed__Billing__c(AcctSeed__Customer__c=projectRecord.AcctSeed__Account__c,AcctSeed__Opportunity__c=projectRecord.AcctSeed__Opportunity__c,AcctSeed__Date__c = dtToday,AcctSeed__Status__c='In Process',project__c=projectRecord.id);
        insert billRecord;
        billId = billRecord.id;
       //list<AcctSeed__Project_Task__c> prjTaskList = [select id,AcctSeed__Project__c,Actual_Labor_Rate__c,Billable_Hours__c,Description__c from AcctSeed__Project_Task__c where AcctSeed__Project__c=:projectRecord.id];
       list<AcctSeed__Project_Task__c> prjTaskList = [select id,Labor_Cost_Rate__c,AcctSeed__Project__c,Actual_Labor_Rate__c,Billable_Hours__c,Description__c from AcctSeed__Project_Task__c where AcctSeed__Project__c=:projectRecord.id];
       list<AcctSeedERP__Material__c> prjMaterialList = [select id,AcctSeedERP__Project__c,AcctSeedERP__Project_Task__c,AcctSeedERP__Quantity_Allocated__c,Unit_Price__c,AcctSeedERP__Product__c,AcctSeedERP__Comment__c,Is_Sublet_Part__c,Unit_Cost__c from AcctSeedERP__Material__c where AcctSeedERP__Project__c=:projectRecord.id];
       if(prjTaskList.size()>0)
           createlBillLinefromPrjTask(prjTaskList);
       if(prjMaterialList.size()>0)
           createBillLineFromMaterial(prjMaterialList);
      
    }
    
    // this method creating Billing Line Item for each Project task record
    private void createlBillLinefromPrjTask(list<AcctSeed__Project_Task__c> prjTaskList){
        list<AcctSeed__Billing_Line__c> accBillingLineList = new list<AcctSeed__Billing_Line__c>();
        date dtToday = date.Today();
        dtToday = date.parse(dtToday.format());
       for(AcctSeed__Project_Task__c accPrjTaskRecord:prjTaskList){
         //AcctSeed__Billing_Line__c accBillLine = new AcctSeed__Billing_Line__c(AcctSeed__Billing__c=billId,AcctSeed__Project__c = accPrjTaskRecord.AcctSeed__Project__c,AcctSeed__Project_Task__c = accPrjTaskRecord.id, AcctSeed__Rate__c = accPrjTaskRecord.Actual_Labor_Rate__c,AcctSeed__List_Price__c = accPrjTaskRecord.Actual_Labor_Rate__c,AcctSeed__Product_Unit_Cost__c = accPrjTaskRecord.Actual_Labor_Rate__c,AcctSeed__Hours_Units__c = accPrjTaskRecord.Billable_Hours__c,AcctSeed__Revenue_GL_Account__c=projectRecord.GL_Revenue_for_Labor__c,AcctSeed__Expense_GL_Account__c = projectRecord.GL_Revenue_for_Labor__c,AcctSeed__Inventory_GL_Account__c = projectRecord.GL_Revenue_for_Labor__c,AcctSeed__Product__c = projectRecord.AcctSeedERP__Manufactured_Product__c,AcctSeed__Date__c=dtToday,AcctSeed__Comment__c = accPrjTaskRecord.Description__c);
         //AcctSeed__Billing_Line__c accBillLine = new AcctSeed__Billing_Line__c(AcctSeed__Billing__c=billId,AcctSeed__Project__c = accPrjTaskRecord.AcctSeed__Project__c,AcctSeed__Project_Task__c = accPrjTaskRecord.id, AcctSeed__Rate__c = accPrjTaskRecord.Actual_Labor_Rate__c,AcctSeed__List_Price__c = accPrjTaskRecord.Actual_Labor_Rate__c,AcctSeed__Hours_Units__c = accPrjTaskRecord.Billable_Hours__c,AcctSeed__Revenue_GL_Account__c=projectRecord.GL_Revenue_for_Labor__c,AcctSeed__Date__c=dtToday,AcctSeed__Comment__c = accPrjTaskRecord.Description__c);
         AcctSeed__Billing_Line__c accBillLine = new AcctSeed__Billing_Line__c(AcctSeed__Billing__c=billId,AcctSeed__Project__c = accPrjTaskRecord.AcctSeed__Project__c,AcctSeed__Project_Task__c = accPrjTaskRecord.id, AcctSeed__Rate__c = accPrjTaskRecord.Actual_Labor_Rate__c,AcctSeed__List_Price__c = accPrjTaskRecord.Actual_Labor_Rate__c, Labor_Unit_Cost__c = accPrjTaskRecord.Labor_Cost_Rate__c, AcctSeed__Product__c=projectRecord.Labor_Product__c, AcctSeed__Hours_Units__c = accPrjTaskRecord.Billable_Hours__c,AcctSeed__Revenue_GL_Account__c=projectRecord.GL_Revenue_for_Labor__c,AcctSeed__Date__c=dtToday,AcctSeed__Comment__c = accPrjTaskRecord.Description__c);
         accBillingLineList.add(accBillLine); 
       }
       if(accBillingLineList.size()>0)
           insert accBillingLineList; 
    }
    
    // this method creating Billing Line Item for each Project material record 
    private void createBillLineFromMaterial(list<AcctSeedERP__Material__c> prjMaterialList){
        list<AcctSeed__Billing_Line__c> accBillingLineList = new list<AcctSeed__Billing_Line__c>();
        for(AcctSeedERP__Material__c prjMaterialRecord:prjMaterialList){
              id glAccountRevenueId;
              id glAccountExpenseId;
              if(prjMaterialRecord.Is_Sublet_Part__c){
                  glAccountRevenueId = projectRecord.GL_Revenue_for_Sublet_Parts__c;
                  glAccountExpenseId = projectRecord.GL_Expense_for_Sublet_Parts__c;
              }
              else{
                  glAccountRevenueId = projectRecord.GL_Revenue_for_Parts__c;  
                  glAccountExpenseId = projectRecord.GL_Expense_for_Parts__c;    
              }
              AcctSeed__Billing_Line__c accBillLine = new AcctSeed__Billing_Line__c(AcctSeed__Billing__c=billId,AcctSeed__Project__c = prjMaterialRecord.AcctSeedERP__Project__c,AcctSeed__Project_Task__c = prjMaterialRecord.AcctSeedERP__Project_Task__c, AcctSeed__Hours_Units__c = prjMaterialRecord.AcctSeedERP__Quantity_Allocated__c ,AcctSeed__Rate__c = prjMaterialRecord.Unit_Price__c,AcctSeed__List_Price__c = prjMaterialRecord.Unit_Price__c,AcctSeed__Product_Unit_Cost__c = prjMaterialRecord.Unit_Cost__c,AcctSeed__Product__c = prjMaterialRecord.AcctSeedERP__Product__c,AcctSeed__Date__c=dtToday,AcctSeed__Comment__c = prjMaterialRecord.AcctSeedERP__Comment__c,AcctSeed__Inventory_GL_Account__c = projectRecord.BS_WIP_Account__c,AcctSeed__Revenue_GL_Account__c=glAccountRevenueId,AcctSeed__Expense_GL_Account__c = glAccountExpenseId);
              accBillingLineList.add(accBillLine); 
         }
       if(accBillingLineList.size()>0)
           insert accBillingLineList;    
       
       }
       
       
}