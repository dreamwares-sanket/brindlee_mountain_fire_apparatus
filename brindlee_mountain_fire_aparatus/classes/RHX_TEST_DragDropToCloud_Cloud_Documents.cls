@isTest(SeeAllData=true)
public class RHX_TEST_DragDropToCloud_Cloud_Documents {
	static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
			FROM DragDropToCloud__Cloud_Documents__c LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new DragDropToCloud__Cloud_Documents__c()
            );
        }
    	rh2.ParentUtil.UpsertRollupTestRecords( sourceList );
    }
}