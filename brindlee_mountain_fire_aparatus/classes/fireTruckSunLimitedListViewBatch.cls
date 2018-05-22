public class fireTruckSunLimitedListViewBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful{
    
    public List<String> pageUrlList = new List<String>();
    public List<String> pageUrlCategoryList = new List<String>();
    public String siteId = '';
    
    public fireTruckSunLimitedListViewBatch(String pageUrl, String siteId) {    
        pageUrlList.add(pageUrl);
        this.siteId = siteId;
    }
    
    public Iterable<String> start(Database.BatchableContext BC) {
        return pageUrlList;
    }
    
    public void execute(Database.BatchableContext bc, List<String> urlList){
        
        for(String endPoint :urlList){
            
            pageUrlCategoryList.addAll(parseResponse(getHtmlBody(endPoint+'used-fire-trucks-for-sale/'), endPoint));    
        }  
    }
    
    public void finish(Database.BatchableContext BC){
        
        if(!pageUrlCategoryList.isEmpty()){
            
            Database.executeBatch(new fireTruckSunLimitedDetailPageListBatch(pageUrlCategoryList, siteId), 1);
        }
    }
    
    public static HTTPResponse getHtmlBody(String endPoint){
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('GET');
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        if(res.getStatusCode() == 301){
            
            String loc = res.getHeader('Location');
            req = new HttpRequest();
            req.setEndpoint(loc);
            req.setMethod('GET');
            res = http .send(req);

        }
        return res;
    }
    
    private static List<String> parseResponse(HTTPResponse httpResponse, String endPoint){
        
        List<String> urlList = new List<String>();
        
        if(httpResponse != null && String.isNotBlank(endPoint)){
            
            String pageMenuTag = httpResponse.getBody().substringBetween('<div class="help">', '</div>');
            List<String> menuList = String.isNotBlank(pageMenuTag) ? pageMenuTag.split('<a'): new List<String>();
                        
            if(!menuList.isEmpty()){
                
                for(String menu :menuList){
                    
                    String pageUrl = menu.substringBetween('href="','"');
                    
                    if(String.isNotBlank(pageUrl)){
                        urlList.add(endPoint.removeEndIgnoreCase('/')+pageUrl); 
                    }
                }
            }
        }
        return urlList;
    }    
}