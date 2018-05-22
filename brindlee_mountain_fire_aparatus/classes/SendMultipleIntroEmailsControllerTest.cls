/*
 * @description - Test class for Controller SendMultipleIntroEmailsController for Vf page SendMultipleIntroEmails
 * @createdDate - 23/2/2016
 * @createdby   - Dreamwares
 * @lastModifiedDate - 2/3/2016
 */
@istest
public class SendMultipleIntroEmailsControllerTest {

    @testSetup
    private static void setuprecords(){
        List<Keyword_Criteria_Field__c> listCriteriaFields = new List<Keyword_Criteria_Field__c>();
        Keyword_Criteria_Field__c criteriaFields;
        
        List<String> listFieldNames = new List<String>{'IsActive','apparatusType__c','FT_Chassis_Manufacturer__c','FT_Fire_Body_Manufacturer__c',
                                                       'FT_Pump_GPM__c','FT_Water_Tank_Size_only__c','FT_Year_of_Truck__c','status__c','Stock_Number__c','VF_Website_Price__c'};
        for(String fieldName : listFieldNames ){
            criteriaFields = new Keyword_Criteria_Field__c();
            criteriaFields.Name = fieldName;
            criteriaFields.Field_API_Name__c = fieldName;
            listCriteriaFields.add(criteriaFields);
        }
        insert listCriteriaFields;
        
        CompanyContactInformation__c contactDetail = new CompanyContactInformation__c();
        contactDetail.Name = 'BMFA Contact Information';
        contactDetail.Sales_Email__c = 'anonymous@sf.com';
        insert contactDetail;
        
        Contact contact = new Contact();
        contact.LastName = 'Test Contact';
        contact.Preferred_Email__c = 'Email';
        contact.Email = 'test@test.com';
        insert contact;
        
        Lead lead = new Lead();
        lead.Lastname = 'Test lead';
        lead.Status = 'Open';
        lead.Company = 'Test Company';
        lead.email = 'test@test123.com';
        insert lead;
        
        Fire_truck__c fireTruck = new Fire_truck__c();
        fireTruck.Chassis_Manufacturer__c = 'American LaFrance';
        fireTruck.Fire_Body_Manufacturer__c = 'American LaFrance';
        fireTruck.Pump_GPM__c = '100 GPM';
        fireTruck.Water_Tank_Size_only__c = '1000';
        fireTruck.Year_of_Truck__c = 1990;
        insert fireTruck;
        
        List<Product2> listProducts = new List<Product2>();
        Product2 product;
        
        for( Integer i=0; i < 10 ; i++ ){
            product = new Product2();
            product.Name = 'Truck no. '+ i;
            product.Fire_Truck__c = fireTruck.Id;
            //product.typeOfSale__c = 'Broker';
            product.Seller_Contact__c = contact.Id;
            
            product.IsActive = True;
            product.status__c = 'Available';
            product.apparatusType__c = 'Towers and Platforms';
            product.Website_Price__c = '$100,000';                  // validation rule in production org
            
            listProducts.add(product);
        }
        insert listProducts;
    }
    
    @isTest
    private static void testFilterCriteriasWithStringkeyword(){
        List<SendMultipleIntroEmailsController.CriteriaWrapper> listCriteriaFilter = getListOfCriteriaWrappers();
        
        // check for string values
        String strProductsJson = SendMultipleIntroEmailsController.processCriteriaAndFetchProducts( 'Available', JSON.serialize(listCriteriaFilter));
        List<Product2> listProducts = ( List<Product2> )System.JSON.deserialize(strProductsjson, List<Product2>.class);
        System.assertEquals( 10, listProducts.size() );
    }
    
    @isTest
    private static void testFilterCriteriasWithBoolkeyword(){
        List<SendMultipleIntroEmailsController.CriteriaWrapper> listCriteriaFilter = getListOfCriteriaWrappers();
        
        // check for boolean values
        String strProductsJson = SendMultipleIntroEmailsController.processCriteriaAndFetchProducts( 'true', JSON.serialize(listCriteriaFilter));
        List<Product2> listProducts = ( List<Product2> )System.JSON.deserialize(strProductsjson, List<Product2>.class);
        System.assertEquals( 10, listProducts.size() );
    }
    
    @isTest
    private static void testFilterCriteriasWithDoublekeyword(){
        List<SendMultipleIntroEmailsController.CriteriaWrapper> listCriteriaFilter = getListOfCriteriaWrappers();
        
        // check for double values
        String strProductsJson = SendMultipleIntroEmailsController.processCriteriaAndFetchProducts( '1990', JSON.serialize(listCriteriaFilter));
        List<Product2> listProducts = ( List<Product2> )System.JSON.deserialize(strProductsjson, List<Product2>.class);
        System.assertEquals( 10, listProducts.size() );
    }
    
    @isTest
    private static void testFilterCriteriasWithNullParameters(){
        // code coverage for null values : method returns error string
        System.assertNotEquals( null, SendMultipleIntroEmailsController.processCriteriaAndFetchProducts( '', null));
    }
    
    
    @isTest
    private static void testNullInputs(){
        Id contactId = [SELECT Id FROM Contact LIMIT 1].Id;
        String response = SendMultipleIntroEmailsController.initiateMultipleIntroEmailsProcess( contactId, '', '');
        System.assert( response.contains('Required arguments not found!'));
    }
    
    @isTest
    private static void testMultipleIntroEmailForContact(){
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        
        List<Product2> listProduct = new List<Product2>([SELECT Id FROM Product2]);
        System.assertEquals( 10, listProduct.size());
        Set<Id> setProductId = new Set<Id>();
        
        for( Product2 product : listProduct){
            setProductId.add(product.Id);
        }
        String strProductsIds = Json.serialize(setProductId),
               strNotes = 'new Seller Notes';
        Test.startTest();
        SendMultipleIntroEmailsController.initiateMultipleIntroEmailsProcess(contact.Id, strProductsIds, strNotes);
        Test.stopTest();
        
        List<Truck_Inquiries__c> listTruckInquiries = new List<Truck_Inquiries__c>([SELECT Id FROM Truck_Inquiries__c WHERE Contact__c=:contact.Id]);
        System.assertEquals( 10, listTruckInquiries.size());
        contact = [SELECT Id, Send_Multiple_Intro_Email_Notes__c FROM Contact LIMIT 1];
        System.assertEquals( strNotes, contact.Send_Multiple_Intro_Email_Notes__c);
    }
    
    @isTest
    private static void testMultipleIntroEmailForLead(){
        Lead lead = [SELECT Id FROM Lead LIMIT 1];
        
        List<Product2> listProduct = new List<Product2>([SELECT Id FROM Product2]);
        System.assertEquals( 10, listProduct.size());
        Set<Id> setProductId = new Set<Id>();
        
        for( Product2 product : listProduct){
            setProductId.add(product.Id);
        }
        String strProductsIds = Json.serialize(setProductId),
               strNotes = 'new Seller Notes';
        SendMultipleIntroEmailsController.initiateMultipleIntroEmailsProcess(lead.Id, strProductsIds , strNotes);
        
        List<Truck_Inquiries__c> listTruckInquiries = new List<Truck_Inquiries__c>([SELECT Id FROM Truck_Inquiries__c WHERE Lead__c=:lead.Id]);
        System.assertEquals( 10, listTruckInquiries.size());
        lead = [SELECT Id, Send_Multiple_Intro_Email_Notes__c FROM Lead LIMIT 1];
        System.assertEquals( strNotes, lead.Send_Multiple_Intro_Email_Notes__c);
    }
    
    @isTest
    private static void testFieldWrapperList(){
        SendMultipleIntroEmailsController controller = new SendMultipleIntroEmailsController();
        System.assertNotEquals(null, controller.fieldWrapperJson);
    } 
    
    @isTest
    private static void testPicklistValues(){
         System.assertNotEquals( null, SendMultipleIntroEmailsController.getPicklistValsFromFieldAPIName('apparatustype__c'));
    }
    
    @isTest
    private static List<SendMultipleIntroEmailsController.CriteriaWrapper> getListOfCriteriaWrappers(){
        
        List<String> listFieldNames = new List<String>{'IsActive','apparatusType__c','FT_Chassis_Manufacturer__c','FT_Fire_Body_Manufacturer__c',
                                                       'FT_Pump_GPM__c','FT_Water_Tank_Size_only__c','FT_Year_of_Truck__c','status__c','VF_Website_Price__c'};

        List<SendMultipleIntroEmailsController.CriteriaWrapper> listCriteriaFilter = new List<SendMultipleIntroEmailsController.CriteriaWrapper>();
        SendMultipleIntroEmailsController.CriteriaWrapper criteriaWrapper = new SendMultipleIntroEmailsController.CriteriaWrapper();
        
        for(String field : listFieldNames){
            criteriaWrapper = new SendMultipleIntroEmailsController.CriteriaWrapper();
            criteriaWrapper.strFieldAPIName = field;
            listCriteriaFilter.add(criteriaWrapper);
        }
                
        listCriteriaFilter[0].strOperator = '=';
        listCriteriaFilter[0].strValue = 'True';
        
        listCriteriaFilter[1].strOperator = 'includes';
        listCriteriaFilter[1].strValue = '(\'Towers and Platforms\')';
        
        listCriteriaFilter[2].strOperator = '=';
        listCriteriaFilter[2].strValue = '\'American LaFrance\'';
        
        listCriteriaFilter[3].strOperator = '=';
        listCriteriaFilter[3].strValue = '\'American LaFrance\'';
              
        listCriteriaFilter[4].strOperator = '=';
        listCriteriaFilter[4].strValue = '\'100 GPM\'';
        
        listCriteriaFilter[5].strOperator = '=';
        listCriteriaFilter[5].strValue = '\'1000\'';
        
        listCriteriaFilter[6].strOperator = '>=';
        listCriteriaFilter[6].strValue = '1990';
        
        listCriteriaFilter[7].strOperator = '=';
        listCriteriaFilter[7].strValue = '\'Available\'';
        
        listCriteriaFilter[8].strOperator = '=';
        listCriteriaFilter[8].strValue = '\'$100,000\'';

        return listCriteriaFilter;
    }
}