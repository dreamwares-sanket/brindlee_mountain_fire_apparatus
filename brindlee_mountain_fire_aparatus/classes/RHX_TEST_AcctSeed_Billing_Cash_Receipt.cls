@isTest(SeeAllData=true)
public class RHX_TEST_AcctSeed_Billing_Cash_Receipt {
  static testMethod void RHX_Testmethod() {
        List<sObject> sourceList = [SELECT Id 
      FROM AcctSeed__Billing_Cash_Receipt__c Where Account_Period_Status__c = 'Open' LIMIT 1];
        if(sourceList.size() == 0) {
            sourceList.add(
                    new AcctSeed__Billing_Cash_Receipt__c()
            );
        }
      Database.upsert(sourceList);
    }
}