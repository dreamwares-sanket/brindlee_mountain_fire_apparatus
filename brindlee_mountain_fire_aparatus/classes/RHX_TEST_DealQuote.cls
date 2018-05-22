@isTest(SeeAllData=true)
public class RHX_TEST_DealQuote {
    static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
            FROM DealQuote__c ORDER BY NAME Asc LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new DealQuote__c()
            );
        }
        Database.upsert(sourceList);
    }
}