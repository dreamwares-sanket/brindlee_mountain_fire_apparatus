/**
    @Purpose : Tests the functionality --> PhotoGuideController
*/
@isTest
public class PhotoGuideControllerTest{  
   
    /*
        @ Purpose : Test the entire functionality.
    */
    public testmethod static void testFunctionality(){
        Test.startTest();
        
        //insert data
        insert new PumperPictures__c( Name = 'Test Image 1', 
                                      Image_URL__c = 'https://s3.amazonaws.com/00do0000000jlleea4/01t-product2/01to0000008thD9AAI/IMG_09131_%2872%29.jpg',
                                      Image_Description__c = 'Pumper Image 1'
                                    );
        
        insert new RescuePictures__c( Name = 'Test Image 1', 
                                      Image_URL__c = 'https://s3.amazonaws.com/00do0000000jlleea4/01t-product2/01to0000008thD9AAI/IMG_09131_%2872%29.jpg',
                                      Image_Description__c = 'Pumper Image 1' );
        
        insert new AerialPictures__c( Name = 'Test Image 1', 
                                      Image_URL__c='https://s3.amazonaws.com/00do0000000jlleea4/01t-product2/01to0000008thD9AAI/IMG_09131_%2872%29.jpg',
                                      Image_Description__c = 'Pumper Image 1' );
        
        PhotoGuideController instancePhotoGuideController = new PhotoGuideController();     
        
        Test.stopTest();
    }   
}