/*
 * @description - Test class for VF page controller RecentDeliveriesController used to display
                  details of sold truck.
 * @dateCreated - 21/08/2015
 * @createdBy   - Dreamwares
 */
@isTest
public class RecentDeliveriesControllerTest {
    
    @testSetup
    public static void testRecords(){
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
        
        List< Product2 > listProducts = new List< Product2 >();
        Product2 objProduct;
        Date dateToday = Date.today();
        for( integer i=0 ;i < 72 ; i++ ){
            objProduct = new Product2();
            objProduct.Fire_Truck__c = fireTruck.Id;
            objProduct.Name = 'Truck no. '+ i;
            objProduct.Stock_Number__c = 'STK#' + i;
            objProduct.Status__c = 'Sold';
            objProduct.Post_To_Website__c = True;
            objProduct.Seller_Contact__c = testCon.Id;
            objProduct.Posting_Date__c = System.today().addDays(-7);
            objProduct.IsActive = True;
            objProduct.Warranty_Terms__c = 'Warranteed';
            objProduct.TypeOfSale__c = 'Broker';
            objProduct.Blue_Date__c = dateToday;
            objProduct.Sold_to_Customer_Account__c = customerAcc.Id;
            listProducts.add(objProduct);
        }
        insert listProducts;
    }
    
    @isTest
    public static void testController(){
        
        RecentDeliveriesController controller = new RecentDeliveriesController();
        controller.initializeProductList();
        System.assertNotEquals(null,controller.setCon);
        System.assertEquals(24,controller.getProducts().size());
    }
    
    @isTest
    public static void testControllerpages(){
        RecentDeliveriesController controller = new RecentDeliveriesController();
        System.assertEquals(3,controller.getTotalPages());  // TotalRec/ defaultPagesize
        System.assertEquals(True,controller.setCon.gethasNext());
        
        PageReference VFpage = Page.recentDeliveries;
        Test.setCurrentPage(VFpage);
        controller.initializeProductList();
        //Negative testing for page number
        ApexPages.Currentpage().getParameters().put('pagenumber','11');
        controller.gotoPageNumber();
        System.assertEquals(3,controller.setCon.getPageNumber());
        
        //Positive testing for page number
        ApexPages.Currentpage().getParameters().put('pagenumber','2');
        controller.gotoPageNumber();
        System.assertEquals(2,controller.setCon.getPageNumber());
        
        controller.showFirstPage();
        System.assertEquals(1,controller.setCon.getPageNumber());
        
        controller.showLastPage();
        System.assertEquals(3,controller.setCon.getPageNumber());
        
        controller.showPreviousPage();
        System.assertEquals(2,controller.setCon.getPageNumber());
        
        controller.showNextPage();
        System.assertEquals(3,controller.setCon.getPageNumber());
        
        System.assertNotEquals(null,controller.pageNumber);
        System.assertNotEquals(null,controller.hasNext);
        System.assertNotEquals(null,controller.hasPrevious);
    }
    
    @isTest
    public static void testException(){
        delete [Select Id FROM Product2];
        RecentDeliveriesController controller = new RecentDeliveriesController();
        controller.gotoPageNumber();
    }
    
     @isTest
    public static void testChacheList(){
        delete [Select Id FROM Product2];
        RecentDeliveriesController controller = new RecentDeliveriesController();
        controller.initializeProductList();
        List< Product2 >listTestProduct = (List< Product2 >)controller.setCon.getRecords();
    }
}