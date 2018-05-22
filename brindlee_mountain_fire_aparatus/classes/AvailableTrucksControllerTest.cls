/*
 * @description - Controller class for VF page AvailableTrucksController used to sort 
 *                results depending on criteria
 * @dateCreated - 17/08/2015
 * @createdBy   - Dreamwares
 */
@isTest
public class AvailableTrucksControllerTest {
    
    @testSetup
    public static void setupRecords(){
        Fire_Truck__c fireTruck = new Fire_Truck__c();
        fireTruck.Main_Title__c = 'new Truck';
        fireTruck.Year_of_Truck__c = 2013;
        fireTruck.Mileage__c = 8000;
        fireTruck.Pump_GPM__c = '1750';
        fireTruck.Fire_Body_Manufacturer__c = 'E-One';
        fireTruck.Chassis_Manufacturer__c = '3D';
        insert fireTruck;
        
        Account testAcc = new Account(name='test Account');
        insert testAcc;
        
        Account customerAcc = new Account(name='Customer Account');
        insert customerAcc;
        
        Contact testCon = new Contact();
        testCon.lastName = 'Test Contact';
        testCon.pi__url__c ='https://pi.pardot.com/prospect/read?id=13322';
        testCon.AccountId = testAcc.Id;
        insert testCon;
        
        List< Product2 > listProducts = new List<Product2>();
        Product2 product;
        for( integer i=0;i<10;i++ ){
            product = new Product2();
            product.Fire_Truck__c = fireTruck.Id;
            product.Seller_Contact__c = testCon.Id;
            product.Sold_to_Customer_Account__c = customerAcc.Id;
            if( i<5 ){  //set 1
                
                product.Website_Price__c = '$40,000';
                //Updated on 11/14/2015 to support Fire Truck object
                //product.Year_of_Truck__c = 1990;
                //product.Custom_Commercial__c = 'Custom';
                //product.Fire_Truck_Manufacturer__c = 'Ferrara';
                //Updated Custom_Commercial__c and Fire_Truck_Manufacturer__c on 11/24/215 to support Fire Truck object (mgd)
                //Updated on 11/14/2015 to support Fire Truck object
                //product.Pump_GPM__c = '250 GPM';
                //product.Water_Tank_Size_only__c  = '500';
                product.apparatusType__c = 'Used ARFF and Airport Crash Trucks';
                product.Warranty_Terms__c = 'test';     // Warranty for trucks
                
            }
            else if( i>=5 ){    // set 2
                product.Website_Price__c = '$120,000';
                //Updated on 11/14/2015 to support Fire Truck object
                //product.Year_of_Truck__c = 2001;
                //product.Custom_Commercial__c = 'Commercial';
                //product.Fire_Truck_Manufacturer__c = 'KME';
                //Updated on 11/14/2015 to support Fire Truck object
                //product.Pump_GPM__c = '750 GPM';
                product.apparatusType__c = 'Vocational Trucks';
                //product.Water_Tank_Size_only__c  = '1500';
            }
            product.IsActive = True;
            product.Post_To_Website__c = True;
            product.Stock_Number__c = ''+i;
            product.Name = 'Truck no.'+i;
            product.status__c = 'Available';
            listProducts.add(product);
        }
        insert listProducts;
        //System.debug('listProducts1:'+listProducts);
        listProducts = new List<product2>([SELECT VF_Sort_By_Tank_Size__c FROM Product2]);
        //System.debug('listProducts2:'+listProducts);
        
        //List< Meta_Data_for_Categories__c > listMetaData = new List< Meta_Data_for_Categories__c >();
        Meta_Data_for_Categories__c objMetaData = new Meta_Data_for_Categories__c();
        objMetaData.Category__c = 'Used ARFF and Airport Crash Trucks';
        objMetaData.Description__c = 'Used ARFF and Airport Crash Trucks';
        objMetaData.Title__c = 'Used ARFF and Airport Crash Trucks';
        objMetaData.Name = '1';
        insert objMetaData;
    }
    
    @isTest
    public static void controllerTestFirstSet(){
        
        PageReference pageRef = Page.AvailableTrucks;
        Test.setCurrentPage(pageRef);
        Map<String, String> mapPageParams = Apexpages.currentPage().getParameters();
        mapPageParams.put('category','ARFF-Airport-Crash-Trucks');
        mapPageParams.put('price','40000');
        mapPageParams.put('year','1990');
        mapPageParams.put('brand','Ferrara');
        mapPageParams.put('pumpsize','250');
        mapPageParams.put('tanksize','500');
        mapPageParams.put('chassis','Custom');
        mapPageParams.put('warranty','yes');
        mapPageParams.put('mileage','Over 15,000');
        AvailableTrucksController con = new AvailableTrucksController();
        //System.assertEquals(5, con.listAllProducts.size());  // commented by Matt on 10/28/2015

    }
    
    @isTest
    public static void controllerTestSecondSet(){
        
        PageReference pageRef = Page.AvailableTrucks;
        Test.setCurrentPage(pageRef);
        Map<String, String> mapPageParams = Apexpages.currentPage().getParameters();
        mapPageParams.put('category','Vocational-Trucks');
        mapPageParams.put('price','0-120000');
        mapPageParams.put('year','1970-2001');
        mapPageParams.put('brand','KME');
        mapPageParams.put('pumpsize','0-1000');
        mapPageParams.put('mileage','Under 15,000');
        mapPageParams.put('region','Africa');
        mapPageParams.put('tanksize','1500');
        mapPageParams.put('chassis','Commercial');
        mapPageParams.put('warranty','no');
        AvailableTrucksController con = new AvailableTrucksController();
        //System.assertEquals(5, con.listAllProducts.size());   // commented by Matt on 10/28/2015
    }
    
    @isTest
    public static void testRandomProducts(){
        PageReference pageRef = Page.AvailableTrucks;
        Test.setCurrentPage(pageRef);
        AvailableTrucksController con = new AvailableTrucksController();
        System.assertEquals(6, con.getRandomProducts().size()); // commented by Matt on 10/28/2015
        System.assertNotEquals(null, con.getBrands());
        System.assertNotEquals(null, con.getPriceOptions());
        System.assertNotEquals(null, con.getCategories()); 
        System.assertNotEquals(null, con.getChassisTypes());
        System.assertNotEquals(null, con.getPumpSizeRanges());
        System.assertNotEquals(null, con.getTankSizeRanges());
        System.assertNotEquals(null, con.getYearOptions()); 
        System.assertNotEquals(null, con.getWarrantyOptions());
        System.assertNotEquals(null, con.getMileageOptions()); 
        System.assertNotEquals(null, con.getGeographicRegions());
    }
    
    @isTest
    public static void testCategory(){
        PageReference pageRef = Page.AvailableTrucks;
        Test.setCurrentPage(pageRef);
        AvailableTrucksController con = new AvailableTrucksController();
        con.selCategory = 'Vocational-Trucks';
        con.changeCategoryPage();
    }
    
    @isTest
    public static void testPicklistSelections(){
        AvailableTrucksController con = new AvailableTrucksController();
        con.resetRecordsList();
        System.assertNotEquals(null, con.getCanonicalCategory());
    }
}