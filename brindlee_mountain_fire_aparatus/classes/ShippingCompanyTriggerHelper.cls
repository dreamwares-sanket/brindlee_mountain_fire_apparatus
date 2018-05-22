/*
            Name            :      ShippingCompanyTriggerHelper
            Developer       :      Ranu Agarwal (iBirds Services)
            Date            :      21th April, 2015
            Description     :      This class is used to Auto Set PO Shipping Company to Default PO Shipping Company Account.
*/
public class ShippingCompanyTriggerHelper{
    
    public void autoShipping(List<AcctSeedERP__Purchase_Order__c> purchaseOrderList){
        
        List<Account> accList = [select id from account where Default_PO_Shipping_Vendor__c = true limit 1];
        if(accList.size()>0){
            Id accId = accList.get(0).id;
            for(AcctSeedERP__Purchase_Order__c  purOrder : purchaseOrderList){
                purOrder.AcctSeedERP__Shipping_Company__c = accId;
            }
        }
    }
}