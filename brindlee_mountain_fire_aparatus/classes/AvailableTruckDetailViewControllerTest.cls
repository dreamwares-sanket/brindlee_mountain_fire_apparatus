/*
 * @description - Test class for AvailableTruckDetailViewController used to display
                  details of truck for page AvailableTruckDetailView
 * @createdDate - 10/09/2015
 * @createdBy   - Dreamwares
 * @lastModifiedDate - 26/4/2016
 */
@isTest
public class AvailableTruckDetailViewControllerTest {
    
    @testSetup
    public static void setupRecords(){
        //insert Custom settings
        insert new CompanyContactInformation__c(Name='BMFA Contact Information');
        
        Fire_Truck__c fireTruck = new Fire_Truck__c();
        fireTruck.Year_of_Truck__c = 2013;
        fireTruck.Mileage__c = 8000;
        fireTruck.Pump_GPM__c = '1750';
        fireTruck.Fire_Body_Manufacturer__c = 'E-One';
        fireTruck.Chassis_Manufacturer__c = '3D';
        insert fireTruck;
        
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
            // Removed on 11/14/2015 as Mileage now resides in Fire Truck
            //objProduct.Mileage__c = 8000;
            // Removed on 11/14/2015 as Pump GPM now resides in Fire Truck
            //objProduct.Pump_GPM__c = '1750';
            //objProduct.Fire_Truck_Manufacturer__c = 'E-One';
            // Removed Fire_Truck_Manufacturer__c as it now resides in Fire Truck
            // Removed on 11/14/2015 as Year of Truk now resides in Fire Truck
            //objProduct.Year_of_Truck__c = 2013;
            listProducts.add(objProduct);
        }
        insert listProducts;
        
        DragDropToCloud__Cloud_Documents__c objDoc;
        List< DragDropToCloud__Cloud_Documents__c > listDocs = new List< DragDropToCloud__Cloud_Documents__c >();
                
        //create cloud documents for products
        for( Product2 product : listProducts){
            
            for( integer i =0 ; i < 6 ; i++ ){
                objDoc = new DragDropToCloud__Cloud_Documents__c();
                objDoc.Product__c = product.Id;
                objDoc.DragDropToCloud__Folder_Id__c = 'testFolder';
                objDoc.Name = 'CloudDoc_' + product.name + '_'+i;
                objDoc.Show_Online__c = True;
                listDocs.add(objDoc);
            }
            listDocs[0].Main_Image__c = True;
            listDocs[1].Main_Thumbnail__c = True;
        }
        insert listDocs;
        
        List<Comment_Generation__c> listComments = new List<Comment_Generation__c>();
        
        Comment_Generation__c sceneLights = new Comment_Generation__c();
        sceneLights.Trigger_Word_Phrase__c = 'Scene Lights';
        sceneLights.Field_Label__c = 'Scene Lights';
        sceneLights.Condition__c = 'Not Empty';
        sceneLights.Comment__c = 'SceneLights';
        sceneLights.Field_API_Name__c = 'Scene_Lights__c';
        sceneLights.Include__c = True;
        listComments.add( sceneLights );
        
        Comment_Generation__c mileage = new Comment_Generation__c();
        mileage.Trigger_Word_Phrase__c = 'Mileage';
        mileage.Field_Label__c = 'Mileage';
        mileage.Condition__c = '0 - 10,000';
        mileage.Comment__c = 'Mileage from 0 to 10 k';
        mileage.Field_API_Name__c = 'FT_Mileage__c';
        mileage.Include__c = True;
        listComments.add( mileage );
        
        Comment_Generation__c pumpGPM = new Comment_Generation__c();
        pumpGPM.Trigger_Word_Phrase__c = 'GPM';
        pumpGPM.Field_Label__c = 'Pump GPM';
        pumpGPM.Condition__c = '1750';
        pumpGPM.Comment__c = 'PumpGPM equals 1750';
        pumpGPM.Field_API_Name__c = 'FT_Pump_GPM__c';
        pumpGPM.Include__c = True;
        listComments.add( pumpGPM );        
        
        Comment_Generation__c phaseSelected = new Comment_Generation__c();
        phaseSelected.Trigger_Word_Phrase__c = 'E-One';
        phaseSelected.Field_Label__c = 'FT - Fire Body Manufacturer';
        phaseSelected.Condition__c = 'Phase Selected';
        phaseSelected.Comment__c = 'Phase Selected E-One';
        phaseSelected.Field_API_Name__c = 'FT_Fire_Body_Manufacturer__c';
        phaseSelected.Include__c = True;
        listComments.add( phaseSelected );
        
        Comment_Generation__c yearOfTruck = new Comment_Generation__c();
        yearOfTruck.Trigger_Word_Phrase__c = 'Year';
        yearOfTruck.Field_Label__c = 'Year of Truck';
        yearOfTruck.Condition__c = '>2010';
        yearOfTruck.Comment__c = 'Phase Selected E-One';
        yearOfTruck.Field_API_Name__c = 'FT_Year_of_Truck__c';  //Updated on 11/14/2015 to support Fire Truck object
        yearOfTruck.Include__c = True;
        listComments.add( yearOfTruck );
        
        Comment_Generation__c yearOfTruck1 = new Comment_Generation__c();
        yearOfTruck1.Trigger_Word_Phrase__c = 'Year';
        yearOfTruck1.Field_Label__c = 'Year of Truck';
        yearOfTruck1.Condition__c = '<2015';
        yearOfTruck1.Comment__c = 'Phase Selected E-One';
        yearOfTruck1.Field_API_Name__c = 'FT_Year_of_Truck__c'; //Updated on 11/14/2015 to support Fire Truck object
        yearOfTruck1.Include__c = True;
        listComments.add( yearOfTruck1 );
        
        //Inactive comment
        Comment_Generation__c phaseSelected1 = new Comment_Generation__c();
        phaseSelected1.Trigger_Word_Phrase__c = 'E-One';
        phaseSelected1.Field_Label__c = 'Fire Body Manufacturer';
        phaseSelected1.Condition__c = 'Phase Selected';
        phaseSelected1.Comment__c = 'Phase Selected E-One';
        phaseSelected1.Field_API_Name__c = 'Fire_Truck_Manufacturer__c';
        phaseSelected1.Include__c = False;
        listComments.add( phaseSelected1 );
        
        insert listComments;
    }

   
	@isTest
    public static void testfetchSimilarProducts(){
        Product2 testProduct = [Select Id From Product2 LIMIT 1];
        AvailableTruckDetailViewController con = new AvailableTruckDetailViewController( new ApexPages.StandardController(testProduct));
        
        System.assertNotEquals(Null, con.getCompanyContactInfo());
        System.assertNotEquals(Null, con.strMainImageURL);        
        System.assertNotEquals(4, con.listSimilarProducts.size());
        con.getLoginCredentials();
    }
    
    @isTest
    public static void testCommentGeneration(){
        Product2 testProduct = [Select Id From Product2 LIMIT 1];
        ApexPages.StandardController stdCon = new ApexPages.StandardController(testProduct);
        AvailableTruckDetailViewController con = new AvailableTruckDetailViewController(stdCon);
        //System.assertEquals(2, con.listCommentsToDisplay.size());   // 6 active comments //Updated on 11/14/2015 to support Fire Truck object - changed from 6 to 2
    }
    
    @isTest
    public static void testPageRedirectUrlForPicklistValues(){
        Product2 product = [SELECT Id, Stock_Number__c, VF_Main_Title__c FROM Product2 LIMIt 1];
        String price = '0-50000', year = '2000', chassis = 'Commercial', brand = 'American LaFrance', pumpsize = '1500-2000',
               tanksize = '1800-2500', category= 'Aerials-Ladder-Trucks-Quints', warranty = 'False';
               
        String productUrlWithSearchParams = String.format('/AvailableTruck/{0}/{1}?price={2}&year={3}&chassis={4}&brand={5}&pumpsize={6}&tanksize={7}&category={8}&warranty={9}',
                                                          	new List<String>{ product.Stock_Number__c, product.VF_Main_Title__c, price, year,chassis, brand, pumpsize, tanksize, category, warranty });
        PageReference pageRef = new PageReference(productUrlWithSearchParams);
		test.setCurrentPage(pageRef);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(product);
        AvailableTruckDetailViewController con = new AvailableTruckDetailViewController(stdCon);
        System.assertNotEquals( null, con.AvailableTrucksUrl);
    }
    
    @isTest
    public static void testBlankPageParams(){
        Product2 product = [SELECT Id, Stock_Number__c, VF_Main_Title__c FROM Product2 LIMIt 1];
        PageReference pageRef = new PageReference('/AvailableTruck');
		test.setCurrentPage(pageRef);
        ApexPages.StandardController stdCon = new ApexPages.StandardController(product);
        AvailableTruckDetailViewController con = new AvailableTruckDetailViewController(stdCon);
        System.assertEquals( null, con.AvailableTrucksUrl);
    }
}