@isTest(SeeAllData=true)
public class RHX_TEST_Task_Time_Entry {
    static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
            FROM Task_Time_Entry__c WHERE Name = 'asdfas2342qfafafasdf22' LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Task_Time_Entry__c(Internal_Task__c = '123')
            );
        }
        Database.upsert(sourceList);
    }
}