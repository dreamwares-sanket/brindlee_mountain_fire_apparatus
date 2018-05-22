/*
 * @description - Controller class for VF component BrindleeMountainMenu 
 * @dateCreated - 07/09/2015
 * @createdBy   - Dreamwares
 */
public with sharing class BrindleeMountainMenuController {
    
    public List<Utilities.CategoryURLCodeWrapper> listCategoryUrlCodes{
        get{
            if( listCategoryUrlCodes == null ){
                listCategoryUrlCodes = Utilities.getCategoryUrlcodesWrapperList(new Product2(),'apparatusType__c');
                return listCategoryUrlCodes;
            }
            return listCategoryUrlCodes;
        }
        set;
    }
    
    public List<Utilities.CategoryURLCodeWrapper> listEquipmentTypeUrlCodes{
        get{
            if( listEquipmentTypeUrlCodes == null ){
                listEquipmentTypeUrlCodes = Utilities.getCategoryUrlcodesWrapperList(new Product2(),'Loose_Equipment_Type__c');
                return listEquipmentTypeUrlCodes;
            }
            return listEquipmentTypeUrlCodes;
        }
        set;
    }
}