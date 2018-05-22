public class DepositBillingFromOpportunity {
    public String recordId {get; set;}
    public DepositBillingFromOpportunity() {
    }
    
    public DepositBillingFromOpportunity(ApexPages.StandardController stdController) {
        
        System.debug('stdController ;;; ' + JSON.serialize(stdController.getRecord()));
        try{
            // get the Id of opportunity record from Standard controllers record.
            recordId = stdController.getRecord().Id;
        }
        catch (Exception exp){
            System.debug('Exception ::' + exp.getMessage() + ' at: ' + exp.getLineNumber());
        }
    }
    
    public void processBillingRecord() {
        try{
            if(String.isNotBlank(recordId)) {
                // get all required values from opportunity record.
                Opportunity opportunityRec = getOpportunityRecord(recordId);
                
                // create new billing record
                AcctSeed__Billing__c billingRec = createBillingRecord(opportunityRec);
                insert billingRec;
                
                // create new Billing Line Item
                AcctSeed__Billing_Line__c billingLine = createBillingLine(billingRec, opportunityRec);
                insert billingLine;
            }
        }
        catch (Exception exp){
            System.debug('Exception ::' + exp.getMessage() + ' at: ' + exp.getLineNumber());
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Oops something went wrong!'));
        }
        
    }
    
    public Opportunity getOpportunityRecord(String oppId){
        Opportunity opportunityRec;
        if(String.isNotBlank(oppId)){
            opportunityRec = [SELECT Id, Name, AccountId, Contact_at_Department__c, Product_Nickname__c, Deposit_Amount__c 
                              From Opportunity 
                              WHERE Id = :oppId];
        }
        return opportunityRec;
    }
    
    public AcctSeed__Billing_Line__c createBillingLine(AcctSeed__Billing__c billingRec, Opportunity opportunityRec){
        return new AcctSeed__Billing_Line__c(AcctSeed__Billing__c = billingRec.Id, 
                                             AcctSeed__Product__c = opportunityRec.Product_Nickname__c, 
                                             AcctSeed__Rate__c = opportunityRec.Deposit_Amount__c);
    }
    
    public AcctSeed__Billing__c createBillingRecord(Opportunity opportunityRec){
        
        PDF_Formats__c pdfFormat = PDF_Formats__c.getValues('DepositPDFId'); 
        
        return new AcctSeed__Billing__c(AcctSeed__Customer__c = opportunityRec.AccountId, 
                                        AcctSeed__Date__c = System.today(), 
                                        AcctSeed__Billing_Contact__c = opportunityRec.Contact_at_Department__c,
                                        AcctSeed__Billing_Terms_Name__c = 'Due upon Reciept',
                                        AcctSeed__Status__c = 'In Process',
                                        AcctSeed__Opportunity__c = opportunityRec.Id, 
                                        AcctSeed__Billing_Format__c = pdfFormat.PDF_Format_recordId__c); 
    }
}