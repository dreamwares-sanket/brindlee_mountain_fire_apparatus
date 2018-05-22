public class JonsmidamericaListViewBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful{
    
    public List<String> pageUrlList = new List<String>();
    public List<String> pageUrlCountList = new List<String>();
    public String siteId = '';
    
    public JonsmidamericaListViewBatch(String pageUrl, String siteId) {    
        pageUrlList.add(pageUrl);
        this.siteId = siteId;
    }
    
    public Iterable<String> start(Database.BatchableContext BC) {
        return pageUrlList;
    }
    
    public void execute(Database.BatchableContext bc, List<String> urlList){
        
        for(String endPoint :urlList){
            
            pageUrlCountList.addAll(parseResponse(SiteCalloutHelper.getHtmlBody(endPoint+'/used-fire-trucks/'), endPoint));    
        }  
    }
    
    public void finish(Database.BatchableContext BC){
         
        if(!pageUrlCountList.isEmpty()){
            
            Database.executeBatch(new JonsmidamericaDetailPageUrlBatch(pageUrlCountList, siteId), 1);
        }
    }
    
    private static Set<String> parseResponse(HTTPResponse httpResponse, String endPoint){
        
        Set<String> urlSet = new Set<String>();
        
        if(httpResponse != null && String.isNotBlank(endPoint)){
            
            urlSet.add(endPoint+'/used-fire-trucks/page/1/');            
            String pageCountTag = httpResponse.getBody().substringBetween('page-numbers', '</ul>');
            
            List<String> pageCountList = String.isNotBlank(pageCountTag) ? pageCountTag.split('<a'): new List<String>();
                        
            if(!pageCountList.isEmpty()){
                
                for(String pageCount: pageCountList){
                    
                    String pageUrl = pageCount.substringBetween('href=\'','\'');
                    if(String.isNotBlank(pageUrl)){
                        urlSet.add(pageUrl); 
                    }
                }
            }
        }
        return urlSet;
    }    
}