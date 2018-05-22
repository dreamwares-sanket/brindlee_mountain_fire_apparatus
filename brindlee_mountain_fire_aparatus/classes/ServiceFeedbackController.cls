/**
@ Purpose : 1. Controls the visualforce page --> ServiceFeedback.
            2. to create the Service Surveys
@createdBy   - Dreamwares
*/
public class ServiceFeedbackController {
    
    public Service_Surveys__c RecordServiceSurveys { get; set; }
    
    public String strView { get; set; }
    
    public ServiceFeedbackController(){
        
        Id opportunityId = ApexPages.currentPage().getParameters().get( 'Id' );
        
        if( opportunityId != NULL ){    
            strView = 'ServiceFeedBackDetail';
            RecordServiceSurveys = new Service_Surveys__c();
            RecordServiceSurveys.Service_Opportunity__c = opportunityId;
        }else{
            strView = 'CreateSuccess';
            displayPageMessage( 'Error', 'Oops! Something went wrong.' ); 
        }
    }
    
    public void createServiceSurveysRecord(){
        
        Id opportunityId = ApexPages.currentPage().getParameters().get( 'Id' );
        if( opportunityId != NULL ){
            try{
                System.debug('RecordServiceSurveys ::  ' + RecordServiceSurveys);
                insert RecordServiceSurveys;
                strView = 'CreateSuccess';
                displayPageMessage( 'Confirm', 'Thanks for your feedback.' );
            }catch( Exception e){
                System.debug(' Exception : '+ e.getMessage());
                displayPageMessage( 'Error', e.getMessage() );
            }
            
        }else{
            displayPageMessage( 'Error', 'Oops! Something went wrong.' ); 
        }
    }
    
    public void displayPageMessage( String strMessageType, String strMessage ) {
        
        ApexPages.Message pageMessage;
        if( String.isNotBlank( strMessageType ) && String.isNotBlank( strMessage ) ) {
            
            if( strMessageType == 'Confirm' ) {
                pageMessage = new ApexPages.Message( ApexPages.Severity.Confirm, strMessage );
            }
            else if( strMessageType == 'Error' ) {
                pageMessage = new ApexPages.Message( ApexPages.Severity.Error, strMessage );
            }
            else if( strMessageType == 'Warning' ) {
                pageMessage = new ApexPages.Message( ApexPages.Severity.Warning, strMessage );
            }
            else {
                pageMessage = new ApexPages.Message( ApexPages.Severity.Info, strMessage );
            }
            ApexPages.addMessage( pageMessage );
        }
    }
}