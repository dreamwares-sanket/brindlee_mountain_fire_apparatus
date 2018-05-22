/*
 Test class for Upload Loose Equipment vf page controller
 @createdDate   2016/09/16
 @author        Dreamwares
 */
@isTest
public class UploadLooseEquipmentControllerTest {
    
    @isTest
    private static void testNewCustomerReg(){
        
        UploadLooseEquipmentController controller = new UploadLooseEquipmentController();
        controller.getLooseEquipmentPricing();
        
        insert new Loose_Equipment_Pricing__c(Name='Test', Price__c=50);
        insert new AWS_Credentials__c(Name='Test', AccessKeyId__c='HBAVSJVANMBNASBN', BucketId__c='00dhw87echJs3', SecretAccessKey__c='jshdfkzz89898hlkdj/8934sdjnfn' );
        
        System.assertNotEquals(null, controller.getLooseEquipmentPricing());
        System.assertNotEquals(null, controller.getLoginCredentials());
        System.assertNotEquals(null, controller.getLooseEquipmentTypes());
        System.assertNotEquals(null, controller.getChargentBillingStateValues());
        
        Account acc = createAccount();
        Contact con = createContact();
        Product2 product = createProduct();
        ChargentOrders__ChargentOrder__c order = createOrder();
        
        Test.startTest();
        
        UploadLooseEquipmentController.registerLooseEquipmentListing(
            JSON.serialize(acc), JSON.serialize(con),
            JSON.serialize(product), JSON.serialize(order)
        );
        
        Id chargentOrderId = [ SELECT Id FROM ChargentOrders__ChargentOrder__c WHERE ChargentOrders__Bank_Account_Name__c='Test' ].Id,
           productId = [ SELECT Id FROM Product2 LIMIT 1 ].Id,
           conId = [ SELECT Id FROM Contact WHERE FirstName='Test User' ].Id;
        
        UploadLooseEquipmentController.ChargeOrder(chargentOrderId, productId, conId);
        
        Test.stopTest();
    }
    
    @isTest
    private static void testExistingCustomerReg(){
        UploadLooseEquipmentController controller = new UploadLooseEquipmentController();
        Account acc = createAccount();
        Contact con = createContact();
        insert con;
        Product2 product = createProduct();
        ChargentOrders__ChargentOrder__c order = createOrder();
        
        Test.startTest();
        
        UploadLooseEquipmentController.registerLooseEquipmentListing(
            JSON.serialize(acc), JSON.serialize(con),
            JSON.serialize(product), JSON.serialize(order)
        );
        
        Test.stopTest();
    }
    
    @isTest
    private static void testExistingCustomerWithAccReg(){
        UploadLooseEquipmentController controller = new UploadLooseEquipmentController();
        Account acc = createAccount();
        insert acc;
        Contact con = createContact();
        con.AccountId = acc.Id;
        insert con;
        Product2 product = createProduct();
        ChargentOrders__ChargentOrder__c order = createOrder();
        
        Test.startTest();
        
        UploadLooseEquipmentController.registerLooseEquipmentListing(
            JSON.serialize(acc), JSON.serialize(con),
            JSON.serialize(product), JSON.serialize(order)
        );
        
        Test.stopTest();
    }
    
    @istest
    private static void testChargentError(){
        UploadLooseEquipmentController controller = new UploadLooseEquipmentController();
        Account acc = createAccount();
        Contact con = createContact();
        con.AccountId = acc.Id;
        insert con;
        Product2 product = createProduct();
        ChargentOrders__ChargentOrder__c order = createOrder();
        order.ChargentOrders__Card_Security_Code__c = '23443';
        
        Test.startTest();
        
        UploadLooseEquipmentController.registerLooseEquipmentListing(
            JSON.serialize(acc), JSON.serialize(con),
            JSON.serialize(product), JSON.serialize(order)
        );
        
        Test.stopTest();
    }
    
    @isTest
    private static void testUpdate(){
        Account acc = createAccount();
        Contact con = createContact();
        Product2 product = createProduct();
        
        insert acc;
        insert con;
        insert product;
        
        UploadLooseEquipmentController.updateLooseEqmntListingDetails(
            JSON.serialize(acc),
            JSON.serialize(con),
            JSON.serialize(product)
        );
    }
    
    @isTest
    private static void testUpdateWithException(){
        Account acc = createAccount();
        Contact con = createContact();
        Product2 product = createProduct();
        
        UploadLooseEquipmentController.updateLooseEqmntListingDetails(
            JSON.serialize(acc),
            JSON.serialize(con),
            JSON.serialize(product)
        );
    }
    
    @isTest
    private static void testNullConditions(){
        UploadLooseEquipmentController.registerLooseEquipmentListing(
            null, null, null, null
        );
        
        UploadLooseEquipmentController.registerLooseEquipmentListing(
            'undefined', 'undefined', 'undefined', 'undefined'
        );
        
        UploadLooseEquipmentController.updateLooseEqmntListingDetails(
            null, null, null
        );
    }
    
    @isTest
    private static Account createAccount(){
        return new Account(Name='Test', Website='abc.com', BillingState='AL');
    }
    
    @isTest
    private static product2 createproduct(){
        return new Product2( Name='Test', Equipment_Price__c=1200, Loose_Equipment_Type__c='Rescue Tools',
                             Equipment_Status__c='Active', Description='Test');
    }
    
    @isTest
    private static ChargentOrders__ChargentOrder__c createOrder(){
        ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c();
        order.ChargentOrders__Manual_Charge__c= true;
        order.ChargentOrders__Payment_Method__c= 'Credit Card';
        order.ChargentOrders__Billing_Address__c= 'Test';
        order.ChargentOrders__Billing_Address_Line_2__c= 'Address';
        order.ChargentOrders__Billing_City__c= 'Birmingham';
        order.ChargentOrders__Billing_State__c= 'Alabama';
        order.ChargentOrders__Billing_Zip_Postal__c= '12323';
        order.ChargentOrders__Bank_Account_Name__c= 'Test';
        order.ChargentOrders__Card_Expiration_Month__c= String.valueOf(System.today().Month());
        order.ChargentOrders__Card_Expiration_Year__c= String.valueOf(System.today().Year());
        order.ChargentOrders__Card_Number__c= '4242424242424242';
        order.ChargentOrders__Card_Security_Code__c= '123';
        order.ChargentOrders__Charge_Amount__c= 20;
        return order;
    }
    
    @isTest
    private static Contact createContact(){
        return new Contact(FirstName='Test User', lastname='Test', Phone='9899289', Email='test@test.com');
    }
}