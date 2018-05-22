/*
 * @description - Test class for DefaultPageController used to display
                  latest trucks
 * @dateCreated - 10/09/2015
 * @createdBy   - Dreamwares
 */
@isTest
public class DefaultPageControllerTest {
    
    @testSetup
    public static void testDefaultPageController(){
         //create five products
        List< Product2 > listProducts = new List< Product2 >();
        Product2 objProduct;
        for( integer i=0 ;i < 32 ; i++ ){
            objProduct = new Product2();
            objProduct.Name = 'Truck no. '+ i;
            objProduct.Stock_Number__c = 'STK#' + i;
            objProduct.Post_To_Website__c = True;
            objProduct.apparatusType__c = 'Used Pumper and Engines';
            objProduct.IsActive = True;
            listProducts.add(objProduct);
        }
        insert listProducts;
        
        DragDropToCloud__Cloud_Documents__c objDoc;
        List< DragDropToCloud__Cloud_Documents__c > listDocs = new List< DragDropToCloud__Cloud_Documents__c >();
        for( Product2 product : listProducts ){
            //create Cloud Document
            objDoc = new DragDropToCloud__Cloud_Documents__c();
            objDoc.Product__c = objProduct.Id;
            objDoc.DragDropToCloud__Folder_Id__c = 'testFolder';
            objDoc.Name = 'CloudDoc_' + product.name;
            objDoc.Show_Online__c = True;
            objDoc.Main_Thumbnail__c = True;
            listDocs.add( objDoc );
        }
        insert listDocs;
    }
    
    @isTest
    public static void testController(){
        DefaultPageController controller = new DefaultPageController();
        controller.initializeProductsList();
        controller.initializeProductsList();
    }
}