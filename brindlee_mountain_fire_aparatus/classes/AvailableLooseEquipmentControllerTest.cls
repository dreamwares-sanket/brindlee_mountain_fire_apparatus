/*
 Test class for Available Loose EquipmentController
 @createdDate   2016/09/16
 @author        Dreamwares
 */
@isTest
public class AvailableLooseEquipmentControllerTest{
    
    @isTest
    private static void testRecord(){
        Product2 product = new Product2( Name='Test', Equipment_Price__c=1200, Loose_Equipment_Type__c='Rescue Tools',
                                         Equipment_Status__c='Active', Description='Test' );
        insert product;
        
        List<DragDropToCloud__Cloud_Documents__c> listCloudDocs = new List<DragDropToCloud__Cloud_Documents__c>();
        listCloudDocs.add( new DragDropToCloud__Cloud_Documents__c(
                                Show_Online__c = True,
                                Product__c = product.Id,
                                Main_Image__c = True,
                                name = 'Test'
                            ));
        listCloudDocs.add( new DragDropToCloud__Cloud_Documents__c(
                                Show_Online__c = True,
                                Product__c = product.Id,
                                Main_Thumbnail__c = True,
                                name = 'Test'
                            ));
        
        
        insert listCloudDocs;
        insert new CompanyContactInformation__c(Name='BMFA Contact Information');
        insert new AWS_Credentials__c(Name='Test', AccessKeyId__c='HBAVSJVANMBNASBN', BucketId__c='00dhw87echJs3', SecretAccessKey__c='jshdfkzz89898hlkdj/8934sdjnfn' );
        
        PageReference pageRef = Page.AvailableLooseEquipments;
        Test.setCurrentPage(pageRef);
        pageRef.getparameters().put('price', '0-10000');
        pageRef.getparameters().put('category', 'Rescue-Tools');
        
        AvailableLooseEquipmentController con = new AvailableLooseEquipmentController(new ApexPages.StandardController(product));
        System.assertNotEquals(null, con.availableLooseEquipmentsUrl);
        System.assertNotEquals(null, con.getLoginCredentials());
        System.assertNotEquals(null, con.getCompanyContactInfo());
    }
    
}