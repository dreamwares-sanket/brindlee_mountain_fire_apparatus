public class InsertAndUpdateQuoteContractItemHelper{

    // Function to insert Quote Contract Item
    public static void insertQuoteContractItem(Map<String, Contract_Item__c> oppContractItem, Map<String, String> oppQuote){
        List<Quote_Contract_Item__c> quoteContractToInsert = new List<Quote_Contract_Item__c>();
        if(oppContractItem.size()>0 && oppQuote.size()>0){
            for(String oppId : oppContractItem.keySet()){
                Quote_Contract_Item__c quoteContractItem = new Quote_Contract_Item__c();
                quoteContractItem.Quote__c = oppQuote.get(oppId);
                quoteContractItem.Contract_Item__c = oppContractItem.get(oppId).id;
                quoteContractItem.Description__c = oppContractItem.get(oppId).Description__c;
                quoteContractItem.Quote_Amount__c = oppContractItem.get(oppId).Amount__c;
                quoteContractToInsert.add(quoteContractItem);
            }
        }
        system.debug('#### QuoteItemList'+quoteContractToInsert);
        if(quoteContractToInsert.size()>0){
            system.debug('#### QuoteItemList'+quoteContractToInsert);
            insert quoteContractToInsert;
        }
    }
    
    // Function to update the Quote Contract Item
    public static void updateQuoteContractItem(Map<String, Contract_Item__c> oppContractItem, Map<String, String> oppQuote){
        List<Quote_Contract_Item__c> quoteContractToUpdate = new List<Quote_Contract_Item__c>();
        List<Quote_Contract_Item__c> tempList = [select id, Contract_Item__c, Quote__c, Description__c, Quote_Amount__c 
                                                 from Quote_Contract_Item__c
                                                 where Quote__r.opportunityId in : oppQuote.keyset()];
        if(oppContractItem.size()>0 && oppQuote.size()>0){
            for(String oppId : oppContractItem.keySet()){
                for(Quote_Contract_Item__c qc : tempList){
                    if(qc.Contract_Item__c == oppContractItem.get(oppId).id && qc.Quote__c == oppQuote.get(oppId)){
                        qc.Description__c = oppContractItem.get(oppId).Description__c;
                        qc.Quote_Amount__c = oppContractItem.get(oppId).Amount__c;
                        quoteContractToUpdate.add(qc);
                    }   
                }
            }
        }
        system.debug('#### QuoteItemList'+quoteContractToUpdate);
        if(quoteContractToUpdate.size()>0){
            system.debug('#### QuoteItemList'+quoteContractToUpdate);
            update quoteContractToUpdate;
        }
    }
    
}