/**
 *  @className  NewsController 
 *  @createdBy  Dreamwares[Amol k]
 *  @createdOn  24 Aug 2015
 *  @purpose  Display news link on page 'News'
 */
public class NewsController {
    
    public transient List<In_The_News__c> listRecentNews { get; private set; }
    private PlatformCacheController cacheController = new PlatformCacheController();
    
    // Constructor
    public NewsController() {
        
    }
    
    public void initializeRecentNewsList() {

        listRecentNews = new List<In_The_News__c>();                      
         
        // fetch RecentNews from cache      
        listRecentNews = cacheController.getPlatformCahche('listRecentNews');//get list from platform cahce

        // if list not found in cache fetch it from database
        if(listRecentNews == null ||listRecentNews .isEmpty()){            
            // fetch recent 15 news
            try {
                listRecentNews =[SELECT Id, News__c FROM In_The_News__c 
                                 ORDER BY CreatedDate  DESC 
                                 LIMIT 15];
            }
            catch (Exception ex){
                System.debug('Error Line:' + ex.getLineNumber() + ' Message: ' + ex.getMessage());
            }  
            cacheController.creaetPlatformCahche(listRecentNews, 'listRecentNews');          
        }
    }
}