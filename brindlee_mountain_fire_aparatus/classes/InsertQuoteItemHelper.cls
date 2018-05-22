public class InsertQuoteItemHelper{

    // Function to insert Quote Contract Item
    public static void insertQuoteContractItem(Map<String, String> oppQuote, Map<String, List<Contract_Item__c>> oppContractItem){
        List<Quote_Contract_Item__c> quoteContractToInsert = new List<Quote_Contract_Item__c>();
        if(oppContractItem.size()>0 && oppQuote.size()>0){
            for(String oppId : oppContractItem.keySet()){
                for(Contract_Item__c conItem : oppContractItem.get(oppId)){
                    Quote_Contract_Item__c quoteContractItem = new Quote_Contract_Item__c();
                    quoteContractItem.Quote__c = oppQuote.get(oppId);
                    quoteContractItem.Contract_Item__c = conItem.id;
                    quoteContractItem.Description__c = conItem.Description__c;
                    quoteContractItem.Quote_Amount__c = conItem.Amount__c;
                    quoteContractToInsert.add(quoteContractItem);
                }
            }
        }
        system.debug('#### QuoteItemList'+quoteContractToInsert);
        if(quoteContractToInsert.size()>0){
            system.debug('#### QuoteItemList'+quoteContractToInsert);
            insert quoteContractToInsert;
        }
    }
}