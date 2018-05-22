/*
 * VF page controller for an RSS feed for Product records
 * 
 * @author Dreamwares (Aditya S.) 
 * @created 08/07/2016
 */
public class TrucksForSale_RSSFeeds_Controller{

    /*
    7/21/2016 @ 11:23 PM CST:
    Note from Matt about the Amazon S3 file in query. Do not query the Amazon_S3_Image_Thumbnail_URL__c field.
    Use the Amazon_S3_Image_URL__c field.  For the record where Main_Thumbnail__c = TRUE there is not
    a thumbnail.  The main image IS the thumbnail.  Let me know if you have any questions.
    
    */
    
    public List<Product2> getListProducts(){
        return [ SELECT FT_Main_Title__c, Truck_Public_URL__c, Description, apparatusType__c, Posting_Date__c,
                        ( SELECT Amazon_S3_Image_URL__c
                          FROM Cloud_Documents__r
                          WHERE Main_Thumbnail__c = true
                                AND Show_Online__c = true LIMIT 1 )
                 FROM Product2
                 WHERE Post_to_Fireapparatus_com__c = true
                       AND RecordTypeId =: Utilities.getTruckRecordTypeId()
                       AND status__c = 'Available'
                 ORDER BY Listing_Date__c DESC NULLS LAST
                 LIMIT 10000 ];
    }
}