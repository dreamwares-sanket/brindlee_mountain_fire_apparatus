/**
@ Purpose : 1. test class for --> ServiceFeedbackController.
@createdBy   - Dreamwares
*/
@isTest
public class ServiceFeedbackControllerTest {

      @testSetup
    static void testSetupRecords() {
        Opportunity Opp = new Opportunity();
        Opp.Name = 'Test Opportiunity';
       // Opp.AccountId = acct.id;
       // Opp.Business_Line__c = 'Capital Markets';
       // Opp.Result_Reason__c = 'Amenities';
        Opp.CloseDate = System.today();
        Opp.StageName = 'Qualified';
        Opp.LeadSource = 'Web';
        Opp.Type = 'New Customer - New Business';
       // Opp.Product_Type_Interests__c = 'ActiveDisclosure';
        insert Opp;
        
    }
    static testmethod void testPositiveData(){
        Opportunity Opp = new Opportunity();
        Opp = [SELECT Id, Name, LeadSource FROM Opportunity LIMIT 1];
        System.assertEquals( Opp.LeadSource , 'Web');
      
        Test.setCurrentPageReference(new PageReference('Page.ServiceFeedback'));
        System.currentPageReference().getParameters().put('id', Opp.Id);
       
        ServiceFeedbackController contr = new ServiceFeedbackController();
        contr.strView = 'ServiceFeedBackDetail';
        contr.displayPageMessage( 'Error', 'Oops! Something went wrong.' );
        contr.createServiceSurveysRecord();
        contr.displayPageMessage( 'Warning', 'Something went wrong.' );
        
        Service_Surveys__c objService = [ SELECT Id, Service_Opportunity__c FROM Service_Surveys__c LIMIT 1 ];
        
        System.assertEquals( Opp.Id, objService.Service_Opportunity__c );
        //Recordobj.Overall_how_did_we_do__c = ''
    }
    static testmethod void testNegativeData(){      
       
        ServiceFeedbackController contr = new ServiceFeedbackController();
        contr.strView = 'ServiceFeedBackDetail';
        contr.displayPageMessage( 'Error', 'Oops! Something went wrong.' );
        contr.createServiceSurveysRecord();
        contr.displayPageMessage( 'Warning', 'Something went wrong.' );
        
        //Recordobj.Overall_how_did_we_do__c = ''
    }
}