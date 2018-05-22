public class fentonFireDetailPageUrlBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful{
    
    Public List<String> pageUrlList = new List<String>();
    public Map<String, String> pageUrlToCategoryMap = new Map<String, String>();
    public String siteId = '';
    
    public fentonFireDetailPageUrlBatch(List<String> pageUrls, String siteId) {    
        pageUrlList.addAll(pageUrls);
        this.siteId = siteId;
    }
    
    public Iterable<String> start(Database.BatchableContext BC) {
        return pageUrlList;
    }
    
    public void execute(Database.BatchableContext bc, List<String> urlList){
        
        for(String endPoint :urlList){   
            System.debug('endPoint:'+endPoint);
            pageUrlToCategoryMap.putAll(parseResponse(getHtmlBody(endPoint), endPoint.subStringBetween('category/','?')));    
        }
    }    
    
    public void finish(Database.BatchableContext BC){
        
        if(!pageUrlToCategoryMap.isEmpty()){       
            List<String> urlList = new List<String>();
            urlList.addAll(pageUrlToCategoryMap.keySet());
            Database.executeBatch(new fentonFireTruckInfoBatch(urlList, pageUrlToCategoryMap, siteId), 1);
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
    
    private static Map<String, String> parseResponse(HTTPResponse httpResponse, String category){
        
        Map<String, String> pageUrlToCategoryMap = new Map<String, String>();
        Integer index = 0;
        Integer pageCount = 1;
        
        if(httpResponse != null){
            
            List<String> rowList = httpResponse.getBody().split('<div class="col-md-4 col-sm-6">');
            System.debug('rowList::'+rowList);
            
            if(rowList != null){
                
                for(String row: rowList){
                   System.debug('index::'+index+ 'row::'+row);
                    if(index > 0){
                        System.debug('category::'+category);
                        pageUrlToCategoryMap.put(row.subStringBetween('href="','"'),category);
                    }                    
                    index ++;    
                }
            }
        }  System.debug('pageUrlToCategoryMap::'+pageUrlToCategoryMap);      
        return pageUrlToCategoryMap;
    }    
}