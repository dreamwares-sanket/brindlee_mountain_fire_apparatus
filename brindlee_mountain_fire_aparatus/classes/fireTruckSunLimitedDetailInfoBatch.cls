public class fireTruckSunLimitedDetailInfoBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful{
    
    public List<Competitor_Site_Truck__c> truckList = new List<Competitor_Site_Truck__c>();
    public List<String> pageUrlList = new List<String>();
    public String siteId = '';
    Map<String, String> siteToCategoryMap = new Map<String, String>();
    
    public fireTruckSunLimitedDetailInfoBatch(List<String> pageUrls, String siteId, Map<String, String> siteToCategoryMap){
       
        pageUrlList.addAll(pageUrls);
        this.siteId = siteId;
        this.siteToCategoryMap.putAll(siteToCategoryMap);
    }
    
    public Iterable<String> start(Database.BatchableContext BC) {
        return pageUrlList;
    }
    
    public void execute(Database.BatchableContext bc, List<String> urlList){
        System.debug('urlList::'+urlList);
        for(String endPoint :urlList){ 
            System.debug('endPoint::'+endPoint);
            truckList.add(parseResponse(getHtmlBody(endPoint), endPoint, siteId, siteToCategoryMap.get(endPoint)));    
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
    
    private static Competitor_Site_Truck__c parseResponse(HTTPResponse httpResponse, String endPoint, String siteId,
                                                          String category){
        
        
        Competitor_Site_Truck__c truckRecord = new Competitor_Site_Truck__c();
        String pageBody = httpResponse.getBody();
        
        String mileage = getValue('Mileage: ', pageBody); 
        truckRecord.Mileage__c = String.isNotBlank(mileage) ? getDecimalValue(mileage): '00.00';
        
        String make = getValue('Make: ', pageBody);        
        truckRecord.Make__c = String.isNotBlank(make) && make.contains(' ') ? make.subStringbefore(' ') : make;
        truckRecord.Truck_Public_Site_Url__c = endPoint;
        
        String price = getValue('class="price">', pageBody); 
        price = String.isBlank(price)? getValue('Asking Price:', pageBody) : price;
        price = String.isBlank(price)? getValue('Asking', pageBody) : price;
        
        truckRecord.Asking_Price__c = String.isNotBlank(price) ? Decimal.valueOf(getDecimalValue(price)) : 00.00;
        
        String model = getValue('Model: ', pageBody);
        truckRecord.Model__c = String.isNotBlank(model) && model.contains(' ') ? model.subStringbefore(' ') : model;
        
        truckRecord.Category__c = String.isNotBlank(category) ? category : '';
        truckRecord.Competitor_Site__c = siteId;
        
        if(pageBody.containsIgnoreCase('Stock')){ 
            
            String stock =  getStockNo('Stock#', pageBody); 
            stock = String.isBlank(stock) ? getStockNo('Stock #', pageBody) : stock;
            
            stock = String.isNotBlank(stock) ? stock.remove('&nbsp;').remove(':').trim() : stock; 
                   
            truckRecord.Stock__c = String.isNotBlank(stock) && stock.contains(' ') ? stock.subStringbefore(' ') : stock;    
        }
        
        String otherInfo = pageBody.subStringBetween('<div class="spec1 first">', '</div>');
        
        if(String.isNotBlank(otherInfo)){
            
            if(otherInfo.containsIgnoreCase('Apparatus Info')){            
                String appratusInfo = otherInfo.subStringBetween('Apparatus Info','</ul>');
                truckRecord.Additional_Apparatus_Info__c = String.isNotBlank(appratusInfo) ? '<ul>'+appratusInfo.subStringAfter('<ul>')+'</ul>' : '';
            }  
            
            if(otherInfo.containsIgnoreCase('Chassis')){            
                String chassisInfo = otherInfo.subStringBetween('Chassis','</ul>');
                truckRecord.Additional_Chassis_Info__c = String.isNotBlank(chassisInfo) ? '<ul>'+chassisInfo.subStringAfter('<ul>')+'</ul>' : '';
            }  
            
            if(otherInfo.containsIgnoreCase('Transmission')){            
                String transmissionInfo = otherInfo.subStringBetween('Transmission','</ul>');
                
                if(String.isNotBlank(transmissionInfo)){                    
                    truckRecord.Transmission_Model__c = transmissionInfo.containsIgnoreCase('Model:') ? transmissionInfo.subStringBetween('Model:','</li>') : '';
                    truckRecord.Transmission_Type__c = transmissionInfo.containsIgnoreCase('Type:') ? transmissionInfo.subStringBetween('Type:','</li>').trim() : '';
                }               
            }  
            
            if(otherInfo.containsIgnoreCase('Pump')){
            
                String pumpInfo = otherInfo.subStringBetween('Pump','</ul>');
                
                if(String.isNotBlank(pumpInfo)){                    
                    truckRecord.Pump_Make__c = pumpInfo.containsIgnoreCase('Make:') && String.isNotBlank(getValue('Make:', pumpInfo))? getValue('Make:', pumpInfo).trim() : '';
                    truckRecord.Pump_Model__c = pumpInfo.containsIgnoreCase('Model:') && String.isNotBlank(getValue('Model:', pumpInfo)) ? getValue('Model:', pumpInfo) : '';
                    truckRecord.Pump_GPM__c = pumpInfo.containsIgnoreCase('GPM:') && String.isNotBlank(getValue('GPM:', pumpInfo)) ? getValue('GPM:', pumpInfo).remove(',').trim() : '';
                }
            }  
            
            if(otherInfo.containsIgnoreCase('Water Tank')){
            
                String tankInfo = otherInfo.subStringBetween('Water Tank','</ul>');
                
                if(String.isNotBlank(tankInfo)){                    
                    truckRecord.Water_Tank_Size_only__c = tankInfo.containsIgnoreCase('Gallons:') && String.isNotBlank(getValue('Gallons:', tankInfo)) ? getValue('Gallons:', tankInfo).trim() : '';
                }
            }  
            
            if(otherInfo.containsIgnoreCase('Foam')){
            
                String foamInfo = otherInfo.subStringBetween('Foam','</ul>');
                
                if(String.isNotBlank(foamInfo)){                    
                    truckRecord.Foam_Make__c = foamInfo.containsIgnoreCase('Make:') && String.isNotBlank(getValue('Make:', foamInfo)) ? getValue('Make:', foamInfo).trim() : '';
                }
            }  
            
            if(otherInfo.containsIgnoreCase('Discharges')){
            
                String disChargeInfo = otherInfo.subStringBetween('Discharges','</ul>');
                
                if(String.isNotBlank(disChargeInfo)){                    
                    truckRecord.Discharges_Driver_s_Side__c = disChargeInfo.containsIgnoreCase('Driver&#8217;s Side:') && String.isNotBlank(getValue('Driver&#8217;s Side:', disChargeInfo)) ? 
                                                              getValue('Driver&#8217;s Side:', disChargeInfo).trim() : '';
                    truckRecord.Discharges_Officer_s_Side__c = disChargeInfo.containsIgnoreCase('Officer&#8217;s Side:') && String.isNotBlank(getValue('Officer&#8217;s Side:', disChargeInfo)) ? 
                                                               getValue('Officer&#8217;s Side:', disChargeInfo).trim() : '';
                    truckRecord.Discharges_Front__c = disChargeInfo.containsIgnoreCase('Front:') && String.isNotBlank(getValue('Front:', disChargeInfo)) ? 
                                                      getValue('Front:', disChargeInfo).trim() : '';
                }
            } 
            
            if(otherInfo.containsIgnoreCase('Lighting')){
            
                String lightningInfo = otherInfo.subStringBetween('Lighting','</ul>');                
                truckRecord.Additional_Lighting_Info__c = String.isNotBlank(lightningInfo) ? '<ul>'+lightningInfo.subStringAfter('<ul>')+'</ul>' : '';
            } 
            
            if(otherInfo.containsIgnoreCase('Additional Features')){
            
                String additionalInfo = otherInfo.subStringBetween('Additional Features','</ul>');                
                truckRecord.Additional_Features__c = String.isNotBlank(additionalInfo) ? '<ul>'+additionalInfo.subStringAfter('<ul>')+'</ul>' : '';
            }  
            
            if(otherInfo.containsIgnoreCase('Suctions')){
            
                String suctionInfo = otherInfo.subStringBetween('Suctions','</ul>');
                
                if(String.isNotBlank(suctionInfo)){                    
                    truckRecord.Suction_Driver_s_Side__c = suctionInfo.containsIgnoreCase('Drivers Side:') && String.isNotBlank(getValue('Drivers Side:', suctionInfo)) ? 
                                                           getValue('Drivers Side:', suctionInfo).trim() : 
                                                           suctionInfo.containsIgnoreCase('Driver&#8217;s Side:') && String.isNotBlank(getValue('Driver&#8217;s Side:', suctionInfo)) ? 
                                                           getValue('Driver&#8217;s Side:', suctionInfo).trim() : '';
                    truckRecord.Suction_Officer_s_Side__c = suctionInfo.containsIgnoreCase('Officer&#8217;s Side:') && String.isNotBlank(getValue('Officer&#8217;s Side:', suctionInfo)) ? 
                                                            getValue('Officer&#8217;s Side:', suctionInfo).trim() : '';                
                }
            }  
            
            if(otherInfo.containsIgnoreCase('Location')){                
                String locationInfo = otherInfo.subStringBetween('<h3>Location','</p>');
                
                if(String.isNotBlank(locationInfo)){
                    locationInfo = String.isNotBlank(locationInfo) && locationInfo.contains('</')? getValue('>', locationInfo) : locationInfo;
                    locationInfo = String.isNotBlank(locationInfo) && locationInfo.containsIgnoreCase('>') ? 
                                   locationInfo.subStringAfterLast('>') : locationInfo;
                    truckRecord.Location__c = locationInfo.removeStartIgnoreCase('&nbsp;').removeEndIgnoreCase('&nbsp;');
                }
            }
        }
        return truckRecord;
    }   
    
    private static String getStockNo(String label, String pageBody){
        
        String stock = '';
        if(String.isNotBlank(label) && String.isNotBlank(pageBody)){
            
            stock = getValue(label, pageBody);
            stock = String.isBlank(stock) ? getValue('strong>', pageBody.subStringBetween(label, '</p')): stock;            
            
            String stockRow = pageBody.subStringBetween(label, '</li');
             
            stock = String.isBlank(stock) && String.isNotBlank(stockRow) ?stockRow.subStringAfter('li>'): stock;
        }
        return stock;
    }
    
    private static String getValue(String label, String pageBody){
        
        String valueStr = '';
      
        if(String.isNotBlank(label) && String.isNotBlank(pageBody)){
           
            valueStr = pageBody.subStringBetween(label,'</');
            valueStr = String.isNotBlank(valueStr) && valueStr.contains('<') ? valueStr.subStringbefore('<') : valueStr;
           
            valueStr = String.isBlank(valueStr) ? pageBody.subStringAfter(label) : valueStr;
           
            valueStr = String.isNotBlank(valueStr) && valueStr.contains('</li>') ? valueStr.subStringbefore('</li>') : valueStr;
            valueStr = String.isNotBlank(valueStr) && valueStr.contains('<br') ? valueStr.subStringbefore('<br') : valueStr; 
            valueStr = String.isNotBlank(valueStr) && valueStr.contains('</strong') ? valueStr.subStringbefore('</strong') : valueStr; 
            valueStr = String.isNotBlank(valueStr) && valueStr.contains('</span') ? valueStr.subStringbefore('</span') : valueStr;
            valueStr = String.isNotBlank(valueStr) && valueStr.containsIgnoreCase('</p') ? valueStr.subStringbefore('</p') : valueStr;
            valueStr = String.isNotBlank(valueStr) && valueStr.containsIgnoreCase('</h3') ? valueStr.subStringAfter('</h3>') : valueStr;
           
            valueStr = String.isNotBlank(valueStr) ? valueStr.replaceAll('&#8243;', '"') : valueStr;           
            valueStr = String.isNotBlank(valueStr) ? valueStr.remove(':').trim() : valueStr; 
        }
        return valueStr;
    } 
    
    private static String getDecimalValue(String fieldValue){
        
        if(String.isNotBlank(fieldValue)){
            fieldValue = fieldValue.remove(',').remove('$').trim();
            fieldValue = fieldValue.contains('</span') ? fieldValue.subStringbefore('</span') : fieldValue;
           
            if(!fieldValue.isNumeric()){
                List<String> tempList = fieldValue.split(' ');
                
                for(String tempValue :tempList){
                    if(tempValue.remove(',').remove('.').remove('$').trim().isNumeric()){
                        fieldValue = tempValue;
                        break;
                    }else{
                        fieldValue = '00.00';
                    }
                }
            }            
        }else{
           fieldValue = '00.00'; 
        }
        return fieldValue;
    }
}