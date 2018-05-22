/**
* Test class for testing of Utilities apex class
*
* @author - Dreamwares(Aditya)
* @createdDate - 2016/5/19
*
*/
@isTest
public class UtilitiesTest {
    
    @testSetup
    private static void  insertRequiredRecords(){
        Fire_Truck__c fireTruck = new Fire_Truck__c();
        fireTruck.Year_of_Truck__c = 2013;
        fireTruck.Mileage__c = 8000;
        fireTruck.Pump_GPM__c = '1750';
        fireTruck.Fire_Body_Manufacturer__c = 'E-One';
        fireTruck.Chassis_Manufacturer__c = '3D';
        fireTruck.Aerial_Length__c = '55';
        insert fireTruck;
        
        Product2 product;
        product = new Product2();
        product.Fire_Truck__c = fireTruck.Id;
        product.Name = 'Test Fire Truck';
        product.Stock_Number__c = 'STK#132123';
        product.Post_To_Website__c = True;
        product.apparatusType__c = 'Used Pumpers and Engines';
        product.Scene_Lights__c = 'Vibrant';
        product.IsActive = True;
        product.Post_To_Website__c = True;
        product.Add_to_Fire_Truck_Finder__c = True;
        product.status__c = 'Available';
        insert product;
    }
    
    @isTest
    private static void testMethods(){
        Product2 product = [SELECT Id, VF_Main_Title__c, Stock_Number__c FROM Product2 LIMIT 1];
        System.assert(String.isNotBlank(Utilities.getTruckDetailPageUrlParams(product)));
        
        System.assert( !Utilities.generatePicklistFieldOptions( new Product2(), 'apparatusType__c', 'All' ).isEmpty() );
        System.assert( !Utilities.getCategoryUrlcodesMap(new Product2(), 'ApparatusType__c').isEmpty());
        System.assert( !Utilities.getCategoryUrlcodesWrapperList(new Product2(), 'ApparatusType__c').isEmpty());
        System.assert( String.isNotBlank(Utilities.getTruckRecordTypeId()));
        
        Utilities.getUserFromUserName('Test User');
        Utilities.getOrgWideEmailAddress('test@test.com');
        Utilities.getSalesRepsEmail();
        Utilities.sendEmailMessage('test', '<h1>HI</h1>', 'test@test.com');
        
        System.assert( !Utilities.getPriceOptions().isEmpty());
        System.assert( !Utilities.getPicklistYearOptions().isEmpty());
        System.assert( !Utilities.getPicklistPumpSizeOptions().isEmpty());
        System.assert( !Utilities.getPicklistTankSizeOptions().isEmpty());
        System.assert( !Utilities.getPicklistWarrantyOptions().isEmpty());
        System.assertNotEquals( null, Utilities.getProductRecordTypeId('Loose Equipment'));
        System.assertEquals( null, Utilities.getProductRecordTypeId(null));
    }
    
    @isTest
    private static void testSendEmailViatemplate(){
        Contact con = new Contact();
        con.LastName='test Contact';
        insert con;
        
        Fire_Truck__c fireTruck = new Fire_Truck__c();
        fireTruck.Main_Title__c = 'new Truck';
        fireTruck.Year_of_Truck__c = 2013;
        fireTruck.Mileage__c = 8000;
        fireTruck.Pump_GPM__c = '1750';
        fireTruck.Fire_Body_Manufacturer__c = 'E-One';
        fireTruck.Chassis_Manufacturer__c = '3D';
        insert fireTruck;
        
        Product2 product = new Product2();
        product.Fire_Truck__c = fireTruck.Id;         
        product.Website_Price__c = '$40,000';
        product.apparatusType__c = 'Used ARFF and Airport Crash Trucks';
        product.Warranty_Terms__c = 'test';     // Warranty for trucks
        product.Website_Price__c = '$120,000';
        product.apparatusType__c = 'Vocational Trucks';
        product.IsActive = True;
        product.Post_To_Website__c = True;
        product.Stock_Number__c = '200';
        product.Name = 'Truck no. 200';
        product.status__c = 'Available';
        insert product;
        
        Id templateId = Utilities.getEmailTemplateId('FTF_Criteria_Email_Notification_VF');
        OrgWideEmailAddress owdEmail =  new OrgWideEmailAddress();
        Utilities.sendEmailViaTemplate(templateId, con.Id, product.Id, false, null );
    }
    
    @isTest
    private static void testLooseEqpmentParams(){
        Product2 product = new Product2(RecordTypeId=Utilities.getProductRecordTypeId('Loose Equipment'), Name='Test Product');
        System.assert(String.isNotBlank(Utilities.getLooseEqpmntDetailPageUrlparams(product)));
    }
}