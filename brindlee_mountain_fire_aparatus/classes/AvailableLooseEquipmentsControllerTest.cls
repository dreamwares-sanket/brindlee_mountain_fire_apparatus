/*
 Test class for AvailableLooseEquipments vf page controller
 @createdDate   2016/09/16
 @author        Dreamwares
 */
@isTest
public class AvailableLooseEquipmentsControllerTest {
    
    @isTest
    private static void testRecords(){
        insert new Product2( Name='Test', Equipment_Price__c=1200, Loose_Equipment_Type__c='Rescue Tools',
                             Equipment_Status__c='Active', Description='Test', RecordTypeId=Utilities.getProductRecordTypeId('Loose Equipment'));
        
        PageReference pageRef = Page.AvailableLooseEquipments;
        Test.setCurrentPage(pageRef);
        pageRef.getparameters().put('price', '0-10000');
        pageRef.getparameters().put('category', 'Rescue-Tools');
        
        AvailableLooseEquipmentsController con = new AvailableLooseEquipmentsController();
        System.assertNotEquals(null, con.selMaxPrice);
        System.assertNotEquals(null, con.selMinPrice);
        System.assertNotEquals(null, con.selCategory);
        System.assertNotEquals(null, con.getCategoryCanonicalUrl());
        System.assertNotEquals(null, con.getPriceOptions());
        System.assertNotEquals(null, con.getCategoryOptions());
        
        con.resetAndFetchProductsByCriteria();
        con.getRandomProducts();
    }    
}