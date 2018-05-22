/*
 * @description - Controller extension class for VF page AvailableTruckDetailView used to display
                  details of truck 
 * @dateCreated - 19/08/2015
 * @createdBy   - Dreamwares
 * @lastModifiedDate - 15/04/2016
 * @lastModifiedBy - Dreamwares
 */
public with sharing class AvailableTruckDetailViewController {
    
    public String strMainImageURL{get; set;}   // URL for main image
    public List<DragDropToCloud__Cloud_Documents__c> listCloudDocuments{get; set;}    // list of cloud docs to display in image gallery
    public List<Product2> listSimilarProducts{get; set;}
    public List<Comment_Generation__c> listCommentsToDisplay{get; set;}
    public String getCanonicalParams{get; set;}    // stocknumber/truckname(hyphenated)
    
    private List<Comment_Generation__c> listComments;
    
    public String AvailableTrucksUrl{
        get{
            if(String.isBlank(AvailableTrucksUrl)){
                AvailableTrucksUrl = buildAvailableTrucksUrl();
            }
            return AvailableTrucksUrl;
        }
        set;
    }
    
    public String getLoginCredentials(){
        List<AWS_Credentials__c> listAWSCredentials = AWS_Credentials__c.getAll().values();
        return !listAWSCredentials.isEmpty() ? JSON.serialize(listAWSCredentials[0]) : null;
    }
    
    /*
     @description - create url to return back to search results if url parameters exists for picklist criterias on AvailableTrucks page
     */ 
    private String buildAvailableTrucksUrl(){    
        String availableTrucksSearchResultsUrl = '';
        Map<String, String> mapPageParams =  ApexPages.CurrentPage().getParameters();
        //System.debug('mapPageParams :'+Json.serialize(mapPageParams ));
        
        List<String> listparams = new List<String>{'price','year','brand','pumpsize','tanksize','chassis','mileage','region','warranty','is4x4'};
        for( String parameter : listparams ){
            availableTrucksSearchResultsUrl += getUrlParameterString( mapPageParams, parameter );
        }
        availableTrucksSearchResultsUrl = availableTrucksSearchResultsUrl.replaceFirst('&','?');
                                                                                // prepend category to url
        availableTrucksSearchResultsUrl = mapPageParams.containsKey('category') 
                                          ? Utilities.getCanonicalCategoryValue( mapPageParams.get('category') ) + availableTrucksSearchResultsUrl
                                          : availableTrucksSearchResultsUrl;    
        
        return String.isNotBlank(availableTrucksSearchResultsUrl) ?  '/AvailableTrucks/' + availableTrucksSearchResultsUrl : null;  // prepend page name to url
    }
    
    /*
     @description - create name-value mapping to conform as a url param
     */ 
    private String getUrlParameterString( Map<String, String> mapPageParams, String param ){
        return mapPageParams.containsKey(param) ? String.format('&{0}={1}', new List<String>{ param, mapPageParams.get(param) }) : '';
    }
    
    public AvailableTruckDetailViewController(ApexPages.StandardController controller) {    // constructor
        fetchActiveComments();                                   // fetch comments for comment generaton 
        List<String> listFieldNames = new List<String>();
        listFieldNames.addAll( getFieldNamesFromComments());    // add all fields from set to list
        
        String query = createQueryForProduct( controller.getId(), listFieldNames );
        //System.debug('Query:'+query);
        Product2 objProduct = fetchProduct(query);
        if( objProduct != null ){
            generateComments( objProduct );
            fetchSimilarProducts( objProduct.Id, objProduct.apparatusType__c );
            fetchRelatedCloudDocs( objProduct.Id );
            getCanonicalParams = Utilities.getTruckDetailPageUrlParams(objProduct);
        }
    }
    
    /*
    @description - Create query for product record wiht given Id and field names
    @inputParam  - 1. Product Id        2. List of field names
    */
    private String createQueryForProduct(Id ProductId, List<String> listFieldNames){
        if(String.isNotBlank(ProductId) && !listFieldNames.isEmpty()){
            return 'SELECT '+ String.join( listFieldNames, ',') +' FROM Product2 WHERE Id = \''+ ProductId +'\'';
        }
        return null;
    }
    
    private Product2 fetchProduct(String query){
        try{
            return Database.query( query );
        }
        catch(Exception e){
            System.debug('Exception in fetching Product record ::: '+ e);
        }
        return null;
    }
    
    /*
    @description - check conditions for required comments for display on VF page
    @inputParam  - Product2 (firetruck record)
    */
    private void generateComments( Product2 objProduct ){
        if( objProduct != null
                && listComments != null && !listComments.isEmpty() ){
            listCommentsToDisplay = new List< Comment_Generation__c >();
            
            for( Comment_Generation__c currentComment : listComments ){
                if( String.isNotBlank( currentComment.Comment__c )
                        && String.isNotBlank( currentComment.Condition__c )){
                        
                    if( compareCondition( objProduct, currentComment )){
                        listCommentsToDisplay.add( currentComment );
                    }
                }
            }
        }
    }
    
    /*
    @description - compare different conditions for generation of comments
    @inputParams - 1. Product2 (firetruck record)    2. Commnet record
    */
    private Boolean compareCondition( Product2 objProduct, Comment_Generation__c objComment ){
        if( objProduct != null && objComment != null &&
                String.isNotBlank( objComment.Comment__c ) && String.isNotBlank( objComment.Condition__c )){
                
            String strCondition = objComment.Condition__c;
            try{
                String charAtZero = strCondition.substring(0,1);
                if( strCondition.equalsIgnoreCase( 'not empty' )){    // non-empty field value
                    if( String.isNotBlank(( String )objProduct.get( objComment.Field_API_Name__c)) ){
                        return True;
                    }
                }
                else if( strCondition.equalsIgnoreCase( 'phase selected' ) ){
                    String strFireTruckManufacturer = ( String )objProduct.get( objComment.Field_API_Name__c);
                    
                    if( String.isNotBlank( strFireTruckManufacturer )
                            && String.isNotBlank( objComment.Trigger_Word_Phrase__c )
                            && strFireTruckManufacturer.equalsIgnoreCase( objComment.Trigger_Word_Phrase__c ) ){
                        return True;
                    }
                }
                else if( strCondition.isNumeric() ){
                   String fieldValue = (String)objProduct.get( objComment.Field_API_Name__c);
                   if( String.isNotBlank(fieldValue) && fieldValue.contains( objComment.Condition__c )){
                        return True;
                   }
                }
                else if( charAtZero.equals('<') || charAtZero.equals('>')){
                    String strActualValue = objComment.Condition__c.replaceAll('[, ]','').subString(1);    // remove first character
                    
                    if( strActualValue.isNumeric()){
                        Decimal commentValue = Decimal.ValueOf( strActualValue );
                        Decimal productFieldValue = ((Decimal)objProduct.get( objComment.Field_API_Name__c ));
                        //System.debug('productFieldValue:::'+productFieldValue+' commentValue '+commentValue );
                        
                        if( ( charAtZero.equals('<') && productFieldValue < commentValue ) ||
                                ( charAtZero.equals('>') && productFieldValue > commentValue )){
                            return True;
                        }
                    }
                }
                else if( strCondition.contains('-') ){    // get values for a range
                    String[] numericRange = strCondition.replaceAll('[, ]','').split('-');    // remove all commas and spaces 
                    
                    if( numericRange != null && numericRange.size() == 2 ){
                        Decimal numericValue = (Decimal)objProduct.get(objComment.Field_API_Name__c);
                        System.debug('numericValue :'+numericValue );
                        if( numericValue > Decimal.valueOf(numericRange[0]) &&
                                numericValue < Decimal.valueOf(numericRange[1]) ){
                            return True;
                        }
                    }
                }
            }
            catch(Exception e){
                System.debug('Exception ::: '+ e);
            }
        }
        return False;
    }

    
    /*
    @description- fetch Comment Records marked with "Include" checkbox field
    */
    private void fetchActiveComments(){
        try{
            listComments = [ SELECT Id, Comment__c, Condition__c, Field_API_Name__c, Link__c, Trigger_Word_Phrase__c
                             FROM Comment_Generation__c WHERE Include__c = TRUE ];
        }
        catch( Exception e ){
            System.debug('Exception in fetching Comments ::: '+ e);
        }
    }
    
    /*
    @description- fetch Fieldnames required to fetch fields mentioned in Comment generation records
    @outputParam - List of field names
    */
    private Set< String > getFieldNamesFromComments(){
        Set< String > setFieldnames = new Set< String >();
        
        if( listComments != null && !listComments.isEmpty()){
            for( Comment_Generation__c currentComment : listComments ){
                if( String.isNotBlank( currentComment.Field_API_Name__c ) ){
                    setFieldnames.add( currentComment.Field_API_Name__c );
                }
            }
        }
        setFieldnames.addAll( new Set<String>{'apparatusType__c','Stock_Number__c',
                                                'VF_Main_Title__c'});    // add Apparatus type field to standard controller
        return setFieldnames;
    }
    
    /*
    @description - fetch Products having similar ApparatusType
    @inputParam  - 1. Product Id     2. Product ApparatusType
    */
    private void fetchSimilarProducts( Id ProductId, String strApparatustype ){
        if( String.isNotBlank(strApparatustype) && String.isNotBlank( ProductId )){
            // split the ApparatusTypes for dml query
            String[] arrAppararusTypes = strApparatustype.split(';');
        
            if( arrAppararusTypes != null && arrAppararusTypes.size() > 0 ){
                try{
                    // fetch products other than current product
                    listSimilarProducts = new List<Product2>([ SELECT Id, VF_Main_Title__c, Description, VF_Video_URL__c,
                                                                      apparatusType__c, Truck_Public_URL__c,
                                                                      ( SELECT id, Amazon_S3_Image_URL__c, Amazon_S3_Main_Thumbnail_URL__c
                                                                        FROM Cloud_Documents__r
                                                                        WHERE Show_Online__c = TRUE AND
                                                                              Main_Thumbnail__c = TRUE LIMIT 1)
                                                                FROM Product2
                                                                WHERE Id !=: ProductId AND 
                                                                      apparatusType__c IN: arrAppararusTypes 
                                                                      // Added on 11/14/2015 by John Burdett - Noticed that it was incorrect
                                                                      AND IsActive=True AND Post_To_Website__c=True AND status__c In ('Available','HOD','Internal HOD','On Lease')
                                                                LIMIT 4 ]);
                    //System.debug('listSimilarProducts :'+listSimilarProducts );
                }
                catch( Exception e ){
                    System.debug('Exception in fetching similar products ::: '+ e);
                }
            }
        }
    }

    /*
    @description - Fetch related image urls from Cloud Document records 
    */
    private void fetchRelatedCloudDocs( Id ProductId ){
        if( String.isNotBlank( ProductId )){
            try{
                // fetch related cloud document records
                listCloudDocuments = new List< DragDropToCloud__Cloud_Documents__c >([ SELECT Id, Main_Image__c, Main_Thumbnail__c, Amazon_S3_Image_Thumbnail_URL__c,
                                                                                              DragDropToCloud__Folder_Id__c, Amazon_S3_Image_URL__c
                                                                                       FROM DragDropToCloud__Cloud_Documents__c
                                                                                       WHERE Product__c =: ProductId 
                                                                                             AND Show_Online__c = True
                                                                                             
                                                                                             ]); // AND Main_Thumbnail__c= False
            }
            catch( Exception e){
                System.debug('Exception in fetching Cloud Documents ::: '+ e);
            }   
            filterCloudDocImageURLs();
        }
    }
    
    /*
    @description - set the image URLs for images displayed as main image and gallery images
    */
    private void filterCloudDocImageURLs(){
        if( listCloudDocuments != null && !listCloudDocuments.isEmpty() ){
            // temporary Cloud Doc Object
            DragDropToCloud__Cloud_Documents__c objCloudDoc;
            Integer intLoopVar = listCloudDocuments.size()-1;
            
            // iterate over cloud Docs from end
            while(  intLoopVar >= 0 ){
                objCloudDoc = listCloudDocuments.get(intLoopVar);
                
                if( objCloudDoc.Main_Image__c && 
                    String.isNotBlank( objCloudDoc.Amazon_S3_Image_URL__c )){
                        // fetch the main image url and remove from list
                        strMainImageURL = objCloudDoc.Amazon_S3_Image_URL__c;
                        listCloudDocuments.remove(intLoopVar);
                }
                else if( objCloudDoc.Main_Thumbnail__c ){
                    listCloudDocuments.remove(intLoopVar);
                }
                intLoopVar--;
            }
        }
    }
    
    /*
    @description - get Company contact info. from Custom Settings
    */
    public CompanyContactInformation__c  getCompanyContactInfo(){
        return CompanyContactInformation__c.getValues('BMFA Contact Information');
    }
}