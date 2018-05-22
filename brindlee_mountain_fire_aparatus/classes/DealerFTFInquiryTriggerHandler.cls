/**
 * @Purpose: Handler for DealerFTFInquiryTrigger
 */
public class DealerFTFInquiryTriggerHandler{
	
    /**
     * To send email on creation of inquiry
     */
    public static void sendEmailOnInquiryCreation(List<Dealer_FTF_Inquiry__c> inquiryList){
        System.debug('inquiryList :::'+inquiryList);
        if(inquiryList != null){
            Map<Id,Id> inquiryToInquirerIdMap = new Map<Id,Id>();
            Map<Id,String> inquiryToContactEmailMap = new Map<Id,String>();
            
            for(Dealer_FTF_Inquiry__c inquiry :inquiryList){
                if(inquiry.Inquirer__c != null){
                    
                    inquiryToInquirerIdMap.put(inquiry.Id, inquiry.Inquirer__c);
                    
                    if(String.isNotBlank(inquiry.Dealer_Contact_Email__c)){
                        inquiryToContactEmailMap.put(inquiry.Id, inquiry.Dealer_Contact_Email__c);
                    }
                }
            }
            if(!inquiryToInquirerIdMap.isEmpty()){
               system.debug('inquiryToContactEmailMap ::::'+inquiryToContactEmailMap); 
               sendEmails(inquiryToInquirerIdMap, inquiryToContactEmailMap);
            }
        }    
    }
    
    /**
     * To send email
     */
    private static void sendEmails(Map<Id,Id> inquiryToInquirerIdMap , Map<Id,String> inquiryToContactEmailMap){
        
        if(inquiryToInquirerIdMap != null && !inquiryToInquirerIdMap.isEmpty()){
			EmailTemplate emailemplate = getTemplateId();
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail;
            
            if(emailemplate != null){
                for(id inquiryId :inquiryToInquirerIdMap.keySet()){
                	mail = new Messaging.SingleEmailMessage();             
                    mail.setWhatId(inquiryId);                           			
                    mail.setTemplateId(emailemplate.Id);
                    mail.setTargetObjectId(inquiryToInquirerIdMap.get(inquiryId));
                    
                    if(inquiryToContactEmailMap != null && !inquiryToContactEmailMap.isEmpty() 
                       && inquiryToContactEmailMap.containsKey(inquiryId)){
                        
                           mail.setCcAddresses(new String[]{inquiryToContactEmailMap.get(inquiryId)});
                    }
                    mail.setBccAddresses(new String[]{'salesforce@firetruckmall.com'});
                    mail.setSaveAsActivity(false);
                    mailList.add(mail);
                }
                
                if(!mailList.isEmpty()){
                    try{
                        Messaging.sendEmail(mailList);
                        system.debug('Mail successfully sent');
                    }
                    catch(Exception e) {
                        system.debug('Failed to send mail ::'+e.getMessage());
                    }
                }
            }
        }
    }
    
    /**
     * To get email template
     * */
    private static EmailTemplate getTemplateId(){
    
        try {
            return [SELECT id, name, HTMLValue, Body 
                    FROM EmailTemplate 
                    WHERE developername = : 'DealerFTFInquiryCreation'
                    LIMIT 1];
        
        }catch (Exception exp){
            System.debug('Exception :::'+exp.getMessage()); 
        }
        return null;
    }
}