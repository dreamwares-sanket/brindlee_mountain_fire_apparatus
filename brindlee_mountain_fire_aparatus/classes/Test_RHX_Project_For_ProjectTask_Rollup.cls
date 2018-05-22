@isTest(SeeAllData=true)
public class Test_RHX_Project_For_ProjectTask_Rollup {
static testMethod void AcctSeed_Project() {
        
        List<sObject> sourceList = [SELECT Id
FROM AcctSeed__Project__c WHERE Name = 'asdfas2342qfafafasdf22'
                          LIMIT 1 ];

        if(sourceList.size() == 0) {
            sourceList.add(
                  new AcctSeed__Project__c()
                );
        }
  Database.upsert(sourceList);
    Database.delete(sourceList);
    
}    
}