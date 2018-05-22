/*
 * @description - Fetch and filter Contact and Lead records having mathcing Product records.
 * @createdBy   - Dreamwares 
 * @createdDate - 27-11-0215
 * @lastModifiedDate - 20/4/2016
 */ 
public class FireTruckFinder_Handler {
    
    /*
    @description - Fetch Product records inserted in the last hour and
                   having Add to Fire Truck Finder field checked
    @outputParam - List of Products created / updated in the last hour.
    @calledFrom  - Execute method of FireTruckFinder_Scheduler
    */    
    public static List<Product2> fetchProducts(){
        //DateTime previousHour = System.Now().addHours(-1);
        //Id truckRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Trucks').getRecordTypeId();
        try{
            return [ SELECT Id, apparatusType__c, FT_Fire_Body_Manufacturer__c, VF_Sort_By_Budget_Range__c, FT_Custom_Commercial__c,
                            VF_Sort_By_Pump_Size__c, VF_Sort_By_Tank_Size__c, VF_Sort_By_Has_Warranty__c, FT_Year_of_Truck__c,
                            Truck_Public_URL__c, VF_Main_Title__c, Description, Stock_Number__c, VF_Website_Price__c, Geographic_Region_Formula_Field__c,
                            FT_Aerial_Length__c, FT_Mileage__c, FT_Four_By_Four__c,
                            ( SELECT Amazon_S3_Main_Thumbnail_URL__c
                              FROM Cloud_Documents__r
                              WHERE Main_Thumbnail__c = True AND 
                                    Show_Online__c = TRUE LIMIT 1 )
                     FROM Product2
                     WHERE RecordTypeId =: Utilities.getTruckRecordTypeId()
                           AND Stock_Number__c != null
                           AND IsActive = True 
                           AND Post_To_Website__c = True 
                           AND Add_to_Fire_Truck_Finder__c = True
                           AND status__c IN ('Available', 'HOD', 'Internal HOD', 'On Lease') ];
 /*
 MD 12/14: removed the previousHour WHERE clause.  For testing we will only include trucks with
 Add_to_Fire_Truck_Finder checked.
 
 Previous lines 29-30::
 
 AND ( Add_to_Fire_Truck_Finder__c = True
    OR CreatedDate >=: previousHour ) ];
 

 */          
                       
        }
        catch(Exception e){
            System.debug('Exception in fetching Products ::: ' +  e );
        }
        return null;
    }
    
    /*
    @description - Fetch products from product Ids and update the Products
    @calledFrom - Execute method of Scheduler
     */
    public static void updateProducts( List<Product2> listProducts ){
        if( listProducts != null && !listProducts.isEmpty() ){
            
            for( Product2 product : listProducts){
                product.Add_To_Fire_Truck_Finder__c = False;
            }
            
            try{
                update listProducts;
            }  
            catch( Exception e ){
                System.debug('Exception in udpating products :::' +e);
            }
        }
    }
    
    /*
    @description - fetch Truck Finder for existing Products
    @inputParam  - 1. list of Product records
    @ouputParams - List of Fire Truck Finder records
    @calledFrom  - Execute method of scheduler
    */
    public static List<Fire_Truck_Finder__c> fetchTruckFinders( List<Product2> listProducts ){
        if( listProducts != null && !listProducts.isEmpty() ){
            try{
                return [ SELECT Id, Contact__c, Product__c, Fire_Truck_Finder_Criteria__c
                         FROM Fire_Truck_Finder__c
                         WHERE Product__c IN : listProducts ];
            }
            catch(Exception e){
                System.debug('Exception in fetching Truck Finder records ::: ' + e);
            }
        }
        return null;
    }
    
    /*
     * @description - Used to fetch products associated to a specific keyword via the list of i/p fields
     * @inputParams - 1. keyword to search  2. Sobject for search
     *                3. List of fields to perform search on
     * @outputParam - List of products
     */
    public static void findProductsByKeywords( List<Fire_Truck_Finder_Criteria__c> listFTFCriteria,
                                               Map<Id, Set<Product2>> mapFTFCriteriaIdToProducts,
                                               Map<Id, Set<Id>> mapProductIdToSetFTFCriteriaId ){
        if( listFTFCriteria != null && !listFTFCriteria.isEmpty() ){
            if( mapFTFCriteriaIdToProducts == null ){
                mapFTFCriteriaIdToProducts = new Map<Id, Set<Product2>>();
            }
            
            List<String> listFields = getFieldListForProductSearch();
            if( listFields != null || !listFields.isEmpty() ){
                searchProductsByKeyword( listFields, listFTFCriteria, mapFTFCriteriaIdToProducts, mapProductIdToSetFTFCriteriaId );
            }
        }
    }
    
    /*
     * @description - get fields for queyr criteria from custom settings
     * @outputParam - List of Strings (fields)
     */
    private static List<String> getFieldListForProductSearch(){
        List<FTFKeywordSearchFields__c> listKeyWordSearchFields = FTFKeywordSearchFields__c.getAll().values();
        List<String> listFields = new List<String>();
        for( FTFKeywordSearchFields__c searchFields : listKeyWordSearchFields ){
            listFields.addAll( searchFields.fields__c.deleteWhitespace().split(',') );
        }
        return listFields;
    }
    
    /*
     * @description - Used to fetch products associated to a specific keyword via the list of i/p fields
     * @inputParams - 1. List of fields to perform search on
                      2. List of FTF Criteria records
     *                3. Map of FTF Criteria Id to Set of already matches products
                      4. Map of Product Id to existing FTF Criteria matches
     * @outputParam - List of products
     */
    public static List<Product2> searchProductsByKeyword( List<String> listFields,
                                                          List<Fire_Truck_Finder_Criteria__c> listFTFCriteria,
                                                          Map<Id, Set<Product2>> mapFTFCriteriaIdToProducts,
                                                          Map<Id, Set<Id>> mapProductIdToSetFTFCriteriaId ){
        if( listFields != null && !listFields.isEmpty()
            && listFTFCriteria != null && !listFTFCriteria.isEmpty() ){

            String SObjectName = 'Product2', query,
                   queryTemplate = String.join(new List<String>{
                       					'SELECT Name,Truck_Public_URL__c,VF_Main_Title__c,Description,Stock_Number__c,VF_Website_Price__c,',
                                        '(SELECT Amazon_S3_Main_Thumbnail_URL__c FROM Cloud_Documents__r WHERE Main_Thumbnail__c = True',
                                        'AND Show_Online__c = TRUE LIMIT 1) FROM Product2 WHERE RecordTypeId = \'\'{0}\'\' AND',
                                        'Stock_Number__c != null AND IsActive = True',
                                        'AND Post_To_Website__c = True AND Add_to_Fire_Truck_Finder__c = True AND status__c IN',
                                        '(\'\'Available\'\',\'\'HOD\'\', \'\'Internal HOD\'\', \'\'On Lease\'\')'},' ');
                
            Map<Id, Product2> mapFetchedProducts, mapMatchedProducts;
            Id ftfCriteriaId;
            List<Product2> listProducts;
            for( Fire_Truck_Finder_Criteria__c ftfCriteria : listFTFCriteria ){
                ftfCriteriaId = ftfCriteria.Id;
                
                // fetch matching products for every FTF criteria record
                query = String.format( queryTemplate, new List<String>{ Utilities.getTruckRecordTypeId() });
                
                String keywordCriteria = SearchUtility.getQueryCriteriaForSObject( ftfCriteria.FTF_Keyword__c, SObjectName, listFields );
                if(String.isNotBlank( keywordCriteria )){
                    query += ' AND (' + keywordCriteria + ')';
                }
                //System.debug('QUERY_Final:'+query);
                
                listProducts = SearchUtility.fetchSObjectMap(query);
                mapFetchedProducts = new Map<Id,Product2>( listProducts );		// initialize the new matching products to a map
                //System.debug(JSON.serialize(mapFetchedProducts));
                
                if( mapFetchedProducts != null && !mapFetchedProducts.isEmpty() ){
                    
                    for( Id productId : mapFetchedProducts.keySet() ){        // select only if FTF matches do not already exist
                        if( isTruckFinderExists( mapProductIdToSetFTFCriteriaId, ftfCriteriaId, productId )
                           	|| isProductAlreadyMatched( productId, mapFTFCriteriaIdToProducts.get(ftfCriteriaId) )){
                        		mapFetchedProducts.remove(productId);
                        }
                    }
                    if( !mapFetchedProducts.isEmpty() ){					// add the products for creating FTF records
                        if( mapFTFCriteriaIdToProducts.containsKey( ftfCriteriaId ) ){
                            mapFTFCriteriaIdToProducts.get( ftfCriteriaId ).addAll(mapFetchedProducts.values());
                        }
                        else{
                            mapFTFCriteriaIdToProducts.put( ftfCriteria.Id, new Set<Product2>(mapFetchedProducts.values()) );
                        }
                    }
                }
            }
        }
        return null;
    }
    
    /*
     * @description - Check if the product has already been matched with the FTF Criteria
     * @inputParams - 1. Product Id to check Set of already matched Products for a FTF Criteria record
     * @outputParam - List of products
     */
    @testVisible
    private static Boolean isProductAlreadyMatched( Id productId, Set<Product2> SetExistingProducts ){
        if(String.isNotBlank(productId) && SetExistingProducts != null && !SetExistingProducts.isEmpty() ){
            Map<Id, Product2> mapMatchedProducts = new Map<Id, Product2>();
            mapMatchedProducts.putAll( new List<Product2>(SetExistingProducts) );
            return mapMatchedProducts.containsKey(productId);
        }
        return false;
    }

    /*
    @description - 1. Used to filter SObject records matching the criteria 
                        2. create Fire Truck Finder records for matching Lead / Contacts records
    @inputParam  - 1. List of SObject      2. List of Products
    @ouputParams - Map Ids of Sobject to matched products
    @calledFrom  - Execute method of batchable
    */
    public static Map<Id, Set<Product2>> findNewMatches( List<Fire_Truck_Finder_Criteria__c> listFTFCriteria,
                                                                List<Product2> listProducts,
                                                                Map<Id, Set<Id>> mapProductIdToSetFTFCriteriaId ){
        if( listProducts != null && !listProducts.isEmpty()
                && listFTFCriteria != null && !listFTFCriteria.isEmpty()){
            Map<Id, Set<Product2>> mapFTFCriteriaIdToProducts = new Map<Id, Set<Product2>>();
            Id FTFCriteriaId;
                    
            for( Product2 currentProduct : listProducts ){
                for( Fire_Truck_Finder_Criteria__c currentFTFCriteria : listFTFCriteria ){
                    FTFCriteriaId = currentFTFCriteria.id;
                    
                    if( !isTruckFinderExists( mapProductIdToSetFTFCriteriaId, FTFCriteriaId, currentProduct.Id )
                            && isMatchTruckFinderFields(currentFTFCriteria, currentProduct)){

                        if( mapFTFCriteriaIdToProducts.containsKey(FTFCriteriaId) ){    // Add to map
                            mapFTFCriteriaIdToProducts.get(FTFCriteriaId).add(currentProduct);
                        }
                        else{
                            mapFTFCriteriaIdToProducts.put(FTFCriteriaId, new Set<Product2>{ currentProduct });
                        }
                    }
                    /*
                    else{
                        System.debug('Truck Not Found for :'+ FTFCriteriaId);
                    }*/
                }
            }
            return mapFTFCriteriaIdToProducts;
        }
        return null;
    }
    
    /*
    @description - Check if the pair of Contact / Lead and Product already exists in Fire Truck Finder
    @inputParams - 1. Map of Products to Set of FTF Criteria Id     2. FTF Criteria Id   3. Product Id
    @outputparams - Boolean result
     */ 
    private static Boolean isTruckFinderExists( Map<Id, Set<Id>> mapProductIdToSetFTFCriteriaId, Id FTFCriteriaId, Id ProductId ){
        if( mapProductIdToSetFTFCriteriaId != null && !mapProductIdToSetFTFCriteriaId.isEmpty()
                && String.isNotBlank(FTFCriteriaId) && String.isNotBlank(ProductId) ){

             return mapProductIdToSetFTFCriteriaId.containsKey(ProductId)
                    && mapProductIdToSetFTFCriteriaId.get(ProductId).contains(FTFCriteriaId);
        }
        return false;
    }
    
    /*
    @description - Create Map of existing matches for Product Id to set of assoc. FTF Criteria Id
    @inputParams - 1. List of Fire Truck Finder records
    @outputparams - Map Product Id to Set of FTF Criteria Ids
     */
    public static Map<Id, Set<Id>> createMapProductIdToSetFTFCriteriaId( List<Fire_Truck_Finder__c> listTruckFinders ){
        if(listTruckFinders != null && !listTruckFinders.isEmpty()){
            Map<Id, Set<Id>> mapProductIdToSetFTFCriteriaId = new Map<Id, Set<Id>>();
            Id ProductId;
            
            for( Fire_Truck_Finder__c truckFinder : listTruckFinders){
                 ProductId = truckFinder.product__c;
                   
                 if( String.isNotBlank(ProductId) && String.isNotBlank(truckFinder.Fire_Truck_Finder_Criteria__c)){
                     if( mapProductIdToSetFTFCriteriaId.containsKey(ProductId)){
                         mapProductIdToSetFTFCriteriaId.get(ProductId).add(truckFinder.Fire_Truck_Finder_Criteria__c);
                     }
                     else{
                         mapProductIdToSetFTFCriteriaId.put(ProductId, new Set<Id>{ truckFinder.Fire_Truck_Finder_Criteria__c });
                     }
                 }
             }
             return mapProductIdToSetFTFCriteriaId;
        }
        return null;
    }
        
    /*
    @description - Create Html data by replacing field values in the string.
    @inputParam  - Map of SObject Id to Product Id
    @ouputParams - Map of SObject Id to Html data
    @calledFrom  - updatePardotProspectsHtmlField method of Batch class
    */
    public static Map< Id, String > createMatchingTrucksHtml( Map<Id, Set<Product2>> mapFTFCriteriaIdToProducts, Map<Id, Fire_Truck_Finder_Criteria__c> mapIdToFTFCriteria ){
        if( mapFTFCriteriaIdToProducts != null && !mapFTFCriteriaIdToProducts.isEmpty()
                && mapIdToFTFCriteria != null && !mapIdToFTFCriteria.isEmpty() ){
            Map<Id, String> mapFTFCriteriaIdToTruckHtml = new Map<Id, String>();
            List<String> listProductFields = new List<String>{ 'Truck_Public_URL__c', 'VF_Main_Title__c', 'Description',
                                                               'Stock_Number__c', 'VF_Website_Price__c' };      
            String truckHtml, fieldValue, truckHtmlTemplate, imageUrl, editLinkHtml = '<hr><p>Click on the Edit_Link__c to edit your Truck Criteria.</p>';
                       
            for( Id FTFCriteriaId : mapFTFCriteriaIdToProducts.keySet() ){
                truckHtml = '';
                
                for(Product2 currentProduct : mapFTFCriteriaIdToProducts.get(FTFCriteriaId)){
                    truckHtmlTemplate = '<hr><div style="padding:10px;"><table><tr><td><a href="Truck_Public_URL__c"><img width=\"150px\" src="ImageURL" /></a></td><td><table>'
                                        + '<tr><td>VF_Main_Title__c</td></tr><tr><td>Description</td></tr><tr><td>Stock Number #Stock_Number__c</td></tr>'
                                        + '<tr><td>VF_Website_Price__c</td></tr><tr><td><a href="Truck_Public_URL__c">View Truck Online</a></td></tr></table></td></tr></table>'
                                        + '</div>';
                    truckHtmlTemplate = JSON.serialize( truckHtmlTemplate ).removeStart('"').removeEnd('"');
                    
                    for( String fieldName : listProductFields ){                                    // replace values for fields in list
                            fieldValue = (String)currentProduct.get( fieldName );
                            fieldValue = String.isNotBlank( fieldValue ) ? fieldValue : '';
                        truckHtmlTemplate = truckHtmlTemplate.replace(fieldName, fieldValue);
                    }
                    
                    if( currentProduct.Cloud_Documents__r != null &&
                            !currentProduct.Cloud_Documents__r.isEmpty() && 
                            String.isNotBlank( currentProduct.Cloud_Documents__r[0].Amazon_S3_Main_Thumbnail_URL__c )){     // get value for Image URL
                        imageUrl = currentProduct.Cloud_Documents__r[0].Amazon_S3_Main_Thumbnail_URL__c;
                        truckHtmlTemplate = truckHtmlTemplate.replace( 'ImageURL', imageUrl );
                    }
                    truckHtml = truckHtml + truckHtmlTemplate;
                }
                editLinkHtml = editLinkHtml.replace('Edit_Link__c', mapIdToFTFCriteria.get(FTFCriteriaId).Edit_Link__c );
                truckHtml += Json.serialize(editLinkHtml).removeStart('"').removeEnd('"');
                mapFTFCriteriaIdToTruckHtml.put(FTFCriteriaId, truckHtml);
            }
            return mapFTFCriteriaIdToTruckHtml;
        }
        return null;
    }
    
    /*
    @description - Used to compare FTF Criteria fields with Product fields to find a match
    @inputParam  - 1. FTF Criteria      2. Product 
    @outputParams - Boolean result
    @calledFrom  - findNewMatches method
    */
    public static Boolean isMatchTruckFinderFields( Fire_Truck_Finder_Criteria__c FTFCriteria, Product2 Product ){
        if( FTFCriteria != null && Product != null ){
            Boolean isMatched = true;
            isMatched = checkAerialLength( isMatched, FTFCriteria.FTF_Aerial_Length_Min__c,
                                                FTFCriteria.FTF_Aerial_Length_Max__c, conformStringForDecimal(Product.FT_Aerial_Length__c));
            isMatched = checkInclusionInRange( isMatched, FTFCriteria.FTF_Budget_Min__c, FTFCriteria.FTF_Budget_Max__c, Product.VF_Sort_By_Budget_Range__c );
            isMatched = checkInclusionInRange( isMatched, FTFCriteria.FTF_Year_Min__c, FTFCriteria.FTF_Year_Max__c, Product.FT_Year_of_Truck__c );
            isMatched = checkMileageCondition( isMatched, FTFCriteria.FTF_Mileage__c, Product.FT_Mileage__c );
            
            isMatched = checkSimilarConditons( isMatched, FTFCriteria.FTF_Apparatus_Type__c, Product.apparatusType__c );
            isMatched = checkMultiSelectInclusion( isMatched, FTFCriteria.FTF_Brands__c, Product.FT_Fire_Body_Manufacturer__c );
            isMatched = checkMultiSelectInclusion( isMatched, FTFCriteria.FTF_Geographic_Region__c, Product.Geographic_Region_Formula_Field__c );
            isMatched = checkMatchingConditons( isMatched, FTFCriteria.FTF_Chassis__c, Product.FT_Custom_Commercial__c );
            isMatched = checkRangeConditions( isMatched, FTFCriteria.FTF_Tank_Size__c, Product.VF_Sort_By_Tank_Size__c );
            //**old**isMatched = checkRangeConditions( isMatched, FTFCriteria.FTF_Pump_Size__c, Product.VF_Sort_By_Pump_Size__c );
            isMatched = checkRangeInMultiSelect( isMatched, FTFCriteria.FTF_Pump_Size__c, Product.VF_Sort_By_Pump_Size__c );
            isMatched = checkWarrantyConditions( isMatched, FTFCriteria.FTF_Trucks_With_Warranty__c, Product.VF_Sort_By_Has_Warranty__c );
            if(isMatched){
            	isMatched = ( FTFCriteria.FTF_Four_By_Four__c == Product.FT_Four_By_Four__c );
            }
            return isMatched;
        }
        return false;
    }
    
    /*
    @description  - Used to compare FTF Warranty with Products Warranty
    @inputParam   - 1. is previously matched      2. FTF Criteria's Warranty option     3. Product's Warranty Option
    @outputParams - Boolean result
    @calledFrom   - isMatchTruckFinderFields method
    */
    @testVisible
    private static Boolean checkWarrantyConditions(Boolean isMatched, String FTFWarrantyOption, Boolean isProductWarranteed ){
        if(isMatched && String.isNotBlank(FTFWarrantyOption) ){
            if( FTFWarrantyOption.equals('All')
                || ( FTFWarrantyOption.equals('Included') && isProductWarranteed )
                || ( FTFWarrantyOption.equals('Not Included') && !isProductWarranteed )){
                    return true;
             }
        }
        return false;
    }
    
    /*
    @description - Used to compare FTF Criterias Aerial Length range with Products Aerial Length
    @inputParam  - 1. is previously matched      2. FTF Min Aerial Length
                   3. FTF MAx Aerial Length      4. Products Aerial Length
    @outputParams - Is Matched 
    @calledFrom  - isMatchTruckFinderFields method
    */
    @testVisible
    private static Boolean checkAerialLength(Boolean isMatched, String FTFMinField, String FTFMaxField, Decimal productField){
        if(isMatched){
            if( String.isBlank(FTFMinField) && String.isBlank(FTFMaxField)){        // Aerial Length can be blank for matches
                return isMatched;
            }
            else if( String.isNotBlank(FTFMaxField) && FTFMaxField.contains('+')){
                return (conformStringForDecimal(FTFMinField) <= productField);
            }
            return checkInclusionInRange( isMatched, conformStringForDecimal(FTFMinField), conformStringForDecimal(FTFMaxField), productField );
        }
        return false;
    }
    
    /*
    @description - Compare Mileage from FTF Criteria and Product
    @inputParams - 1. Boolean ismatched     2. FTF Criteria Mileage
                   3. Product Mileage
    @outputparam - Boolean result
    @calledFrom  - isMatchTruckFinderFields
     */
    @testVisible
    private static Boolean checkMileageCondition(Boolean isMatched, String FTFField, Decimal productField){
        if(isMatched && String.isNotBlank(FTFField)){
            if(FTFField.equalsIgnoreCase('Any Mileage')){
                return true;
            }
            if(FTFField.contains('Under')){
                return (conformStringForDecimal(FTFField) >= productField);
            }
            if(FTFField.contains('Over')){
                return (conformStringForDecimal(FTFField) <= productField);
            }
        }
        return false;
    }
    
    /*
    @description - Compare Csv from FTF Criteria to the single value from Product
    @inputParams - 1. Boolean ismatched     2. CSV FTF Criteria field value
                   3. Product field value
    @outputparam - Boolean result
    @calledFrom  - isMatchTruckFinderFields
     */
    @testVisible
    private static Boolean checkMultiSelectInclusion(Boolean isMatched, String FTFField, String productField){
        if(isMatched && String.isNotBlank(FTFField)){
            if(FTFField.equalsIgnoreCase('all'))
                return true;
            
            if(String.isNotBlank(productField)){
                List<String> listChoices = FTFField.split(';');            
                for(String currentChoice : listChoices)
                    if(productField.equalsIgnoreCase(currentChoice))
                        return true;
            }
        }
        return false;
    }
    
    /*
    @description - Compare FTF Criteria min and max values with product field
    @inputParams - 1. Boolean ismatched     2. FTF Criteria min value
                   3. FTF Criteria max value    4. Product field value
    @outputparam - Boolean result
    @calledFrom  - isMatchTruckFinderFields
     */
    @testVisible
    private static Boolean checkInclusionInRange(Boolean isMatched, Decimal FTFMinField, Decimal FTFMaxField, Decimal productField){
        if(isMatched){
            return (productField >= FTFMinField && productField <= FTFMaxField);
        }
        return false;
    }
    
    @testVisible
    private static Boolean checkRangeInMultiSelect(Boolean isMatched, String FTFField, Decimal productField){
        if(isMatched){
            List<String> listRanges = FTFField.split(';');
            
            Boolean isRangeMatch, trueVal = true;
            for( String currentPumpSizeRange : listRanges ){
                isRangeMatch = checkRangeConditions( trueVal, currentPumpSizeRange, productField );
                if(isRangeMatch){
                    return true;
                }
            }
        }
        return false;
    }
    
    /*
    @description - Get decimal values from corresponding string values
    @inputParams - String field value
    @outputparam - Boolean result
    @calledFrom  - isMatchTruckFinderFields
     */
    private static Decimal conformStringForDecimal(String strValue){
        if(String.isNotBlank(strValue)){
            try{
                return Decimal.valueOf(strValue.replaceAll('(\\+)|(,)|(Under)|(Over)|( )',''));
            }
            catch(Exception e){
                System.debug('Exception in converting String to Decimal ::: '+ e);
            }
        }
        return 0;
    }
    
    /*
    @description - Compare string for value between a range condition
    @inputParams - 1. Boolean ismatched     2. FTF Criteria record field value (String)
                   3. Product field value
    @outputparam - result in the form of Boolean
    @calledFrom  - isMatchTruckFinderFields
     */
    @TestVisible
    private static Boolean checkRangeConditions( Boolean isMatched, String FTFField, Decimal productField ){
        if( isMatched ){
            if( String.isBlank( FTFField )
                || ( String.isNotBlank( FTFField ) && FTFField.equalsIgnoreCase('all'))){
                return true;
            }
            else if( productField != null && String.isNotBlank( FTFField ) ){
                String[] range = FTFField.split('-');
                if( range.size() == 1 && productField >= Decimal.valueOf( range[0] )){      // check single number
                    return true;
                }
                else if( range.size() == 2 ){                                               // check from a range
                    Decimal min, max;
                    try{
                        min = Decimal.valueOf( range[0] );
                        max = Decimal.valueOf( range[1] );
                    }
                    catch( Exception e ){
                        System.debug('Exception in getting decimal values from range ::: ' + e);
                    }
                    return ( min != null && max != null && productField >= min && productField <= max );
                }
            }
        }
        return false;
    }
    
    /*
    @description - Compare string for equals condition
    @inputParams - 1. Boolean ismatched     2.FTF Criteria record field value
                   3. Product field value
    @outputparam - result in the form of Boolean
    @calledFrom  - isMatchTruckFinderFields
     */ 
    @testVisible
    private static Boolean checkMatchingConditons( Boolean isMatched, String FTFField, String productField ){
        if(isMatched && String.isNotBlank(FTFField)){
            if( FTFField.equalsIgnoreCase('all')){
               return true;
            }
            if(String.isNotBlank(productField)){
                return FTFField.equals(productField);
            }
        }
        return false;
    }
    
    /*
    @description - Compare string for "contains" condition
    @inputParams - 1. Boolean ismatched     2. FTF Criteria record field value
                   3. Product field value
    @outputparam - result in the form of Boolean
    @calledFrom  - isMatchTruckFinderFields
     */ 
    public static Boolean checkSimilarConditons( Boolean isMatched, String FTFField, String productField ){
        if( isMatched && String.isNotBlank( FTFField ) ){
            if( FTFField.equalsIgnoreCase('all') ){
                return true;
            }
            if( String.isNotBlank( productField ) ){
                return productField.contains(FTFField);
            }
        }
        return false;
    }
    
    /*
    @description - Send email containing errorsto all Users eith Email Ids in parameter
    @inputParam  - 1. Errors    2. Comma seperated Email Ids
    @calledFrom  - Finish method of Batch class
    */
    public static void sendErrorMails( String errors, String emailIds ){
        if( String.isNotBlank( emailIds )){
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            String body;
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses( emailIds.split(','));                                  // split emailIds by ',' to get all email Ids
            mail.setSubject('Fire Truck Finder Errors / Exceptions');
            body = 'Hi User,<br/><br/>' + 'The following errors occured in the batch job : <br/>' + errors + '<br/>';
            mail.setHtmlBody( body );
            mails.add( mail );
            
            Messaging.SendEmailResult[] results;
            try{
                results = Messaging.sendEmail(mails);
            }
            catch( Exception e ){
                System.debug('Exception in sending emails ::: '+ e);
            }
            
            if( results != null && !results.isEmpty() ){
                for( Messaging.SendEmailResult currentResult : results ){
                    if( currentResult.isSuccess() ){
                        System.debug('Error Email Sent Successfully!!');
                    }
                    else{
                        System.debug('Error Email not Sent!!\n'+currentResult.getErrors());
                    }
                }
            }
        }
    }
}