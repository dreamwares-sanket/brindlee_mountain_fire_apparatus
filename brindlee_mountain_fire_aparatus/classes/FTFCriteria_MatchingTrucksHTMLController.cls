/*
 * @description - This class is a controller for FTFCriteria_MatchingTrucksHTML VF Component used for finding matching products and creating HTML data for them. 
 * @createdDate - 18/5/2016
 * @createdBy   - Dreawares (Aditya)
 * 
 */ 
public class FTFCriteria_MatchingTrucksHTMLController {
    
    public Id FTFCriteriaId {get; set;}
    public String matchingTrucksHTML {
        get{
            if(String.isBlank( matchingTrucksHTML )){
                Fire_Truck_Finder_Criteria__c FTFCriteria = fetchFTFCriteria(FTFCriteriaId);
                matchingTrucksHTML = consolidateMatchingTrucksHTML( FTFCriteria );
                if(String.isNotBlank( matchingTrucksHTML )){
                    return ' <br/><br/> Check out the following truck(s) that match your criteria: <br/> ' + matchingTrucksHTML;
                }    
            }
            return matchingTrucksHTML;
        }
        set;
    }
    
    public FTFCriteria_MatchingTrucksHTMLController(){
        
    }
    
    private Fire_Truck_Finder_Criteria__c fetchFTFCriteria( Id FTFCriteriaId ){
        try{
            return [ SELECT Id, FTF_Apparatus_Type__c, FTF_Year_Min__c, FTF_Year_Max__c, FTF_Budget_Min__c, FTF_Budget_Max__c,
                            FTF_Tank_Size__c, FTF_Aerial_Length_Min__c, FTF_Aerial_Length_Max__c, FTF_Geographic_Region__c, FTF_Brands__c,
                            FTF_Chassis__c, FTF_Mileage__c, FTF_Trucks_With_Warranty__c, FTF_Pump_Size__c
                     FROM Fire_Truck_Finder_Criteria__c
                     WHERE Id=: FTFCriteriaId ];
        }
        catch(Exception e){
            System.debug('Exception in fetching FTF Criteria ::: '+ e);
        }
        return null;
    }
        
    private String consolidateMatchingTrucksHTML( Fire_Truck_Finder_Criteria__c FTFCriteria ){
        List<String> listProductFields = new List<String>{ 'Truck_Public_URL__c', 'VF_Main_Title__c', 'Description',
                                                               'Stock_Number__c', 'VF_Website_Price__c' };
        List<Product2> listMatchingProducts = fetchMatchingProducts( FTFCriteria, listProductFields );
        return createTrucksHTML( listMatchingProducts, listProductFields );        
    }
    
    /*
    @description - Consolidate Matching Trucks HTML from products
    @inputParam  - 1. List of Products
                   2. List of Product field API names
    @outputParam - Matching trucks HTML
    */
    private static String createTrucksHTML( List<Product2> ListProducts, List<String> listProductFields ){
        if( listProducts != null && !listProducts.isEmpty()
                && listProductFields != null && !listProductFields.isEmpty() ){
                
            String productHtml, consolidatedTrucksHtml = '', fieldValue, imageUrl,
                   truckHtmlTemplate = '<hr/><div style="padding:10px;"><table><tr><td><a href="Truck_Public_URL__c"><img width=\"150px\" src="ImageURL"/></a></td>'
                                       +'<td><table><tr><td>VF_Main_Title__c</td></tr><tr><td>Description</td></tr><tr><td>Stock Number #Stock_Number__c</td></tr>'
                                       +'<tr><td>VF_Website_Price__c</td></tr><tr><td><a href="Truck_Public_URL__c">View Truck Online</a></td></tr></table></td></tr></table></div>';
                                                          
            for( Product2 product : ListProducts ){
                productHtml = truckHtmlTemplate;
                for( String mergeField : listProductFields ){
                    fieldValue = (String)product.get(mergeField);
                    fieldValue = String.isNotBlank( fieldValue ) ? fieldValue : '';
                    productHtml = productHtml.replace( mergeField, fieldValue );
                }
                
                if( product.Cloud_Documents__r != null && !product.Cloud_Documents__r.isEmpty()
                        && String.isNotBlank( product.Cloud_Documents__r[0].Amazon_S3_Main_Thumbnail_URL__c )){     // get value for Image URL
                    imageUrl = product.Cloud_Documents__r[0].Amazon_S3_Main_Thumbnail_URL__c;
                    productHtml = productHtml.replace( 'ImageURL', imageUrl );
               }
                
                consolidatedTrucksHtml += productHtml;
            }
                    //System.debug('HTML:'+consolidatedTrucksHtml);
            return consolidatedTrucksHtml +'<hr/>';
        }
        return null;
    }
    
    /*
    @description - Fetch list of matching products 
    @inputParam  - 1. FTF Criteria record    2. List of product field API Names
    @outputParam - List of Product records
    */
    private static List<Product2> fetchMatchingProducts( Fire_Truck_Finder_Criteria__c FTFCriteria, List<String> listProductFields ){
        String queryCriteria = buildCriteriaQueryForProducts(FTFCriteria);
        if(String.isNotBlank(queryCriteria)){
            queryCriteria = String.format( 'SELECT {0}, (SELECT Amazon_S3_Main_Thumbnail_URL__c FROM Cloud_Documents__r WHERE Main_Thumbnail__c = True AND ' 
                                            +'Show_Online__c = TRUE LIMIT 1) FROM Product2 WHERE {1} AND IsActive = True AND Post_To_Website__c = True AND '
                                            +'status__c IN (\'\'Available\'\', \'\'HOD\'\', \'\'Internal HOD\'\', \'\'On Lease\'\') LIMIT 8',
                                                new List<String>{ String.join( listProductFields, ',' ), queryCriteria });
            //System.debug('Query : '+queryCriteria);
            return Database.query(queryCriteria);
        }
        return null;
    }
    
    /*
    @description - Get query criteria string for fetching matching products for FTF Criteria
    @inputParam  - FTF Criteria record
    @outputParam - Query dynamic criteria part of SOQL query
    */
    @testVisible
    public static String buildCriteriaQueryForProducts( Fire_Truck_Finder_Criteria__c FTFCriteria ){
        if( FTFCriteria != null ){
            String lessOrEquals = '<=', greaterOrEquals = '>=',
            queryCriteria = addApparatusTypeCriteria( FTFCriteria.FTF_Apparatus_Type__c );
            
            queryCriteria += addNumericCondition( 'FT_Year_of_truck__c', greaterOrEquals, FTFCriteria.FTF_Year_Min__c );
            queryCriteria += addNumericCondition( 'FT_Year_of_truck__c', lessOrEquals, FTFCriteria.FTF_Year_Max__c );
            queryCriteria += addNumericCondition( 'VF_Sort_By_Budget_Range__c', greaterOrEquals, FTFCriteria.FTF_Budget_Min__c );
            queryCriteria += addNumericCondition( 'VF_Sort_By_Budget_Range__c', lessOrEquals, FTFCriteria.FTF_Budget_Max__c );
            
            queryCriteria += generateRangeCriteria( 'VF_Sort_By_Pump_Size__c', FTFCriteria.FTF_Pump_Size__c );
            queryCriteria += generateRangeCriteria( 'VF_Sort_By_Tank_Size__c', FTFCriteria.FTF_Tank_Size__c );
            
            queryCriteria += getCriteriaForAerialLength( FTFCriteria.FTF_Aerial_Length_Min__c, FTFCriteria.FTF_Aerial_Length_Max__c );
            
            queryCriteria += getCriteriaFromMultiselectVal( 'Geographic_Region_Formula_Field__c', FTFCriteria.FTF_Geographic_Region__c );
            queryCriteria += getCriteriaFromMultiselectVal( 'FT_Fire_Body_Manufacturer__c', FTFCriteria.FTF_Brands__c );
            
            queryCriteria += addChassisCriteria( FTFCriteria.FTF_Chassis__c );
            queryCriteria += addMileageCriteria( FTFCriteria.FTF_Mileage__c );
            queryCriteria += addWarrantyCriteria( FTFCriteria.FTF_Trucks_With_Warranty__c );
            
            //System.debug('Query : '+ queryCriteria );
            return queryCriteria.removeEnd(' AND ');
        }
        return null;
    }
    
    /*
    @description - Add criteria for Product's Aerial Length
    @inputParam  - 1. FTF Criteria Minimum  2. FTF Criteria Maximum 
    @outputParam - products matching criteria 
    */
    @testVisible
    private static String getCriteriaForAerialLength( String minimum, String maximum ){
        if( String.isNotBlank(minimum) && String.isNotBlank(maximum)){
            String strAerialLengthAPIName = 'VF_Sort_By_Aerial_Length__c';
            if( maximum.contains('+') ){
                return strAerialLengthAPIName + ' >= ' + minimum + ' AND ';
            }
            else{
                return String.format('{0} >= {1} AND {0} <= {2} AND ', new List<String>{ strAerialLengthAPIName, minimum, maximum });
            }
        }
        return '';
    }
    
    /*
    @description - Add criteria for Product's Apparatus Type field
    @inputParam  - 1. FTF Criteria field value
    @outputParam - product matching criteria 
    */
    @testVisible
    private static String addApparatusTypeCriteria( String FTFCriteriaVal ){
        if( String.isNotBlank(FTFCriteriaVal) ){
            return FTFCriteriaVal.equals('All') ? '' : 'ApparatusType__c includes (\'' + FTFCriteriaVal + '\') AND ';
        }
        return '';
    }
    
    /*
    @description - Add criteria for Numeric condition
    @inputParam  - 1. Product field name 2. condition string
                   3. Decimal value for FTF Criteria field
    @outputParam - product matching criteria 
    */
    @testVisible
    private static String addNumericCondition( String productField, String conditionalLiteral, Decimal FTFCriteriaVal ){
        if( String.isNotBlank(conditionalLiteral) && String.isNotBlank(productField)
                && FTFCriteriaVal != null ){
            return String.format('{0} {1} {2} AND ', new List<String>{ productField, conditionalLiteral, '' + FTFCriteriaVal });
        }
        return null;
    }
    
    /*
    @description - Generate criteria over a range
    @inputParam  - 1. Fieldname     2. FieldValue
    @outputParam - criteria values for a field 
    */
    @testVisible
    private static String generateRangeCriteria( String productField, String FTFCriteriaVal ){
        String strCriteria = '';
        if( String.isNotBlank(FTFCriteriaVal) ){
            if( FTFCriteriaVal.equalsIgnoreCase('All') ){
                return strCriteria;     // return bank string for no criteria
            }
            String[] arrNumRange = FTFCriteriaVal.split('-');    // split the range
            
            if( arrNumRange != null ){           // get string for range criteria
                if( arrNumRange.size() == 2 ){  // range with minima at 1st location and maxima at 2nd location
                    String initialOperator = arrNumRange[0].equals('0') ? '>' : '>=';
                    
                    strCriteria = String.format('{0}{1}{2} AND {3}<={4} AND ',
                                                new String[]{ productField, initialOperator, arrNumRange[0],
                                                    productField, arrNumRange[1] });
                }
                else if( arrNumRange.size() == 1 ){
                    strCriteria = productField + '>=' + arrNumRange[0] + ' AND ';
                }
            }
        }
        return strCriteria;
    }
    
    /*
    @description - Generate criteria over a multiselect value
    @inputParam  - 1. Product field     2. FTF Criteria field value
    */
    @testVisible
    private static String getCriteriaFromMultiselectVal( String productField, String FTFCriteriaVal ){
        if( String.isNotblank(productField) && String.isNotblank(FTFCriteriaVal) ){
            if( FTFCriteriaVal.equals('All') ){
                return '';
            }
            return String.format('{0} in ({1}) AND ', new List<String>{ productField, getQuotedValues(FTFCriteriaVal) });
        }
        return '';
    }
    
    
    /*
    @description - Generate criteria over a range
    @inputParam  - FTF Criteria chassis field value
    */
    @testVisible
    private static String addChassisCriteria( String FTFCriteriaVal ){
        if( String.isNotBlank(FTFCriteriaVal) ){
            if(FTFCriteriaVal.equals('Both')){
                return '';
            }
            return 'FT_Custom_Commercial__c = \''+ FTFCriteriaVal +'\' AND ';
        }
        return '';
    }  
    
    
    /*
    @description - Generate criteria for Mileage
    @inputParam  - 1. FTF Criteria Mileage 
    */ 
    @testVisible
    private static String addMileageCriteria( String FTFMileage ){
        if( String.isNotBlank(FTFMileage) ){
            if( FTFMileage.equals('Any Mileage')){
                return '';
            }
            String conditionalOperator;
            if( FTFMileage.contains('Under') ){
                conditionalOperator = '<=';
            }
            else if( FTFMileage.contains('Over') ){
                conditionalOperator = '>=';
            }
            if( String.isNotEmpty(conditionalOperator) ){
                return String.format('FT_Mileage__c {0} {1} AND ',
                                        new List<String>{ conditionalOperator, ConformToNumericString( FTFMileage ) });
            }
        }
        return '';
    }
    
    
    /*
    @description - Generate criteria for Warranty field
    @inputParam  - 1. FTF Criteria field value
    */
    @testVisible
    private static String addWarrantyCriteria( String FTFCriteriaVal ){
        if( String.isNotBlank(FTFCriteriaVal) ){
            if( FTFCriteriaVal.equals('All') ){
                return '';
            }
            String strBooleanVal;
            if( FTFCriteriaVal.equals('Included') ){
                strBooleanVal = 'true';
            }
            else if( FTFCriteriaVal.equals('Not Included') ){
                strBooleanVal = 'false';
            }
            return 'VF_Sort_By_Has_Warranty__c = ' + strBooleanVal + ' AND ';
        }
        return '';
    }
    
    
    /*
    @description - Get Numeric string for comparison
    @inputParam  - 1. FieldValue 
    */ 
    private static String ConformToNumericString( String strValue ){
        return String.isNotBlank(strValue)? strValue.replaceAll('(Under)|(Over)|( )|(,)','') : '0';
    }
    
    /*
    @description - get comma seperated quoted values from multiselected values
    @inputParam  - 1 FTF Criteria  field value
    */ 
    private static String getQuotedValues( String FTFCriteriaVal ){
        if( String.isNotBlank(FTFCriteriaVal) ){
            String strQuoteEscapedString = '';
            for( String currentVal : FTFCriteriaVal.split(';') ){
                strQuoteEscapedString += '\'' + currentVal + '\',';
            }
            return strQuoteEscapedString.removeEnd(',');
        }
        return '';
    }
    
}