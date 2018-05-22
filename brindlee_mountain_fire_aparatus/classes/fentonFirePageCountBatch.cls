public class fentonFirePageCountBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful{
    
    public List<String> pageUrlList = new List<String>();
    public List<String> pageUrlCategoryList = new List<String>();
    public String siteId = '';
    
    public fentonFirePageCountBatch(List<String> pageUrls, String siteId) {    
        pageUrlList.addAll(pageUrls);
        this.siteId = siteId;
    }
    
    public Iterable<String> start(Database.BatchableContext BC) {
        return pageUrlList;
    }
    
    public void execute(Database.BatchableContext bc, List<String> urlList){
        
        for(String endPoint :urlList){
            
            pageUrlCategoryList.addAll(parseResponse(getHtmlBody(endPoint), endPoint));    
        }     
    }
    
    public void finish(Database.BatchableContext BC){
        
        if(!pageUrlCategoryList.isEmpty()){
            
            Database.executeBatch(new fentonfireDetailPageUrlBatch(pageUrlCategoryList, siteId), 1);
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
        Integer pageCount = 1;
        
        if(String.isNotBlank(endPoint) && httpResponse != null){
            
            Boolean pagination = httpResponse.getBody().contains('<div class="btn-group">');
            
            if(pagination ){
                pageCount = httpResponse.getBody().substringBetween('<div class="btn-group">', '</div>').countMatches('</li>');
            }
        
            for(Integer index = 1; index <= pageCount; index ++){
                
                urlList.add(endPoint+'?page='+index);
            }
        }        
        return urlList;
    }    
}