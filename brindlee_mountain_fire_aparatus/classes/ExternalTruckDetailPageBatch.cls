public class ExternalTruckDetailPageBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful{
    
    public List<String> pageUrlList = new List<String>();
    public List<Competitor_Site_Truck__c> truckList = new List<Competitor_Site_Truck__c>();
    public String siteId = '';
    
    public ExternalTruckDetailPageBatch(Set<String> pageUrls, String siteId) {    
        pageUrlList.addAll(pageUrls);
        this.siteId = siteId;
    }
    
    public Iterable<String> start(Database.BatchableContext BC) {
        return pageUrlList;
    }   
    
    public void execute(Database.BatchableContext bc, List<String> urlList){
        
        for(String endPoint :urlList){
            System.debug('0000000 endPoint  ::::'+endPoint);
            truckList.add(parseResponse(getHtmlBody(endPoint), siteId, endPoint));    
        } 
    }
    
    public void finish(Database.BatchableContext BC){
        
        if(!truckList.isEmpty()){
            try{
                
                insert truckList;
                
                update new CompetitorSite__c(Id = siteId, Last_Record_Created_By_Batch__c = DateTime.now());
            }catch(Exception exp){            
                System.debug('Exception :::'+exp.getMessage());
            }
        }   
    }
    
    public static HTTPResponse getHtmlBody(String endPoint){
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('GET');
        
        Http http = new Http();
        // HTTPResponse res = http.send(req);
        return http.send(req);
    }
    
    private static Competitor_Site_Truck__c parseResponse(HTTPResponse httpResponse,  String siteId, String endPoint){
        
        Competitor_Site_Truck__c siteTruck = new Competitor_Site_Truck__c();
        List<String> tableDataList = new List<String>();
        
        if(httpResponse != null){
            
            String pageHtml = httpResponse.getBody();
            String price = pageHtml.substringAfterLast('<div class="single-regular-price').
                                        substringAfter('<span class="h3">').substringBefore('</span>').split(' ')[0].remove(','); 
                                        
            siteTruck.Asking_Price__c = String.isNotBlank(price) ? Decimal.valueof(price) : 0.0;                           
            siteTruck.Competitor_Site__c = siteId;
            siteTruck.Truck_Public_Site_Url__c = endPoint;
            
            String location = pageHtml.substringBetween('Unit Location:', '</span>');
            siteTruck.Location__c =  string.isNotBlank(location) ? location.subStringAfter('span>') : '';  
            
              // for description
            String description = pageHtml.subStringAfter('Vehicle overview');
            System.debug('description  11111 ::: '+description);
            System.debug('description  22222222 ::: '+description.substringBetween('<div class="wpb_wrapper">','</div>'));
            siteTruck.Description__c = String.isNotBlank(description) ? description.substringBetween('<div class="wpb_wrapper">','</div>'): description;
              
            // for title
            siteTruck.Main_Title__c =  pageHtml.subStringBetween('<h1 class="title h2">','</h1>');
            
            String tempData = pageHtml.substringBetween('<div class="single-car-data">', '</div>');
            tempData = String.isNotBlank(tempData) ? tempData.remove('<table>').remove('</table>'):'';
            
            if(String.isNotBlank(tempData)){
                tableDataList.addAll(tempData.split('tr'));
            }
            
            for(String tableData :tableDataList){
                if(tableData.containsIgnoreCase('<td class="t-value h6">')){
                    
                    if(tableData.substringBetween('<td class="t-label">', '</td>').equalsIgnoreCase('UNIT TYPE')){
                        
                        String category = tableData.substringBetween('<td class="t-value h6">','</td>'); 
                        siteTruck.Category__c = String.isNotBlank(category) ? category.replaceAll(',',';') : category;   
                    }else if(tableData.substringBetween('<td class="t-label">', '</td>').equalsIgnoreCase('Manufacturer')){
                        
                        siteTruck.Make__c = tableData.substringBetween('<td class="t-value h6">','</td>');                        
                    }else if(tableData.substringBetween('<td class="t-label">', '</td>').equalsIgnoreCase('YEAR')){
                    
                        System.debug('Year :::::::'+tableData.substringBetween('<td class="t-label">','</td>'));
                        siteTruck.Year__c = Integer.valueOf(tableData.substringBetween('<td class="t-value h6">','</td>').remove(','));                        
                    }else if(tableData.substringBetween('<td class="t-label">', '</td>').equalsIgnoreCase('MILEAGE')){
                    
                        siteTruck.Mileage__c = tableData.substringBetween('<td class="t-value h6">','</td>');                        
                    }
                }
            }
        }
        return siteTruck;
    }
}