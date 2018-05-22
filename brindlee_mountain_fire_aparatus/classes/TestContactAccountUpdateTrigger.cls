/**
    Name           :    TestContactAccountUpdateTrigger
    Author         :
    Date           :    July 14, 2015
    Description    :    This test class is used to test ContactAccountUpdateTrigger.
**/
@isTest
public class TestContactAccountUpdateTrigger{
    
    @isTest
    public static void testTrigger(){
        
        Account acc = new Account(name = 'Test Account',BillingState = 'State1');
        insert acc;
        Contact con = new Contact(firstname = 'Test',
                                  lastname = 'Contact',
                                  email = 'test@gmail.com',
                                  accountid = acc.id);
        insert con;                                  
        product2 product = new product2(Seller_Contact_Email__c='test@gmail.com',
                                        Sold_to_Customer__c='Test Account',
                                        name='abc',
                                        Stock_Number__c='9', Sold_to_State__c = 'State1' );
        insert product;
        system.debug('@@@@@ product' + product);
        system.assertEquals([select id, Seller_Contact__c from product2 where id =: product.id].Seller_Contact__c, con.id);
        system.assertEquals([select id, Seller_Contact_Account__c  from product2 where id =: product.id].Seller_Contact_Account__c , con.accountid);
        system.assertEquals([select id, Sold_to_Customer_Account__c  from product2 where id =: product.id].Sold_to_Customer_Account__c , con.accountid);
        Account accnt = new Account(name = 'Test Account', BillingState ='State' );
        insert accnt ;
        
        Contact con2 = new Contact(firstname = 'Test',
                                  lastname = 'Contact2',
                                  email = 'test2@gmail.com',
                                  accountid = accnt .id);
        insert con2;    
        product.Seller_Contact_Email__c='test2@gmail.com';
        product.Sold_to_Customer__c='Test Account';
        product.Sold_to_State__c='state'; 
        update product;
        product.Sold_to_Customer__c='Test Account';
        update product;
        product.Sold_to_State__c='state1';
        update product;
        //system.assertEquals([select id, Seller_Contact__c from product2 where id =: product.id].Seller_Contact__c, con2.id);
        //system.assertEquals([select id, Seller_Contact_Account__c  from product2 where id =: product.id].Seller_Contact_Account__c , con2.accountid);
        //system.assertEquals([select id, Sold_to_Customer_Account__c  from product2 where id =: product.id].Sold_to_Customer_Account__c , con2.accountid); 
    }
}