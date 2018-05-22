/**
 * This class searches records on an SObject via SOQL query
 *
 * @author Aditya S. (Dreamwares) 
 * @createdDate 2016/5/30
 *
 */
public class SearchUtility{
        
    /**
     * Used to create query on the specified object, fields and keyword
     *
     * @param keyword to search
     * @param Sobject for search
     * @param List of fields to perform search on
     * @return String with all field criterias for query
     */
    public static String getQueryCriteriaForSObject( String queryKeyword, String SObjectName, List<String> listFields ){
        if( String.isNotBlank(queryKeyword) && String.isNotBlank(SObjectName)
            && listFields != null && !listFields.isEmpty() ){
            
            Double doubleKeyword;
            try{
                doubleKeyword = Double.valueof(queryKeyword);
            }
            catch(Exception e){
                System.debug('Couldnt parse number from queryKeyword! ::: '+e);
            }
            String strCriteria = '', strOR = ' OR ';
            Schema.DisplayType fieldDataType, urlType = Schema.DisplayType.URL,
                               stringType = Schema.DisplayType.String, picklistType = Schema.DisplayType.Picklist,
                               doubleType = Schema.DisplayType.Double, currencyType = Schema.DisplayType.Currency,
                               multiListType = Schema.DisplayType.MultipickList;
            
            Boolean isNonNumericWord = !queryKeyword.isNumeric();
            queryKeyword = isNonNumericWord ? '\'%'+ String.escapeSingleQuotes(queryKeyword) +'%\'' : querykeyword;		// escape single quotes to avoid soql injection
            
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(SObjectName).getDescribe().fields.getMap();
            
            for( String fieldName: listFields ){
            //System.debug(fieldName + 'fields Count : '+fieldMap.get(fieldName));
                try{
                	fieldDataType = fieldMap.get(fieldName).getDescribe().getType();
                }
                catch(Exception e){
                    System.debug('Error for '+SObjectName+' field : '+fieldName);
                }
                if( fieldDataType != null ){
                    if( isNonNumericWord ){
                        if( fieldDataType == stringType
                            || fieldDataType == picklistType
                            || fieldDataType == urlType ){                
                            strCriteria += fieldName + ' LIKE ' + queryKeyword + strOR;
                        }
                        else if( fieldDataType == multiListType ){
                                 strCriteria += fieldName + ' IN (' + queryKeyword + ')' + strOR;
                        }
                    }
                    else if( fieldDataType == currencyType
                             || fieldDataType == doubleType ){
                        strCriteria += fieldName + ' = ' + doubleKeyword + strOR;
                    }
                }
            }
            return strCriteria.removeEnd(strOR);
        }
        return null;
    }
    
    /**
     * Used to fetch records for the given query
     *
     * @param query
     * @return List of Sobjects
     */
    public static List<SObject> fetchSObjectMap( String query ){
        //System.debug('Query:'+query);
        try{
        	return String.isNotBlank(query) ? Database.query(query) : null;
    	}
        catch(Exception e){
            System.debug('Exception in fetching results from search query ::: '+ e);
        }
        return null;
    }
}