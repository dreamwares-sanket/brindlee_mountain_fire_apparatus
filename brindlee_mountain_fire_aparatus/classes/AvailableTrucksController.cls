/*
 * @description  - Controller class for VF page BuildAvailableTrucksSearch used to sort 
 *                 results depending on criteria
 * @dateCreated  - 17/08/2015
 * @lastModified - 26/4/2016
 * @createdBy    - Dreamwares
 */
public with sharing class AvailableTrucksController{
    
    // Values chosen from picklist    
    public String selBudgetMin{
        get{
            return String.isBlank(selBudgetMin) ? '0' : selBudgetMin;
        } set;}           
    public String selBudgetMax{
        get{   
            return String.isBlank(selBudgetMax) ? '1200000' : selBudgetMax;
        }set;}
    public String selYearMin{
        get{
            return String.isBlank(selYearMin) ? '1950' : selYearMin;
        } set;}
    public String selYearMax{
        get{
            return String.isBlank(selYearMax) ? String.valueOf(System.Today().year()) : selYearMax;
        } set;}
    public String selChassis{
        get{
            return String.isBlank(selChassis) ? 'Both' : selChassis;
        } set;}
    public List<String> listSelBrands{
        get{
            return listSelBrands == null ? new List<String>{'All'} : listSelBrands;
        } set;}
    public String selPumpSize{
        get{
            return String.isBlank(selPumpSize) ? 'All' : selPumpSize;
        } set;}
    public String selTankSize{
        get{
            return String.isBlank(selTankSize) ? 'All' : selTankSize;
        } set;}
    public String selCategory{
        get{
            return String.isBlank(selCategory) ? 'All' : selCategory;
        } set;}
    public String selMileageOption{
        get{
            return String.isBlank(selMileageOption) ? 'Any Mileage' : selMileageOption;
        } set;}
    public List<String> listSelRegions{
        get{
            return listSelRegions == null ? new List<String>{'All'} : listSelRegions;
        } set;}
    public String selWarrantyOption{
        get{
            return String.isBlank(selWarrantyOption) ? 'All' : selWarrantyOption;
        } set;}
    public String sel4x4Option{
        get{
            return String.isBlank(sel4x4Option) ? 'All' : sel4x4Option;
        }
        set; }
        
    // Seo attributes
    public String SeoTitle { get; set; }
    public String SeoDescription { get; set; }
    
    public List<SelectOption> getPriceOptions(){          // Get list options for Beudget Lists
        List<SelectOption> listOptions = new List<SelectOption>();
        for( Integer count=0;count<=1200000;count=count+5000 ){
            listOptions.add(new SelectOption( String.valueOf(count), '$'+String.valueOf(count)));
        }
        return listOptions;
    }

    public List<SelectOption> getYearOptions(){           // Get year options for picklists
        List<SelectOption> listOptions = new List<SelectOption>();
        Integer maxYear = System.Today().Year();
        listOptions.add(new SelectOption('1950','1950'));
        listOptions.add(new SelectOption('1960','1960'));
        listOptions.add(new SelectOption('1970','1970'));
        listOptions.add(new SelectOption('1980','1980'));
        
        for( Integer count=1990;count<=maxYear;count++ ){
            listOptions.add(new SelectOption( String.valueOf(count), String.valueOf(count)));
        }
        return listOptions;
    }
    
    public List<SelectOption> getChassisTypes(){    // create picklist for chassis types
        return Utilities.generatePicklistFieldOptions( new Fire_Truck__c(),'Custom_Commercial__c','Both');
    }
    
    public List<SelectOption> getBrands(){    // create picklist for brands
        return Utilities.generatePicklistFieldOptions( new Fire_Truck__c(),'Fire_Body_Manufacturer__c','All');
    }
    
    public List< SelectOption > getPumpSizeRanges(){    // create picklist for pump size ranges
        return new List<SelectOption>{
                    new SelectOption('All', 'All'),
                    new SelectOption('0-500', '0 - 500 GPM'),
                    new SelectOption('500-750', '500 - 750 GPM'),
                    new SelectOption('750-1250', '750 - 1250 GPM'),
                    new SelectOption('1250-1500', '1250 - 1500 GPM'),
                    new SelectOption('1500-2000', '1500 - 2000 GPM'),
                    new SelectOption('2000', '2000+ GPM')
                };
    }
        
    public List<SelectOption> getTankSizeRanges(){     // create picklist for tank size ranges
        return new List<SelectOption>{
                    new SelectOption('All', 'All'),
                    new SelectOption('0-250', '0 - 250 Gallons'),
                    new SelectOption('250-400', '250 - 400 Gallons'),
                    new SelectOption('400-750', '400 - 750 Gallons'),
                    new SelectOption('750-1100', '750 - 1100 Gallons'),
                    new SelectOption('1100-1800', '1100 - 1800 Gallons'),
                    new SelectOption('1800-2500', '1800 - 2500 Gallons'),
                    new SelectOption('2500', '2500+ Gallons')
                };
    }
    
    public List<SelectOption> getCategories(){    // create picklist for categories
        return Utilities.generatePicklistFieldOptions(new Product2(),'apparatusType__c','All');
    }
    
    public List<SelectOption> getMileageOptions(){
        return Utilities.generatePicklistFieldOptions( new Fire_Truck_Finder_Criteria__c(), 'FTF_Mileage__c', '' );
    }
    
    public List<SelectOption> getGeographicRegions(){
        return Utilities.generatePicklistFieldOptions( new Fire_Truck_Finder_Criteria__c(), 'FTF_Geographic_Region__c', '' );
    }
    
    public List<SelectOption> getWarrantyOptions(){    // Create picklist for Warranty options
        return new List<SelectOption>{
                    new SelectOption('All','All'),
                    new SelectOption('True','Trucks with warranty'),
                    new SelectOption('False', 'Trucks without warranty')
                };
    }
    
    public String CategoryCanonicalUrl{    // get canonicalized category value
        get{
            return String.isNotBlank(selCategory) ? Utilities.getCanonicalCategoryValue(selCategory) : null;
        } set; }
    
    public List< Product2 > listAllProducts {get; set;}    //List of product records
    
    public List<Product2> getRandomProducts(){      // return 6 random product records    
        if( listAllProducts != null && !listAllProducts.isEmpty() ){
            Integer intTotalRecords = listAllProducts.size();

            // check the number of records available for display
            Integer intRecsToDisplay = ( intTotalRecords < 6 )? intTotalRecords : 6;
            List<Product2> listRandomProducts = new List<Product2>();
            
            for( Integer currNum = 0 ; currNum < intRecsToDisplay ; currNum++ ){    // get 6 random records to display
                listRandomProducts.add( listAllProducts.get( Integer.ValueOf( Math.floor(Math.random()*intTotalRecords))));
            }
            return listRandomProducts;
        }
        return null;
    }
    
    public AvailableTrucksController(){    // Constructor
        List<String> listparams = new List<String>{'category','price','year','brand','pumpsize','tanksize','chassis','mileage','region','warranty','is4x4'};
        presetPicklistValuesFromUrl( listparams );
        
        listAllProducts = new List<Product2>();
        fetchRelatedRecords();            // fetch Products
    }
    
    /*
    @description - set picklist values from url parameters
    @inputParam  - List of url parameters
    */
    private void presetPicklistValuesFromUrl( List<String> listparams ){
        if( listparams != null && !listparams.isEmpty() ){
            Map<String, String> mapPageParams = ApexPages.CurrentPage().getParameters();
            
            String paramValue;
            for(String currentParam : listparams){
                paramValue = mapPageParams.get(currentParam);
                
                if(String.isNotBlank(paramValue)){
                    presetPicklistValue(currentParam, paramValue);
                }
            }
        }
    }
    
    /*
    @description - set all filter values in the url 
    */
    public PageReference changeCategoryPage(){
        PageReference pageRef = new PageReference('/AvailableTrucks/' + addParameterInUrl() );
        pageRef.setRedirect(false);
        return pageRef;
    }
    
    /*
    @description - get all filter parameters conforming as url parameters
    */
    private String addParameterInUrl(){
        return String.format('{0}?price={1}-{2}&year={3}-{4}&brand={5}&chassis={6}&pumpsize={7}&tanksize={8}&mileage={9}&region={10}&warranty={11}&is4x4={12}',
                                    new List<String>{ CategoryCanonicalUrl, selBudgetMin, selBudgetMax, selYearMin,
                                                      selYearMax, String.join(listSelBrands, ';'), selChassis, selPumpSize, 
                                                      selTankSize, selMileageOption, String.join(listSelRegions,';'), selWarrantyOption, sel4x4Option });
    }
    
    /*
    @description - Pre-populate field values according to field name
    @inputParam  - 1. Field name     2. Field value
    */
    private void presetPicklistValue( String strFieldName, String strValue ){
        if( String.isNotBlank(strFieldName) && String.isNotBlank(strValue)){
            strFieldName = strFieldName.toLowerCase();
            
            if(strFieldName.equals('category')){    // set category
                Map<String, String> mapCategoryUrlCodes = Utilities.getCategoryUrlcodesMap(new Product2(), 'apparatusType__c');
                
                strValue = Utilities.getCanonicalCategoryValue(strValue);
                if(mapCategoryUrlCodes != null && mapCategoryUrlCodes.containsKey(strValue)){
                    selCategory = mapCategoryUrlCodes.get( strValue );    // set the category value from url code
                }
            }
            else if( strFieldName.equals('price') || strFieldName.equals('year') ){    // set price
                String[] range = strValue.split('-');
                if( range.size() >= 2 ){
                    if(strFieldName.equals('price')){
                        selBudgetMin = range[0];
                        selBudgetMax = range[1];
                    }
                    else if(strFieldName.equals('year')){
                        selYearMin = range[0];
                        selYearMax = range[1];
                    }
                }
            }
            else if( strFieldName.equals('brand')){     // set brand
                listSelBrands = strValue.split(';');    // set array of values
            }
            else if( strFieldName.equals('pumpsize')){  //  set pumpsize
                selPumpsize = strValue;
            }
            else if( strFieldName.Equals('tanksize')){  //  set tanksize
                selTanksize = strValue;
            }
            else if( strFieldName.equals('chassis')){  //  set chassis
                strValue = strValue.toLowerCase();
                
                if( strValue.equals('custom') ){
                    selChassis = 'Custom';
                }
                else if( strValue.equals('commercial') ){ 
                    selChassis = 'Commercial';
                }
            }
            else if( strFieldName.equals('mileage')){     // set mileage
                selMileageOption = strValue;    
            }
            else if( strFieldName.equals('region')){     // set brand
                listSelRegions = strValue.split(';');    // set array of values
            }
            else if( strFieldName.equals('warranty')){  //  set warranty
                strValue = strValue.toLowerCase();
                
                if(strValue.equals('yes') || strValue.equals('true') ){
                   selWarrantyOption = 'True';
                }
                else if(strValue.equals('no') || strValue.equals('false') ){
                   selWarrantyOption = 'False';
                }
            }
            else if( strFieldName.equals('is4x4')){  //  set warranty
                strValue = strValue.toLowerCase();
                
                if(strValue.equals('yes') || strValue.equals('true') ){
                   sel4x4Option = 'True';
                }
                else if(strValue.equals('no') || strValue.equals('false') ){
                   sel4x4Option = 'False';
                }
            }
        }
    }
    
    /*
    @description - Reinitialize list of all products to newly fetch records
    @calledFrom  - On change event of select pick lists on vf page
    */
    public void resetRecordsList(){
        listAllProducts = new List<Product2>();
        fetchRelatedRecords();
    }
    
    /*
    @description - get hyphenated canonical values for selected category
    */
    public String getCanonicalCategory(){
        return Utilities.getCanonicalCategoryValue(selCategory);
    }
        
    /*
    @description - Fetch records matching the selected criteria from picklist(if exists)
    @calledFrom  - 1. Constructor    2. Picklists on VF page
    */
    public void fetchRelatedRecords(){
        String strOffset = ApexPages.CurrentPage().getParameters().get('offset');
        Integer offset = String.isBlank(strOffset)? 0 : Integer.valueOf(strOffset);
        
        if(offset <= 950){                                            // Limit the total number of records to be shown on page
            String strQuery = buildProductsQuery( String.valueOf(Offset) );
            List<Product2> listNewProducts = new List<Product2>();
            try{
                listNewProducts = Database.Query(strQuery);
            }
            catch( Exception e ){
                System.debug('Exception in fetching product records ::: ' + e);
            }
            if(!listNewProducts.isEmpty()){                // add newly fetched records to the listAllProducts for display
               listAllProducts.addAll(listNewProducts); 
            }
            populateMetaDataValues();
        }
    }
    
    /*
    @description - Build Product query by fetching required fields for criteria
    @inputParam  - Offset for query
    @outputParam - query for products 
    */
    private String buildProductsQuery( String strOffset ){
        String strCriteria = setFieldCriterias('');
        
        // query to get Product records
        String strQuery = String.join( new String[]{ 'SELECT Id, VF_Main_Title__c, VF_Additional_Pricing_Text__c, Description, VF_Sort_By_Budget_Range__c,VF_Website_Price__c,VF_Website_Price_Financing_WAC__c,',
                                                     '(SELECT Id, Amazon_S3_Main_Thumbnail_URL__c FROM Cloud_Documents__r',
                                                     'WHERE Main_Thumbnail__c = TRUE AND Show_Online__c = TRUE LIMIT 1)',
                                                     'FROM Product2 WHERE IsActive=True AND Post_To_Website__c=True AND',
                                                     'status__c IN (\'Available\',\'Auction\',\'HOD\',\'Internal HOD\',\'On Lease\')'}, ' ');
        if( String.isNotBlank( strCriteria ) ){
            //strCriteria = strCriteria.removeEnd(' AND ');    // remove redundant 'AND'
            strQuery = String.format('{0} AND {1}',     // append criteria string to query
                                        new String[]{ strQuery, strCriteria});     
        }
        
        strQuery = String.join( new String[]{strQuery, 'ORDER BY FT_Year_of_Truck__c DESC LIMIT 50 OFFSET', strOffset}, ' ');    //limit records for query
        //System.debug('strQuery:'+strQuery);
        return strQuery;
    }
    
    /*
    @description - Create query criterias for fields
    @inputParam - Existing criteria
    @outputParam - Generated criteria
    */
    private String setFieldCriterias(String strCriteria){
        strCriteria = checkQueryCriteria( strCriteria, 'VF_Sort_By_Budget_Range__c', selBudgetMin+'-'+selBudgetMax, 'none' );    // hyphenated budget min and max values as a range ex: 0-50000
        strCriteria = checkQueryCriteria( strCriteria, 'FT_Year_of_Truck__c', selYearMin+'-'+selYearMax, 'none' );            // hyphenated year min and max values as a range ex: 1990-1995
        //Updated on 11/14/2015 to support Fire Truck object
        strCriteria = checkQueryCriteria( strCriteria, 'FT_Custom_Commercial__c', selChassis, 'Both' );
        strCriteria = checkQueryCriteria( strCriteria, 'FT_Fire_Body_Manufacturer__c', String.join(listSelBrands,','), 'All' );
        strCriteria = checkQueryCriteria( strCriteria, 'VF_Sort_By_Pump_Size__c', selPumpSize, 'All' );
        strCriteria = checkQueryCriteria( strCriteria, 'VF_Sort_By_Tank_Size__c', selTankSize, 'All' );
        strCriteria = checkQueryCriteria( strCriteria, 'apparatusType__c', selCategory, 'All' );
        strCriteria = checkQueryCriteria( strCriteria, 'FT_Mileage__c', selMileageOption, 'Any Mileage' );
        strCriteria = checkQueryCriteria( strCriteria, 'Geographic_Region_Formula_Field__c', String.join(listSelRegions,','), 'All' );
        strCriteria = checkQueryCriteria( strCriteria, 'VF_Sort_By_Has_Warranty__c', selWarrantyOption, 'All' );
        strCriteria = checkQueryCriteria( strCriteria, 'FT_Four_By_Four__c', sel4x4Option, 'All' );
        return strCriteria.removeEnd(' AND ');    // remove redundant 'AND'
    }
    
    /*
    @description - Create criteria string and append existing criteria
    @inputParam -  1. Existing criteria     2. Selected field name
                   3. Selected field value  4. Ignore value
    @outputParam - Generated criteria value 
    */
    private String checkQueryCriteria( String strCriteria, String strSelField, String strSelValue, String strIgnoreValue ){
        if( String.isNotBlank( strSelValue ) 
                && String.isNotBlank( strSelField )
                && !strSelValue.containsIgnoreCase( strIgnoreValue ) ){
           strCriteria = String.format('{0}{1}', new String[]{ strCriteria,
                                            generateQueryCriteria( strSelField, strSelValue )});
        }
        return strCriteria;
    }
    
    /*
    @description - Generate 'WHERE' clause criterias in query
    @inputParam  - 1. Field name     2. Field value
    @outputParam - String with criteria to be used in query
    */
    public String generateQueryCriteria( String strFieldName, String strSelValue ){
        String strCriteria = '';
        if( String.isNotBlank(strFieldName) && String.isNotBlank(strSelValue) ){
            
            if(strFieldName.equals('FT_Custom_Commercial__c') ){                // Criteria for chassis
                strCriteria = strFieldName + '=\'' + strSelValue + '\'';
            }
            else if( strFieldName.equals('apparatusType__c') ){                    // Criteria for category
                strCriteria = strFieldName + ' includes (\'' +  strSelValue +'\')'; 
            }
            else if( strFieldName.equals('FT_Fire_Body_Manufacturer__c') ){        // Criteria for brand
                strCriteria = parseMultiSelectValues( strFieldName, strSelValue );
            }
            else if( strFieldName.equals('FT_Mileage__c') ){
                strCriteria = getMileageCriteria( strSelValue );
            }
            else if( strFieldName.equals('Geographic_Region_Formula_Field__c') ){
                strCriteria = parseMultiSelectValues( strFieldName, strSelValue );
            }
            else if( strFieldName.equals('VF_Sort_By_Has_Warranty__c') || strFieldName.equals('FT_Four_By_Four__c') ){    // string for Warranty criteria
                strCriteria = strFieldName + '=' + strSelValue;
            }
            else{    // condition to get values in a range
                strCriteria = generateRangeCriteria( strFieldName, strSelValue );
            }
        }
        strCriteria = strCriteria + ' AND ';
        return strCriteria;
    }
    
    /*
    @description - 
    @inputParam  - 1. Field name     2. Field value
    @outputParam - String with criteria to be used in query
    */
    private String parseMultiSelectValues( String strfieldName, String strSelValue ){
        return (String.isNotBlank(strfieldName) && String.isNotBlank(strSelValue))
                ? strfieldName + ' IN (\'' + strSelValue.replace(',','\',\'') + '\')'
                : '';
    }
    
    private String getMileageCriteria( String strSelValue ){
        if(String.isNotBlank(strSelValue)){
            String condition;
            if(strSelValue.contains('Under')){
                condition = '<=';
            }
            else if(strSelValue.contains('Over')){
                condition = '>=';
            }
            if( String.isNotEmpty(condition)){
                return String.format('FT_Mileage__c {0} {1}',
                                        new List<String>{ condition, ConformToNumericString(strSelValue) });
            }
        }
        return '';
    }
    
    private String ConformToNumericString( String strValue ){
        return String.isNotBlank(strValue)? strValue.replaceAll('(Under)|(Over)|( )|(,)','') : '0';
    }
    
    /*
    @description - Generate criteria over a range
    @inputParam  - 1. Fieldname     2. FieldValue
    @outputParam - criteria values for a field 
    */ 
    private String generateRangeCriteria( String strFieldName, String strSelValue ){
        String strCriteria;
        String[] arrNumRange = strSelValue.split('-');    // split the range
        
        if( arrNumRange != null ){    // get string for range criteria 
            
            // range with minima at 1st location and maxima at 2nd location
            if( arrNumRange.size() == 2 ){
                strCriteria = String.format('{0}>={1} AND {0}<={2}',
                                new String[]{ strFieldName, arrNumRange[0], arrNumRange[1] });
            }
            else if( arrNumRange.size() == 1 ){
                strCriteria = strFieldName + '>= ' + arrNumRange[0];
            }
        }
        return strCriteria;
    }
    
    /*
    @description - Populate metadata atrributes for title and description
    @calledFrom  - fetchRelatedRecords
    */
    public void populateMetaDataValues(){
        String strMetaDataCategory;                             
        
        if( String.isBlank( selCategory )
            || ( String.isNotBlank( selCategory )
                 && selCategory.equalsIgnoreCase('all'))){              // default value for no category selected
            strMetaDataCategory = 'Used Fire Trucks';
        }
        else{
            strMetaDataCategory = selCategory;
        }
        
        Meta_Data_for_Categories__c objMetaData;                    // fetch custom setting record depending on the category
        try{
            objMetaData = [ SELECT Id, Title__c, Description__c
                            FROM Meta_Data_for_Categories__c
                            WHERE Category__c =: strMetaDataCategory
                            LIMIT 1];
        }
        catch(Exception e){
            System.debug('Exception in fetching Meta Data custom settings ::: '+ e);
        }
        
        if( objMetaData != null ){            // populate Seo attributes for metadata
            SeoTitle = objMetaData.Title__c;
            SeoDescription = objMetaData.Description__c;
        }
    }
}