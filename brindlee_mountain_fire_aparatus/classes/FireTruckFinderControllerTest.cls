/*
 @description - test class for controller of Fire Truck Finder vf page.
 @createdDate - 8/04/2016
 @createdBy   - Dreamwares
 */
@isTest
public class FireTruckFinderControllerTest {
    
    @testSetup    
    private static void insertRecords(){
        CompanyContactInformation__c bmfaInfo = new CompanyContactInformation__c();
        bmfaInfo.Name = 'BMFA\'s contact info';
        bmfaInfo.Sales_Email__c = 'sales@bmfa.com';
        insert bmfaInfo;
    }
    @isTest
    private static void testPicklists(){
        FireTruckFinderController contlr = new FireTruckFinderController();
        System.assert(String.isNotBlank(contlr.getChassisTypes()));
        System.assert(String.isNotBlank(contlr.getBrands()));
        System.assert(String.isNotBlank(contlr.getMileageOptions()));
        System.assert(String.isNotBlank(contlr.getGeographicRegns()));
        System.assert(String.isNotBlank(contlr.getAerialLengthMin()));
        System.assert(String.isNotBlank(contlr.getAerialLengthMax()));
        System.assert(!contlr.getMapApparatusTypes().isEmpty());
        System.assert(String.isNotBlank(contlr.getWarrantyOptions()));
    }
    
    @isTest
    private static void testFTFCriteriaSubmit(){
        Account account = createAccount();        
        Contact contact = createContact();
        Fire_Truck_Finder_Criteria__c FTFCriteria = createFTFCriteria();
        
        Boolean result = FireTruckFinderController.submitFTFCriteriaRequest(FTFCriteria, account, contact);
        System.assertEquals( true, result);
    }
    
    @isTest
    private static void testSubmitFTFCriteriaforExistingContact(){
        Contact newContact = createContact();
        insert newContact;
        
        Account account = createAccount();
        Fire_Truck_Finder_Criteria__c FTFCriteria = createFTFCriteria();
        
        Boolean result = FireTruckFinderController.submitFTFCriteriaRequest(FTFCriteria, account, newContact);
        System.assertEquals( true, result);
        
        Opportunity opp = [ SELECT Id, Name, OwnerId, AccountId, Contact_at_Department__c, Year_Min__c, Year_Max__c, Budget_Min__c, Budget_Max__c,
                                   Brand__c, Chassis__c, Tank_Size__c, Type_of_Apparatus__c, Pump__c
                            FROM Opportunity
                            WHERE Contact_at_Department__c =: newContact.Id];
        System.assertEquals(opp.Contact_at_Department__c, newContact.Id);
    }
    
    @isTest
    private static void testSubmitFTFCriteriaWithActiveOpportunities(){
        Contact newContact = createContact();
        insert newContact;
        Account account = createAccount();
        insert account;
        
        Opportunity opp = new Opportunity();
        opp.AccountId = account.Id;
        opp.Name = newContact.Id;
        opp.StageName = 'Fire Truck Finder';
        opp.CloseDate = System.today().addDays(5);
        opp.Contact_at_Department__c = newContact.Id;
        insert opp;
        
        Fire_Truck_Finder_Criteria__c FTFCriteria = createFTFCriteria();
        
        Boolean result = FireTruckFinderController.submitFTFCriteriaRequest(FTFCriteria, account, newContact);
        System.assertEquals( true, result);
        
        Contact testContact = [ SELECT Id, Name, (SELECT Id FROM Opportunities__r)
                                FROM Contact
                                WHERE Id=:newContact.Id];
        System.assertEquals(1, testContact.Opportunities__r.size());
    }
    
    @isTest
    private static void testFetchExistingFTFCriteria(){
        Account account = createAccount();        
        Contact contact = createContact();
        Fire_Truck_Finder_Criteria__c FTFCriteria = createFTFCriteria();
        Boolean result = FireTruckFinderController.submitFTFCriteriaRequest(FTFCriteria, account, contact);
        System.assertEquals( true, result);
        FTFCriteria = [SELECT Id,FTF_Id__c FROM Fire_Truck_Finder_Criteria__c LIMIT 1];
        
        Pagereference pageRef = Page.FireTruckFinder;
        pageRef.getParameters().put('id', FTFCriteria.Id);
        pageRef.getParameters().put('ftf_Id', String.valueOf(FTFCriteria.FTF_Id__c));
        test.setCurrentPage(pageRef);
        
        FireTruckFinderController contlr = new FireTruckFinderController();
        System.assertNotEquals(null, contlr.strFTFCriteriaRec);
        
        FTFCriteria = (Fire_Truck_Finder_Criteria__c)JSON.deserialize(contlr.strFTFCriteriaRec, Fire_Truck_Finder_Criteria__c.class);
        
        FTFCriteria.FTF_Apparatus_Type__c = 'European Style Units';
        result = FireTruckFinderController.updateFTFCriteriaRequest(FTFCriteria, createAccount(), contact);
        System.assertEquals( true, result);
        
        Contact con = [SELECT Id, Name, AccountId, OwnerId,
                              (SELECT Id, Type_of_Apparatus__c
                               FROM Opportunities__r
                               WHERE StageName NOT IN ('Closed Won','Closed Lost'))
                       FROM Contact WHERE Id =:contact.Id  LIMIT 1];
        
        // Check if the Opportunity has been updated
        Opportunity opp = con.Opportunities__r[0];
        System.assertEquals(FTFCriteria.FTF_Apparatus_Type__c, opp.Type_of_Apparatus__c);
    }
    
    @isTest
    private static void testFTFCriteriaMatchingTrucks(){
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
        
        Fire_Truck_Finder_Criteria__c FTFCriteria = new Fire_Truck_Finder_Criteria__c();
        //FTFCriteria.Add_to_Fire_Truck_Finder__c = true;
        FTFCriteria.FTF_Aerial_Length_Min__c = '0';
        FTFCriteria.FTF_Aerial_Length_Max__c = '105+';
        FTFCriteria.FTF_Apparatus_Type__c = 'All';
        FTFCriteria.FTF_Brands__c = 'All';
        FTFCriteria.FTF_Budget_Min__c = 0;
        FTFCriteria.FTF_Budget_Max__c = 100000;
        FTFCriteria.FTF_Chassis__c= 'Both';
        FTFCriteria.FTF_Geographic_Region__c = 'All';
        FTFCriteria.FTF_Mileage__c = 'Any Mileage';
        FTFCriteria.FTF_Pump_Size__c = 'All';
        FTFCriteria.FTF_Tank_Size__c = 'All';
        FTFCriteria.FTF_Year_Min__c = 1991;
        FTFCriteria.FTF_Year_Max__c = 2016;
        FTFCriteria.FTF_Trucks_With_Warranty__c = 'All';
        insert FTFCriteria;
        
        Account account = createAccount();        
        Contact contact = createContact();
        Boolean result = FireTruckFinderController.submitFTFCriteriaRequest(FTFCriteria, account, contact);
    }
    
    @isTest
    private static void addCodeCoverageForCriteriaMethods(){
        System.assertEquals(null, FTFCriteria_MatchingTrucksHTMLController.buildCriteriaQueryForProducts(null));
        System.assert(String.isBlank(FTFCriteria_MatchingTrucksHTMLController.getCriteriaForAerialLength(null, null)));
        System.assert(String.isBlank(FTFCriteria_MatchingTrucksHTMLController.addApparatusTypeCriteria(null)));
        System.assert(String.isBlank(FTFCriteria_MatchingTrucksHTMLController.addNumericCondition(null,null,null)));
        FTFCriteria_MatchingTrucksHTMLController.generateRangeCriteria('VF_Sort_By_Pump_Size__c','1000');
        System.assert(String.isBlank(FTFCriteria_MatchingTrucksHTMLController.getCriteriaFromMultiselectVal(null,null)));
        System.assert(String.isBlank(FTFCriteria_MatchingTrucksHTMLController.addChassisCriteria(null)));
        System.assert(String.isNotBlank(FTFCriteria_MatchingTrucksHTMLController.addMileageCriteria('Over 12,000')));
        System.assert(String.isNotBlank(FTFCriteria_MatchingTrucksHTMLController.addMileageCriteria('Under 12,000')));
        System.assert(String.isNotBlank(FTFCriteria_MatchingTrucksHTMLController.addWarrantyCriteria('Included')));
        System.assert(String.isNotBlank(FTFCriteria_MatchingTrucksHTMLController.addWarrantyCriteria('Not Included')));
    }
    
    @isTest
    private static Fire_Truck_Finder_Criteria__c createFTFCriteria(){
        Fire_Truck_Finder_Criteria__c FTFCriteria = new Fire_Truck_Finder_Criteria__c();
        FTFCriteria.Add_to_Fire_Truck_Finder__c = true;
        FTFCriteria.FTF_Aerial_Length_Min__c = '50';
        FTFCriteria.FTF_Aerial_Length_Max__c = '55';
        FTFCriteria.FTF_Apparatus_Type__c = 'Command Units';
        FTFCriteria.FTF_Brands__c = '3D;E-One;Ford';
        FTFCriteria.FTF_Budget_Min__c = 10000;
        FTFCriteria.FTF_Budget_Max__c = 20000;
        FTFCriteria.FTF_Chassis__c= 'custom';
        FTFCriteria.FTF_Geographic_Region__c = 'Canada';
        FTFCriteria.FTF_Mileage__c = 'Under 60,000';
        FTFCriteria.FTF_Pump_Size__c = '500-700';
        FTFCriteria.FTF_Tank_Size__c = '0-250';
        FTFCriteria.FTF_Year_Min__c = 1991;
        FTFCriteria.FTF_Year_Max__c = 1995;
        return FTFCriteria;
    }
    
    @isTest
    private static Contact createContact(){
        Contact newContact = new Contact();
        newContact.FirstName='FName';
        newContact.LastName='LName';
        newContact.Phone='837465865';
        newContact.Email='firetruckmall@bmfa.com';
        return newContact;
    }
    
    @isTest
    private static Account createAccount(){
        Account account = new Account();
        account.Name = 'Fire Dept';
        account.Website='https://www.firetruckmall.com';
        account.BillingState='Arizona';
        return Account;
    }
}