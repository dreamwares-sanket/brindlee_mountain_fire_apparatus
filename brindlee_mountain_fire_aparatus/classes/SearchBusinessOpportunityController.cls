public class SearchBusinessOpportunityController {

    public String strTypeOfObject{get;set;}   
    public List<OpportunityWrapper>listOpportunityWrapper{get; set;}
    
    Public Map<Id, String>mapProductIdImagesURL {get;set;}
    private Static Integer intAllowedBudgetDiffrence = 20000; // constant for budget diff
    private Static Integer intAllowedBudgetDiffrenceForPartialPoint = 50000; // constant for budget diff
    
    private Static Integer intAllowedYearDiffrence = 3;
    private Static Integer intAllowedYearDiffForPartialPoint = 6;
    
    
        
    public SearchBusinessOpportunityController() {    
        mapProductIdImagesURL = new Map<Id, String> ();
        searchRecords();               
    }
    
    //@purpose Search records of opportunity/ product depending upon id in page parameter
    public void searchRecords() {
        List<OpportunityWrapper>listRecordsToApplyScore = new List<OpportunityWrapper>();
        listOpportunityWrapper = new List<OpportunityWrapper>();
        // fetch id of record from URL 
        Id IdOfRecord;
        try {
            IdOfRecord = Id.ValueOf(ApexPages.currentPage().getParameters().get('id'));
            
        }catch(Exception ex){           
            addErrorToPage('Record Id Not Found.');
        }
        
        if(IdOfRecord !=null){        
            // get object type from Id of record 
            strTypeOfObject = getObjectType(IdOfRecord);
            
            //  check reord id type and then crate filter query
            if(strTypeOfObject != null && 
               (strTypeOfObject.EqualsIgnoreCase('Product2') 
                || strTypeOfObject.EqualsIgnoreCase('Opportunity'))) 
            {
                
                String queryToSearchRecords;
                opportunity masterOprtunityToCompare;
                Product2 masterProductToCompare;
                //if Opporunity Record 
                if(strTypeOfObject.EqualsIgnoreCase('Opportunity')){
                    
                    masterOprtunityToCompare = (opportunity)getMasterObject(strTypeOfObject, IdOfRecord);                                                
                    
                    if(masterOprtunityToCompare != null ) {                                                                                                           
                        // set search object as Product2 as we have opportunity as source record
                        // Filter product2 records 
                        queryToSearchRecords = buildQueryWithFilterCondtions('Product2', masterOprtunityToCompare);     
                        
                    }
                    
                }else if(strTypeOfObject.EqualsIgnoreCase('Product2')) {
                    
                    masterProductToCompare = (Product2)getMasterObject(strTypeOfObject, IdOfRecord);                        
                    if(masterProductToCompare != null ) {
                        
                        // set search object as Opportunity as we have opportunity as source record
                        // Filter opportunity records
                        queryToSearchRecords= buildQueryWithFilterCondtions('Opportunity', masterProductToCompare);                                                           
                    }                    
                }   
                List<Sobject>listRecordsFiltered = new List<Sobject>();
                if(String.isNotBlank(queryToSearchRecords)){
                    try{
                        System.debug('queryToSearchRecords:::'+ queryToSearchRecords);
                        listRecordsFiltered = database.query(queryToSearchRecords);            
                    }catch(Exception ex){
                        addErrorToPage('Opps.. Sorry for inconvenience. Please try agian after some time');         
                    }               
                }   
                listRecordsToApplyScore = covertListToWrapperClass(listRecordsFiltered);    
                
                
                // Apply Scoring Criteria
                if(strTypeOfObject.EqualsIgnoreCase('Product2')){

                    // Apply Score on opportunity records                    
                    listRecordsToApplyScore = calculateScoreForOpprtunityRecords(masterProductToCompare, listRecordsToApplyScore );                                        
                }
                else{
                
                    // Apply Score on Product2 records
                    listRecordsToApplyScore = calculateScoreForProductRecords(masterOprtunityToCompare, listRecordsToApplyScore );                    
                }           
                listRecordsToApplyScore.sort();      
                for(Integer count = 0; count < listRecordsToApplyScore.size() && count<500; Count++ ){
                    listOpportunityWrapper.add(listRecordsToApplyScore[count]);
                    
                }    
            }else {                
                addErrorToPage('Record Id must be of Opportunity or Product.');
            }        
        }                
    }      
    
    //  @purpose :: Get Source (Master object from whcih related record is to be search)
    private Sobject getMasterObject(String strObjectType, Id IdOfMasterRecord) {
        
        if(IdOfMasterRecord != null && String.isNotBlank(strObjectType)) {
            String queryForGettingMasterObject = 'SELECT {0} FROM {1} WHERE Id =:IdOfMasterRecord'; // create query string on Master object                      
            try {
                return Database.query(createQueryString(queryForGettingMasterObject, strObjectType));
                
            } catch(Exception ex){               
                addErrorToPage('Opps.. Sorry for inconvenience. Please try agian after some time.');
            }
        }
        return null;        
    }
    
    // @purpose createQueryString 
    private String createQueryString (String stringTempalteString, String strObjectType){ 
        if(String.isNotBlank(stringTempalteString) && String.isNotBlank(strObjectType)) {   
            // Retrive Parent Object 
            Set<String> queryLiterals = new Set<String>();
            queryLiterals.add('Id');
            
            for(Schema.FieldSetMember currentField : this.getFieldPaths(strObjectType, 'SellMyProducts')) {
                queryLiterals.add(currentField.getFieldPath());
            }        
            if(strObjectType.equalsIgnoreCase('Product2')) {
                String strSubquery = '( SELECT Id, Amazon_S3_Main_Thumbnail_URL__c  FROM Cloud_Documents__r WHERE Main_Thumbnail__c = True AND Show_Online__c = True LIMIT 1)';
                queryLiterals.add (strSubquery);
            }       
            
            String strqueryLiterals = string.join(new List<String>(queryLiterals), ', ') ;
            return String.format(stringTempalteString , new String[]{strqueryLiterals, strObjectType});   
        }         
        return null;
    }
    
    // @purpose Build query string and append filter conditions 
    private string buildQueryWithFilterCondtions(String strTypeOfObjectToSearchFor, Sobject sourceObject) {
        
        if(String.isNotBlank(strTypeOfObjectToSearchFor) && sourceObject != null) {          
            String query = 'SELECT {0} FROM {1} WHERE ';     
            query = createQueryString(query, strTypeOfObjectToSearchFor) + ' {0} ORDER BY  LastModifiedDate DESC LIMIT 1000' ;
            System.debug('query :::' + query );
            
            List<String> condtionLiterals = new List<String>();
            String strConditionsToApply;
            
            // match Opprtunity Fields with Product
            if(strTypeOfObjectToSearchFor == 'Opportunity') {
                // create Filter string for opportunity query  
                strConditionsToApply = createFilterOfOpportunity(sourceObject);                                   
            }
            else{    
                // create Filter string for product query              
                strConditionsToApply = createFilterOfProduct(sourceObject);                                                   
            }          
            
            
            // Add conditions to list 
            if(String.isNotBlank(strConditionsToApply)) {                        
                condtionLiterals.add(strConditionsToApply);
            }
            System.debug('condtionLiterals::' + condtionLiterals);
            if(!condtionLiterals.isEmpty()){
                return String.format(query ,condtionLiterals);
            }
            else{                           
                // remove where FROM Query string if condtionLiterals are empty as no condtions
                return String.format(query ,condtionLiterals).remove('WHERE');
                
            }            
            
        }
        return null;            
    }
    
    public String createFilterOfProduct(Sobject sourceObject){   
        List<String> condtionLiterals = new List<String>();
        String strNewConditionToAdd;
        Integer intValueToFind;
        
        // build condition for Type of Apparatus (match with Apparatus Type)     
        try {  
            // multiselect picklist field: apparatusType__c on opportunity {add keyword search includes}
            String StringToFind = String.valueOf(sourceObject.get('Type_of_Apparatus__c'));
            strNewConditionToAdd = buildMultiPicklistConditionsForSourceObject(StringToFind, 'apparatusType__c');            
            
        }catch(Exception ex) {
            strNewConditionToAdd =  buildMultiPicklistConditionsForSourceObject(null,'apparatusType__c');
        }   
        if(strNewConditionToAdd != null) {
            condtionLiterals.add(strNewConditionToAdd );
        }    

        
        try {       
            strNewConditionToAdd = buildStringConditions( 'trucks', 'RecordType.Name');
        }catch(Exception ex) {
            strNewConditionToAdd = null;
        }           
        if(strNewConditionToAdd != null) {
            condtionLiterals.add(strNewConditionToAdd );
        } 
        
        
        try {       
            strNewConditionToAdd = buildStringConditions( 'Available', 'status__c');
        }catch(Exception ex) {
            strNewConditionToAdd = null;
        }           
        if(strNewConditionToAdd != null) {
            condtionLiterals.add(strNewConditionToAdd );
        } 
        return  string.join(condtionLiterals, ' AND ');
        
    }     
    
    public String createFilterOfOpportunity(Sobject sourceObject){        
        List<String> condtionLiterals = new List<String>();
        
        String strNewConditionToAdd;
        Integer intValueToFind;
        try {
            // multiselect picklist of Source Object : apparatusType__c 
            String StringToFind = String.valueOf(sourceObject.get('apparatusType__c'));
            strNewConditionToAdd = buildMultiSelectPicklistConditions(StringToFind, 'Type_of_Apparatus__c');            
            
        }catch(Exception ex) {
            strNewConditionToAdd =  buildMultiSelectPicklistConditions(null,'Type_of_Apparatus__c');
        }           
        if(strNewConditionToAdd != null) {
            condtionLiterals.add(strNewConditionToAdd );
        } 
        try {       
            strNewConditionToAdd = buildStringConditions( 'Sales', 'RecordType.Name');
        }catch(Exception ex) {
            strNewConditionToAdd = null;
        }           
        if(strNewConditionToAdd != null) {
            condtionLiterals.add(strNewConditionToAdd );
        } 
        // Get opportunity record type ID  where Name is 'Sales'
        return  string.join(condtionLiterals, ' AND ');
    }
    
    // @purpose : If values to search is value get from multiselect picklist then create query condition
    Public String buildMultiSelectPicklistConditions ( String stringToFind, String strSourceObjectFieldName) {
        if(String.isNotBlank(strSourceObjectFieldName)) {
            List<String> searcConditions = new List<String>();
            List<String>searchliterals = new List<String>();
            
            if(String.isNotBlank(stringToFind)) {
                searchliterals= stringToFind.split(';');
            }
            
            if(searchliterals.isEmpty()){
                searcConditions.add( strSourceObjectFieldName + ' != null ');                            
            }            
            
            String valueOfStringLiteral;
            
            for(String searchliteral :searchliterals) {        
                valueOfStringLiteral ='\'%' + String.escapeSingleQuotes(searchliteral) + '%\'';
                searcConditions.add( strSourceObjectFieldName + ' like ' + valueOfStringLiteral );
            }
            
            searcConditions.add( strSourceObjectFieldName + ' = null ');                            
            
            valueOfStringLiteral ='\'%' + String.escapeSingleQuotes('All') + '%\'';
            searcConditions.add( strSourceObjectFieldName + ' like ' + valueOfStringLiteral );
            
            valueOfStringLiteral ='\'%' + String.escapeSingleQuotes('Both') + '%\'';
            searcConditions.add( strSourceObjectFieldName + ' like ' + valueOfStringLiteral );
            
            
            // If Value available to compare Add OR condtion after each value
            if(!searcConditions.isEmpty()) {
                String strqueryLiterals = '('+ string.join(searcConditions, ' OR ') + ') ' ;
                System.debug('buildMultiSelectPicklistConditions:::' + strqueryLiterals);
                return strqueryLiterals;
            }
        }
      
        return null;
    }
    
    // @purpose: If source object API field is multiselct picklist 
    Public String buildMultiPicklistConditionsForSourceObject (String stringToFind, String strSourceObjectFieldName){
        //if(String.isNotBlank(stringToFind) && String.isNotBlank(strSourceObjectFieldName)) {
        if(String.isNotBlank(strSourceObjectFieldName)) {
            
            List<String> searcConditions = new List<String>();            
            List<String>searchliterals = new List<String>();
            if(String.isNotBlank(stringToFind)) {
                searchliterals= stringToFind.split(';');
            }
            
            if(searchliterals.isEmpty()){
                searcConditions.add( strSourceObjectFieldName + ' != null ');                            
            }
            
            for(String searchliteral :searchliterals) {        
                searcConditions.add( strSourceObjectFieldName + ' INCLUDES  (\'' + searchliteral + '\')');                
                
            }
            
            // consider blank value 
            searcConditions.add( strSourceObjectFieldName + ' = null ');                            
            searcConditions.add( strSourceObjectFieldName + ' INCLUDES  (\'Both\')');  
            searcConditions.add( strSourceObjectFieldName + ' INCLUDES  (\'All\')');  
            
            
            // If Value available to compare Add OR condtion after each value
            if(!searcConditions.isEmpty()) {
                String strqueryLiterals = '('+ string.join(searcConditions, ' OR ') + ') ';
                System.debug('buildMultiSelectPicklistConditions:::' + strqueryLiterals);
                return strqueryLiterals;
            }
        }  
        
        return null;
    }     

    //  @Purpose Create Condition For String Values 
    Public String buildStringConditions ( String StrValueToMatch, String strSourceObjectFieldName) { 
        if(String.isNotBlank(StrValueToMatch) && String.isNotBlank(strSourceObjectFieldName)) {
            return (' ' + strSourceObjectFieldName  + '  = \'' + StrValueToMatch + '\' ' );
        }
        return null;
    }
        
    
    // @purpose get object type from reocrd Id   
    private String getObjectType(Id IdOfRecord) {
        
        try {
            return String.ValueOf(IdOfRecord.getSobjectType());             
        }
        catch(Exception ex){
            addErrorToPage('Invalid record Id.');
        }
        return null;
        
    }
    
    // @purpose  get Field API Names relaetd to objects
    public List<Schema.FieldSetMember> getFieldPaths(String ObjectName, String fieldSetName) {
        if(String.isNotBlank(ObjectName) && String.isNotBlank(fieldSetName)) {
            Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
            Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
            
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();                
            Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);     
            return fieldSetObj.getFields(); 
            
        }  
        return new List<Schema.FieldSetMember>();               
    }
    
    //  @Purpose Create and Error Messages to page 
    private void addErrorToPage(String errorMessage){
        ApexPages.Message errorMsg= new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
        ApexPages.addMessage(errorMsg);    
    }
    
    //  @Purpose conver sobject list to Wrapper class 
    private List<OpportunityWrapper> covertListToWrapperClass(List<Sobject>listSourceObject){
        List<OpportunityWrapper> listWrapperClass = new List<OpportunityWrapper>();
        
        if(listSourceObject != null && !listSourceObject.isEmpty()){
            for(Sobject sourceObject :listSourceObject) {
                listWrapperClass.add(new OpportunityWrapper(sourceObject )); 
            }
        }
        return listWrapperClass; 
        
    }
    
    //  @purpose  Calcluate score for opportunity records 
    public List<OpportunityWrapper> calculateScoreForOpprtunityRecords(Product2 mainProduct, List<OpportunityWrapper>listRecordsToCheck) {
        // Filter records with required pump size and Tanksize 
        // Get Integer Value of FT - Pump GPM
        if (mainProduct != null && listRecordsToCheck !=null) {
            Integer pumpSizeToCompare = getPumpSize(mainProduct, 'FT_Pump_GPM__c');
            Integer tankSizeToCompare = getNumberValueOfSourceField(mainProduct, 'FT_Water_Tank_Size_only__c');
            
            Integer YearToCompare = Integer.ValueOF( mainProduct.FT_Year_of_Truck__c);
            Integer WebsitBudgetToCompare = convertCurrencyTextToInteger(mainProduct, 'Website_Price__c');
            Integer RetailPriceBudgetToCompare = convertCurrencyTextToInteger(mainProduct, 'Retail_Price__c');
           
            Decimal decMileageToCompare =  mainProduct.FT_Mileage__c;
            String strWarranty = mainProduct.FTF_Warranty__c;
            
            List<OpportunityWrapper>listRecordsToDisplay = new List<OpportunityWrapper>();                        
            if(listRecordsToCheck != null) {                
                Integer minYearToCompare; 
                Integer maxYearToCompare; 
                Integer minBudgetTocompare; 
                Integer maxBudgetTocompare;
                Integer intSourceMileage;
               
                Decimal decScore; // store points of each record 
                string strWarrantyStatusOfTarget;
                for(OpportunityWrapper opportunityToCompare: listRecordsToCheck) {
                    
                    // Caluculate score for Year conditions  
                    decScore = 0;
                    minYearToCompare = getNumberValueOfSourceField(opportunityToCompare.sourceRecord, 'Year_Min__c');
                    maxYearToCompare = getNumberValueOfSourceField(opportunityToCompare.sourceRecord, 'Year_Max__c');
                    
                    // If the year is within +/- 3 years it is a full point.  
                    // If the year is within 4-6 +/- then it will be a 1/2 partial point.
                    if(compareLimitValues( YearToCompare, intAllowedYearDiffrence, minYearToCompare , maxYearToCompare)){
                        decScore = decScore + 1;
                        system.debug('full year decScore :::: ' + decScore );
                        
                    }
                    else if(compareLimitValues( YearToCompare, intAllowedYearDiffForPartialPoint, minYearToCompare, maxYearToCompare)) {                            
                        // If the year is within 4-6 +/- then it will be a 1/2 partial point.
                        decScore = decScore+0.5;
                        
                    }

                    //  pump Size.  If within the drop down range then a full point.  If the range above or below, then a partial point.  
                    Boolean isMatchFound = false;
                    try {                       
                        for(string rangeValueToCompare : String.ValueOf(opportunityToCompare.sourceRecord.get('pUMP__c')).split(';')) {
                            if(matchRangeValue(pumpSizeToCompare, rangeValueToCompare)) {
                                isMatchFound = true;
                                break;
                            }                         
                        }
                    }catch(exception ex) { 
                        system.debug('Error while Converting Range value::' + ex.getStackTraceString());                    
                    }
                    decScore = decScore + (isMatchFound ?  1 : 0.5);                    
                    
                    //  Tank Size: If within the drop down range then a full point.  If the range above or below, then a partial point else no point .
                    if( matchRangeValue(tankSizeToCompare, String.ValueOf(opportunityToCompare.sourceRecord.get('Tank_Size__c')))){
                        decScore = decScore + 1;             
                        
                    }else {                           
                        decScore = decScore + 0.5;
                    }                       
                    
                    // WebsitBudget : if range is within +/- $20,000 full point 
                    // else if range is within $20,000 to $50,000  then a partial point else no point 
                    minBudgetToCompare = getNumberValueOfSourceField(opportunityToCompare.sourceRecord, 'Budget_Min__c');
                    maxBudgetToCompare = getNumberValueOfSourceField(opportunityToCompare.sourceRecord, 'Budget_Max__c');
                    
                    if(compareLimitValues( WebsitBudgetToCompare, intAllowedBudgetDiffrence,minBudgetToCompare , maxBudgetToCompare)){
                        decScore = decScore + 1;             
                    }
                    else if(compareLimitValues( WebsitBudgetToCompare, intAllowedBudgetDiffrenceForPartialPoint  ,minBudgetToCompare , maxBudgetToCompare )){
                        decScore = decScore + 0.5;
                    }
                    
                    //  RetailPriceBudgetToCompare : if range is within +/- $20,000 full point 
                    //  else if range is within $20,000 to $50,000  then a partial point else no point                        
                    if(compareLimitValues( RetailPriceBudgetToCompare, intAllowedBudgetDiffrence,minBudgetToCompare , maxBudgetToCompare)){
                        decScore = decScore + 1;             
                    }
                    else if(compareLimitValues( RetailPriceBudgetToCompare, intAllowedBudgetDiffrenceForPartialPoint  ,minBudgetToCompare , maxBudgetToCompare )){
                        decScore = decScore + 0.5;
                    }
                    
                    //  Brand: Must be an exact match.  No partial points.                       
                    //  build condition for FT - Fire Body Manufacturer (match with Brand)   
                    try {  
                        // multiselect picklist field: Brand on opportunity {if Source string contains ALL or both or substring then match found}
                        if(compareStringValues(mainProduct.FT_Fire_Body_Manufacturer__c ,String.valueOf(opportunityToCompare.sourceRecord.get('Brand__c')))){
                            decScore = decScore + 1;             
                        }                            
                    }catch(Exception ex) {                        
                        system.debug('Error ::' + ex.getStackTraceString());
                    }   
                    
                    // Chassis: Must be an exact match.  No partial points.                       
                    // build condition for FT_Custom_Commercial__c (match with Brand)   
                    try {  
                        //  multiselect picklist field: Brand on opportunity {if Source string contains ALL or both or substring then match found}
                        if(compareStringValues(mainProduct.FT_Custom_Commercial__c,String.valueOf(opportunityToCompare.sourceRecord.get('Chassis__c')))){
                            decScore = decScore + 1;             
                        }    
                        else {
                            decScore = decScore + 0.5;                                         
                        }                        
                    }catch(Exception ex) {                        
                        system.debug('Error ::' + ex.getStackTraceString());
                    }                                         
                    
                    //  Mileage: If the truck is within the range given in piclist then it's a full point match, else it is a 1/2 point.                    
                    if(compareOpportunityMileage(Integer.Valueof(decMileageToCompare), String.ValueOf(opportunityToCompare.sourceRecord.get('FTF_Mileage__c')))) {                    
                        decScore = decScore + 1;
                    } else {
                        decScore = decScore + 0.5;
                    }
                    
                    //  check Warranty                    
                    try{
                        strWarrantyStatusOfTarget = String.ValueOf(opportunityToCompare.sourceRecord.get('Trucks_With_Warranty__c'));
                    } catch(Exception ex) {                        
                        system.debug('Error ::' + ex.getStackTraceString());
                    }  
                    
                     //  Warranty : if  product.FTF_Warranty__c = yes  then opportunity.Trucks_With_Warranty__c = included
                    //  if product.FTF_Warranty__c = No then opportunity.Trucks_With_Warranty__c = not included 
                    //  if All then full point of score 
                  
                    if( (String.isBlank(strWarranty) || String.isBlank(strWarrantyStatusOfTarget) || strWarrantyStatusOfTarget.equalsIgnoreCase('All'))
                    || (strWarranty.equalsIgnoreCase('yes') && (strWarrantyStatusOfTarget.equalsIgnoreCase('included')))
                    || (strWarranty.equalsIgnoreCase('no') && (strWarrantyStatusOfTarget.equalsIgnoreCase('Not Included')))                       
                    ){
                        decScore = decScore + 1; // full Warranty match
                        system.debug(' full Warranty match:::');
                    }
                    else {
                        decScore = decScore + 0.5; // partial Warranty match
                        system.debug(' partial Warranty match:::');
                    }
                    
                    
                    // region : Must be an exact match.  No partial points.                       
                    try {  
                        //  multiselect picklist field: Geographic_Region__c on opportunity {if Source string contains ALL or both or substring then match found}
                        if(compareStringValues(mainProduct.Geographic_Region_Formula_Field__c, String.valueOf(opportunityToCompare.sourceRecord.get('Geographic_Region__c')))){
                            decScore = decScore + 1;             
                        }    
                        else {
                            decScore = decScore + 0.5;                                         
                        }                        
                    }catch(Exception ex) {                        
                        system.debug('Error ::' + ex.getStackTraceString());
                    }   
                         
                         
                    
                    opportunityToCompare.intPoints = decScore;                                                                                                    
                }
            }
                        
        }   
        return listRecordsToCheck;
    }
    public List<OpportunityWrapper> calculateScoreForProductRecords(Opportunity mainOprtunity, List<OpportunityWrapper>listRecordsToCheck) {
    
        if (mainOprtunity != null && listRecordsToCheck!=null) {
            
            Decimal decScore; // store points of each record 
            Integer intMinValueToFind;
            Integer intMaxValueToFind;
            
            Decimal intBudgetMax = intAllowedBudgetDiffrence; 
            Decimal intBudgetMin = 0; 
            Decimal intpartialBudgetMax = intAllowedBudgetDiffrenceForPartialPoint;   
            Decimal intpartialBudgetMin = 0; 
            String strWarrantyStatusOfTarget = mainOprtunity.Trucks_With_Warranty__c;

            
            // calculate budget ranges for full score and partial score 
            if(mainOprtunity.Budget_Max__c != null){                
                intBudgetMax = intBudgetMax + mainOprtunity.Budget_Max__c;
                intpartialBudgetMax  = intpartialBudgetMax  + mainOprtunity.Budget_Max__c;
            }
            
            if(mainOprtunity.Budget_Min__c != null){            
                intBudgetMin =  mainOprtunity.Budget_Min__c - intAllowedBudgetDiffrence;
                intpartialBudgetMin  = mainOprtunity.Budget_Min__c - intAllowedBudgetDiffrenceForPartialPoint;
            }
            
            try {
                intMaxValueToFind  = getNumberValueOfSourceField(mainOprtunity, 'Year_Max__c');                
                
            }catch(Exception ex) {
                intMaxValueToFind = System.Today().year() + intAllowedYearDiffrence;
            }
            try {
                intMinValueToFind = getNumberValueOfSourceField(mainOprtunity, 'Year_Min__c');                
            }catch(Exception ex) {
                intMinValueToFind = System.Today().year() - intAllowedYearDiffrence;
            }  
            
            Integer intWebsitePrice;
            Integer intRetailPrice;  
            string strWarranty;
            
            for(OpportunityWrapper opportunityToCompare: listRecordsToCheck) {                                                  
                decScore = 0;               
                                                 
                // compare year Values of product records with source opportunity    
                if(compareLimitValues( Integer.ValueOF(opportunityToCompare.sourceRecord.get('FT_Year_of_Truck__c')), intAllowedYearDiffrence,
                 intMinValueToFind, intMaxValueToFind )){
                     decScore = decScore + 1;             
                }
                else if(compareLimitValues( Integer.ValueOF(opportunityToCompare.sourceRecord.get('FT_Year_of_Truck__c')), intAllowedYearDiffForPartialPoint,
                 intMinValueToFind, intMaxValueToFind )){                
                    decScore = decScore + 0.5;             
                }        
                
                //  pump Size.  If within the drop down range then a full point.  If the range above or below, then a partial point.  
                Boolean isMatchFound = false;
                try {
                    Integer valueToMatch=  getPumpSize(opportunityToCompare.sourceRecord, 'FT_Pump_GPM__c');                                      
                    for(string rangeValueToCompare : (mainOprtunity.pUMP__c).split(';')) {
                        if(matchRangeValue(valueToMatch, rangeValueToCompare)) {
                            isMatchFound = true;
                            break;
                        }                         
                    }
                }catch(exception ex) { 
                    system.debug('Error while Converting Range value::' + ex.getStackTraceString());                    
                }
                decScore = decScore + (isMatchFound ?  1 : 0.5);                
                                
                opportunityToCompare.intPoints = decScore;      
                
                 //  Tank Size"  If within the drop down range then a full point.  If the range above or below, then a partial point.                    
                if( matchRangeValue(getNumberValueOfSourceField(opportunityToCompare.sourceRecord, 'FT_Water_Tank_Size_only__c'), mainOprtunity.Tank_Size__c) ) {                  
                    decScore = decScore + 1;                      
                }else {
                    decScore = decScore + 0.5;
                }   
                
                 // Budget Range: Full point match if the opportunity range is within +/- $20,000 from either the website price or retail price. 
                 // From $20,000 to $50,000 is a partial match.

                intWebsitePrice = convertCurrencyTextToInteger(opportunityToCompare.sourceRecord, 'Website_Price__c');
                intRetailPrice = convertCurrencyTextToInteger(opportunityToCompare.sourceRecord, 'Retail_Price__c');                                
                
                //  calculate budget score for website price
                if( intWebsitePrice >= intBudgetMin && intWebsitePrice <= intBudgetMax ) {
                    decScore = decScore + 1;                      
                }else if( intWebsitePrice >= intpartialBudgetMin && intWebsitePrice <= intpartialBudgetMax  ) {
                    decScore = decScore + 0.5;                      
                } 
                
                //  calculate budget score for Retail Price
                if( intRetailPrice >= intBudgetMin && intRetailPrice <= intBudgetMax ) {
                    decScore = decScore + 1;                      
                }else if( intRetailPrice >= intpartialBudgetMin && intRetailPrice <= intpartialBudgetMax  ) {
                    decScore = decScore + 0.5;                      
                } 

                 //  Brand: Must be an exact match.  No partial points.                       
                //  build condition for FT - Fire Body Manufacturer (match with Brand)   
                try {  
                    // multiselect picklist field: Brand on opportunity {if Source string contains ALL or both or substring then match found}
                    if(compareStringValues(String.valueOf(opportunityToCompare.sourceRecord.get('FT_Fire_Body_Manufacturer__c')), mainOprtunity.Brand__c)){
                        decScore = decScore + 1;             
                    }                            
                }catch(Exception ex) {                        
                    system.debug('Error ::' + ex.getStackTraceString());
                }   
                
                // Chassis: Must be an exact match.  No partial points.                       
                // build condition for FT_Custom_Commercial__c (match with Brand)   
                try {  
                    //  multiselect picklist field: Brand on opportunity {if Source string contains ALL or both or substring then match found}
                     if(compareStringValues(mainOprtunity.Chassis__c,String.valueOf(opportunityToCompare.sourceRecord.get('FT_Custom_Commercial__c')))){

                        decScore = decScore + 1;             
                    }    
                    else {
                        decScore = decScore + 0.5;                                         
                    }                        
                }catch(Exception ex) {                        
                    system.debug('Error ::' + ex.getStackTraceString());
                }
                
                //  Mileage  If the truck is within the range then it's a full point match, else it is a 1/2 point.
                if(compareOpportunityMileage(Integer.Valueof(opportunityToCompare.sourceRecord.get('FT_Mileage__c')), mainOprtunity.FTF_Mileage__c )) {                    
                    decScore = decScore + 1;
                } else {
                    decScore = decScore + 0.5;
                }
              //  check Warranty                    
                try{
                    strWarranty = String.ValueOf(opportunityToCompare.sourceRecord.get('FTF_Warranty__c'));
                } catch(Exception ex) {                        
                    system.debug('Error ::' + ex.getStackTraceString());
                }  
                
                 //  Warranty : if  product.FTF_Warranty__c = yes  then opportunity.Trucks_With_Warranty__c = included
                //  if product.FTF_Warranty__c = No then opportunity.Trucks_With_Warranty__c = not included 
                //  if All then full point of score 
                if( (String.isBlank(strWarranty) || String.isBlank(strWarrantyStatusOfTarget) || strWarrantyStatusOfTarget.equalsIgnoreCase('All'))
                || (strWarranty.equalsIgnoreCase('yes') && (strWarrantyStatusOfTarget.equalsIgnoreCase('included')))
                || (strWarranty.equalsIgnoreCase('no') && (strWarrantyStatusOfTarget.equalsIgnoreCase('Not Included')))                       
                ){
                    decScore = decScore + 1; // full Warranty match
                    system.debug(' full Warranty match:::');
                }
                else {
                    decScore = decScore + 0.5; // partial Warranty match
                    system.debug(' partial Warranty match:::');
                }

                // region : Must be an exact match.  No partial points.                       
                try {  
                    //  multiselect picklist field: Geographic_Region__c on opportunity {if Source string contains ALL or both or substring then match found}                   
                    if(compareStringValues(mainOprtunity.Geographic_Region__c, String.valueOf(opportunityToCompare.sourceRecord.get('Geographic_Region_Formula_Field__c')))){
                        decScore = decScore + 1;             
                    }    
                    else {
                        decScore = decScore + 0.5;                                         
                    }                        
                }catch(Exception ex) {                        
                    system.debug('Error ::' + ex.getStackTraceString());
                }           
                opportunityToCompare.intPoints = decScore;                                                                                                 
            }
        }
        return listRecordsToCheck;

    }

    
    public Integer getPumpSize(Sobject sourceObject, String strFieldName){   
        try {
            return Integer.ValueOf(String.ValueOf(sourceObject.get(strFieldName)).substringBefore('GPM').deleteWhitespace());            
        }
        catch(Exception ex){
        }
        return null;    
    }
    
    public Integer getNumberValueOfSourceField(Sobject sourceObject, String strFieldName){
        try {
            return Integer.ValueOf(String.ValueOf(sourceObject.get(strFieldName)).deleteWhitespace());             
        }
        catch(Exception ex){
        }   
        return null;        
    }
    
    public Integer convertCurrencyTextToInteger (Sobject sourceObject, String strFieldName) {   
        try {                
            return Integer.valueOf(String.ValueOf(sourceObject.get(strFieldName)).replace('$',' ').deleteWhitespace().replace(',',''));
        }catch(Exception ex){
            return 0;
        }
    }
    
    private boolean compareOpportunityMileage(Integer intSourceMilage, String strTargetMilage) {
    
        if(intSourceMilage != null && (!String.isBlank(strTargetMilage))){
            
            //  if All Mileage return true 
            if(strTargetMilage.containsIgnoreCase('Any Mileage')) {
                return true;
            }
           
            else {
                try {
                    //  compare source mileage with target mileage 
                    if(strTargetMilage.containsIgnoreCase('Over')){         
                        //  convert target mileage string to integer and compare       
                        system.debug('intSourceMilage::' + intSourceMilage);                         
                        return (convertMileageToInteger(strTargetMilage, 'Over') <= intSourceMilage); 
                    }else {    
                        //  convert target mileage string to integer and compare           
                        return ( convertMileageToInteger(strTargetMilage, 'Under') > intSourceMilage);
                    }
                    
                }catch(Exception ex) {                        
                        system.debug('Error ::' + ex.getStackTraceString());
                }                 
            }
       
        }        
        return false;
    }
    
    //  @purpose conver string of mileage to integer by removing string identfier used for comparisosn 
    private Integer convertMileageToInteger (String strMileage, String strIdentifier) {
        try {
            return Integer.ValueOf(strMileage.substringAfter(strIdentifier).deleteWhitespace().remove(','));
        }catch(Exception ex) {                        
            system.debug('Error ::' + ex.getStackTraceString());
        } 
        return 0;
    }
  
    // @purpose Devide Range Value of opporuniy pump size in Max and Min Limit Compare That value     
    public Boolean matchRangeValue(Integer valueToMatch, String strRangeValue) {
        if(valueToMatch != null && strRangeValue != null ){
            if(strRangeValue.equalsIgnoreCase('All')) {
                return true;
            }else {
                Integer MaxValue;
                Integer MinValue;
                try {
                    MinValue = Integer.ValueOf(strRangeValue.substringBefore('-').deleteWhitespace());
                }catch(Exception ex) {
                    MinValue = 0;           
                }
                
                try {
                    MaxValue = Integer.ValueOf(strRangeValue.substringAfter('-').deleteWhitespace());                    
                }catch(Exception ex) {
                    MaxValue = MinValue;            
                }
                return (valueToMatch >=MinValue && valueToMatch <= MaxValue);  
            }
            
        }        
        return true;
    }    
    
    public Boolean compareLimitValues( Integer valueToCompare, Integer intAllowedDiffrence,Integer intMinValue, Integer intMaxValue) {
        if(valueToCompare != null || intAllowedDiffrence != null) {
            
            try{
                intMinValue = intMinValue - intAllowedDiffrence;
            }
            catch(exception ex){
                intMinValue = -(intAllowedDiffrence);
            }
            try{
                intMaxValue = intMaxValue + intAllowedDiffrence;
            }
            catch(exception ex){
                intMaxValue = (intAllowedDiffrence);
            }           
            
            return ((valueToCompare >= intMinValue) && (valueToCompare <= intMaxValue));
            
        }
        return true;    
    }
    
    // @purpose : compare string vlaues of multislect and singleseclt picklist
    public Boolean compareStringValues(String sourceString, String TargetString) {
        if(sourceString!= null && TargetString != null ) {
            List<String> searchliterals= new List<String>();
            
            try{
                searchliterals= sourceString.split(';');    // split the source string to get seprate values of multiselect picklilst 
            }
            catch(exception ex){
                system.debug('Error while spliting string ');                            
            }
            for(String searchliteral :searchliterals) {
                
                // If Search literal is All or Both consider it as perfect match as all values are covered by this literals       
                if(TargetString.containsIgnoreCase(searchliteral)|| searchliteral.equalsIgnoreCase('All') 
                   ||searchliteral.equalsIgnoreCase('Both') ||TargetString.containsIgnoreCase('All') ||
                   TargetString.equalsIgnoreCase('Both')
                  )
                {
                    return true;
                }                 
            }
            
        }
        return false;
    }       
}