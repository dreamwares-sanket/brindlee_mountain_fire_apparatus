public class SiteCalloutHelper{
     
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
}