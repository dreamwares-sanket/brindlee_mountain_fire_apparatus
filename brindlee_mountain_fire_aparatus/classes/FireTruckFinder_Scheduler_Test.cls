/*
 * @description - Test class for FireTruckFinder_Scheduler
 * @createdby   - Dreamwares
 * @createdDate - 7/12/2015
 * @lastModifiedDate - 20/4/2016
 */
@isTest 
public class FireTruckFinder_Scheduler_Test {
    
    @isTest
    private static Fire_Truck_Finder_Criteria__c createFTFCriteria(){
        Fire_Truck_Finder_Criteria__c FTFCriteria = new Fire_Truck_Finder_Criteria__c();
        FTFCriteria.Add_to_Fire_Truck_Finder__c = true;
        FTFCriteria.FTF_Aerial_Length_Min__c = '50';
        FTFCriteria.FTF_Aerial_Length_Max__c = '55';
        FTFCriteria.FTF_Apparatus_Type__c = 'Used Pumpers and Engines';
        FTFCriteria.FTF_Brands__c = '3D;E-One;American LaFrance';
        FTFCriteria.FTF_Budget_Min__c = 10000;
        FTFCriteria.FTF_Budget_Max__c = 30000;
        FTFCriteria.FTF_Chassis__c= 'Custom';
        FTFCriteria.FTF_Geographic_Region__c = 'Canada;Africa';
        FTFCriteria.FTF_Mileage__c = 'Under 60,000';
        FTFCriteria.FTF_Pump_Size__c = '0-500';
        FTFCriteria.FTF_Tank_Size__c = '0-250';
        FTFCriteria.FTF_Year_Min__c = 1991;
        FTFCriteria.FTF_Year_Max__c = 1995;
        FTFCriteria.FTF_Trucks_With_Warranty__c = 'Not Included';
        FTFCriteria.FTF_Four_By_Four__c = True;
        return FTFCriteria;
    }
    
    @testSetup 
    public static void insertRecords(){
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
        
        Fire_Truck__c objFireTruck = new Fire_Truck__c();
        objFireTruck.Year_of_Truck__c = 1993;
        objFireTruck.Chassis_Manufacturer__c = 'American LaFrance';
        objFireTruck.Custom_Commercial__c = 'Custom';
        objFireTruck.Fire_Body_Manufacturer__c = 'American LaFrance';
        objFireTruck.Water_Tank_Size_only__c = '250';
        objFireTruck.Pump_GPM__c = '300 GPM';
        objFireTruck.Aerial_Length__c = '50';
        objFireTruck.Mileage__c = 30000;
        objFireTruck.Four_By_Four__c = False;
        insert objFireTruck;

        Id ProductRecordTypeId = getTruckRecordTypeId();
        Product2 objProduct = new Product2();        
        objProduct.Fire_Truck__c = objFireTruck.Id;
        objProduct.Add_to_Fire_Truck_Finder__c = True;
        objProduct.Stock_Number__c = '00001';
        objProduct.apparatusType__c = 'Command Units;Used Pumpers and Engines';
        objProduct.Name = 'New Truck';
        objProduct.Retail_Price__c = '$25,000';  /* MD 12/14:  replaced all test values from 25000 to $25,000 in order to meet Production
validation */
        objProduct.IsActive = True;
        objProduct.Post_To_Website__c = True;
        //objProduct.Geographic_State__c ='Canada';
        objProduct.Warranty_Terms__c = 'Warranteed';
        objProduct.status__c = 'Available';
        objProduct.RecordTypeId = ProductRecordTypeId;
        insert objProduct;
        
        DragDropToCloud__Cloud_Documents__c objDoc = new DragDropToCloud__Cloud_Documents__c();
        objDoc.Product__c = objProduct.Id;
        objDoc.DragDropToCloud__Folder_Id__c = 'testFolder';
        objDoc.Name = 'Cloud Document';
        objDoc.Main_Image__c = True;
        objDoc.Main_Thumbnail__c = True;
        objDoc.Show_Online__c = True;
        insert objDoc;
    }
    
    public static testMethod void testSchedulerMethod(){
        Contact newContact = new Contact();
        newContact.FirstName='FName';
        newContact.LastName='LName';
        newContact.Phone='837465865';
        newContact.Email='firetruckmall@bmfa.com';
        newContact.pi__url__c = 'https://pi.pardot.com/prospect/read?id=92655609';
        insert newContact;
            
        Fire_Truck_Finder_Criteria__c ftfCriteria = createFTFCriteria();
        ftfCriteria.Contact__c = newContact.Id;
        insert ftfCriteria;
        
        Test.startTest();        
        FireTruckFinder_Scheduler.runSchedulerHourly();
        Test.stopTest();
        
        System.assertNotEquals(null, [ SELECT Id FROM Fire_Truck_Finder__c
                                       WHERE Fire_Truck_Finder_Criteria__c=:ftfCriteria.Id]);
    }
    
    public static testMethod void testForErrorHandling(){
        Contact newContact = new Contact();
        newContact.FirstName='FName';
        newContact.LastName='LName';
        newContact.Phone='837465865';
        newContact.Email='firetruckmall@bmfa.com';
        newContact.pi__url__c = 'https://pi.pardot.com/prospect/read?id=92655609';
        insert newContact;
            
        Fire_Truck_Finder_Criteria__c ftfCriteria = createFTFCriteria();
        ftfCriteria.Contact__c = newContact.Id;
        insert ftfCriteria;
        
        Test.startTest();
        DateTime curentTime = System.Now().addMinutes(1);
        Integer sec = curentTime.second();
        Integer min = curentTime.minute();
        Integer hr = curentTime.hour();
        String cron = sec + ' ' + min + ' ' + hr + ' * * ?';
        
        // Schedule the test job
        String jobId = System.schedule('Fire Truck Finder Scheduler 1',
                                       cron, 
                                       new FireTruckFinder_Scheduler());
        Test.stopTest();
    }
    
    public static testMethod void testSchedulerForExistingContacts(){        
        Contact newContact = new Contact();
        newContact.FirstName='FName';
        newContact.LastName='LName';
        newContact.Phone='837465865';
        newContact.Email='firetruckmall@bmfa.com';
        newContact.pi__url__c = 'https://pi.pardot.com/prospect/read?id=92655609';
        insert newContact;
                
        Fire_Truck__c objFireTruck = new Fire_Truck__c();
        objFireTruck.Year_of_Truck__c = 1993;
        objFireTruck.Chassis_Manufacturer__c = 'American LaFrance';
        objFireTruck.Custom_Commercial__c = 'Custom';
        objFireTruck.Fire_Body_Manufacturer__c = 'American LaFrance';
        objFireTruck.Water_Tank_Size_only__c = '250';
        objFireTruck.Pump_GPM__c = '300 GPM';
        objFireTruck.Aerial_Length__c = '50';
        objFireTruck.Mileage__c = 30000;
        objFireTruck.Four_By_Four__c = False;
        insert objFireTruck;
        
        Id ProductRecordTypeId = getTruckRecordTypeId();
        Product2 objProduct = new Product2();
        objProduct.Fire_Truck__c = objFireTruck.Id;
        objProduct.Add_to_Fire_Truck_Finder__c = True;
        objProduct.Stock_Number__c = '00001';
        objProduct.apparatusType__c = 'Command Units;Used Pumpers and Engines';
        objProduct.Name = 'New Truck';
        objProduct.Retail_Price__c = '$25,000';  // MD 12/14:  replaced all test values from 25000 to $25,000 in order to meet Production validation 
        objProduct.IsActive = True;
        objProduct.Post_To_Website__c = True;
        objProduct.Warranty_Terms__c = 'Warranteed';
        objProduct.IsActive = True;
        objProduct.Post_To_Website__c = True;
        objProduct.status__c = 'Available';
        objProduct.RecordTypeId = ProductRecordTypeId;
        //objProduct.Geographic_State__c = 'Canada';
        insert objProduct;
        
        List<Fire_Truck_Finder_Criteria__c> listFTFCriteria = new List<Fire_Truck_Finder_Criteria__c>();
        
        Fire_Truck_Finder_Criteria__c ftfCriteria1 = new Fire_Truck_Finder_Criteria__c();   // Create FTF Criteria to find matches for
        ftfCriteria1.Add_to_Fire_Truck_Finder__c = true;
        ftfCriteria1.FTF_Apparatus_Type__c = 'Used Pumpers and Engines';
        ftfCriteria1.FTF_Brands__c = '3D;E-One;American LaFrance';
        ftfCriteria1.FTF_Budget_Min__c = 10000;
        ftfCriteria1.FTF_Budget_Max__c = 30000;
        ftfCriteria1.FTF_Chassis__c= 'Custom';
        ftfCriteria1.FTF_Geographic_Region__c = 'Canada;Africa';
        ftfCriteria1.FTF_Pump_Size__c = '0-500';
        ftfCriteria1.FTF_Tank_Size__c = '0-250';
        ftfCriteria1.FTF_Year_Min__c = 1991;
        ftfCriteria1.FTF_Year_Max__c = 1995;
        ftfCriteria1.FTF_Mileage__c = 'Over 10,000';
        ftfCriteria1.FTF_Aerial_Length_Max__c = '30+';
        ftfCriteria1.FTF_Aerial_Length_Min__c = '0';
        ftfCriteria1.FTF_Trucks_With_Warranty__c = 'Not Included';
        ftfCriteria1.Contact__c = newContact.Id;
        ftfCriteria1.FTF_Four_By_Four__c = False;
        listFTFCriteria.add(ftfCriteria1);
        
        Fire_Truck_Finder_Criteria__c ftfCriteria2 = new Fire_Truck_Finder_Criteria__c();
        ftfCriteria2.Add_to_Fire_Truck_Finder__c = true;
        ftfCriteria2.FTF_Brands__c = 'All';
        ftfCriteria2.FTF_Budget_Min__c = 10000;
        ftfCriteria2.FTF_Budget_Max__c = 30000;
        ftfCriteria2.FTF_Four_By_Four__c = False;
        ftfCriteria2.FTF_Geographic_Region__c = 'Canada;Africa';
        
        ftfCriteria2.FTF_Pump_Size__c = '0-500';
        ftfCriteria2.FTF_Tank_Size__c = '0-250';
        ftfCriteria2.FTF_Year_Min__c = 1991;
        ftfCriteria2.FTF_Year_Max__c = 1995;
        ftfCriteria2.FTF_Mileage__c = 'Any Mileage';
        ftfCriteria2.Contact__c = newContact.Id;
        ftfCriteria2.FTF_Aerial_Length_Max__c = '';
        ftfCriteria2.FTF_Aerial_Length_Min__c = '';
        ftfCriteria2.FTF_Apparatus_Type__c = 'All';
        ftfCriteria2.FTF_Chassis__c = 'Both';
        ftfCriteria2.FTF_Trucks_With_Warranty__c = 'All';
        listFTFCriteria.add(ftfCriteria2);        
        insert listFTFCriteria;
        
        List<Fire_Truck_Finder__c> listTruckFinders = new List<Fire_Truck_Finder__c>();
        Fire_Truck_Finder__c fireTruckFinder1 = new Fire_Truck_Finder__c(); // Create existing FTF records for the scheduler to process duplicates
        fireTruckFinder1.Product__c = objProduct.Id;
        fireTruckFinder1.Contact__c = newContact.Id;
        fireTruckFinder1.Fire_Truck_Finder_Criteria__c = ftfCriteria1.Id;
        listTruckFinders.add(fireTruckFinder1);
        
        Fire_Truck_Finder__c fireTruckFinder2 = new Fire_Truck_Finder__c(); // Create existing FTF records for the scheduler to process duplicates
        fireTruckFinder2.Product__c = objProduct.Id;
        fireTruckFinder2.Contact__c = newContact.Id;
        fireTruckFinder2.Fire_Truck_Finder_Criteria__c = ftfCriteria1.Id;
        listTruckFinders.add(fireTruckFinder2);
        insert listTruckFinders;
        
        Test.startTest();        
        DateTime curentTime = System.Now().addMinutes(1);
        Integer sec = curentTime.second();
        Integer min = curentTime.minute();
        Integer hr = curentTime.hour();
        String cron = sec + ' ' + min + ' ' + hr + ' * * ?';
        
        // Schedule the test job
        String jobId = System.schedule('Fire Truck Finder Scheduler 2',
                                       cron, 
                                       new FireTruckFinder_Scheduler());
        
        Test.stopTest();
    }
      
    private static testMethod void testMismatchingRecord(){
        Contact newContact = new Contact();
        newContact.FirstName='FName';
        newContact.LastName='LName';
        newContact.Phone='837465865';
        newContact.Email='firetruckmall@bmfa.com';
        newContact.pi__url__c = 'https://pi.pardot.com/prospect/read?id=92655609';
        insert newContact;
            
        Fire_Truck_Finder_Criteria__c ftfCriteria1 = new Fire_Truck_Finder_Criteria__c();   // Create FTF Criteria to find matches for
        ftfCriteria1.Add_to_Fire_Truck_Finder__c = true;
        ftfCriteria1.FTF_Apparatus_Type__c = 'Vocational Trucks';
        ftfCriteria1.FTF_Brands__c = '3D;E-One';
        ftfCriteria1.FTF_Budget_Min__c = 10000;
        ftfCriteria1.FTF_Budget_Max__c = 15000;
        ftfCriteria1.FTF_Chassis__c= 'Commercial';
        ftfCriteria1.FTF_Geographic_Region__c = 'Africa';
        ftfCriteria1.FTF_Pump_Size__c = '500-1000';
        ftfCriteria1.FTF_Tank_Size__c = '500-750';
        ftfCriteria1.FTF_Year_Min__c = 1997;
        ftfCriteria1.FTF_Year_Max__c = 1999;
        ftfCriteria1.FTF_Mileage__c = 'Over 50,000';
        ftfCriteria1.FTF_Aerial_Length_Max__c = '100';
        ftfCriteria1.FTF_Aerial_Length_Min__c = '95';
        ftfCriteria1.FTF_Trucks_With_Warranty__c = 'All';
        ftfCriteria1.Contact__c = newContact.Id;
        ftfCriteria1.FTF_Four_By_Four__c = False;
        insert ftfCriteria1;
        
        Test.startTest();
        DateTime curentTime = System.Now().addMinutes(1);
        Integer sec = curentTime.second();
        Integer min = curentTime.minute();
        Integer hr = curentTime.hour();
        String cron = sec + ' ' + min + ' ' + hr + ' * * ?';
        
        // Schedule the test job
        String jobId = System.schedule('Fire Truck Finder Scheduler 3',
                                       cron, 
                                       new FireTruckFinder_Scheduler());
        Test.stopTest();
        List<Fire_Truck_Finder__c> listFTFRecords =
            new List<Fire_Truck_Finder__c>([ SELECT Id
                                             FROM Fire_Truck_Finder__c
                                             WHERE Fire_Truck_Finder_Criteria__c=:ftfCriteria1.Id]);
        System.assert(listFTFRecords.isEmpty());
    }
    
    private static testMethod void testKeywordFunctionality(){
        Contact newContact = new Contact();
        newContact.FirstName='FName';
        newContact.LastName='LName';
        newContact.Phone='837465865';
        newContact.Email='firetruckmall@bmfa.com';
        newContact.pi__url__c = 'https://pi.pardot.com/prospect/read?id=92655609';
        insert newContact;
        
        List<Fire_Truck_Finder_Criteria__c> listTrucksFinders = new List<Fire_Truck_Finder_Criteria__c>();
        Fire_Truck_Finder_Criteria__c ftfCriteria1 = new Fire_Truck_Finder_Criteria__c();   // Create FTF Criteria to find matches for
        ftfCriteria1.Add_to_Fire_Truck_Finder__c = true;
        ftfCriteria1.FTF_Apparatus_Type__c = 'All';
        ftfCriteria1.FTF_Brands__c = '3D;E-One';
        ftfCriteria1.FTF_Budget_Min__c = 0;
        ftfCriteria1.FTF_Budget_Max__c = 800000;
        ftfCriteria1.FTF_Chassis__c= 'Both';
        ftfCriteria1.FTF_Geographic_Region__c = 'All';
        ftfCriteria1.FTF_Pump_Size__c = 'All';
        ftfCriteria1.FTF_Tank_Size__c = 'All';
        ftfCriteria1.FTF_Year_Min__c = 1970;
        ftfCriteria1.FTF_Year_Max__c = 2016;
        ftfCriteria1.FTF_Mileage__c = 'Over 50,000';
        ftfCriteria1.FTF_Trucks_With_Warranty__c = 'All';
        ftfCriteria1.FTF_Keyword__c = 'Canada';
        ftfCriteria1.Contact__c = newContact.Id;
        ftfCriteria1.FTF_Four_By_Four__c = False;
        listTrucksFinders.add(ftfCriteria1);
        
        Fire_Truck_Finder_Criteria__c ftfCriteria2 = ftfCriteria1.clone( false, true, false, false );
        ftfCriteria2.FTF_Keyword__c = '60000';
        listTrucksFinders.add(ftfCriteria2);
        insert listTrucksFinders;
        
        Fire_Truck__c objFireTruck = new Fire_Truck__c();
        objFireTruck.Year_of_Truck__c = 1993;
        objFireTruck.Chassis_Manufacturer__c = 'American LaFrance';
        objFireTruck.Custom_Commercial__c = 'Custom';
        objFireTruck.Fire_Body_Manufacturer__c = 'American LaFrance';
        objFireTruck.Water_Tank_Size_only__c = '250';
        objFireTruck.Pump_GPM__c = '300 GPM';
        objFireTruck.Aerial_Length__c = '50';
        objFireTruck.Mileage__c = 30000;
        objFireTruck.Four_By_Four__c = False;
        insert objFireTruck;
        
        List<Product2> listProducts = new List<Product2>();
        Product2 objProduct = new Product2();
        objProduct.Fire_Truck__c = objFireTruck.Id;
        objProduct.Add_to_Fire_Truck_Finder__c = True;
        objProduct.Stock_Number__c = '00001';
        objProduct.apparatusType__c = 'Command Units;Used Pumpers and Engines';
        objProduct.Name = 'New Truck';
        objProduct.Retail_Price__c = '$25,000';
        objProduct.IsActive = True;
        objProduct.Post_To_Website__c = True;
        //objProduct.Geographic_State__c ='Canada';
        objProduct.IsActive = True;
        objProduct.Post_To_Website__c = True;
        objProduct.status__c = 'Available';
        objProduct.RecordTypeId = getTruckRecordTypeId();
        listProducts.add(objProduct);
        
        objProduct = new Product2();
        objProduct.Fire_Truck__c = objFireTruck.Id;
        objProduct.Add_to_Fire_Truck_Finder__c = True;
        objProduct.Stock_Number__c = '00001';
        objProduct.apparatusType__c = 'Command Units;Used Pumpers and Engines';
        objProduct.Name = 'New Truck';
        objProduct.Retail_Price__c = '$25,000';
        objProduct.IsActive = True;
        objProduct.Post_To_Website__c = True;
        //objProduct.Geographic_State__c ='Africa';
        objProduct.IsActive = True;
        objProduct.Post_To_Website__c = True;
        objProduct.status__c = 'Available';
        objProduct.RecordTypeId = getTruckRecordTypeId();
        objProduct.Truck_Sales_Price__c = 60000;
        listProducts.add(objProduct);
        insert listProducts;
        
        List<FTFKeywordSearchFields__c> listSearchField = new List<FTFKeywordSearchFields__c>();
        FTFKeywordSearchFields__c searchFields = new FTFKeywordSearchFields__c( Name = 'Record 1', Fields__c = 'FT_Aerial_Hours__c,FT_Aerial_Length__c,FT_Aerial_Manufacturer__c,FT_Chassis_Manufacturer__c,FT_Custom_Commercial__c,FTF_Tank_Size__c,FTF_Pump_Size__c,FT_Mileage__c,FT_Pump_GPM__c,FT_Water_Tank_Size_only__c,FT_Year_of_Truck__c');
        listSearchField.add(searchFields);
                                                                               
        searchFields = new FTFKeywordSearchFields__c( Name = 'Record 2', Fields__c = 'apparatusType__c,HOD_Days__c,Seller_Contact_Email__c,VF_Sort_By_Tank_Size__c,VF_Website_Price__c,Truck_Sales_Price__c');
        listSearchField.add(searchFields);
        insert listSearchField;
        
        Test.starttest();
        DateTime curentTime = System.Now().addMinutes(1);
        Integer sec = curentTime.second();
        Integer min = curentTime.minute();
        Integer hr = curentTime.hour();
        String cron = sec + ' ' + min + ' ' + hr + ' * * ?';
        
        // Schedule the test job
        String jobId = System.schedule('Fire Truck Finder Scheduler 4',
                                       cron, 
                                       new FireTruckFinder_Scheduler());
        Test.stopTest();
    }
    
    private static testMethod void updateUnsubscribedContacts(){
        Contact newContact = new Contact();
        newContact.FirstName='FName';
        newContact.LastName='LName';
        newContact.Phone='837465865';
        newContact.Email='firetruckmall@bmfa.com';
        newContact.pi__url__c = 'https://pi.pardot.com/prospect/read?id=92655609';
        insert newContact;
        
        FireTruckFinder_batch batch = new FireTruckFinder_batch();
        batch.modifyAndUpdateUnsubscribedProspects(new List<Contact>{newContact});
    }
    
    private static testMethod void testExceptionForContactsUpdate(){
        Contact newContact = new Contact();
        newContact.FirstName='FName';
        newContact.LastName='LName';
        newContact.Phone='837465865';
        newContact.Email='firetruckmall@bmfa.com';
        newContact.pi__url__c = 'https://pi.pardot.com/prospect/read?id=92655609';
        
        FireTruckFinder_batch batch = new FireTruckFinder_batch();
        batch.modifyAndUpdateUnsubscribedProspects(new List<Contact>{newContact});        
    }
    
    private static testMethod void TruckFinderCreationCodeCoverage(){
        FireTruckFinder_batch batch = new FireTruckFinder_batch();
        batch.createTruckFinderRecords(null, null);
        batch.createTruckFinder(null, null);
        
        Fire_Truck_Finder__c fireTruckFinder = new Fire_Truck_Finder__c();
        insert fireTruckFinder;
        batch.insertFireTruckFinders(new List<Fire_Truck_Finder__c>{ fireTruckFinder });
    }
	
    private static testmethod void coverComparisonMethods(){
        fireTruckFinder_Handler.checkWarrantyConditions(true, 'Not Included', false);
        fireTruckFinder_Handler.checkAerialLength(false, null, null, null);
        fireTruckFinder_Handler.checkMultiSelectInclusion(true,'Canada', 'East');
        fireTruckFinder_Handler.checkMatchingConditons(true,'Test','Test');
        Product2 product = new Product2(Name='Test');
        insert product;
        fireTruckFinder_Handler.isProductAlreadyMatched(product.Id, new Set<Product2>{product});
        fireTruckFinder_Handler.checkRangeInMultiSelect(True,'0-500;500-900', 400 );
        fireTruckFinder_Handler.checkRangeConditions(true, null, null );
        fireTruckFinder_Handler.checkRangeConditions(true, '500', 1000 );
        fireTruckFinder_Handler.checkMatchingConditons(true, 'all', null);
    }
    
    private static testMethod void testEmailSend(){
        FireTruckFinder_Handler.sendErrorMails('Errors', 'testEmail@sf.com');        
    }
    
    private static testMethod Id getTruckRecordTypeId(){
        return Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Trucks').getRecordTypeId();
    }
}