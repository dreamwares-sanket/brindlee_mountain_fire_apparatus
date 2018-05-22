/**
 *  Controller Extension for vf pages LooseEquipmentPDF and TruckDetailsPDF
 *  @author  Dreamwares [Amol]
 *  @lastModifiedOn 2016/09/16
 *  @lastModifiedBy Dreamwares [Aditya S.] 
 */
public class TruckDetailsPDFController {

    public Transient CompanyContactInformation__c companyContactInfo{ get; private set; }
    public Transient String strMainImageURL{get; set;}   // URL for main image

    public TruckDetailsPDFController(ApexPages.StandardController controller) {
        companyContactInfo = new CompanyContactInformation__c();
        
        try {
            companyContactInfo = [SELECT Id, Toll_Free__c, Address__c, Sales_Email__c 
                                  FROM CompanyContactInformation__c 
                                  ORDER BY CreatedDate ASC 
                                  LIMIT 1]; 
        }
        catch (Exception ex){
            System.debug('Error Line:' + ex.getLineNumber() + ' Message: ' + ex.getMessage());
        }
        
        if( controller != null){
            Id productId = controller.getId();
            setMainImageUrl(productId);
        }
    }  
    
    /*
         Fetch main image url from Cloud Document records 
     */
    private void setMainImageUrl(Id ProductId){
        if(String.isNotBlank(ProductId)) {
            try{
                DragDropToCloud__Cloud_Documents__c cloudDoc = ([ SELECT Amazon_S3_Image_URL__c
                                                                  FROM DragDropToCloud__Cloud_Documents__c
                                                                  WHERE Product__c =: ProductId
                                                                        AND Show_Online__c = True
                                                                        AND Main_Image__c = True
                                                                  LIMIT 1 ]);
                strMainImageURL = cloudDoc.Amazon_S3_Image_URL__c;
            }
            catch(Exception e){
                System.debug('Exception in fetching Cloud Documents ::: '+ e);
            }
        }
    }
}