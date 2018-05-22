/**
 * 
 * @Created Date : 13-7-2017
 * @Authors      : Dreamwares
 */
 global class dealerWeeklyNotifierBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    
    public void execute(SchedulableContext SC) {
        Integer batchSize  = limits.getLimitCallouts();   
        dealerWeeklyNotifierBatch notifyDealer = new dealerWeeklyNotifierBatch();
        Database.executebatch(notifyDealer, batchSize );
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String FTF_AccountQuery = 'SELECT Id, Dealer_Email__c '+
                                  'FROM Dealer_FTF_Account__c';
        
        return Database.getQueryLocator( FTF_AccountQuery );
    }

    global void execute(Database.BatchableContext BC, List<Dealer_FTF_Account__c> FTF_Accounts) {
    
        List<Messaging.SingleEmailMessage> singleEMessageList = new List<Messaging.SingleEmailMessage>();
        for(Dealer_FTF_Account__c FTFAcc : FTF_Accounts) {
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            //mail.setCcAddresses(ccAddresses);
            //mail.setReplyTo('roshan@dreamwares.com');
            mail.setSenderDisplayName('Support');
            mail.setSubject('Dealership Notification');
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setToAddresses(new String[] { FTFAcc.Dealer_Email__c } );//add email id
            mail.setPlainTextBody('Please Find Attachment.');
            //mail.setTargetObjectId(temp.Id);
            //mail.setWhatId(temp.Id);
            
            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            
            PageReference pdfPage = Page.dealerTrucksPDF;
            //PageReference pdfPage = new PageReference('/apex/dealerTrucksPDF?id='+FTFAcc.id);
            pdfPage.getParameters().put('id', FTFAcc.id);
            //Blob pdf = pdfPage.getContentAsPdf();
            pdfPage.setRedirect(true);
            Blob pdf = (Test.isRunningTest() ? Blob.valueOf('TEST') : pdfPage.getContent());            
            
            Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
            efa.setFileName('AllottedTruckList.pdf');
            efa.setBody(pdf);            
            fileAttachments.add(efa);            
            mail.setFileAttachments( fileAttachments );
            
            singleEMessageList.add ( mail );            
        }
        if( !singleEMessageList.isEmpty() ) {
            System.debug('singleEMessageList  : ' + singleEMessageList);
            // Sends the email
            Messaging.SendEmailResult [] r = Messaging.sendEmail( singleEMessageList );
            //System.debug('r : ' + r);
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        
        /*if(!SFUtilityResult.isSuccess){
        
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setSubject('Error while updating Account Total Amounts');
    
            String mailBody = 'Hi '+UserInfo.getName()+'<br/>' +
                              'Error occured while running <bold>UpdateAmountsOnAccountBatch<bold><br/>'+
                              'due to : <br/>'+ SFUtilityResult.displayMessage +'<br/>'+
                              'Please contact your System Admin.';
    
            mail.setHtmlBody(mailBody);
            mail.setTargetObjectId(UserInfo.getUserId());
    
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }*/
    }
}