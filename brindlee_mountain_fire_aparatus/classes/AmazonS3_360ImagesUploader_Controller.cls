/*
    Controller for vf page AmazonS3_360ImagesUploader used to upload 360 view images to Amazon S3
    @author Dreamwares (Aditya S.)
    @createdDate 2016/10/14
 */
public with sharing class AmazonS3_360ImagesUploader_Controller {

    public String getLoginCredentials(){    // API credentials for AWS
        List<AWS_Credentials__c> listAWSCredentials = AWS_Credentials__c.getAll().values();
        return !listAWSCredentials.isEmpty() ? JSON.serialize(listAWSCredentials[0]) : null;
    }
}