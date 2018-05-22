/*
 * @description - Controller extension class for VF page RecentDeliveries used to display
                  details of sold truck 
 * @dateCreated - 07/09/2015
 * @createdBy   - Dreamwares
 */
public with sharing class RecentDeliveriesController { 
    private PlatformCacheController cacheController = new PlatformCacheController();
    private List< Product2 > listAvailableProdcutsInCache = new List< Product2 >();
    private static final Integer PAGESIZE = 24;
    
    public void initializeProductList() {
        listAvailableProdcutsInCache = cacheController.getPlatformCahche('listProductRecentDeliveries');//get list from platform cahce
        
        if(listAvailableProdcutsInCache == null) {    
            setCon.setPageSize( 1000 ); // temporarily set page size to get all records to set in cache
            listAvailableProdcutsInCache = (List<Product2>)setCon.getRecords();
            setCon.setPageSize( PAGESIZE );
            
            cacheController.creaetPlatformCahche(listAvailableProdcutsInCache, 'listProductRecentDeliveries');      // records put to cache    
        }
    }

    
    //public Integer pageSize{get; set;}    // number of records on a page
    
    public ApexPages.StandardSetController setCon{    // Set controller for Products
        get{
            if(setCon == null){
            
                List< Product2 > listProducts;
                try{       
                    if(listAvailableProdcutsInCache == null || listAvailableProdcutsInCache.isEmpty()) {         
                        listProducts = new List< Product2 >([ SELECT Id, VF_Main_Title__c, Sold_to_Customer_Account__r.BillingCity, Sold_to_Customer_Account__r.Name,
                                                                     Truck_Public_URL__c, Sold_to_Customer_Account__r.BillingState, Description, 
                                                                     status__c, Post_To_Website__c,
                                                                     ( SELECT ID, Amazon_S3_Main_Thumbnail_URL__c
                                                                       FROM Cloud_Documents__r
                                                                       WHERE Show_Online__c = TRUE
                                                                               AND Main_Thumbnail__c = True LIMIT 1 )
                                                             FROM Product2
                                                             WHERE status__c = 'Sold' AND Post_To_Website__c = True AND Blue_Date__c != null
                                                             ORDER BY Blue_Date__c DESC
                                                             LIMIT 1000]);            
                   
                       listAvailableProdcutsInCache = listProducts;
                   }     
                   else {
                       listProducts = listAvailableProdcutsInCache;
                   }                                
                   setCon = new ApexPages.StandardSetController( listProducts );

                }
                catch( Exception e ){
                    System.debug('Exception in fetching StandardSetController records ::: '+ e);
                }           
                setCon.setPageSize( PAGESIZE );
            }
            return setCon;
        } set;
    }
    
    Public List< Product2 > getProducts(){    // return current list of Products
        List< Product2 > listProducts = new List< Product2 >();        
        if( setCon != null && !setCon.getRecords().isEmpty() ){
            listProducts = (List< Product2 >)setCon.getRecords();
        }
        return listProducts;
    }
    
    public Boolean hasNext{    // Boolean to confirm next set of records exists in List 
        get {
            return setCon.getHasNext();
        }
        set;
    }
    
    public Boolean hasPrevious{    // Boolean to confirm previous set of records exists in List 
        get {
            return setCon.getHasPrevious();
        }
        set;
    }
  
    public Integer pageNumber{    // return page number from set controller
        get {
            return setCon.getPageNumber();
        }
        set;
    }
    
    public Integer getTotalPages(){    // return total number of pages 
        Integer resultSize = setCon.getResultSize();
        return Math.mod(resultSize,PAGESIZE) == 0 
               ? resultSize / PAGESIZE 
               : (resultSize/PAGESIZE)+1;
    }
    
    // Constructor
    public RecentDeliveriesController(){
        
        try{    // set page number from url param
            changePageNumber( Integer.valueOf(ApexPages.CurrentPage().getParameters().get('page')));
        }
        catch( Exception e ){
            SYstem.debug('Exception in getting page no. from Url ::: '+ e );
        }
    }
    
    /*
    @description - Set page number from picklist
    @caller - Action function "gotoPage" from visualforce page
    */
    public void gotoPageNumber(){
        try{
            // convert page number parameter from string to integer datatype
            changePageNumber(Integer.valueOf( ApexPages.CurrentPage().getParameters().get('pagenumber')));
        }
        catch( Exception e){
            System.debug('Exception ::: ' + e);
        }
    }
        
    /*
    @description - Change page number of page from picklist value or URL
    */
    public void changePageNumber( integer intNewPageNumber ){
        
        if( intNewPageNumber != null ){
            integer currentPages = getTotalPages();
            if( intNewPageNumber > currentPages ){
                intNewPageNumber = currentPages;
            }
            setCon.setPageNumber( intNewPageNumber );
        }
    }
        
    // display first page
    public void showFirstPage(){
        setCon.first();
    }
    
    // display last page
    public void showLastPage(){
        setCon.last();
    }
    
    // display previous page
    public void showPreviousPage(){
        setCon.previous();
    }
    
    // display next page
    public void showNextPage(){
        setCon.next();
    }
    
}