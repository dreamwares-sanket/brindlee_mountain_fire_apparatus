/*
 * VF page controller for an RSS feed for Product records
 * 
 * @author Dreamwares (Aditya S.) 
 * @created 09/07/2016
 */
@isTest
public class TrucksForSale_RSSFeeds_ControllerTest {
    
    @testSetup
    private static void insertRecords(){
        Fire_Truck__c fireTruck = new Fire_Truck__c();
        fireTruck.Main_Title__c = 'new Truck';
        fireTruck.Year_of_Truck__c = 2013;
        fireTruck.Mileage__c = 8000;
        fireTruck.Pump_GPM__c = '1750';
        fireTruck.Fire_Body_Manufacturer__c = 'E-One';
        fireTruck.Chassis_Manufacturer__c = '3D';
        insert fireTruck;
        
        Id truckTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Trucks').getRecordTypeId();
        Boolean boolVar = true;
        
        List<Product2> listProducts = new  list<Product2>();
        for(integer count=0;count<50;count++){
            listProducts.add(
                new Product2(
                    Name = 'Product'+count,
                    Fire_Truck__c = fireTruck.Id,
                    Website_Price__c = '$120,000',
                    apparatusType__c = 'Vocational Trucks',
                    RecordTypeId = truckTypeId,
                    Post_to_Fireapparatus_com__c = boolVar,
                    status__c = 'Available'
                ));
        }
        insert listProducts;
    }
    @isTest
    private static void testRecords(){
        Test.startTest();
            TrucksForSale_RSSFeeds_Controller controller = new TrucksForSale_RSSFeeds_Controller();
            System.assertEquals(50, controller.getListProducts().size());
        Test.stopTest();
    }
    
}