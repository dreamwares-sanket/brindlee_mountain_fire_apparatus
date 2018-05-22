/*
 * @description - Test class for AvailableTruckDetailViewController used to display
                  details of truck for page AvailableTruckDetailView
 * @dateCreated - 10/09/2015
 * @createdBy   - Dreamwares
 */
@isTest
public class SearchResultsControllerTest {
    
    @testSetup
    public static void setupRecords(){
        
        //create five products
        List< Product2 > listProducts = new List< Product2 >();
        Product2 objProduct;
        for( integer i=0 ;i < 20 ; i++ ){
            objProduct = new Product2();
            objProduct.Name = 'Truck no. '+ i;
            objProduct.Stock_Number__c = '000' + i;
            objProduct.Post_To_Website__c = True;
            objProduct.apparatusType__c = 'Used Pumper and Engines';
            objProduct.status__c='Available';
            if( i>=10){
                objProduct.mainDescription__c = '6kw 1500 gallons ';
            }
            listProducts.add(objProduct);
        }
        insert listProducts;
    }
    
    @isTest
    public static void testSearchCriterias(){
        PageReference pageRef = Page.SearchResults;
        Test.setCurrentPage(pageRef);
        
        // test result on stock number
        ApexPages.currentPage().getParameters().put('search','0001');
        SearchResultsController con = new SearchResultsController();
        ApexPages.currentPage().getParameters().put('search','6kw');
        con = new SearchResultsController();
        System.assertEquals(10, con.listProducts.size());
    }
    
    @isTest
    public static void testSearchStockNumber(){
         
        Product2 objProduct = [SELECT Id, Stock_Number__c FROM Product2 LIMIT 1];
        PageReference pageRef = Page.Searchresults;
        Test.setCurrentPage( pageRef );
        ApexPages.Currentpage().getParameters().put('stockNo', objProduct.Stock_Number__c );
        SearchResultsController controller = new SearchResultsController();
        System.assert( controller.strMessage.contains( 'Are you searching for one of these?' ));
        
        // test for no results
        ApexPages.Currentpage().getParameters().put('stockNo', '0999' );
        controller = new SearchResultsController();
        System.assert( controller.strMessage.contains( 'No results found' ));
        
        //test for blank search string
        ApexPages.Currentpage().getParameters().put('stockNo', '' );
        controller = new SearchResultsController();
        System.assert( controller.strMessage.contains( 'Please enter a search query' ));
    }
    
    @isTest
    private static void testLooseEqpmnts(){
        List<Product2> listProducts = new List<Product2>();
        Product2 objProduct;
        
        Id recType = Utilities.getProductRecordTypeId('Loose Equipment');
        for( integer i=0 ;i < 20 ; i++ ){
            objProduct = new Product2();
            objProduct.Name = 'Loose Equipment no. '+ i;
            objProduct.Description = 'Test Equipment';
            objProduct.RecordTypeId = recType;
            objProduct.Equipment_Status__c = 'Active';
            listProducts.add(objProduct);
        }
        insert listProducts;
        
        Test.startTest();
        PageReference pageRef = Page.SearchResults;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('search','Equipment');
        SearchResultsController con = new SearchResultsController();
		Test.stopTest();        

        System.assertEquals( 20, con.listLooseEquipments.size());
    }
}