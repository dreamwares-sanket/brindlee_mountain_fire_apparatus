/**
    Name           :    ContactAccountUpdateTriggerHelper
    Author         :
    Date           :    July 14, 2015
    Description    :    This class is used to auto populate fields on product object and called by ContactAccountUpdateTrigger.
**/
public class ContactAccountUpdateTriggerHelper{

    public void populateAccountContact(Set<String> productEmailSet, Set<String> accountNameSet,Set<String> stateNameSet,List<Product2>productList){
        Map<String, Contact> contactMap = new Map<String, Contact>();
        Map<String, Account> accountNameMap = new Map<String, Account>();
        
        //Fill contact map according to email ids
        for(Contact con : [select id, email, accountid from Contact where email IN : productEmailSet]){
            if(con.email != null)
                contactMap.put(con.email.tolowercase(), con);
        }
        //Fill accountNameMap according to Account name and billing state
        for(Account accnt: [select id, name, BillingState from Account where name IN : accountNameSet and BillingState IN : stateNameSet]){
            accountNameMap.put(accnt.name.tolowercase(), accnt);
        }
        system.debug('@@@@@@2 contactMap ' + contactMap);
        system.debug('@@@@@@2 accountNameMap ' + accountNameMap );
        //Auto Populate fields on product object
        for(Product2 product : productList){
            if(product.Seller_Contact_Email__c != null && contactMap.containsKey(product.Seller_Contact_Email__c.tolowercase())){
                system.debug('come in email part'+contactMap.get(product.Seller_Contact_Email__c.tolowercase()).id + '@@@ ' + contactMap.get(product.Seller_Contact_Email__c.tolowercase()).accountid);
                product.Seller_Contact__c = contactMap.get(product.Seller_Contact_Email__c.tolowercase()).id;
                product.Seller_Contact_Account__c = contactMap.get(product.Seller_Contact_Email__c.tolowercase()).accountid;
            }
            if(product.Sold_to_Customer__c != null && product.Sold_to_State__c!=null && accountNameMap.containsKey(product.Sold_to_Customer__c.tolowercase())){
                system.debug('come in next part ' + accountNameMap .get(product.Sold_to_Customer__c.tolowercase()).id);
                system.debug('@@@@@ state name '+  accountNameMap.get(product.Sold_to_Customer__c.tolowercase()).BillingState.tolowercase());
                if(product.Sold_to_State__c.tolowercase() == accountNameMap.get(product.Sold_to_Customer__c.tolowercase()).BillingState.tolowercase() ){
                    product.Sold_to_Customer_Account__c = accountNameMap .get(product.Sold_to_Customer__c.tolowercase()).id;    
                }   
            }
        }
    }
}