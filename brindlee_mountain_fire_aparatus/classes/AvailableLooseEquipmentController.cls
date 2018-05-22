/*
 * Controller for vf page LooseEquipmentListing to display Products with Loose Equipment record type
 *
 * @createdDate 2016/09/08
 * @author Aditya S. (Dreamwares)
 */
public with sharing class AvailableLooseEquipmentController {

    public String strMainImageURL { get; set; }
    
    public String availableLooseEquipmentsUrl {
        get{
            availableLooseEquipmentsUrl = '';
            Map<String, String> mapPageParams = ApexPages.CurrentPage().getParameters();
            
            List<String> listParams = new List<String>{ 'price', 'category' };
            for( String param : listParams ){
                availableLooseEquipmentsUrl += getUrlValues( param, mapPageParams );
            }
            availableLooseEquipmentsUrl = availableLooseEquipmentsUrl.replaceFirst('&','?');
            return String.isNotBlank(availableLooseEquipmentsUrl) ?  Page.AvailableLooseEquipments.getUrl() + availableLooseEquipmentsUrl : null;  // prepend page name to url
        } set; }
        
    public List<Product2> listSimilarProducts{ get; set; }
    public List<DragDropToCloud__Cloud_Documents__c> listCloudDocuments{ get; set; }    // list of cloud docs to display in image gallery
    
    private String getUrlValues( String param, Map<String, String> mapPageParams ){
        return mapPageParams.containsKey(param) ? String.format('&{0}={1}', new List<String>{ param, mapPageParams.get(param) }) : '';
    }
    
    public AvailableLooseEquipmentController(ApexPages.StandardController controller) {    // Constructor
        if( controller != null ){
            Product2 currentProduct;
            if( !Test.isRunningTest() ){
                controller.addFields(new List<String>{ 'Loose_Equipment_Type__c' });
                currentProduct = (Product2)controller.getRecord();
            }
            else{
                currentProduct = (Product2)controller.getRecord();
                currentProduct.Loose_Equipment_Type__c = 'Rescue Tools';
            }
            
            
            fetchRelatedCloudDocs(currentProduct.Id);
            filterCloudDocImageURLs();
            
            fetchSimilarProducts(currentProduct.Id, currentProduct.Loose_Equipment_Type__c);
        }
    }
    
    /*
        Fetch related image urls from Cloud Document records 
    */
    private void fetchRelatedCloudDocs( Id ProductId ){
        if( String.isNotBlank( ProductId )){
            try{
                listCloudDocuments = new List< DragDropToCloud__Cloud_Documents__c >([ SELECT Id, Main_Image__c, Main_Thumbnail__c, Amazon_S3_Image_Thumbnail_URL__c,
                                                                                              DragDropToCloud__Folder_Id__c, Amazon_S3_Image_URL__c
                                                                                       FROM DragDropToCloud__Cloud_Documents__c
                                                                                       WHERE Product__c =: ProductId 
                                                                                             AND Show_Online__c = True
                                                                                      ]);
            }
            catch( Exception e){
                System.debug('Exception in fetching Cloud Documents ::: '+ e);
            }
        }
    }
    
    /*
        Set the image URLs for images displayed as main image and gallery images
    */
    private void filterCloudDocImageURLs(){
        if( listCloudDocuments != null && !listCloudDocuments.isEmpty() ){
            DragDropToCloud__Cloud_Documents__c objCloudDoc;
            Integer count = listCloudDocuments.size()-1;
            
            while( count >= 0 ){    // iterate over cloud Docs from the rear end
                objCloudDoc = listCloudDocuments.get(count);
                
                if( objCloudDoc.Main_Image__c && String.isNotBlank( objCloudDoc.Amazon_S3_Image_URL__c )){    // Extract main image url and remove from list
                    strMainImageURL = objCloudDoc.Amazon_S3_Image_URL__c;
                    listCloudDocuments.remove(count);
                }
                else if( objCloudDoc.Main_Thumbnail__c ){
                    listCloudDocuments.remove(count);
                }
                count--;
            }
        }
    }
    
    /*
        Fetch Products having similar ApparatusType
        @param Product Id     
        @param Product ApparatusType
    */
    private void fetchSimilarProducts( Id ProductId, String category ){
        if( String.isNotBlank(category) && String.isNotBlank( ProductId )){
            Id looseEqpmntRecTypeId = Utilities.getProductRecordTypeId('Loose Equipment');
            
            try{    // fetch products other than current product
                listSimilarProducts = new List<Product2>([ SELECT Loose_Equipment_Type__c, Equipment_Price__c, Name, Description,
                                                                  ( SELECT id, Amazon_S3_Image_URL__c, Amazon_S3_Main_Thumbnail_URL__c
                                                                    FROM Cloud_Documents__r
                                                                    WHERE Show_Online__c = TRUE AND
                                                                          Main_Thumbnail__c = TRUE LIMIT 1)
                                                            FROM Product2
                                                            WHERE Id !=: ProductId
                                                                  AND Loose_Equipment_Type__c = :category
                                                                  AND RecordTypeId = :looseEqpmntRecTypeId
                                                            LIMIT 4 ]);
            }
            catch( Exception e ){
                System.debug('Exception in fetching similar products ::: '+ e);
            }
        }
    }
    
    public String getLoginCredentials(){
        List<AWS_Credentials__c> listAWSCredentials = AWS_Credentials__c.getAll().values();
        return !listAWSCredentials.isEmpty() ? JSON.serialize(listAWSCredentials[0]) : null;
    }
    
    /*
        Get Company contact info. from Custom Settings
    */
    public CompanyContactInformation__c  getCompanyContactInfo(){
        return CompanyContactInformation__c.getValues('BMFA Contact Information');
    }
}