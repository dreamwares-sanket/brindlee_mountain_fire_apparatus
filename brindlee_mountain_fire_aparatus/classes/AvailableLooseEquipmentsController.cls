/*
 * Controller for vf page LooseEquipmentListing to display Products with Loose Equipment record type
 *
 * @createdDate 2016/09/05
 * @author Aditya S. (Dreamwares)
 */
public with sharing class AvailableLooseEquipmentsController {

    public String selMaxPrice {
        get{
            return String.isBlank(selMaxPrice) ? '800000' : selMaxPrice;
        } set; }

    public String selMinPrice {
        get{
            return String.isBlank(selMinPrice) ? '0' : selMinPrice;
        } set; }
    
    public String selCategory {
        get{
            return String.isBlank(selCategory) ? 'All' : selCategory;
        } set; }
    
    public String getCategoryCanonicalUrl(){ // get canonicalized category value
            return String.isNotBlank(selCategory) ? Utilities.getCanonicalCategoryValue(selCategory) : null;
    }
    
    public List<Product2> listProducts { get; set; }
    
    public List<SelectOption> getPriceOptions(){          // Get list options for Beudget Lists
        List<SelectOption> listOptions = new List<SelectOption>();
        for( Integer count=0;count<=800000;count=count+5000 ){
            listOptions.add(new SelectOption( String.valueOf(count), '$'+String.valueOf(count)));
        }
        return listOptions;
    }
    
    public List<SelectOption> getCategoryOptions(){          // Get list options for Beudget Lists
        return Utilities.generatePicklistFieldOptions( new Product2(),'Loose_Equipment_Type__c', 'All');
    }
    
    public AvailableLooseEquipmentsController(){    // constructor
        listProducts = new List<Product2>();
        presetPicklistValuesFromUrl();
        fetchProductsByBatch();
    }
    
    private void presetPicklistValuesFromUrl(){
        Map<String, String> mapPageParams = ApexPages.CurrentPage().getParameters();
        
        String strPriceRange = mapPageParams.get('price');
        
        if( String.isNotBlank(strPriceRange) ){
            String[] arrPriceRange = strPriceRange.split('-');
            if( arrPriceRange != null && !arrPriceRange.isEmpty() && arrPriceRange.size() == 2 ){
                if( arrPriceRange[0].isNumeric() && arrPriceRange[1].isNumeric() ){
                    selMinPrice = arrPriceRange[0];
                    selMaxPrice = arrPriceRange[1];
                }
            }
        }
        
        String strCategory = mapPageParams.get('category');
        
        if( String.isNotBlank(strCategory) ){
            Map<String, String> mapCategoryUrlCodes = Utilities.getCategoryUrlcodesMap( new Product2(), 'Loose_Equipment_Type__c' );
                
            strCategory = Utilities.getCanonicalCategoryValue(strCategory);
            if(mapCategoryUrlCodes != null && mapCategoryUrlCodes.containsKey(strCategory)){
                selCategory = mapCategoryUrlCodes.get( strCategory );    // set the category value from url code
            }
        }
    }
    
    public void resetAndFetchProductsByCriteria(){
        listProducts = new List<Product2>();
        fetchProductsByBatch();
    }
    
    public List<Product2> getRandomProducts() {    // get random records from list of products
        if( listProducts != null && !listProducts.isEmpty() ){
            Integer intTotalRecords = listProducts.size();

            // check the number of records available for display
            Integer intRecsToDisplay = ( intTotalRecords < 6 )? intTotalRecords : 6;
            List<Product2> listRndmPoducts = new List<Product2>();
            
            for( Integer currNum = 0 ; currNum < intRecsToDisplay ; currNum++ ){    // get 6 random records to display
                listRndmPoducts.add( listProducts.get( Integer.ValueOf( Math.floor(Math.random()*intTotalRecords))));
            }
            return listRndmPoducts;
        }
        return null;
    }
    
    public void fetchProductsByBatch(){
        String offset = ApexPages.CurrentPage().getparameters().get('offset');
        Integer intOffset = String.isBlank(offset) ? 0 : Integer.valueOf(offset);
        
        if( intOffset <= 950 ){
            String query = buildProductsQuery(intOffset);
            List<Product2> listNewBatchProducts = Database.query( query );
            
            if( listNewBatchProducts != null && !listNewBatchProducts.isEmpty() ){
                listProducts.addAll(listNewBatchProducts);
            }
        }
    }
    
    private String buildProductsQuery(Integer offset){
        if( offset != null ){
            Id looseEqpmntRecTypeId = Utilities.getProductRecordTypeId('Loose Equipment');
            
            String baseQuery = 'SELECT Loose_Equipment_Type__c, Equipment_Price__c, Name, Description,'
                                +' VF_Additional_Pricing_Text__c, VF_Website_Price__c,( SELECT Amazon_S3_Main_Thumbnail_URL__c FROM Cloud_Documents__r'
                                    +' WHERE Main_Thumbnail__c = TRUE AND Show_Online__c = TRUE'
                                    +' LIMIT 1) FROM Product2 WHERE RecordTypeId =\'' + looseEqpmntRecTypeId +'\'',
                   criteria = assembleFieldCriteria();
        
            return String.format('{0} AND {1} LIMIT 50 OFFSET {2}', new List<String>{ baseQuery, criteria, String.valueOf(offset) });
        }
        return null;
    }
    
    private String assembleFieldCriteria(){
        String criteria = '';
        criteria += getFieldCriteria( 'Equipment_Price__c', '>=', selMinPrice, null );
        criteria += getFieldCriteria( 'Equipment_Price__c', '<=', selMaxPrice, null );
        criteria += getFieldCriteria( 'Loose_Equipment_Type__c', '=', selCategory, 'All' );
        criteria = criteria.removeEnd(' AND ');
        return criteria;
    }
    
    private String getFieldCriteria( String fieldName, String operator, String fieldVal,  String ignoreVal ){
        if( String.isNotBlank(fieldName) && String.isNotBlank(fieldVal) && String.isNotBlank(operator) ){
            if( String.isNotBlank(ignoreVal) && fieldVal.equals(ignoreVal) ){
                return '';
            }
            else if( fieldName.equals('Equipment_Price__c') ){
                return String.format('{0} {1} {2} AND ', new List<String>{ fieldName, operator, fieldVal });
            }
            else{
                return String.format('{0} {1} \'\'{2}\'\' AND ', new List<String>{ fieldName, operator, fieldVal });
            }
        }
        return '';
    }
}