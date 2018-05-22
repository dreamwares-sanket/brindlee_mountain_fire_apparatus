/*
 * @description - Site map file controller to generate site map for firetruckmall.com
 * @createdBy   - Dreamwares
 * @createdDate - 12/22/2015
 */
public with sharing class sitemapController {
    
    public transient List< List< UrlSetWrapper > > listUrlSetWrapper{ get; set; }
    
    public List< String > listAvailableTrucksUrls{                     // Generate Url for available trucks categories
        get{
            if( listAvailableTrucksUrls == null  ){
                List< String > listCategories = Utilities.generatePicklistValues( new Product2(),'apparatusType__c' );
                List< String > listAvailableTrucksUrls = new List< String >();
                String strUrlcode, trucksUrl = 'https://www.firetruckmall.com/AvailableTrucks/';
                
                for( String strCategory : listCategories ){    // create map of url codes 
                    strUrlcode = Utilities.getCanonicalCategoryValue( strCategory );
                    
                    if( String.isNotBlank( strUrlcode )){
                        listAvailableTrucksUrls.add( trucksUrl + strUrlcode.replace('&','%26').replace('\'','%27') );
                    }
                }
                return listAvailableTrucksUrls;
            }
            return null;
        }
        set;
    }
    
    
    public sitemapController(){        // controller
        createListUrlSetWrapper();
    }
    
    /*
    @description  - Create Wrapper records for storing Available truck urls and lastmodified time of products
    */
    private void createListUrlSetWrapper(){
        List< UrlSetWrapper > setUrlsetMappers = new List< UrlSetWrapper >();
        this.listUrlSetWrapper = new List< List< UrlSetWrapper > >();
        UrlSetWrapper objUrlSetWrapper;
        String canonicalUrl, strDate;
        for( Product2 currentProduct : fetchProducts() ){
            
            canonicalUrl = generateCanonicalProductUrl( currentProduct );                  // get canonical value for url
            if( String.isNotBlank( canonicalUrl ) ){
                strDate = String.valueOf( currentProduct.LastModifiedDate.format('YYYY-MM-dd'));
                objUrlSetWrapper = new UrlSetWrapper( canonicalUrl, strDate );
                setUrlsetMappers.add( objUrlSetWrapper );
            }
            
            if( setUrlsetMappers.size() == 1000 ){                                        // 1000 record limit for a repeat tag
                this.listUrlSetWrapper.add( setUrlsetMappers );
                System.debug('setUrlsetMappers:'+setUrlsetMappers.size());
                setUrlsetMappers = new List< UrlSetWrapper >();
            }
        }
        if( setUrlsetMappers.size() > 0 && setUrlsetMappers.size() < 1000 ){             // place the remaining records in the list
            this.listUrlSetWrapper.add( setUrlsetMappers );
        }
    }
    
    /*
    @description  - get canonical value for product url
    @inputParams  - Product record
    @outputParams - String with canonical value
    */
    private String generateCanonicalProductUrl( Product2 objProduct ){
        if( objproduct != null ){
            String truckPageUrl = 'https://www.firetruckmall.com/AvailableTruck/';
            String strCanonicalUrl = String.format('{0}{1}',
                                             new String[]{ truckPageUrl,
                                                             Utilities.getTruckDetailPageUrlParams(objProduct)});
            return strCanonicalUrl;
        }
        return null;
    }
    
    /*
    @description  - fetch required products for generating availabletruck url
    @outputParams - List of products
    */
    private List< Product2 > fetchProducts(){
        Id truckRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Trucks').getRecordTypeId();
        
        if( truckRecordTypeId != null ){
            try{
                return [ SELECT Id, Stock_Number__c, VF_Main_Title__c, LastModifiedDate 
                         FROM Product2
                         WHERE RecordTypeId =: truckRecordTypeId
                               AND Stock_Number__c != null
                               AND IsActive = True 
                               AND Post_To_Website__c = True 
                               AND ( status__c='Available'
                                     OR status__c='HOD'
                                     OR status__c='Internal HOD'
                                     OR status__c='On Lease')
                               LIMIT 50000];
            }
            catch( Exception e ){
                System.debug('Exception in fetching products ::: '+ e);
            }
        }
        return null;
    }
    
    /*
     * @description - Wrapper class to save url and time values for UrlSet
     * 
     */
    public class UrlSetWrapper{
        public String strUrl{ get; set; }
        public String strDate{ get; set; }
        
        public UrlSetWrapper(String strUrl, String strDate){
            this.strUrl = strUrl;
            this.strDate = strDate;
        }
    }
    
}