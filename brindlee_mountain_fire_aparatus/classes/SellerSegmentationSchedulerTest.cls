/*
 * @description - Test class for SellerSegmentationBatch
 * @createdBy   - Dreamwares
 * @createdDate - 20/1/2016
 */
@isTest
public class SellerSegmentationSchedulerTest {

    @testSetup
    public static void setUpRecords(){
        Pardot_API_Settings__c pardorCustomSettings = new Pardot_API_Settings__c();
        pardorCustomSettings.Name = 'PS';
        pardorCustomSettings.Authentication_url__c = 'https://pi.pardot.com/api/login/version/3';
        pardorCustomSettings.Email__c = 'truckfinder@firetruckfinder.com';
        pardorCustomSettings.Email_Template_Id__c = '14332';
        pardorCustomSettings.Password__c = 'googleIt';
        pardorCustomSettings.Single_Email_Url__c = 'https://pi.pardot.com/api/email/version/3/do/send/prospect_id/';
        pardorCustomSettings.User_Key__c = 'sfgadffwfezd';
        pardorCustomSettings.Batch_Update_Url__c = 'https://pi.pardot.com/api/prospect/version/3/do/batchUpdate?prospects=';
        pardorCustomSettings.Truck_Match_Pardot_Campaign_Id__c = '12232';
        pardorCustomSettings.Error_Report_Email_Ids__c = 'xyz@gmail.com';
        insert pardorCustomSettings;
        
		List<Seller_Segmentation_Emails_Setting__c> ListSellerSegmtSettings = new List<Seller_Segmentation_Emails_Setting__c>();
        Seller_Segmentation_Emails_Setting__c SellerSegmtSettings = new Seller_Segmentation_Emails_Setting__c();
        SellerSegmtSettings.Name = 'FTF_Seller_Truck_Report_HTML';
        SellerSegmtSettings.Interval_Days__c = 7;
        SellerSegmtSettings.Pardot_Template_Id__c = 16799;
        ListSellerSegmtSettings.add(SellerSegmtSettings);
        
        SellerSegmtSettings = new Seller_Segmentation_Emails_Setting__c();
        SellerSegmtSettings.Name = 'FTF_Seller_Truck_30_Day_Report_HTML';
        SellerSegmtSettings.Interval_Days__c = 30;
        SellerSegmtSettings.Pardot_Template_Id__c = 16801;
        ListSellerSegmtSettings.add(SellerSegmtSettings);
        
        SellerSegmtSettings = new Seller_Segmentation_Emails_Setting__c();
        SellerSegmtSettings.Name = 'FTF_Seller_Truck_60_Day_Report_HTML';
        SellerSegmtSettings.Interval_Days__c = 60;
        SellerSegmtSettings.Pardot_Template_Id__c = 16807;
        ListSellerSegmtSettings.add(SellerSegmtSettings);
        
        SellerSegmtSettings = new Seller_Segmentation_Emails_Setting__c();
        SellerSegmtSettings.Name = 'FTF_Seller_Truck_90_Day_Report_HTML';
        SellerSegmtSettings.Interval_Days__c = 90;
        SellerSegmtSettings.Pardot_Template_Id__c = 18839;
        ListSellerSegmtSettings.add(SellerSegmtSettings);
        
        SellerSegmtSettings = new Seller_Segmentation_Emails_Setting__c();
        SellerSegmtSettings.Name = 'FTF_Seller_Truck_120_Day_Report_HTML';
        SellerSegmtSettings.Interval_Days__c = 120;
        SellerSegmtSettings.Pardot_Template_Id__c = 18841;
        ListSellerSegmtSettings.add(SellerSegmtSettings);
        
        SellerSegmtSettings = new Seller_Segmentation_Emails_Setting__c();
        SellerSegmtSettings.Name = 'FTF_Seller_Truck_150_Day_Report_HTML';
        SellerSegmtSettings.Interval_Days__c = 150;
        SellerSegmtSettings.Pardot_Template_Id__c = 18847;
        ListSellerSegmtSettings.add(SellerSegmtSettings);
        
        insert ListSellerSegmtSettings;       
        
        Scheduler_Settings__c SegmentationSchedulerSetting = new Scheduler_Settings__c();
		SegmentationSchedulerSetting.Segmentation_Email_Schedule_Time__c = 20;
        SegmentationSchedulerSetting.Name = 'Seller Segmentation Scheduler Time';
        insert SegmentationSchedulerSetting;
        
        Contact testCon = new Contact( lastName = 'Test Contact', pi__url__c ='https://pi.pardot.com/prospect/read?id=13322' );
        insert testCon;
        
        Fire_Truck__c fireTruck = new Fire_Truck__c();
        fireTruck.Year_of_Truck__c = 2013;
        fireTruck.Mileage__c = 8000;
        fireTruck.Pump_GPM__c = '1750';
        fireTruck.Fire_Body_Manufacturer__c = 'E-One';
        fireTruck.Chassis_Manufacturer__c = '3D';
        insert fireTruck;
        
        List< Product2 > listProduct = new List< Product2 >();
        Product2 objProduct;
        for( Integer i = 0 ; i < 3 ; i++  ){
            objProduct = new Product2();
            objProduct.Fire_Truck__c = fireTruck.Id;
            objProduct.Seller_Contact__c = testCon.Id;
            objProduct.Posting_Date__c = System.today().addDays(-7);
            objProduct.Stock_Number__c = '0000'+i;
            objProduct.Name = 'New Truck';
            objProduct.IsActive = True;
            objProduct.Post_To_Website__c = True;
            objProduct.Warranty_Terms__c = 'Warranteed';
            objProduct.TypeOfSale__c = 'Broker';
            objProduct.status__c = 'Available';
            listProduct.add( objProduct );
        }
        listProduct[1].Posting_Date__c = System.today().addDays(-30);
        listProduct[2].Posting_Date__c = System.today().addDays(-60);
        insert listProduct;
        
        Lead testLead = new Lead();
        testLead.LastName = 'testLead';
        testLead.Company = 'Company';
        testlead.Status = 'Open';
        insert testLead;
        
        //Product2 testProduct = [SELECT Id, of_Inquiries__c FROM Product2 LIMIT 1];
        
        Fire_Truck_Finder__c truckFinder;
        List< Fire_Truck_Finder__c > listTruckFinder = new List< Fire_Truck_Finder__c >();
        for( Integer i = 0 ; i < 5 ; i++ ){
            truckFinder = new Fire_Truck_Finder__c();
            truckFinder.Lead__c = testLead.Id;
            truckFinder.Product__c = objProduct.Id;
            listTruckFinder.add( truckFinder );
        }        
        insert listTruckFinder;
        
        List< Truck_Inquiries__c > truckinquiries = new List< Truck_Inquiries__c >();
        Truck_Inquiries__c objTruckInquiry;
        for( Integer i = 0 ; i < 5 ; i++ ){
            objTruckInquiry = new Truck_Inquiries__c();
            objTruckInquiry.Lead__c = testLead.Id;
            objTruckInquiry.Product__c = objProduct.Id;
            objTruckInquiry.Inquiry_Type__c = 'phone';
            truckinquiries.add( objTruckInquiry );
        }
        truckinquiries[0].Inquiry_Type__c = 'web';
        insert truckinquiries;
    }
    
	
    public static testmethod void CheckSchedulingMethod(){
        Test.startTest();
        SellerSegmentationScheduler.runSegmentationScheduler();
        Test.stopTest();
    }
    
    public static testMethod void testZeroTruckInquiries(){
        delete [SELECT Id FROM Truck_Inquiries__c];
        
        DateTime curentTime = System.Now().addMinutes(1);
        Integer sec = curentTime.second();
        Integer min = curentTime.minute();
        Integer hr = curentTime.hour();
        String cron = sec + ' ' + min + ' ' + hr + ' * * ?';
        Test.startTest();
        
        // Schedule the test job
        String jobId = System.schedule('Seller Segmentation Emails 7',
                                       cron, 
                                       new SellerSegmentationScheduler());
        Test.stopTest();
    }
    
    public static testMethod void testNullSellerContactForProduct(){
        Product2 product = [SELECT Id, Seller_Contact__c FROM Product2 LIMIT 1];
        product.Seller_Contact__c = null;
        update product;
        
        DateTime curentTime = System.Now().addMinutes(1);
        Integer sec = curentTime.second();
        Integer min = curentTime.minute();
        Integer hr = curentTime.hour();
        String cron = sec + ' ' + min + ' ' + hr + ' * * ?';
        Test.startTest();
        
        // Schedule the test job
        String jobId = System.schedule('Seller Segmentation Emails 6',
                                       cron, 
                                       new SellerSegmentationScheduler());
        Test.stopTest();
    }
    
    public static testMethod void testRecords(){
        DateTime curentTime = System.Now().addMinutes(1);
        Integer sec = curentTime.second();
        Integer min = curentTime.minute();
        Integer hr = curentTime.hour();
        String cron = sec + ' ' + min + ' ' + hr + ' * * ?';
        Test.startTest();
        
        // Schedule the test job
        String jobId = System.schedule('Seller Segmentation Emails 5',
                                       cron, 
                                       new SellerSegmentationScheduler());
        Test.stopTest();
    }
    
    @isTest
    public static void testBatchUpdateRecords(){
        Contact testContact = [SELECT Id FROM Contact];
        
        List< Product2 > listProduct = new List< Product2 >();
        Product2 objProduct;
        for( Integer i = 0 ; i < 50 ; i++  ){
            objProduct = new Product2();
            objProduct.Seller_Contact__c = testContact.Id;
            objProduct.Posting_Date__c = System.today().addDays(-7);
            objProduct.Stock_Number__c = '0000'+i;
            objProduct.Name = 'New Truck';
            objProduct.IsActive = True;
            objProduct.Post_To_Website__c = True;
            objProduct.Warranty_Terms__c = 'Warranteed';
            objProduct.IsActive = True;
            objProduct.TypeOfSale__c = 'Broker';
            objProduct.status__c = 'Available';
            listProduct.add( objProduct );
        }
        insert listProduct;
        
        DateTime curentTime = System.Now().addMinutes(1);
        Integer sec = curentTime.second();
        Integer min = curentTime.minute();
        Integer hr = curentTime.hour();
        String cron = sec + ' ' + min + ' ' + hr + ' * * ?';
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('Seller Segmentation 1',
                                       cron, 
                                       new SellerSegmentationScheduler());
        
        Test.stopTest();
        
    }
    
    @isTest
    public static void testBatchUpdate48Records(){
        delete [SELECT Id FROM Product2];
        Contact testContact = [SELECT Id FROM Contact];
        
        List< Product2 > listProduct = new List< Product2 >();
        Product2 objProduct;
        for( Integer i = 0 ; i < 45 ; i++  ){
            objProduct = new Product2();
            objProduct.Seller_Contact__c = testContact.Id;
            objProduct.Posting_Date__c = System.today().addDays(-7);
            objProduct.Stock_Number__c = '00001'+i;
            objProduct.Name = 'New Truck';
            objProduct.IsActive = True;
            objProduct.Post_To_Website__c = True;
            objProduct.Warranty_Terms__c = 'Warranteed';
            objProduct.IsActive = True;
            objProduct.TypeOfSale__c = 'Broker';
            objProduct.status__c = 'Available';
            listProduct.add( objProduct );
        }
        insert listProduct;
        
        DateTime curentTime = System.Now().addMinutes(1);
        Integer sec = curentTime.second();
        Integer min = curentTime.minute();
        Integer hr = curentTime.hour();
        String cron = sec + ' ' + min + ' ' + hr + ' * * ?';
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('Seller Segmentation 2',
                                       cron, 
                                       new SellerSegmentationScheduler());
        
        Test.stopTest();
        
    }
    
    private static testMethod void testNullCustomSettings(){
        delete [SELECT Id FROM Seller_Segmentation_Emails_Setting__c];
        delete [SELECT Id FROM Pardot_API_Settings__c];
        
        //Test.setMock(HttpCalloutMock.class, new PardotHttpCalloutMock());
        
        Test.startTest();        
        DateTime curentTime = System.Now().addMinutes(1);
        Integer sec = curentTime.second();
        Integer min = curentTime.minute();
        Integer hr = curentTime.hour();
        String cron = sec + ' ' + min + ' ' + hr + ' * * ?';
        
        // Schedule the test job
        String jobId = System.schedule('Seller Segmentation 3',
                                       cron, 
                                       new SellerSegmentationScheduler());
        
        Test.stopTest();
    }
}