public class fentonFireListViewBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful{
    
    public List<String> pageUrlList = new List<String>();
    public List<String> pageUrlCategoryList = new List<String>();
    public String siteId = '';
    
    public fentonFireListViewBatch(String pageUrl, String siteId) {    
        pageUrlList.add(pageUrl);
        this.siteId = siteId;
    }
    
    public Iterable<String> start(Database.BatchableContext BC) {
        return pageUrlList;
    }
    
    public void execute(Database.BatchableContext bc, List<String> urlList){
        
        for(String endPoint :urlList){
            
            pageUrlCategoryList.addAll(parseResponse(getHtmlBody(endPoint)));    
        } 
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('pageUrlCategoryList ::::'+pageUrlCategoryList);
        if(!pageUrlCategoryList.isEmpty()){
            
            Database.executeBatch(new fentonfirePageCountBatch(pageUrlCategoryList, siteId), 1);
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
    
    private static List<String> parseResponse(HTTPResponse httpResponse){
        
        List<String> urlList = new List<String>();
        
        if(httpResponse != null){
            
            String pageMenuTag = httpResponse.getBody().substringBetween('<ul class="sidebar__menu">', '</ul>');
            
            List<String> menuList = String.isNotBlank(pageMenuTag) ? pageMenuTag.split('</li>'): new List<String>();
            
            if(!menuList.isEmpty()){
                
                for(String menu :menuList){
                    
                    String pageUrl = menu.substringBetween('href="','"');
                    
                    if(String.isNotBlank(pageUrl) && !pageUrl.equalsIgnoreCase('/')){
                        urlList.add(menu.substringBetween('href="','"')); 
                    } 
                }
            }
        }
        System.debug('urlList::::'+urlList);
        return urlList;
    }    
}