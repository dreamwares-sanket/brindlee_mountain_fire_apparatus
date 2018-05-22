/**
 * @Description  : Batch class to Aggregate Truck ID's as per Dealer FTF Criteria's related to Dealer FTF Account and 
                   Populate Truck ID's in the Dealer FTF Account Object field (Dealer_Truck_Details__c).
 * @Created Date : 14-5-2017
 * @Authors      : Dreamwares
 */
 public class DealerAccountCategoryCountBatch implements Database.Batchable<sObject>, Schedulable {
    
        
 
        
   
    public void execute(SchedulableContext SC) {
        DealerAccountCategoryCountBatch  updateAccountCategoery = new DealerAccountCategoryCountBatch();
        Database.executebatch(updateAccountCategoery , 1);
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
                
        String FTF_AccountQuery = 'SELECT Id, Name, Dealer__c, Dealer_Truck_Details__c, Display_Truck_Pricing__c, '
                                   + '(SELECT Id, Truck__c FROM Dealer_FTF_Suppressed_Trucks__r) '                                     
                                   +  ' FROM Dealer_FTF_Account__c';
        
        return Database.getQueryLocator(FTF_AccountQuery);
    }

    public void execute(Database.BatchableContext BC, List<Dealer_FTF_Account__c> FTF_Accounts) {       
        
        
        if ( FTF_Accounts!= null && !FTF_Accounts.isEmpty() ){
            
            DealerAccountCategoryCountBatchHelper.UpdateCategoryForEachAccount(FTF_Accounts[0]);
        }
    }
    
    
    
    public void finish(Database.BatchableContext BC) {
        
        
    }
}