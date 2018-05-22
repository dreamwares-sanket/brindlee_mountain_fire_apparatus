/**
 * @Description  : Batch class to Aggregate Truck ID's as per Dealer FTF Criteria's related to Dealer FTF Account and 
                   Populate Truck ID's in the Dealer FTF Account Object field (Dealer_Truck_Details__c).
 * @Created Date : 14-5-2017
 * @Authors      : Dreamwares
 */
 public class populateProductsPerFTFAccountBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    private static final integer RECORD_COUNT_TO_BE_FETCH = 100;
        
    private static final Map<String, String> oneToOneFieldBindings = new Map<String, String>{
        'Apparatus_Type__c' => 'ApparatusType__c',
        'Truck_4x4__c' => 'FT_Four_By_Four__c',
        'Truck_Brands__c' => 'FT_Fire_Body_Manufacturer__c',
        'Truck_Chassis__c' => 'FT_Custom_Commercial__c',
        'Truck_Geographic_Region__c' => 'Geographic_Region_Formula_Field__c',
        'Truck_Mileage__c' => 'FT_Mileage__c',
        'Truck_Price_Max__c' => 'Website_Price_Currency__c',
        'Truck_Price_Min__c' => 'Website_Price_Currency__c',
        'Truck_Pump_Size__c' => 'FTF_Pump_Size__c',
        'Truck_Tank_Size__c' => 'FTF_Tank_Size__c',
        'Truck_Warranty__c' => 'FTF_Warranty__c',
        'Status__c' => 'Status__c',
        'Type_of_Sale__c' => 'typeOfSale__c',
        'Truck_Year_Max__c' => 'FT_Year_of_Truck__c',
        'Truck_Year_Min__c' => 'FT_Year_of_Truck__c',
        'Advertised_on_Brindlee_s_site__c' => 'Post_To_Website__c'
    };
    
    private static final Map<String, String> oneToOneRangeFieldBindings = new Map<String, String>{
        'Truck_Price_Max__c' => 'Retail_Price_Currency__c',
        'Truck_Price_Min__c' => 'Retail_Price_Currency__c'
    };
        
    private static final Set<String> rangeFields = new Set<String>{
        'Truck_Price_Min__c',
        'Truck_Price_Max__c',
        'Truck_Year_Min__c',
        'Truck_Year_Max__c'
    };
    
    private static final Set<String> multipicklistToSingleFields = new Set<String>{
        'Truck_Brands__c',
        'Truck_Geographic_Region__c',
        'Truck_Chassis__c',
        'Truck_Mileage__c',
        //'Truck_Pump_Size__c',
        //'Truck_Tank_Size__c',
        'Truck_Warranty__c',
        'Type_of_Sale__c',
        'Status__c',
        'Advertised_on_Brindlee_s_site__c'    
    };
    
    private static final Set<String> multipicklistToformulaFields = new Set<String>{
        'Truck_Pump_Size__c',
        'Truck_Tank_Size__c'
    };
    
    private static final Set<String> picklistToSingleDecimalField = new Set<String>{
        'Truck_Mileage__c'
    };
    
    public static Map<String, String> tankSizeMap = new Map<String, String>();
    public static Map<String, String> pumpSizeMap = new Map<String, String>();
    
    public void execute(SchedulableContext SC) {
        
        populateProductsPerFTFAccountBatch updateAccount = new populateProductsPerFTFAccountBatch();
        Database.executebatch(updateAccount, 10);
    }    
        
    public Database.QueryLocator start(Database.BatchableContext BC) {
                
        String FTF_AccountQuery = 'SELECT Id, '+
                                  '      (SELECT '+ String.join(new List<String>(oneToOneFieldBindings.keySet()), ', ') +
                                  '       FROM Dealer_FTF_Truck_Criteria__r LIMIT 90), '+
                                  '      (SELECT Truck__c '+
                                  '       FROM Dealer_FTF_Trucks__r) '+
                                  'FROM Dealer_FTF_Account__c';
        
        return Database.getQueryLocator(FTF_AccountQuery);
    }
    
    /**
    *    to save Dealer Account info
    */
    public static void saveDealerAccount(List<Dealer_FTF_Account__c> FTF_Accounts, Boolean isBatchRun){
        
        pumpSizeMap = getPumpSizeMap();
        tankSizeMap = getTankSizeMap();
        
        String FTF_ProductQueryHolder = 'SELECT Id, '+ String.join(new List<String>(new Set<String>(oneToOneFieldBindings.values())), ', ') +' '+
                                        'FROM Product2';
        
        Map<Id, Dealer_FTF_Account__c> dealerAccountMap = new Map<Id, Dealer_FTF_Account__c>();
        Map<Id, Set<Id>> accountToProductIds = new Map<Id, Set<Id>>();
        Map<Id, String> accountToQueryMap = new Map<Id, String>();
        
        for(Dealer_FTF_Account__c ftfAcc : FTF_Accounts){
            
            dealerAccountMap.put(ftfAcc.Id, ftfAcc);

            accountToProductIds.put(ftfAcc.Id, new Set<Id>());
            for(Dealer_FTF_Truck__c FTFTruck : ftfAcc.Dealer_FTF_Trucks__r) {
                accountToProductIds.get(ftfAcc.Id).add(FTFTruck.Truck__c);
            }
            
            Integer accCriteriaCount = ftfAcc.Dealer_FTF_Truck_Criteria__r.size();
            if(accCriteriaCount > 0) {
            
                String FTF_ProductQuery = FTF_ProductQueryHolder + ' WHERE';
                                
                for(Dealer_FTF_Truck_Criteria__c FTFTruckCriteria : ftfAcc.Dealer_FTF_Truck_Criteria__r) { 
                                    
                    Map<String, Object> fieldInValueMap = new Map<String, Object>();
                    Map<String, List<Object>> rangeFieldsInValueMap = new Map<String, List<Object>>();
                    Map<String, List<Object>> priceRangeFieldsInValueMap = new Map<String, List<Object>>();
                    FTF_ProductQuery += ' ( ';
                    
                    for(Schema.FieldSetMember field : getFields()) {
                        
                        String fieldApiName = field.getFieldPath();             
                        Object fieldValue = FTFTruckCriteria.get(fieldApiName);                        
                        
                        Boolean isAddCriteria = true;
                        if(fieldValue != null) {
                            String targetField = oneToOneFieldBindings.get(fieldApiName);                                   
                            if(!fieldInValueMap.ContainsKey(fieldApiName)) {
                                if(Schema.DisplayType.MULTIPICKLIST == field.getType() || 
                                    Schema.DisplayType.PICKLIST == field.getType()) {
                                    if(multipicklistToSingleFields.Contains(fieldApiName)) {
                                        if(picklistToSingleDecimalField.Contains(fieldApiName)) {
                                            List<String> splitedString = String.valueOf(fieldValue).split(' ');
                                            isAddCriteria = !splitedString[0].equalsIgnoreCase('Any');
                                            fieldValue = ((splitedString[0].equalsIgnoreCase('Under')) ? ' <= ' : ' >= ') + splitedString[1].replaceAll(',', '');
                                        } else {
                                            isAddCriteria = !String.valueOf(fieldValue).equalsIgnoreCase('All');                                            
                                            if( String.valueOf(fieldValue).equalsIgnoreCase('Included') ) {
                                                fieldValue = ' = \'yes\'';
                                            }
                                            else if( String.valueOf(fieldValue).equalsIgnoreCase('Not Included') ) {
                                                fieldValue = ' = \'no\'';
                                            }
                                            else if( String.valueOf(fieldValue).equalsIgnoreCase('Yes') ) {
                                                fieldValue = ' = true';
                                            }
                                            else if( String.valueOf(fieldValue).equalsIgnoreCase('No') ) {
                                                fieldValue = ' = false';
                                                
                                            }else {
                                                fieldValue = ' IN (\''+ String.valueOf(fieldValue).replaceAll(';','\',\'') +'\')';
                                            }
                                        }                                        
                                    }else if(multipicklistToformulaFields.Contains(fieldApiName)){
                                    
                                        String picklistFormulaValue ='';
                                         
                                        for(String picklistValue :getPlickListValueForFormula(fieldApiName , String.valueOf(fieldValue))){
                                            
                                            picklistFormulaValue = picklistFormulaValue+'\''+picklistValue.trim()+'\',';
                                        } 
                                        
                                        picklistFormulaValue = picklistFormulaValue.removeEnd(',');                                        
                                        
                                        fieldValue = ' IN ('+picklistFormulaValue+') ';
                                    }else {                                                                                 
                                        fieldValue = ' INCLUDES (\''+ String.valueOf(fieldValue).replaceAll(';','\',\'') +'\')';
                                    }
                                } else if(rangeFields.Contains(fieldApiName)) {
                                    if(fieldApiName.indexOf('_Min_') > -1) {
                                        fieldValue = ' >= '+ fieldValue;
                                    } else {
                                        fieldValue = ' <= '+ fieldValue;
                                    }
                                } else {
                                    fieldValue = ' = '+ fieldValue;
                                }                                
                                if(isAddCriteria) {
                                    if(rangeFields.Contains(fieldApiName)) {
                                        
                                        if( oneToOneRangeFieldBindings.ContainsKey(fieldApiName) ) {
                                            
                                            String rangeTargetField = oneToOneRangeFieldBindings.get(fieldApiName); 
                                            
                                            if( !priceRangeFieldsInValueMap.ContainsKey(targetField) ) {
                                                priceRangeFieldsInValueMap.put( targetField, new List<Object>() );
                                            }
                                            priceRangeFieldsInValueMap.get(targetField).add(fieldValue);    
                                            
                                            if( !priceRangeFieldsInValueMap.ContainsKey(rangeTargetField)) {
                                                priceRangeFieldsInValueMap.put(rangeTargetField, new List<Object>());
                                            }
                                            priceRangeFieldsInValueMap.get(rangeTargetField).add(fieldValue);
                                        }
                                        else {                                      
                                            
                                            if(!rangeFieldsInValueMap.ContainsKey(targetField)) {
                                                rangeFieldsInValueMap.put(targetField, new List<Object>());
                                            }
                                            rangeFieldsInValueMap.get(targetField).add(fieldValue);     
                                        }                                   
                                    } else {                                                                            
                                        fieldInValueMap.put(targetField, fieldValue);
                                    } 
                                }
                            }
                        }           
                    }                                    
                    if(!fieldInValueMap.isEmpty()) {
                        for(String field : fieldInValueMap.keySet()) {
                            Object valueIn = fieldInValueMap.get(field);
                            FTF_ProductQuery += field + valueIn + ' AND ';
                        }
                        
                        for(String field : rangeFieldsInValueMap.keySet()) {
                            List<Object> valueIns = rangeFieldsInValueMap.get(field);
                            if( valueIns != null && !valueIns.isEmpty() ) {
                                FTF_ProductQuery += '( ';
                                for( Object valueObj : valueIns ) {
                                    FTF_ProductQuery += field + valueObj + ' AND '; 
                                }
                                FTF_ProductQuery = FTF_ProductQuery.removeEnd('AND ');                              
                                FTF_ProductQuery += ') AND ';                                                                       
                            }                           
                        }                 
                        
                        if(!priceRangeFieldsInValueMap.isEmpty() ) {                           
                            FTF_ProductQuery += '( ';                           
                            for( String field : priceRangeFieldsInValueMap.keySet() ) {
                                List<Object> valueIns = priceRangeFieldsInValueMap.get(field);                          
                                if( valueIns != null && !valueIns.isEmpty() ) {
                                    FTF_ProductQuery += '( ';
                                    for( Object valueObj : valueIns ) {
                                        FTF_ProductQuery += field + valueObj + ' AND '; 
                                    }
                                    FTF_ProductQuery = FTF_ProductQuery.removeEnd('AND ');                              
                                    FTF_ProductQuery += ') OR ';                                                                    
                                }                           
                            }       
                            FTF_ProductQuery = FTF_ProductQuery.removeEnd('OR ');
                            FTF_ProductQuery = FTF_ProductQuery.removeEnd('AND ');
                            FTF_ProductQuery += ' )';       
                        }        
                        FTF_ProductQuery = FTF_ProductQuery.removeEnd('OR ');
                        FTF_ProductQuery = FTF_ProductQuery.removeEnd('AND ');
                        FTF_ProductQuery += ' ) OR ';
                    }                   
                }
                FTF_ProductQuery = FTF_ProductQuery.removeEnd(' OR ');
                FTF_ProductQuery = FTF_ProductQuery.removeEnd(' AND ');
                FTF_ProductQuery += ' LIMIT 1000';
                System.debug('FTF_ProductQuery--' + FTF_ProductQuery);
                
                accountToQueryMap.put(ftfAcc.Id, FTF_ProductQuery);
                try {                                               
                    Map<id, Product2> productMap = new Map<id, Product2>((List<Product2>)Database.query(FTF_ProductQuery));
                    if(!productMap.isEmpty()) {
                        accountToProductIds.get(ftfAcc.Id).addAll(productMap.keySet());
                    }                       
                } catch(Exception exp) {
                    System.debug('Exception While Fetch Products : \n ' + exp.getMessage());
                }
            }
        }
        List<Dealer_FTF_Account__c> dealerAccList = new List<Dealer_FTF_Account__c>();
        for(Id accountId : accountToProductIds.keySet() ) {
            Dealer_FTF_Account__c dealerAcc = dealerAccountMap.get(accountId);
            
            dealerAcc.Dealer_Truck_Details__c = String.Join(new List<Id>(accountToProductIds.get(accountId)), ',');
            if(!accountToQueryMap.isEmpty() && accountToQueryMap.containsKey(accountId)){
                    dealerAcc.Inventory_Query__c = accountToQueryMap.get(accountId);
            }
            
                        
            dealerAccList.add(dealerAcc );
        }
        
        if(!dealerAccList.isEmpty()) {
            try {
                Upsert dealerAccList;
                System.debug('In batch class::::'+dealerAccList[0]);
                if(!isBatchRun){
                    DealerAccountCategoryCountBatchHelper.UpdateCategoryForEachAccount(dealerAccList[0]);
                }
            } catch(Exception exp) {
                System.debug('Exception While Upsert Products : \n ' + exp.getMessage());
            }       
        }
    }
    
    public void execute(Database.BatchableContext BC, List<Dealer_FTF_Account__c> FTF_Accounts) {       
        
        saveDealerAccount(FTF_Accounts, true);
    }
    
    public static List<Schema.FieldSetMember> getFields() {
        return SObjectType.Dealer_FTF_Truck_Criteria__c.FieldSets.CriteriaFields.getFields();
    }
    
    public void finish(Database.BatchableContext BC) {
        
        /*if(!SFUtilityResult.isSuccess){
        
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setSubject('Error while updating Account Total Amounts');
    
            String mailBody = 'Hi '+UserInfo.getName()+'<br/>' +
                              'Error occured while running <bold>UpdateAmountsOnAccountBatch<bold><br/>'+
                              'due to : <br/>'+ SFUtilityResult.displayMessage +'<br/>'+
                              'Please contact your System Admin.';
    
            mail.setHtmlBody(mailBody);
            mail.setTargetObjectId(UserInfo.getUserId());
    
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }*/
    }
    
    
    private static Set<String> getPlickListValueForFormula(String customMetadataTypeName , String multiSelectValues){
         
        Set<String> formulaFieldValueSet = new Set<String>();
        
        if(String.isNotBlank(customMetadataTypeName) && String.isNotBlank(multiSelectValues)){
           
                
            if(customMetadataTypeName.endsWithIgnoreCase('Truck_Pump_Size__c')){
                                
                for(String fieldValue : multiSelectValues.split(';')){
                    
                    if(pumpSizeMap.containsKey(fieldValue) && String.isNotBlank(pumpSizeMap.get(fieldValue))){
                    
                        formulaFieldValueSet.addAll(pumpSizeMap.get(fieldValue).split(','));
                    }
                }    
            }else if(customMetadataTypeName.endsWithIgnoreCase('Truck_Tank_Size__c')){
                                
                for(String fieldValue : multiSelectValues.split(';')){
                    
                    if(tankSizeMap.containsKey(fieldValue) && String.isNotBlank(tankSizeMap.get(fieldValue))){
                    
                        formulaFieldValueSet.addAll(tankSizeMap.get(fieldValue).split(','));
                    }
                }    
            }
        } 
        return formulaFieldValueSet;    
    }
    
    public static Map<String, String> getPumpSizeMap(){
        
        Map<String, String> pumpSizeMap = new Map<String, String>();
        List<FTF_Pump_Size__mdt> pumpSizeList = new List<FTF_Pump_Size__mdt>();
        try{
            pumpSizeList = [SELECT DeveloperName, Label, formulaFiledResult__c 
                            FROM FTF_Pump_Size__mdt
                            LIMIT 100];
        }catch(Exception exp){
            System.debug('Exception ::::'+exp);
        }
        for(FTF_Pump_Size__mdt pump :pumpSizeList){
            pumpSizeMap.put(pump.Label.trim(), pump.formulaFiledResult__c.trim());
        }
        return pumpSizeMap;
    }
    
    public static Map<String, String> getTankSizeMap(){
    
        Map<String, String> tankSizeMap = new Map<String, String>();
        List<FTF_Tank_Size__mdt> tankSizeList = new List<FTF_Tank_Size__mdt>();
        try{
            tankSizeList = [SELECT DeveloperName, Label, formulaFiledResult__c 
                            FROM FTF_Tank_Size__mdt 
                            LIMIT 100];
        }catch(Exception exp){
            System.debug('Exception ::::'+exp);
        }
        for(FTF_Tank_Size__mdt tank :tankSizeList){
            tankSizeMap.put(tank.Label.trim(), tank.formulaFiledResult__c.trim());
        }
        
        return tankSizeMap;
    }
}