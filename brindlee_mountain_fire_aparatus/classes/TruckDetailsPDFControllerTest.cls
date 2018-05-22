/*
* @description - Test class for TruckDetailsPDFController
* @dateCreated - 10/09/2015
* @createdBy   - Dreamwares
*/
@isTest
public class TruckDetailsPDFControllerTest {
    
    @testSetup
    public static void setupRecords(){
        //insert Custom settings
        insert new CompanyContactInformation__c(Name='BMFA Contact Information');
        
        Product2 objProduct = new Product2();
        objProduct.Name = 'Truck no. 1';
        objProduct.Stock_Number__c = 'STK#1';
        objProduct.Post_To_Website__c = True;
        objProduct.apparatusType__c = 'Used Pumper and Engines';
        insert objProduct;
        
        List< DragDropToCloud__Cloud_Documents__c > listDocs = new List< DragDropToCloud__Cloud_Documents__c >();
        DragDropToCloud__Cloud_Documents__c objDoc;
        for( integer i =0 ; i < 4 ; i++ ){
            objDoc = new DragDropToCloud__Cloud_Documents__c();
            objDoc.Product__c = objProduct.Id;
            objDoc.DragDropToCloud__Folder_Id__c = 'testFolder';
            objDoc.Name = 'CloudDoc_' + objProduct.name + '_'+i;
            objDoc.Show_Online__c = True;
            listDocs.add(objDoc);
        }
        listDocs[0].Main_Image__c = True;
        listDocs[1].Main_Thumbnail__c = True; 
        insert listDocs;
    }
    
    @isTest
    public static void testController(){
        Product2 product = [SELECT ID FROM Product2 LIMIT 2];
        TruckDetailsPDFController con = new TruckDetailsPDFController( new ApexPages.StandardController(product));
        System.assertNotEquals(null, con.strMainImageURL);
        System.assertNotEquals(null, con.companyContactInfo);
        //System.assertNotEquals(null, con.listRequiredCloudDocuments);
    }
}