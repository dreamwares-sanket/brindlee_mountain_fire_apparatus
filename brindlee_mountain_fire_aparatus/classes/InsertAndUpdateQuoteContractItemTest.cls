@isTest
public class InsertAndUpdateQuoteContractItemTest{
    @isTest
    public static void myUnitTest(){
        // insert Account 
        Account acc = new Account(Name='testAccount');
        //insert acc;
        // insert opportunity
        Opportunity opp = new Opportunity(Name = 'TestOpportunity' , AccountId = acc.id, CloseDate = system.Today(), StageName = 'Hot - sales');
        insert opp;
        // insert Quote
        Quote qu1 = new Quote(Name = 'TestQuote', OpportunityId = opp.id);
        insert qu1;
        // insert contract item
        Contract_Item__c contract = new Contract_Item__c(Name = 'TestContract' , Opportunity__c = opp.id, Description__c = 'test description', Amount__c = 500.00);
        insert contract;

        // update contract item
        contract.Description__c = 'Test Description123';
        contract.Amount__c = 600.00;
        update contract;
    }
}