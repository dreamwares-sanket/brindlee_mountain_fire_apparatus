/**
* @ Puspose : AmazonS3FileUploaderController controller class for FireTruckAssest VF Page
* @ Created Date : 17 Jan 2018
*/
public with sharing class AmazonS3FileUploaderController {
    
    public List<DragDropToCloud__Cloud_Documents__c> toBeInsertCloundDocumentList{get;set;}
    public String SObjectName{get;set;} 
    public String ObjectApiName{get;set;} 
    
    public AmazonS3FileUploaderController(ApexPages.StandardController acon) { 
        toBeInsertCloundDocumentList = new List<DragDropToCloud__Cloud_Documents__c>();
        SObjectName = 'FireTruckAssest';
        ObjectApiName = 'Fire_Truck__c';
    }
    
    
    public String getLoginCredentials(){    // API credentials for AWS
        List<AWS_Credentials__c> listAWSCredentials = AWS_Credentials__c.getAll().values();
        return !listAWSCredentials.isEmpty() ? JSON.serialize(listAWSCredentials[0]) : null;
    }
    
    /*
    * @ Purpose : RemoteAction Method to insert cloud document record.
    * @ Parameteres : String jsonCloudDocumentList.          
    */
    @RemoteAction
    public static Response insertCloudDoccumentRecord(String jsonCloudDocumentList) {
        System.debug('jsonCloudDocumentList: '+ jsonCloudDocumentList);
        
        List<DragDropToCloud__Cloud_Documents__c> ddcCloudDocList;
        Response response;
        String message;
        
        if(!String.isEmpty(jsonCloudDocumentList) && !String.isBlank(jsonCloudDocumentList)) {
            ddcCloudDocList = 
                (List<DragDropToCloud__Cloud_Documents__c>)JSON.deserialize(jsonCloudDocumentList, List<DragDropToCloud__Cloud_Documents__c>.class);
        } 
        
        if(!ddcCloudDocList.isEmpty()) {
            try {           
                insert ddcCloudDocList; 
                
                message = 'Files Uploaded Successfully';
                response = new Response(null, message, true, null);
            }
            catch(Exception excp) {
                message = 'Exception : ' +excp.getLineNumber()+ ' : ' +excp.getMessage();           
                
                response = new Response(null, message, false, null);
                System.debug(message);
            }
        }
        return response;
    }
   
}