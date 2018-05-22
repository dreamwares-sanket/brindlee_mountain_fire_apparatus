/*
    Test class for Controller of vf page AmazonS3_360ImagesUploader
    @author Dreamwares (Aditya S.)
    @createdDate 2016/10/20
 */
@isTest
public class AmazonS3_360ImagesUploaderControllerTest {
	
    @isTest
    private static void testAWSCredentials_CustomSettings(){
        insert new AWS_Credentials__c(
                    Name='Test'
               );
        String.isNotBlank(new AmazonS3_360ImagesUploader_Controller().getLoginCredentials());
    }
    
}