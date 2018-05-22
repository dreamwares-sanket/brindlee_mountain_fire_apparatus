/*
 * @Description An apex test class expose all the trigger functionality on Product2 object
 */
@isTest
public class ProductTriggerTest {
    
    public static testMethod void testProductTriggerSingleRecord() {
        Test.startTest();
        
        Product2 highStockProduct;
        Id truckRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Trucks').getRecordTypeId();
        Id serviceRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        
        Fire_Truck__c fireTruck = new Fire_Truck__c(Year_of_Truck__c = 2011,Chassis_Manufacturer__c='Amertek');
        insert fireTruck;
        
        product2 pdtRecord1 = new product2(recordTypeId = serviceRecordTypeId,
                                          Stock_Number__c = 'test0',
                                          Name = 'test1');
        insert pdtRecord1;
        try {
            highStockProduct = [SELECT Stock_Number__c FROM Product2 WHERE recordType.Name = 'Trucks' ORDER BY Stock_Number__c DESC LIMIT 1];        
        } catch(Exception exp) {
        }
        // As there is no record of type Trucks, So highStockProduct will be null
        system.assertEquals(null,highStockProduct);
        
        product2 pdtRecord2 = new product2(recordTypeId = truckRecordTypeId,
                                          Stock_Number__c = '00000',
                                          Name = 'test1',
                                          Fire_Truck__c = fireTruck.id,
                                          apparatusType__c = 'Towers and Platforms');
        insert pdtRecord2;
        highStockProduct = [SELECT Stock_Number__c FROM Product2 WHERE recordType.Name = 'Trucks' ORDER BY Stock_Number__c DESC LIMIT 1];        
        // Stock_Number__c = 00001 is predicted by above code, as only 1 records is inserted as 'Trucks' record type.
        system.assertEquals('00001',highStockProduct.Stock_Number__c);
        
        Test.stopTest();
    }
    
    public static testMethod void testProductTriggerNonTruckRecords() {        
        Test.startTest();
        
        Product2 highStockProduct;
        Id truckRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Trucks').getRecordTypeId();
        Id serviceRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        List<Product2> productList = new List<Product2>();
        
        for(integer i=1;i<=200;i++) {
            productList.add(new product2(recordTypeId = serviceRecordTypeId,
                                         Stock_Number__c = 'T0' + ( 100 + i ),
                                         Name = 'test'+i));
        }
        insert productList;        
        
        try {
            highStockProduct = [SELECT Stock_Number__c FROM Product2 WHERE recordType.Name = 'Trucks' ORDER BY Stock_Number__c DESC LIMIT 1];        
        } catch(Exception exp) {
        }
        // Stock_Number__c = 00001 as one record inserted as 'Trucks' record type by previous method
        system.assertEquals(null,highStockProduct);

        Test.stopTest();        
    }
    
    
    public static testMethod void testProductTriggerBulkRecord() {
        Test.startTest();
        
        Product2 highStockProduct;
        Id truckRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Trucks').getRecordTypeId();
        Id serviceRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        List<Product2> productList = new List<Product2>();
        
        Fire_Truck__c fireTruck = new Fire_Truck__c(Year_of_Truck__c = 2014,Chassis_Manufacturer__c='Amertek');
        insert fireTruck;
        
        for(integer i=1;i<=200;i++) {
            if(math.mod(i,2) == 0) {
                productList.add(new product2(recordTypeId = truckRecordTypeId,
                                            Stock_Number__c = '00' + (600 + i),
                                            Name = 'test'+i,
                                            Fire_Truck__c = fireTruck.id,
                                            apparatusType__c = 'Towers and Platforms'));
            } else {
                productList.add(new product2(recordTypeId = serviceRecordTypeId,
                                            Stock_Number__c = '0T0' + (600 - i),
                                            Name = 'test'+i));
            }
        }
        insert productList;        
        
        highStockProduct = [SELECT Stock_Number__c FROM Product2 WHERE recordType.Name = 'Trucks' ORDER BY Stock_Number__c DESC LIMIT 1];
        // Stock_Number__c = 00100 is predicted by above code, as 100 records are inserted as 'Trucks' record type.
        system.assertEquals('00100',highStockProduct.Stock_Number__c);
        
        Test.stopTest();
    }
    
    @isTest
    private static void insertLooseEquipment_UnitTest(){
        Id looseEqpmntType = Utilities.getProductRecordTypeId('Loose Equipment');
        
        Product2 product1 = new Product2( Name='Test Eqpmnt', RecordTYpeId=looseEqpmntType);
        insert product1;
        Product2 resultProd = [ SELECT Id, Equipment_Number__c FROM Product2 WHERE Id=:product1.Id LIMIT 1 ];
        System.assertEquals('E00001', resultProd.Equipment_Number__c);
        delete resultProd;
        
        product1 = new Product2( Name='Test Eqpmnt', RecordTYpeId=looseEqpmntType );
        insert product1;
        resultProd = [ SELECT Id, Equipment_Number__c FROM Product2 WHERE Id =:product1.Id LIMIT 1 ];
        System.assertEquals('E00002', resultProd.Equipment_Number__c);
    }
    
    @isTest
    private static void insertLooseEquipment_BulkTest(){
        Id looseEqpmntType = Utilities.getProductRecordTypeId('Loose Equipment');
        
        List<Product2> listProducts = new List<Product2>();
        for( integer i=0; i<100; i++ ){
            listProducts.add(new Product2( Name='Test Eqpmnt'+i, RecordTYpeId=looseEqpmntType ));
        }
        insert listProducts;
        
        Product_Autonumber_Identity__c product_Identity = Product_Autonumber_Identity__c.getAll().values()[0];
        System.assertEquals(listProducts.size(), product_Identity.Latest_Equipment_Number__c);
    }
    
    @isTest
    private static void insertTrucks_UnitTest(){
        Id trucksType = Utilities.getProductRecordTypeId('Trucks');
        Fire_Truck__c fireTruck = new Fire_Truck__c(Year_of_Truck__c = 2014,Chassis_Manufacturer__c='Amertek');
        insert fireTruck;
        Product2 product = new product2( recordTypeId = trucksType, Name = 'test', Fire_Truck__c = fireTruck.id,
                             			 apparatusType__c = 'Towers and Platforms');
        insert product;
        Product_Autonumber_Identity__c product_Identity = Product_Autonumber_Identity__c.getAll().values()[0];
        System.assertEquals( 1, product_Identity.Latest_Stock_Number__c );
        delete product;
        
        Product2 product2 = new product2( recordTypeId = trucksType, Name = 'test', Fire_Truck__c = fireTruck.id,
                             			 apparatusType__c = 'Towers and Platforms');
        insert product2;
        product_Identity = Product_Autonumber_Identity__c.getAll().values()[0];
        System.assertEquals( 2, product_Identity.Latest_Stock_Number__c );
    }
    
    @isTest
    private static void insertTrucks_BulkTest(){
        Id trucksType = Utilities.getProductRecordTypeId('Trucks');
        Fire_Truck__c fireTruck = new Fire_Truck__c(Year_of_Truck__c = 2014,Chassis_Manufacturer__c='Amertek');
        insert fireTruck;
        
        List<Product2> listProducts = new List<Product2>();
        for( Integer count=0; count<100; count++ ){
            listProducts.add( new product2( recordTypeId = trucksType, Name = 'test'+count, Fire_Truck__c = fireTruck.id,
                                             apparatusType__c = 'Towers and Platforms'));
        }
        insert listProducts;
        
        Product_Autonumber_Identity__c product_Identity = Product_Autonumber_Identity__c.getAll().values()[0];
        System.assertEquals( listProducts.size(), product_Identity.Latest_Stock_Number__c );
        ProductTriggerHandler.formatInteger(null);
    }
}