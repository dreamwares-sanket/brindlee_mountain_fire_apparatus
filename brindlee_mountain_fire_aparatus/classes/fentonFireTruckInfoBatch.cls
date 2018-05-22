public class fentonFireTruckInfoBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful{
    
    List<Competitor_Site_Truck__c> truckList = new List<Competitor_Site_Truck__c>();
    public Map<String, String> pageUrlToCategoryMap = new Map<String, String>();
    List<String> pageUrlList = new List<String>();
    public String siteId = '';
    
    public fentonFireTruckInfoBatch(List<String> pageUrlList, Map<String, String> pageUrlToCategoryMap, String siteId){
        
        this.pageUrlList.addAll(pageUrlList);    
        this.pageUrlToCategoryMap.putAll(pageUrlToCategoryMap);
        this.siteId = siteId;
    }
    
    public Iterable<String> start(Database.BatchableContext BC) {
        return pageUrlList;
    }
    
    public void execute(Database.BatchableContext bc, List<String> urlList){
        
        for(String endPoint :urlList){            
            truckList.add(parseResponse(getHtmlBody(endPoint), endPoint, pageUrlToCategoryMap, siteId));    
        }     
    }
    
    public void finish(Database.BatchableContext BC){
        
        if(!truckList.isEmpty()){            
            try{
                
                insert truckList;
                
                update new CompetitorSite__c(Id = siteId, Last_Record_Created_By_Batch__c = DateTime.now());
                
            }catch(Exception exp){
                System.debug('Exception ::::'+exp.getMessage());
            }
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
    
    private static Competitor_Site_Truck__c parseResponse(HTTPResponse httpResponse, String endPoint, Map<String, String> pageUrlToCategoryMap,
                                                          String siteId){
        
        Competitor_Site_Truck__c truckRecord = new Competitor_Site_Truck__c();
        
        if(httpResponse != null && String.isNotBlank(endPoint) && pageUrlToCategoryMap != null){ 
            System.debug('endPoint::'+endPoint);
            System.debug('pageUrlToCategoryMap::'+pageUrlToCategoryMap);
            String response = httpResponse.getBody();
            truckRecord.Category__c = pageUrlToCategoryMap.containsKey(endPoint) ? pageUrlToCategoryMap.get(endPoint).replaceAll('_', ' ') : '';
            //truckRecord.Description__c = pageUrlToCategoryMap.containsKey(endPoint) ? pageUrlToCategoryMap.get() : '';
            truckRecord.Stock__c = endPoint.substringAfterLast('/');
            truckRecord.Date_listed__c = Date.today();
            truckRecord.Competitor_Site__c = siteId;
            truckRecord.Truck_Public_Site_Url__c = endPoint;
            
            String dimensions = response.subStringBetween('<h2>Dimensions</h2>','</div>');
            
            if(String.isNotBlank(dimensions)){
                
                String mileage = String.isNotBlank(dimensions.subStringBetween('Mileage:','<br />')) ? dimensions.subStringBetween('Mileage:','<br/>') :
                                 String.isNotBlank(dimensions.subStringBetween('Mileage:','</p>')) ? dimensions.subStringBetween('Mileage:','</p>') :
                                 '';
                truckRecord.Mileage__c = String.isNotBlank(mileage) ? mileage.remove(',').trim().split(' ')[0] : '00.00';
            }
            
            String details = response.subStringBetween('<ul class="listing_details">','</ul>');
            if(String.isNotBlank(details)){
                String priceDetails = details.subStringBetween('Price:','</li>').subStringBetween('<div','</div>');
                priceDetails = String.isNotBlank(priceDetails) ? priceDetails.subStringAfter('<').remove('$').remove(',') : '';
                truckRecord.Asking_Price__c = String.isNotBlank(priceDetails) ? Decimal.valueOf(priceDetails.trim()) : 0;   
            }  
            
            // for description
            String description = response.subStringAfter('Vehicle overview');
            System.debug('description  11111 ::: '+description);
            System.debug('description  22222222 ::: '+description.substringBetween('<div class="wpb_wrapper">','</div>'));
            truckRecord.Description__c = String.isNotBlank(description) ? description.substringBetween('<div class="wpb_wrapper">','</div>'): description;
            
        }        
        return truckRecord;
    }    
}