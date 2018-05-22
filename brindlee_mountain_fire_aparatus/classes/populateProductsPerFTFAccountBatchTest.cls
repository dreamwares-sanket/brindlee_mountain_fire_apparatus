@isTest
public class populateProductsPerFTFAccountBatchTest {

    @testSetup 
    static void setupTestData(){
        
        Fire_Truck__c fireTruck = new Fire_Truck__c();
        fireTruck.Year_of_Truck__c = System.Today().year();
        fireTruck.Four_By_Four__c = false;
        fireTruck.Mileage__c = 8000;
        fireTruck.Pump_GPM__c = '250';
        fireTruck.Fire_Body_Manufacturer__c = '3D';
        fireTruck.Chassis_Manufacturer__c = '3D';
        fireTruck.Custom_Commercial__c ='Commercial';
        fireTruck.Pump_GPM__c='225 GPM';
        fireTruck.Water_Tank_Size_only__c = '225';
        fireTruck.Disable_VIN_Validation__c = true;
        
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
        
        Account testAccount = new Account ( Name = 'testAccount' );
        insert testAccount;
        
        Dealer_FTF_Account__c dealerAcc = new Dealer_FTF_Account__c ( Dealer__c = testAccount.Id, Dealer_Status__c = 'Active', Dealer_Email__c = 'abc1@gmail.com',
                                                                      Dealer_Language_Code__c = 'en' );
        insert dealerAcc;
        
        Dealer_FTF_Truck__c ftfTruck = new Dealer_FTF_Truck__c( Dealer_FTF_Account__c = dealerAcc.Id,
                                                                Truck__c = listProducts[0].Id );        
        INSERT ftfTruck;
            
        Dealer_FTF_Truck_Criteria__c criteria1 = new Dealer_FTF_Truck_Criteria__c ( Dealer_FTF_Account__c = dealerAcc.Id, 
                                                                                    Truck_Year_Min__c = System.Today().year(), 
                                                                                    Truck_Year_Max__c = System.Today().year(),
                                                                                    Truck_Price_Min__c = 100,
                                                                                    Truck_Price_Max__c = 1000);
        insert    criteria1;      

        Dealer_FTF_Truck_Criteria__c criteria2 = new Dealer_FTF_Truck_Criteria__c ( Dealer_FTF_Account__c = dealerAcc.Id, 
                                                                                    Apparatus_Type__c = 'Used Pumpers and Engines',
                                                                                    Truck_Warranty__c = 'Included' );
        insert  criteria2; 
        
        Dealer_FTF_Truck_Criteria__c criteria3 = new Dealer_FTF_Truck_Criteria__c ( Dealer_FTF_Account__c = dealerAcc.Id, 
                                                                                    Apparatus_Type__c = 'Used Pumpers and Engines',
                                                                                    Truck_Warranty__c = 'Not Included' );
        insert  criteria3;
    }
    
    public static testMethod void testScheduler() {
                
        test.startTest();
        
        populateProductsPerFTFAccountBatch obj = new populateProductsPerFTFAccountBatch();       
        
        obj.execute(null);
        test.stopTest();
        
        Dealer_FTF_Account__c dealerAcc = [ SELECT Dealer_Truck_Details__c
                                            FROM Dealer_FTF_Account__c
                                            LIMIT 1 ];
        
        List<String> idList = new List<String>();
        
        for( String prodId : dealerAcc.Dealer_Truck_Details__c.split(',')){
            idList.add(prodId);
        }
        
        System.assert( !idList.isEmpty() );
    }            
}