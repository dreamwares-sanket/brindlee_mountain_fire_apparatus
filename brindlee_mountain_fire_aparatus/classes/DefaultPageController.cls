/**
 *  className  DefaultPageController  
 *  createdBy  Amol[Dreamwares]
 *  purpose  Default Homepage page controller that will show recently added 32 trucks
 *  createdOn  21-8-2015
 */
public class DefaultPageController {
    public transient List<Product2>listRecentlyAddedTrucks { get; set; }
    private PlatformCacheController cacheController = new PlatformCacheController();

    public DefaultPageController(){
    }
    
    public void initializeProductsList(){
        listRecentlyAddedTrucks = new List<Product2>();
        listRecentlyAddedTrucks  = cacheController.getPlatformCahche('default');//get list from platform cahce
        
        if(listRecentlyAddedTrucks  == null ||listRecentlyAddedTrucks.isEmpty()){          
            try {    // get the recently added trucks where Stock_Number__c and Post_To_Website__c is not null 
                listRecentlyAddedTrucks  = [SELECT Id, VF_Main_Title__c, Description, 
                                              ( SELECT Id, Main_Thumbnail__c, DragDropToCloud__Folder_Id__c, Product__c, Amazon_S3_Image_URL__c, Amazon_S3_Main_Thumbnail_URL__c  
                                                FROM Cloud_Documents__r
                                                WHERE Main_Thumbnail__c = True AND
                                                      Show_Online__c = True LIMIT 1)
                                            FROM Product2 
                                            WHERE Stock_Number__c != null
                                             AND IsActive = True 
                                             AND Post_To_Website__c = True
                                             AND status__c IN ('Available','HOD','Internal HOD','On Lease')
                                            ORDER BY CreatedDate DESC
                                            LIMIT 32];
            }
            catch (Exception ex){
                System.debug('Error Line:' + ex.getLineNumber() + ' Message: ' + ex.getMessage());
            }           
            cacheController.creaetPlatformCahche(listRecentlyAddedTrucks, 'default');
        }
        
    }
}