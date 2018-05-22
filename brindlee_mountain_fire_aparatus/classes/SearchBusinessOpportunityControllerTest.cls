@isTest
public class SearchBusinessOpportunityControllerTest {

    @testSetup 
    static void setupTestData(){
        Fire_Truck__c fireTruck = new Fire_Truck__c();
        fireTruck.Year_of_Truck__c = System.Today().year();
        fireTruck.Mileage__c = 8000;
        fireTruck.Pump_GPM__c = '250';
        fireTruck.Fire_Body_Manufacturer__c = '3D';
        fireTruck.Chassis_Manufacturer__c = '3D';
        fireTruck.Custom_Commercial__c ='Commercial';
        fireTruck.Pump_GPM__c='225 GPM';
        fireTruck.Water_Tank_Size_only__c = '225';
        insert fireTruck;
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Product2; 
        Map<String,Schema.RecordTypeInfo> ProductRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id recordTypeId = ProductRecordTypeInfo.get('Trucks').getRecordTypeId();
        //create five products
        List< Product2 > listProducts = new List< Product2 >();
        Product2 objProduct;
        for( integer i=0 ;i < 5 ; i++ ){
            objProduct = new Product2();
            objProduct.Fire_Truck__c = fireTruck.Id;
            objProduct.Name = 'Truck no. '+ i;
            objProduct.Stock_Number__c = 'STK#' + i;
            objProduct.Post_To_Website__c = True;
            objProduct.apparatusType__c = 'Used Pumpers and Engines';
            objProduct.Scene_Lights__c = 'Vibrant';
            objProduct.Website_Price__c = '$500';            
            objProduct.Retail_Price__c = '$500';
            objProduct.recordTypeId = recordTypeId; 
            objProduct.status__c  = 'Available';
            listProducts.add(objProduct);
        }
        insert listProducts;
        
        List<Account> accounts = new List<Account>();
        for(Integer i=0;i < 10;i++){
            accounts.add(new Account(Name = 'Test Acc', BillingCountry = 'USA', BillingState='Oklahoma'));
        }
        insert accounts;
        List<Opportunity> opportunities = new List<Opportunity>();
        
        Id productId = [SELECT Id FROM Product2 LIMIT 1].Id;
        for(Account acc:accounts){
            for(Integer i=0;i < 10;i++){
                opportunities.add(new Opportunity(
                    Name = 'Test Opp', 
                    AccountId = acc.Id,
                    StageName = 'Closed Won',
                    CloseDate = Date.today(),
                    Type_of_Apparatus__c = 'Used Pumpers and Engines',
                    Year_Max__c  = System.Today().year(),
                    Year_Min__c =System.Today().year(),
                    Brand__c ='WORKING ON SHARED LIST;3D',
                    Budget_Max__c = 1000,
                    Budget_Min__c = 100,
                    Chassis__c = 'Custom;Commercial',
                    Pump__c = '0-500',
                    Tank_Size__c ='0-250',
                    Product_Nickname__c = productId,
                    Sales_Projected_Close_Date__c = System.today(),
                    Why_are_you_moving_the_close_date__c = 'ksuhfkjdfkl',
                    Truck_Sales_Price_or_Commission__c = 10000,
                    FTF_Mileage__c = 'Under 200,000',
                    Broker_Truck_Sale_Price__c = '20000',
                    What_is_our_next_step_to_sell__c = 'Sell'
                ));
            }
        }
        insert opportunities;
    }
    public static testMethod void testScoreForProductAndOpportunity() {
        PageReference pageRef = Page.SearchBusinessOpportunity ;
        Test.setCurrentPage(pageRef);
        Id opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        Id ProductId = [SELECT Id FROM Product2 LIMIT 1].Id;
        SearchBusinessOpportunityController  controller = new SearchBusinessOpportunityController ();
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', opportunityId);
        
        // Instantiate a new controller with all parameters in the page
        controller = new SearchBusinessOpportunityController(); 
        
        ApexPages.currentPage().getParameters().put('id', ProductId);
        
        // Instantiate a new controller with all parameters in the page
        controller = new SearchBusinessOpportunityController ();        
        system.assertNotEquals(0, controller.listOpportunityWrapper.size());
    }
    
    public static testMethod void testScoreForOpportunity() {
        PageReference pageRef = Page.SearchBusinessOpportunity ;
        Test.setCurrentPage(pageRef);
        Opportunity opportunity = [SELECT Id, Name, Type_of_Apparatus__c, Year_Min__c, Year_Max__c, 
                                   Brand__c, Budget_Min__c, Budget_Max__c, Chassis__c, Tank_Size__c,
                                   Trucks_With_Warranty__c, Geographic_Region__c, pUMP__c
                                   FROM Opportunity Limit 1];
        
        // change opportunity Mileage         
        opportunity.FTF_Mileage__c = 'Any Mileage';
        
        // change opportunity Budget         
        opportunity.Budget_Max__c = 100000;
        opportunity.Budget_Min__c = 100000;
        opportunity.Year_Max__c  = System.Today().year() - 5;
        opportunity.Year_Min__c = System.Today().year()- 5;
        opportunity.pUMP__c = '500-750';
        opportunity.Tank_Size__c = '400-750';
        opportunity.Chassis__c = 'Custom';
        opportunity.Trucks_With_Warranty__c = 'Included';
        opportunity.Geographic_Region__c = 'USA - West';
            
        Update opportunity;     
        Id ProductId = [SELECT Id FROM Product2 LIMIT 1].Id;
        SearchBusinessOpportunityController  controller = new SearchBusinessOpportunityController ();
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', opportunity.Id);
        
        // Instantiate a new controller with all parameters in the page
        controller = new SearchBusinessOpportunityController(); 
        
        ApexPages.currentPage().getParameters().put('id', ProductId);
        
        // Instantiate a new controller with all parameters in the page
        controller = new SearchBusinessOpportunityController ();        
        system.assertNotEquals(0, controller.listOpportunityWrapper.size());
        
        opportunity.FTF_Mileage__c = 'Over 200,000';
        Update opportunity;  
        ApexPages.currentPage().getParameters().put('id', ProductId);
        
        // Instantiate a new controller with all parameters in the page
        controller = new SearchBusinessOpportunityController ();                                
    }
    public static testMethod void testErrorAndExceptions() {
        PageReference pageRef = Page.SearchBusinessOpportunity ;
        Test.setCurrentPage(pageRef);
   
        SearchBusinessOpportunityController  controller = new SearchBusinessOpportunityController ();
        
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('id', userinfo.getuserid());
        
        // Instantiate a new controller with all parameters in the page
        controller = new SearchBusinessOpportunityController(); 
        controller.createFilterOfProduct(new Account());
        controller.createFilterOfOpportunity(new Account());
        controller.buildMultiSelectPicklistConditions(null,null);
        controller.buildMultiPicklistConditionsForSourceObject(null,null);
        controller.getFieldPaths(null,null);
        controller.getPumpSize(null,null);        
        controller.getNumberValueOfSourceField(null,null);       
        controller.convertCurrencyTextToInteger(null,null);
        controller.matchRangeValue(null,null);
        controller.matchRangeValue(113,'All');
        controller.matchRangeValue(123,'wrwer');


    }
	
}