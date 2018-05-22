/*
 * @description - Test class for controllers of visual force components
 * @createdDate - 11-09-2015
 * @createdBy - Dreamwares
 */
@isTest
public class BrindleeMountainComponentControllersTest {
    
    @isTest
    public static void BMFAHeaderControllerTest(){
        CompanyContactInformation__c objCustomSetting = new CompanyContactInformation__c(Name='BMFA Contact Information');
        insert objCustomSetting;
        BrindleeMountainHeaderController con = new BrindleeMountainHeaderController();
        System.assertNotEquals(null,con.companyContactInfo);
    }
    
    @isTest
    public static void BMFAMenuControllerTest(){
        BrindleeMountainMenuController con = new BrindleeMountainMenuController();
        System.assertNotEquals(null,con.listCategoryUrlCodes);
        System.assertNotEquals(null,con.listEquipmentTypeUrlCodes);
        
        System.assertNotEquals(null,con.listCategoryUrlCodes);
        System.assertNotEquals(null,con.listEquipmentTypeUrlCodes);
    }
}