public class ExternalTruckDetailViewLinkBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful{
    
    public List<String> pageUrlList = new List<String>();
    public Set<String> detailPageUrlList = new Set<String>();
    public String siteId = '';
    
    public ExternalTruckDetailViewLinkBatch(List<String> pageUrls, String siteId) {    
        pageUrlList.addAll(pageUrls);
        this.siteId = siteId;
    }
    
    public Iterable<String> start(Database.BatchableContext BC) {
        return pageUrlList;
    }   
    
    public void execute(Database.BatchableContext bc, List<String> urlList){
        
        for(String endPoint :urlList){
            
            detailPageUrlList.addAll(parseResponse(SiteCalloutHelper.getHtmlBody(endPoint), endPoint));    
        } 
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('detailPageUrlList size ::::'+detailPageUrlList.size());
        if(!detailPageUrlList.isEmpty()){
            
            Database.executeBatch(new ExternalTruckDetailPageBatch(detailPageUrlList, siteId ),1);  
        }    
    }
       
    private static List<String> parseResponse(HTTPResponse httpResponse, String endPoint){
        
        List<String> pageUrlList = new List<String>();
        
        if(String.isNotBlank(endPoint) && httpResponse != null){
            
            List<String> recordUrlBlockList = httpResponse.getBody().substringAfterLast('<div class="stm-isotope-sorting stm-isotope-sorting-list">').
                                                substringBeforeLast('<div class="stm_ajax_pagination stm-blog-pagination">').
                                                removeEndIgnoreCase('</div>').split('<div class="title heading-font">');
            
            for(Integer index = 1; index < recordUrlBlockList.size(); index++){            
                pageUrlList.add(recordUrlBlockList[index].substringBetween('<a href="', '"'));    
            }
            System.debug('pageUrlList :::::'+pageUrlList);          
        }
        return pageUrlList;
    }
}