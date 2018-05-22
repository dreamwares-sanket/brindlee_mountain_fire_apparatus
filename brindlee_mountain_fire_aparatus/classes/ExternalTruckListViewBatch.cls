public class ExternalTruckListViewBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful{
   
    public List<String> pageUrlList = new List<String>();
    Public List<String> pageUrlCategoryList = new List<String>();
    public String siteId = '';
    
    public ExternalTruckListViewBatch(String pageUrl, String siteId) {    
        pageUrlCategoryList.add(pageUrl);
        this.siteId = siteId;
    }
    
    public Iterable<String> start(Database.BatchableContext BC) {
        return pageUrlCategoryList;
    }   
    
    public void execute(Database.BatchableContext bc, List<String> urlList){
        
        for(String siteUrl :urlList){
            siteUrl = siteUrl +'inventory/';
            pageUrlList.addAll(parseResponse(SiteCalloutHelper.getHtmlBody(siteUrl), siteUrl));   
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
        System.debug('In Finish :::'+pageUrlList);
        if(!pageUrlList.isEmpty()){
            Database.executeBatch(new ExternalTruckDetailViewLinkBatch(pageUrlList, siteId));
        }
    }
    
    private static List<String> parseResponse(HTTPResponse httpResponse, String endPoint){
        
        Integer pageNo = 1;
        List<String> pageUrlList = new List<String>();
        
        if(String.isNotBlank(endPoint)){
        
            if(httpResponse != null){
                
                String pageNoTag = httpResponse.getBody().substringBetween('<ul class=\'page-numbers\'>', '</ul>');
                
                String pageNoStr = pageNoTag.substringAfterLast('<a class=\'page-numbers\' href=\'').substringBefore('</a>').substringAfter('>');
                pageNo = String.isNotBlank(pageNoStr) ? Integer.valueof(pageNoStr) : pageNo;
            }
            
            for(Integer index = 1; index <= pageNo; index ++){                
                pageUrlList.add(endPoint+'page/'+index+'/');    
            }
        }
        return pageUrlList;     
    }
}