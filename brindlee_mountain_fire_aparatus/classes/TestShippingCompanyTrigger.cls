/*
            Name            :      TestShippingCompanyTrigger
            Developer       :      Ranu Agarwal (iBirds Services)
            Date            :      21th April, 2015
            Description     :      This class is used to test ShippingCompanyTrigger trigger.
*/
@isTest
public class TestShippingCompanyTrigger{

    @isTest
    public static void TestShippingCompany(){
        Account acc = new Account(name = 'Test Account', Default_PO_Shipping_Vendor__c = true);
        insert acc;
        AcctSeed__Billing_Format__c pdfObj = new AcctSeed__Billing_Format__c(Name = 'Test Pdf', AcctSeed__Type__c = 'Purchase Order', 
                                                                          AcctSeed__Visualforce_PDF_Page__c = 'PurchaseOrderPDF', AcctSeed__Default_Email_Template__c = 'Purchase_Order_Email_Template');
        insert pdfObj;  
        AcctSeedERP__Purchase_Order__c purOrder = new AcctSeedERP__Purchase_Order__c(AcctSeedERP__Purchase_Order_Format__c = pdfObj.id, AcctSeedERP__Order_Date__c = Date.toDay());
        insert purOrder;
        
        Account acc2 = new Account(name = 'Test Account2', Default_PO_Shipping_Vendor__c = false);
        insert acc2;
        purOrder.AcctSeedERP__Shipping_Company__c = acc2.id;
        update purOrder;
        purOrder.AcctSeedERP__Shipping_Company__c = null;
        update purOrder;
    }
}