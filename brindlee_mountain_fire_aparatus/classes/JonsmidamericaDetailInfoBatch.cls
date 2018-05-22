public class JonsmidamericaDetailInfoBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful{
    
    public List<String> pageUrlList = new List<String>();
    public List<Competitor_Site_Truck__c> truckList = new List<Competitor_Site_Truck__c>();
    public String siteId = '';
    
    public JonsmidamericaDetailInfoBatch(List<String> pageUrlList, String siteId){
     
        this.pageUrlList.addAll(pageUrlList);
        this.siteId = siteId;
    }
    
    public Iterable<String> start(Database.BatchableContext BC){
    
        return pageUrlList;
    }
    
    public void execute(Database.BatchableContext bc, List<String> urlList){
        
        for(String endPoint :urlList){
            
            truckList.add(parseResponse(SiteCalloutHelper.getHtmlBody(endPoint), endPoint, siteId));    
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
    
    private static Competitor_Site_Truck__c parseResponse(HTTPResponse httpResponse, String endPoint, String siteId){
        
        
        Competitor_Site_Truck__c truckRecord = new Competitor_Site_Truck__c();
        String pageBody = httpResponse.getBody();
        
        String title = pageBody.subStringBetween('h1 class="product_title','/h1');
        truckRecord.Main_Title__c = String.isNotBlank(title) ? title.subStringBetween('>','<') : '';
       
        truckRecord.Description__c = pageBody.subStringBetween('Description</h2>', '</div>');
        
        if(String.isNotBlank(truckRecord.Description__c)){
            truckRecord.Tank_size__c = truckRecord.Description__c.subStringBetween('Tank Size:','</'); 
            
            String pumpGPM = truckRecord.Description__c.subStringBetween('Pump:','GPM');
            truckRecord.Pump_GPM__c = String.isNotBlank(pumpGPM) ? pumpGPM+' GPM' : '';
        }
        
        String category = pageBody.subStringAfter('Category:');
        category = String.isNotBlank(category) ? category.subStringBetween('>','<'): '';
        truckRecord.Category__c = String.isNotBlank(category) ? category : endPoint.subStringBetween('trucks/', '/');
        truckRecord.Competitor_Site__c = siteId;
        truckRecord.Truck_Public_Site_Url__c = endPoint;
                
        String additionalInfo = pageBody.subStringBetween('shop_attributes">', '</table>');
        List<String> additionalInfoList = String.isNotBlank(additionalInfo) ? additionalInfo.split('/tr') : new List<String>();
        
        if(!additionalInfoList.isEmpty()){
            
            for(String info :additionalInfoList){
                
                if(info.subStringBetween('<th>','</th>') == 'Year'){
                    
                    String year = info.subStringBetween('p>','</p');             
                    truckRecord.Year__c = String.isNotBlank(year) ? Decimal.valueOf(year.remove(',')) : null;   
                }else if(info.subStringBetween('<th>','</th>') == 'Make'){ 
                               
                    truckRecord.Make__c = info.subStringBetween('p>','</p');   
                }else if(info.subStringBetween('<th>','</th>') == 'Model'){ 
                    
                    String model = info.subStringBetween('p>','</p');           
                    truckRecord.Model__c = String.isNotBlank(model) ? model.replaceAll('&#039;', '\'') : '';   
                }else if(info.subStringBetween('<th>','</th>') == 'Mileage'){ 
                    
                    String mileage = info.subStringBetween('p>','</p');
                    truckRecord.Mileage__c = String.isNotBlank(mileage) ? mileage.replaceAll('&#039;', '\'').replaceAll('&quot;','"') : '';
                }
            }
        }
        return truckRecord;
    }   
}