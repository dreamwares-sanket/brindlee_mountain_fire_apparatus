/*
 * @description - Controller class for VF page SearchResults used to show results 
 *                from search box
 * @dateCreated - 08/09/2015
 * @createdBy   - Dreamwares
 */
public with sharing class SearchResultsController {
    
    public Transient List<Product2> listProducts{ get; set; }    // List for main results with entire search string
    public Transient List<Product2> listLooseEquipments { get; set; }
    
    public Transient List<Product2> listExtraProducts{ get; set; }        // Lists for search results with keywords seperated
    public Transient List<Product2> listExtraLooseEquipments { get; set; }
    
    public Transient String strMessage{ get; set; }
    public Transient String strExtraResultsMsg{ get; set; }
      
    public Boolean showMoreRecsLink { get; set; }    // decides to show/hide the load more results link
    
    public SearchResultsController(){    // constructor
        Map<String, String> mapParams = Apexpages.CurrentPage().getparameters();
        String strStockNumber = mapParams.get('stockNo');     // if page is referred from WebsiteUrlRewriter class
        
        if( String.isNotBlank(strStockNumber)){      // search only for similar stock numbers
            getSearchResultsForStockNumbers(strStockNumber);
        }
        else{   
            String searchParam =mapParams.get('search');    // search on stock no., title and description
            
            if( String.isNotBlank( searchParam )){
                System.debug('*'+ searchParam+'*');
                searchParam = searchParam.trim();
                showMoreRecsLink = searchParam.containsWhiteSpace();    // show link if string is seperable by spaces
            
                searchTrucks(searchParam);    // fetch products
                searchLooseEquipments(searchParam);
                
                if( ( listProducts != null && !listProducts.isEmpty() )
                        || ( listLooseEquipments != null && !listLooseEquipments.isEmpty() )){
                   integer resultSize = listProducts.size() + listLooseEquipments.size();
                   strMessage = 'Showing '+ resultSize +' result(s) for <b>"'+ searchParam + '"</b>:';
                }
                else if( listProducts.isEmpty() && listLooseEquipments.isEmpty() ){        // if no matches found then automatically find extra matches
                   //strMessage = 'No results found!!';
                   fetchMoreResults( false );
                }
            }
            else{
                strMessage = 'Please enter a search query!!';
            }
        }
    }
    
    public void invokeFetchMoreResults(){
        fetchMoreResults( true );
    }
    
    /*
        Fetch trucks and loose equipments by breaking down the search string and then searching on all req. fields
        @param - denotes if main results were found
    */
    public void fetchMoreResults( Boolean doMainResultsExist ){
        String search = Apexpages.CurrentPage().getparameters().get('search');
        
        if( String.isNotBlank( search )){
            search = search.trim();
            List<String> listKeywords = search.split(' ');
            
            if( listKeywords != null && !listKeywords.isEmpty() ){
                String productsSearchStr = '', looseEqpmntSearchStr = '';
                
                for( String keyword : listKeywords ){    // create a query for all search fields with every piece of the string
                    keyword = String.escapeSingleQuotes(keyword);
                    productsSearchStr += ' Stock_Number__c = \'' + keyword + '\' OR VF_Main_Title__c LIKE \'%' + keyword
                                            + '%\' OR mainDescription__c LIKE \'%' + keyword + '%\' OR';
                                            
                    looseEqpmntSearchStr += ' Loose_Equipment_Type__c LIKE \'%'+ keyword +'%\' OR Name LIKE \'%'+ keyword
                                            +'%\' OR Description LIKE \'%'+ keyword + '%\' OR';
                }
                productsSearchStr = productsSearchStr.removeEnd(' OR');
                looseEqpmntSearchStr =looseEqpmntSearchStr.removeEnd(' OR');
                
                listExtraProducts = fetchExtraTrucks( productsSearchStr, search );
                listExtraLooseEquipments = fetchExtraLooseEqpmnts( looseEqpmntSearchStr, search );
                
                integer sizeProducts = ( listExtraProducts == null ) ? 0 : listExtraProducts.size(),
                        sizeLooseEqpmnts = ( listExtraLooseEquipments == null ) ? 0 : listExtraLooseEquipments.size(),
                        countRecs = sizeProducts + sizeLooseEqpmnts;
                
                if( countRecs > 0 ){
                    if( doMainResultsExist ){
                        strExtraResultsMsg = 'Showing '+ countRecs + ' additional result(s) for <b>"'+ search + '"</b>:';
                    }
                    else{
                        strExtraResultsMsg = 'Showing '+ countRecs + ' result(s) for <b>"'+ search + '"</b>:';
                    }
                }
                else{
                    strExtraResultsMsg = 'Sorry, No Results Found!!';
                }        
            }
        }
        showMoreRecsLink = false;
    }
    
    /*
        Fetch truck records for given search conditions and not matching given keyword (to eliminate duplicates)
        @param Search conditions string to use in query
        @param Search string - containing entire search
    */
    private List<Product2> fetchExtraTrucks( String searchConditions, String searchStr ){
        if( String.isNotBlank( searchConditions )){
            // conditions to exclude main products from results
            String mainProdsExcl = 'Stock_Number__c != \'' + searchStr + '\' AND (NOT VF_Main_Title__c LIKE \'%' + searchStr + '%\') AND (NOT mainDescription__c LIKE \'%' + searchStr + '%\')',
                   productsQuery = 'SELECT Id, VF_Main_Title__c, VF_Additional_Pricing_Text__c, Description,'
                                            +'Truck_Public_URL__c, VF_Website_Price__c, VF_Sort_By_Budget_Range__c, RecordType.Name,'
                                            +'( SELECT Id, Amazon_S3_Image_URL__c FROM Cloud_Documents__r '
                                               +'WHERE Main_Thumbnail__c = TRUE AND Show_Online__c = TRUE LIMIT 1) '
                                    +'FROM Product2 '
                                    +'WHERE ( '+ searchConditions +' ) AND '
                                    + mainProdsExcl
                                    +' AND Post_To_Website__c = True AND RecordType.Name=\'Trucks\' '
                                           +'AND ( status__c=\'Available\' '
                                                 +'OR status__c=\'Call For Pricing\' '
                                                 +'OR status__c=\'Internal HOD\' ) '
                                     +'ORDER BY FT_Year_of_Truck__c DESC '
                                     +'LIMIT 1000';
             try{
                 return database.query(productsQuery);
             }
             catch( Exception e ){
                 System.debug('Exception in fetching extra truc records : '+e);
             }
        }
        return null;
    }
    
    /*
        Fetch Loose Equipment records for given search conditions and not matching given keyword (to eliminate duplicates)
        @param Search conditions string to use in query
        @param Search string - containing entire search
    */
    private List<Product2> fetchExtraLooseEqpmnts( String searchConditions, String searchStr ){
        if( String.isNotBlank( searchConditions )){
            // conditions to exclude main Loose Equipments from results                         
            String mainLEExcl = '(NOT Loose_Equipment_Type__c LIKE \'%'+ searchStr +'%\') AND (NOT Name LIKE \'%'+ searchStr
                                        +'%\') AND (NOT Description LIKE \'%'+ searchStr + '%\')',
                   looseEqpmntQuery = 'SELECT RecordType.Name, Description, Name, Equipment_Price__c,'
                                                +'( SELECT Id, Amazon_S3_Image_URL__c '
                                                  +'FROM Cloud_Documents__r '
                                                  +'WHERE Main_Thumbnail__c = TRUE '
                                                  +'AND Show_Online__c = TRUE LIMIT 1) '
                                        +'FROM Product2 WHERE ( '+ searchConditions +' ) AND '
                                        + mainLEExcl
                                        +'AND Equipment_Status__c = \'Active\' '
                                        +'AND RecordType.Name  = \'Loose Equipment\' '
                                        +'ORDER BY CreatedDate DESC LIMIT 1000 ';
            try{
                 return database.query(looseEqpmntQuery);
            }
            catch( Exception e ){
                System.debug('Exception in fetching extra Loose Equipments: '+e);
            }
        }
        return null;
    }
    
    /*
    @description - fetch product records having similar stock numbers (same range). This method is invoked in case
                   a user changes the stock number of a product from AvailableTruckDetail and no match is found
    */
    private void getSearchResultsForStockNumbers(String strStockNumber){
        String strSearchStockNumber;
        integer strlength = strStockNumber.length();
        // consider search for products on same range of stock numbers
        strSearchStockNumber =  ( strlength >= 5 )  
                                ? strStockNumber.subString( 0, strlength-1 )        // search for input string with one less character 
                                : strStockNumber;
        try{
            listProducts = new List< Product2 >([SELECT Id, VF_Main_Title__c, VF_Additional_Pricing_Text__c, Description, 
                                                           Truck_Public_URL__c, VF_Website_Price__c, VF_Sort_By_Budget_Range__c,
                                                       ( SELECT Id, Amazon_S3_Image_URL__c 
                                                         FROM Cloud_Documents__r 
                                                         WHERE Main_Thumbnail__c = TRUE AND 
                                                             Show_Online__c = TRUE LIMIT 1) 
                                                 FROM Product2
                                                 WHERE Stock_Number__c LIKE :'%'+strSearchStockNumber+'%'
                                                       AND Post_To_Website__c = True
                                                       AND RecordType.Name ='Trucks'
                                                       AND ( status__c='Available'
                                                             OR status__c='Call For Pricing'
                                                             OR status__c='Internal HOD' )
                                                 ORDER BY FT_Year_of_Truck__c DESC //Updated on 11/14/2015 to support Fire Truck object
                                                 LIMIT 1000]);
             //System.debug('listProducts :'+listProducts + ' strStockNumber : '+strSearchStockNumber );
       }
       catch( Exception e ){
           System.debug('Exception in fetching search results::: '+ e);
       }
       
       if( listProducts != null && listProducts.size()>0 ){
           strMessage = 'No Results found for <b>"'+ strStockNumber + '"</b>. Are you searching for one of these?';
       }
       else{
           strMessage = 'No results found!!';
       }       
    }
    
    /*
        Fetch products records ( trucks type ) with input search value
        @param search param
    */
    private void searchTrucks(String strSearch){
        try{
            listProducts = new List<Product2>( [ SELECT Id, VF_Main_Title__c, VF_Additional_Pricing_Text__c, Description, 
                                                        Truck_Public_URL__c, VF_Website_Price__c, VF_Sort_By_Budget_Range__c, RecordType.Name,
                                                        ( SELECT Id, Amazon_S3_Image_URL__c 
                                                          FROM Cloud_Documents__r 
                                                          WHERE Main_Thumbnail__c = TRUE AND 
                                                              Show_Online__c = TRUE LIMIT 1) 
                                                 FROM Product2
                                                 WHERE ( Stock_Number__c =: strSearch
                                                         OR VF_Main_Title__c LIKE :'%'+strSearch+'%'
                                                         OR mainDescription__c LIKE :'%'+strSearch+'%' )
                                                       AND Post_To_Website__c = True
                                                       AND RecordType.Name ='Trucks'
                                                       AND ( status__c='Available'
                                                             OR status__c='Call For Pricing'
                                                             OR status__c='Internal HOD' )
                                                 ORDER BY FT_Year_of_Truck__c DESC //Updated on 11/14/2015 to support Fire Truck object
                                                 LIMIT 1000 ]);
        }
        catch( Exception e ){
            System.debug('Exception in fetching search results::: '+ e);
        }
    }
    
    /*
        Fetch products records ( Loose Equipment type ) with input search value
        @param search param
    */
    private void searchLooseEquipments(String strSearch){
        if( String.isNotBlank(strSearch) ){
            //strSearch = '%'+String.escapeSingleQuotes(strSearch)+'%';    // causes exception for single quotes in query
            strSearch = '%'+strSearch+'%';
            try{
                listLooseEquipments = new List<Product2>([ SELECT RecordType.Name, Description, Name, Equipment_Price__c,
                                                                  ( SELECT Id, Amazon_S3_Image_URL__c 
                                                                    FROM Cloud_Documents__r 
                                                                    WHERE Main_Thumbnail__c = TRUE
                                                                          AND Show_Online__c = TRUE LIMIT 1) 
                                                           FROM Product2
                                                           WHERE ( Loose_Equipment_Type__c LIKE :strSearch
                                                                   OR Name LIKE :strSearch
                                                                   OR Description LIKE :strSearch )
                                                                 AND Equipment_Status__c = 'Active'
                                                                 AND RecordType.Name  = 'Loose Equipment'
                                                           ORDER BY CreatedDate DESC
                                                           LIMIT 1000 ]);
            }
            catch( Exception e ){
                System.debug('Exception in fetching search results::: '+ e);
            }
        }
    }
}