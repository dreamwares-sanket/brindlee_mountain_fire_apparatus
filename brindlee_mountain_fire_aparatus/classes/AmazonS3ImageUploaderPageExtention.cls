public with sharing class AmazonS3ImageUploaderPageExtention {

    public AmazonS3ImageUploaderPageExtention(ApexPages.StandardController controller) { }
    
    public String getLoginCredentials(){
        List<AWS_Credentials__c> listAWSCredentials = AWS_Credentials__c.getAll().values();
        return !listAWSCredentials.isEmpty() ? JSON.serialize(listAWSCredentials[0]) : null;
    }

}