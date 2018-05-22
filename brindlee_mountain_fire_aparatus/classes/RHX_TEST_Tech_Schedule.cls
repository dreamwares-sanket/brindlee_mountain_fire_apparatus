@isTest(SeeAllData=true)
public class RHX_TEST_Tech_Schedule {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM Tech_Schedule__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new Tech_Schedule__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}