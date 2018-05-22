public class JonsmidamericaDetailPageUrlBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful{
    
    public List<String> pageUrlList = new List<String>();
    public List<String> pageUrlCountList = new List<String>();
    public String siteId = '';
    
    public JonsmidamericaDetailPageUrlBatch(List<String> pageUrlCountList, String siteId){
     
        this.pageUrlCountList.addAll(pageUrlCountList);
        this.siteId = siteId;
    }
    
    public Iterable<String> start(Database.BatchableContext BC){
    
        return pageUrlCountList;
    }
    
    public void execute(Database.BatchableContext bc, List<String> urlList){
        
        for(String endPoint :urlList){
        
            System.debug('endPoint 22222 '+endPoint);
            pageUrlList.addAll(parseResponse(SiteCalloutHelper.getHtmlBody(endPoint), endPoint));    
        }  
    }
    
    public void finish(Database.BatchableContext BC){
        
        System.debug('pageUrlList 2222 '+pageUrlList);
        
        if(!pageUrlList.isEmpty()){                            
            Database.executeBatch(new JonsmidamericaDetailInfoBatch(pageUrlList, siteId), 1);
        }
    }
    
    private static Set<String> parseResponse(HTTPResponse httpResponse, String endPoint){
        
        Set<String> urlSet = new Set<String>();
        System.debug('httpResponse 2222 '+httpResponse);
        System.debug('endPoint 2222 '+endPoint);
        
        if(httpResponse != null && String.isNotBlank(endPoint)){
            
            String pageSectionTag = httpResponse.getBody().substringBetween('ALL PRODUCTS', '</section');
            
            List<String> truckSectionList = String.isNotBlank(pageSectionTag) ? pageSectionTag.split('<a'): new List<String>();
                      
            if(!truckSectionList.isEmpty()){
                
                for(String truckSection: truckSectionList){
                    
                    String pageUrl = truckSection.substringBetween('href="','"');
                    
                    if(String.isNotBlank(pageUrl)){
                        urlSet.add(pageUrl); 
                    }
                }
            }
        }
        System.debug('urlSet '+urlSet);
        return urlSet;
    }    
}