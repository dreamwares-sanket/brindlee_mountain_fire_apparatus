/**
 * @Purpose: Test class for DealerFTFInquiryTrigger
 */
@isTest
public class DealerFTFInquiryTriggerTest {
    @testSetup
    public static void initData(){
		
        // insert Account
        Account account = new Account();
        account.Name = 'Test';
        
        insert account;
        
        // insert Contact
        Contact contact = new Contact();
        contact.LastName = 'Test';
        contact.AccountId = account.Id;
        contact.Email = 'test@test.com';
        
        insert contact;
        
        // insert Dealer_FTF_Account__c
        Dealer_FTF_Account__c dealarAccount = new Dealer_FTF_Account__c();
        dealarAccount.Dealer_Email__c = 'test@test.com';
        dealarAccount.Dealer_Language_Code__c = 'en';
        dealarAccount.Dealer_Contact__c = contact.Id;
        
        insert dealarAccount;
    }
    
    /**
     * Test DealerFTFInquiryTrigger functionality on insert event
     */
    public static testMethod void testDealerFTFInquiryTriggerOnInsert(){
    	
        Dealer_FTF_Account__c dealarAccount = [SELECT Id, Name
                                               FROM Dealer_FTF_Account__c
                                               LIMIT 1];
        Contact contact = [SELECT Id, Name
                           FROM Contact
                           LIMIT 1];
        
    	List<Dealer_FTF_Inquiry__c> inquiryList = new List<Dealer_FTF_Inquiry__c>();
        for(Integer index = 0; index < 100; index++){
        	
            Dealer_FTF_Inquiry__c inquiry = new Dealer_FTF_Inquiry__c();
            inquiry.Dealer_FTF_Account__c = dealarAccount.Id;
            inquiry.Dealer_Contact_Email__c = 'test@test.com';
            inquiry.Inquirer__c = contact.Id;
            
            inquiryList.add(inquiry);
        }
        
        Test.startTest();
        
        insert inquiryList;
        Test.stopTest();
    }
}