/**
* @ Description : Test class for AmazonS3FileUploaderController.
* @ Created Date : 23 Jan 2018
* @ Author : Dreamwares
*/
@isTest
public class AmazonS3FileUploaderController_Test {
    
    /*
    * @ Purpose : Method to create testData   
    */
    @testSetup
    static void dataSetup() {
        createCustomSetting();
        createFireTruckRecord();
    } 
    
    /*
    * @ Purpose : Method to test InsertCloudDoccumentRecord.            
    */
    private static testMethod void testInsertCloudDoccumentRecord() {
        
        Fire_Truck__c fireTruckRecord = [SELECT Id, Main_Title__c FROM Fire_Truck__c WHERE Main_Title__c =: 'Test Record'];
 
        Test.startTest();
        
        Response responseRec1 = new Response(true, null,'this is test');
        Response responseRec2 = new Response(true, null,'this is test', null);
        
		ApexPages.StandardController sc = new ApexPages.StandardController(fireTruckRecord);        
        AmazonS3FileUploaderController AWS3 = new AmazonS3FileUploaderController(sc);
        
        PageReference pageRef = Page.UploadFireTruckAssest;
        pageRef.getParameters().put('id', String.valueOf(fireTruckRecord.Id));
        Test.setCurrentPage(pageRef);
        
        AWS3.getLoginCredentials();
        
        String cloudDataJSONStr = '[{"Name":"A_Child_And_UFO.jpg","DragDropToCloud__Contact__c":null,'+
                                  '"Fire_Truck__c": "'+ fireTruckRecord.Id + '","DragDropToCloud__Bucket_Name__c":'+
                                  '"00do0000000jlleea4","DragDropToCloud__Hidden_File_Version_No__c":"00",'+
                                  '"DragDropToCloud__Folder_Id__c":"/0052F000000cTc6QAE/A_Child_And_UFO.jpg",'+
                                  '"DragDropToCloud__Access_Level__c":"public-read-write","DragDropToCloud__Hidden_File_Name__c"'+
                                  ':"A_Child_And_UFO.jpg","DragDropToCloud__Actual_File_Name__c":"A_Child_And_UFO.jpg"}]';
        Response response = AmazonS3FileUploaderController.insertCloudDoccumentRecord( cloudDataJSONStr );
        
        Test.stopTest();
        
        DragDropToCloud__Cloud_Documents__c cloudDocRec = [SELECT Id, Fire_Truck__c FROM DragDropToCloud__Cloud_Documents__c];
        
        System.assertEquals(fireTruckRecord.Id, cloudDocRec.Fire_Truck__c);
    }
    
        
    /*
    * @ Purpose : Method to createCustomSetting            
    */
    private static void createCustomSetting() {
        
        AWS_Credentials__c awsCredentials = new AWS_Credentials__c( AccessKeyId__c='AKIAJZS44NH5UY2WAOQQ',
                                                                    BucketId__c='erisaadvisortools',
                                                                    Name = 'Amazon S3',
                                                                    SecretAccessKey__c='nSEir6gjYKJ/0lJPIHJR+b0/hkgWOw6dkDfhfpoZ' );
        insert awsCredentials;

    }
    
    /*
    * @ Purpose : Method to creat Fire Truck records.            
    */
    private static void createFireTruckRecord() {
    	
        Fire_Truck__c fireTruckRecord = new Fire_Truck__c();
        fireTruckRecord.Main_Title__c = 'Test Record';
        fireTruckRecord.Year_of_Truck__c = 1994;
		fireTruckRecord.Chassis_Manufacturer__c = '3D';
        
        insert fireTruckRecord;
    }

}