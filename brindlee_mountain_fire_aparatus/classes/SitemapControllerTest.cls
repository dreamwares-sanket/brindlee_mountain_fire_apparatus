/*
 * @description - Code coverage and test methods for sitemap Controller
 * @createdDate - 22/12/2015
 * @createdBy - Dreamwares
 */ 
@isTest
public class SitemapControllerTest {
	
    @testSetup
    public static void insertRecords(){
    	Fire_Truck__c objFireTruck = new Fire_Truck__c();
        objFireTruck.Year_of_Truck__c = 1990;
        objFireTruck.Chassis_Manufacturer__c = 'American LaFrance';
        objFireTruck.Custom_Commercial__c = 'Custom';
        objFireTruck.Fire_Body_Manufacturer__c = 'American LaFrance';
        objFireTruck.Water_Tank_Size_only__c = '250';
        objFireTruck.Pump_GPM__c = '300 GPM';
        insert objFireTruck; 
        
        //List< Product2 > listProduct2 = new List< PRoduct2 >();
        
        Id ProductRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Trucks').getRecordTypeId();
        
        list< Product2 > listProducts =new List< Product2 >();
        Product2 objProduct;
        for( Integer i=0;i<1200;i++ ){
            objProduct = new Product2();
            objProduct.Fire_Truck__c = objFireTruck.Id;
            objProduct.Stock_Number__c = '00001';
            objProduct.apparatusType__c = 'Used Pumpers and Engines';
            objProduct.Name = 'New Truck';
            objProduct.IsActive = True;
            objProduct.Post_To_Website__c = True;
            objProduct.status__c = 'Available';
            objProduct.RecordTypeId = ProductRecordTypeId;
            listProducts.add( objProduct );
        }        
        insert listProducts;
    }
    
    @isTest
    private static void checkProductUrls(){
        sitemapController con = new sitemapController();
        
        System.assertEquals( 1000, con.listUrlSetWrapper[0].size());
        System.assertEquals( 200, con.listUrlSetWrapper[1].size());
        
        System.assertNotEquals(null, con.listAvailableTrucksUrls);
    }
    
}