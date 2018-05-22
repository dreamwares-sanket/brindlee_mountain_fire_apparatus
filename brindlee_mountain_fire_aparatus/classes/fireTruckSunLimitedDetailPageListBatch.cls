public class fireTruckSunLimitedDetailPageListBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful{
    
    public List<String> pageUrlList = new List<String>();
    public List<String> pageUrlCategoryList = new List<String>();
    public String siteId = '';
    Map<String, String> siteToCategoryMap = new Map<String, String>();
    
    public fireTruckSunLimitedDetailPageListBatch(List<String> pageUrls, String siteId) {    
        pageUrlList.addAll(pageUrls);
        this.siteId = siteId;
    }
    
    public Iterable<String> start(Database.BatchableContext BC) {
        return pageUrlList;
    }
    
    public void execute(Database.BatchableContext bc, List<String> urlList){
        
        for(String endPoint :urlList){  
             
            List<String> tempList = parseResponse(getHtmlBody(endPoint), endPoint, siteToCategoryMap);  
            
            if(!tempList.isEmpty()){       
                pageUrlCategoryList.addAll(tempList);
            }    
        }     
    }
    
    public void finish(Database.BatchableContext BC){
        
        if(!pageUrlCategoryList.isEmpty()){  
            
            Database.executeBatch(new fireTruckSunLimitedDetailInfoBatch(pageUrlCategoryList, siteId, siteToCategoryMap), 1);
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
    
    private static List<String> parseResponse(HTTPResponse httpResponse, String endPoint, Map<String, String> siteToCategoryMap){
        
        List<String> urlList = new List<String>();
        Integer index = 0;
        
        if(httpResponse != null){
            
            String pageMenuTag = httpResponse.getBody().substringAfter('class="truck-loop-con"');
            List<String> menuList = String.isNotBlank(pageMenuTag) ? pageMenuTag.split('class="truck-item-con'): new List<String>();
            
            if(!menuList.isEmpty()){
                
                for(String menu :menuList){
                    
                    String pageUrl = menu.substringBetween('href="','"');
                    
                    if(String.isNotBlank(pageUrl) && index > 0){
                       
                        urlList.add(pageUrl);
                        siteToCategoryMap.put(pageUrl, endPoint.subStringBetween('used-fire-trucks-for-sale/','/'));
                        
                    }
                    index ++;
                }
            }
        }
        return urlList;
    }    
}