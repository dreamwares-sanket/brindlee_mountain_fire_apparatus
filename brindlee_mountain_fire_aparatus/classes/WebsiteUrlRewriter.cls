/*
 * @description  - URL rewriter class for BMFA website (firetruckmall.com)
 * @dateCreated  - 09/09/2015
 * @lastModified - 11/11/2016
 * @createdBy    - Dreamwares (Aditya S.)
 */
global with sharing class WebsiteUrlRewriter implements Site.UrlRewriter {
    
    private static final String LOOSEEQPMNTDETAILCANONICALPAGEURL = '/AvailableLooseEquipment/';
    private static final String LOOSEEQPMNTDETAILPAGEURL = '/AvailableLooseEquipment?id=';
    
    private static final String AVAILABLEQUIPMENTSCANONICALURL = '/AvailableLooseEquipments/';
    private static final String AVAILABLEQUIPMENTSPAGEURL = '/AvailableLooseEquipments?category=';
    
    private static final String TRUCKSDETAILPAGEURL = '/AvailableTruckDetailView?id=';
    private static final String TRUCKDETAILCANONICALURL = '/AvailableTruck/';
    
    private static final String AVAILABLETRUCKSCANOCICALURL = '/AvailableTrucks/';
    private static final String AVAILABLETRUCKSPAGEURL = '/AvailableTrucks?category=';
    
    /*
    @description - Interface method to map to vf page's true url from canonical url
    */
    global PageReference mapRequestUrl( PageReference currentPage ){
        String strUrl = currentPage.getUrl();    // get current page url
        
        if( strUrl.startsWithIgnoreCase( TRUCKDETAILCANONICALURL ) ){
            return mapTruckDetailPageRef( strUrl );
        }
        else if( strUrl.startsWithIgnoreCase( AVAILABLETRUCKSCANOCICALURL )){
            return mapAvailableCategoriesPageRef( strUrl, AVAILABLETRUCKSCANOCICALURL, AVAILABLETRUCKSPAGEURL );
        }
        else if( strUrl.startsWithIgnoreCase( LOOSEEQPMNTDETAILCANONICALPAGEURL )){
            return mapLooseEqpmntPageRef( strUrl );
        }
        else if( strUrl.startsWithIgnoreCase( AVAILABLEQUIPMENTSCANONICALURL ) ){
            return mapAvailableCategoriesPageRef( strUrl, AVAILABLEQUIPMENTSCANONICALURL, AVAILABLEQUIPMENTSPAGEURL );
        }
        else if( strUrl.startsWithIgnoreCase('/Buying-a-Used-Fire-Truck') ||
                     strUrl.startsWithIgnoreCase('/Selling-your-Used-Fire-Truck') || 
                     strUrl.startsWithIgnoreCase('/Need-Work-on-Your-Used-Fire-Truck')){
            return new PageReference( strUrl.replace('-','_') );
        }
        return null;
    }
    
    /*
    @description - map page url for truck Detail page
    @inputParam  - Canonical url
    @outputparam - original page Url
    */
    private Pagereference mapTruckDetailPageRef( String strUrl ){
         if( String.isNotBlank( strUrl )){
            String strUrlParam = strUrl.substring( TRUCKDETAILCANONICALURL.length(), strUrl.length());	// extract current page parameters from url
            String[] arrParams = strUrlParam.split('/'); 	// seperate the params string to get the stock number at index 0 of array
            
            try{
                Id productId = [ SELECT Id FROM Product2
                                 WHERE Stock_Number__c =: arrParams[0]
                                 LIMIT 1].Id;
                return new PageReference( TRUCKSDETAILPAGEURL + productId );
            }
            catch( Exception e){
                System.debug('Exception in fetching records ::: '+ e);
            }
            return new PageReference( '/SearchResults?stockNo='+arrParams[0] );	// if no result found, then redirect user to search page( search records with similar stock number )
        }
        return null;
    }
    
    /*
     	Map to true Loose Equipment url from canonical url	
		@param url
		@return pagereference
     */
    private Pagereference mapLooseEqpmntPageRef( String strUrl ){
        if( String.isNotBlank(strUrl)){
        	String strUrlParam = strUrl.substring( LOOSEEQPMNTDETAILCANONICALPAGEURL.length(), strUrl.length());
			String[] arrParams = strUrlParam.split('/'); 	// seperate the params string to get the Equipment number at index 0 of array
            
            try{
                Id productId = [ SELECT Id FROM Product2
                                 WHERE Equipment_Number__c =: arrParams[0]
                                 LIMIT 1].Id;
                return new PageReference( LOOSEEQPMNTDETAILPAGEURL + productId );
            }
            catch( Exception e){
                System.debug('Exception in fetching records ::: '+ e);
            }
            return new PageReference( '/SearchResults?search='+arrParams[0] );	// if no result found, then redirect user to search page( search records with similar stock number )
        }
        return null;
    }
    
    /*
    @description - map page url for Available trucks page and Available Loose Equipments page
    @inputParam  - Canonical url
    @outputparam - original page Url
    */
    private PageReference mapAvailableCategoriesPageRef( String strUrl, String canonicalUrl, String pageUrl ){
        String strCategory = strUrl.substring( canonicalUrl.length(), strUrl.length());	// get the category parameter
        String catUrl = pageUrl + strCategory.replace('?','&').replace('-&-','-%26-');	// replace '?' with '&' for further parameters in url
        return new PageReference( catUrl );
    }
    
    /*
    @description - Generate friendly URLs for website pages
    @inputParam  - List of page references
    @outputParam - List of pagereferences with friendly urls
    */
    global List<PageReference> generateUrlFor( List<PageReference> listSalesforceUrls ){
        List<PageReference> listCanonicalUrls;    // list of user-friendly urls
        
        if( listSalesforceUrls != null && !listSalesforceUrls.isEmpty() ){
            
            List<Id> listTruckIds = extractProductIdsFromURLs( listSalesforceUrls, TRUCKSDETAILPAGEURL ), // extract IDs from Truck Detail URLs
                     listLooseEqpmntIds = extractProductIdsFromURLs( listSalesforceUrls, LOOSEEQPMNTDETAILPAGEURL );	// extract IDs from Loose Eqpmnt Detail URLs
            
            Map<Id, Product2> mapTrucks = fetchProducts( listTruckIds ),
                			  mapLooseEqpmnts = fetchProducts( listLooseEqpmntIds );
            
            List<Product2> listProducts = orderProducts( listTruckIds, mapTrucks ),	// Order products according to sequence of product Ids
            				listLooseEqpmnts = orderProducts( listLooseEqpmntIds, mapLooseEqpmnts );
            
            integer trucksCount=0, looseEqpmntCount=0;    // keep count of records from list
            listCanonicalUrls = new List<PageReference>();
            
            Product2 objProduct;
            String strStockNumber, strMainTitle, strCanonicalUrl;
            
            for( PageReference currPageRef : listSalesforceUrls ){
                
                 if( currPageRef.getUrl().startsWith( '/Buying_a_Used_Fire_Truck' ) || 
                         currPageRef.getUrl().startsWith( '/Selling_your_Used_Fire_Truck' ) ||
                         currPageRef.getUrl().startsWith( '/Need_Work_on_Your_Used_Fire_Truck' ) ){
                         
                     strCanonicalUrl = currPageRef.getUrl().replace('_','-');
                     listCanonicalUrls.add( new PageReference( strCanonicalUrl ));
                 }
                 else if( currPageRef.getUrl().startsWith( TRUCKSDETAILPAGEURL )){    // truck detail page
                     //try{
                     objProduct = listProducts.get(trucksCount);
                     strCanonicalUrl = String.format('{0}{1}', new String[]{ TRUCKDETAILCANONICALURL,
                                                         		Utilities.getTruckDetailPageUrlParams(objProduct)});
                     listCanonicalUrls.add( new PageReference( strCanonicalUrl ));
                     trucksCount++;
                     /*}
                     catch( Exception e ){
                         System.debug( 'Exception in creating URL ::: '+ e );
                     }*/
                 }
                 else if(currPageRef.getUrl().startsWith( AVAILABLETRUCKSPAGEURL )){    // available trucks page
                     listCanonicalUrls.add( setCanonicalCategoryForUrl( currPageRef, AVAILABLETRUCKSCANOCICALURL ));
                 }
                else if( currPageRef.getUrl().startsWith( LOOSEEQPMNTDETAILPAGEURL ) ){
                    objProduct = listLooseEqpmnts.get(looseEqpmntCount++);
                    strCanonicalUrl = String.format('{0}{1}',
                                             new String[]{ LOOSEEQPMNTDETAILCANONICALPAGEURL,
                                                             Utilities.getLooseEqpmntDetailPageUrlparams(objProduct)});
                    listCanonicalUrls.add( new PageReference( strCanonicalUrl ));
                }
                else if( currPageRef.getUrl().startsWith( AVAILABLEQUIPMENTSPAGEURL ) ){
                    listCanonicalUrls.add( setCanonicalCategoryForUrl( currPageRef, AVAILABLEQUIPMENTSCANONICALURL ));
                }
                else{
                    listCanonicalUrls.add( currPageRef );
                }
            }
        }
        return listCanonicalUrls;
    }
    
    private PageReference setCanonicalCategoryForUrl( PageReference pageRef, String canonicalUrl ){
        String[] currentUrlParam = pageRef.getUrl().split('=');
        String pageRefUrl = canonicalUrl + currentUrlParam[1];
        pageRefUrl = EncodingUtil.urlDecode( pageRefUrl, 'UTF-8');
        return new PageReference( pageRefUrl );
    }
    
    /*
    @description - Extract the product Ids from pagereference's urls
    @inputParam  - List of PageReferences
    @outputParam - List of Product Ids
    */
    private List<Id> extractProductIdsFromURLs( List<PageReference> listPageRefs, String pageUrl ){
        List<Id> listProductId = new List<Id>();
        
        if( String.isNotBlank(pageUrl) && listPageRefs != null && !listPageRefs.isEmpty() ){
            String strUrl, prodId;
            
            for( PageReference currPageRef : listPageRefs ){
                strUrl = currPageRef.getUrl();
                
                if( strUrl.startsWith( pageUrl )){
                    try{    // find product Id
                        prodId = strUrl.substring( pageUrl.length(), strUrl.length());
                        listProductId.add( prodId );
                    }
                    catch( Exception e ){
                        System.debug('Exception in extracting Id from page URL ::: '+ e);
                    }
                }
            }
        }
        return listProductId;
    }
    
    /*
    @description - Fetch Products having Ids provided as a parameter 
    @inputParam  - List of Product Ids
    @outputParam - Map of Products
    */
    private Map<Id, Product2> fetchProducts( List<Id> listProductId ){
    
        if( listProductId != null && !listProductId.isEmpty() ){
            try{
                return new Map<Id, Product2>([ SELECT Id,VF_Main_Title__c,Name,Stock_Number__c,Equipment_Number__c
                                               FROM Product2
                                               WHERE Id IN: listProductId ]);
            }
            catch( Exception e ){
                System.debug('Exception in fetching products ::: '+ e);
            }
        }
        return null;
    }
    
    /*
    @description - map products in the same order as of their IDs occurences
    @inputParam  - 1. List of Product Ids    2. Map of Products
    @outputParam - Map of Products sorted according to the occurence of its Id
    */
    private List<Product2> orderProducts( List<Id> listProductIds, Map<Id, Product2> mapProducts ){
        List<Product2> listArrangedProducts;
        
        if( listProductIds != null && !listProductIds.isEmpty() &&
            mapProducts != null ){
                listArrangedProducts = new List<Product2>();
                for( Id currentProductId : listProductIds ){
                
                    if( mapProducts.containsKey( currentProductId ) ){
                        listArrangedProducts.add( mapProducts.get( currentProductId ));
                    }
                }
        }
        return listArrangedProducts;
    }
}